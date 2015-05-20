#!/bin/bash

## Simple test to see whether all the matlab files are used

for m in *.m ; do
    others=$(ls *.m | grep -v ${m})

    e=$(grep ${m/.m/} $others)

    if [ -z "$e" ] ; then
        echo "$m not used"
    fi

done