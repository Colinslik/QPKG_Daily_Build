#!/bin/sh

Daily_Build_path=admin@172.17.22.134:/share/Qpkg_Daily/

YT_Daily_Build_path=/share/Hybrid_Backup_Restore/

QPKG_ROOT=`getcfg QDK Install_Path -f /etc/config/qpkg.conf`

qpkg_path=$QPKG_ROOT/MyQPKG/

qpkg_cfg=qpkg.cfg

output_path=build/

x86_server=root@172.17.30.202

x86_src=/mnt/vdisk/git_4.2.0/

x86_path=x86/

x86_HAL_server=root@172.17.30.206

x86_HAL_src=/mnt/vdisk/git_4.2.0/

x86_HAL_path=x86_hal/

x86_SNAPSHOT_server=root@172.17.30.31

x86_SNAPSHOT_src=/mnt/vdisk/git_4.2.0/

x86_SNAPSHOT_path=x86_snapshot/

x86ce_server=root@172.17.30.204

x86ce_src=/mnt/vdisk/git_4.2.0/

x86ce_path=x86_ce53xx/

arm_x09_server=root@172.17.30.199

arm_x09_src=/mnt/vdisk/git_4.2.0/

arm_x09_path=arm-x09/

arm_x19_server=$arm_x09_server

arm_x19_src=/mnt/vdisk/git_4.2.0/

arm_x19_path=arm-x19/

arm_x31_server=root@172.17.30.200

arm_x31_src=/mnt/vdisk/git_4.2.0/

arm_x31_path=arm-x31/

arm_x41_server=root@172.17.30.201

arm_x41_src=/mnt/vdisk/git_4.2.0/

arm_x41_path=arm-x41/

x53ii_server=root@172.17.30.147

x53ii_src=/mnt/vdisk/4.2.0_hal/

x53ii_path=X53II/

# ========================4.2.1 Binary=====================

folder_421=4.2.1/

binary_path_421=/share/Daily_Build_Binary/

X86_tar=TS-459

X86_HAL_tar=TS-469

X86_SNAPSHOT_tar=TS-470

X86_CE_tar=TS-269H

X09_tar=TS-421

X19_tar=TS-421

X31_tar=TS-X31

X41_tar=TS-X41

X53II_tar=TS-X53II

x53ii_path=X53II/

dummy_file=qboxRequest.cgi

# =========================================================

UI_path=shared/

UI_src=root@172.17.30.202:/mnt/vdisk/git_UI2/

qsync_path=NasUtil/replication/qsync/

qsync_file=qsync

library_path=NasLib/replication/library/

library_file=libgeneral.so.0.0

libqsync_path=NasLib/replication/libqsync/

libqsync_file=libqsync.so.0.0

cgi_path=NasMgmt/HTTP/WebPage/UI_2.1/Backup/

qsync_cgi_1=qsyncrequest.cgi

qsync_cgi_2=hdusb_stratct.cgi

qsync_cgi_3=extdriverequest.cgi

qsync_cgi_4=backupRequest.cgi

cgi_file=*.cgi

Icons=icons/

UI_src_file=UI/

UI_cgi=cgi/

UI_des_file=backupRestore/

Rsync_cgi_path=NasMgmt/HTTP/WebPage/UI_2.1/Home/

Rsync_cgi_file=wizReq.cgi

Rsync_sh_path=NasMgmt/HTTP/WebPage/misc/

Rsync_sh_file=rsyncRR.sh

Rsync_SpeedTest_path=RootFS/init.d_509/

Rsync_SpeedTest_file=rsyncSpeedTest.sh

Rsync_exe_path=SysUtil/rsync-3.0.7/

Rsync_exe=rsync

Rsync_hbrm_path=NasMgmt/HTTP/WebPage/UI_2.1/Backup/

Rsync_hbrm_file=download_hbrm_diagnose_report.sh

Version_server=root@172.17.30.31

Version_src=/mnt/vdisk/

Version_src_file=git_version/QPKG/shared/

Version_src_script=scripts/

Version_path=shared/

X86_model_name=x86

HAL_model_name=hal

CE_model_name=x86_ce

X09_model_name=x09

X31_model_name=x31

X41_model_name=x41

NOW=$(date +%y%m%d)

Date=$(date +%Y_%m_%d)

Year=$(date +%Y)

Month=$(date +%b)

Day=$(date +%d)

Python_path=/share/Python_Lib/

Python_file=python/

# ===============scp retry function===========================
function SCP ()
{
  # input parameter
  server=$1
  src=$2
  name=$3
  local_path=$4

  while : ; do

    # local parameter
    remote=`ssh $server cksum $src$name | awk '{print $1}'`
    local=`cksum $local_path$name | awk '{print $1}'`

    if [ $remote ==  $local ]; then
       break;
    else
       scp -rp ${server}:$src$name $local_path$name 1>/dev/null 2>/dev/null
    fi
  done
}
#==============================================================

# ===============File Check function===========================
function check_files ()
{
  # input parameter
  folder_path=$1
  file_counts=$2

 cd $folder_path
 if [ $(ls -l | wc -l | awk '{print $1}') == $file_counts ]
 then
   echo "true"
 else
   echo >&2 "File counts is $(ls -l | wc -l | awk '{print $1}') and mismatch with $file_counts"
   echo "false"
 fi
}
#==============================================================


function x86()
{
  echo "===========Start X86 Qpkg Build ... ==========="


  # X86 Model Files

  # copy src file from build machine to X86 path
  cd $qpkg_path$x86_path
  rm * 1>/dev/null 2>/dev/null
  rm -rf $Python_file 1>/dev/null 2>/dev/null

  SCP $x86_server $x86_src$qsync_path $qsync_file $qpkg_path$x86_path 1>/dev/null 2>/dev/null
  SCP $x86_server $x86_src$library_path $library_file $qpkg_path$x86_path 1>/dev/null 2>/dev/null
  SCP $x86_server $x86_src$libqsync_path $libqsync_file $qpkg_path$x86_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $x86_server $x86_src$cgi_path $cgi_files $qpkg_path$x86_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to X86 path
#  SCP $x86_server $x86_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$x86_path 1>/dev/null 2>/dev/null
  SCP $x86_server $x86_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$x86_path 1>/dev/null 2>/dev/null
  SCP $x86_server $x86_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$x86_path 1>/dev/null 2>/dev/null
  SCP $x86_server $x86_src$Rsync_exe_path $Rsync_exe $qpkg_path$x86_path 1>/dev/null 2>/dev/null
  SCP $x86_server $x86_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$x86_path 1>/dev/null 2>/dev/null


  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #copy python lib to X86 path
  cp -rp $Python_path$X86_model_name/$Python_file $Python_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$x86_path 16)

  if [ $check_flag == "true" ]
  then
  #  echo "Check OK!"
   : 
  else
    cd $qpkg_path$x86_path
    rm -rf * 1>/dev/null 2>/dev/null
  fi


  echo "===========END X86 Qpkg Build  ...  ==========="
  echo " "
}


function hal()
{
  echo "===========Start X86_HAL Qpkg Build ... ==========="


  # X86_HAL Model Files

  # copy src file from build machine to X86_HAL path
  cd $qpkg_path$x86_path
  rm -rf $HAL_model_name 1>/dev/null 2>/dev/null
  cd $qpkg_path$x86_HAL_path
  rm -rf * 1>/dev/null 2>/dev/null

  SCP $x86_HAL_server $x86_HAL_src$qsync_path $qsync_file $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null
  SCP $x86_HAL_server $x86_HAL_src$library_path $library_file $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null
  SCP $x86_HAL_server $x86_HAL_src$libqsync_path $libqsync_file $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $x86_HAL_server $x86_HAL_src$cgi_path $cgi_files $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to X86_HAL path
#  SCP $x86_HAL_server $x86_HAL_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null
  SCP $x86_HAL_server $x86_HAL_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null
  SCP $x86_HAL_server $x86_HAL_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null
  SCP $x86_HAL_server $x86_HAL_src$Rsync_exe_path $Rsync_exe $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null
  SCP $x86_HAL_server $x86_HAL_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$x86_HAL_path 1>/dev/null 2>/dev/null

  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$x86_HAL_path 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $x86_HAL_path $x86_path
    rm -rf $x86_HAL_path* 1>/dev/null 2>/dev/null
    cd $qpkg_path$x86_path
    mv $x86_HAL_path $HAL_model_name
  else
    cd $qpkg_path$x86_HAL_path
    rm -rf * 1>/dev/null 2>/dev/null
  fi

  echo "===========END X86_HAL Qpkg Build  ...  ==========="
  echo " "
}

function snapshot()
{
  echo "===========Start X86_SNAPSHOT Qpkg Build ... ==========="


  # X86_SNAPSHOT Model Files

  # copy src file from build machine to X86_SNAPSHOT path
  cd $qpkg_path$x86_path
  rm -rf $x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir $x86_SNAPSHOT_path
  cd $qpkg_path$x86_SNAPSHOT_path

  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$qsync_path $qsync_file $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$library_path $library_file $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$libqsync_path $libqsync_file $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$cgi_path $cgi_files $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to X86_SNAPSHOT path
#  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$Rsync_exe_path $Rsync_exe $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  SCP $x86_SNAPSHOT_server $x86_SNAPSHOT_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$x86_SNAPSHOT_path 1>/dev/null 2>/dev/null

  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$x86_SNAPSHOT_path 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    mv $x86_SNAPSHOT_path $x86_path$x86_SNAPSHOT_path
  else
    cd $qpkg_path
    rm -rf $x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  fi


  echo "===========END X86_SNAPSHOPT Qpkg Build  ...  ==========="
  echo " "
}

function x86_ce()
{ 
  echo "===========Start X86_CE53XX Qpkg Build ... ==========="


  # X86_CE53XX Model Files

  # copy src file from build machine to X86_CE53XX path
  cd $qpkg_path$x86ce_path
  rm * 1>/dev/null 2>/dev/null
  rm -rf $Python_file 1>/dev/null 2>/dev/null

  SCP $x86ce_server $x86ce_src$qsync_path $qsync_file $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null
  SCP $x86ce_server $x86ce_src$library_path $library_file $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null
  SCP $x86ce_server $x86ce_src$libqsync_path $libqsync_file $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $x86ce_server $x86ce_src$cgi_path $cgi_files $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to X86_CE53XX path
#  SCP $x86ce_server $x86ce_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null
  SCP $x86ce_server $x86ce_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null
  SCP $x86ce_server $x86ce_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null
  SCP $x86ce_server $x86ce_src$Rsync_exe_path $Rsync_exe $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null
  SCP $x86ce_server $x86ce_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$x86ce_path 1>/dev/null 2>/dev/null


  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #copy python lib to X86_CE53XX path
  cp -rp $Python_path$CE_model_name/$Python_file $Python_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$x86ce_path 13)

  if [ $check_flag == "true" ]
  then
    #cd $qpkg_path
    #cp -rp $x86ce_path $x86_path
    #rm -rf $x86ce_path* 1>/dev/null 2>/dev/null
    #cd $qpkg_path$x86_path
    #mv $x86ce_path $CE_model_name
    :
  else
    cd $qpkg_path$x86ce_path
    rm -rf * 1>/dev/null 2>/dev/null
  fi


  echo "===========END X86_CE53XX Qpkg Build  ...  ==========="
  echo " "
}


function x09()
{ 
  echo "===========Start ARM_X09 Qpkg Build ... ==========="


  # ARM_X09 Model Files

  # copy src file from build machine to ARM_X09 path
  cd $qpkg_path$arm_x09_path
  rm * 1>/dev/null 2>/dev/null
  rm -rf $Python_file 1>/dev/null 2>/dev/null

  SCP $arm_x09_server $arm_x09_src$qsync_path $qsync_file $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null
  SCP $arm_x09_server $arm_x09_src$library_path $library_file $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null
  SCP $arm_x09_server $arm_x09_src$libqsync_path $libqsync_file $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $arm_x09_server $arm_x09_src$cgi_path $cgi_files $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to ARM_X09 path
#  SCP $arm_x09_server $arm_x09_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null
  SCP $arm_x09_server $arm_x09_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null
  SCP $arm_x09_server $arm_x09_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null
  SCP $arm_x09_server $arm_x09_src$Rsync_exe_path $Rsync_exe $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null
  SCP $arm_x09_server $arm_x09_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$arm_x09_path 1>/dev/null 2>/dev/null

  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #copy python lib to ARM_X09 path
  cp -rp $Python_path$X09_model_name/$Python_file $Python_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$arm_x09_path 13)

  if [ $check_flag == "true" ]
  then
    #cd $qpkg_path
    #cp -rp $arm_x09_path $x86_path
    #rm -rf $arm_x09_path* 1>/dev/null 2>/dev/null
    #cd $qpkg_path$x86_path
    #mv $arm_x09_path $X09_model_name
    :
  else
    cd $qpkg_path$arm_x09_path
    rm -rf * 1>/dev/null 2>/dev/null
  fi



  echo "===========END ARM_X09 Qpkg Build  ...  ==========="
  echo " "
}


function x19()
{ 
  # echo "===========Start ARM_X19 Qpkg Build ... ==========="


  # ARM_X19 Model Files

  # copy src file from build machine to ARM_X19 path
  #cd $qpkg_path$arm_x19_path
  #rm * 1>/dev/null 2>/dev/null
  #rm -rf $Python_file 1>/dev/null 2>/dev/null

  #SCP $arm_x19_server $arm_x19_src$qsync_path $qsync_file $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null
  #SCP $arm_x19_server $arm_x19_src$library_path $library_file $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null
  #SCP $arm_x19_server $arm_x19_src$libqsync_path $libqsync_file $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null

  #for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  #do
  #  SCP $arm_x19_server $arm_x19_src$cgi_path $cgi_files $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null
  #done

  # copy Rsync file from build machine to ARM_X19 path
  #SCP $arm_x19_server $arm_x19_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null
  #SCP $arm_x19_server $arm_x19_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null
  #SCP $arm_x19_server $arm_x19_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null
  #SCP $arm_x19_server $arm_x19_src$Rsync_exe_path $Rsync_exe $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null
  #SCP $arm_x19_server $arm_x19_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$arm_x19_path 1>/dev/null 2>/dev/null

  #change access permissions to script file
  #chmod 755 $Rsync_sh_file
  #chmod 755 $Rsync_SpeedTest_file
  #chmod 755 $Rsync_exe
  #chmod 755 $Rsync_hbrm_file


  #copy python lib to ARM_X19 path
  #cp -rp $Python_path$X09_model_name/$Python_file $Python_file


  #check whether all files are done or delete this folder to block building.
  #check_flag=$(check_files $qpkg_path$arm_x19_path 13)

  #if [ $check_flag == "true" ]
  #then
    #cd $qpkg_path
    #cp -rp $arm_x19_path $x86_path
    #rm -rf $arm_x19_path* 1>/dev/null 2>/dev/null
    #cd $qpkg_path$x86_path
    #mv $arm_x19_path $X19_model_name
    :
  #else
  #  cd $qpkg_path$arm_x19_path
  #  rm -rf * 1>/dev/null 2>/dev/null
  #fi


  # echo "===========END ARM_X19 Qpkg Build  ...  ==========="
  # echo " "
}


function x31()
{
  echo "===========Start ARM_X31 Qpkg Build ... ==========="


  # ARM_X31 Model Files

  # copy src file from build machine to ARM_X31 path
  cd $qpkg_path$arm_x31_path
  rm * 1>/dev/null 2>/dev/null
  rm -rf $Python_file 1>/dev/null 2>/dev/null

  SCP $arm_x31_server $arm_x31_src$qsync_path $qsync_file $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null
  SCP $arm_x31_server $arm_x31_src$library_path $library_file $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null
  SCP $arm_x31_server $arm_x31_src$libqsync_path $libqsync_file $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $arm_x31_server $arm_x31_src$cgi_path $cgi_files $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to ARM_X31 path
#  SCP $arm_x31_server $arm_x31_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null
  SCP $arm_x31_server $arm_x31_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null
  SCP $arm_x31_server $arm_x31_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null
  SCP $arm_x31_server $arm_x31_src$Rsync_exe_path $Rsync_exe $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null
  SCP $arm_x31_server $arm_x31_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$arm_x31_path 1>/dev/null 2>/dev/null

  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #copy python lib to ARM_X31 path
  cp -rp $Python_path$X31_model_name/$Python_file $Python_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$arm_x31_path 13)

  if [ $check_flag == "true" ]
  then
    #cd $qpkg_path
    #cp -rp $arm_x31_path $x86_path
    #rm -rf $arm_x31_path* 1>/dev/null 2>/dev/null
    #cd $qpkg_path$x86_path
    #mv $arm_x31_path $X31_model_name
    :
  else
    cd $qpkg_path$arm_x31_path
    rm -rf * 1>/dev/null 2>/dev/null
  fi



  echo "===========END ARM_X31 Qpkg Build  ...  ==========="
  echo " "
}

function x41()
{
  echo "===========Start ARM_X41 Qpkg Build ... ==========="


  # ARM_X41 Model Files

  # copy src file from build machine to ARM_X41 path
  cd $qpkg_path$arm_x41_path
  rm * 1>/dev/null 2>/dev/null
  rm -rf $Python_file 1>/dev/null 2>/dev/null

  SCP $arm_x41_server $arm_x41_src$qsync_path $qsync_file $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null
  SCP $arm_x41_server $arm_x41_src$library_path $library_file $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null
  SCP $arm_x41_server $arm_x41_src$libqsync_path $libqsync_file $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $arm_x41_server $arm_x41_src$cgi_path $cgi_files $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to ARM_X41 path
#  SCP $arm_x41_server $arm_x41_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null
  SCP $arm_x41_server $arm_x41_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null
  SCP $arm_x41_server $arm_x41_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null
  SCP $arm_x41_server $arm_x41_src$Rsync_exe_path $Rsync_exe $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null
  SCP $arm_x41_server $arm_x41_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$arm_x41_path 1>/dev/null 2>/dev/null

  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #copy python lib to ARM_X41 path
  cp -rp $Python_path$X41_model_name/$Python_file $Python_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$arm_x41_path 13)

  if [ $check_flag == "true" ]
  then
    #cd $qpkg_path
    #cp -rp $arm_x41_path $x86_path
    #rm -rf $arm_x41_path* 1>/dev/null 2>/dev/null
    #cd $qpkg_path$x86_path
    #mv $arm_x41_path $X41_model_name
    :
  else
    cd $qpkg_path$arm_x41_path
    rm -rf * 1>/dev/null 2>/dev/null
  fi


  echo "===========END ARM_X41 Qpkg Build  ...  ==========="
  echo " "
}

function x53ii()
{
  echo "===========Start X53II Qpkg Build ... ==========="


  # X53II Model Files

  # copy src file from build machine to X53II path
  cd $qpkg_path$x86_path
  rm -rf $x53ii_path 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir $x53ii_path
  cd $qpkg_path$x53ii_path

  SCP $x53ii_server $x53ii_src$qsync_path $qsync_file $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null
  SCP $x53ii_server $x53ii_src$library_path $library_file $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null
  SCP $x53ii_server $x53ii_src$libqsync_path $libqsync_file $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null

  for cgi_files in $qsync_cgi_1 $qsync_cgi_2 $qsync_cgi_3 $qsync_cgi_4
  do
    SCP $x53ii_server $x53ii_src$cgi_path $cgi_files $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null
  done

  # copy Rsync file from build machine to X53II path
#  SCP $x53ii_server $x53ii_src$Rsync_cgi_path $Rsync_cgi_file $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null
  SCP $x53ii_server $x53ii_src$Rsync_sh_path $Rsync_sh_file $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null
  SCP $x53ii_server $x53ii_src$Rsync_SpeedTest_path $Rsync_SpeedTest_file $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null
  SCP $x53ii_server $x53ii_src$Rsync_exe_path $Rsync_exe $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null
  SCP $x53ii_server $x53ii_src$Rsync_hbrm_path $Rsync_hbrm_file $qpkg_path$x53ii_path 1>/dev/null 2>/dev/null

  #change access permissions to script file
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file


  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$x53ii_path 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    mv $x53ii_path $x86_path$x53ii_path
  else
    cd $qpkg_path
    rm -rf $x53ii_path 1>/dev/null 2>/dev/null
  fi


  echo "===========END X53II Qpkg Build  ...  ==========="
  echo " "
}

#============================================4.2.1 QPKG Builder=============================================

function x86_421()
{
  echo "===========Start 4.2.1 X86 Qpkg Build ... ==========="


  # X86 Model Files

  # copy src file from build machine to X86 path
  cd $qpkg_path$x86_path
  rm -rf $folder_421 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X86_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X86_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X86_tar}.tar 1>/dev/null 2>/dev/null
  cp -rp $qpkg_path$folder_421$X86_tar/* $qpkg_path$folder_421
  rm -rf $X86_tar 1>/dev/null 2>/dev/null

  #change access permissions to script file
  cd $qpkg_path$folder_421
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $x86_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
	:
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 X86 Qpkg Build  ...  ==========="
  echo " "

}


function snapshot_421()
{
  echo "===========Start 4.2.1 X86_SNAPSHOT Qpkg Build ... ==========="


  # X86_SNAPSHOT Model Files

  # copy src file from build machine to X86_SNAPSHOT path
  cd $qpkg_path$x86_path$folder_421
  rm -rf $x86_SNAPSHOT_path 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X86_SNAPSHOT_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X86_SNAPSHOT_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X86_SNAPSHOT_tar}.tar 1>/dev/null 2>/dev/null
  mv $X86_SNAPSHOT_tar $x86_SNAPSHOT_path

  #change access permissions to script file
  cd $qpkg_path$folder_421$x86_SNAPSHOT_path
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$x86_SNAPSHOT_path/$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421$x86_SNAPSHOT_path 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $x86_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
	:
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 X86_SNAPSHOT Qpkg Build  ...  ==========="
  echo " "

}


function hal_421()
{
  echo "===========Start 4.2.1 X86_HAL Qpkg Build ... ==========="


  # X86_HAL Model Files

  # copy src file from build machine to X86_HAL path
  cd $qpkg_path$x86_path$folder_421
  rm -rf $x86_HAL_path 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X86_HAL_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X86_HAL_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X86_HAL_tar}.tar 1>/dev/null 2>/dev/null
  mv $X86_HAL_tar $HAL_model_name 

  #change access permissions to script file
  cd $qpkg_path$folder_421$HAL_model_name
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$HAL_model_name/$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421$HAL_model_name 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $x86_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
	:
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 X86_HAL Qpkg Build  ...  ==========="
  echo " "
}


function x86_ce_421()
{
  echo "===========Start 4.2.1 X86_CE53XX Qpkg Build ... ==========="


  # X86_CE53XX Model Files

  # copy src file from build machine to X86_CE53XX path
  cd $qpkg_path$x86ce_path
  rm -rf $folder_421 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X86_CE_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X86_CE_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X86_CE_tar}.tar 1>/dev/null 2>/dev/null
  cp -rp $qpkg_path$folder_421$X86_CE_tar/* $qpkg_path$folder_421
  rm -rf $X86_CE_tar 1>/dev/null 2>/dev/null

  #change access permissions to script file
  cd $qpkg_path$folder_421
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $x86ce_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
	:
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 X86_CE53XX Qpkg Build  ...  ==========="
  echo " "

}


function x09_421()
{
  echo "===========Start 4.2.1 ARM_X09 Qpkg Build ... ==========="


  # ARM_X09 Model Files

  # copy src file from build machine to ARM_X09 path
  cd $qpkg_path$arm_x09_path
  rm -rf $folder_421 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X09_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X09_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X09_tar}.tar 1>/dev/null 2>/dev/null
  cp -rp $qpkg_path$folder_421$X09_tar/* $qpkg_path$folder_421
  rm -rf $X09_tar 1>/dev/null 2>/dev/null

  #change access permissions to script file
  cd $qpkg_path$folder_421
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $arm_x09_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
	:
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 ARM_X09 Qpkg Build  ...  ==========="
  echo " "

}

function x19_421()
{
#  echo "===========Start 4.2.1 ARM_X19 Qpkg Build ... ==========="


  # ARM_X19 Model Files

  # copy src file from build machine to ARM_X19 path
#  cd $qpkg_path$arm_x19_path
#  rm -rf $folder_421 1>/dev/null 2>/dev/null
#  cd $qpkg_path
#  mkdir -p $folder_421
#  cp -rp $binary_path_421${X19_tar}.tar $qpkg_path$folder_421
#  cd $qpkg_path$folder_421
#  tar -xvf ${X19_tar}.tar 1>/dev/null 2>/dev/null
#  rm -rf ${X19_tar}.tar 1>/dev/null 2>/dev/null
#  cp -rp $qpkg_path$folder_421$X19_tar/* $qpkg_path$folder_421
#  rm -rf $X19_tar 1>/dev/null 2>/dev/null

  #change access permissions to script file
#  cd $qpkg_path$folder_421
#  chmod 755 $Rsync_sh_file
#  chmod 755 $Rsync_SpeedTest_file
#  chmod 755 $Rsync_exe
#  chmod 755 $Rsync_hbrm_file

  #remove dummy file
#  rm -rf $qpkg_path$folder_421$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
#  check_flag=$(check_files $qpkg_path$folder_421 11)

#  if [ $check_flag == "true" ]
#  then
#    cd $qpkg_path
#    cp -rp $folder_421 $arm_x19_path
#    rm -rf $folder_421 1>/dev/null 2>/dev/null
	:
#  else
#    cd $qpkg_path
#    rm -rf $folder_421 1>/dev/null 2>/dev/null
#  fi


#  echo "===========END 4.2.1 ARM_X19 Qpkg Build  ...  ==========="
#  echo " "

}

function x31_421()
{
  echo "===========Start 4.2.1 ARM_X31 Qpkg Build ... ==========="


  # ARM_X31 Model Files

  # copy src file from build machine to ARM_X31 path
  cd $qpkg_path$arm_x31_path
  rm -rf $folder_421 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X31_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X31_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X31_tar}.tar 1>/dev/null 2>/dev/null
  cp -rp $qpkg_path$folder_421$X31_tar/* $qpkg_path$folder_421
  rm -rf $X31_tar 1>/dev/null 2>/dev/null

  #change access permissions to script file
  cd $qpkg_path$folder_421
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $arm_x31_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
	:
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 ARM_X31 Qpkg Build  ...  ==========="
  echo " "

}

function x41_421()
{
  echo "===========Start 4.2.1 ARM_X41 Qpkg Build ... ==========="


  # ARM_X41 Model Files

  # copy src file from build machine to ARM_X41 path
  cd $qpkg_path$arm_x41_path
  rm -rf $folder_421 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X41_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X41_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X41_tar}.tar 1>/dev/null 2>/dev/null
  cp -rp $qpkg_path$folder_421$X41_tar/* $qpkg_path$folder_421
  rm -rf $X41_tar 1>/dev/null 2>/dev/null

  #change access permissions to script file
  cd $qpkg_path$folder_421
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $arm_x41_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
        :
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 ARM_X41 Qpkg Build  ...  ==========="
  echo " "

}

function x53ii_421()
{
  echo "===========Start 4.2.1 X53II Qpkg Build ... ==========="


  # X53II Model Files

  # copy src file from build machine to X53II path
  cd $qpkg_path$x86_path$folder_421
  rm -rf $x53ii_path 1>/dev/null 2>/dev/null
  cd $qpkg_path
  mkdir -p $folder_421
  cp -rp $binary_path_421${X53II_tar}.tar $qpkg_path$folder_421
  cd $qpkg_path$folder_421
  tar -xvf ${X53II_tar}.tar 1>/dev/null 2>/dev/null
  rm -rf ${X53II_tar}.tar 1>/dev/null 2>/dev/null
  mv $X53II_tar $x53ii_path

  #change access permissions to script file
  cd $qpkg_path$folder_421$x53ii_path
  chmod 755 $Rsync_sh_file
  chmod 755 $Rsync_SpeedTest_file
  chmod 755 $Rsync_exe
  chmod 755 $Rsync_hbrm_file

  #remove dummy file
  rm -rf $qpkg_path$folder_421$x53ii_path/$dummy_file 1>/dev/null 2>/dev/null

  #check whether all files are done or delete this folder to block building.
  check_flag=$(check_files $qpkg_path$folder_421$x53ii_path 11)

  if [ $check_flag == "true" ]
  then
    cd $qpkg_path
    cp -rp $folder_421 $x86_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
        :
  else
    cd $qpkg_path
    rm -rf $folder_421 1>/dev/null 2>/dev/null
  fi


  echo "===========END 4.2.1 X53II Qpkg Build  ...  ==========="
  echo " "

}

#============================================4.2.1 QPKG Builder End=========================================


function ui()
{
  echo "===========Start Copy UI ... ==========="


  # copy UI from git
  cd $qpkg_path$UI_path
  rm -rf $UI_des_file 1>/dev/null 2>/dev/null
  rm $cgi_file 1>/dev/null 2>/dev/null
#  scp -rp $UI_src$UI_src_file $UI_des_file 1>/dev/null 2>/dev/null
  scp -rp $UI_src $UI_des_file 1>/dev/null 2>/dev/null

  cd $qpkg_path$UI_path$UI_des_file
  rm -rf .git 1>/dev/null 2>/dev/null

  cd $qpkg_path$UI_path$UI_des_file$UI_cgi
  for f in *.py ; do mv "$f" "${f%.py}.cgi" ; done

  cd $qpkg_path$UI_path
  cp -p "$qpkg_path$UI_path$UI_des_file$UI_cgi"*.cgi $qpkg_path$UI_path
  rm -rf $UI_des_file$UI_cgi


  #copy icons to QPKG folder
  cd $qpkg_path
  rm -rf $Icons 1>/dev/null 2>/dev/null
  cd $qpkg_path$UI_path$UI_des_file
  mv $Icons $qpkg_path
}

function versioning()
{
  echo "===========Start Copy Backup Versioning Script ... ==========="


  # copy Backup Versioning script from git
  cd $qpkg_path$Version_path
  rm -rf $Version_src_script 1>/dev/null 2>/dev/null
  ssh $Version_server cp -rp $Version_src$Version_src_file$Version_src_script $Version_src
  ssh $Version_server python -m compileall  $Version_src$Version_src_script*
  scp -rp ${Version_server}:$Version_src$Version_src_script $Version_src_script 1>/dev/null 2>/dev/null
  ssh $Version_server rm -rf $Version_src$Version_src_script


  # Backup Version Build script 
  chmod 755 $Version_src_script*
 # python -m compileall $Version_src_script
  rm -f $Version_src_script*.py
}

function update_version_number()
{
  echo "===========Update Version number  ...  ==========="
  echo " "

  # Update Version number
  cd $qpkg_path
  sed -i 's/ *QPKG_VER=".*$/\QPKG_VER="1.0.'${NOW}'\"/g' $qpkg_path$qpkg_cfg 1>/dev/null 2>/dev/null
  sed -i 's/?{Build_Num}.*/\?'${Date}'\"\,/g' "$qpkg_path"shared/backupRestore/config.json  1>/dev/null 2>/dev/null
}


# Mode selection

case ${1} in

"x86")
        x86
	;;
"x86_421")
	x86_421
	exit 1
	;;
"hal")
        hal
        exit 1
	;;
"hal_421")
	hal_421
	exit 1
	;;
"snapshot")
        snapshot
        exit 1
        ;;
"snapshot_421")
        snapshot_421
        exit 1
        ;;
"x86_ce")
        x86_ce
        ;;
"x86_ce_421")
	x86_ce_421
	exit 1
	;;
"x09")
        x09
        ;;
"x09_421")
	x09_421
	exit 1
	;;
"x19")
        x19
        ;;
"x19_421")
	x19_421
	exit 1
	;;
"x31")
        x31
        ;;
"x31_421")
	x31_421
	exit 1
	;;
"x41")
        x41
        ;;
"x41_421")
	x41_421
	exit 1
	;;
"x53ii")
        x53ii
        exit 1
        ;;
"x53ii_421")
	x53ii_421
	exit 1
	;;
"ui")
        ui
        ;;
"versioning")
        versioning
        ;;
"all")
        x86_421
        hal_421
	hal
        snapshot_421
        snapshot
	x53ii_421
	x53ii
        x86
        x86_ce_421
	x86_ce
        x09_421
	x09
        x19_421
	x19
        x31_421
	x31
        x41_421
	x41
        ui
        versioning
	update_version_number
	;;
*)
        echo "Usage: $0 {x86/x86_421 | hal/hal_421 | snapshot/snapshot_421 | x86_ce/x86_ce_421 | x09/x09_421 | x19/x19_421 | x31/x31_421 | x41/x41_421 | x53ii/x53ii_421 | ui | versioning | all}"
        exit 1
esac


echo "===========Remove tempfile  ...  ==========="
echo " "

# remove the last Qpkg file
cd $qpkg_path$output_path
rm -rf *


echo "===========Start QBuild Script ...  ==========="
echo " "

# QPKG Builder
cd $qpkg_path
qbuild 1>/dev/null 2>/dev/null


echo "===========Start Copy Qpkg to Daily Build Folder  ...  ==========="
echo " "

# copy Qpkg to Daily Build folder
cd $qpkg_path
mkdir -p $Year/$Month/$Day/

file_name=`ls $output_path | grep x86.qpkg`
cp $output_path$file_name $Year/$Month/$Day/

file_name=`ls $output_path | grep ce53xx`
cp $output_path"$file_name" $Year/$Month/$Day/"${file_name/ce53xx/es}"

file_name=`ls $output_path | grep x09`
cp $output_path"$file_name" $Year/$Month/$Day/"${file_name/-x09/_kw}"

file_name=`ls $output_path | grep x31`
cp $output_path"$file_name" $Year/$Month/$Day/"${file_name/-x31/_ms}"

file_name=`ls $output_path | grep x41`
cp $output_path"$file_name" $Year/$Month/$Day/"${file_name/-x41/_al}"


scp -r $Year $Daily_Build_path
cp -r $Year $YT_Daily_Build_path
rm -rf $Year

