build-container:
	docker build -t demo-android:0.0.1 \
	--build-arg HTTPS_URL=192.168.195.1 \
	--build-arg HTTPS_PORT=7890 \
	.

start-container:
	docker run -it --rm \
	demo-android:0.0.1 \
	bash

.PHONY: build-container