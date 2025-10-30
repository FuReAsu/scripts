declare -a namespaces=($(kubectl get ns | awk '{print $1}')) 
for namespace in "${namespaces[@]}"; do 
	echo $namespace
	kubectl get jobs -n $namespace | grep -E "Error" | awk '{print $1}' | xargs kubectl delete jobs -n $namespace 
done
