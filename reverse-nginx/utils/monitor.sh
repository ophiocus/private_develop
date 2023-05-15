#!/bin/sh

# Continuously monitor Docker events
docker events --filter 'type=network' --format '{{json .}}' |
while read -r event; do
    # Extract relevant information from the event
    event_type=$(echo "$event" | jq -r '.Type')
    container_id=$(echo "$event" | jq -r '.Actor.Attributes.container')
    container_name=$(echo "$event" | jq -r '.Actor.Attributes.name')
    network_name=$(echo "$event" | jq -r '.Actor.Attributes.network')

    # Perform actions based on the event type
    if [ "$event_type" = "container" ]; then
        if [ "$container_name" != "null" ] && [ "$network_name" != "null" ]; then
            # Container joined the network
            echo "Container joined network:"
            echo "Container ID: $container_id"
            echo "Container Name: $container_name"
            echo "Network Name: $network_name"

            # Configure NGINX for the joined container
            source ./configuration.sh
            configure_nginx_for_container "$container_id"

            # Add container name to the array
            source ./utils.sh
            add_container_to_array "$container_name"
        fi
    elif [ "$event_type" = "network" ]; then
        if [ "$container_name" != "null" ] && [ "$network_name" = "null" ]; then
            # Container left the network
            echo "Container left network:"
            echo "Container ID: $container_id"
            echo "Container Name: $container_name"

            # Check if the container name is present in the array
            source ./utils.sh
            if container_exists_in_array "$container_name"; then
                # Remove container-specific configuration and certificates
                source ./configuration.sh
                remove_container_configuration "$container_name"

                # Remove container name from the array
                remove_container_from_array "$container_name"
            fi
        fi
    fi
done
