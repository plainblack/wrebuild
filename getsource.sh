#!/bin/bash

# This script will help you get all needed sources 
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir source
cd source

wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.20.tar.gz
tar xfz pcre-8.20.tar.gz

wget http://nginx.org/download/nginx-1.0.11.tar.gz
tar xfz nginx-1.0.11.tar.gz


