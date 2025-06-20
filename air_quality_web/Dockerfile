# Use nginx image
FROM nginx:alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom config to nginx
COPY nginx.conf /etc/nginx/conf.d

# Copy Flutter web build output to nginx directory
COPY build/web /usr/share/nginx/html

# Expose port 8080 for Cloud Run
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

