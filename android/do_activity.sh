#!/usr/bin/env bash

# Do an activity in Google Fit

emulatorId=$1 # E.g. 5554

# Launch Google Fit and start the last activity type: running/walking/etc
./gfit.sh $emulatorId launch
./gfit.sh $emulatorId start-activity

# Wait for the 321 countdown
sleep 4

# Do steps to be tracked for the activity
./step2.sh $emulatorId 10

# Stop and save the activity
./gfit.sh $emulatorId stop-activity

