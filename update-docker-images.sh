#!/usr/bin/sh

# Constants
black=`tput setaf 0`;
red=`tput setaf 1`;
green=`tput setaf 2`;
yellow=`tput setaf 3`;
blue=`tput setaf 4`;
magenta=`tput setaf 5`;
cyan=`tput setaf 6`;
white=`tput setaf 7`;
reset=`tput sgr0`;

clear

echo "${green}Stoping and removing all containers${reset}"
for container in $( docker ps -a -q ); do
    docker stop $container
    docker rm $container
done

echo "${green}Removing all LaravelLocal images${reset}"
#docker images | grep -v REPOSITORY | grep laravellocal | awk '{print $3}' | xargs -L1 docker rmi
for container in $(docker images "laravellocal_*" -q); do
    docker rmi $container
done

echo "${green}Removing all untagged images${reset}"
for container in $(docker images -aq -f dangling=true); do
    docker rmi $container
done

echo "${green}Updating all images${reset}"
#docker images | grep -v REPOSITORY | awk '{printf("%s:%s\n", $1, $2)}' | xargs -L1 docker pull
for image in $(docker images --format "{{.Repository}}:{{.Tag}}"); do
    echo "${green}Atualizando a imagem ${blue}$image${reset}"
    docker pull $image
done

