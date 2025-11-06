#!/usr/bin/env bash
set -euo pipefail

# Simple driver to build with Conan 2 for Android arm64-v8a using the
# preinstalled SDK/NDK at /opt/android-sdk and Qt outside Conan if needed.

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build/android-armv8"

mkdir -p "${BUILD_DIR}"

# 1) Detect (or create) a native build profile once, outside of CI.
#    In container, you can run: conan profile detect --force
BUILD_PROFILE="default"
HOST_PROFILE="${PROJECT_DIR}/profiles/host-android-armv8"

# 2) Install dependencies and generate toolchain files
conan install "${PROJECT_DIR}" \
  --profile:build="${BUILD_PROFILE}" \
  --profile:host="${HOST_PROFILE}" \
  -of "${BUILD_DIR}" -b missing

# 3) Configure CMake with the Conan toolchain
cmake -S "${PROJECT_DIR}" -B "${BUILD_DIR}" \
  -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="${BUILD_DIR}/conan_toolchain.cmake" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DANDROID_PLATFORM=android-23 \
  -DANDROID_ABI=arm64-v8a \
  ${EXTRA_CMAKE_ARGS:-}

# If you want to use the preinstalled Qt for your actual app build, add:
#   -DCMAKE_PREFIX_PATH=/opt/qt6-android-arm64

# 4) Build
cmake --build "${BUILD_DIR}" --parallel

# 5) Where deps and toolchain live
echo "Conan output folder: ${BUILD_DIR}"
