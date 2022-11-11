#! /usr/bin/env bash
set -euo pipefail

D=`pwd`
Q=\"

if [ ! -d '../pedestal' ] ; then
    echo "This script needs a pedestal checkout as a sibling of the docs checkout"
    exit -1
fi

if [ -z `which clojure` ] ; then
    echo "This script needs 'clojure' on your PATH"
    exit -1
fi

cd ../pedestal && \
  clojure -T:build codox :output-path ${Q}${D}/api${Q}
