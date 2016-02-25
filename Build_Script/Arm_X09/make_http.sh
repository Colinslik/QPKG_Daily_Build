#!/bin/bash

ARM_Model_src=/opt/cross-project/arm-glibc-2.5.env

# ARM Environment variables setup
source $ARM_Model_src

#get the folloing argrment from partial_build_hal.sh

git_src=$1
cgi_build_path=$2
log_path=$3

NOW=$(date +%Y%m%d%H%M)

log_name=Cgi_build_$NOW.log

cd $git_src$cgi_build_path

make HTTP >> $log_path$log_name 2>&1 &
