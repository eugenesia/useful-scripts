#!/usr/bin/env bash

# Rsync Drupal 7 files from one server to localhost, or vice versa.


######################################################################
# Get options

# Src folder to rsync from.
rsyncSrc='' # a

rsyncDest='' # b

verbose=false # v

usageMsg="Rsync Drupal 7 files from one server to localhost, or vice versa.\n"\
"Usage: $0 -a <srcUser@srcHost:/src/dir/> -b <destUser@destHost:/dest/dir/>\n"\
"  -v\n\n"\
"Example: $0 -a jane@example1.com:/var/www/files/ -b john@example2.com:/tmp/files/"

while getopts 'a:b:v' flag; do
  case "${flag}" in
    a) rsyncSrc=${OPTARG} ;;
    b) rsyncDest=${OPTARG} ;;
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
# Echo: '--exclude=dir1 --exclude=dir2 ...'
getExcludeParams() {
  excludeDirs=(
    css
    ctools
    js
    xmlsitemap
  )

  excludeParams=''
  for dir in "${excludeDirs[@]}"; do
    excludeParams="$ignoreParams --exclude=$dir"
  done

  echo $excludeParams
}


######################################################################
# Main program

rsyncFlags='az'

# Turn on Bash and Rsync verbosity.
if [ "$verbose" = true ]; then
  # Turn on Rsync verbosity.
  rsyncFlags="${options}v"
  set -vx
fi

rsync -$rsyncFlags $(getExcludeParams) $rsyncSrc $rsyncDest

# Turn off verbose.
set +vx

