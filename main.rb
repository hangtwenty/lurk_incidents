#require 'rubygems' <-- wow religious debate around this, interesting... but I hear the arguments against :)

require 'date'
require 'json'
require 'uri'
require 'yaml'

require 'colorize'
require 'mechanize'

require './incident.rb'
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
