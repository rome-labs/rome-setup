#!/bin/bash -x

export BRANCH="local"
DOCKER_COMPOSE_DIR="romescout/docker-compose"
export FRONTEND_DOCKER_TAG=v1.36.2
export DOCKER_TAG=6.9.2
export STATS_DOCKER_TAG=v2.2.3
export VISUALIZER_DOCKER_TAG=v0.2.1
export SIG_PROVIDER_DOCKER_TAG=v1.1.1
export SMART_CONTRACT_VERIFIER_DOCKER_TAG=v1.9.2
export USER_OPS_INDEXER_DOCKER_TAG=v1.3.0

echo "Starting Blockscout setup..."

# Clone the Blockscout repo from the branch provided in the environment variable using HTTPS
if [ ! -d "romescout" ]; then
    echo "Cloning Blockscout repo from branch $BRANCH..."
    git clone --branch $BRANCH https://github.com/rome-labs/romescout.git
fi

# Change directory to docker-compose folder
echo "Navigating to the docker-compose directory..."
cd $DOCKER_COMPOSE_DIR || exit

docker compose down

# Remove old data

echo "Removing old Docker data..."
rm -rf services/blockscout-db-data
rm -rf services/stats-db-data
rm -rf services/logs
rm -rf services/redis-data

# Build Docker images and run them
echo "Building Docker images and starting containers..."
# docker compose up --build -d
docker compose up -d
cd ../..
echo "Blockscout services started."
