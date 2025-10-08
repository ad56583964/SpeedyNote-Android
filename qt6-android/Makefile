build-qt6-android:
	docker build -t qt6-android-build:0.0.1 \
	--build-arg HTTPS_PROXY=http://192.168.195.1:7890 \
	-f Dockerfile.qt6-android-build .

start-container:
	docker run -it --rm \
	qt6-android-build:0.0.1 \
	bash
