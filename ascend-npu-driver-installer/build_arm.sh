#! /bin/bash

docker buildx build --platform linux/arm64 -f Dockerfile_openeuler22.03 -t ascend-npu-driver-installer:openeuler-22.03 . 
docker buildx build --platform linux/arm64 -f Dockerfile_openeuler24.03 -t ascend-npu-driver-installer:openeuler-24.03 . 
docker buildx build --platform linux/arm64 -f Dockerfile_ubuntu20.04 -t ascend-npu-driver-installer:ubuntu-20.04 . 
