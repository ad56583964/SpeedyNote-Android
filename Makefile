ENV_FILE ?= .build.env
-include $(ENV_FILE)
export

DOCKER_BUILD_ARGS :=
ifdef HTTPS_URL
DOCKER_BUILD_ARGS += --build-arg HTTPS_URL=$(HTTPS_URL)
endif
ifdef HTTPS_PORT
DOCKER_BUILD_ARGS += --build-arg HTTPS_PORT=$(HTTPS_PORT)
endif

build-container:
	docker build -t demo-android:0.0.1 \
	$(DOCKER_BUILD_ARGS) \
	.
	mkdir -p output && docker run --rm demo-android:0.0.1 cat /opt/src/build-android/android-build/AndroidHello.apk > output/AndroidHello.apk

start-container:
	docker run -it --rm \
	-v 
	demo-android:0.0.1 \
	bash

.PHONY: build-container
