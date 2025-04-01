FROM ubuntu:latest

# Update the package list
RUN apt-get update

# Install necessary tools
RUN apt-get install -y build-essential make git wget unzip

## Install FFmpeg and its development headers (adjust version as needed)
RUN apt-get install -y libavformat-dev libavcodec-dev libavutil-dev libswscale-dev libswresample-dev

# Install SDL2
RUN apt-get install -y libsdl2-dev

WORKDIR /app

COPY . /app

RUN make
