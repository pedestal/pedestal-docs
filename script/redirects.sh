#!/bin/bash

## Requires:
##   1) able to invoke aws with proper credentials
##   2) aws_upload_bucket and aws_target_bucket set

# Redirects are an empty file redirected to an existing page
echo "Setting up redirects in ${aws_target_bucket}"

function redirect {
	aws s3 cp target/empty ${aws_target_bucket}$1 --website-redirect $2
}

# about pages
