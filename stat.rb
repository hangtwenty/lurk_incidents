require 'colorize'
require 'savanna-outliers'


# given an array of objects, get the outliers for given attr. :max, :min, :all
def get_outliers(objects, attr, type=:max)
  ary = objects.map{|x| x.send(attr).to_f}
  outliers = Savanna::Outliers.get_outliers(ary, type)
  puts "[.] get_outliers(..., #{attr}, type=#{type}) = " +
  "#{outliers.to_s.light_magenta} | " +
  "#{outliers.length.to_s.light_magenta} of #{objects.length.to_s.cyan}"
  outliers
end
