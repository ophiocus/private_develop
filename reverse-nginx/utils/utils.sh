#!/bin/sh

# Array to store container names
containers=()

# Function to add a container name to the array
add_container_to_array() {
    container_name="$1"
    containers+=("$container_name")
}

# Function to remove a container name from the array
remove_container_from_array() {
    container_name="$1"
    containers=("${containers[@]/$container_name}")
}

# Function to check if a container name exists in the array
container_exists_in_array() {
    container_name="$1"
    for container in "${containers[@]}"; do
        if [ "$container" = "$container_name" ]; then
            return 0 # Container exists in the array
        fi
    done
    return 1 # Container does not exist in the array
}