Copy

#!/bin/bash
# scripts/update.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Install dependencies based on OS
install_dependencies() {
    echo -e "${YELLOW}Checking and installing dependencies...${NC}"
    
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update && sudo apt-get install -y \
            curl unzip \
            libsdl2-dev \
            libavformat-dev \
            libavcodec-dev \
            libavutil-dev \
            libswscale-dev \
            libswresample-dev
            
    elif command -v brew >/dev/null 2>&1; then
        # macOS
        brew update && brew install \
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

# Main update function
update_app() {
    # Get current installed version
    CURRENT_VERSION=$($INSTALL_DIR/video_viewer --version | awk '{print $3}')
    
    # Get latest version info
    echo -e "${YELLOW}Checking for updates...${NC}"
    TEMP_FILE=$(mktemp)
    curl -s https://raw.githubusercontent.com/<your-username>/<your-repo>/main/latest_version.txt > $TEMP_FILE
    
    LATEST_VERSION=$(head -1 $TEMP_FILE)
    LINKS=$(tail -n +2 $TEMP_FILE)
    rm $TEMP_FILE

    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        echo -e "${GREEN}You already have the latest version ($CURRENT_VERSION)${NC}"
        exit 0
    fi

    echo -e "${YELLOW}New version available: $LATEST_VERSION${NC}"
    echo -e "${YELLOW}Current version: $CURRENT_VERSION${NC}"
    read -p "Do you want to update? [y/N] " answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        install_dependencies
        
        # Create temp directory
        TEMP_DIR=$(mktemp -d)
        
        # Download appropriate package
        case "$(uname -s)" in
            Linux*)  URL=$(echo "$LINKS" | head -1);;
            Darwin*) URL=$(echo "$LINKS" | head -2 | tail -1);;
            CYGWIN*|MINGW*|MSYS*) URL=$(echo "$LINKS" | tail -1);;
            *)       echo -e "${RED}Unsupported OS${NC}"; exit 1;;
        esac

        echo -e "${YELLOW}Downloading update...${NC}"
        curl -L "$URL" -o "$TEMP_DIR/update.zip"
        
        echo -e "${YELLOW}Installing update...${NC}"
        unzip -o "$TEMP_DIR/update.zip" -d "$TEMP_DIR"
        
        # Backup old version
        sudo mv "$INSTALL_DIR/video_viewer" "$INSTALL_DIR/video_viewer.bak"
        
        # Install new version
        sudo cp "$TEMP_DIR/video_viewer" "$INSTALL_DIR/"
        sudo chmod +x "$INSTALL_DIR/video_viewer"
        
        # Cleanup
        rm -rf "$TEMP_DIR"
        echo -e "${GREEN}Update complete!${NC}"
    else
        echo -e "${YELLOW}Update cancelled${NC}"
    fi
}

# Detect installation directory
if [ -f "/usr/local/bin/video_viewer" ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -f "/usr/bin/video_viewer" ]; then
    INSTALL_DIR="/usr/bin"
else
    echo -e "${RED}Could not find video_viewer installation${NC}"
    exit 1
fi

update_app
