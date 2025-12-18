#!/bin/bash

# Build script for libcamera-shim using Yocto SDK (32-bit ARM)
# Target: cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build_arm32"
TOOLCHAIN_FILE="${SCRIPT_DIR}/toolchain-yocto-arm32.cmake"
SDK_ENV="/opt/poky/5.0.14/environment-setup-cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi"

echo "=========================================="
echo "Building libcamera-shim for 32-bit ARM"
echo "=========================================="

# Check if SDK environment setup script exists
if [ ! -f "$SDK_ENV" ]; then
    echo "ERROR: SDK environment setup script not found at: $SDK_ENV"
    echo "Please ensure the Yocto SDK is installed correctly."
    exit 1
fi

# Source the Yocto SDK environment
echo "Sourcing Yocto SDK environment..."
source "$SDK_ENV"

# Verify toolchain is available
if [ -z "$CC" ] || [ -z "$CXX" ]; then
    echo "ERROR: Compiler environment variables not set after sourcing SDK"
    exit 1
fi

echo "Using compiler: $CC"
echo "Using C++ compiler: $CXX"
echo "Target sysroot: $SDKTARGETSYSROOT"

# Clean previous build if requested
if [ "$1" == "clean" ]; then
    echo "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Create build directory
mkdir -p "$BUILD_DIR"

# Configure with CMake
echo ""
echo "Configuring CMake..."
cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$BUILD_DIR/install" \
    -G "Ninja"

# Build
echo ""
echo "Building..."
cmake --build "$BUILD_DIR" -j$(nproc)

# Install
echo ""
echo "Installing..."
cmake --install "$BUILD_DIR"

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo "Output location: $BUILD_DIR"
echo "Library: $BUILD_DIR/install/lib/libcamera-shim.so"
echo "=========================================="
