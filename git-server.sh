#!/bin/bash

# Create a local Git repository that ArgoCD can access
REPO_DIR="/tmp/localstack-repo"
CURRENT_DIR=$(pwd)

# Remove existing repo if it exists
rm -rf $REPO_DIR

# Create new repo directory
mkdir -p $REPO_DIR

# Copy our helm chart to the repo
cp -r $CURRENT_DIR/helm $REPO_DIR/
cp -r $CURRENT_DIR/app $REPO_DIR/

# Initialize git repo
cd $REPO_DIR
git init
git add .
git commit -m "Initial commit"

# Create a simple Git server using git daemon
echo "Starting Git daemon on port 9418..."
git daemon --verbose --export-all --base-path=/tmp --enable=receive-pack --reuseaddr --port=9418 &

echo "Git daemon started. Repository available at: git://localhost:9418/localstack-repo"
echo "Press Ctrl+C to stop"

# Keep the script running
wait
