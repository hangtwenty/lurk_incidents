require './config.rb'
require './fetch.rb'
require './incident.rb'
require './natural_language.rb'
require './util.rb'

target_url = LurkConfig.default_target_url

incidents = get_incidents(target_url)
puts "[.] LOADED: #{incidents.size} incidents".green

incidents.each { |incident|
  puts "    #{incident.inspect.light_black}"
}

puts "[.] KEYWORD TIME!".green
keywordable = get_keywordable_from_blurbs(incidents)
keywordable.to_strings_and_ranks(100).each{|keyword, rank|
    puts "    #{keyword.light_magenta}\t#{rank}"
}
