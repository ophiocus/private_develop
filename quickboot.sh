#!/bin/zsh

compose_files_file="compose_files.txt"
compose_files=()

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

  echo "Checking ports before triggering Docker Compose for $absolute_path..."

  local port_in_use=false
  for port in 80 443 3306; do
    if lsof -i:$port >/dev/null; then
      echo "Port $port is already in use."
      port_in_use=true
    fi
  done

  if [ "$port_in_use" = true ]; then
    echo "Cannot trigger Docker Compose for $absolute_path due to port conflicts."
  else
    echo "Triggering Docker Compose using absolute path: $absolute_path"
    docker-compose -f "$absolute_path" up -d
  fi
}

for file in "${compose_files[@]}"; do
  trigger_docker_compose "$file"
done
