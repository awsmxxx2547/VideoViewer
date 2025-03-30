#!/bin/bash

# Detect platform
PLATFORM=$(uname -s)

# Installation directories
LINUX_DIR="/usr/local/bin"
MACOS_DIR="/usr/local/bin"
WINDOWS_DIR="/c/Program Files/video_viewer"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Uninstall function
uninstall() {
    echo -e "${RED}Uninstalling video_viewer...${NC}"
    
    case "$PLATFORM" in
        Linux)
            if [ -f "$LINUX_DIR/video_viewer" ]; then
                sudo rm -f "$LINUX_DIR/video_viewer"
                echo -e "${GREEN}Removed $LINUX_DIR/video_viewer${NC}"
            else
                echo -e "${RED}video_viewer not found in $LINUX_DIR${NC}"
            fi
            ;;
        Darwin)
            if [ -f "$MACOS_DIR/video_viewer" ]; then
                sudo rm -f "$MACOS_DIR/video_viewer"
                echo -e "${GREEN}Removed $MACOS_DIR/video_viewer${NC}"
            else
                echo -e "${RED}video_viewer not found in $MACOS_DIR${NC}"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            if [ -f "$WINDOWS_DIR/video_viewer.exe" ]; then
                rm -f "$WINDOWS_DIR/video_viewer.exe"
                echo -e "${GREEN}Removed $WINDOWS_DIR/video_viewer.exe${NC}"
                echo "Please remove '$WINDOWS_DIR' from your PATH if you added it"
            else
                echo -e "${RED}video_viewer.exe not found in $WINDOWS_DIR${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Unsupported platform: $PLATFORM${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Uninstallation complete!${NC}"
}

# Confirm uninstall
read -p "Are you sure you want to uninstall video_viewer? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    uninstall
else
    echo "Uninstallation cancelled"
    exit 0
fi
