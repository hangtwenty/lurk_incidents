as long as every statuspage instance allows the '.json' to happen, there's no need to do an alternate implementation based on HTML scraping.
but. if that changes, or you encounter a statuspage where it doesn't allow '.json' ...
you would subclass (or just satisfy interface of) `Incident`, and implement all the methods as getting data from HTML instead o' json.

here are the fiddly bits I've thought of in the process though (warnings):

- in the JSON that is returned, there's an `id` field ... I don't think you find the equivalent in the HTML anywhere. BUT it's the same thing
shown in the URL. so you can just get it from the URL path.


----

note on the test suite -- the magical `incidents_fixtures` file

    NOTES on the future:
      - the way it's set up, you could add *multiple* givens under the same name, different extension,
      and it would try each against one 'given'... so that means if this eventually also supported
      scraping from HTML (rather than just the json), you could grab both, and make this check parity
      regardless of input data format, too.
