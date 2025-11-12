read -p "Please input the namespace: " namespace

if [ "$namespace" = "all" ]; then
	read -p "Selecting all namspaces please confirm by pressing any key " continue
	declare -a namespaces=($(kubectl get ns --no-headers | awk '{print $1}')) 
else
	declare -a namespaces=($namespace)
fi

for namespace in "${namespaces[@]}"; do 
	echo $namespace
	declare -a jobs=($(kubectl get jobs -n $namespace --no-headers | grep -E "Error|Pending|Running" | awk '{print $1}'))
	if [ "${#jobs[@]}" -eq 0 ]; then
		echo "No faulty jobs can be found..."
	else
		for job in "${jobs[@]}"; do
			kubectl delete job -n $namespace $job
		done
	fi
done
