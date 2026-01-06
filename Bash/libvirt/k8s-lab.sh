#!/bin/bash

declare -a k8s_nodes=( "k8s-m1" "k8s-w1" "k8s-w2" )

if [ "$#" -eq 0 ]; then
	echo "
Usage:
k8s-lab [start|stop|restart|info]"
	exit 0
fi

run_virsh(){
	local -n domains="$1"
	local cmd="$2"
	for domain in "${domains[@]}"; do
		virsh $cmd $domain
	done
}

case $1 in
	"start")
		run_virsh "k8s_nodes" start
		;;
	"stop")
		run_virsh "k8s_nodes" shutdown
		;;
	"info")
		run_virsh "k8s_nodes" dominfo
		;;
	"restart")
		run_virsh "k8s_nodes" reset
		;;
	*)
		echo "unknown option"
		exit 1
		;;
esac
