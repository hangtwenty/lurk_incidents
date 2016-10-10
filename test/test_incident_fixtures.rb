# this test file is more magical than anything I normally do myself in Python
# but I figured I'd try out some magic. when in Rome...
# so, to what end?
#
# one of the main things this tool needs to do is grab Incidents correctly,
# and that should work right even in some tricky or suprising cases.
#
# this test suite is set up so you can drop in a 'tricky case' verbatim like:
#       ./test/fixtures/incidents/given/#{uuid}.json
# ... and then another one, with JUST the expectations you care about, as
#       ./test/fixtures/incidents/expected/#{uuid}.yaml (note: YAML!!!)
# and this test suite will pick it up and make sure that we do it right.
#
# NOTES on the EXPECTED files!
#   - the "expected"is NOT the statuspage json format, RATHER it corresponds to the `Incident` class.
#   - YAML! not JSON. made the expected cases as YAML since they are hand-edited and that's easier...
# ... and all those notes should make sense if you think about 'em :)
#
# for best results, make sure your 'expect' cases are restricted ONLY relevant data (tolerant reader).
#
# TODO is there a cleaner way to do this out of the box in ruby? (couldn't find one from initial searching)

# stdlib
require 'json'
require 'yaml'

# third party
require 'colorize'

# test only
require "minitest/autorun"

# relative
require './incident.rb'

def load_all_cases
  cases = Hash.new
  puts "[.] #{File.basename(__FILE__).light_magenta} | loading fixtures"
  Dir.glob("./test/fixtures/incidents/given/*.json") do |given_fn|
    begin
      f = File.open(given_fn, "r")
      given_data = JSON.load f
    ensure
      f.close
    end

    expected_fn = File.join(
        "./test/fixtures/incidents/expected",
        File.basename(given_fn, ".json") + ".yaml")
    begin
      f = File.open(expected_fn, "r")
      expected_data = YAML.load_file(f)
    ensure
      f.close
    end 

    # if it proves not viable to use the uuid here, 
    # can switch to counter or somesuch
    case_name = File.basename(given_fn, ".json")

    cases[case_name] = {
      :given => given_data,
      :expected => expected_data,
    }

    puts "    loaded case #{case_name.cyan} "
    puts "           :given    from #{given_fn.yellow}"
    puts "           :expected from #{expected_fn.green}"

  end
  puts "[.] #{File.basename(__FILE__).light_magenta} | " +
       "loaded #{cases.count} cases from fixtures"
  cases
end

class TestIncidentFixtureSpecs < Minitest::Test
  @@cases = load_all_cases

  @@cases.each {|case_name, this_case|

    # XXX(hangtwenty) just a little note on the magic here...
    # I wanted separate reporting per case, like I get from py.test.
    # turns out I don't need a library/framework for the magic,
    # Ruby gives you access to the drawer full of knives, no questions asked!
    define_method("test_incident_fixture_spec__#{case_name}") do
      incident = Incident.new this_case[:given]
      expected = this_case[:expected]
      expected.each {|name, expected_value|

        # ask the Incident instance for the attr or method w/ that name
        actual = incident.send(name)

        # edgecase for datetimes ... <SomeDateTime>.to_s doesn't go to same precision as the original data.
        # original data (from statuspage json originally, now saved to yaml) -- goes to 3 decimals...
        #-"2016-09-07T11:01:36-07:00"
        #+"2016-09-07T11:01:36.719-07:00"
        begin
          actual_s = actual.iso8601(3)
        rescue NoMethodError
          actual_s = actual.to_s
        end

        # make sure it's what we expect (stringify both operands...)
        assert_equal(actual_s, expected_value.to_s)
      }
    end
  }
  
end
