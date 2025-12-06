#!/usr/bin/env bash
set -euo pipefail

# propagate proxy to Gradle if provided
if [ -n "${HTTPS_URL:-}" ] && [ -n "${HTTPS_PORT:-}" ]; then
  export JAVA_TOOL_OPTIONS="-Dhttps.proxyHost=${HTTPS_URL} -Dhttps.proxyPort=${HTTPS_PORT} ${JAVA_TOOL_OPTIONS:-}"
  export GRADLE_OPTS="-Dhttps.proxyHost=${HTTPS_URL} -Dhttps.proxyPort=${HTTPS_PORT} ${GRADLE_OPTS:-}"
elif [ -n "${HTTPS_PROXY:-}" ]; then
  proto_host_port=$(printf '%s' "$HTTPS_PROXY" | sed -E 's#^([^:]+)://##')
  host_port=$(printf '%s' "$proto_host_port" | sed -E 's#^[^@]+@##')
  hp_host=$(printf '%s' "$host_port" | cut -d':' -f1)
  hp_port=$(printf '%s' "$host_port" | cut -d':' -f2 | sed 's#/.*$##')
  if [ -n "$hp_host" ] && [ -n "$hp_port" ]; then
    export JAVA_TOOL_OPTIONS="-Dhttps.proxyHost=${hp_host} -Dhttps.proxyPort=${hp_port} ${JAVA_TOOL_OPTIONS:-}"
    export GRADLE_OPTS="-Dhttps.proxyHost=${hp_host} -Dhttps.proxyPort=${hp_port} ${GRADLE_OPTS:-}"
  fi
fi

cmake --build --preset conan-debug --parallel --target NoteApp
cmake --build --preset conan-debug --parallel --target NoteApp_make_apk

echo "[build-apk] Done. See build/android-armv8/build/Debug/..."
