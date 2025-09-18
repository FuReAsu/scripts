#!/bin/bash

declare backup_server="backup.local"
declare backup_user="backup-admin"
declare now="[$(date +%D-%H:%m:%N)] --"
declare dir

if ! [ "$#" -eq 0 ]; then
	dir="$1"
else
	echo "Please pass the directory you want to backup as the first argument"
	exit 1
fi

declare file_name="/tmp/$(date +%Y%m%d%H%M)-$(basename $dir).tar.gz"

if ! [ -d "$dir" ]; then
	echo "$now No such directory $dir. Exiting..."
	exit 1
else
	echo "$now Compressing the directory into tar.gz"
	tar -czvf $file_name $dir > /dev/null 2>&1
fi

if [ "$?" ]; then
	echo "$now Compressed $dir to $file_name"
	echo "$now Copying $file_name to $backup_server using scp"
	scp $file_name $backup_user@$backup_server:~/backup > /dev/null 2>&1
else
	echo "$now Compressing file failed. Exiting..."
	exit 1
fi

if [ "$?" ]; then
	echo "$now Copied $file_name to $backup_server"
	echo "$now Backup process successfully completed"
else
	echo "$now Copying $file_name to $backup_server failed"
	exit 1
fi
