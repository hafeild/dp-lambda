#!/bin/sh

## This provides a wrapper for user rake tasks in the dev container, which 
## require Solr to be up and running.

if [[ $# -eq 0 ]]; then
    echo "Please provide a task:"
    bundle exec rake -T users
    exit
fi

docker/scripts/dev-run-wrapper.sh bundle exec rake $@

