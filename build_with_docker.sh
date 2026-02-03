#!/bin/bash

echo "Building WifiTrigger with Docker..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed or not in PATH. Please install Docker Desktop."
    exit 1
fi

echo "Creating Docker image for iOS compilation..."
docker build -t wifitrigger-builder . || {
    echo "Failed to build Docker image"
    exit 1
}

echo "Compiling WifiTrigger..."
docker run --rm -v "$(pwd)":/project -w /project wifitrigger-builder

echo ""
echo "Compilation complete! Check the packages/ directory for the .deb file."