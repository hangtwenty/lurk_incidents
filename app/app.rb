require 'sinatra'
require 'chartkick'

get '/' do
  @data = {'Foo' => 70, 'Bar' => 15, 'Baz' => 13, 'quux' => 2}
  erb :index
end
