#require 'rubygems' <-- wow religious debate around this, interesting... so much to learn...

require 'colorize'
require 'json'
require 'mechanize'
require 'uri'

require './util.rb'

TARGET = URI('https://status.shopify.com/history')      # TODO make this come in from a CLI arg (use docopt)
puts "[.] TARGET = ".green + TARGET.host.white

agent = Mechanize.new

page = agent.get TARGET
links_incidents = page.links.select { |link| 
    is_same_host = link.uri.host.nil? || link.uri.host == TARGET.host
    is_same_host && link.uri.path.start_with?('/incidents/') 
}.uniq

my_parent_dir = File.expand_path(File.dirname(__FILE__))
cache_dir = File.join(my_parent_dir, "cache")
Dir.mkdir(cache_dir) unless File.exists?(cache_dir)
puts "[.] cache_dir = ".green + cache_dir.cyan


# TODO multithread this, just for kicks - to see how that works in ruby?
incidents_uris = links_incidents.collect { |link| 
    # bit o boilerplate to get the '.json' version of each link... and make absolute
    uri = link.uri.clone
    uri.host = TARGET.host
    uri.scheme = TARGET.scheme
    uri.path = uri.path + ".json"
    uri
}

puts "[.] gathering incidents.".green
# 'get or create' the data blob for each incident... just to be polite if I run this script many times.
# ASSUMPTION: it is OK to cache the incident data blobs, because incidents in the past should not get updates.
incidents_data = incidents_uris.collect { |uri| 
    # check if file exists with this incident key.
    uuid = get_incident_uuid(uri)
    filename = File.join(cache_dir, uuid)

    if File.exists?(filename)
      puts "incident #{uuid.green} cached. loading."
      data = File.open(filename, 'r') { |f| f.gets }
    else

      # FIXME after fetching the incident, should actually json-parse to check if it has been resolved... if not, DO NOT cache it. in fact, entirely discard it.
      # it wouldn't make sense if you ran this script while an incident was in progress, then permanently saved its intermediate, unresolved state.

      puts "incident #{uuid.yellow} fetching live... caching."
      # fetch it 
      data = agent.get(uri.to_s).content
      # save it
      File.open(filename, 'w') { |f| f.write(data) }
    end

    data
}

puts incidents_data

incidents_data.each { |obj|
    puts JSON.parse obj
}

