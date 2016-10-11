## normal usage

- currently I assume you are just cloing this repo then running `ruby main.rb` (I haven't packaged up as a real CLI script, since it feels like a one-off/niche util...)
- configuration is loaded from `$( pwd )/lurk_incidents.yaml`.
    - there's an example for you to start from, `lurk_incidents.yaml.example`
- there's a little chartkick+sinatra app to run local and see lots o' graphs of the incidents.

### not ready for anything serious

still just a toy, and I've noticed some bugs related to my usage of Chartkick (_without_ `Groupdate` or a database or Rails or `ActiveRecords`)... If I make a second cut of this, I will not use a magic library, will instead use JSON and d3 etc.


    Watch out for bugs related to Chartkick

    For some status pages, the order gets screwed up here. Mainly seems to be an issue when there are gaps in the timeseries. Seemingly this is normally OK in Chartkick because of relying on the Groupdate

----

## development, testing

- test suite
    - run it: `rake test`
    - there's some magic to enable data-driven tests :) rationale:
        - I wanted to be able to work with real fixtures for a reg suite of sorts, do this a bit test driven, see how that feels in ruby...
        - ... and I was fully ready to open the knives drawer in Ruby and play with some magic. being a Python programmer usually, this makes me feel so _edgy_ but I figured I'd give it a shot and see if I surprise myself ... hey maybe I'd like it?
        - so, that explains the cleverness in `test_incidents_fixtures.rb` ... which is, anyway, useful in the end. leaving the cleverness there so I can look back at it in a few months and see how I feel about it. a little test on myself. how much do I like the magic? :)
    - to add cases... see `test_incident_fixtures.rb` (has docs)
