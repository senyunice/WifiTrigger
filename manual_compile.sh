#!/bin/bash

# Manual compilation script for WifiTrigger
# This script bypasses some of the Theos toolchain issues

set -e  # Exit on any error

echo "Starting manual compilation of WifiTrigger..."

# Set environment
export THEOS=/home/$(whoami)/theos
export PATH=$THEOS/bin:$PATH

PROJECT_DIR="/home/$(whoami)/projects/WifiTrigger"
OUTPUT_DIR="$PROJECT_DIR/.theos/obj"
BUILD_DIR="$PROJECT_DIR/.theos/obj/arm64"
PACKAGE_DIR="$PROJECT_DIR/packages"

echo "Project directory: $PROJECT_DIR"
echo "Theos directory: $THEOS"

# Clean previous build
echo "Cleaning previous build..."
make -C "$PROJECT_DIR" clean >/dev/null 2>&1 || true

# Create necessary directories
mkdir -p "$BUILD_DIR"
mkdir -p "$PACKAGE_DIR"

# Define iOS SDK path
IOS_SDK="$THEOS/sdks/iPhoneOS15.6.sdk"

echo "Using iOS SDK: $IOS_SDK"

# Compile Tweak.x to object file manually
echo "Compiling Tweak.x..."
clang -arch arm64 \
  -isysroot "$IOS_SDK" \
  -miphoneos-version-min=15.0 \
  -stdlib=libc++ \
  -I"$THEOS/include" \
  -I"$IOS_SDK/usr/include" \
  -fobjc-arc \
  -MMD -MP \
  -c "$PROJECT_DIR/Tweak.x" \
  -o "$BUILD_DIR/Tweak.o"

echo "Tweak.x compiled successfully"

# Compile Prefs module
echo "Compiling Prefs module..."
PREFS_DIR="$PROJECT_DIR/Prefs"
PREFS_BUILD_DIR="$PREFS_DIR/.theos/obj/arm64"

mkdir -p "$PREFS_BUILD_DIR"

clang -arch arm64 \
  -isysroot "$IOS_SDK" \
  -miphoneos-version-min=15.0 \
  -stdlib=libc++ \
  -I"$THEOS/include" \
  -I"$THEOS/vendor/include" \
  -I"$IOS_SDK/usr/include" \
  -fobjc-arc \
  -MMD -MP \
  -c "$PREFS_DIR/WifiTriggerRootListController.m" \
  -o "$PREFS_BUILD_DIR/WifiTriggerRootListController.o"

echo "Prefs module compiled successfully"

# Create dylib manually for main tweak
echo "Creating dynamic library for main tweak..."
ld -dylib \
  -syslibroot "$IOS_SDK" \
  -arch arm64 \
  -ios_version_min 15.0 \
  -undefined dynamic_lookup \
  -compatibility_version 1.0.0 \
  -current_version 1.0.0 \
  -o "$BUILD_DIR/WifiTrigger.dylib" \
  "$BUILD_DIR/Tweak.o"

echo "Main dylib created successfully"

# Create dylib for prefs
PREFS_DYLIB_DIR="$PREFS_DIR/.theos/obj/arm64/WifiTriggerPrefs.bundle"
mkdir -p "$PREFS_DYLIB_DIR"

ld -dylib \
  -dylib_install_name "@executable_path/WifiTriggerPrefs.bundle/WifiTriggerPrefs" \
  -syslibroot "$IOS_SDK" \
  -arch arm64 \
  -ios_version_min 15.0 \
  -undefined dynamic_lookup \
  -compatibility_version 1.0.0 \
  -current_version 1.0.0 \
  -o "$PREFS_DYLIB_DIR/WifiTriggerPrefs" \
  "$PREFS_BUILD_DIR/WifiTriggerRootListController.o"

echo "Prefs dylib created successfully"

# Package everything using dpkg-deb
echo "Packaging into DEB file..."

# Create staging directory
STAGE_DIR="$PROJECT_DIR/staging"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"

# Copy files to staging
mkdir -p "$STAGE_DIR/Library/MobileSubstrate/DynamicLibraries"
cp "$BUILD_DIR/WifiTrigger.dylib" "$STAGE_DIR/Library/MobileSubstrate/DynamicLibraries/"

mkdir -p "$STAGE_DIR/Library/PreferenceBundles"
cp -r "$PREFS_DYLIB_DIR" "$STAGE_DIR/Library/PreferenceBundles/"

mkdir -p "$STAGE_DIR/Library/PreferenceLoader/Preferences"
cp "$PROJECT_DIR/WifiTrigger.plist" "$STAGE_DIR/Library/PreferenceLoader/Preferences/"

# Copy control file
cp "$PROJECT_DIR/control" "$STAGE_DIR/DEBIAN/control"

# Fix permissions
chmod -R 644 "$STAGE_DIR/Library/PreferenceBundles/WifiTriggerPrefs.bundle"
chmod 755 "$STAGE_DIR/Library/PreferenceBundles/WifiTriggerPrefs.bundle/WifiTriggerPrefs"
chmod 755 "$STAGE_DIR/Library/MobileSubstrate/DynamicLibraries/WifiTrigger.dylib"

# Create the deb package
PACKAGE_NAME="WifiTrigger_0.1.0_iphoneos-arm64.deb"
dpkg-deb --build "$STAGE_DIR" "$PACKAGE_DIR/$PACKAGE_NAME"

echo "SUCCESS: WifiTrigger has been compiled and packaged!"
echo "DEB package location: $PACKAGE_DIR/$PACKAGE_NAME"

# Cleanup
rm -rf "$STAGE_DIR"

echo "Compilation completed successfully!"