#!/bin/bash
# Execute this from root directory.  You must have watchexec installed.
set -exuo pipefail

watchexec -c -\
   -w ../pedestal/docs \
   -w ui-overrides \
   -w local-antora-playbook.yml \
   npx antora local-antora-playbook.yml