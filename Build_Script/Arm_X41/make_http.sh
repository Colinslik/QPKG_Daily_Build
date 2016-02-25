#!/bin/bash

export PROJECT=arm-linux-gnueabihf
export PRJROOT=/opt/cross-project/arm/linaro
export TARGET=arm-linux-gnueabihf
export CROSS_COMPILE=${TARGET}-
export TARGET_PREFIX=${PRJROOT}/arm-linux-gnueabihf/libc
export SYS_TARGET_PREFIX= ${PRJROOT}/arm-linux-gnueabihf/libc
export PATH=${PRJROOT}/usr/include:${PRJROOT}/bin:/usr/local/bin:${PATH}:/usr/sbin:/sbin:../../Others/utils/


git_src=/mnt/vdisk/git_4.2.0/

cgi_path=Model/TS-X41/

log_path=/mnt/vdisk/log/

NOW=$(date +%Y%m%d%H%M)

log_name=Cgi_build_$NOW.log

cd $git_src$cgi_path
make HTTP >> $log_path$log_name 2>&1 &
