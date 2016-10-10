quoting from http://www.rubydoc.info/gems/spiderkit/0.2.0 ... might be good to do some of this:

    Well Behaved Spiders
    Which is not to say you can't write ill-behaved spiders with this gem, but you're kind of a jerk if you do, and I'd really rather you didn't! A well behaved spider will do a few simple things:

    It will download and obey robots.txt
    It will avoid repeatedly re-visiting pages
    It will wait in between requests / avoid agressive spidering
    It will honor rate-limit return codes
    It will send a valid User-Agent string

    This library is written with an eye towards rapidly prototyping spiders that will do all of these things, plus whatever else you can come up with.

we aren't really crawling much so we're not that bad, but ...
should do probably these ones, just to be nice :)

    It will download and obey robots.txt
    It will honor rate-limit return codes
    It will send a valid User-Agent string (info: http://webmasters.stackexchange.com/questions/6205/what-user-agent-should-i-set)

----

erm yeah from http://webmasters.stackexchange.com/questions/6205/what-user-agent-should-i-set

> If you don't already respect robots.txt, do it. Nothing will get you a bad reputation faster than ignoring robots.txt.
