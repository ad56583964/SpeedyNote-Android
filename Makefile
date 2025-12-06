build-image:
	docker build -t $(IMAGE) $(DOCKER_BUILD_ARGS) .
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
ifdef SPEEDYNOTE_POPPLER_SYSROOT
DOCKER_RUN_ENV += -e SPEEDYNOTE_POPPLER_SYSROOT=$(SPEEDYNOTE_POPPLER_SYSROOT)
endif

.PHONY: help build-image enter-container \
        in-conan in-configure in-buildonly in-apk in-build in-build-poppler in-profile-detect in-clean

help:
	@echo "Commands (container-focused):"
	@echo "  build-image          Build $(IMAGE) with optional proxy args"
	@echo "  enter-container      Start interactive container at $(WORKDIR)"
	@echo "  in-conan             ./conan-install.sh"
	@echo "  in-configure         ./configure.sh"
	@echo "  in-buildonly         cmake --build --preset conan-debug --target NoteApp"
	@echo "  in-apk               ./build-apk.sh"
	@echo "  in-build             ./conan-install.sh && ./configure.sh && ./build-apk.sh"
	@echo "  in-build-poppler     ./build-poppler.sh   (requires running 'in-conan' first)"
	@echo "  in-profile-detect    conan profile detect --force"
	@echo "  in-clean             rm -rf build"

enter-container:
	docker run -it --rm $(DOCKER_RUN_ENV) \
		--network host \
		-v $(REPO_ROOT):/workspace \
		-w $(WORKDIR) \
		$(IMAGE) bash

# Inside-container shortcuts -------------------------------------------------
in-conan:
	./conan-install.sh

in-configure:
	./configure.sh

in-buildonly:
	cmake --build --preset conan-debug --parallel --target NoteApp

in-apk:
	./build-apk.sh

in-build:
	./conan-install.sh && ./configure.sh && ./build-apk.sh

in-build-poppler:
	./build-poppler.sh

in-profile-detect:
	conan profile detect --force

in-clean:
	rm -rf $(CURDIR)/build
