FROM nginx:latest

# Install additional tools (e.g., netcat) for network monitoring
RUN apt-get update && apt-get install -y netcat

# This nginx will make its own certs on the fly for any incomming Services.
RUN apt-get -y install openssl

# Copy custom NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the NGINX default port
EXPOSE 80 443 3306

# Start NGINX and run the monitoring script in the background
CMD ["sh", "-c", "nginx"]
