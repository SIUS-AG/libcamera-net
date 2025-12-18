# CMake Toolchain file for Yocto SDK - 32-bit ARM (cortex-a7)
# Generated for cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi target

# Set the target system
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Skip the compiler test to avoid ABI detection issues with cross-compilation
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Extract compiler and flags from CC/CXX environment variables
# Format: "compiler [flags] --sysroot=..."
string(REGEX MATCH "^([^ ]+)" YOCTO_C_COMPILER "$ENV{CC}")
string(REGEX MATCH "^([^ ]+)" YOCTO_CXX_COMPILER "$ENV{CXX}")

# Extract all flags after the compiler name
string(REGEX REPLACE "^[^ ]+ *(.*)" "\\1" YOCTO_C_FLAGS "$ENV{CC}")
string(REGEX REPLACE "^[^ ]+ *(.*)" "\\1" YOCTO_CXX_FLAGS "$ENV{CXX}")

# Specify the cross compiler
set(CMAKE_C_COMPILER ${YOCTO_C_COMPILER})
set(CMAKE_CXX_COMPILER ${YOCTO_CXX_COMPILER})

# Specify the sysroot
set(CMAKE_SYSROOT $ENV{SDKTARGETSYSROOT})
set(CMAKE_FIND_ROOT_PATH $ENV{SDKTARGETSYSROOT})

# Compiler flags from Yocto - combine extracted flags with additional CFLAGS/CXXFLAGS
set(CMAKE_C_FLAGS_INIT "${YOCTO_C_FLAGS} $ENV{CFLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${YOCTO_CXX_FLAGS} $ENV{CXXFLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "$ENV{LDFLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "$ENV{LDFLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "$ENV{LDFLAGS}")

# Also set as CACHE variables for later use
set(CMAKE_C_FLAGS "${YOCTO_C_FLAGS} $ENV{CFLAGS}" CACHE STRING "CFLAGS" FORCE)
set(CMAKE_CXX_FLAGS "${YOCTO_CXX_FLAGS} $ENV{CXXFLAGS}" CACHE STRING "CXXFLAGS" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "$ENV{LDFLAGS}" CACHE STRING "LDFLAGS" FORCE)
set(CMAKE_SHARED_LINKER_FLAGS "$ENV{LDFLAGS}" CACHE STRING "LDFLAGS" FORCE)

# Search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Additional paths for pkg-config
set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "$ENV{SDKTARGETSYSROOT}")

# Set rpath settings
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
