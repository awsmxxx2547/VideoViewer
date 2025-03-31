# ========================
# Build Configuration
# ========================
APP_NAME 					:= video_viewer

CC 							:= gcc
CFLAGS 						:= -Wall -Wextra -g -Iinclude 
LDFLAGS 					:= -lSDL2 -lavformat -lavcodec -lavutil -lswscale -lswresample

INSTALL_DIR 				:= /usr/local/bin
TARGET 						:= build/bin/$(APP_NAME)

# ========================
# File Paths
# ========================
SRC_DIR 					:= src
BUILD_DIR 					:= build
BIN_DIR 					:= $(BUILD_DIR)/bin
OBJ_DIR 					:= $(BUILD_DIR)/obj

SOURCES 					:= $(wildcard $(SRC_DIR)/*.c)
OBJECTS 					:= $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))

# ========================
# Build Targets
# ========================
.PHONY: all clean install uninstall help

all: directories $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "Starting build process..."
	@$(CC) $^ -o $@ $(LDFLAGS)
	@echo "Build successful!"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "Compiling $<..."
	@$(CC) $(CFLAGS) -c $< -o $@

# ========================
# Development Utilities
# ========================
directories:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR) $(OBJ_DIR)

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BIN_DIR) $(OBJ_DIR)
	@echo "Project cleaned!"

help:
	@echo "📖 Available targets:"
	@echo "  all       - Build the project (default)"
	@echo "  clean     - Remove build artifacts"
	@echo "  install   - Install system-wide"
	@echo "  uninstall - Remove installed version"
	@echo "  test      - Run test suite"
	@echo "  help      - Show this help message"

# ========================
# Installation
# ========================
install: all $(TARGET)
	@echo "Installing to $(INSTALL_DIR)..."
	@sudo install -d $(INSTALL_DIR)
	@sudo install -m 755 $(TARGET) $(INSTALL_DIR)
	@echo "Installation complete! Run with: video_viewer"

uninstall:
	@echo "Uninstalling from $(INSTALL_DIR)..."
	@if [ -f "$(INSTALL_DIR)/video_viewer" ]; then \
		sudo rm -f "$(INSTALL_DIR)/video_viewer" && \
		echo "✅ Removed $(INSTALL_DIR)/video_viewer"; \
	else \
		echo "⚠️  video_viewer not found in $(INSTALL_DIR)"; \
	fi
