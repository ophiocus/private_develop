#!/bin/zsh

# Function to handle the event
handle_event() {
    # Extract relevant information from the event
    container_id=$(echo "$1" | jq -r '.id')
    event_action=$(echo "$1" | jq -r '.Action')
    event_type=$(echo "$1" | jq -r '.Type')

    # Check if the event is a container creation event
    if [[ "$event_type" == "container" && "$event_action" == "create" ]]; then
        # Get the container's network information
        network_info=$(docker inspect -f '{{json .NetworkSettings.Networks}}' "$container_id")

        # Check if the container has joined the desired network
        if [[ $network_info == *"your_network_name"* ]]; then
            echo "Container $container_id joined the network"
            # Perform actions or trigger logic here
        fi
    fi
}

# Function to start monitoring
start_monitoring() {
    # Listen for Docker events
    docker events --filter 'event=create' --filter 'event=connect' --filter 'event=disconnect' --filter 'event=destroy' --format '{{json .}}' |
    # When an event comes through, pass it to the handle_event function.
    while read -r event; do
        handle_event "$event"
    done
}

# Function to stop monitoring
stop_monitoring() {
    # Stop the monitoring process
    pkill -f "docker events"
    echo "Monitoring stopped."
}

# Check the command-line argument
if [[ $# -eq 1 ]]; then
    if [[ "$1" == "start" ]]; then
        # Start monitoring in the background
        start_monitoring &
        echo "Monitoring started in the background."
    elif [[ "$1" == "stop" ]]; then
        # Stop monitoring
        stop_monitoring
    else
        echo "Invalid command. Usage: $0 [start|stop]"
    fi
else
    echo "Invalid command. Usage: $0 [start|stop]"
fi
