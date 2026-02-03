# WifiTrigger Compilation Notes

## Current Status
- All project files have been successfully created with correct structure
- Source code is properly written in Tweak.x and Prefs modules
- Makefile, control file, and plist files are correctly configured

## Compilation Issues Encountered
1. Missing iOS-specific clang toolchain (current clang is for Linux)
2. Linker errors due to incorrect cross-compilation setup
3. Need for iOS-specific linker and libraries

## Solution Steps Required

### 1. Install Complete iOS Toolchain
Run these commands in your WSL Ubuntu terminal:

```bash
# Navigate to theos directory
cd ~/theos

# Install iOS toolchain (if available via Theos)
# You may need to download a pre-built iOS toolchain

# Alternative: Install ios-toolchain-based-on-clang
git clone https://github.com/tpoechtrager/ios-cmake.git
# Or follow theos documentation to install iOS toolchain
```

### 2. Verify Installation
```bash
# Check if iOS clang is available
~/theos/toolchain/linux/iphone/bin/clang --version
```

### 3. Compile Project
```bash
cd ~/projects/WifiTrigger
export THEOS=/home/$(whoami)/theos
make clean package FINALPACKAGE=1
```

## Result Location
Upon successful compilation, the .deb package will be located in:
~/projects/WifiTrigger/packages/

## Transfer to iOS Device
After compilation, transfer the .deb file to your iOS device using:
- SFTP client
- Dropbox/other cloud services
- USB transfer tools like libimobiledevice

## Installation on iOS
- Install via Sileo/Zebra (recommended)
- Or use command line: dpkg -i package.deb

## Notes
- Ensure your iOS device is jailbroken with rootless support (Dopamine recommended)
- Requires PreferenceLoader for settings integration
- Shortcut commands will run via /var/jb/usr/bin/shortcuts (Dopamine-specific path)