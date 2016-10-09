#require 'rubygems' <-- wow religious debate around this, interesting... so much to learn...

require 'colorize'
require 'json'
require 'mechanize'
require 'uri'

TARGET = URI('https://status.shopify.com/history')
puts "TARGET = ".green + TARGET.host.white

agent = Mechanize.new

page = agent.get TARGET
links_incidents = page.links.select { |link| 
    is_same_host = link.uri.host.nil? || link.uri.host == TARGET.host
    is_same_host && link.uri.path.start_with?('/incidents/') 
}.uniq

# FIXME temporary shortening
links_incidents = links_incidents[0,3]

# TODO multithread this, just for kicks?
incidents_json = links_incidents.collect { |link| 
    # maybe mechanize has a trick to save this trouble, but straightforward is good'nuff for me
    uri = link.uri.clone
    uri.host = TARGET.host
    uri.scheme = TARGET.scheme
    uri.path = uri.path + ".json"
    JSON.parse(agent.get(uri.to_s).content)
}

puts incidents_json

