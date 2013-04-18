#!/bin/sh

set -e

DIR=`pwd`
cd ..
nimrod c awesome_rmdir.nim
cd "${DIR}"

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
../awesome_rmdir todelete

mkdir todelete
touch todelete/.DS_Store
../awesome_rmdir todelete

mkdir todelete
touch todelete/.DS_Store
touch todelete/Thumbs.db
../awesome_rmdir todelete -v

mkdir todelete
touch todelete/.DS_Store
touch todelete/Thumbs.db
touch todelete/meh.db
! ../awesome_rmdir todelete -v
rm todelete/meh.db
rmdir todelete

echo Finished
