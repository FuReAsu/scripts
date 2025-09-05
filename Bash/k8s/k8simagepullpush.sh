#!/bin/bash
#pull images for k8s control plane and push to internal registry

k8s="registry.k8s.io"
ints="registry.intsmm.net/kubernetes"

echo "Pulling images from k8s"

for image in $(cat images.txt)
do
        echo "pulling $image"
        docker pull $k8s/$image
done

echo "Successfully pulled k8s images from k8s"

docker login registry.intsmm.net
echo "Tagging and pushing to ints"

for image in $(cat images.txt)
do
        echo "tagging and pushing $image"
        docker tag $k8s/$image $ints/$image
        docker push $ints/$image
done

echo "Successfully push k8s images to ints"