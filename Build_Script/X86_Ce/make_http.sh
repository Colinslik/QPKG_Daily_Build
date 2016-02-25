git_src=/mnt/vdisk/git_4.2.0/

cgi_path=Model/TS-269H/

log_path=/mnt/vdisk/log/

NOW=$(date +%Y%m%d%H%M)

log_name=Cgi_build_$NOW.log

cd $git_src$cgi_path
make HTTP >> $log_path$log_name 2>&1 &
