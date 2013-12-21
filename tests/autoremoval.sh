#!/bin/sh

set -e

DIR=`pwd`
cd ..
nimrod c awesome_rmdir.nim
cd "${DIR}"

rm -Rf todelete

echo Test 1
mkdir todelete
../awesome_rmdir todelete

echo Test 2
mkdir todelete
touch todelete/.DS_Store
../awesome_rmdir todelete

echo Test 3
mkdir todelete
touch todelete/.DS_Store
touch todelete/Thumbs.db
../awesome_rmdir todelete

echo Test 4
mkdir todelete
../awesome_rmdir todelete

echo Test 5
mkdir todelete
touch todelete/.DS_Store
../awesome_rmdir todelete

echo Test 6
mkdir todelete
touch todelete/.DS_Store
touch todelete/Thumbs.db
../awesome_rmdir todelete -v

echo Test 7
mkdir todelete
touch todelete/.DS_Store
touch todelete/Thumbs.db
touch todelete/meh.db
! ../awesome_rmdir todelete -v
rm -f todelete/meh.db
rm -f todelete/Thumbs.db
rm -f todelete/.DS_Store
rmdir todelete

echo Test 8
mkdir ./--version
../awesome_rmdir -- --version

echo Finished tests succesfully
