FROM nginx:latest

# Install additional tools (e.g., netcat) for network monitoring
RUN apt-get update && apt-get install -y netcat

# Copy custom NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy custom monitoring script
COPY monitor.sh /usr/local/bin/monitor.sh

# Set execute permissions for the monitoring script
RUN chmod +x /usr/local/bin/monitor.sh

# Expose the NGINX default port
EXPOSE 80

# Start NGINX and run the monitoring script in the background
CMD ["sh", "-c", "nginx && /usr/local/bin/monitor.sh"]
