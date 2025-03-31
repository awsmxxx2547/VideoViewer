#!/bin/bash

# Detect platform
PLATFORM=$(uname -s)

# Installation directories
LINUX_DIR="/usr/local/bin"
MACOS_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

# Uninstall function
uninstall() {
    echo -e "${RED}Uninstalling video_viewer...${NC}"
    
    case "$PLATFORM" in
        Linux)
            if [ -f "$LINUX_DIR/video_viewer" ]; then
                $(SUDO) rm -f "$LINUX_DIR/video_viewer"
                echo -e "${GREEN}Removed $LINUX_DIR/video_viewer${NC}"
            else
                echo -e "${RED}video_viewer not found in $LINUX_DIR${NC}"
            fi
            ;;
        Darwin)
            if [ -f "$MACOS_DIR/video_viewer" ]; then
                $(SUDO) rm -f "$MACOS_DIR/video_viewer"
                echo -e "${GREEN}Removed $MACOS_DIR/video_viewer${NC}"
            else
                echo -e "${RED}video_viewer not found in $MACOS_DIR${NC}"
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
read -p "Are you sure you want to uninstall VideoViewer? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    uninstall
else
    echo "Uninstallation cancelled"
    exit 0
fi
