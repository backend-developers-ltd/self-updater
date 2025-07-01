#!/bin/bash
set -e

# Default values
ORG_NAME=${ORG_NAME:-"backend-developers-ltd"}
PROJECT_NAME=${PROJECT_NAME:-"self-updater"}
ENV_NAME=${ENV_NAME:-"prod"}

# Build the Docker image with build arguments for x86 Linux platform
docker build \
  --platform linux/amd64 \
  --build-arg ORG_NAME="$ORG_NAME" \
  --build-arg PROJECT_NAME="$PROJECT_NAME" \
  -t backenddevelopersltd/luxor-updater-${ENV_NAME}:latest \
  .

echo "Built image: backenddevelopersltd/luxor-updater-${ENV_NAME}:latest"
echo "With GitHub repo: $ORG_NAME/$PROJECT_NAME"
echo "Branch: deploy-compose-${ENV_NAME}"
echo "Platform: linux/amd64 (x86 Linux)"