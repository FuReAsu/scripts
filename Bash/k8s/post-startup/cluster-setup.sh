#!/usr/bin/env bash
#post-startup kubernetes cluster setup

CALICO_VERSION="${CALICO_VERSION:-v3.31}"

declare WHITE="\033[0m" #white
declare RED="\033[1;31m" #red
declare GREEN="\033[1;32m" #green
declare YELLOW="\033[1;33m" #yellow

declare temp_path="/tmp"
declare help_message="------------------------------------------------------------
⚓ post-startup kubernetes setup script ⚓
Please provide --profile flag with the following values
🚀 full (calico, metrics-server, metallb, istio, longhorn)
🚀 minimal (metrics-server, metallb, istio)"

declare available_options=("full" "minimal")

log() {
	case "$1" in
		success)
			echo -e "$GREEN✔️ $2$WHITE"
			;;
		failure)
			echo -e "$RED❌ $2$WHITE"
			;;
		progress)
			echo -e "$YELLOW🚀 $2$WHITE"
			;;
	esac
}

check_tools() {
	local -a tools=( "kubectl" "helm" "istioctl")
	log progress "Checking for tools in \$PATH"
	for tool in "${tools[@]}"; do
		if which "$tool" > /dev/null; then
			log success "$tool exists in \$PATH"
			return 0
		else
			log failure "$tool doesn't exist in \$PATH"
			exit 1
		fi
	done
}

check_context() {
	log progress "Checking for context"
	if kubectl config get-contexts | grep "*" > /dev/null; then
		log success "Kubectl context found. Using $(kubectl config get-contexts | grep '*' | awk -F ' ' '{ print $2 }')"
		return 0
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
				found=0
				for option in "${available_options[@]}"; do
					[ "$2" = "$option" ] && found=1 && break
				done
				[ $found -eq 0 ] && log failure "Invalid option $2" && exit 1
				log success "Profile value exists. Using profile [$2]" && return 0
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

label_nodes() {
	log progress "Labeling worker nodes if not already done"
	local -a nodes=($(kubectl get nodes --no-headers -o custom-columns="Name:.metadata.name"))
	for node in "${nodes[@]}"; do
		grep "control-plane" -v <<< "$node" > /dev/null && kubectl label nodes $node node-role.kubernetes.io/worker=
	done
}

install_calico() {

	if (kubectl -n kube-system  rollout status deployments calico-kube-controllers > /dev/null); then
		log success "Calico already exists"
		return 0
	fi

	log progress "Getting latest calico manifest to $temp_path/calico.yml"
	curl -fsS https://raw.githubusercontent.com/projectcalico/calico/refs/heads/release-${CALICO_VERSION}/manifests/calico.yaml --output $temp_path/calico.yml
	if [ "$?" -eq 0 ]; then
		log progress "Installing calico"
		kubectl apply -f /tmp/calico.yml
		sleep 5
	else
		log failure "Getting calico manifest failed. Try again"
		exit 1
	fi

	log progress "Checking calico controller status"
	if ! (kubectl -n kube-system  rollout status deployments calico-kube-controllers ); then
		log failure "Calico controller is still not ready"
		exit 1
	else
		log success "Calico controller is ready"
		return 0
	fi

	log failure "Calico controller is not ready, setup is on hold"
	exit 1
}

setup_networks() {
	if (kubectl get ippool --no-headers -o custom-columns=":.metadata.name" | grep -v "default"); then
		log success "Ippools already created"
		return 0
	fi
	log progress "Generating ippool config to $temp_path/calico_ippools.yaml"
	local -a nodes=($(kubectl get nodes --no-headers -o custom-columns="Name:.metadata.name"))
	for node in "${nodes[@]}"; do
		if (kubectl get ippool --no-headers -o custom-columns=":.metadata.name" | grep "$node"); then
			log success "Ippool for $node is already set"
			continue
		fi
		current_cidr=$(kubectl get nodes $node --no-headers -o custom-columns=':.spec.podCIDRs[0]')
		cat <<EOF >> $temp_path/calico_ippools.yaml
apiVersion: crd.projectcalico.org/v1
kind: IPPool
metadata:
  name: $node-ippool
spec:
  allowedUses:
  - Workload
  - Tunnel
  cidr: ${current_cidr}
  blockSize: 24
  ipipMode: Always
  natOutgoing: true
  nodeSelector: 'kubernetes.io/hostname == "$node"'
  vxlanMode: Never
---
EOF
	done
	log progress "Applying ippools"
	kubectl apply -f $temp_path/calico_ippools.yaml
	if [ "$?" -eq 0 ]; then
		log success "Ippools created"
		log progress "Deleting default ipv4 pool"
		kubectl delete ippool default-ipv4-ippool
		return 0
	else
		log failure "Ippool creation failed"
	fi
}

profile_full() {
	install_calico
	setup_networks
}

profile_minimal() {
	echo "minimal"
}

main() {
	check_args "$@"
	local option="$2"
	check_tools
	check_context
	label_nodes
	case "$option" in
		full)
			profile_full
			;;
		kind)
			profile_minimal
			;;
		esac
}

main "$@"
