build-container:
	docker build -t demo-android-env:0.0.1 \
	--build-arg HTTP_PROXY=http://192.168.195.1:7890 \
	--build-arg HTTPS_PROXY=http://192.168.195.1:7890 \
	--build-arg NO_PROXY=localhost,127.0.0.1 \
	-f Dockerfile.demo-android-base .

start-container:
	docker run -it --rm \
	-v $$(realpath ${CURDIR}/../):/workspace \
	demo-android-env:0.0.1 \
	bash

.PHONY: build-container start-container
