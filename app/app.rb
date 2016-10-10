# sinatra (etc.) must be all the way at top it seems
require 'sinatra'
require 'sinatra/param'

# stdlib
require 'uri'

# other third party
require 'active_support'
require 'active_support/core_ext'
require 'chartkick'
#require 'descriptive_statistics/safe'

# my repo
require_relative '../config.rb'
require_relative '../fetch.rb'
require_relative '../incident.rb'
require_relative '../stat.rb'


get '/' do
  @target_url = LurkConfig.default_target_url
  @data = nil
  erb :index
end

post '/' do
  param :target_url,    String, required: true, format: URI.regexp, raise: true
  @target_url = params[:target_url]
  @incidents = get_incidents(@target_url)
  @outliers = {
    :duration_seconds_max => get_outliers(@incidents, :duration_seconds, :max),
    :duration_seconds_min => get_outliers(@incidents, :duration_seconds, :min)
  }
  @incidents_exclude_long = @incidents.select{|incident|
    !@outliers[:duration_seconds_max].include? incident.duration_seconds
  }
  @incidents_exclude_short = @incidents.select{|incident|
    !@outliers[:duration_seconds_min].include? incident.duration_seconds
  }
  erb :index
end
  
error Sinatra::Param::InvalidParameterError do
  {error: "#{env['sinatra.error'].param} is invalid"}.to_json
end

