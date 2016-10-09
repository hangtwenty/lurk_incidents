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
