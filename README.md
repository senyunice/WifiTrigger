# WifiTrigger

An iOS jailbreak plugin that automatically runs Shortcuts when connecting to specific WiFi networks. Designed for multi-dopamine rootless environments.

## Features

- Automatically detects WiFi network connections
- Triggers specified Shortcuts upon connecting to target WiFi
- Settings panel for configuring WiFi name and Shortcut name
- Supports multi-dopamine rootless environment
- Optimized for iOS 15.x/16.x

## Technical Details

- **Hook Method**: SBWiFiManager `_updateWiFiState`
- **Execution Path**: `/var/jb/usr/bin/shortcuts run` (multi-dopamine compatible)
- **Preferences Path**: `/var/jb/var/mobile/Library/Preferences/com.tom.wifitrigger.plist`
- **Supported Architectures**: arm64, arm64e

## Installation

1. Compile the project using Theos on a macOS system:
   ```bash
   make clean package FINALPACKAGE=1
   ```
2. Transfer the .deb file to your iOS device
3. Install using Sileo, Zebra, or command line
4. Respring your device
5. Configure in Settings under "WiFi指令触发器"

## Configuration

The settings panel allows you to specify:
- WiFi network name to monitor
- Shortcut name to execute when connecting
- Enable/disable the plugin

## Credits

- Based on Theos development framework
- Uses posix_spawn for iOS compatibility
- Supports multi-dopamine rootless environments