require 'date'
require 'json'
require 'uri'

require 'colorize'
require 'mechanize'


# little factory for mechanize agent w/ polite user-agent
def get_mechanize_agent
  agent = Mechanize.new
  agent.user_agent = "benevolent lurk_incidents (https://github.com/hangtwenty/lurk_incidents)"
  agent
end

# given a root target_url (like foo.com/history), get all the incident links
# (does not cache, we want to always grab latest list of incidents)
def get_incident_uris(target_url)
  puts "[.] requesting ".green + target_url.to_s
  page = get_mechanize_agent().get target_url
  links = page.links.select { |link| 
    is_same_host = link.uri.host.nil? || link.uri.host == target_url.host
    is_same_host && !link.uri.path.nil? && link.uri.path.start_with?('/incidents/') 
  }.uniq

  # XXX(hangtwenty) coupled to json here, but, a way to KISS for now.
  # this is the little bit of touchup to do, to make sure we get back json.
  links.collect { |link| 
    uri = link.uri.clone
    uri.host = target_url.host
    uri.scheme = target_url.scheme
    uri.path = uri.path + ".json"
    uri
  }
end

# given a list of URIs to incidents, go get 'em. (get-or-create in cache.)
# (method makes few assumptions about json vs html etc., but note the "XXX"...)
# ASSUMPTION: it is OK to cache the incident data blobs, because incidents 
#   in the past should not get updates.
def get_incidents_raw_data(incidents_uris, 
        top_cache_dir=LurkConfig.top_cache_dir, 
        sleep_seconds=LurkConfig.sleep_seconds)
  agent = get_mechanize_agent

  data = incidents_uris.collect { |uri| 
    # check if file exists with this incident key.
    uuid = get_incident_uuid(uri)

    cache_filename = nil
    host_cache_dir = nil
    if top_cache_dir 
      host_cache_dir = File.join(top_cache_dir, uri.host)
      mkdir_p(host_cache_dir)
      # XXX(hangtwenty) here is a spot coupled to '.json'...
      cache_filename = File.join(host_cache_dir, "#{uuid}.json")
    end

    if host_cache_dir && File.exists?(cache_filename)
      data = File.open(cache_filename, 'r') { |f| f.gets }
      puts "incident #{uuid.green} was in " + "cache. ".cyan + "loaded.".green
    else
      print "incident #{uuid.yellow} fetching live... "

      data = agent.get(uri.to_s).content
      print "fetched. ".green
      if host_cache_dir && cache_filename
        File.open(cache_filename, 'w') { |f| f.write(data) }
        print "cached. ".cyan
      end
      if sleep_seconds
        sleep_seconds_final = sleep_seconds + Random.new.rand(-0.2..0.2)
        print "sleep #{sleep_seconds_final}.".magenta
        sleep sleep_seconds_final
      end

      puts
    end

    data
  }
end


# create Incident instances from list of json strings.
def incidents_from_json(incidents_data)
  incidents_data.collect { |s| Incident.new JSON.parse(s) }
end

# filter out irrelevant incidents (namely, those not yet ended)
def select_incidents(incidents)
  incidents.select { |incident| 
    if !incident.is_ended
      puts "[!] dropping incident #{incident.uuid}, has not ended. ".red + incident.inspect
      nil
    else
      incident.is_ended
    end
  }
end

# top-level function, does All the Things and gives you a list of Incidents
def get_incidents(target_url, 
        top_cache_dir=LurkConfig.top_cache_dir, 
        sleep_seconds=LurkConfig.sleep_seconds,
        sort_by_start=true)

  target_url = URI(target_url)

  puts "[.] GATHERING. ".green
  puts "[.] gathering incidents.".green

  incident_uris = get_incident_uris(target_url)
  incidents_raw_data = get_incidents_raw_data(
      incident_uris,
      top_cache_dir=LurkConfig.top_cache_dir, 
      sleep_seconds=LurkConfig.sleep_seconds)

  puts "[.] GATHERING done. ".green
  puts "[.] PROCESSING. ".green

  all_incidents = incidents_from_json(incidents_raw_data)
  incidents = select_incidents(all_incidents)
  if sort_by_start
    incidents.sort_by(&:started_at)
  else
    incidents
  end
end
