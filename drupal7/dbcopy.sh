#!/usr/bin/env bash

# Copy Drupal 7 databases from one server to another.


######################################################################
# Get options

# Src database to copy from.
srcHost='' # a
srcPort='3306' # b
srcDb='' # c
srcDbUser='' # d
srcDbPass='' # e

# Dest database to copy to.
destHost='' # f
destPort='3306' # g
destDb='' # h
destDbUser='' # i
destDbPass='' # j

# Name of database (same for both src and dest).

verbose=false # v

# Delete dest database if it exists.
delDestDb=false # x

usageMsg="Copy Drupal 7 databases from one server to another.\n"\
"Usage: $0 -a <srcHost> [-b <srcPort>] -c <srcDb> -d <srcDbUser> -e <srcDbPass>\n"\
"  -f <destHost> [-g <destPort>] -h <destDb> -i <destDbUser> -j <destDbPass>\n"\
"  [-v<verbose>] [-x<delDestDb>]\n\n"\
"Example: $0 -a sql.example1.com -b 3306 -c src_db -d myuser -e MyPass\n"\
"  -f sql.example2.com -g 3307 -h myawsuser -i MyAwsPass -j destdb -vx"

while getopts 'a:b:c:d:e:f:g:h:i:j:vx' flag; do
  case "${flag}" in
    a) srcHost=${OPTARG} ;;
    b) srcPort=${OPTARG} ;;
    c) srcDb=${OPTARG} ;;
    d) srcDbUser=${OPTARG} ;;
    e) srcDbPass=${OPTARG} ;;
    f) destHost=${OPTARG} ;;
    g) destPort=${OPTARG} ;;
    h) destDb=${OPTARG} ;;
    i) destDbUser=${OPTARG} ;;
    j) destDbPass=${OPTARG} ;;
    v) verbose=true ;;
    x) delDestDb=false ;;
    *) echo -e "$usageMsg"
       exit 1 ;;
  esac
done

# Check for mandatory options.
if [[ -z $srcHost || -z $srcDb || -z $srcDbUser || -z $srcDbPass \
  || -z $destHost || -z $destDb || -z $destDbUser || -z $destDbPass ]]; then
  echo 'Error: Mandatory arguments not provided.'
  echo -e "$usageMsg"
  exit 1
fi


######################################################################
# Define functions

# Create --ignore-table=mydb.mytable params
# Arg1: database name.
# Echo: '--ignore-table=mydb.mytable1 --ignore-table=mydb.myothertable ...'
getIgnoreParams() {
  dbName=$1

  ignoreTables=(
    cache
    cache_admin_menu
    cache_authcache_key
    cache_authcache_p13n
    cache_block
    cache_bootstrap
    cache_brightcove
    cache_entity_registration
    cache_entity_registration_state
    cache_entity_registration_type
    cache_features
    cache_feeds_http
    cache_field
    cache_filter
    cache_form
    cache_image
    cache_libraries
    cache_menu
    cache_page
    cache_path
    cache_path_breadcrumbs
    cache_performance
    cache_proxy
    cache_rules
    cache_salesforce_object
    cache_token
    cache_update
    cache_variable
    cache_views
    cache_views_data
    ctools_css_cache
    ctools_object_cache
    download_count_cache
    flood
    history
    queue
    search_api_db_node_index
    search_api_db_node_index_field_related_to_product
    search_api_db_node_index_field_tags
    search_api_db_node_index_text
    search_api_db_search_contents
    search_api_db_search_contents_field_file_file
    search_api_db_search_contents_field_tags
    search_api_db_search_contents_text
    search_api_db_search_contents_text_1
    search_api_item
    search_api_item_string_id
    search_api_task
    semaphore
    sessions
    watchdog
  )

  ignoreParams=''
  for table in "${ignoreTables[@]}"; do
    ignoreParams="$ignoreParams --ignore-table=$dbName.$table"
  done

  echo $ignoreParams
}


######################################################################
# Main program

# mysql/msqldump params.
srcParams="-h $srcHost -P $srcPort -u $srcDbUser -p$srcDbPass"
destParams="-h $destHost -P $destPort -u $destDbUser -p$destDbPass"

# Turn on Bash verbosity.
if [ "$verbose" = true ]; then
  set -vx
fi

echo -e "Backing up \033[92m$dbName\033[0m"

# Dump table structures
mysqldump --no-data $srcParams $srcDb > $srcDb.sql

# Dump table data, ignoring some tables.
ignoreParams=$(getIgnoreParams $srcDb)
mysqldump $ignoreParams $srcParams $srcDb >> $srcDb.sql

echo -e "Migrating \033[92m$dbName\033[0m"

if [ "$delDestDb" = true ]; then
  mysql $destParams -e "DROP DATABASE IF EXISTS $destDb"
fi

mysql $destParams -e "CREATE DATABASE IF NOT EXISTS $destDb"

# Load data into dest table by "sourcing" the SQL commands. This seems to be
# the proper way to restore Drupal databases.
mysql $destParams $destDb < $srcDb.sql

# Delete temp SQL file.
rm $srcDb.sql

# Turn off verbose.
set +vx

