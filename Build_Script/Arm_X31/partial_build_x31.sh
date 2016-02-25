#!/bin/bash
# qsync partial build


function Rm_Process_Tree(){
    #reference:
	#http://stackoverflow.com/questions/392022/best-way-to-kill-all-child-processes/15139734#15139734	
	kill -- -$(ps -o pgid= $pid_of_top | grep -o [0-9]*)	
	
	#
	#PGID=$(ps -o pgid= $pid_of_top | grep -o [0-9]*)
	#kill -TERM -"$PGID"  # kill -15
	#kill -INT  -"$PGID"  # correspond to [CRTL+C] from keyboard
	#kill -QUIT -"$PGID"  # correspond to [CRTL+\] from keyboard
	#kill -CONT -"$PGID"  # restart a stopped process (above signals do not kill it)
	#sleep 2              # wait terminate process (more time if required)
	#kill -KILL -"$PGID"  # kill -9 if it does not intercept signals (or buggy)
	
}

function Check_File(){
	checkFile=$1
	if [[ -f "$checkFile" ]]; then
		echo "===========Build {$checkFile} succeeded !! " 	
    else
     	echo "===========Build {$checkFile} failed 0rz" 							
		Rm_Process_Tree;
		exit 1
	fi	
}

function Update_From_GIT(){
	cd $git_src
	echo "===========Start git pull ...===========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1
	git pull $git_pull_ori $git_pull_branch >> $log_path$log_name 2>&1
	
	#error handling for git pull
	return=$?
	if [[ $return != 0 ]]; then
		echo "===========git pull failed  ===========" >> $log_path$log_name 2>&1
		exit $return;
	fi
	#erro handling
	
	echo "===========END git pull ...  ===========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1	
}

function Build_RTRR_LIB(){
	
	#====================== make General library ======================	
	cd $git_src$rtrr_library_path
	echo "===========Start make rtrrlibrary ...=======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

	make clean 1>/dev/null 2>/dev/null
	make RECYCLE_EX=yes QNAP_HAL_SUPPORT=yes STORAGE_V2=yes >> $log_path$log_name 2>&1
			
	Check_File libgeneral.so.0.0
		
	echo "===========END make rtrr library ... ========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

	#====================== make libqsync ======================	
	cd $git_src$rtrr_libqsync_path
	echo "===========Start make libqsync ...======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

	make clean 1>/dev/null 2>/dev/null
	make RECYCLE_EX=yes QNAP_HAL_SUPPORT=yes STORAGE_V2=yes ENABLE_LIMITRATE=yes >> $log_path$log_name 2>&1
	
	Check_File libqsync.so.0.0

	echo "===========END make libqsync ... =======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

}

function Build_RTRR_BIN(){
	cd $git_src$qsync_path
	echo "===========Start make qsync ... ========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

	make clean 1>/dev/null 2>/dev/null	
	make RECYCLE_EX=yes QNAP_HAL_SUPPORT=yes STORAGE_V2=yes ENABLE_LIMITRATE=yes LDAP=yes TARGET_PREFIX=${git_src_model}build/RootFS >> $log_path$log_name 2>&1
	#make clean;make clean;make RECYCLE_EX=yes QNAP_HAL_SUPPORT=yes STORAGE_V2=yes ENABLE_LIMITRATE=yes LDAP=yes  >> $log_path$log_name 2>&1
	
	Check_File qsync
		
	echo "===========END make qsync ... ==========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1
}

function Build_CGI(){
	
	#delete old cgi first.
	cd $git_src$cgi_source_path1
	echo $(pwd)
	rm *.cgi

	cd $git_src$cgi_build_path1
	cd $BASEDIR
	echo "===========Start make cgi ... ==========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1
	
	./$Http_builder $git_src $cgi_build_path1 $log_path
	
	pid_of_top="$!"
	build_start_time=$(date +%s)
	while [[ ! -f "$git_src$buildFile" ]];do
	  sleep 1
	  elapsedtime=$(($(date +%s)-$build_start_time))	  
	  if [[ $elapsedtime -ge 50 ]]; then
			break
	  fi		  	  
	done	
	#kill -9 $pid_of_top     #1>/dev/null 2>/dev/null
	#Rm_Process_Tree;
	
	cd $git_src$cgi_source_path1
	Check_File qsyncrequest.cgi
	Check_File extdriverequest.cgi
		
	echo "CGI Log path is ${log_path}Cgi_build_time.log" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

	echo "===========END make cgi ... ============" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

}

function Build_Rsync_LIB(){
	
	#====================== make General library ======================	
	cd $git_src$rsync_library_path
	echo "===========Start make rsync library ...=======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1
	
	echo "===========Start make cfg_rsync.o ...=======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1
	gcc -I$git_src_model../../Kernel/linux-3.12.6/include/generated/uapi -I../uLinux -I../include -I../common -I../libnaslog-2.0.0 -I ../../DataService/DBMS/sqlite/sqlite-3.4.1 -I../../DataService/DBMS/sqlite/sqlite-3.4.1/src -I$git_src_model../../Kernel/linux-3.12.6/include/qnap -I/opt/cross-project/x86/sys-root/usr/include -I../../Include -I../ini_config -I../hal -I../storage_man_v2 -U_FORTIFY_SOURCE -fPIC -Wall -c -O -DSYNC_BY_NFS -DX86_SANDYBRIDGE  -DTS470 -DTS470 -DMKE2FS_64BIT -DKERNEL_IS_64BIT -DENCRYPTFS -DNAS_VIRTUAL -DNAS_VIRTUAL_EX -DAPACHE_WEBDAV -DAPACHE_SSL -DUIV2 -DTS470 -DM_DEFAULT_SHARE -DIPV6 -DTIMEMACHINE -DPARAGON_NTFS -DNFS_HACCESS -DNFSV4 -DHFSPLUS -DLIO_TARGET -DACL -DDISK_REORDER -DLDAP -DMS_DFS -DEXT_ENCRYPTION -DQNAP_HAL_SUPPORT -DSTORAGE_V2 -DSUPPORT_SINGLE_INIT_LOGIN -DMUSICSTATION -DPHOTOSTATION2 -DPUBLIC_PHOTOSTATION -DRECYCLE_EX -DQOS4 -DQBOX_SUPPORT -DHDSTATION -DLIBRSYNC -DQTS_SAMBA4 -DUSER_GROUP_DB -DQTS_HA -DPRODUCTION -DSYSLOG_SERVER -DRADIUS -DQNAPDDNS -DVLAN -DNIC_4LAN_SUPPORT -DWIRELESS -DCUPS -DCLAMAV -I../../NasLib/replication/library -DSUPPORT_LIMITRATE -DVPN_OPENVPN -DVPN_PPTP -DLDAP_SERVER -DQTS_SNAPSHOT -DQTS_SNAPSYNC -DPUSH_NOTIFICATION -DNSS_V2 -I../../Include -DNSS_V2 -I../qlicense2 cfg_rsync.c -o cfg_rsync.o >> $log_path$log_name 2>&1
	
	Check_File cfg_rsync.o
	
	echo "===========Start make cfg_backup.o  ...=======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1	
	gcc -I$git_src_model../../Kernel/linux-3.12.6/include/generated/uapi -I../uLinux -I../include -I../common -I../libnaslog-2.0.0 -I../../DataService/DBMS/sqlite/sqlite-3.4.1 -I../../DataService/DBMS/sqlite/sqlite-3.4.1/src -I$git_src_model../../Kernel/linux-3.12.6/include/qnap -I/opt/cross-project/x86/sys-root/usr/include -I../../Include -I../ini_config -I../hal -I../storage_man_v2 -U_FORTIFY_SOURCE -fPIC -Wall -c -O -DSYNC_BY_NFS -DX86_SANDYBRIDGE -DTS470 -DTS470 -DMKE2FS_64BIT -DKERNEL_IS_64BIT -DENCRYPTFS -DNAS_VIRTUAL -DNAS_VIRTUAL_EX -DAPACHE_WEBDAV -DAPACHE_SSL -DUIV2 -DTS470 -DM_DEFAULT_SHARE -DIPV6 -DTIMEMACHINE -DPARAGON_NTFS -DNFS_HACCESS -DNFSV4 -DHFSPLUS -DLIO_TARGET -DACL -DDISK_REORDER -DLDAP -DMS_DFS -DEXT_ENCRYPTION -DQNAP_HAL_SUPPORT -DSTORAGE_V2 -DSUPPORT_SINGLE_INIT_LOGIN -DMUSICSTATION -DPHOTOSTATION2 -DPUBLIC_PHOTOSTATION -DRECYCLE_EX -DQOS4 -DQBOX_SUPPORT -DHDSTATION -DLIBRSYNC -DQTS_SAMBA4 -DUSER_GROUP_DB -DQTS_HA -DSYSLOG_SERVER -DRADIUS -DQNAPDDNS -DVLAN -DNIC_4LAN_SUPPORT -DWIRELESS -DCUPS -DCLAMAV -I../../NasLib/replication/library -DSUPPORT_LIMITRATE -DVPN_OPENVPN -DVPN_PPTP -DLDAP_SERVER -DQTS_SNAPSHOT -DQTS_SNAPSYNC -DPUSH_NOTIFICATION -DNSS_V2 -I../../Include -DNSS_V2 -I../qlicense2 cfg_backup.c -o cfg_backup.o >> $log_path$log_name 2>&1
	
	Check_File cfg_backup.o
	
	echo "===========Start make libuLinux_config.so.0.0  ...=======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1	
	gcc -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE  -DTS470 -DTS470 -DMKE2FS_64BIT -DKERNEL_IS_64BIT -DENCRYPTFS -DNAS_VIRTUAL -DNAS_VIRTUAL_EX -DAPACHE_WEBDAV -DAPACHE_SSL -DUIV2 -DTS470 -DM_DEFAULT_SHARE -DIPV6 -DTIMEMACHINE -DPARAGON_NTFS -DNFS_HACCESS -DNFSV4 -DHFSPLUS -DLIO_TARGET -DACL -DDISK_REORDER -DLDAP -DMS_DFS -DEXT_ENCRYPTION -DQNAP_HAL_SUPPORT -DSTORAGE_V2 -DSUPPORT_SINGLE_INIT_LOGIN -DMUSICSTATION -DPHOTOSTATION2 -DPUBLIC_PHOTOSTATION -DRECYCLE_EX -DQOS4 -DQBOX_SUPPORT -DHDSTATION -DLIBRSYNC -DQTS_SAMBA4 -DUSER_GROUP_DB -DQTS_HA -DPRODUCTION -DSYSLOG_SERVER -DRADIUS -DQNAPDDNS -DVLAN -DNIC_4LAN_SUPPORT -DWIRELESS -DCUPS -DCLAMAV -I../../NasLib/replication/library -DSUPPORT_LIMITRATE -DVPN_OPENVPN -DVPN_PPTP -DLDAP_SERVER -DQTS_SNAPSHOT -DQTS_SNAPSYNC -DPUSH_NOTIFICATION -shared -Wl,-soname,libuLinux_config.so.0 -o libuLinux_config.so.0.0 ../common/nas_lib_common.o cfg_system.o cfg_alert.o cfg_network.o cfg_samba.o cfg_appletalk.o cfg_nfs.o cfg_webfs.o cfg_smtp.o gw.o ifcfg.o sem.o cfg_display.o cfg_misc.o msg.o hardware.o cfg_ftp.o cfg_snmp.o cfg_nic.o cfg_printer.o cfg_logo.o mangle.o cfg_system_recover.o cfg_save_restore.o cfg_ntp.o cfg_rtrr.o cfg_rsync.o cfg_qphoto.o cfg_qmultimedia.o cfg_qdownload.o cfg_qweb.o cfg_qwebdav.o base64.o eventlog_mgr.o cfg_backup.o cfg_ddns.o cfg_dhcp.o cfg_tftp.o cfg_fw.o cfg_recycle_bin.o cfg_mysql.o cfg_ip_filter.o cfg_ups.o cfg_login.o cfg_usb_button.o cfg_hdcopyusb.o pl_parser.o cfg_buzzer.o cfg_sms.o cfg_qsurveillance.o cfg_bonjour.o cfg_redundant_power.o cfg_upnp.o cfg_ldap.o cfg_applog.o cfg_medialibrary.o cfg_versioning.o cfg_qbox.o cfg_qpkg.o cfg_tbtnet.o tbt_trace.o cfg_iscsi.o cfg_iscsi_lio.o ../ini_config/err_trace.o ../ini_config/ini_config.o ../ini_config/minIni.o cfg_amazons3.o cfg_qfan.o cfg_br.o cfg_timemachine.o cfg_syslog.o cfg_radius.o cfg_upnpc.o cfg_qnapddns.o cfg_antivirus.o custom_lib.o cfg_vpn.o cfg_ldap_server.o cfg_snapshot.o cfg_itms.o -lc -lcrypt >> $log_path$log_name 2>&1
	
	Check_File libuLinux_config.so.0.0
	
	echo "===========Start make libuLinux_config_ext.so.0.0  ...=======" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1	
	gcc -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE  -DTS470 -DTS470 -DMKE2FS_64BIT -DKERNEL_IS_64BIT -DENCRYPTFS -DNAS_VIRTUAL -DNAS_VIRTUAL_EX -DAPACHE_WEBDAV -DAPACHE_SSL -DUIV2 -DTS470 -DM_DEFAULT_SHARE -DIPV6 -DTIMEMACHINE -DPARAGON_NTFS -DNFS_HACCESS -DNFSV4 -DHFSPLUS -DLIO_TARGET -DACL -DDISK_REORDER -DLDAP -DMS_DFS -DEXT_ENCRYPTION -DQNAP_HAL_SUPPORT -DSTORAGE_V2 -DSUPPORT_SINGLE_INIT_LOGIN -DMUSICSTATION -DPHOTOSTATION2 -DPUBLIC_PHOTOSTATION -DRECYCLE_EX -DQOS4 -DQBOX_SUPPORT -DHDSTATION -DLIBRSYNC -DQTS_SAMBA4 -DUSER_GROUP_DB -DQTS_HA -DPRODUCTION -DSYSLOG_SERVER -DRADIUS -DQNAPDDNS -DVLAN -DNIC_4LAN_SUPPORT -DWIRELESS -DCUPS -DCLAMAV -I../../NasLib/replication/library -DSUPPORT_LIMITRATE -DVPN_OPENVPN -DVPN_PPTP -DLDAP_SERVER -DQTS_SNAPSHOT -DQTS_SNAPSYNC -DPUSH_NOTIFICATION -shared -Wl,-soname,libuLinux_config_ext.so.0 -o libuLinux_config_ext.so.0.0 cfg_remote_folder.o -lc -lcrypt -L../../SysLib/json-c-0.9/.libs -ljson -L /root/WorkSpace/4.2.0_Latest/NasX86/NasLib/config/../.build/usr/lib -L/opt/cross-project/x86/sys-root/lib -L/opt/cross-project/x86/sys-root/usr/lib -L../ini_config -luLinux_Util -luLinux_NAS -luLinux_Storage -luLinux_quota -luLinux_PDC -luLinux_cgi -lpthread -luLinux_ini -lm -lssl -lcrypt -lcrypto -L../hal -luLinux_hal >> $log_path$log_name 2>&1
	
	Check_File libuLinux_config_ext.so.0.0
				
	echo "===========END make cfg_backup.o  ... ========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1



}

function Build_Rsync_BIN(){
	cd $git_src$rsync_path
	echo "===========Start make rsync ... ========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1

	make clean 1>/dev/null 2>/dev/null	
	make >> $log_path$log_name 2>&1
	
	Check_File rsync
		
	echo "===========END make rsync ... ==========" >> $log_path$log_name 2>&1
	echo " " >> $log_path$log_name 2>&1
}

function Update_RTRR_TO_NAS(){

	#update libgeneral	
	cd $git_src$rtrr_library_path
	scp libgeneral.so.0.0 admin@$Dest_Server:/usr/lib
	
	#update libqsync
	cd $git_src$rtrr_libqsync_path
	scp libqsync.so.0.0 admin@$Dest_Server:/usr/lib

	#update RTRR bin
	cd $git_src$qsync_path
	scp qsync admin@$Dest_Server:/usr/bin

	#update RTRR cgi	
	cd $git_src$rtrr_cgi_source_path
	file_list=("qsyncrequest.cgi" "extdriverequest.cgi" "download_hbrm_diagnose_report.sh")	
	for filename in "${file_list[@]}"
	do
		scp $filename admin@$Dest_Server:/home/httpd/cgi-bin/backup/
	done
}

function Update_Rsync_TO_NAS(){

	#update Rsync library
	#need to sh /etc/init.d/thttpd.sh start on remote NAS
	#cd $git_src$rsync_library_path
	#file_list=("libuLinux_config.so.0.0" "libuLinux_config_ext.so.0.0")
	file_list=("libuLinux_config.so.0.0")
	for filename in "${file_list[@]}"
	do
		scp $filename admin@$Dest_Server:/usr/lib
	done
					
	#update Rsync bin
	cd $git_src$rsync_path
	file_list=("rsync")
	for filename in "${file_list[@]}"
	do
		scp $filename admin@$Dest_Server:/usr/bin
	done	
		
	#update Rsync cgi-1
	cd $git_src$rsync_cgi_source_path1
	file_list=( "backupRequest.cgi")
	for filename in "${file_list[@]}"
	do
		scp $filename admin@$Dest_Server:/home/httpd/cgi-bin/backup/
	done		
	
	#update Rsync cgi-2
	cd $git_src$rsync_cgi_source_path2
	file_list=( "wizReq.cgi")
	for filename in "${file_list[@]}"
	do
		scp $filename admin@$Dest_Server:/home/httpd/cgi-bin/
	done	
	
	#update Rsync script1
	cd $git_src$rsync_script_path1
	file_list=("rsyncRR.sh")	
	for filename in "${file_list[@]}"
	do
		scp $filename admin@$Dest_Server:/etc/init.d
	done
	
	#update Rsync script2
	cd $git_src$rsync_script_path2
	file_list=("rsyncSpeedTest.sh")	
	for filename in "${file_list[@]}"
	do
		scp $filename admin@$Dest_Server:/etc/init.d
	done
}

function Set_Environment(){

	#===============================Common setting===============================

export PATH=/opt/cross-project/arm/mindspeed/toolchain-arm_v7-a_gcc-4.5-linaro_glibc-2.14.1_eabi/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}

# include functions
/etc/autobuild/cksum_check.sh

export CROSS_COMPILE=arm-openwrt-linux-
export ARCH=arm
export SYS_TARGET_PREFIX=/opt/cross-project/arm/mindspeed/target-arm_v7-a_glibc-2.14.1_eabi
export TARGET_PREFIX=/opt/cross-project/arm/mindspeed/target-arm_v7-a_glibc-2.14.1_eabi

	#1. model name
	model_name="TS-X31"
	
	#2. working tree and model 
	#4.2.0
	
	QTS4_2_0=/mnt/vdisk/git_4.2.0/
	Main_Trunk=/root/WorkSpace/4.2.0/NasX86/
	
	git_src=$QTS4_2_0
	git_src_model=/mnt/vdisk/git_4.2.0/Model/$model_name/
	
	#3. destinaion NAS
	Server_470A=172.17.28.75
	Server_470B=172.17.28.66
	Server_670A=172.17.28.218
	Dest_Server=$Server_470B
	
	#4. log path
	log_path=/mnt/vdisk/log/
		
	#5. script use to build cgi
	Http_builder=make_http.sh
	
	#6. cgi build path
	cgi_build_path1=Model/$model_name/
	
	#7. cgi source file path
	cgi_source_path1=NasMgmt/HTTP/WebPage/UI_2.1/Backup/
	
	#8.git path
	git_pull_ori=backupteamMaster
	git_pull_branch=DevBranch-master

	NOW=$(date +%Y%m%d%H%M)
	log_name=Partial_build_$NOW.log
	
	buildFile=NasMgmt/HTTP/WebPage/UI_2.1/Backup/qsyncrequest.cgi
	BASEDIR=`pwd`	
		
export ROOT_PATH=${git_src_model}build/RootFS

	#===============================RTRR related setting===========================
	
	#1.library
	rtrr_library_path=NasLib/replication/library/	
	rtrr_libqsync_path=NasLib/replication/libqsync/
	
	#2.bin
	qsync_path=NasUtil/replication/qsync/
		
	#3.cgi and script
	rtrr_cgi_source_path=NasMgmt/HTTP/WebPage/UI_2.1/Backup/	
	
	#===============================Rsync related setting===============================
			
	#l.ibrary
	rsync_library_path=NasLib/config/
	
	#2.bin
	rsync_path=SysUtil/rsync-3.0.7/
		
	#3.cgi and script
	rsync_cgi_source_path1=NasMgmt/HTTP/WebPage/UI_2.1/Backup/
	rsync_cgi_source_path2=NasMgmt/HTTP/WebPage/UI_2.1/Home/
	rsync_script_path1=NasMgmt/HTTP/WebPage/misc/
	rsync_script_path2=RootFS/init.d_509/
	
}


Set_Environment;
#Update_From_GIT;


build_mode=$1   # rtrr/rsync


case ${build_mode} in
	"rtrr")  #RTRR
	Build_RTRR_LIB;          #build rtrr library
	Build_RTRR_BIN;          #build rtrr binary     
	#Build_CGI;	             #build cgi
	#Update_RTRR_TO_NAS;     #scp rtrr file to remote NAS, neet to set RSA key if you don't want to keyin password
	;;
	"rsync") #Rsync
	Build_Rsync_LIB;         #build rsync library
	Build_Rsync_BIN;         #build rsync binary
	Build_CGI;               #build cgi
	#Update_Rsync_TO_NAS;    ##scp rsync file to remote NAS, neet to set RSA key if you don't want to keyin password
	;;
	*)
	echo "Usage 1/2 build RTRR/build Rsync)"
	;;
esac

#kill process tree
Rm_Process_Tree;




	
 











