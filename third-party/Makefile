ENV_FILE ?= ./../build.env
-include $(ENV_FILE)
export

QT_IMAGE ?= qt6-android-env:latest

DOCKER_BUILD_ARGS := --build-arg QT6_IMAGE=$(QT_IMAGE)
ifdef HTTPS_URL
DOCKER_BUILD_ARGS += --build-arg HTTPS_URL=$(HTTPS_URL)
endif
ifdef HTTPS_PORT
DOCKER_BUILD_ARGS += --build-arg HTTPS_PORT=$(HTTPS_PORT)
endif

build-container:
	docker build -t third-party-build:0.0.1 \
	$(DOCKER_BUILD_ARGS) \
	.

start-container:
	docker run -it --rm \
	-v ${CURDIR}:/workspace \
	third-party-build:0.0.1 \
	bash
