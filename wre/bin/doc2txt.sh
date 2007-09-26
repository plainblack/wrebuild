#!/bin/bash

sleep=15 # how many seconds are we tolerant?

nice -n 20 /data/wre/prereqs/bin/catdoc -s us-ascii $1 $1.txt &

# are we running?
while ps $! | grep -c $! >/dev/null 2>&1; do
        sleep 1
        sleep=`expr $sleep - 1`
        if [ "$sleep" -eq 0 ]; then
                kill $!
                exit 1
        fi
done

cat $1.txt
rm -f $1.txt

