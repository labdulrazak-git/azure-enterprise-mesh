# Pull from GitHub's public registry to bypass Docker Hub rate limits
FROM ghcr.io/nginxinc/nginx-unprivileged:alpine

# Copy our custom web page into the container's web server folder
COPY index.html /usr/share/nginx/html/

# Expose port 8080 (the unprivileged NGINX image uses 8080 by default for security)
EXPOSE 8080