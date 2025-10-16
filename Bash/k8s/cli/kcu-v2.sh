#!/bin/bash

CONFIG_DIR="$HOME/.kube/config.d"

if ! [ -d "$CONFIG_DIR" ]; then
	echo "Config directory $CONFIG_DIR not found. Please create it first..."
	exit 1
fi

declare -a contexts=($(ls $CONFIG_DIR | sed 's/.yaml//'))

if ! [ "$#" -eq 0 ] && [[ "$option" =~ ^([0-9]{1,2})$ ]] && [[ "$1" -gt 0 ]] && [[ "$1" -le ${#contexts[@]} ]]; then
	option="$1"
else
	echo "No args given or invalid arg. Going into interactive mode..."
	while true; do
		echo "Choose a context to use..."
		i=1
		for context in ${contexts[@]}; do
			echo "#$i -> $context"
			i=$(($i+1))
		done

		read -p "#? -> " option

		if [[ "$option" =~ ^([0-9]{1,2})$ ]] && [[ "$option" -le ${#contexts[@]} ]]; then
			break
		else
			echo "invalid input"
		fi
		
	done
fi

option=$(($option-1))
context_to_use="${contexts[$option]}"

echo "Using config file $CONFIG_DIR/$context_to_use.yaml"

export KUBECONFIG="${CONFIG_DIR}/${context_to_use}.yaml"

sed -i '/^#kubectl context config file/d' $HOME/.bashrc
sed -i '/^.*KUBECONFIG.*/d' $HOME/.bashrc

echo "#kubectl context config file
export KUBECONFIG=${CONFIG_DIR}/${context_to_use}.yaml" >> $HOME/.bashrc
