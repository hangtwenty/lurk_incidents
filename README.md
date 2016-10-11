# what is this?

Kind of a shaky premise, but, this was a toy project so I could learn some more Ruby.

It does some ad-hoc analysis of a [StatusPage.io](https://www.statuspage.io/) incident history -- from the public view, not an API call.

Why? Well indeed, [StatusPage.io has a nice API](https://doers.statuspage.io/api/v1/incidents/), and you can use it if you're inside the organization and you are provided with auth keys. What if you're outside, just curious? What if you're inside, but you're waiting on getting access?

## normal usage

- **little sinatra app shows you graphs and keywords.** 
    - various graphs, currently using Chartkick
    - also does some keyword analysis using [highscore](https://github.com/domnikl/highscore). this is shown in a table. (needs further cleanup but it's a start.)
    - run it: `ruby app/app.rb` then go to http://localhost:4567/

- prerequisites before running
    - install with `bundle install`. if anything gives you trouble, check out `Gemfile`, there are some marked as `OPTIONAL` (just optimizations for the [`highscore`](https://github.com/domnikl/highscore) library/ natural language features)
    - currently I assume you are just cloing this repo, `cd` in, and run from in the directory.
    - configuration is loaded from `./lurk_incidents.yaml` - **you should create this**
        - there's an example for you to start from, `lurk_incidents.yaml.example`
    - lastly. `main.rb` is a little script, not super useful in itself, but **I recommend you run this first** before `app.rb`.
        - why: I didn't do anything fancy with async fetching of all the incidents ... so if you just go straight to `app.rb`, it will block for a couple minutes on the first run, or perhaps even time out. (messy I know, toy project, yadda yadda)
        
### caveats

not meant for anything serious! also...

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
