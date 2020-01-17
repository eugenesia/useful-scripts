#!/usr/bin/env bash

# Download a movie as segmented TS files.

# URL before and after the index
# E.g. 'https://n-harcourt.betterstream.co/abrplayback/dc/54/6942fb239d0cd4b207b4d3bd2686177ee60dbaa84f24519275b429104537238a5122a4192e3d02417dd2e7372d2b8cdb4a2937fdeb404423f6b1f6bd41cbdd3312ed34de8708a9c221c9105811e3a715705b7b725576b7ece35695d8da82e06610e06c17c0392e11a945f80f30d5bdb6044b91555804d64f0f4f999cb04940a4/seg-'
urlBefore=$1
urlAfter=$2

seqStart=${3:-0} # E.g. 1
seqEnd=${4:-827} # E.g. 730

downloadDir=$5 # Where to store the downloaded segments

referer=$6

for i in $(seq $seqStart $seqEnd); do
  wget_retry.sh $urlBefore$i$urlAfter $downloadDir/seg-$i.ts $referer
done

