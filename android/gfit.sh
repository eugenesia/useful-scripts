#!/usr/bin/env bash

# Commands for Google Fit.

emulatorId=$1 # E.g. 5554
cmd=$2 # launch | start-activity | stop-activity

adbShellCmd=''

# Run a command in the Adb shell
function runShellCmd() {
  local cmd=$1
  adb -s emulator-$emulatorId shell $cmd
}

# Start an activity
function startActivity() {
  # "Plus" button to start an activity
  runShellCmd 'input tap 430 750'
  # "Start activity" button
  runShellCmd 'input tap 430 650'
  # "Running" button
  # runShellCmd 'input tap 240 280'
  # "Start" button
  runShellCmd 'input tap 240 700'
}

case "$cmd" in
  launch)
    # Home button - KEYCODE_HOME === 3
    runShellCmd 'input keyevent 3'
    # Launch the app
    runShellCmd 'monkey -p com.google.android.apps.fitness 1'
    # Back button go to to app homepage. Do twice, just in case it's too deep
    runShellCmd 'input keyevent 4'
    runShellCmd 'input keyevent 4'
    # Launch the app again in case we exited by pressing too many Backs.
    runShellCmd 'monkey -p com.google.android.apps.fitness 1'
    ;;
  start-activity)
    startActivity
    ;;
  stop-activity)
    # Pause button
    runShellCmd 'input tap 240 750'
    # Stop button
    runShellCmd 'input tap 430 750'
    # Back button - KEYCODE_BACK === 4
    runShellCmd 'input keyevent 4'
    ;;
  *)
    ;;
esac
    

