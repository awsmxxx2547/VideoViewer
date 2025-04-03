#!/bin/bash

source ./install_dependencies.sh

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installation directories
LINUX_DIR="/usr/local/bin"
MACOS_DIR="/usr/local/bin"

TARGET="build/bin/video_viewer"

if command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

# Main installation function
install_video_viewer() {
    PLATFORM=$(uname -s)
    echo -e "${YELLOW}Installing VideoViewer for $PLATFORM...${NC}"

    # Install dependencies first
    install_dependencies

    case "$PLATFORM" in
        Linux)
            $SUDO install -m 755 $TARGET "$LINUX_DIR"
            ;;
        Darwin)
            $SUDO install -m 755 $TARGET "$MACOS_DIR"
            ;;
        *)
            echo -e "${RED}Unsupported platform: $PLATFORM${NC}"
            exit 1
            ;;
    esac

    echo -e "${GREEN}Installation complete!${NC}"
    echo "Run with: video_viewer"
}

# Run installation
install_video_viewer
