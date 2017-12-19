#!/usr/bin/env bash

# Rsync Drupal 7 files from one server to localhost, or vice versa.


######################################################################
# Get options

# Excluded files/dirs specified in command line.
cmdExcludes=''

# Src folder to rsync from.
rsyncSrc='' # a

rsyncDest='' # b

verbose=false # v

# Filename of this script.
scriptFile=$(basename $0)

usageMsg="Rsync Drupal 7 files from one server to localhost, or vice versa.\n"\
"Usage: $scriptFile -a <srcUser@srcHost:/src/dir/> -b <destUser@destHost:/dest/dir/>\n"\
"  [-e dir1 -e dir2 ...] -v\n\n"\
"Example: $scriptFile -a jane@example1.com:/var/www/files/ -b john@example2.com:/tmp/files/\n"\
"  -e dir1 -e '*.mp3'"

while getopts 'a:b:e:v' flag; do
  case "${flag}" in
    a) rsyncSrc=$OPTARG ;;
    b) rsyncDest=$OPTARG ;;
    # Concatenate all the excludes.
    e) cmdExcludes="$cmdExcludes $OPTARG" ;;
    v) verbose=true ;;
    *) echo -e "$usageMsg"
       exit 1 ;;
  esac
done

# Check for mandatory args.
if [[ -z $rsyncSrc || -z $rsyncDest ]]; then
  echo 'Error: Mandatory arguments not provided.'
  echo -e "$usageMsg"
  exit 1
fi


######################################################################
# Define functions

# Get rsync exclude params, to exclude unnecessary dirs.
# $@ (remaining args): Space-separated string of more things to exclude.
# Echo: '--exclude=dir1 --exclude=dir2 ...'
getExcludeParams() {

  moreExcludes="${@:1:99}"

  # Drupal-generated dirs which don't need to be copied over.
  drupalExcludeDirs='.ht.filecache css ctools js styles xmlsitemap'

  # Concatenate all the excluded args.
  excludes="$drupalExcludeDirs $moreExcludes"

  excludeParams=''
  for exclude in $excludes; do
    excludeParams="$excludeParams --exclude=$exclude"
  done

  echo $excludeParams
}


######################################################################
# Main program

excludeParams=$(getExcludeParams $cmdExcludes)

rsyncFlags='az'

# Turn on Bash and Rsync verbosity.
if [ "$verbose" = true ]; then
  # Turn on Rsync verbosity.
  rsyncFlags="${rsyncFlags}v"
  set -vx
fi

rsync -$rsyncFlags $excludeParams $rsyncSrc $rsyncDest

# Turn off verbose.
set +vx

