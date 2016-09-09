#!/bin/bash

# Prerequisites to run this script:
#   Java installed and on PATH
#   git installed and on PATH
#   aws cli installed and on PATH
#   user must have read access to the git repos
#   user must have aws configured with proper credentials
#   aws_target_bucket must be set

set -e

# Upload bucket
export aws_upload_bucket=${aws_target_bucket}-upload

./script/build.sh
./script/upload.sh
./script/redirects.sh

echo "Success!"
