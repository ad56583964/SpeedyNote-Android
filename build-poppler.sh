#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
POPLER_SRC_DEFAULT="${PROJECT_DIR}/../poppler"
POPLER_SRC="${POPLER_SRC:-${POPLER_SRC_DEFAULT}}"
BUILD_ROOT="${PROJECT_DIR}/build/android-armv8"
GEN_DIR="${BUILD_ROOT}/build/Debug/generators"
POPLER_BUILD="${PROJECT_DIR}/../poppler-android-build"
POPLER_PREFIX="${PROJECT_DIR}/../poppler-android-sysroot"

if [ ! -d "${POPLER_SRC}" ]; then
  echo "[build-poppler] ERROR: Poppler source dir not found: ${POPLER_SRC}" >&2
  echo "               Set POPLER_SRC=/abs/path/to/poppler" >&2
  exit 2
fi

if [ ! -f "${GEN_DIR}/conan_toolchain.cmake" ]; then
  echo "[build-poppler] ERROR: Conan toolchain not found at: ${GEN_DIR}/conan_toolchain.cmake" >&2
  echo "               Please run: ./conan-install.sh (or 'make in-conan') first." >&2
  exit 2
fi

rm -rf "${POPLER_BUILD}"
mkdir -p "${POPLER_BUILD}" "${POPLER_PREFIX}"

cmake -S "${POPLER_SRC}" -B "${POPLER_BUILD}" \
  -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE="${GEN_DIR}/conan_toolchain.cmake" \
  -DCMAKE_PREFIX_PATH="/opt/qt6-android-arm64;${GEN_DIR}" \
  -DQt6_DIR="/opt/qt6-android-arm64/lib/cmake/Qt6" \
  -DCMAKE_FIND_ROOT_PATH="${POPLER_PREFIX};/opt/qt6-android-arm64;${GEN_DIR}" \
  -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX="${POPLER_PREFIX}" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-23 \
  -DANDROID_STL=c++_shared \
  -DBUILD_SHARED_LIBS=OFF \
  -DENABLE_QT5=OFF \
  -DENABLE_QT6=ON \
  -DENABLE_GLIB=OFF \
  -DENABLE_UTILS=OFF \
  -DENABLE_CPP=OFF \
  -DENABLE_BOOST=OFF \
  -DENABLE_GPGME=OFF \
  -DENABLE_NSS3=OFF \
  -DENABLE_LIBOPENJPEG=openjpeg2 \
  -DENABLE_LIBCURL=ON \
  -DENABLE_LIBTIFF=ON \
  -DENABLE_LCMS=ON \
  -DENABLE_ZLIB_UNCOMPRESS=OFF \
  -DRUN_GPERF_IF_PRESENT=OFF \
  -DBUILD_GTK_TESTS=OFF \
  -DBUILD_CPP_TESTS=OFF \
  -DBUILD_QT6_TESTS=OFF \
  -DBUILD_MANUAL_TESTS=OFF \
  -DWITH_FONTCONFIGURATION_WIN32=OFF \
  -DWITH_FONTCONFIGURATION_FONTCONFIG=OFF \
  -DWITH_FONTCONFIGURATION_ANDROID=ON \
  -DFreetype_DIR="${GEN_DIR}/Freetype"

cmake --build "${POPLER_BUILD}" --parallel
cmake --install "${POPLER_BUILD}"

echo "[build-poppler] Installed Poppler to: ${POPLER_PREFIX}"
