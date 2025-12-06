#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build/android-armv8"

mkdir -p "${BUILD_DIR}"

DEFAULT_POPPLER_SYSROOT="${PROJECT_DIR}/../poppler-android-sysroot"
if [ -z "${SPEEDYNOTE_POPPLER_SYSROOT:-}" ]; then
  SPEEDYNOTE_POPPLER_SYSROOT="${DEFAULT_POPPLER_SYSROOT}"
fi
if [ ! -f "${SPEEDYNOTE_POPPLER_SYSROOT}/lib/pkgconfig/poppler-qt6.pc" ]; then
  echo "[configure] ERROR: Poppler sysroot not found or incomplete at: ${SPEEDYNOTE_POPPLER_SYSROOT}" >&2
  echo "           Please run: ./build-poppler.sh (or set SPEEDYNOTE_POPPLER_SYSROOT to your sysroot)" >&2
  exit 2
fi

export PKG_CONFIG_LIBDIR="${SPEEDYNOTE_POPPLER_SYSROOT}/lib/pkgconfig:${SPEEDYNOTE_POPPLER_SYSROOT}/share/pkgconfig${PKG_CONFIG_LIBDIR:+:${PKG_CONFIG_LIBDIR}}"

cmake --preset conan-debug \
  -D CMAKE_PREFIX_PATH=/opt/qt6-android-arm64 \
  -D QT_HOST_PATH=/opt/qt6-install \
  -D ANDROID_SDK_ROOT=/opt/android-sdk \
  -D ANDROID_NDK_ROOT=/opt/android-sdk/ndk/25.2.9519653 \
  -D SPEEDYNOTE_ENABLE_POPPLER=ON \
  -D SPEEDYNOTE_POPPLER_SYSROOT="${SPEEDYNOTE_POPPLER_SYSROOT}" \
  ${EXTRA_CMAKE_ARGS:-}

echo "[configure] CMake configured with Poppler sysroot: ${SPEEDYNOTE_POPPLER_SYSROOT}"
