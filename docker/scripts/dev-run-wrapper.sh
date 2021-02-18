#!/bin/sh

## Installs any new gems, performs any outstanding migrations, and runs the
## given command. This is the command that the Docker dev container runs on 
## startup by default.

## Grab the user defined command + args; default to running the server.
cmd="bin/rails s -b 0.0.0.0"
if [[ $# -gt 0 ]]; then 
    cmd="$@"
fi 

## Clear out an old pids.
rm -f tmp/pids/*

status=0

## Only run `bundle install` if the Gemfile has been updated.
if [ Gemfile -nt Gemfile.lock ]; then
    bundle install
    status=$?
    echo "IMPORTANT: don't forget to re-build your Docker image."
fi

## Copy over solr configuration file.
cat sunspot/conf/schema.xml > solr/configsets/sunspot/conf/schema.xml

## Perform DB migration, solr startup, reindexing, and finally run the user's
## command.
[ $status -eq 0 ] && 
    bundle exec rake db:migrate &&
    bundle exec rake sunspot:solr:start &&
    echo "Reindexing..." &&
    bundle exec rake sunspot:solr:reindex &&
    # echo "Running server; use ctrl-c to exit and drop to the command line." &&
    echo "Running $args..." &&
    $cmd &&
    bundle exec rake sunspot:solr:stop
