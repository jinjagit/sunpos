# Algorithm based on information in: https://en.wikipedia.org/wiki/Position_of_the_Sun

require 'date'

class String
  def red
    "\e[31m#{self}\e[0m"
  end
end

def valid_time?(time)
  return true if time =~ /^([01]?[0-9]|2[0-3])\:[0-5][0-9]\:[0-5][0-9]$/
  false
end

def valid_date?(date)
  date = pad_date(date)
  d, m, y = date.split '-'
  return true if Date.valid_date? y.to_i, m.to_i, d.to_i
  false
end

def pad_date(date)
  d, m, y = date.split '-'
  d = "0" + d if d.length == 1
  m = "0" + m if m.length == 1
  y = "20" + y if y.length == 2
  y = "200" + y if y.length == 1
  return "#{d}-#{m}-#{y}"
end

def time_to_fraction(time)
  h, m, s = time.split ':'
  return (h.to_i * 3600 + m.to_i * 60 + s.to_i) / 86400.0
end


date = "date-not-set"
time = "time-not-set"

loop do
  puts "Enter date in format dd-mm-yyyy"
  date = gets.chomp
  break if valid_date?(date)
  puts "Invalid date!".red
end

loop do
  puts "Enter time in format hh:mm:ss"
  time = gets.chomp
  break if valid_time?(time)
  puts "Invalid time!".red
end


# Start by calculating n, the number of days (positive or negative, including fractional days) since Greenwich noon,
# Terrestrial Time, on 1 January 2000 (J2000.0). If the Julian date (JD) for the desired time is known, then
# n = JD - 2451545.0

n = Date.parse(pad_date(date)).jd - 2451545.0 + time_to_fraction(time)

puts n