#!/bin/bash

declare -a contexts=($(kubectl config get-contexts -o name))


while true; do
	echo "Choose a context to use..."
	i=1
	for context in ${contexts[@]}; do
		echo "#$i -> $context"
		i=$(($i+1))
	done

	read -p "#? -> " option

	if [[ "$option" -gt 0 ]] && [[ "$option" =~ ^([0-9]{1,2})$ ]] && [[ "$option" -le ${#contexts[@]} ]]; then
		break
	else
		echo "invalid input"
	fi
	
done

option=$(($option-1))

context_to_use="${contexts[$option]}"

echo "Using kubectl context $context_to_use"

kubectl config use-context $context_to_use
