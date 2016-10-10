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



# TODO review this way of doing the classes/subclasses ... 
# got some analysis paralysis with this, since people talk so much bad about plain old inheritance in ruby... 
# JFDI but did I do it OK?
# This class is assuming JSON as the data and all the method implementations are against the JSON.
# but you could easily code a class that subclasses or is just a 'duck' w/ same methods, that works on HTML/scrape.
class Incident

  STATUSES_RESOLVED = ["resolved", "postmortem"]

  # Initialize with data, e.g. a hash parsed from StatusPage /incidents/#{uuid}.json.
  def initialize( data )
    @data = data
  end

  def uuid
    return @data["id"]
  end

  def created_at
    return DateTime.parse(@data["created_at"])
  end

  def is_resolved
    marked_resolved = STATUSES_RESOLVED.include? @data["status"].downcase
    has_resolved_time = !@data["resolved_at"].nil?
    return marked_resolved && has_resolved_time
  end

  def resolved_at
    return is_resolved && DateTime.parse(@data["resolved_at"])
  end

  def duration
    return resolved_at - created_at
  end

  # for purposes here, @data is way too much info, so print (almost) everything else
  def inspect
    "Incident(uuid: #{uuid}, created_at: #{created_at}," +
    "resolved_at: #{resolved_at}, duration: #{duration}, ...)"
  end
end 
      

####end<DateTime>       (.resolved_at)
####finished            [ this one is very pragmatic: we want to filter out anything that does not have status of 'resolved' or 'postmortem' ... or that doesn't have an end ... (don't include an incident ongoing at the time the script was run]
####duration()          ^ calculated from start/end.
####
####impact              ( .impact_override || .impact )
####scheduled           ( .title.contains('planned').or.contains('scheduled') || `!.scheduled_*.nil?`)

####updates             ... could keep the list of updates ... as mentioned earlier could be cool to do fancy overlay graphing of timelines, but ...
####    .count          ... just count for now :) that will work for initial graphing

####blurb               ( .postmortem_body + .incident_updates.body[].join )
####keywords            blurb | keyword_extraction()   # use:       https://github.com/domnikl/highscore || https://github.com/louismullie/graph-rank

####publicized          [tweeted ( .twitter* ) ]
####start<DateTime>     (.created_at || .incident_updates[<earliest>].created_at )
####end<DateTime>       (.resolved_at)
####finished            [ this one is very pragmatic: we want to filter out anything that does not have status of 'resolved' or 'postmortem' ... or that doesn't have an end ... (don't include an incident ongoing at the time the script was run]
####duration()          ^ calculated from start/end.
####
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
  if !incident.is_resolved
    puts "[!] dropping incident #{incident.uuid}, not resolved"
    nil
  else
    incident.is_resolved
  end
}

incidents.each { |incident|
    puts incident.inspect
}
