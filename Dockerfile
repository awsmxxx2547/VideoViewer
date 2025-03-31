FROM ubuntu:latest

# Update the package list
RUN apt-get update

# Install necessary tools
RUN apt-get install -y build-essential make git wget unzip mingw-w64

# Install SDL2
RUN apt-get install -y libsdl2-dev

WORKDIR /app

COPY . /app

# Download and Build FFmpeg from Source (MinGW)
RUN apt-get install -y autoconf automake libtool pkg-config texinfo # Dependencies
RUN mkdir /tmp/ffmpeg_build && cd /tmp/ffmpeg_build && \
    wget https://ffmpeg.org/releases/ffmpeg-4.4.1.tar.gz && \
    tar xzf ffmpeg-4.4.1.tar.gz && cd ffmpeg-4.4.1 && \
    ./configure \
    --target-os=mingw32 \
    --arch=x86_64 \
    --prefix=/usr/x86_64-w64-mingw32 \
    --enable-cross-compile \
    --enable-shared \
    --disable-static \
    --disable-doc \
    --toolchain=gcc \
    --extra-cflags="-I/usr/x86_64-w64-mingw32/include" \
    --extra-ldflags="-L/usr/x86_64-w64-mingw32/lib" && \
    make -j$(nproc) && \
    make install

# Set up environment variables for cross-compilation.
ENV CC="x86_64-w64-mingw32-gcc"
ENV CXX="x86_64-w64-mingw32-g++"
ENV AR="x86_64-w64-mingw32-ar"
ENV RANLIB="x86_64-w64-mingw32-ranlib"
ENV WINDRES="x86_64-w64-mingw32-windres"

    
