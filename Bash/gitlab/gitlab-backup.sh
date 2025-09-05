#!/bin/bash
#
#GitLab Back Script
#
#Back up Directories
config_backup_dir="/home/gitlabadmin/gitlab-backups/config"
data_backup_dir="/var/opt/gitlab/backups"

if [ ! -d "$config_backup_dir" ]; then
        echo "directory doesn't exist, creating one"
        mkdir -p "$config_backup_dir"
fi

#Today's Date
today=$(date +%Y_%m_%d)

#NFS path
NFS="/mnt/NFS-iNT"

#Clean up file that are older than 30 days in NFS and files that are older than 5 days in local files
echo "$(/usr/sbin/hwclock) | finding and cleaning up backup files older than 30 days in $NFS/config"
if [ -n "$(ls -A "$NFS/config")" ]; then
	sleep 1
	find "$NFS/config" -type f -name "*.tar" -mtime +30 -exec rm -f {} \;
else
	echo "$(/usr/sbin/hwclock) | directory empty nothing to clean"
fi

echo "$(/usr/sbin/hwclock) | finding and cleaning up backup files older than 5 days in $config_backup_dir"
if [ -n "$(ls -A "$config_backup_dir")" ]; then
	sleep 1
	find "$config_backup_dir" -type f -name "*.tar" -mtime +5 -exec rm -f {} \;
else
	echo "$(/usr/sbin/hwclock) | directory empty nothing to clean"
fi	

echo "$(/usr/sbin/hwclock) | finding and cleaning up backup files older than 30 days in $NFS/data"
if [ -n "$(ls -A "$NFS/data")" ]; then
	sleep 1
	find "$NFS/data" -type f -name "*.tar" -mtime +30 -exec rm -f {} \;
else
	echo "$(/usr/sbin/hwclock) | directory empty nothing to clean"
fi

echo "$(/usr/sbin/hwclock) | finding and cleaning up backup files older than 5 days in $data_backup_dir"
if [ -n "$(ls -A "$data_backup_dir")" ]; then
	sleep 1
	find "$data_backup_dir" -type f -name "*.tar" -mtime +5 -exec rm -f {} \;
else
	echo "$(/usr/sbin/hwclock) | directory empty nothing to clean"
fi	

#Run Config Backup
gitlab-ctl backup-etc -p $config_backup_dir

config_backup_file=$(ls $config_backup_dir/*"$today"*.tar 2>/dev/null | head -n 1)

echo "$(/usr/sbin/hwclock) | configuration backup added at $config_backup_file"

sleep 2

#Run Data Backup

gitlab-backup create

data_backup_file=$(ls $data_backup_dir/*"$today"*.tar 2>/dev/null | head -n 1)

echo "$(/usr/sbin/hwclock) | data backup added at $data_backup_file"

#Copy the files to NFS

echo "$(/usr/sbin/hwclock) | copying backup files to NFS"

sleep 1

cp $config_backup_file $NFS/config

echo "$(/usr/sbin/hwclock) | config backup copied to NFS"

sleep 1

cp $data_backup_file $NFS/data

echo "$(/usr/sbin/hwclock) | data backup copied to NFS"
