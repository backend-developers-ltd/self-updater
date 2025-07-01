#!/bin/bash
set -e

# Configuration
ORG_NAME="${ORG_NAME}"
PROJECT_NAME="${PROJECT_NAME}"
ENV_NAME="${ENV_NAME:-prod}"
BRANCH="deploy-compose-${ENV_NAME}"
GITHUB_REPO="https://raw.githubusercontent.com/${ORG_NAME}/${PROJECT_NAME}/${BRANCH}/docker-compose.yml"
LOCAL_FILE="/app/docker-compose.yml"
TEMP_FILE="/tmp/docker-compose.yml.new"

# Ensure we have access to docker
if ! docker info > /dev/null 2>&1; then
    echo "$(date): Error: Cannot connect to the Docker daemon. Is the docker socket mounted correctly?"
    exit 1
fi

echo "$(date): Checking for updates..."

# Fetch the latest docker-compose.yml from GitHub
curl -s -o "$TEMP_FILE" "$GITHUB_REPO"

if [ ! -f "$LOCAL_FILE" ]; then
    echo "$(date): Local docker-compose.yml not found. Creating initial file."
    cp "$TEMP_FILE" "$LOCAL_FILE"
    docker compose -f "$LOCAL_FILE" up -d --remove-orphans
    echo "$(date): Initial deployment completed."
    exit 0
fi

# Extract local name value if it exists
LOCAL_NAME=$(grep -E "^name:" "$LOCAL_FILE" | sed 's/^name: *//')

# Compare files ignoring the name field
LOCAL_CONTENT=$(grep -v "^name:" "$LOCAL_FILE" | sort)
REMOTE_CONTENT=$(grep -v "^name:" "$TEMP_FILE" | sort)

if [ "$LOCAL_CONTENT" != "$REMOTE_CONTENT" ]; then
    echo "$(date): Changes detected, updating docker-compose.yml"

    # If local name exists, preserve it in the new file
    if [ -n "$LOCAL_NAME" ]; then
        # Remove any existing name line from the new file
        grep -v "^name:" "$TEMP_FILE" > "$TEMP_FILE.tmp"
        # Add the local name at the top of the file
        echo "name: $LOCAL_NAME" > "$TEMP_FILE"
        cat "$TEMP_FILE.tmp" >> "$TEMP_FILE"
        rm "$TEMP_FILE.tmp"
    fi

    # Backup the old file
    cp "$LOCAL_FILE" "$LOCAL_FILE.bak"

    # Replace the local file with the new one
    cp "$TEMP_FILE" "$LOCAL_FILE"

    echo "$(date): Running docker compose up -d --remove-orphans"
    cd $(dirname "$LOCAL_FILE") && docker compose up -d --remove-orphans
    echo "$(date): Update completed successfully"
else
    echo "$(date): No changes detected"
fi

# Clean up
rm -f "$TEMP_FILE"
