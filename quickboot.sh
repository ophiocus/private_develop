#!/bin/zsh

compose_files_file="quickboot.conf"
compose_files=()

# This file provides a quickboot agent that performs the following tasks
# Check ports are not already in use.
# Attempts to docker up all the entries listed in config file
#

# Read and parse the Docker Compose file paths from the file
while IFS= read -r line; do
  compose_files+=("$line")
done < "$compose_files_file"

trigger_docker_compose() {
  local compose_file=$1
  local absolute_path=""

  # Check if the path is absolute
  if [[ $compose_file == /* ]]; then
    absolute_path=$(realpath "$compose_file")
  else
    absolute_path=$(realpath "$PWD/$compose_file")
  fi

  # Check if the Docker Compose file exists
  if [ ! -f "$absolute_path" ]; then
    echo "Docker Compose file not found: $absolute_path"
    return
  fi

  
  docker-compose -f "$absolute_path" up -d
  
}

for file in "${compose_files[@]}"; do
  trigger_docker_compose "$file"
done
