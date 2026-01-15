#!/usr/bin/env bash

declare action="$1"
declare cluster="$2"

case $action in
	start)
		if (docker ps --filter "name=^$cluster-.*$" --format "{{.ID}}\t{{.Names}}\t{{.Image}}" | grep "kindest" > /dev/null); then
			echo "kind nodes are already started"
			exit 0
		else
			set -e; docker ps -a --filter "name=^$cluster-.*$" --format "{{.ID}}\t{{.Names}}\t{{.Image}}" | grep "kindest" | awk -F ' ' '{ print $1 }' | xargs docker start; set +e
		fi
		;;
	stop)
		if ! (docker ps --filter "name=^$cluster-.*$" --format "{{.ID}}\t{{.Names}}\t{{.Image}}" | grep "kindest" > /dev/null); then
			echo "kind nodes are already stopped"
			exit 0
		else
			set -e; docker ps --filter "name=^$cluster-.*$" --format "{{.ID}}\t{{.Names}}\t{{.Image}}" | grep "kindest" | awk -F ' ' '{ print $1 }' | xargs docker stop; set +e
		fi
		;;
	help)
		echo "kind-ctl [start|stop|show] {cluster_name}"
		exit 0
		;;
	info)
		docker ps -a --filter "name=^$cluster-.*$" | grep "kindest"
		;;
	stats)
		docker stats --no-stream | grep "^.*$cluster-.*$"
		;;
	*)
		echo "Invalid action"
		exit 1
		;;
esac
