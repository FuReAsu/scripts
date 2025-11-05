#!/bin/bash

echo "Please run export BOT_ACCESS_TOKEN=<your-token-first>"
read -p "Project ID: " prj

while true; do
	read -p "dependency name: " dep
	read -p "dependency version: " ver
	read -p "dependency path: " path

	curl --header "PRIVATE-TOKEN: ${BOT_ACCESS_TOKEN}" --location "https://gitlab.com/api/v4/projects/$prj/packages/maven/$path/$dep/$ver/$dep-$ver.pom" --upload-file $dep-$ver.pom
	curl --header "PRIVATE-TOKEN: ${BOT_ACCESS_TOKEN}" --location "https://gitlab.com/api/v4/projects/$prj/packages/maven/$path/$dep/$ver/$dep-$ver.jar" --upload-file $dep-$ver.jar
	echo ""
done
