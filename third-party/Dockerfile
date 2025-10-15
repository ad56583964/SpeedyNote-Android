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

ENV ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}
ENV NDK_ROOT=${ANDROID_NDK_ROOT}
ENV ANDROID_API=${ANDROID_API}
ENV TARGET_TRIPLE=${TARGET_TRIPLE}
ENV ANDROID_ABI=${ANDROID_ABI}
ENV INSTALL_PREFIX=${INSTALL_PREFIX}

ENV TOOLCHAIN_DIR=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64
ENV TOOLCHAIN_BIN=${TOOLCHAIN_DIR}/bin
ENV PATH=${TOOLCHAIN_BIN}:${PATH}

RUN mkdir -p /opt/third-party
WORKDIR /opt/third-party

COPY harfbuzz-crossfile.ini /opt/third-party/config/harfbuzz-crossfile.ini

RUN git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git \
    --branch ${LIBJPEG_REF} \
    --depth 1

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
