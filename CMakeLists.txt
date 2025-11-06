cmake_minimum_required(VERSION 3.22)
project(AndroidConanHello LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Let users point to the preinstalled Qt (outside Conan) when they need it.
# Example: -DCMAKE_PREFIX_PATH=/opt/qt6-android-arm64

# Conan provides find_package targets via CMakeDeps
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)
find_package(Freetype REQUIRED)
find_package(HarfBuzz REQUIRED)
find_package(LCMS REQUIRED)
find_package(OpenJPEG REQUIRED)
find_package(TIFF REQUIRED)
find_package(JPEG REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(CURL REQUIRED)

# Minimal native target to validate link; not a full Android activity
add_library(conan_aggregate STATIC src/main.cpp)

# Link a representative subset
# (Real app can consume these via target_link_libraries in its own CMake)
target_link_libraries(conan_aggregate PRIVATE
    ZLIB::ZLIB PNG::PNG Freetype::Freetype HarfBuzz::harfbuzz
    LCMS::LCMS OpenJPEG::openjpeg TIFF::TIFF JPEG::JPEG
    OpenSSL::SSL OpenSSL::Crypto CURL::libcurl
)

# Show resolved versions for quick sanity checks
message(STATUS "ZLIB: ${ZLIB_VERSION}")
message(STATUS "PNG: ${PNG_VERSION}")
message(STATUS "Freetype: ${FREETYPE_VERSION_STRING}")
