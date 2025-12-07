cmake_minimum_required(VERSION 3.22)
project(AndroidConanHello LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Let users point to the preinstalled Qt (outside Conan) when they need it.
message(STATUS "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")

# Conan CMakeDeps emitted the following recommendations for find_package() names
find_package(harfbuzz REQUIRED)
find_package(Freetype REQUIRED)
find_package(PNG REQUIRED)
find_package(lcms REQUIRED)
find_package(OpenJPEG REQUIRED)
find_package(TIFF REQUIRED)
find_package(libjpeg-turbo REQUIRED)
find_package(CURL REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(ZLIB REQUIRED)

# Minimal native target to validate link; not a full Android activity
add_library(conan_aggregate STATIC src/main.cpp)

# Link a representative subset
# (Real app can consume these via target_link_libraries in its own CMake)
target_link_libraries(conan_aggregate PRIVATE
    harfbuzz::harfbuzz Freetype::Freetype PNG::PNG lcms::lcms
    openjp2 TIFF::TIFF libjpeg-turbo::libjpeg-turbo
    CURL::libcurl openssl::openssl ZLIB::ZLIB
)

# Show resolved versions for quick sanity checks
# Version printouts omitted; variables differ between config packages and modules.

# ---------------------------
# Qt Widgets Hello (Android)
# ---------------------------
option(ANDROID_CONAN_ENABLE_QTHELLO "Build QtHello example" OFF)
if(ANDROID_CONAN_ENABLE_QTHELLO)
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Widgets)

qt_add_executable(QtHello
    src/qt_main.cpp
)

target_link_libraries(QtHello PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets)

# Optional: provide package sources (AndroidManifest.xml etc.) if you have any under android/ dir
# set_property(TARGET QtHello PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android")

# Ensure we build position-independent code for shared libs
set_target_properties(QtHello PROPERTIES POSITION_INDEPENDENT_CODE ON)
endif()

# ---------------------------
# SpeedyNote (Qt Widgets) — Poppler REQUIRED
# ---------------------------
# This build requires Poppler (Qt6) from an external Android sysroot.
# Provide it via -D SPEEDYNOTE_POPPLER_SYSROOT=/absolute/path or
# environment variable SPEEDYNOTE_POPPLER_SYSROOT. Build will fail if missing.

set(SPEEDYNOTE_SRC_DIR "${SPEEDYNOTE_SRC_DIR}" CACHE PATH "SpeedyNote source dir")
if(SPEEDYNOTE_SRC_DIR)
    set(SPEEDYNOTE_SRC "${SPEEDYNOTE_SRC_DIR}")
else()
    # 仅使用当前仓库中的 SpeedyNote 子目录（例如通过 make speedynote-clone 获取）
    get_filename_component(SPEEDYNOTE_SRC "${CMAKE_CURRENT_SOURCE_DIR}/SpeedyNote" ABSOLUTE)
endif()

if(NOT EXISTS "${SPEEDYNOTE_SRC}/CMakeLists.txt")
    message(FATAL_ERROR "SpeedyNote source not found at: '${SPEEDYNOTE_SRC}'. Clone it via 'make speedynote-clone' or set SPEEDYNOTE_SRC_DIR to an existing checkout.")
endif()

message(STATUS "Including SpeedyNote from: ${SPEEDYNOTE_SRC}")

# Force Poppler usage
set(SPEEDYNOTE_ENABLE_POPPLER ON CACHE BOOL "" FORCE)
set(SPEEDYNOTE_ENABLE_SDL OFF CACHE BOOL "" )
set(SPEEDYNOTE_ENABLE_AUDIO OFF CACHE BOOL "" )

# Resolve Poppler sysroot
if(NOT SPEEDYNOTE_POPPLER_SYSROOT AND DEFINED ENV{SPEEDYNOTE_POPPLER_SYSROOT})
    set(SPEEDYNOTE_POPPLER_SYSROOT "$ENV{SPEEDYNOTE_POPPLER_SYSROOT}")
endif()
if(NOT SPEEDYNOTE_POPPLER_SYSROOT)
    # Default to sibling folder in build space
    set(SPEEDYNOTE_POPPLER_SYSROOT "${CMAKE_CURRENT_LIST_DIR}/../poppler-android-sysroot")
endif()
if(NOT EXISTS "${SPEEDYNOTE_POPPLER_SYSROOT}")
    message(FATAL_ERROR "Poppler sysroot not found: '${SPEEDYNOTE_POPPLER_SYSROOT}'. Set -D SPEEDYNOTE_POPPLER_SYSROOT=/path or env SPEEDYNOTE_POPPLER_SYSROOT.")
endif()

# Surface for child project
set(SPEEDYNOTE_POPPLER_SYSROOT "${SPEEDYNOTE_POPPLER_SYSROOT}" CACHE PATH "" FORCE)

add_subdirectory("${SPEEDYNOTE_SRC}" "${CMAKE_BINARY_DIR}/SpeedyNote")
