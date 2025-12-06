#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build/android-armv8"
BUILD_PROFILE="${BUILD_PROFILE:-default}"
HOST_PROFILE="${PROJECT_DIR}/profiles/host-android-armv8"

mkdir -p "${BUILD_DIR}"

if ! conan profile list | awk '{print $1}' | grep -qx "${BUILD_PROFILE}"; then
  echo "[conan-install] Conan build profile '${BUILD_PROFILE}' not found; detecting default profile..." >&2
  conan profile detect --force
fi

conan install "${PROJECT_DIR}" \
  --profile:build="${BUILD_PROFILE}" \
  --profile:host="${HOST_PROFILE}" \
  -c tools.build:skip_test=True \
  -of "${BUILD_DIR}" -b missing

echo "[conan-install] Done. Toolchain at: ${BUILD_DIR}/build/Debug/generators"
