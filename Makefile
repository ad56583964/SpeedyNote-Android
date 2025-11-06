ENV_FILE ?= $(CURDIR)/../.build.env
-include $(ENV_FILE)
export

IMAGE ?= android-conan:0.0.1
REPO_ROOT := $(realpath $(CURDIR)/..)
WORKDIR := /workspace/android-conan

# Build args for proxy-enabled environments
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

# Run-time env passthrough (optional)
DOCKER_RUN_ENV :=
ifdef HTTP_PROXY
DOCKER_RUN_ENV += -e HTTP_PROXY=$(HTTP_PROXY) -e http_proxy=$(HTTP_PROXY)
endif
ifdef HTTPS_PROXY
DOCKER_RUN_ENV += -e HTTPS_PROXY=$(HTTPS_PROXY) -e https_proxy=$(HTTPS_PROXY)
endif
ifdef NO_PROXY
DOCKER_RUN_ENV += -e NO_PROXY=$(NO_PROXY) -e no_proxy=$(NO_PROXY)
endif

.PHONY: help build-image shell build profile-detect clean

help:
	@echo "Targets:"
	@echo "  build-image     Build $(IMAGE) with optional proxy args"
	@echo "  shell           Run container and drop into bash at $(WORKDIR)"
	@echo "  build           Run ./build.sh inside container"
	@echo "  profile-detect  Run 'conan profile detect --force' inside container"
	@echo "  clean           Remove local build folder (android-conan/build)"

build-image:
	docker build -t $(IMAGE) $(DOCKER_BUILD_ARGS) .

shell:
	docker run -it --rm $(DOCKER_RUN_ENV) \
		-v $(REPO_ROOT):/workspace \
		-w $(WORKDIR) \
		$(IMAGE) bash

build:
	docker run --rm $(DOCKER_RUN_ENV) \
		-v $(REPO_ROOT):/workspace \
		-w $(WORKDIR) \
		$(IMAGE) bash -lc './build.sh'

profile-detect:
	docker run --rm $(DOCKER_RUN_ENV) \
		-v $(REPO_ROOT):/workspace \
		-w $(WORKDIR) \
		$(IMAGE) bash -lc 'conan profile detect --force'

clean:
	rm -rf $(CURDIR)/build

