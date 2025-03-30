FROM ubuntu:latest

# Update the package list
RUN apt-get update

# Install necessary tools
RUN apt-get install -y build-essential make git wget unzip

# Install MinGW for Windows cross-compilation
RUN apt-get install -y mingw-w64

## Install FFmpeg and its development headers (adjust version as needed)
RUN apt-get install -y libavformat-dev libavcodec-dev libavutil-dev libswscale-dev libswresample-dev

# Install SDL2
RUN apt-get install -y libsdl2-dev

WORKDIR /app

COPY . /app

# Set up environment variables for cross-compilation.
ENV CC      = "x86_64-w64-mingw32-gcc"
ENV CXX     = "x86_64-w64-mingw32-g++"
ENV AR      = "x86_64-w64-mingw32-ar"
ENV RANLIB  = "x86_64-w64-mingw32-ranlib"
ENV WINDRES = "x86_64-w64-mingw32-windres"

# Build the image.
# docker build -t my-c-project .
