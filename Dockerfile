FROM demo-android-env:0.0.1

COPY src /opt/src
WORKDIR /opt/src
ENV QT_ANDROID_CMAKE=/opt/qt6-android-arm64/bin/qt-cmake

ARG HTTPS_URL
ARG HTTPS_PORT
ENV HTTPS_URL=${HTTPS_URL}
ENV HTTPS_PORT=${HTTPS_PORT}
ENV JAVA_TOOL_OPTIONS="-Dhttps.proxyHost=${HTTPS_URL} -Dhttps.proxyPort=${HTTPS_PORT}"

RUN $QT_ANDROID_CMAKE -S . -B build-android \
      -DQT_HOST_PATH=/opt/qt6-install \
      -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/build/cmake/android.toolchain.cmake \
      -DANDROID_SDK_ROOT=${ANDROID_SDK_ROOT} \
      -DANDROID_NDK_ROOT=${ANDROID_NDK_ROOT} \
      -DQt6_DIR=/opt/qt6-android-arm64/lib/cmake/Qt6 \
      -DQt6Core_DIR=/opt/qt6-android-arm64/lib/cmake/Qt6Core \
      -DQt6Gui_DIR=/opt/qt6-android-arm64/lib/cmake/Qt6Gui \
      -DQt6Widgets_DIR=/opt/qt6-android-arm64/lib/cmake/Qt6Widgets \
      -DANDROID_PLATFORM=android-23 \
      -DANDROID_ABI=arm64-v8a \
      -DANDROID_STL=c++_shared
RUN cmake --build build-android