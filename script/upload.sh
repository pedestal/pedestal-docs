#!/bin/bash

## Requires:
##   1) able to invoke aws with proper credentials
##   2) aws_upload_bucket and aws_target_bucket set

echo "Uploading ./output to bucket ${aws_upload_bucket}"

# Delete upload bucket contents
aws s3 rm ${aws_upload_bucket} --recursive

# Copy files with some extension
aws s3 cp output/ ${aws_upload_bucket} --recursive --exclude "*" --include "*.[a-z]*"

# Copy files with no extension and mark as html content
aws s3 cp output/ ${aws_upload_bucket} --recursive --include "*" --exclude "*.[a-z]*" --content-type text/html

# Copy robots.txt file
aws s3 cp script/robots.txt ${aws_upload_bucket}

echo "Syncing from ${aws_upload_bucket} to ${aws_target_bucket}"

# Sync from upload to target bucket
aws s3 sync ${aws_upload_bucket} ${aws_target_bucket} --delete
