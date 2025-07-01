# Self-Updater Service

A Docker-based service that automatically keeps your docker-compose.yml file in sync with a GitHub repository and applies changes.

## For Users

### What It Does

The Self-Updater service:
1. Checks a GitHub repository every minute for updates to a docker-compose.yml file
2. If changes are detected, updates your local docker-compose.yml file
3. Preserves your local `name:` field when updating
4. Automatically runs `docker compose up -d --remove-orphans` to apply the changes

### How to Use It

1. Deploy the service using the provided docker-compose.yml:
   ```bash
   docker compose up -d
   ```

2. The service will automatically start monitoring for updates to your docker-compose.yml file.

### Configuration Options

You can customize the service using the following environment variable:

- `ENV_NAME`: Determines which environment configuration to use (default: `prod`)
  - Affects the Docker image used: `backenddevelopersltd/luxor-updater-${ENV_NAME}:latest`
  - Affects which GitHub branch is monitored: `deploy-compose-${ENV_NAME}`

Example with custom environment:
```bash
ENV_NAME=staging docker compose up -d
```

This will use the `backenddevelopersltd/luxor-updater-staging:latest` image and monitor the `deploy-compose-staging` branch.

## For Developers

### Repository Configuration

The service is designed to be configurable at build time to point to different GitHub repositories:

- `ORG_NAME`: The GitHub organization name (default: `backend-developers-ltd`)
- `PROJECT_NAME`: The GitHub project name (default: `self-updater`)

These values are baked into the Docker image at build time and determine which GitHub repository the service will monitor.

### Building Custom Images

Use the provided `build.sh` script to build custom images:

```bash
# Using defaults
./build.sh

# With custom organization and project
ORG_NAME=my-org PROJECT_NAME=my-project ./build.sh

# With custom environment
ENV_NAME=dev ./build.sh

# With all custom values
ORG_NAME=my-org PROJECT_NAME=my-project ENV_NAME=dev ./build.sh
```

The script will build a Docker image with the specified configuration and tag it appropriately.

### How It Works

1. The service runs a cron job that executes the `update-check.sh` script every minute
2. The script fetches the docker-compose.yml from the configured GitHub repository
3. It compares the remote file with the local file (ignoring the `name:` field)
4. If differences are detected:
   - The local `name:` value is preserved
   - The local file is updated with the content from GitHub
   - `docker compose up -d --remove-orphans` is executed to apply changes

### GitHub Repository Structure

For the service to work properly, your GitHub repository should:
1. Have a docker-compose.yml file in the root directory of each branch
2. Use branch names in the format `deploy-compose-{environment}` (e.g., `deploy-compose-prod`, `deploy-compose-staging`)

## Troubleshooting

If you encounter issues:

1. Check the logs:
   ```bash
   docker logs -f updater
   ```

2. Ensure the Docker socket is properly mounted
3. Verify that the GitHub repository and branch are accessible
4. Check that your environment variables are set correctly