#!/usr/bin/env bash

# Retry wget until succeeded
# https://superuser.com/questions/493640/how-to-retry-connections-with-wget

url=$1
output=$2

while [ 1 ]; do
  wget \
    --retry-connrefused \
    --waitretry=1 \
    --read-timeout=20 \
    --timeout=15 \
    --tries=0 \
    --continue \
    --output-document=$output
    -- $url

  if [ $? = 0 ]; then break; fi; # check return value, break if successful (0)
  sleep 1s;
done;

