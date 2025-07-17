#!/bin/bash
# Execute this from root directory.  You must have watchexec installed.
set -exuo pipefail


watchexec --clear --notify \
   --project-origin . \
   --watch ../pedestal/docs \
   --watch ui-overrides \
   --watch local-antora-playbook.yml \
   --watch lib \
   --debounce=500ms \
   npx antora \
      --stacktrace \
      --log-level=info \
      local-antora-playbook.yml
