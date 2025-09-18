#!/bin/bash

declare backup_server="backup.local"
declare backup_user="backup-admin"

declare dir

if ! [ "$#" -eq 0 ]; then
	dir="$1"
else
	echo "Please pass the directory you want to backup as the first argument"
	exit 1
fi

declare -l confirm

read -p "Confirm backup of $dir? [Y|n]: " confirm
confirm="${confirm:=y}"


if [ "$confirm" = "no" -o "$confirm" = "n" ]; then
	echo "Exiting..."
	exit 0
fi

if [ "$confirm" = "yes" -o "$confirm" = "y" ]; then
	echo "Continuing..."
fi

declare file_name="/tmp/$(date +%Y%m%d-%H%M)-$(basename $dir).tar.gz"

if ! [ -d "$dir" ]; then
	echo "No such directory $dir. Exiting..."
	exit 1
else
	echo "Compressing the directory into tar.gz"
	tar -czvf $file_name $dir
fi

if [ "$?" ]; then
	scp $file_name $backup_user@$backup_server:~/backup
else
	echo "compressing file failed. Exiting..."
	exit 1
fi
