#!/bin/sh

#####
# Runs all of the tests. The alice repo folder on the host is mounted as a
# volume, so all files (logs, sqlite database, etc.) are persistent.
#####

docker run -ti --rm -v "$PWD:/usr/src/app" alice-dev docker/scripts/dev-run-tests.sh