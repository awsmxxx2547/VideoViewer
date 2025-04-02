# ========================
# Build Configuration
# ========================
APP_NAME := video_viewer
PLATFORM:= $(shell uname -s)

CC:= gcc
CFLAGS:= -Wall -Wextra -g -I./include $(shell pkg-config --cflags libavformat libavcodec libavutil libswscale libswresample sdl2)
LDFLAGS:=$(shell pkg-config --libs libavformat libavcodec libavutil libswscale libswresample sdl2)

ifeq ($(PLATFORM), Windows)
	INSTALL_DIR:= "C:/Program Files/VideoViewer"
	TARGET:= build/bin/$(APP_NAME).exe
	LDFLAGS+=-static-libgcc
else
	INSTALL_DIR:= /usr/local/bin
	TARGET:= build/bin/$(APP_NAME)
endif

# ========================
# File Paths
# ========================
SRC_DIR:= src
BUILD_DIR:= build
BIN_DIR:= $(BUILD_DIR)/bin
OBJ_DIR:= $(BUILD_DIR)/obj
SCRIPTS_DIR:= scripts

SOURCES:= $(wildcard $(SRC_DIR)/*.c)
OBJECTS:= $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))

# ========================
# Test Paths
# ========================
TEST_DIR:= tests
TEST_BIN:= $(BIN_DIR)/tests
UNIT_TEST_DIR:= $(TEST_DIR)/unit
INTEGRATION_TEST_DIR:= $(TEST_DIR)/integration
TEST_SAMPLES_DIR:= $(INTEGRATION_TEST_DIR)/test_samples
COVERAGE_REPORTS_DIR:= coverage_reports

UNIT_TEST_SOURCES:= $(wildcard $(UNIT_TEST_DIR)/*.c)
INTEGRATION_TEST_SOURCES:= $(wildcard $(INTEGRATION_TEST_DIR)/*.c)

UNIT_TEST_OBJECTS:= $(patsubst $(UNIT_TEST_DIR)/%.c,$(OBJ_DIR)/unit/%.o,$(UNIT_TEST_SOURCES))
INTEGRATION_TEST_OBJECTS:= $(patsubst $(INTEGRATION_TEST_DIR)/%.c,$(OBJ_DIR)/integration/%.o,$(INTEGRATION_TEST_SOURCES))

# ========================
# Build Targets
# ========================
.PHONY: all clean install uninstall help test

all: directories $(TARGET)

$(TARGET): $(OBJECTS)
	@echo "Starting build process..."
	$(CC) $^ -o $@ $(LDFLAGS)
	@echo "Build successful!"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

# ========================
# Development Utilities
# ========================
directories:
	@mkdir -p $(BUILD_DIR) $(BIN_DIR) $(OBJ_DIR) $(OBJ_DIR)/unit $(OBJ_DIR)/integration $(COVERAGE_REPORTS_DIR)

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BIN_DIR) $(OBJ_DIR)
	@rm -rf $(TEST_SAMPLES_DIR)
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
	@$(SCRIPTS_DIR)/uninstall

# ========================
# Test Configuration
# ========================
.PHONY: test t-unit t-integration t-coverage t-samples

test: directories t-samples t-unit-conf t-integration-conf

t-unit: t-samples t-unit-conf
t-integration: t-samples t-integration-conf

t-unit-conf: $(filter-out $(OBJ_DIR)/main.o,$(OBJECTS)) $(UNIT_TEST_OBJECTS)
	@echo "Linking unit tests..."
	@$(CC) $^ -o $(TEST_BIN) $(LDFLAGS)
	@echo "Running unit tests..."
	@./$(TEST_BIN) --unit

t-integration-conf: $(filter-out $(OBJ_DIR)/main.o,$(OBJECTS)) $(INTEGRATION_TEST_OBJECTS)
	@echo "Linking integration tests..."
	@$(CC) $^ -o $(TEST_BIN) $(LDFLAGS)
	@echo "Running integration tests..."
	@./$(TEST_BIN) --integration

t-samples:
	@$(SCRIPTS_DIR)/download_test_samples.sh

$(OBJ_DIR)/unit/%.o: $(UNIT_TEST_DIR)/%.c
	@mkdir -p $(@D)
	@echo "🛠️  Building unit test $<..."
	@$(CC) $(CFLAGS) -I$(TEST_DIR) -c $< -o $@

$(OBJ_DIR)/integration/%.o: $(INTEGRATION_TEST_DIR)/%.c
	@mkdir -p $(@D)
	@echo "🛠️  Building integration test $<..."
	@$(CC) $(CFLAGS) -I$(TEST_DIR) -c $< -o $@

t-coverage: CFLAGS += --coverage
t-coverage: LDFLAGS += --coverage
t-coverage: clean test
	@echo "📊 Generating coverage report..."
	@gcovr --root . --exclude tests/ --html --html-details -o $(COVERAGE_REPORTS_DIR)/coverage_report.html
	@echo "📄 Coverage report generated: coverage_report.html"

# ========================
# Release
# ========================
.PHONY: version version-major version-minor version-patch

VERSION_FILE := VERSION

# MAJOR.MINOR.PATCH -- semantic versioning

# Default version bump (patch)
version: version-patch

# Bump major version
version-major:
	@./scripts/bump_version.sh major

# Bump minor version
version-minor:
	@./scripts/bump_version.sh minor

# Bump patch version
version-patch:
	@./scripts/bump_version.sh patch

# Show current version
current-version:
	@if [ -f $(VERSION_FILE) ]; then \
		echo "Current version: $$(cat $(VERSION_FILE))"; \
	else \
		echo "VERSION file not found. Run 'make version' to create it."; \
	fi
