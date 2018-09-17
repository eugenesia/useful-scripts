#!/usr/bin/env bash

# Do an activity in Google Fit

emulatorId=$1 # E.g. 5554
steps=${2:-14000} # No. of steps to do

# Launch Google Fit and start the last activity type: running/walking/etc
./gfit.sh $emulatorId launch
./gfit.sh $emulatorId start-activity

# Do steps to be tracked for the activity
./step2.sh $emulatorId $steps

# Stop and save the activity
./gfit.sh $emulatorId stop-activity

