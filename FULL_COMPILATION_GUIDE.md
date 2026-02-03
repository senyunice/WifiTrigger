# WifiTrigger Full Compilation Guide

## Current Status
The WifiTrigger project has been completely developed with all source files and configurations ready. The only remaining step is compilation.

## Issue
The compilation fails in WSL because of missing iOS cross-compilation toolchain. The error "unrecognised emulation mode: llvm" occurs because we're using Linux linker instead of iOS-specific linker.

## Solution Options

### Option 1: Use a macOS Machine (Recommended)
The easiest solution is to compile on a macOS machine with Xcode installed:
1. Copy the project to a Mac
2. Install Theos following the official guide: https://theos.dev/docs/installation
3. Run `make clean package FINALPACKAGE=1`

### Option 2: Set Up Complete iOS Toolchain in WSL
Follow these steps to install a proper iOS cross-compilation toolchain:

```bash
# 1. Install prerequisites
sudo apt-get update
sudo apt-get install -y build-essential git cmake python3

# 2. Clone and build ios-cmake (iOS cross-compilation tools)
cd /tmp
git clone https://github.com/leetal/ios-cmake.git
sudo cp -r ios-cmake/ios.toolchain.cmake /usr/share/cmake-*/Modules/Platform/

# 3. Download and compile cctools-port for iOS
cd /tmp
git clone https://github.com/tpoechtrager/cctools-port.git
cd cctools-port/cctools
./configure
make
sudo make install

# 4. Install ld64 (iOS linker)
cd /tmp/cctools-port/cctools/ld64
./configure
make
sudo make install

# 5. Create proper iOS toolchain in Theos
mkdir -p ~/theos/toolchain/darwin/iphone/bin
# Create iOS-specific clang wrapper
cat > ~/theos/toolchain/darwin/iphone/bin/clang << 'EOF'
#!/bin/bash
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export SDKROOT="$(xcrun --sdk iphoneos --show-sdk-path)"
exec /usr/bin/clang \
  -isysroot "$SDKROOT" \
  -arch arm64 \
  -miphoneos-version-min=15.0 \
  -stdlib=libc++ \
  "$@"
EOF

chmod +x ~/theos/toolchain/darwin/iphone/bin/clang

# 6. Update your Makefile to use the darwin toolchain
sed -i 's/iphone:/iphone:/' ~/projects/WifiTrigger/Makefile
```

### Option 3: Use Docker with Pre-built iOS Toolchain
Create a Dockerfile with a pre-configured iOS toolchain:

```bash
# Create Dockerfile
cat > ~/projects/WifiTrigger/Dockerfile << 'EOF'
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    ldid \
    zip \
    unzip \
    git \
    wget \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Theos
RUN git clone --recursive https://github.com/theos/theos.git /opt/theos

ENV THEOS=/opt/theos
ENV PATH=$THEOS/bin:$PATH

# Create toolchain symlinks
RUN mkdir -p $THEOS/toolchain/linux/iphone/bin && \
    ln -s $(which clang) $THEOS/toolchain/linux/iphone/bin/clang

WORKDIR /project
COPY . /project

CMD ["make", "clean", "package"]
EOF

# Build and run
cd ~/projects/WifiTrigger
docker build -t wifitrigger-builder .
docker run --rm -v $(pwd):/project -w /project wifitrigger-builder
```

### Option 4: Manual Toolchain Setup (Advanced)
Download and configure a pre-built iOS toolchain manually:

```bash
# Download a pre-built iOS toolchain
cd ~/theos/toolchain/darwin/iphone
wget -O toolchain.tar.xz https://github.com/roothorick/ios-toolchain-based-on-clang/releases/download/latest/ios-toolchain.tar.xz
tar -xf toolchain.tar.xz
```

## Verification Steps
After setting up the proper toolchain, verify with:
```bash
cd ~/projects/WifiTrigger
export THEOS=/home/$(whoami)/theos
make clean package FINALPACKAGE=1
```

## Expected Output
Upon successful compilation, you'll find the .deb package in:
`~/projects/WifiTrigger/packages/`

## Deployment
1. Transfer the .deb file to your jailbroken iOS device
2. Install using Sileo, Zebra, or command line: `dpkg -i package.deb`
3. Respring your device
4. Configure in Settings app under "WiFi指令触发器"

## Troubleshooting
- If you get "command not found" errors, ensure all tools (clang, ldid, etc.) are installed
- If linking fails, double-check that iOS-specific linker is being used instead of Linux linker
- Make sure the SDK versions match your target iOS version