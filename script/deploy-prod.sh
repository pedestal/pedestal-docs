#!/bin/bash

set -e

# Staging and production bucket
case $TRAVIS_BRANCH in
    master)
        bucket="pedestal.io"
        ;;
    *)
        bucket="staging.pedestal.io"
        ;;
esac

export aws_target_bucket=s3://${bucket}

./script/deploy.sh
