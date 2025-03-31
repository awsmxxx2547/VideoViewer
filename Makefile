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
SCRIPTS_DIR 				:= scripts

SOURCES 					:= $(wildcard $(SRC_DIR)/*.c)
OBJECTS 					:= $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SOURCES))


# ========================
# Test Paths
# ========================
TEST_DIR 					:= tests
UNIT_TEST_DIR 				:= $(TEST_DIR)/unit
INTEGRATION_TEST_DIR 		:= $(TEST_DIR)/integration
TEST_SAMPLES_DIR 			:= $(INTEGRATION_TEST_DIR)/test_samples
COVERAGE_REPORTS_DIR 		:= coverage_reports

UNIT_TEST_SOURCES 			:= $(wildcard $(UNIT_TEST_DIR)/*.c)
INTEGRATION_TEST_SOURCES 	:= $(wildcard $(INTEGRATION_TEST_DIR)/*.c)

TEST_BIN 					:= $(BIN_DIR)/tests
UNIT_TEST_OBJECTS 			:= $(patsubst $(UNIT_TEST_DIR)/%.c,$(OBJ_DIR)/unit/%.o,$(UNIT_TEST_SOURCES))
INTEGRATION_TEST_OBJECTS 	:= $(patsubst $(INTEGRATION_TEST_DIR)/%.c,$(OBJ_DIR)/integration/%.o,$(INTEGRATION_TEST_SOURCES))

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

# ========================
# Test Configuration
# ========================
.PHONY: test t-unit t-integration t-coverage t-samples

test: directories t-samples t-unit-conf t-integration-conf

t-unit: t-samples t-unit-conf

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













