#!/usr/bin/env bash
#post-startup kubernetes cluster setup

declare help_message="------------------------------------------------------------
⚓ post-startup kubernetes setup script ⚓
Please provide --profile flag with the following values
🚀 full (calico, metrics-server, metallb, istio, longhorn)
🚀 kind (metrics-server, metallb, istio)"

log() {
	case "$1" in
		success)
			echo "✔️ $2"
			;;
		failure)
			echo "❌ $2"
			;;
		process)
			echo "🚀 $2"
			;;
	esac
}

check_tools() {
	local -a tools=( "kubectl" "helm" "istioctl")
	log process "Checking for tools in \$PATH"
	for tool in "${tools[@]}"; do
		if which "$tool" > /dev/null; then
			log success "$tool exists in \$PATH"
		else
			log failure "$tool doesn't exist in \$PATH"
			exit 1
		fi
	done
}

check_context() {
	log process "Checking for context"
	if kubectl config get-contexts | grep "*" > /dev/null; then
		log success "Kubectl context found. Using $(kubectl config get-contexts | grep '*' | awk -F ' ' '{ print $2 }')"
	else
		log failure "No kubectl context found. Please select a context"
		exit 1
	fi
}

check_args() {
	case "$1" in
		--help)
			echo "$help_message"
			exit 0
			;;
		--profile)
			if ! [ -z ${2+true} ]; then
				log success "Profile value exists. Using profile [$2]"
			else
				log failure "Please set a value for --profile flag"
				exit 1
			fi
			;;
		*)
			echo "$help_message"
			exit 0
			;;
	esac
}

install_calico() {
	log process "Getting latest calico manifest"
	curl -fsS https://raw.githubusercontent.com/projectcalico/calico/refs/heads/master/manifests/calico.yaml --output /tmp/calico.yml
	if [ "$?" -eq 0 ]; then
		log process "Installing calico"
		kubectl apply -f /tmp/calico.yml
		sleep 5
	else
		log failure "Getting calico manifest failed. Try again"
		exit 1
	fi

	log process "Waiting for calico controller to be ready"
	i=5
	while [ "$i" -gt 0 ]; do 
		if ! (kubectl get apiservices.apiregistration.k8s.io | grep calico | grep True > /dev/null ); then
			log process "Still waiting, $i times left"
			sleep 20
			i=$((i-1))
		else
			log success "Calico controller is ready"
			return 0
		fi
	done
	log failure "Calico controller is not ready, setup is on hold"
	exit 1
}

profile_full() {
	install_calico	
}

profile_kind() {
	echo "kind"
}

main() {
	check_args "$@"
	check_tools
	check_context
	case "$2" in
		full)
			profile_full
			;;
		kind)
			profile_kind
			;;
		*)
			log failure "Invalid profile"
			exit 1
			;;
		esac
}

main "$@"
