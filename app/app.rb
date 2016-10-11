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

Chartkick.options = {
  width: "100%",
  colors: [
     "#2B879E", #navyish
     "#98D9B6", #teal1
     "#CDB380", #terracotta
     "#A75B38", #dark terracotta
     "#036564", #'dark teal'?
     "#79BD9A", #another greenish
     "#616668", #darkgrey
     #"#3EC9A7", #teal2
  ]
}


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

def pie_chart_impact(min_year, max_year=3000)
  # TODO(hangtwenty) move to view-helper? what's that like in Sinatra?
  pie_chart(
    @incidents
    .select{|x| x.started_at.year >= min_year && x.started_at.year <= max_year}
    .reject{|x| x.impact == "maintenance"}
    .group_by(&:impact).map{|key, group_of_incidents| 
      [key, group_of_incidents.size] 
  })
end

