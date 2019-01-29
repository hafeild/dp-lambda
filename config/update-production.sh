#!/bin/bash

###
## File:     update-production.sh
## Author:   Hank Feild (hank@feild.org)
## Date:     02-Feb-2019
## Purpose:  Runs through the necessary steps after updating to a new version
##           of Alice.
USAGE="
update-production.sh [--help] [--reindex]

Updates a production version of Alice. Assumes the git repository is already
at the correct version (i.e., this script does not issue the `git pull` 
command).

--help -- prints this message and exits.

--reindex -- calls the sunspot:reindex task to reindex the entire Solr index;
             this is done after the rest of the updating process has occured.
"


reindex=""

for arg in $@; do
  if [ "$arg" == "--help" ]; then
    echo "$USAGE"
    exit 
  elif [ "$arg" == "--reindex" ]; then
    reindex="1"
  fi
done

## Exit as soon as the first command fails.
set -e

echo "Putting up maintenance message..."
touch site-down

echo "Running bundle install..."
bundle install

echo "Running migrations..."
bundle exec rake db:migrate RAILS_ENV=production

echo "Compile assests..."
bundle exec rake assets:precompile RAILS_ENV=production

echo "Restarting unicorn and solr..."
service alice-unicorn restart
service alice-solr restart

if [ "$reindex" == "1" ]; then
  echo "Reindexing..."
  bin/rake sunspot:reindex RAILS_ENV=production
fi

echo "Removing maintenance message..."
rm -f site-down


echo "DONE"

