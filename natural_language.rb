require 'highscore'


# configuration block gets passed to Highscore::Content.new(...).configure
# (see https://github.com/domnikl/highscore for full options)
HIGHSCORE_CONFIGURE = lambda {|arg|
  set :ignore_case, true             # => default: false

  #TODO get stemming back, it cleans things up; but, how to unstem for display?
  set :stemming, true                # => default: false 
}

# TODO(hangtwenty) path to blacklist should be configurable
HIGHSCORE_BLACKLIST = Highscore::Blacklist.load_file "blacklist.txt"

# example usages:
#   - play safe w/ facade: `Keywordable.new(s).keywords_strings(top=20)`
#   - against the underlying API:
#       `Keywordable.new(s).top(20).map{|kw| [kw.text, kw.weight]}`
# (see for more methods: 
# https://github.com/domnikl/highscore/blob/master/lib/highscore/keywords.rb)
# (just a facade for highscore API to separate some concerns)
class Keywordable

  def initialize(text, blacklist=HIGHSCORE_BLACKLIST)
    @highscore_content = Highscore::Content.new(text, blacklist)
    @highscore_content.configure(&HIGHSCORE_CONFIGURE)
  end

  # analyze and return Highscore::Keyword
  def keywords
    @highscore_content.keywords
  end

  # analyze and return keywords like ["foo", "bar", "baz"]
  def to_strings(top=nil)
    unless top.nil?
      keywords.top(top).map(&:text)
    else
      keywords.rank.map(&:text)
    end
  end

  # analyze and return pairs like [("foo", 1.0), ("bar", 0.6)...]
  def to_strings_and_ranks(top=nil)
    unless top.nil?
      keywords.top(top).map{|kw| [kw.text, kw.weight]}
    else
      keywords.rank.map{|kw| [kw.text, kw.weight]}
    end
  end
end


# keywordable from all the blurbs array of incidents
# (can be any objects with #blurb)
def get_keywordable_from_blurbs(incidents)
  megablurb = incidents.map(&:blurb).join("\n\n\n\n")
  Keywordable.new megablurb
end
