# ========================
# Build Configuration
# ========================
CC := $(CC)
CXX := $(CXX)
AR := $(AR)
RANLIB := $(RANLIB)
WINDRES := $(WINDRES)
CFLAGS := -Wall -Iinclude -I/usr/include/
LDFLAGS := -lSDL2 -lavformat -lavcodec -lavutil -lswscale -lswresample

# Source files
SOURCES = src/*

# Executable name
EXECUTABLE = video_viewer.exe

# Build rule 
all: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Clean rule
clean:
	rm -f $(EXECUTABLE)

#Windres rule
windres:
	$(WINDRES) resource.rc resource.o

# Example of including resource files
# 	$(CC) $(CFLAGS) -o $@ $^ resource.o $(LDFLAGS)
