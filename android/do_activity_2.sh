#!/usr/bin/env bash

# Do an activity in Google Fit

emulatorId=$1 # E.g. 5554
steps=${2:-16000} # No. of steps to do

# Launch Google Fit and start the last activity type: running/walking/etc
./gfit2.sh $emulatorId launch
./gfit2.sh $emulatorId start-activity

# Do steps to be tracked for the activity
./step2.sh $emulatorId $steps

# Stop and save the activity
./gfit2.sh $emulatorId stop-activity

