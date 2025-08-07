FROM nginx:alpine

# Install curl and unzip
RUN apk add --no-cache curl unzip

# Download and extract the 2048 game
RUN curl -L https://codeload.github.com/gabrielecirulli/2048/zip/master -o /tmp/master.zip \
    && unzip /tmp/master.zip -d /tmp \
    && mv /tmp/2048-master/* /usr/share/nginx/html/ \
    && rm -rf /tmp/*

# Expose port 80
EXPOSE 80

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
