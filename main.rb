#require 'rubygems' <-- wow religious debate around this, interesting... but I hear the arguments against :)

require 'date'
require 'json'
require 'uri'
require 'yaml'

require 'colorize'
require 'mechanize'

require './util.rb'

# TODO move the settings to a ./settings.rb module
#=== settings ===
def mkdir_p(path)
  Dir.mkdir(path) unless File.exists?(path)
end

# TODO -- make path to config itself configurable via command-line switch.
settings_path = File.join(Dir.pwd, "lurk_incidents.yml")
settings = YAML.load_file(settings_path)
TARGET = URI(settings["target"])
if settings["cache"] && settings["cache"]["enabled"]
  top_cache_dir = settings["cache"]["directory"] 
  mkdir_p(top_cache_dir)
  cache_dir = File.join(top_cache_dir, TARGET.host)
  mkdir_p(cache_dir)
  puts "[.] cache_dir = ".green + cache_dir
else
  cache_dir = nil
  puts "[.] cache_dir = ".green + "disabled".red 
end

if settings["politeness"]
  sleep_seconds = settings["politeness"]["sleep_seconds"]
end
#=== settings ===

puts "[.] GATHERING. ".green
puts "[.] requesting ".green + TARGET.to_s
agent = Mechanize.new
page = agent.get TARGET
links_incidents = page.links.select { |link| 
  is_same_host = link.uri.host.nil? || link.uri.host == TARGET.host
  is_same_host && !link.uri.path.nil? && link.uri.path.start_with?('/incidents/') 
}.uniq


# TODO multithread this, just for kicks - to see how that works in ruby?
incidents_uris = links_incidents.collect { |link| 
  # bit o boilerplate to get the '.json' version of each link... and make absolute
  uri = link.uri.clone
  uri.host = TARGET.host
  uri.scheme = TARGET.scheme
  uri.path = uri.path + ".json"
  uri
}

# FIXME ---- the filename should be "incident_#{uuid}" just cos namespacing is good

puts "[.] gathering incidents.".green
# 'get or create' the data blob for each incident... just to be polite if I run this script many times.
# ASSUMPTION: it is OK to cache the incident data blobs, because incidents in the past should not get updates.
incidents_data = incidents_uris.collect { |uri| 
  # check if file exists with this incident key.
  uuid = get_incident_uuid(uri)

  if cache_dir 
    cache_filename = File.join(cache_dir, "#{uuid}.json")
  else
    cache_filename = nil
  end

  if cache_dir && File.exists?(cache_filename)
    data = File.open(cache_filename, 'r') { |f| f.gets }
    puts "incident #{uuid.green} was in " + "cache. ".cyan + "loaded.".green
  else
    # FIXME handle edge case -- after fetching the incident, should actually json-parse to check if it has been resolved... if not, DO NOT cache it. in fact, entirely discard it.
    # it wouldn't make sense if you ran this script while an incident was in progress, then permanently saved its intermediate, unresolved state.

    print "incident #{uuid.yellow} fetching live... "

    data = agent.get(uri.to_s).content
    print "fetched. ".green
    if cache_dir && cache_filename
      File.open(cache_filename, 'w') { |f| f.write(data) }
      print "cached. ".cyan
    end
    if sleep_seconds
      print "sleep #{sleep_seconds}.".magenta
      sleep sleep_seconds
    end

    puts
  end

  data
}

puts "[.] GATHERING done. ".green
puts "[.] PROCESSING. ".green


# TODO review this way of doing the classes/subclasses ... 
# got some analysis paralysis with this, since people talk so much bad about plain old inheritance in ruby... 
# JFDI but did I do it OK?
# This class is assuming JSON as the data and all the method implementations are against the JSON.
# but you could easily code a class that subclasses or is just a 'duck' w/ same methods, that works on HTML/scrape.
class Incident

  STATUSES_RESOLVED = ["completed", "resolved", "postmortem"]

  # Initialize with data, e.g. a hash parsed from StatusPage /incidents/#{uuid}.json.
  def initialize( data )
    @data = data
  end

  # unique hash-id from statuspage. from json.
  def uuid
    @data["id"]
  end

  # when the incident started
  def started_at
    DateTime.parse(@data["created_at"])
  end

  # status field.
  def status
    @data["status"].downcase
  end

  # is resolved/completed/postmortem. anything meaning "not still changing."
  def is_ended
    STATUSES_RESOLVED.include? status
  end

  # when the incident ended, if it did...
  def ended_at
    if is_ended
      # edge case I've seen & want to handle: incident has really ended, 
      # and it's marked 'resolved', but only have 'updated_at' ...
      # Since we already know it's marked resolved, take the earlier one.
      resolved_at = @data["resolved_at"] && DateTime.parse(@data["resolved_at"])
      updated_at = @data["updated_at"] && DateTime.parse(@data["updated_at"])
      if resolved_at and updated_at
        return [resolved_at, updated_at].min
      else
        return updated_at || resolved_at
      end
    else
      return nil
    end
  end

  # time between start and end, in seconds.
  def duration_seconds
    if started_at && ended_at
      # subtracting two DateTimes returns time in days. convert to seconds.
      ((ended_at - started_at) * 24 * 60 * 60).to_i
    else
      nil
    end
  end

  # inspect most vital fields, do NOT print whole @data again :)
  def inspect
    "Incident(uuid: #{uuid}, status: #{status}, started_at: #{started_at}, " +
    "ended_at: #{ended_at}, duration_seconds: #{duration_seconds}, ...)"
  end
end 
      

####impact              ( .impact_override || .impact )
####scheduled           ( .title.contains('planned').or.contains('scheduled') || `!.scheduled_*.nil?`)

####updates             ... could keep the list of updates ... as mentioned earlier could be cool to do fancy overlay graphing of timelines, but ...
####    .count          ... just count for now :) that will work for initial graphing

####blurb               ( .postmortem_body + .incident_updates.body[].join )
####keywords            blurb | keyword_extraction()   # use:       https://github.com/domnikl/highscore || https://github.com/louismullie/graph-rank

####publicized          [tweeted ( .twitter* ) ]

incidents = incidents_data.collect { |s|
    #puts JSON.pretty_generate( JSON.parse obj )
    Incident.new JSON.parse(s)
}.select { |incident| 
  if !incident.is_ended
    puts "[!] dropping incident #{incident.uuid}, has not ended. ".red + incident.inspect
    nil
  else
    incident.is_ended
  end
}

incidents.each { |incident|
    puts incident.inspect
}
