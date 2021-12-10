#!/bin/bash
# This script is to update docker containers automatically

# Static Variables

# Update apps_home with location of your docker "installs"
apps_home="LOCATION_TO_DOCKER_APPS"
container_count=$(docker container ls -a | wc -l)
apps_count=$(ls ${apps_home} | wc -l) 
docker_countainer_count=$(docker container ls -a | grep -vi 'CONTAINER ID' | wc -l)
docker_images_count=$(docker images  | awk '{print $2, $3}' | grep -iv "TAG" | awk '{print $2}' | wc -l)

# Update Docker images function:
#function update_images() {
#    i=1
#    while [ $i -le ${container_count} ]
#    do
#        docker pull $(docker container ls -a | grep -vi 'CONTAINER ID' | awk '{print $2}' | head -$i | tail +$i) 
#        ((i++))
#    done
#}

# Stop containers:
function stop_containers() {
    if [ ${docker_countainer_count} -eq '0' ]; then
        echo "No containers found, moving on... "
    else
        echo "Removing containers... "
        docker container rm -f $(docker container ls -a -q)
        echo "Removed containers successfully... "
    fi
}

# Delete Docker images:
function delete_images() {
    if [ ${docker_images_count} -eq 0 ]; then
        echo "No Docker images to remove. Moving on... "
    else
        echo "Deleting Docker images... Please wait... "
        docker rmi -f $(docker images  | awk '{print $2, $3}' | grep -iv "TAG" | awk '{print $2}')
        echo "Successfully deleted images. Moving on... "
    fi
}

# Update containers & start via script or compose file
function update_containers() {
    i=1
    while [ $i -le ${apps_count} ]
    do
        app_path="${apps_home}/$(ls ${apps_home} | head -$i | tail +$i)"
        if [ -f ${app_path}/docker-compose.yml ] || [ -f ${app_path}/docker-compose.yaml ]; then
            echo "Found Docker-Composed file in: ${app_path}"
            cd ${app_path} && docker-compose up -d
        fi

        if [ -f ${app_path}/docker-cli.sh ]; then
            echo "Found Docker CLI Script in: ${app_path}"
            bash ${app_path}/docker-cli.sh
        fi
        ((i++))
    done
}

centralize_functions() {
    stop_containers
    delete_images
    update_containers
    echo "Successfully updated containers, please verify that they are working properly... "
}

centralize_functions