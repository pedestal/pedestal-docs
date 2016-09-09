#! /usr/bin/env bash

D=`pwd`

cd ..

if [ ! -d 'pedestal' ] ; then
    echo "This script needs a pedestal checkout as a sibling of the docs checkout"
    exit -1
fi

if [ -z `which lein` ] ; then
    echo "This script needs 'lein' on your PATH"
    exit -1
fi

cd pedestal

for m in service service-tools route interceptor log immutant jetty tomcat
do
    if [ ! -d $m ] ; then
        echo "Missing module $m in the pedestal checkout. Aborting."
        exit -1
    fi

    echo "Generating docs for $m"
    pushd $m

    lein docs

    if [ $? -ne 0 ] ; then
        echo "Codox failed to generate docs. Aborting."
        exit -1
    fi

    moddir=${D}/api/pedestal.${m}

    if [ -d $moddir ] ; then
        rm $moddir/*.html
    else
        mkdir -p $moddir
    fi

    cp -r target/doc/* $moddir

    popd
done
