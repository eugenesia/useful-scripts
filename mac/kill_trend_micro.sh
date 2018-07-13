#!/usr/bin/env bash

# Suspend Trend Micro Antivirus until this script is stopped.

while true; do
  sudo pkill -f iCoreService
  ret=$?
  if [ "$ret" -eq 0 ]; then
    echo $(date): Processes killed
  else
    echo $(date): There was an error, code $ret
  fi
  sleep 5
done

