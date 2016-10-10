# sinatra (etc.) must be all the way at top it seems
require 'sinatra'
require 'sinatra/param'

# stdlib
require 'uri'

# third party
require 'chartkick'

# my repo
require_relative '../config.rb'
require_relative '../fetch.rb'
require_relative '../incident.rb'


get '/' do
  @target_url = LurkConfig.default_target_url
  @data = nil
  erb :index
end

post '/' do
  param :target_url,    String, required: true, format: URI.regexp, raise: true
  @target_url = params[:target_url]
  @incidents = get_incidents(@target_url)
  erb :index
end
  
error Sinatra::Param::InvalidParameterError do
  {error: "#{env['sinatra.error'].param} is invalid"}.to_json
end

