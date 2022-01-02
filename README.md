Algorithm based on information in: https://en.wikipedia.org/wiki/Position_of_the_Sun

Calculates sun's position in sky for any specified date, time, timezone, latitude and longitude.  
Returns solar zenith and solar azimuth.  
Probably only resonably accurate for a couple of decades into the past or future (not tested).  
  
  
## Tests
Testing solar zenith calculation by iterating through minutes of a given date to find approximate times when sun is (apparently) closest to horizon (sunrise and sunset):

Example comparisons with values from: https://www.timeanddate.com/sun

For London (longitude = 0.0 E, latitude = 51.4769 N), on 01-07-2021 (UTC+1, BST):  
timeanddate.com gives:  
  `sunrise: 04:47, sunset: 21:20`  
sunpos.rb gives:  
  `sunrise: 04:46, sunset: 21:20`  

For Sao Paulo (longitude = 46.6396 W, latitude = 23.5558 S), on 01-07-2021 (UTC-3):  
timeanddate.com gives:  
  `sunrise: 06:49, sunset: 17:31`  
sunpos.rb gives:  
  `sunrise: 06:49, sunset: 17:31`  

= within 1 minute of times given by timeanddate.com
