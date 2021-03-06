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

if [ ! -f "config/application.yml" ]; then 
    echo "Please copy `application.EXAMPLE.yml` to config/application.yml and "
    echo "configure as necessary before running this command again."
    exit
fi

status=0

## Only run `bundle install` if the Gemfile has been updated.
if [ Gemfile -nt Gemfile.lock ]; then
    bundle install
    status=$?
    echo "IMPORTANT: don't forget to re-build your Docker image."
fi

if [ $status -eq 0 ] && [ ! -d "solr/" ]; then 
    echo "Performing initial Solr startup..."
    bundle exec rake sunspot:solr:start && 
        bundle exec rake sunspot:solr:stop
    status=$?
fi

## Perform DB migration, solr startup, reindexing, and finally run the user's
## command.
[ $status -eq 0 ] && 
    ## Copy over solr configuration file.
    cat sunspot/conf/schema.xml > solr/configsets/sunspot/conf/schema.xml &&
    bundle exec rake db:migrate &&
    bundle exec rake sunspot:solr:start &&
    echo "Reindexing..." &&
    bundle exec rake sunspot:solr:reindex &&
    # echo "Running server; use ctrl-c to exit and drop to the command line." &&
    echo "Running $args..." &&
    $cmd &&
    bundle exec rake sunspot:solr:stop
