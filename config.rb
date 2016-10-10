require 'ostruct'
require 'uri'
require 'yaml'

require 'colorize'

require './incident.rb'
require './util.rb'

LurkConfig = OpenStruct.new

# defaults
LurkConfig.default_target_url = URI("http://metastatuspage.com/history")
LurkConfig.top_cache_dir = "/tmp/lurk_incidents_cache"
LurkConfig.sleep_seconds = 0.5

# TODO -- make path to config itself configurable via command-line switch.
config_path = File.join(Dir.pwd, "lurk_incidents.yaml")
begin
  config = YAML.load_file(config_path)

  LurkConfig.default_target_url = URI(config["target"])

  if config["cache"] && config["cache"]["enabled"]
    top_cache_dir = config["cache"]["directory"] 
    mkdir_p(top_cache_dir)
    puts "[.] LurkConfig.top_cache_dir = ".green + top_cache_dir
  else
    top_cache_dir = nil
    puts "[.] LurkConfig.top_cache_dir = ".green + "disabled".red 
  end
  if config["politeness"]
    LurkConfig.sleep_seconds = config["politeness"]["sleep_seconds"]
  end
rescue IOError
  puts "[.] couldn't read config from #{config_path}, using defaults".yellow
end
