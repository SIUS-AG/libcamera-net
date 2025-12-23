.PHONY: help build build-x64 build-arm64 build-arm32 build-all pack pack-x64 pack-arm64 pack-arm32 pack-all clean run-remote analyze-arm32

# Configuration
PROJECT := Bld.LibcameraNet/Bld.LibcameraNet.csproj
EXAMPLE_PROJECT := examples/Bld.LibcameraNet.Example/Bld.LibcameraNet.Example.csproj
ARM32_SDK_ENV := /opt/poky/5.0.14/environment-setup-cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi
ARM32_TOOLCHAIN := toolchain-yocto-arm32.cmake
ARM32_GENERATOR := Ninja
NATIVE_OUTPUT ?= src/Bld.LibcameraNet/runtimes/linux-arm/native/

# Load environment from .env if it exists
-include .env
export

# Remote deployment configuration
REMOTE_HOST ?= $(word 2,$(subst @, ,$(HOST)))
REMOTE_USER ?= $(word 1,$(subst @, ,$(HOST)))
REMOTE_DIR := /tmp/libcamera-example

help:
	@echo "libcamera-net build targets:"
	@echo ""
	@echo "  build         - Build for current platform (auto-detected)"
	@echo "  build-x64     - Build for linux-x64"
	@echo "  build-arm64   - Build for linux-arm64"
	@echo "  build-arm32   - Build for linux-arm (32-bit) using Yocto SDK"
	@echo "  build-all     - Build for all platforms (x64, arm64, arm32)"
	@echo ""
	@echo "  pack-x64      - Create NuGet package for linux-x64 only"
	@echo "  pack-arm64    - Create NuGet package for linux-arm64 only"
	@echo "  pack-arm32    - Create NuGet package for linux-arm only"
	@echo "  pack-all      - Create separate NuGet packages for each runtime"
	@echo "  pack          - Create single NuGet package with all runtimes"
	@echo ""
	@echo "  run-remote    - Build ARM32 example and run on remote device"
	@echo "                  Set REMOTE_HOST env var"
	@echo "  analyze-arm32 - Analyze ARM32 native library dependencies"
	@echo ""
	@echo ""
	@echo "  clean         - Clean build artifacts"
	@echo ""

build:
	@echo "Building for current platform..."
	cd src && dotnet build $(PROJECT)

build-x64:
	@echo "Building for linux-x64..."
	cd src && dotnet build $(PROJECT) \
		/p:NativeTargetRuntimeId=linux-x64

build-arm64:
	@echo "Building for linux-arm64..."
	cd src && dotnet build $(PROJECT) \
		/p:NativeTargetRuntimeId=linux-arm64

build-arm32:
	@echo "Building for linux-arm (32-bit) with Yocto SDK..."
	@if [ ! -f "$(ARM32_SDK_ENV)" ]; then \
		echo "ERROR: Yocto SDK not found at $(ARM32_SDK_ENV)"; \
		echo "Please install the SDK or update ARM32_SDK_ENV in Makefile"; \
		exit 1; \
	fi
	cd src && dotnet build $(PROJECT) \
		/p:NativeTargetRuntimeId=linux-arm \
		/p:NativeSdkEnv="$(ARM32_SDK_ENV)" \
		/p:NativeCrossToolchain="$(ARM32_TOOLCHAIN)" \
		/p:NativeBuildGenerator="$(ARM32_GENERATOR)"

build-all: build-x64 build-arm64 build-arm32
	@echo ""
	@echo "All platforms built successfully!"
	@echo "Available runtimes:"
	@ls -1d src/Bld.LibcameraNet/runtimes/*/native 2>/dev/null || true

pack-x64: build-x64
	@echo "Creating NuGet package for linux-x64..."
	@rm -rf src/Bld.LibcameraNet/runtimes/linux-arm src/Bld.LibcameraNet/runtimes/linux-arm64
	cd src && dotnet pack $(PROJECT) -c Debug -o ../packages /p:PackageVersion=$$(grep '<VersionPrefix>' $(PROJECT) | sed 's/.*<VersionPrefix>\(.*\)<\/VersionPrefix>.*/\1/')-linux-x64
	@echo "Package created: packages/Bld.LibcameraNet.*-linux-x64.nupkg"

pack-arm64: build-arm64
	@echo "Creating NuGet package for linux-arm64..."
	@rm -rf src/Bld.LibcameraNet/runtimes/linux-arm src/Bld.LibcameraNet/runtimes/linux-x64
	cd src && dotnet pack $(PROJECT) -c Debug -o ../packages /p:PackageVersion=$$(grep '<VersionPrefix>' $(PROJECT) | sed 's/.*<VersionPrefix>\(.*\)<\/VersionPrefix>.*/\1/')-linux-arm64
	@echo "Package created: packages/Bld.LibcameraNet.*-linux-arm64.nupkg"

pack-arm32: build-arm32
	@echo "Creating NuGet package for linux-arm..."
	@rm -rf src/Bld.LibcameraNet/runtimes/linux-arm64 src/Bld.LibcameraNet/runtimes/linux-x64
	cd src && dotnet pack $(PROJECT) -c Debug -o ../packages /p:PackageVersion=$$(grep '<VersionPrefix>' $(PROJECT) | sed 's/.*<VersionPrefix>\(.*\)<\/VersionPrefix>.*/\1/')-linux-arm
	@echo "Package created: packages/Bld.LibcameraNet.*-linux-arm.nupkg"

pack-all: clean
	@echo "Creating separate packages for all runtimes..."
	@mkdir -p packages
	@$(MAKE) pack-x64
	@$(MAKE) pack-arm64
	@$(MAKE) pack-arm32
	@echo ""
	@echo "All packages created in packages/:"
	@ls -lh packages/*.nupkg

pack: build-all
	@echo "Creating single NuGet package with all runtimes..."
	@mkdir -p packages
	cd src && dotnet pack $(PROJECT) -c Debug -o ../packages
	@echo ""
	@echo "Package contents:"
	@unzip -l packages/Bld.LibcameraNet.*.nupkg | grep -E "runtimes.*libcamera-shim" || true
	@echo ""
	@echo "Package created in packages/"

clean:
	@echo "Cleaning build artifacts..."
	cd src && dotnet clean $(PROJECT)
	rm -rf src/Bld.LibcameraNet/bin
	rm -rf src/Bld.LibcameraNet/obj
	rm -rf src/Bld.LibcameraNet/runtimes
	rm -rf src/libcamera-shim/build_*
	rm -rf packages
	@echo "Clean complete!"

run-remote: build-arm32
	@echo "Building ARM32 example..."
	@rm -rf src/Bld.LibcameraNet/runtimes/linux-x64 src/Bld.LibcameraNet/runtimes/linux-arm64
	cd src && dotnet publish $(EXAMPLE_PROJECT) -c Release -r linux-arm --self-contained -o ../build/arm32-example
	@echo ""
	@echo "Copying to remote device $(REMOTE_USER)@$(REMOTE_HOST)..."
	scp -r build/arm32-example $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DIR)
	@if [ -d "bin/arm32-example" ]; then \
		echo "Copying additional files from bin/arm32-example..."; \
		scp -r bin/arm32-example/* $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DIR); \
	fi
	@echo ""
	@echo "Running example on remote device..."
	ssh $(REMOTE_USER)@$(REMOTE_HOST) "cd $(REMOTE_DIR) && ./Bld.LibcameraNet.Example"

analyze-arm32: build-arm32
	@echo "=========================================="
	@echo "Analyzing ARM32 native library dependencies"
	@echo "=========================================="
	@echo ""
	@echo "Native library location:"
	@ls -lh $(NATIVE_OUTPUT)libcamera-shim.so.0.3.2
	@echo ""
	@echo "Library information:"
	@file $(NATIVE_OUTPUT)libcamera-shim.so.0.3.2
	@echo ""
	@echo "Required shared libraries (from build host):"
	@if [ -f "$(ARM32_SDK_ENV)" ]; then \
		bash -c "source $(ARM32_SDK_ENV) && \$$READELF -d $(NATIVE_OUTPUT)libcamera-shim.so.0.3.2 | grep NEEDED"; \
	else \
		readelf -d $(NATIVE_OUTPUT)libcamera-shim.so.0.3.2 | grep NEEDED; \
	fi
	@echo ""
	@echo "Symbol table summary:"
	@nm -D $(NATIVE_OUTPUT)libcamera-shim.so.0.3.2 | grep -E "^[0-9a-f]+ [TW]" | wc -l | xargs echo "  Exported functions:"
	@nm -D $(NATIVE_OUTPUT)libcamera-shim.so.0.3.2 | grep -E "U " | wc -l | xargs echo "  Undefined symbols:"
	@echo ""
	@echo "Checking dependencies on remote device $(REMOTE_USER)@$(REMOTE_HOST):"
	@echo "Copying library to remote device for analysis..."
	@scp -q $(NATIVE_OUTPUT)libcamera-shim.so.0.3.2 $(REMOTE_USER)@$(REMOTE_HOST):/tmp/
	@echo ""
	@echo "Running dependency check on remote device:"
	@if ssh $(REMOTE_USER)@$(REMOTE_HOST) "command -v ldd >/dev/null 2>&1"; then \
		ssh $(REMOTE_USER)@$(REMOTE_HOST) "ldd /tmp/libcamera-shim.so.0.3.2"; \
		echo ""; \
		echo "Missing dependencies:"; \
		ssh $(REMOTE_USER)@$(REMOTE_HOST) "ldd /tmp/libcamera-shim.so.0.3.2 2>&1 | grep 'not found'" || echo "  All dependencies found!"; \
	else \
		echo "  ldd not available on remote device"; \
		echo "  Checking if required libraries exist:"; \
		ssh $(REMOTE_USER)@$(REMOTE_HOST) "for lib in libcamera.so.0.4 libcamera-base.so.0.4 libstdc++.so.6 libgcc_s.so.1 libc.so.6; do \
			if ldconfig -p 2>/dev/null | grep -q \$$lib || find /usr/lib /lib -name \$$lib 2>/dev/null | grep -q .; then \
				echo \"  ✓ \$$lib found\"; \
			else \
				echo \"  ✗ \$$lib NOT FOUND\"; \
			fi; \
		done"; \
	fi
	@echo ""
	@echo "=========================================="

