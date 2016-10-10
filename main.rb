require './config.rb'
require './incident.rb'
require './web.rb'
require './util.rb'


puts "[.] GATHERING. ".green
puts "[.] gathering incidents.".green

# TODO take arg from CLI or app
target_url = LurkConfig.default_target_url
incident_uris = get_links_to_incidents(target_url)
incidents_data = get_incidents_data(incident_uris)

puts "[.] GATHERING done. ".green
puts "[.] PROCESSING. ".green

incidents = select_incidents(incidents_from_json(incidents_data))

incidents.each { |incident|
    puts incident.inspect
}
