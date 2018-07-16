#!/usr/bin/expect

# Simulate stepping in Android emulator.
# You must first run an emulator in Android Studio, then install and run the
# app you want to simulate steps for.


###############################################################################
# Variables and config

# Port for connecting to Android emulator instance.
set port [lindex $argv 0]
if {$port eq ""} {
  set port 5554
}

# No. of steps to simulate
set stepcount [lindex $argv 1]
if {$stepcount eq ""} {
  set stepcount 100
}

# Starting lat and long.
set latStart [lindex $argv 2]
set lonStart [lindex $argv 3]

# If lat/lon not specified, randomly pick a starting point within this area.
# Battersea Park
set areaLatMin 51.479107
set areaLonMin -0.156498
# Queen Elizabeth Olympic Park
set areaLatMax 51.543296
set areaLonMax -0.016552

if {$latStart eq ""} {
  set latStart [expr { $areaLatMin + rand() * ($areaLatMax - $areaLatMin) }]
}
if {$lonStart eq ""} {
  set lonStart [expr { $areaLonMin + rand() * ($areaLonMax - $areaLonMin) }]
}

# For each step, lat/lon will change by random amount in range
# -geoIncr to +geoIncr.
# 0.000005 lat === 56 cm: Ok for distance of one step
set geoIncr 0.00000001

# Pause after every x steps to allow data to upload.
set pauseInterval 3000
# Number of seconds to pause.
set pauseDuration 300


###############################################################################
# Procedures

# Set acceleration to a value, then wait.
proc accset { y } {
  set xAcc [ randSigned 3 ]
  set zAcc [ randSigned 3 ]
  send "sensor set acceleration $xAcc:$y:$zAcc\r"
  expect "OK"
}

# Get a random float in the range -abs to +abs.
proc randSigned { abs } {
  return [expr { $abs - (2 * $abs * rand()) }]
}


###############################################################################
# Main script

#If it all goes pear shaped the script will timeout after 20 seconds.
set timeout 20

# Get emulator auth token
set f [open "~/.emulator_console_auth_token"]
set token [read $f]
close $f


#This spawns the telnet program and connects it to the variable name
spawn telnet localhost $port
expect "OK"

send "auth $token\r"
expect "OK"

# send "help\r"

# Set latitude and longitude as we take each step, to better simulate walking.
set lat $latStart
set lon $lonStart

for {set i 0} {$i < $stepcount} {incr i} {
  send_user "Step: $i of $stepcount\n"

  # Randomly increment/decrement the lat/lon.
  set latIncr [randSigned $geoIncr]
  set lat [expr {$lat + $latIncr}]

  set lonIncr [randSigned $geoIncr]
  set lon [expr {$lon + $lonIncr}]

  # Set the phone's GPS to the new lat lon.
  send "geo fix $lon $lat\n"
  expect "OK"

  # Up movement
  accset [ expr { 9 + [ randSigned 1 ] }]
  accset [ expr { 7 + [ randSigned 1 ] }]
  accset [ expr { 5 + [ randSigned 1 ] }]
  accset [ expr { 3 + [ randSigned 1 ] }]
  sleep 0.5

  # Down movement
  accset [ expr { 5 + [ randSigned 1 ] }]
  accset [ expr { 7 + [ randSigned 1 ] }]
  accset [ expr { 9 + [ randSigned 1 ] }]
  accset [ expr { 11 + [ randSigned 1 ] }]
  accset [ expr { 13 + [ randSigned 1 ] }]
  accset [ expr { 15 + [ randSigned 1 ] }]
  sleep 0.5

  accset [ expr { 13 + [ randSigned 1 ] }]
  accset [ expr { 11 + [ randSigned 1 ] }]
  accset [ expr { 9 + [ randSigned 1 ] }]
  sleep 0.5

  # After every number of steps, pause for data to upload.
  if { $i > 0 && $i % $pauseInterval == 0 } {
    sleep $pauseDuration
  }
}

# Set to default acceleration (1 G-Force).
accset 9.81

#This hands control of the keyboard over two you (Nice expect feature!)
# interact

