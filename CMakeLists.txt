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
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Widgets)

qt_add_executable(QtHello
    src/qt_main.cpp
)

target_link_libraries(QtHello PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets)

# Optional: provide package sources (AndroidManifest.xml etc.) if you have any under android/ dir
# set_property(TARGET QtHello PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android")

# Ensure we build position-independent code for shared libs
set_target_properties(QtHello PROPERTIES POSITION_INDEPENDENT_CODE ON)
