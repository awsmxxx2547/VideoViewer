#!/bin/bash

if command -v sudo &>/dev/null; then
    SUDO="sudo"
else
    SUDO=""
fi

install_dependencies() {
    echo -e "Installing dependencies..."

    $SUDO apt-get update && $SUDO apt-get install -y \
        ffmpeg \
        curl unzip \
        libsdl2-dev \
        libavformat-dev \
        libavcodec-dev \
        libavutil-dev \
        libswscale-dev \
        libswresample-dev
    echo -e "Installation complete!!!"
    }

install_dependencies
