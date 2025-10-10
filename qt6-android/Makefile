ENV_FILE ?= $(CURDIR)/../.build.env
-include $(ENV_FILE)
export

DOCKER_BUILD_ARGS :=
ifdef HTTP_PROXY
DOCKER_BUILD_ARGS += --build-arg HTTP_PROXY=$(HTTP_PROXY)
endif
ifdef HTTPS_PROXY
DOCKER_BUILD_ARGS += --build-arg HTTPS_PROXY=$(HTTPS_PROXY)
endif

build-qt6-android:
	docker build -t qt6-android-build:0.0.1 \
	$(DOCKER_BUILD_ARGS) \
	-f Dockerfile.qt6-android-build .

start-container:
	docker run -it --rm \
	qt6-android-build:0.0.1 \
	bash
