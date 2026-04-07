# Use official Nginx image as base
FROM nginx:alpine

# Copy all your web files to Nginx html directory
COPY . /usr/share/nginx/html

# Expose port 80 for web access
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
