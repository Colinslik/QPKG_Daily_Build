#!/bin/bash

export PROJECT=x86
export PRJROOT=/opt/cross-project/x86/sys-root
export ARCH=x86
export TARGET=
export CROSS_COMPILE=
export TARGET_PREFIX=${PRJROOT}
export SYS_TARGET_PREFIX=${PRJROOT}
export PATH=${SYS_TARGET_PREFIX}/bin:${PATH}:/usr/sbin:/sbin
export LD_LIBRARY_PATH=/opt/cross-project/x86/sys-root/lib:/opt/cross-project/x86/sys-root/usr/lib

#X86_Model_src=/opt/cross-project/x86-glibc-2.6.env

git_src=/mnt/vdisk/git_4.2.1/

kernel_path=Kernel/

git_model_path=Model/TS-X53II/

log_path=/mnt/vdisk/log/

git_origin_branch=origin

git_pull_ori=backupteamMaster

git_pull_branch=DevBranch-master

NOW=$(date +%Y%m%d%H%M)

log_name=Model_build_$NOW.log

buildFile=NasMgmt/HTTP/WebPage/UI_2.1/Backup/qsyncrequest.cgi


#===============================For 4.2.1 build setting===========================

MediaLibrary2_src=NasUtil/MediaLibrary2/

linux_src=Kernel/linux-3.19/

Driver_src=Driver/

photostation5_src=NasMgmt/HTTP/WebPage/photostation5/

musicstation5_src=NasMgmt/HTTP/WebPage/musicstation5/

videostation5_src=NasMgmt/HTTP/WebPage/videostation5/

filestation5_src=NasMgmt/HTTP/WebPage/filestation5/

#1.library
rtrr_library_path=NasLib/replication/library/

rtrr_libqsync_path=NasLib/replication/libqsync/

#2.bin
qsync_path=NasUtil/replication/qsync/

#3.script
script_path=/mnt/vdisk/

replace_code_script=copy_hybrid_code.sh


# qsync Model build

# clean all log file
#cd $log_path
#rm -rf *

mkdir -p $log_path


# MediaLibrary2 pull
echo "===========Start MediaLibrary2 ... ===========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1

cd $git_src$MediaLibrary2_src
rm $git_src${MediaLibrary2_src}.git/*.lock
git pull >> $log_path$log_name 2>&1
cd $git_src$linux_src
rm $git_src${linux_src}.git/*.lock
git pull >> $log_path$log_name 2>&1
cd $git_src$Driver_src
rm $git_src${Driver_src}.git/*.lock
git pull >> $log_path$log_name 2>&1
cd $git_src$photostation5_src
rm $git_src${photostation5_src}.git/*.lock
git pull >> $log_path$log_name 2>&1
cd $git_src$musicstation5_src
rm $git_src${musicstation5_src}.git/*.lock
git pull >> $log_path$log_name 2>&1
cd $git_src$videostation5_src
rm $git_src${videostation5_src}.git/*.lock
git pull >> $log_path$log_name 2>&1
cd $git_src$filestation5_src
rm $git_src${filestation5_src}.git/*.lock
git pull >> $log_path$log_name 2>&1

echo " " >> $log_path$log_name 2>&1
echo "===========END MediaLibrary2 ... =============" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1


# Update Kernel
cd $git_src$kernel_path
echo "===========Start Kernel pull ...===========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1

rm $git_src${kernel_path}.git/*.lock
git reset --hard 1>/dev/null 2>/dev/null
git clean -dfx 1>/dev/null 2>/dev/null
git pull >> $log_path$log_name 2>&1

echo "===========END Kernel pull ...  ===========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1

# stash this branch and checkout to master
cd $git_src
echo "===========Start checkout to master ...===========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1

rm ${git_src}.git/*.lock
git stash 1>/dev/null 2>/dev/null
git reset --hard 1>/dev/null 2>/dev/null
git clean -dfx 1>/dev/null 2>/dev/null
git checkout QTS_4.2.1 >> $log_path$log_name 2>&1
git branch -D $git_pull_branch 1>/dev/null 2>/dev/null
git reset --hard 1>/dev/null 2>/dev/null
git clean -dfx 1>/dev/null 2>/dev/null

echo "===========END checkout to master ...  ===========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1


# git pull from git 4.2.1
cd $git_src
echo "===========Start git pull from 4.2.0 ...===========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1

git pull $git_origin_branch QTS_4.2.1 >> $log_path$log_name 2>&1


# clear time error
rm -rf SysUtil/ntp-4.2.8
git checkout -- SysUtil/ntp-4.2.8
find SysUtil/ntp-4.2.8 -type f -print | while read l; do touch -m -t 201505112302 "$l";done
rm -rf SysUtil/dhcpcd-1.3.22-p14
git checkout -- SysUtil/dhcpcd-1.3.22-p14
find SysUtil/dhcpcd-1.3.22-p14 -type f -print | while read l; do touch -m -t 201505112302 "$l";done


echo "===========END git pull from 4.2.1 ...  ===========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1


# X86 Environment variables setup
#cd $git_src$git_model_path
#echo "===========Start X86 Environment variables setup ...=======" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1

#source $X86_Model_src

#echo "===========END X86 Environment variables setup ... ========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1


# Copy Hybrid Code Base
#cd $script_path
#echo "===========Start Copy Hybrid Code Base ...=======" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1

#./$replace_code_script >> $log_path$log_name 2>&1

#echo "===========END Copy Hybrid Code Base ... ========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1


# Clean all partial
#echo "===========Start Clean all partial ...=======" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1

#cd $git_src$rtrr_library_path
#make clean >> $log_path$log_name 2>&1

#cd $git_src$rtrr_libqsync_path
#make clean >> $log_path$log_name 2>&1

#cd $git_src$qsync_path
#make clean >> $log_path$log_name 2>&1

#echo "===========END Clean all partial ... ========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1


# Build Model
cd $git_src$git_model_path
echo "===========Start Model Build ...=======" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1

make  >> $log_path$log_name 2>&1

echo "===========END Model Build ... ========" >> $log_path$log_name 2>&1
echo " " >> $log_path$log_name 2>&1


# create new branch
#cd $git_src
#echo "===========Start change to new branch ...===========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1

#git checkout -b $git_pull_branch af23b1f07be63d44e138d6b756dff85e73c1dea5  >> $log_path$log_name 2>&1

#echo "===========END change to new branch ...  ===========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1


# git pull from YT's git server
#cd $git_src
#echo "===========Start git pull from backupteam ...===========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1

#git pull $git_pull_ori $git_pull_branch >> $log_path$log_name 2>&1

#echo "===========END git pull from backupteam ...  ===========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1


# Build Model V2
#cd $git_src$git_model_path
#echo "===========Start Model Build ...=======" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1

#make  >> $log_path$log_name 2>&1

#echo "===========END Model Build ... ========" >> $log_path$log_name 2>&1
#echo " " >> $log_path$log_name 2>&1
#echo "End Script at $(date +%Y/%m/%d\ %H\:%M)" >> $log_path$log_name 2>&1

