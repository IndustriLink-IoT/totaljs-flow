#!/bin/bash

# A simple run.sh script that automates clean, build & run development workflow.
# Don't forget to make the script executable: chmod +x run.sh
# Run it with: ./run.sh

# Exit on any error
set -e

BUNDLE_PATH="--bundles--"

# Step 0: Gracefully shut down any existing podman-compose apps
if [ -f "docker-compose.yml" ] || [ -f "podman-compose.yml" ]; then
  echo "📦 Found docker-compose.yml"
  echo "Gracefully shutting down existing apps - running podman-compose down..."
  podman-compose down || true
  sleep 0.5
else
  echo " "
fi

echo "🛑 Stopping all containers..."
podman stop --all || true
sleep 1

echo "🧹 Removing all containers..."
podman rm --all || true
sleep 0.2

echo "🧼 Removing all images..."
podman rmi --all --force || true
sleep 0.2

echo "🗑️ Removing all volumes..."
podman volume rm --all || true
sleep 0.2

echo "✅ Docker is Clean ..."
sleep 0.5

echo "🗑️ Removing existing app bundles..."
sleep 0.2
# Make temp working dir
mkdir -p .temp
cd .temp

# Check for existing bundle files and delete them
if [ -f "../$BUNDLE_PATH/app.bundle" ]; then
  echo "| |-- Removing existing app.bundle"
  rm "../$BUNDLE_PATH/app.bundle"
  sleep 0.5
fi

if [ -f "../$BUNDLE_PATH/bookmarks.bundle" ]; then
  echo "| |-- Removing existing bookmarks.bundle"
  rm "../$BUNDLE_PATH/bookmarks.bundle"
  sleep 0.5
fi

# Return to parent directory and cleanup
cd ..
rm -rf .temp

echo "✅ Bundles Removed"
sleep 0.5

echo "📦 Bundling app..."
./bundle.sh
sleep 0.2

echo "✅ New Bundles Built"
sleep 0.5

echo "🚀 Starting app with podman-compose..."
podman-compose up --build
