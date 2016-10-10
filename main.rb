require './config.rb'
require './fetch.rb'
require './incident.rb'
require './util.rb'


# TODO take arg from CLI or app
target_url = LurkConfig.default_target_url

incidents = get_incidents(target_url)

incidents.each { |incident|
    puts incident.inspect
}
