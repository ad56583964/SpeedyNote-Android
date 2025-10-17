FROM demo-android-env:0.0.1

ARG ANDROID_NDK_ROOT=/opt/android-sdk/ndk/25.2.9519653
ARG ANDROID_API=23
ARG TARGET_TRIPLE=aarch64-linux-android
ARG ANDROID_ABI=arm64-v8a
ARG INSTALL_PREFIX=/opt/third-party/sysroot
ARG LIBJPEG_REF=1.1.0
ARG ZLIB_VERSION=1.3.1
ARG LIBPNG_VERSION=1.6.43
ARG FREETYPE_VERSION=2.13.2
ARG HARFBUZZ_VERSION=9.0.0
ARG LCMS2_VERSION=2.16
ARG OPENJPEG_VERSION=2.5.2
ARG LIBTIFF_VERSION=4.6.0
ARG LIBCURL_VERSION=8.10.1
ARG OPENSSL_VERSION=3.2.2
ARG QT6_ANDROID_PREFIX=/opt/qt6-android-arm64
ARG POPPLER_REF=poppler-24.02.0

ENV ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}
ENV NDK_ROOT=${ANDROID_NDK_ROOT}
ENV ANDROID_API=${ANDROID_API}
ENV TARGET_TRIPLE=${TARGET_TRIPLE}
ENV ANDROID_ABI=${ANDROID_ABI}
ENV INSTALL_PREFIX=${INSTALL_PREFIX}

ENV TOOLCHAIN_DIR=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64
ENV TOOLCHAIN_BIN=${TOOLCHAIN_DIR}/bin
ENV PATH=${TOOLCHAIN_BIN}:${PATH}
ENV QT6_ANDROID_PREFIX=${QT6_ANDROID_PREFIX}
ENV POPPLER_SRC=/opt/third-party/poppler
ENV POPPLER_BUILD_DIR=/opt/third-party/build/poppler

RUN mkdir -p /opt/third-party
WORKDIR /opt/third-party

COPY harfbuzz-crossfile.ini /opt/third-party/config/harfbuzz-crossfile.ini

RUN git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git \
    --branch ${LIBJPEG_REF} \
    --depth 1

RUN git clone https://gitlab.freedesktop.org/poppler/poppler.git \
    --branch ${POPPLER_REF} \
    --depth 1 \
    "${POPPLER_SRC}"

RUN apt-get update && \
    apt-get install -y autoconf automake libtool pkg-config cmake ninja-build meson python3 curl xz-utils gettext-base && \
    rm -rf /var/lib/apt/lists/*

ENV LIBJPEG_SRC=/opt/third-party/libjpeg-turbo
ENV LIBJPEG_BUILD_DIR=/opt/third-party/build/libjpeg-turbo-android

ENV CC=${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang
ENV CXX=${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang++
ENV AR=${TOOLCHAIN_BIN}/llvm-ar
ENV AS=${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang
ENV LD=${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang
ENV RANLIB=${TOOLCHAIN_BIN}/llvm-ranlib
ENV STRIP=${TOOLCHAIN_BIN}/llvm-strip
ENV CFLAGS=-fPIC
ENV LDFLAGS=
ENV CPPFLAGS=
ENV PKG_CONFIG_SYSROOT_DIR=${INSTALL_PREFIX}
ENV PKG_CONFIG_LIBDIR=${INSTALL_PREFIX}/lib/pkgconfig:${INSTALL_PREFIX}/share/pkgconfig
ENV PKG_CONFIG_PATH=${PKG_CONFIG_LIBDIR}

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    mkdir -p "${LIBJPEG_BUILD_DIR}" "${INSTALL_PREFIX}"; \
    cd "${LIBJPEG_SRC}" && autoreconf -fiv; \
    cd "${LIBJPEG_BUILD_DIR}" && \
    CC="${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang" \
    CXX="${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang++" \
    AR="${TOOLCHAIN_BIN}/llvm-ar" \
    AS="${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang" \
    LD="${TOOLCHAIN_BIN}/${TARGET_TRIPLE}${ANDROID_API}-clang" \
    RANLIB="${TOOLCHAIN_BIN}/llvm-ranlib" \
    STRIP="${TOOLCHAIN_BIN}/llvm-strip" \
    CFLAGS="-fPIC" \
    CPPFLAGS="" \
    LDFLAGS="" \
    "${LIBJPEG_SRC}/configure" \
        --host="${TARGET_TRIPLE}" \
        --prefix="${INSTALL_PREFIX}" \
        --with-jpeg8 \
        --without-turbojpeg \
        --without-simd \
        --enable-static \
        --disable-shared || { cat config.log; exit 1; }; \
    make -C "${LIBJPEG_BUILD_DIR}" -j"$(nproc)"; \
    make -C "${LIBJPEG_BUILD_DIR}" install

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    cd /tmp; \
    curl -fsSL "https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz" -o zlib.tar.gz; \
    tar xf zlib.tar.gz; \
    cd "zlib-${ZLIB_VERSION}"; \
    CC="${CC}" AR="${AR}" RANLIB="${RANLIB}" ./configure --prefix="${INSTALL_PREFIX}" --static; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/zlib.tar.gz "/tmp/zlib-${ZLIB_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    export CPPFLAGS="-I${INSTALL_PREFIX}/include"; \
    export LDFLAGS="-L${INSTALL_PREFIX}/lib"; \
    cd /tmp; \
    curl -fsSL "https://download.sourceforge.net/libpng/libpng-${LIBPNG_VERSION}.tar.xz" -o libpng.tar.xz; \
    tar xf libpng.tar.xz; \
    cd "libpng-${LIBPNG_VERSION}"; \
    ./configure \
        --host="${TARGET_TRIPLE}" \
        --prefix="${INSTALL_PREFIX}" \
        --enable-static \
        --disable-shared; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/libpng.tar.xz "/tmp/libpng-${LIBPNG_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    export CPPFLAGS="-I${INSTALL_PREFIX}/include"; \
    export LDFLAGS="-L${INSTALL_PREFIX}/lib"; \
    cd /tmp; \
    curl -fsSL "https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz" -o freetype.tar.gz; \
    tar xf freetype.tar.gz; \
    cd "freetype-${FREETYPE_VERSION}"; \
    ./configure \
        --host="${TARGET_TRIPLE}" \
        --prefix="${INSTALL_PREFIX}" \
        --enable-static \
        --disable-shared \
        --with-harfbuzz=no \
        --with-png=yes \
        --with-zlib=yes \
        --without-bzip2 \
        --without-brotli; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/freetype.tar.gz "/tmp/freetype-${FREETYPE_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    cd /tmp; \
    curl -fsSL "https://github.com/harfbuzz/harfbuzz/releases/download/${HARFBUZZ_VERSION}/harfbuzz-${HARFBUZZ_VERSION}.tar.xz" -o harfbuzz.tar.xz; \
    tar xf harfbuzz.tar.xz; \
    cd "harfbuzz-${HARFBUZZ_VERSION}"; \
    envsubst < /opt/third-party/config/harfbuzz-crossfile.ini > crossfile.txt; \
    meson setup build \
        --prefix "${INSTALL_PREFIX}" \
        --libdir lib \
        --bindir bin \
        --buildtype release \
        --default-library static \
        --wrap-mode nofallback \
        --cross-file crossfile.txt \
        -Dtests=disabled \
        -Dbenchmark=disabled \
        -Ddocs=disabled \
        -Dicu=disabled \
        -Dintrospection=disabled \
        -Dglib=disabled \
        -Dgobject=disabled \
        -Dcairo=disabled \
        -Dfreetype=enabled; \
    ninja -C build install; \
    rm -rf /tmp/harfbuzz.tar.xz "/tmp/harfbuzz-${HARFBUZZ_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    export CPPFLAGS="-I${INSTALL_PREFIX}/include"; \
    export LDFLAGS="-L${INSTALL_PREFIX}/lib"; \
    cd /tmp; \
    curl -fsSL "https://downloads.sourceforge.net/project/lcms/lcms/${LCMS2_VERSION}/lcms2-${LCMS2_VERSION}.tar.gz" -o lcms2.tar.gz; \
    tar xf lcms2.tar.gz; \
    cd "lcms2-${LCMS2_VERSION}"; \
    ./configure \
        --host="${TARGET_TRIPLE}" \
        --prefix="${INSTALL_PREFIX}" \
        --enable-static \
        --disable-shared; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/lcms2.tar.gz "/tmp/lcms2-${LCMS2_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    cd /tmp; \
    curl -fsSL "https://github.com/uclouvain/openjpeg/archive/refs/tags/v${OPENJPEG_VERSION}.tar.gz" -o openjpeg.tar.gz; \
    tar xf openjpeg.tar.gz; \
    cmake -S "openjpeg-${OPENJPEG_VERSION}" -B "openjpeg-${OPENJPEG_VERSION}/build" \
        -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="${ANDROID_ABI}" \
        -DANDROID_PLATFORM=android-${ANDROID_API} \
        -DANDROID_STL=c++_static \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_CODEC=OFF \
        -DOPENJPEG_INSTALL_INCLUDE_DIR=include \
        -DOPENJPEG_INSTALL_LIB_DIR=lib; \
    cmake --build "openjpeg-${OPENJPEG_VERSION}/build" -j"$(nproc)"; \
    cmake --install "openjpeg-${OPENJPEG_VERSION}/build"; \
    rm -rf /tmp/openjpeg.tar.gz "/tmp/openjpeg-${OPENJPEG_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    cd /tmp; \
    curl -fsSL "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" -o openssl.tar.gz; \
    tar xf openssl.tar.gz; \
    cd "openssl-${OPENSSL_VERSION}"; \
    ./Configure android-arm64 \
        --prefix="${INSTALL_PREFIX}" \
        --openssldir="${INSTALL_PREFIX}/ssl" \
        no-shared \
        no-tests; \
    make -j"$(nproc)"; \
    make install_sw; \
    rm -rf /tmp/openssl.tar.gz "/tmp/openssl-${OPENSSL_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    export CPPFLAGS="-I${INSTALL_PREFIX}/include"; \
    export LDFLAGS="-L${INSTALL_PREFIX}/lib"; \
    cd /tmp; \
    curl -fsSL "https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz" -o libtiff.tar.gz; \
    tar xf libtiff.tar.gz; \
    cd "tiff-${LIBTIFF_VERSION}"; \
    ./configure \
        --host="${TARGET_TRIPLE}" \
        --prefix="${INSTALL_PREFIX}" \
        --enable-static \
        --disable-shared \
        --disable-lzma \
        --disable-webp \
        --disable-jbig; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/libtiff.tar.gz "/tmp/tiff-${LIBTIFF_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    export CPPFLAGS="-I${INSTALL_PREFIX}/include"; \
    export LDFLAGS="-L${INSTALL_PREFIX}/lib"; \
    export PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}"; \
    cd /tmp; \
    curl -fsSL "https://curl.se/download/curl-${LIBCURL_VERSION}.tar.xz" -o curl.tar.xz; \
    tar xf curl.tar.xz; \
    cd "curl-${LIBCURL_VERSION}"; \
    ./configure \
        --host="${TARGET_TRIPLE}" \
        --prefix="${INSTALL_PREFIX}" \
        --enable-static \
        --disable-shared \
        --without-nghttp2 \
        --without-libidn2 \
        --without-libpsl \
        --without-brotli \
        --without-zstd \
        --with-ssl="${INSTALL_PREFIX}" \
        --with-zlib="${INSTALL_PREFIX}" \
        --disable-ldap \
        --disable-manual \
        --disable-rtsp; \
    make -j"$(nproc)"; \
    make install; \
    rm -rf /tmp/curl.tar.xz "/tmp/curl-${LIBCURL_VERSION}"

RUN set -eux; \
    export PATH="${TOOLCHAIN_BIN}:${PATH}"; \
    export PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR}"; \
    export PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}"; \
    cmake -S "${POPPLER_SRC}" -B "${POPPLER_BUILD_DIR}" \
        -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE="${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake" \
        -DANDROID_ABI="${ANDROID_ABI}" \
        -DANDROID_PLATFORM=android-${ANDROID_API} \
        -DANDROID_STL=c++_static \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${INSTALL_PREFIX};${QT6_ANDROID_PREFIX}" \
        -DCMAKE_FIND_ROOT_PATH="${INSTALL_PREFIX};${QT6_ANDROID_PREFIX}" \
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_UNSTABLE_API_ABI_HEADERS=OFF \
        -DENABLE_UTILS=OFF \
        -DENABLE_CPP=OFF \
        -DENABLE_GLIB=OFF \
        -DENABLE_QT5=OFF \
        -DENABLE_QT6=ON \
        -DENABLE_GPGME=OFF \
        -DENABLE_NSS3=OFF \
        -DENABLE_BOOST=OFF \
        -DENABLE_LIBOPENJPEG=openjpeg2 \
        -DENABLE_LIBCURL=ON \
        -DENABLE_LIBTIFF=ON \
        -DENABLE_LCMS=ON \
        -DENABLE_ZLIB_UNCOMPRESS=OFF \
        -DRUN_GPERF_IF_PRESENT=OFF \
        -DBUILD_GTK_TESTS=OFF \
        -DBUILD_CPP_TESTS=OFF \
        -DBUILD_QT5_TESTS=OFF \
        -DBUILD_QT6_TESTS=OFF \
        -DBUILD_MANUAL_TESTS=OFF \
        -DWITH_FONTCONFIGURATION_WIN32=OFF \
        -DWITH_FONTCONFIGURATION_FONTCONFIG=OFF \
        -DWITH_FONTCONFIGURATION_ANDROID=ON \
        -DPKG_CONFIG_EXECUTABLE=/usr/bin/pkg-config \
        -DQt6_DIR="${QT6_ANDROID_PREFIX}/lib/cmake/Qt6"; \
    cmake --build "${POPPLER_BUILD_DIR}" -j"$(nproc)"; \
    cmake --install "${POPPLER_BUILD_DIR}"; \
    rm -rf "${POPPLER_BUILD_DIR}" "${POPPLER_SRC}"
