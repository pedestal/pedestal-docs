#!/bin/bash

# Prerequisites to run this script:
#   Java installed and on PATH
#   git installed and on PATH
#   jbake 2.5.0 installed and on PATH
#   user must have read access to the git repos

set -e

# Variables
content_branch=master

echo "Cleaning build area in ./output"
rm -rf ./output

echo "Building pages in ./output"
jbake

echo "Copying API docs to ./output/api"
cp -r ./api ./output/

echo "Done!"
