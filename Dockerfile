FROM alpine:3.18

# Build arguments for GitHub repository configuration
ARG ORG_NAME
ARG PROJECT_NAME

# Set environment variables from build arguments
ENV ORG_NAME=$ORG_NAME
ENV PROJECT_NAME=$PROJECT_NAME

# Install required packages
RUN apk add --no-cache \
    docker \
    docker-compose \
    curl \
    jq \
    bash \
    git \
    dcron

# Create update script
COPY update-check.sh /usr/local/bin/update-check.sh
RUN chmod +x /usr/local/bin/update-check.sh

# Set up cron job
RUN echo "* * * * * /usr/local/bin/update-check.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root && \
    mkdir -p /var/log && \
    touch /var/log/cron.log

# Create directory for docker-compose file
RUN mkdir -p /app

WORKDIR /app

# Start cron in foreground
CMD crond -f -l 8
