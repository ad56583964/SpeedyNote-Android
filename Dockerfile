FROM third-party-build:0.0.1

ARG HTTPS_URL
ARG HTTPS_PORT

ENV HTTPS_URL=${HTTPS_URL}
ENV HTTPS_PORT=${HTTPS_PORT}
ENV JAVA_TOOL_OPTIONS="-Dhttps.proxyHost=${HTTPS_URL} -Dhttps.proxyPort=${HTTPS_PORT}"

ENV QT_ANDROID_CMAKE=/opt/qt6-android-arm64/bin/qt-cmake
ENV SPEEDYNOTE_POPPLER_SYSROOT=/opt/third-party/sysroot
ENV PKG_CONFIG_LIBDIR=/opt/third-party/sysroot/lib/pkgconfig:/opt/third-party/sysroot/share/pkgconfig

WORKDIR /workspace
COPY SpeedyNote ./SpeedyNote
WORKDIR /workspace/SpeedyNote

RUN chmod +x build-android.sh

RUN ./build-android.sh --clean
