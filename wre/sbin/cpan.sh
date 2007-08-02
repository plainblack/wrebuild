#!/bin/sh
. /data/wre/sbin/setenvironment.sh
echo $PATH
perl -MCPAN -e shell
