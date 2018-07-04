#!/usr/bin/expect

# Simulate stepping in Android emulator.
# You must first run an emulator in Android Studio, then install and run the
# app you want to simulate steps for.

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
set latStart 51.5018
set lonStart -0.0198
# For each step, lat/lon will change by random amount in range
# -geoIncr to +geoIncr.
set geoIncr 0.0001


# Set acceleration to a value, then wait.
proc accset { y } {
  send "sensor set acceleration 0:$y:0\r"
  expect "OK"
}

# Get a random float in the range -abs to +abs.
proc randSigned { abs } {
  return [expr { $abs - (2 * $abs * rand()) }]
}

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

send "help\r"

# Set latitude and longitude as we take each step, to better simulate walking.
set lat $latStart
set lon $lonStart

for {set i 0} {$i < $stepcount} {incr i} {
  send_user "Step: $i\n"

  # Randomly increment/decrement the lat/lon.
  set latIncr [randSigned $geoIncr]
  set lat [expr {$lat + $latIncr}]

  set lonIncr [randSigned $geoIncr]
  set lon [expr {$lon + $lonIncr}]

  # Set the phone's GPS to the new lat lon.
  send "geo fix $lon $lat\n"
  expect "OK"

  # Up movement
  accset 0
  sleep 0.2

  # Down movement
  accset 20
  sleep 0.2
}

# Set to default acceleration (1 G-Force).
accset 9.81

#This hands control of the keyboard over two you (Nice expect feature!)
# interact

