#!/bin/bash

set -e

# Staging and production bucket
export aws_target_bucket=s3://pedestal.io

./script/deploy.sh
