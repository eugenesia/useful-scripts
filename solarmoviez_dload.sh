#!/usr/bin/env bash

#
# Download a movie from solarmoviez.ru.
# Usage: <script name> <movieId> <episodeId>
#
# Prerequisite: ffmpeg must be installed.
#
# The movie and episode IDs can be found on the URL when watching the movie on
# the website. E.g. when watching "The Crown", the URL is:
# https://solarmoviez.ru/movie/the-crown-season-2-22918/1106440-7/watching.html
# So the movie ID is 22918, episode ID is 1106440.
#

set -vx

movieId=$1
episodeId=$2

# Temp dir to save all downloaded files.
tmpDir=${3:-tmp}

# Header required for certain requests.
refererHeader='Referer:https://solarmoviez.ru'

# URL to get movie tokens (X and Y args).
movieTokenUrl="https://solarmoviez.ru/ajax/movie_token?eid=$episodeId&mid=$movieId"

# Curl output: _x='b74855de78944bf28c145cb9b486143a', _y='b3b3db66d6e0b64dc85754a6a2e2a070';
movieTokenX=$(curl -k $movieTokenUrl | sed -E "s/_x='([[:alnum:]]+)'.+/\1/")
movieTokenY=$(curl -k $movieTokenUrl | sed -E "s/.+_y='([[:alnum:]]+)'.+/\1/")

# Movie source URL to get JSON data about the movie.
# E.g. https://solarmoviez.ru/ajax/movie_sources/1106444?x=b168bd15c58bda72a786122d53c3f88e&y=b3b3db66d6e0b64dc85754a6a2e2a070
movieSrc="https://solarmoviez.ru/ajax/movie_sources/$episodeId?x=$movieTokenX&y=$movieTokenY"

# Curl $movieSrc gets us a JSON e.g.
# {"playlist":[{"sources":[{"file":"https:\/\/streaming.lemonstream.me:1443\/...\/playlist.m3u8?...","type":"m3u8"}],"tracks":[{"default":true,"file":"https:\/\/sub.solarcdn.ru\/eng\/Subtitle-Dat\/Daily\/2017\/12\/08\/the.crown.s02e02.720p.webrip.x264-strife_track3_eng.srt","label":"English","kind":"captions"}]}]}

# Subtitle file URL.
subtitle=$(curl -k $movieSrc | sed -E 's/.+\,"file":"([^"]+)".+/\1/; s/\\//g')

# Download files into tmp dir.
mkdir -p $tmpDir
rm $tmpDir/*
cd $tmpDir

# Download subtitle first in case subsequent commands fail.
wget $subtitle

# Extract URL-encoded playlist, then delete escape char '\' to URL-decode.
# E.g. https://streaming.lemonstream.me:1443/.../.../playlist.m3u8?ggdomain=...&ggvideo=...&cookie=...&link=...
# This isn't the actual playlist, just a URL to use to get the actual playlists.
playlist=$(curl -k $movieSrc | sed -E 's/.+\{"file":"([^"]+)".+/\1/; s/\\//g')

# This gets us 3 URLs for the actual playlists, based on bandwidth. Extract the
# last one (highest bandwidth/resolution).
# E.g. https://streaming.lemonstream.me:1443/.../.../playlist.m3u8?ggdomain=...&ggvideo=...&cookie=...&link=...
playlist2=$(curl -k -H $refererHeader $playlist | grep 'https' | tail -1)

# Playlist gets us a list of .ts files with sequence numbers. We just need the
# URL pattern and the last number in the sequence on the 2nd last line, e.g.
# '65/a6/65a68beaf5512b753618cd4d77c01d4e-360.mp4/seg-656-v1-a1.ts'
lastTs=$(curl -k -H $refererHeader $playlist2 | tail -2 | head -1)

# TS file URL pattern: [prefix][seq num][suffix (.ts)]
tsPrefix=$(echo $lastTs | sed -E 's/(.+seg\-).+/\1/')
tsSuffix=$(echo $lastTs | sed -E 's/.+seg\-[[:digit:]]+(\-.+)/\1/')
tsLastIndex=$(echo $lastTs | sed -E 's/.+seg\-([[:digit:]]+).+/\1/')

# Another prefix needed to get the full TS file URL.
tsBaseUrl=$(echo $playlist2 | sed -E 's/(.+)playlist\.m3u8.+/\1/')

for i in $(seq 1 $tsLastIndex); do
  curl -k -H $refererHeader $tsBaseUrl$tsPrefix$i$tsSuffix > $i.ts
done

# Concatenate all files using ffmpeg.
# Cmd: ffmpeg -i "concat:input1.ts|input2.ts|input3.ts" -c copy output.ts
ffmArg='concat:1.ts'
for i in $(seq 2 $tsLastIndex); do
  ffmArg="$ffmArg|$i.ts"
done

# Concatenate without re-encoding.
ffmpeg -i $ffmArg -c copy output.mp4

cd ..

set +vx

