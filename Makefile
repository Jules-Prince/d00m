# Compiler settings
CXX = clang++
CXXFLAGS = -std=c++17 -Wall -g -Wno-deprecated

# Project structure
SRC_DIR = src
DEPS_DIR = dependencies
BUILD_DIR = out/build
BIN_DIR = out/bin

# Include and library paths
INCLUDES = -I$(DEPS_DIR)/include
LIBRARIES = -L$(DEPS_DIR)/library
LIB_FILES = $(DEPS_DIR)/library/libglfw.3.4.dylib

# Source files (adding .cpp extension explicitly)
CPP_FILES = $(wildcard $(SRC_DIR)/*.cpp)
C_FILES = glad.c

# Object files (maintaining directory structure)
CPP_OBJECTS = $(CPP_FILES:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)
GLAD_OBJECT = $(BUILD_DIR)/glad.o

# All objects
OBJECTS = $(CPP_OBJECTS) $(GLAD_OBJECT)

# macOS specific frameworks
FRAMEWORKS = -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo -framework CoreFoundation

# Output binary
TARGET = $(BIN_DIR)/app

# Main target
all: setup check-sources $(TARGET)

# Create necessary directories
setup:
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(BIN_DIR)

# Check if source files exist
check-sources:
	@if [ -z "$(CPP_FILES)" ]; then \
		echo "Error: No .cpp files found in $(SRC_DIR)"; \
		echo "Current directory contains:"; \
		ls -R; \
		exit 1; \
	fi

# Link the final executable
$(TARGET): $(OBJECTS)
	@echo "Linking target..."
	$(CXX) $(OBJECTS) $(LIBRARIES) $(LIB_FILES) $(FRAMEWORKS) -o $@

# Compile C++ source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@echo "Compiling $<..."
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Compile glad.c separately
$(BUILD_DIR)/glad.o: glad.c
	@echo "Compiling glad.c..."
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# Clean build files
clean:
	rm -rf out

# Run the application
run: $(TARGET)
	./$(TARGET)

# Print variables for debugging
debug:
	@echo "Directory contents:"
	@ls -R
	@echo "\nSource files (.cpp):"
	@echo $(CPP_FILES)
	@echo "\nObject files:"
	@echo $(OBJECTS)
	@echo "\nTarget:"
	@echo $(TARGET)
	@echo "\nCompiler flags:"
	@echo $(CXXFLAGS)
	@echo "\nInclude paths:"
	@echo $(INCLUDES)

.PHONY: all clean setup debug check-sources run