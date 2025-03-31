      
# Compiler and flags
CC = $(CC)  # Use the CC environment variable (set in Dockerfile)
CXX = $(CXX) # Use the CXX environment variable (set in Dockerfile)
AR = $(AR)
RANLIB = $(RANLIB)
WINDRES = $(WINDRES)
CFLAGS = -Wall -Iinclude -I/usr/x86_64-w64-mingw32/include # Include MinGW path
LDFLAGS = -lSDL2 -lavformat -lavcodec -lavutil -lswscale -lswresample -L/usr/x86_64-w64-mingw32/lib # Added Library path

# Source files
SOURCES = src/main.c src/sdl.c src/video.c

# Executable name
EXECUTABLE = video_viewer.exe

# Build rule
all: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Clean rule
clean:
	rm -f $(EXECUTABLE)

# Windres rule
windres:
	$(WINDRES) resource.rc resource.o

    
