#!/bin/bash

###
## File:     update-production.sh
## Author:   Hank Feild (hank@feild.org)
## Date:     02-Feb-2019
## Purpose:  Runs through the necessary steps after updating to a new version
##           of Alice.

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

echo "Removing maintenance message..."
rm -f site-down


echo "DONE"

