# Algorithm based on information in: https://gml.noaa.gov/grad/solcalc/solareqns.PDF

require 'date'
include Math

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
  y = y.to_i + 2000 if y.to_i < 100
  return "#{d}-#{m}-#{y}"
end

def string_to_date(str)
  d, m, y = str.split '-'
  Date.parse("#{y}-#{m}-#{d}")
end

# Returns number of hours passed in the day, in fractional hours.
# TODO: This might not be needed.
def time_to_hours(time)
  h, m, s = time.split ':'
  h.to_i + (((m.to_i * 60) + s.to_i) / 3600.0)
end

# Returns fraction of the day.
def time_to_fraction(time)
  h, m, s = time.split ':'
  return (h.to_i * 3600 + m.to_i * 60 + s.to_i) / 86400.0
end

def leap_year?(year)
  return true if year % 4 == 0 && year % 100 != 0
  return true if year % 400 == 0
  false
end

def get_datetime()
  date = "date-not-set"
  time = "time-not-set"

  loop do
    puts "Enter date in format dd-mm-yyyy"
    date = gets.chomp

    if valid_date?(date)
      date = string_to_date(pad_date(date))
      break
    end

    puts "Invalid date!".red
  end

  loop do
    puts "Enter time in 24-hour format hh:mm:ss"
    time = gets.chomp
    break if valid_time?(time)
    puts "Invalid time!".red
  end

  [date, time]
end


# date, time = get_datetime

date = Date.parse("2021-12-31")
time = "23:59:59"

diy = leap_year?(date.year) ? 366 : 365 # days in year

# fy = fractional year, in radians (360 degrees ~= 6.28319 radians)
fy = ((2 * PI) / diy) * (date.yday - 1 + time_to_fraction(time))

puts fy


