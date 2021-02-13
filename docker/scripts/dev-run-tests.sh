#!/bin/sh

## Installs any new gems, performs any outstanding migrations, and starts the
## server. This is the command that the Docker dev container runs on startup.

trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C; dropping to command line..."
}

## Clear out an old pids.
rm -f tmp/pids/*

status=0

## Only run `bundle install` if the Gemfile has been updated.
if [ Gemfile -nt Gemfile.lock ]; then
    bundle install
    status=$?
    echo -n "IMPORTANT: don't forget to re-build your Docker image (if you're "
    echo "using docker)"
fi

[ $status -eq 0 ] && 
    bundle exec rake db:migrate RAILS_ENV=test &&
    bundle exec rake sunspot:solr:start RAILS_ENV=test  &&
    bundle exec rake test
    bundle exec rake sunspot:solr:stop RAILS_ENV=test
