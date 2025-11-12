read -p "Please input the namespace: " namespace

if [ "$namespace" = "all" ]; then
	read -p "Selecting all namspaces please confirm by pressing any key " continue
	declare -a namespaces=($(kubectl get ns --no-headers | awk '{print $1}')) 
else
	declare -a namespaces=($namespace)
fi

for namespace in "${namespaces[@]}"; do 
	echo $namespace
	declare -a pods=($(kubectl get pods -n $namespace --no-headers | grep -E "Terminating|Err|ImagePullBackOff" | awk '{print $1}'))
	if [ "${#pods[@]}" -eq 0 ]; then
		echo "No faulty pods can be found..."
	else
		for pod in "${pods[@]}"; do
			kubectl delete pod -n $namespace $pod
		done
	fi
done
