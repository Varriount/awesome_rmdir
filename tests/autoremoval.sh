#!/bin/sh

set -e

rm -Rf todelete

mkdir todelete
../awesome_rmdir todelete

mkdir todelete
touch todelete/.DS_Store
../awesome_rmdir todelete

mkdir todelete
touch todelete/.DS_Store
touch todelete/Thumbs.db
../awesome_rmdir todelete

# Running tests
mkdir todelete
../awesome_rmdir todelete -v

mkdir todelete
touch todelete/.DS_Store
../awesome_rmdir todelete -v

mkdir todelete
touch todelete/.DS_Store
touch todelete/Thumbs.db
#../awesome_rmdir todelete -v

