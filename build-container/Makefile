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
ifdef NO_PROXY
DOCKER_BUILD_ARGS += --build-arg NO_PROXY=$(NO_PROXY)
endif

build-container:
	docker build -t demo-android-env:0.0.1 \
	$(DOCKER_BUILD_ARGS) \
	-f Dockerfile.demo-android-base .

start-container:
	docker run -it --rm \
	-v $$(realpath ${CURDIR}/../):/workspace \
	demo-android-env:0.0.1 \
	bash

.PHONY: build-container start-container
