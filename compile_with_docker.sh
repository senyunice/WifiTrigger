#!/bin/bash

# Script to compile WifiTrigger using Docker
echo "Starting Docker-based compilation of WifiTrigger..."

# Navigate to project directory
cd /home/$(whoami)/projects/WifiTrigger

# Build the Docker image (this may take several minutes)
echo "Building Docker image with iOS cross-compilation environment..."
docker build -t wifitrigger-builder . || {
    echo "Docker build failed. This may be due to:"
    echo "1. Network connectivity issues during download"
    echo "2. Insufficient disk space"
    echo "3. Docker daemon not running properly"
    exit 1
}

echo "Docker image built successfully!"

# Run the compilation
echo "Starting compilation process..."
docker run --rm -v $(pwd):/project -w /project wifitrigger-builder bash -c "
export THEOS=/opt/theos &&
echo 'Environment variables set:' &&
echo 'THEOS='\$THEOS &&
echo 'PATH='\$PATH &&
echo 'Compiling WifiTrigger...' &&
make clean &&
make package FINALPACKAGE=1 &&
echo 'Compilation completed!' &&
echo 'Checking for output files...' &&
ls -la packages/ 2>/dev/null || echo 'No packages/ directory found'"

echo "Compilation process finished. Check the packages/ directory for the .deb file."