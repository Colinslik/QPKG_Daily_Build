#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="HybridBackup"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
QSYNCD_CONF='/etc/qsync/qsyncd.conf'
QSYNCD_EXEC="/usr/bin/qsyncd"
LANGS="CZE DAN DUT ENG ESM FIN FRE GER GRK HUN ITA JPN KOR NOR POL POR ROM RUS SCH SPA SWE TCH THA TUR"
LangPath="/home/httpd/cgi-bin/langs"

#Backup Versioning script
cgiPath=/home/httpd/cgi-bin/BackupVersionV2
old_cgiPath=/home/httpd/cgi-bin/BackupVersion
InstallPath=$(/sbin/getcfg $QPKG_NAME Install_Path -d FALSE -f $CONF)

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)

#Update th binary
#backup_date=`/bin/date -d "$(/bin/ls -le $QPKG_ROOT/backup/qsync | /bin/awk '{print $7,$8,$10}')" +%Y%m%d`
#FW_date=`/sbin/getcfg "System" "Build Number"`
backup_date=`/sbin/cksum $QPKG_ROOT/backup/qsync | /bin/awk '{print $1}'`
FW_date=`/sbin/cksum /usr/bin/qsync | /bin/awk '{print $1}'`
if [ "$(/bin/ls -A $QPKG_ROOT/backup)" ] && [ "$backup_date" != "$FW_date" ] ; then
    /bin/echo "Update the binary to $QPKG_ROOT"
    /bin/cp -p -a /usr/bin/qsync $QPKG_ROOT/backup
    /bin/cp -p -a /home/httpd/cgi-bin/backup/backupRequest.cgi $QPKG_ROOT/backup
    /bin/cp -p -a /home/httpd/cgi-bin/backup/extdriverequest.cgi $QPKG_ROOT/backup
    /bin/cp -p -a /home/httpd/cgi-bin/backup/qsyncrequest.cgi $QPKG_ROOT/backup
    /bin/cp -p -a /home/httpd/cgi-bin/backup/hdusb_stratct.cgi $QPKG_ROOT/backup
    /bin/cp -p -a /usr/lib/libgeneral.so.0.0 $QPKG_ROOT/backup
    /bin/cp -p -a /usr/lib/libqsync.so.0.0 $QPKG_ROOT/backup
    #/bin/cp -p -a /home/httpd/cgi-bin/wizReq.cgi $QPKG_ROOT/backup
    /bin/cp -p -a /etc/init.d/rsyncRR.sh $QPKG_ROOT/backup
    /bin/cp -p -a /etc/init.d/rsyncSpeedTest.sh $QPKG_ROOT/backup
    /bin/cp -p -a /usr/bin/rsync $QPKG_ROOT/backup
else
    /bin/echo "current  backup version is up-to-date."
fi


#Backup Versioning script
    /bin/ln -fs $InstallPath/scripts $cgiPath

    if [ ! "$(/sbin/getcfg BackupVersion Install_Path -f ${CONF})" ]; then
      /bin/echo "Setup compatibility of backup versioning to backupstation."
      /bin/ln -fs $InstallPath/scripts $old_cgiPath
    fi
    /bin/chmod u+x $InstallPath/scripts/*.pyc

    if [ "$ENABLED" != "TRUE" ]; then
        /bin/echo "$QPKG_NAME is disabled."
        exit 1
    fi
    : ADD START ACTIONS HERE
    
#Change folder between 4.2.0 and 4.2.1
	
	if [ "$(/sbin/getcfg "System" version)" = "4.2.1" ] && [ "$(/bin/ls -A $QPKG_ROOT/4.2.1)" ]; then
		/bin/echo "Using 4.2.1 FW binary."
		Model_ver=4.2.1
	else
		/bin/echo "Using default FW version."
		Model_ver=.
	fi

#copy new version of binary to system.

    	if [ "$(/bin/ls -A /lib/libuLinux_hal.so)" ] && [ "$(/bin/ls -A $QPKG_ROOT/hal)" ]; then
        	Target_Name=Snapshot
        	conf_path=/etc/default_config/volume_man.conf
        	Start=$(/bin/sed -n "/\\[$Target_Name]/=" $conf_path)
        	array=($(/bin/sed -n '/\[.*]/=' $conf_path))
        	HAL_MODEL=hal
        	for i in "${!array[@]}"
           	do
               		if [ "${array[$i]}" = "$Start" ]; then

                  		first=${array[$i]}
                  		if [ -z "${array[$((i+1))]}" ]; then
                     			last=\$
                  		else
                     			last=$((${array[$((i+1))]}-1))
                  		fi
                  		snapshot_flag=$(/bin/sed -n "${first},${last}"p $conf_path | /bin/grep Support | /bin/sed -n 's/.*'='/ /p' | /bin/tr [a-z] [A-Z] )
                  		if [ $snapshot_flag == 'YES' ]; then
                       			/bin/echo "This is SnapShot Model."
					Kernel_ver=`/bin/uname -a | /bin/awk '{print $3}'`
					if [ $Kernel_ver == '3.19.8' ] || [ $Kernel_ver == '3.19.8+' ]; then
						HAL_MODEL=X53II
					else
                       				HAL_MODEL=x86_snapshot
					fi
                  		else
                       			/bin/echo "This is HAL Model."
                  		fi
               		fi
           	done
    	else
        	/bin/echo "This model is not support HAL."
        	HAL_MODEL=.
    	fi
    qsyncman_proc=`/bin/ps -ef | /bin/grep -c [q]syncman`
    if [ $qsyncman_proc != 0 ]; then
      /usr/bin/killall qsyncman
    fi
    if [ "$(/bin/ls -A /etc/config/qsync/hbrm_storage.conf)" ]; then
        /bin/echo "hbrm_storage.conf is found."
    else
        /bin/echo "Create hbrm_storage.conf."
        /bin/touch /etc/config/qsync/hbrm_storage.conf
    fi
    /bin/rm -f /usr/bin/qsync
    /bin/rm -f /home/httpd/cgi-bin/backup/backupRequest.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/extdriverequest.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/hdusb_stratct.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/qsyncrequest.cgi
    /bin/rm -f /usr/lib/libgeneral.so.0.0
    /bin/rm -f /usr/lib/libqsync.so.0.0
    #/bin/rm -f /home/httpd/cgi-bin/wizReq.cgi
    /bin/rm -f /etc/init.d/rsyncRR.sh
    /bin/rm -f /etc/init.d/rsyncSpeedTest.sh
    /bin/rm -f /usr/bin/rsync
    /bin/rm -f /home/httpd/cgi-bin/backup/download_hbrm_diagnose_report.sh
    /bin/rm -f /home/httpd/cgi-bin/backup/joblist.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/dashboard.cgi
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/backupRequest.cgi /home/httpd/cgi-bin/backup/backupRequest.cgi
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/extdriverequest.cgi /home/httpd/cgi-bin/backup/extdriverequest.cgi
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/hdusb_stratct.cgi /home/httpd/cgi-bin/backup/hdusb_stratct.cgi
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/qsyncrequest.cgi /home/httpd/cgi-bin/backup/qsyncrequest.cgi
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/libgeneral.so.0.0 /usr/lib/libgeneral.so.0.0
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/libqsync.so.0.0 /usr/lib/libqsync.so.0.0
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/qsync /usr/bin/qsync
    #/bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/wizReq.cgi /home/httpd/cgi-bin/wizReq.cgi
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/rsyncRR.sh /etc/init.d/rsyncRR.sh
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/rsyncSpeedTest.sh /etc/init.d/rsyncSpeedTest.sh
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/rsync /usr/bin/rsync
    /bin/cp -p -a $QPKG_ROOT/$Model_ver/$HAL_MODEL/download_hbrm_diagnose_report.sh /home/httpd/cgi-bin/backup/download_hbrm_diagnose_report.sh
    /bin/cp -p -a $QPKG_ROOT/joblist.cgi /home/httpd/cgi-bin/backup/joblist.cgi
    /bin/cp -p -a $QPKG_ROOT/dashboard.cgi /home/httpd/cgi-bin/backup/dashboard.cgi
    /bin/ln -snf ${QPKG_ROOT}/backupRestore /home/httpd/cgi-bin/qpkg/${QPKG_NAME}
    /bin/ln -snf ${QPKG_ROOT}/python /home/httpd/cgi-bin/backup/python_dir
    /home/httpd/cgi-bin/backup/python_dir/bin/python $QPKG_ROOT/profileID.cgi
    /home/httpd/cgi-bin/backup/python_dir/bin/python $QPKG_ROOT/externalID.cgi shiftup
# restart RTRR     
    /bin/chmod 777 /usr/bin/qsync
    if [ $qsyncman_proc != 0 ]; then
      /etc/rcS.d/S99qsyncman start
    fi
      ;;

  stop)
    : ADD STOP ACTIONS HERE

    qsyncman_proc=`/bin/ps -ef | /bin/grep -c [q]syncman`
    if [ $qsyncman_proc != 0 ]; then
      /usr/bin/killall qsyncman
    fi

#Change folder between 4.2.0 and 4.2.1

        if [ "$(/sbin/getcfg "System" version)" = "4.2.1" ] && [ "$(/bin/ls -A $QPKG_ROOT/4.2.1)" ]; then
		/bin/echo "Using 4.2.1 FW binary."
                Model_ver=4.2.1
        else
                /bin/echo "Using default FW version."
                Model_ver=.
        fi

#check Nas Model is support hal or snapshot

    if [ "$(/bin/ls -A /lib/libuLinux_hal.so)" ] && [ "$(/bin/ls -A $QPKG_ROOT/hal)" ]; then

        Target_Name=Snapshot
        conf_path=/etc/default_config/volume_man.conf
        Start=$(/bin/sed -n "/\\[$Target_Name]/=" $conf_path)
        array=($(/bin/sed -n '/\[.*]/=' $conf_path))
        HAL_MODEL=hal

        for i in "${!array[@]}"
           do
               if [ "${array[$i]}" = "$Start" ]; then

                  first=${array[$i]}

                  if [ -z "${array[$((i+1))]}" ]; then
                     last=\$
                  else
                     last=$((${array[$((i+1))]}-1))
                  fi

                  snapshot_flag=$(/bin/sed -n "${first},${last}"p $conf_path | /bin/grep Support | /bin/sed -n 's/.*'='/ /p' | /bin/tr [a-z] [A-Z] )
                  if [ $snapshot_flag == 'YES' ]; then
			/bin/echo "This is SnapShot Model."
			Kernel_ver=`/bin/uname -a | /bin/awk '{print $3}'`
			if [ $Kernel_ver == '3.19.8' ]; then
				HAL_MODEL=X53II
			else
				HAL_MODEL=x86_snapshot
			fi
                  else
                       /bin/echo "This is HAL Model."
                  fi
               fi
           done
    else
        /bin/echo "This model is not support HAL."
        HAL_MODEL=.
    fi


#Resume the binary

#system_date=`/bin/date -d "$(/bin/ls -le /usr/bin/qsync | /bin/awk '{print $7,$8,$10}')" +%Y%m%d`
#qpkg_date=`/bin/date -d "$(/bin/ls -le $QPKG_ROOT/qsync | /bin/awk '{print $7,$8,$10}')" +%Y%m%d`

system_date=`/sbin/cksum /usr/bin/qsync | /bin/awk '{print $1}'`
qpkg_date=`/sbin/cksum $QPKG_ROOT/$Model_ver/$HAL_MODEL/qsync | /bin/awk '{print $1}'`
if [ "$system_date" != "$qpkg_date" ] ; then
    /bin/echo "Reserve current version."
else
    /bin/echo "Resume the previous version."
    /bin/rm -f /usr/bin/qsync
    /bin/rm -f /home/httpd/cgi-bin/backup/joblist.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/dashboard.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/backupRequest.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/extdriverequest.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/hdusb_stratct.cgi
    /bin/rm -f /home/httpd/cgi-bin/backup/qsyncrequest.cgi
    /bin/rm -f /usr/lib/libgeneral.so.0.0
    /bin/rm -f /usr/lib/libqsync.so.0.0
    #/bin/rm -f /home/httpd/cgi-bin/wizReq.cgi
    /bin/rm -f /etc/init.d/rsyncRR.sh
    /bin/rm -f /etc/init.d/rsyncSpeedTest.sh
    /bin/rm -f /usr/bin/rsync
    /bin/rm -f /home/httpd/cgi-bin/backup/download_hbrm_diagnose_report.sh
    /bin/rm -f /home/httpd/cgi-bin/qpkg/${QPKG_NAME}
   # /bin/cp -p -a $QPKG_ROOT/backup/wizReq.cgi /home/httpd/cgi-bin/wizReq.cgi
    /bin/cp -p -a $QPKG_ROOT/backup/rsyncRR.sh /etc/init.d/rsyncRR.sh
    /bin/cp -p -a $QPKG_ROOT/backup/rsyncSpeedTest.sh /etc/init.d/rsyncSpeedTest.sh
    /bin/cp -p -a $QPKG_ROOT/backup/rsync /usr/bin/rsync
    /bin/cp -p -a $QPKG_ROOT/backup/backupRequest.cgi /home/httpd/cgi-bin/backup/backupRequest.cgi
    /bin/cp -p -a $QPKG_ROOT/backup/extdriverequest.cgi /home/httpd/cgi-bin/backup/extdriverequest.cgi
    /bin/cp -p -a $QPKG_ROOT/backup/hdusb_stratct.cgi /home/httpd/cgi-bin/backup/hdusb_stratct.cgi
    /bin/cp -p -a $QPKG_ROOT/backup/qsyncrequest.cgi /home/httpd/cgi-bin/backup/qsyncrequest.cgi
    /bin/cp -p -a $QPKG_ROOT/backup/qsync /usr/bin/
    /bin/cp -p -a $QPKG_ROOT/backup/lib* /usr/lib/
fi
    /home/httpd/cgi-bin/backup/python_dir/bin/python $QPKG_ROOT/externalID.cgi shiftdown
    /bin/rm -f /home/httpd/cgi-bin/backup/python_dir
    
    # restart RTRR
    /bin/chmod 777 /usr/bin/qsync
   
    if [ $qsyncman_proc != 0 ]; then
      /etc/rcS.d/S99qsyncman start
    fi
 
#Backup Versioning script   
    /bin/rm -f $cgiPath

    if [ ! "$(/sbin/getcfg BackupVersion Install_Path -f ${CONF})" ]; then
      /bin/rm -f $old_cgiPath
    fi
    ;;

  restart)
    $0 stop
    $0 start
    ;;

  *)
    /bin/echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit 0
