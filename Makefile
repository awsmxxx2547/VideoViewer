# ========================
# Build Configuration
# ========================
CC := gcc
CFLAGS := -Wall -Wextra -g -I./include $(VERSION_FLAGS)
L$(VERSION_FLAGS)DFLAGS := -lSDL2 -lavformat -lavcodec -lavutil -lswscale -lswresample -luser32 -lgdi32

VERSION := $(shell cat VERSION)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_HASH := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Version flags
VERSION_FLAGS := -DVERSION="\"$(VERSION)\"" \
                 -DBUILD_DATE="\"$(BUILD_DATE)\"" \
                 -DGIT_HASH="\"$(GIT_HASH)\""

# Platform Detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    INSTALL_DIR := /usr/local/bin
    TARGET := build/bin/video_viewer
endif
ifeq ($(UNAME_S),Darwin)
    INSTALL_DIR := /usr/local/bin
    TARGET := build/bin/video_viewer
endif
ifeq ($(OS),Windows_NT)
    INSTALL_DIR := "C:/Program Files/video_viewer"
    TARGET := build/bin/video_viewer.exe
    LDFLAGS += -static-libgcc
endif

# ========================
# File Paths
# ========================
SRC_DIR 					:= src
BUILD_DIR 					:= build
BIN_DIR 					:= $(BUILD_DIR)/bin
OBJ_DIR 					:= $(BUILD_DIR)/obj
COVERAGE_REPORTS_DIR 		:= coverage_reports
SCRIPTS_DIR 				:= scripts
TEST_DIR 					:= tests
UNIT_TEST_DIR 				:= $(TEST_DIR)/unit
INTEGRATION_TEST_DIR 		:= $(TEST_DIR)/integration
TEST_SAMPLES_DIR 			:= $(INTEGRATION_TEST_DIR)/test_samples

SOURCES 					:= $(wildcard $(SRC_DIR)/*.c)
OBJECTS 					:= $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))
UNIT_TEST_SOURCES 			:= $(wildcard $(UNIT_TEST_DIR)/*.c)
INTEGRATION_TEST_SOURCES 	:= $(wildcard $(INTEGRATION_TEST_DIR)/*.c)

# ========================
# Test Configuration
# ========================
TEST_BIN 					:= $(BIN_DIR)/tests
UNIT_TEST_OBJECTS 			:= $(patsubst $(UNIT_TEST_DIR)/%.c,$(OBJ_DIR)/unit/%.o,$(UNIT_TEST_SOURCES))
INTEGRATION_TEST_OBJECTS 	:= $(patsubst $(INTEGRATION_TEST_DIR)/%.c,$(OBJ_DIR)/integration/%.o,$(INTEGRATION_TEST_SOURCES))

# ========================
# Build Targets
# ========================
.PHONY: all clean install uninstall test help

all: directories $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "🚀 Linking $@..."
	@$(CC) $^ -o $@ $(LDFLAGS)
	@echo "✅ Build successful!"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "🔨 Compiling $<..."
	@$(CC) $(CFLAGS) -c $< -o $@

# ========================
# Installation
# ========================
install: all $(TARGET)
ifeq ($(OS),Windows_NT)
	@echo "🖥️  Installing for Windows..."
	@powershell -Command "New-Item -ItemType Directory -Force -Path '$(INSTALL_DIR)'"
	@copy $(TARGET) "$(INSTALL_DIR)" > NUL
	@echo "💡 Please add '$(INSTALL_DIR)' to your PATH"
else
	@echo "📦 Installing to $(INSTALL_DIR)..."
	@sudo install -d $(INSTALL_DIR)
	@sudo install -m 755 $(TARGET) $(INSTALL_DIR)
	@sudo install -m 755 $(SCRIPTS_DIR)/update.sh $(INSTALL_DIR)/video_viewer-update
	@echo "🎉 Installation complete! Run with: video_viewer"
	@echo "🔔 Update with: video_viewer --update or video_viewer-update"
endif
	@echo "🎉 Installation complete! Run with: video_viewer"

uninstall:
ifeq ($(OS),Windows_NT)
	@echo "🧹 Uninstalling from Windows..."
	@if exist "$(INSTALL_DIR)\video_viewer.exe" ( \
		del "$(INSTALL_DIR)\video_viewer.exe" && \
		echo "✅ Removed $(INSTALL_DIR)\video_viewer.exe" \
	) else ( \
		echo "⚠️  video_viewer.exe not found in $(INSTALL_DIR)" \
	)
else
	@echo "🧹 Uninstalling from $(INSTALL_DIR)..."
	@if [ -f "$(INSTALL_DIR)/video_viewer" ]; then \
		sudo rm -f "$(INSTALL_DIR)/video_viewer" && \
		echo "✅ Removed $(INSTALL_DIR)/video_viewer"; \
	else \
		echo "⚠️  video_viewer not found in $(INSTALL_DIR)"; \
	fi
endif

# ========================
# Test Targets
# ========================
.PHONY: test test-unit test-integration test-coverage test-samples

test: directories test-samples test-unit-add test-integration-add

test-unit: test-samples test-unit-add
test-integration: test-samples test-integration-add

test-unit-add: $(filter-out $(OBJ_DIR)/main.o,$(OBJECTS)) $(UNIT_TEST_OBJECTS) 
	@echo "🧪 Linking unit tests..."
	@$(CC) $^ -o $(TEST_BIN) $(LDFLAGS)
	@echo "🚀 Running unit tests..."
	@./$(TEST_BIN) --unit

test-integration-add: $(filter-out $(OBJ_DIR)/main.o,$(OBJECTS)) $(INTEGRATION_TEST_OBJECTS) 
	@echo "🧪 Linking integration tests..."
	@$(CC) $^ -o $(TEST_BIN) $(LDFLAGS)
	@echo "🚀 Running integration tests..."
	@./$(TEST_BIN) --integration

test-samples:
	@$(SCRIPTS_DIR)/download_test_samples.sh

test-coverage: CFLAGS += --coverage
test-coverage: LDFLAGS += --coverage
test-coverage: clean test
	@echo "📊 Generating coverage report..."
	@gcovr --root . --exclude tests/ --html --html-details -o $(COVERAGE_REPORTS_DIR)/coverage_report.html
	@echo "📄 Coverage report generated: coverage_report.html"

# Test object rules
$(OBJ_DIR)/unit/%.o: $(UNIT_TEST_DIR)/%.c
	@mkdir -p $(@D)
	@echo "🛠️  Building unit test $<..."
	@$(CC) $(CFLAGS) -I$(TEST_DIR) -c $< -o $@

$(OBJ_DIR)/integration/%.o: $(INTEGRATION_TEST_DIR)/%.c
	@mkdir -p $(@D)
	@echo "🛠️  Building integration test $<..."
	@$(CC) $(CFLAGS) -I$(TEST_DIR) -c $< -o $@

# ========================
# Development Utilities
# ========================
directories:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR) $(OBJ_DIR) $(OBJ_DIR)/unit $(OBJ_DIR)/integration $(COVERAGE_REPORTS_DIR)

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf $(BIN_DIR) $(OBJ_DIR)
	@rm -rf $(TEST_SAMPLES_DIR)
	@echo "✨ Project cleaned!"

help:
	@echo "📖 Available targets:"
	@echo "  all       - Build the project (default)"
	@echo "  clean     - Remove build artifacts"
	@echo "  install   - Install system-wide"
	@echo "  uninstall - Remove installed version"
	@echo "  test      - Run test suite"
	@echo "  help      - Show this help message"

# ========================
# Version Management
# ========================

version:
	@echo "Current version: $(VERSION)"
	@echo "Build date: $(BUILD_DATE)"
	@echo "Git hash: $(GIT_HASH)"

bump-version:
	@read -p "Enter new version (current: $(VERSION)): " new_version; \
	echo "$$new_version" > VERSION
	@echo "Version bumped to: $$(cat VERSION)"

release: clean test bump-version
	git commit -am "Bump version to $$(cat VERSION)"
	git tag -a v$$(cat VERSION) -m "Version $$(cat VERSION)"
	@echo "✅ Version $$(cat VERSION) tagged and ready for release"

# ========================
# CI/CD Integration
# ========================
ci-install-deps:
ifeq ($(UNAME_S),Linux)
	@sudo apt-get update
	@sudo apt-get install -y libsdl2-dev libavformat-dev libavcodec-dev libavutil-dev libswscale-dev libswresample-dev
else ifeq ($(UNAME_S),Darwin)
	@brew update
	@brew install sdl2 ffmpeg pkg-config
endif

package:
	@echo "📦 Creating distribution packages..."
	@mkdir -p dist/linux dist/windows dist/macos
	@cp $(TARGET) dist/linux/
	@cp $(TARGET) dist/macos/
	@if [ -f "$(TARGET).exe" ]; then cp "$(TARGET).exe" dist/windows/; fi
	@tar -czvf dist/video_viewer_linux.tar.gz -C dist/linux .
	@tar -czvf dist/video_viewer_macos.tar.gz -C dist/macos .
	@zip -j dist/video_viewer_windows.zip dist/windows/*
	@echo "🎁 Packages created in dist/"
