# Conan-based Android build stage, reusing the existing Android SDK/NDK + Qt
FROM demo-android-env:0.0.1

# Optional corporate proxy during build
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ENV http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY} no_proxy=${NO_PROXY} \
    HTTP_PROXY=${HTTP_PROXY} HTTPS_PROXY=${HTTPS_PROXY} NO_PROXY=${NO_PROXY}

# Install Conan 2 and helpers
RUN apt-get update && apt-get install -y python3-venv python3-pip && \
    python3 -m venv /opt/conan && \
    /opt/conan/bin/pip install --no-cache-dir "conan>=2,<3" && \
    ln -sf /opt/conan/bin/conan /usr/local/bin/conan && \
    conan --version

# Prepare workspace
WORKDIR /workspace/android-conan
COPY . /workspace/android-conan

# Default command just opens a shell; build is driven by build.sh
CMD ["/bin/bash"]
