- mechanize? anemone? // anemone. docs were a little sparse up front but I realize now that's because it assumes a certain audience. those bits that are conspicuously undetailed in the guide - they are just common knowledge to ruby devs and I'm just not there yet w/ ruby :)
- at /history there is /history.rss and /history.atom; I asked myself, can it be used for my purpose?
    - well the RSS is no better than the webpage, it just has links to the incidents, I would still need to crawl
    - the atom features the linked page (no need to crawl!) but it's too few items, not full history. (makes sense since it's a feed.)
    - conclusion: back to scraping :)

----

noticing the incident colors on both /history and on the page once you go to it. in the HTML it is communicated as 'impact-none', 'impact-minor', 'impact-major' etc. I'd like to scrape these ... now, what are all the possible valid values?

... ah, https://help.statuspage.io/knowledge_base/topics/component-status-incident-impact-and-top-level-status-calculations 

    Incident impact can be any of the following...

    None (black)
    Minor (yellow)
    Major (orange)
    Critical (red)
    Maintenance (black)

----

wait a second the "/history.atom", "/history.rss" convention ... well it makes me think these are probably rails apps. do I get "/history.json" ?

this works: https://status.shopify.com/incidents/8vvgpvfj7p0l.json
this does NOT work: https://status.shopify.com/history.json 

so they have disabled that, back to scraping :P

what about my other example case, braintree?

yep same, no '.json' on the /history list, but yes '.json' on the incidents.

well, here is why not to use anemone! already have broken out of the specialized use case... back to mechanize!

----

cool I can get all the incident links from the history page (with the assumption that history page remains a complete list...), then += '.json' and  I get the json ... and yep API is documented here, https://doers.statuspage.io/api/v1/incidents/ ... so now I just have to decide what to do with all this juicy data! shouts out to statuspage.io for making this incredibly easy for me. no hacks needed so far. yee!

this is what I should gather up...

- time from incident open to incident resolved. initial time = (.created_at || .incident_updates[<earliest>].created_at ) until ( .resolved_at )
- accumulate impacts. ( .impact_override || .impact ) ... probably should categorize the incidents, by impact. would be good to chart & calculate separately.
- number of updates per incident. (then can do avg, median, etc.)
- use TextRank against any freeform fields. namely ( .postmortem_body , .incident_updates.body[] )
- scheduled or not -- looking at the json (e.g. https://status.shopify.com/incidents/4zf7pjyytb30.json), I think that *even though* StatusPage gives a client a way to do scheduled things, in a structured way, well of course not everybody adheres to that. so I need to scrape the title for "Planned" or "Scheduled" ... so ( .title.contains('planned').or.contains('scheduled') || `!.scheduled_*.nil?`) ... a heuristic somethin like that
- whether twitter was updated or not.
- OUTTAKE: the updates: investigating, identified, (identified, ...) monitoring, resolved ... pony: it would be nice to see some kind of visual of the curve things take... but I would need a better understanding of the problem (what's allowed per StatusPage?) to do that right.

ok and looking forward to [Chartkick](http://chartkick.com/) / [Groupdate](https://github.com/ankane/groupdate) samples I might try...

- over time, how many incidents per month?
- group_by_hour_of_day -- any tendencies in time of day?
- ok using the TextRank idea, can I group incidents by certain keywords, then do a chart that shows how long certain keywords take to resolve?

so. I think I'll make a class with fields on these points. some pseudocode:

    start<DateTime>     (.created_at || .incident_updates[<earliest>].created_at )
    end<DateTime>       (.resolved_at)
    finished            [ this one is very pragmatic: we want to filter out anything that does not have status of 'resolved' or 'postmortem' ... or that doesn't have an end ... (don't include an incident ongoing at the time the script was run]
    duration()          ^ calculated from start/end.
    
    impact              ( .impact_override || .impact )
    scheduled           ( .title.contains('planned').or.contains('scheduled') || `!.scheduled_*.nil?`)

    updates             ... could keep the list of updates ... as mentioned earlier could be cool to do fancy overlay graphing of timelines, but ...
        .count          ... just count for now :) that will work for initial graphing

    blurb               ( .postmortem_body + .incident_updates.body[].join )
    keywords            blurb | keyword_extraction()   # use:       https://github.com/domnikl/highscore || https://github.com/louismullie/graph-rank

    publicized          [tweeted ( .twitter* ) ]

in python I'd make a base class... then a subclass for the json-backed version (and leave open the possibility of a subclass for an HTML-scraping version, JIC some people have the '.json' disabled on their StatusPages). in ruby, what would be preferred? base class, plus composition - i mean, is this really a case where that kind of indirection is necessary? its seems like one spot where inheritance might be the KISS way ...

hmm yeah actually, this could be even more generic than just StatusPage.io, with a bit of data massaging. I really am just targeting StatusPage.io for now but it's neat that I can structure this in a generally useful way, I'd like to keep that.


----

mmm should probably also have a separate 'components-affected' field, this could be used for grouping/coloring different graphs ...
anyway, ASIDE FROM THAT, add the 'components-affected' words onto 'keywords' cos that makes sense.

----

TODO -- in `get_incidents_data`, there is a little edge case that would be nice to handle

      # FIXME handle edge case -- after fetching the incident, should eagerly json-parse to check if it has been resolved... if not, DO NOT cache it. in fact, entirely discard it.
      # it wouldn't make sense if you ran this script while an incident was in progress, then permanently saved its intermediate, unresolved state.


----

IDEA, snoozing: after done with all the charts and stuff, well it could be cool to  take in *multiple* targets at once, so then one could overlay the graphs and such from several statuspages ... could be cool to see how companies vary in duration of outage ... or if/not they are similar in shortening the duration over time ... well anyway while a novel idea, it would have its own problems, and it doesn't seem worth the effort yet. snooze.

