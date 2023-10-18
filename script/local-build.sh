#!/bin/bash
# Execute this from root directory.  You must have watchexec installed.
set -exuo pipefail

watchexec -c -N -w ../pedestal/docs npx antora local-antora-playbook.yml