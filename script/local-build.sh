#!/bin/bash
# Execute this from root directory.  You must have watchexec installed.
set -exuo pipefail

watchexec --clear --notify \
   --watch ../pedestal/docs \
   --watch ui-overrides \
   --watch local-antora-playbook.yml \
   npx antora local-antora-playbook.yml