#!/bin/sh

# Function to configure NGINX for the joined container
configure_nginx_for_container() {
    container_id="$1"

    # Extract environment variables from the joined Docker container
    domain_name=$(docker inspect --format '{{ index .Config.Env "DOMAIN_NAME" }}' "$container_id")
    ssl_cert=$(docker inspect --format '{{ index .Config.Env "SSL_CERT" }}' "$container_id")
    ssl_key=$(docker inspect --format '{{ index .Config.Env "SSL_KEY" }}' "$container_id")

    # Configure NGINX for the joined container
    if [ -n "$domain_name" ]; then
        echo "Configuring NGINX for domain: $domain_name"

        # Create a symlink to the container-specific configuration file
        config_file="/etc/nginx/conf.d/$container_id.conf"
        ln -sf "/etc/nginx/active_reverse/$container_id.conf" "$config_file"

        # Update the symlink target with the container-specific reverse proxy configuration
        echo "
        server {
            listen 80;
            listen 443 ssl;
            server_name $domain_name;

            ssl_certificate /etc/nginx/certs/$container_id/cert.crt;
            ssl_certificate_key /etc/nginx/certs/$container_id/cert.key;

            location / {
                proxy_pass http://$container_id:80;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
            }
        }
        " > "/etc/nginx/active_reverse/$container_id.conf"

        # Create SSL certificate directory if it doesn't exist
        mkdir -p "/etc/nginx/certs/$container_id"
        # Save the SSL certificate and key for the container
        echo "$ssl_cert" > "/etc/nginx/certs/$container_id/cert.crt"
        echo "$ssl_key" > "/etc/nginx/certs/$container_id/cert.key"

        # Reload NGINX configuration
        nginx -s reload
    fi
}

# Function to remove container-specific configuration and certificates
remove_container_configuration() {
    container_id="$1"

    # Remove the symlink to the container-specific configuration file
    config_file="/etc/nginx/conf.d/$container_id.conf"
    rm -f "$config_file"

    # Remove the container-specific reverse proxy configuration file
    rm -f "/etc/nginx/active_reverse/$container_id.conf"

    # Remove the container-specific SSL certificate and key
    rm -f "/etc/nginx/certs/$container_id/cert.crt"
    rm -f "/etc/nginx/certs/$container_id/cert.key"

    # Reload NGINX configuration
    nginx -s reload
}
