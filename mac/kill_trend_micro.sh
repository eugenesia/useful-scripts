#!/usr/bin/env bash

# Suspend Trend Micro Antivirus until this script is stopped.

while true; do
  sudo pkill -f iCoreService
  sleep 5
done

