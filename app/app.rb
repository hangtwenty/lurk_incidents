# sinatra (etc.) must be all the way at top it seems
require 'sinatra'
require 'sinatra/param'

# stdlib
require 'uri'

# third party
require 'chartkick'

get '/' do
  @data = {'Foo' => 70, 'Bar' => 15, 'Baz' => 13, 'quux' => 2}
  erb :index
end

post '/' do
  param :target_url,    String, required: true, format: URI.regexp, raise: true
  @target_url = params[:target_url]
  @data = {'Foo' => 70, 'Bar' => 15, 'Baz' => 13, 'TARGET' => 2}
  erb :index
end
  
error Sinatra::Param::InvalidParameterError do
  {error: "#{env['sinatra.error'].param} is invalid"}.to_json
end

