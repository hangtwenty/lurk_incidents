# what is this?

Ad-hoc analysis of _someone else's_ [StatusPage.io](https://www.statuspage.io/) status page. Why? Well, if you're _in_ the organization, and you've got auth keys, you can just use the (nice) API it gives you. What if you don't have privileges for auth keys? What if you take a look at status page trends from the outside? Maybe you're going to 

This was a toy project so I could learn some more Ruby. 

## normal usage

- **app for charts.** 
    - there's a little sinatra app to run local and see lots o' graphs of the incidents. graphs use chartkick.
    - run it like `ruby app/app.rb` then go to http://localhost:4567/
- **script for keyword analysis.** there's also `main.rb` which fetches all the incidents
    - _utilitarian note,_ it shares the same cache as the `app.rb`, so if you get timeouts, run `main.rb` first before running app. 
    - **fun note,** also uses [highscore](https://github.com/domnikl/highscore) to do some keyword analysis of the whole set of incidents!
- nitty gritty details for running
    - install with `bundle install`. if anything gives you trouble, check out `Gemfile`, there are some marked as `OPTIONAL` (just optimizations for the [`highscore`](https://github.com/domnikl/highscore) library/ natural language features)
    - currently I assume you are just cloing this repo then running `ruby main.rb` (messy, but, toy)
    - I didn't do anything fancy with async fetching of all the incidents ... and it takes a couple minutes initially. so, you might want to do `main.rb` against your target at least once before you do `app.rb` way... then `app.rb` will be quick (just fetch any NEW incidents since initial fetch). (messy I know, toy project, yadda yadda)
    - configuration is loaded from `./lurk_incidents.yaml` - **you should create this**
        - there's an example for you to start from, `lurk_incidents.yaml.example`

### caveat: not meant for anything serious

#### occasional bugs in the graphs

This affects _some_ but not all runs of this tool. Namely it _does_ affect the most 'neutral' target of all, the [StatusPage of StatusPage](http://metastatuspage.com/). But I tested against another where the bugs did not (seem to) appear.

Where's it come from? Looks like when you use [Chartkick](https://github.com/ankane/chartkick) _without_ `Groupdate` or a database or Rails or `ActiveRecords` ... you can hit some dark magic. (Mainly seems to be an issue when there are (actual) gaps in the timeseries, somehow this doesn't fly well with Chartkick or Google Charts doing some reordering. Seemingly this is normally OK in Chartkick because of relying on the Groupdate?)

##### how that could be fixed

If I develop this further, I'll have to get it away from Chartkick... I won't try to use another magic library, will instead use some plain JavaScript lib, and feed it JSON. Will be more laborious but less buggy.

----

## development, testing

- test suite
    - run suite: `rake test`
    - there's some magic to enable data-driven tests :) **see `test_incident_fixtures.rb`**.  rationale:
        - I wanted to be able to work with real fixtures for a reg suite of sorts, do this a bit test driven, see how that feels in ruby...
        - ... and I was fully ready to open the knives drawer in Ruby and play with some magic. being a Python programmer usually, this makes me feel so _edgy_ but I figured I'd give it a shot and see if I surprise myself ... hey maybe I'd like it?
        - so, that explains the cleverness in `test_incidents_fixtures.rb` ... which is, anyway, useful in the end. leaving the cleverness there so I can look back at it in a few months and see how I feel about it. a little test on myself. how much do I like the magic? :)
    - to add cases... see `test_incident_fixtures.rb` (lengthy docs at top!)
