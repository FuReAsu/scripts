declare -a namespaces=($(kubectl get ns | awk '{print $1}')) 
for namespace in "${namespaces[@]}"; do 
	echo $namespace
	kubectl get pods -n $namespace | grep -E "Terminating|Err|ImagePullBackOff" | awk '{print $1}' | xargs kubectl delete pods -n $namespace --force 
done
