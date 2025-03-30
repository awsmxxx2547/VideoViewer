#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Installation directories
LINUX_DIR="/usr/local/bin"
MACOS_DIR="/usr/local/bin"
WINDOWS_DIR="/c/Program Files/video_viewer"

# Function to install dependencies
install_dependencies() {
    echo -e "${YELLOW}Checking and installing dependencies...${NC}"
    
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update && sudo apt-get install -y \
            ffmpeg \
            curl unzip \
            libsdl2-dev \
            libavformat-dev \
            libavcodec-dev \
            libavutil-dev \
            libswscale-dev \
            libswresample-dev
            
    elif command -v brew >/dev/null 2>&1; then
        # macOS
        brew update && upgrade && brew install \
            curl unzip \
            sdl2 \
            ffmpeg
            
    elif command -v choco >/dev/null 2>&1; then
        # Windows (Chocolatey)
        choco install -y \
            curl \
            unzip \
            mingw \
            ffmpeg \
            sdl2
            
    else
        echo -e "${RED}Could not detect package manager!${NC}"
        echo "Please manually install: curl, unzip, SDL2, and FFmpeg libraries"
        exit 1
    fi
    
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

# Main installation function
install() {
    PLATFORM=$(uname -s)
    echo -e "${YELLOW}Installing video_viewer for $PLATFORM...${NC}"

    # Install dependencies first
    install_dependencies

    case "$PLATFORM" in
        Linux)
            sudo install -m 755 bin/video_viewer "$LINUX_DIR"
            sudo install -m 755 scripts/update.sh "$LINUX_DIR/video_viewer-update"
            ;;
        Darwin)
            sudo install -m 755 bin/video_viewer "$MACOS_DIR"
            sudo install -m 755 scripts/update.sh "$MACOS_DIR/video_viewer-update"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            mkdir -p "$WINDOWS_DIR"
            cp bin/video_viewer.exe "$WINDOWS_DIR"
            cp scripts/update.sh "$WINDOWS_DIR/video_viewer-update"
            echo -e "${YELLOW}Please add '$WINDOWS_DIR' to your PATH${NC}"
            ;;
        *)
            echo -e "${RED}Unsupported platform: $PLATFORM${NC}"
            exit 1
            ;;
    esac

    echo -e "${GREEN}Installation complete!${NC}"
    echo "Run with: video_viewer"
    echo "Update with: video_viewer --update or video_viewer-update"
}

# Run installation
install
