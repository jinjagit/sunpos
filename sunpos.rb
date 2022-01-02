# Algorithm based on information in: https://gml.noaa.gov/grad/solcalc/solareqns.PDF

require 'date'
include Math

class String
  def red
    "\e[31m#{self}\e[0m"
  end
end

class Numeric
  # Convert degrees to radians
  # 90.degrees => 1.5707963267949
  def degrees
    self * Math::PI / 180 
  end

  # Convert radians to degrees
  # 1.5707963267949.radians => 90.0
  def radians
    self * 180 / Math::PI
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

# Returns time as string in 24-hour format
def integers_to_time(h, m, s)
  hrs = ''
  mins = ''
  secs = ''
  
  if h > 9
    hrs = h.to_s
  else
    hrs = "0#{h}"
  end

  if m > 9
    mins = m.to_s
  else
    mins = "0#{m}"
  end

  if s > 9
    secs = s.to_s
  else
    secs = "0#{s}"
  end

  "#{hrs}:#{mins}:#{secs}"
end

def leap_year?(year)
  return true if year % 4 == 0 && year % 100 != 0
  return true if year % 400 == 0
  false
end

def get_date()
  date = "date-not-set"

  loop do
    puts "Enter date in format dd-mm-yyyy"
    date = gets.chomp

    if valid_date?(date)
      date = string_to_date(pad_date(date))
      break
    end

    puts "Invalid date!".red
  end

  date
end

# ========== Calculate the Sun's position ============
def sunpos (date, time, latitude, longitude, timezone)
  h, m, s = time.split(':').map(&:to_i)
  diy = leap_year?(date.year) ? 366 : 365 # days in year

  # fy = fractional year, in radians (360 degrees ~= 6.28319 radians)
  fy = ((2 * PI) / diy) * (date.yday - 1 + time_to_fraction(time))

  # eqtime = equation of time (in minutes)
  eqtime = 229.18 * (0.000075 + (0.001868 * cos(fy)) - (0.032077 * sin(fy)) - (0.014615 * cos(2 * fy)) - (0.040849 * sin(2 * fy)))

  # decl = solar declination (in radians)
  decl = 0.006918 - (0.399912 * cos(fy)) + (0.070257 * sin(fy)) - (0.006758 * cos(2 * fy)) + (0.000907 * sin(2 * fy)) - (0.002697 * cos(3 * fy)) + (0.00148 * sin(3 * fy))

  # t_offset = time offset (in minutes), where longitude is in degrees (positive to the east of the Prime Meridian), timezone is in hours from UTC
  t_offset = eqtime + (4 * longitude) - (60 * timezone)

  # tst = true solar time (in minutes), where hr is the hour (0 - 23), mn is the minute (0 - 59), sc is the second (0 - 59)
  tst = (h * 60) + m + (s / 60.0) + t_offset

  # sha = solar hour angle, (in radians)
  sha = ((tst / 4.0) - 180).degrees

  # sza = solar zenith angle (in radians) can then be found from the hour angle (sha), latitude (lat) and solar declination (decl)
  sza = acos((sin(latitude.degrees) * sin(decl)) + (cos(latitude.degrees) * cos(decl) * cos(sha)))

  #                  (sin(latitude.radians) * cos(sza)) - sin(decl)
  # cos(180 - saa) = ----------------------------------------------
  #                        cos(latitude.radians) * sin(sza)

  # saa = the solar azimuth angle (in radians, clockwise from north)
  saa = (acos(((sin(latitude.degrees) * cos(sza)) - sin(decl)) / (cos(latitude.degrees) * sin(sza))) - 180.0.degrees) * -1

  [sza, saa]
end


date = get_date

# longitude = 0.0    # Greenwich meridian (in degrees)
# latitude = 51.4769 # Greenwich observatory (in degrees)
# timezone = 0       # UTC == GMT

longitude = 360.0 - 46.6396    # Sao Paulo (in degrees)
latitude = -23.5558 # Sao Paulo (in degrees)
timezone = -3 # Sao Paulo, UTC-3

times = ["03:00:00", "15:00:00"]
sunrise = nil
sunset = nil

2.times do |i|
  h, m, s = times[i].split(':').map(&:to_i)
  start = h
  smallest_diff = nil

  # iterate through 8 hours, minute by minute
  loop do
    sza, saa = sunpos(date, integers_to_time(h, m, s), latitude, longitude, timezone)

    # for sunrise or sunset, the zenith is set to 90.833 degrees (the approximate correction for atmospheric refraction)
    diff = (90.833 - sza.radians).abs

    if diff < 5.0
      if (smallest_diff.nil? || diff < smallest_diff)
        smallest_diff = diff
        sunrise = integers_to_time(h, m, s) if i == 0
        sunset = integers_to_time(h, m, s) if i == 1
      end
    end

    m += 1

    if m == 60
      h += 1
      m = 0
    end

    break if h == start + 8 
  end
end

puts "sunrise is at approximately #{sunrise}"
puts "sunset is at approximately  #{sunset}"