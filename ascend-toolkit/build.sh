#!/bin/bash

arch=$(uname -m)
arr=("910" "910b")

if [ $arch == "x86_64" ]; then
  for element in "${arr[@]}"; do
    rm -f Ascend-cann-*.run
    cp -rf /usr1/package/Ascend-cann-toolkit_*-$(arch).run .
    cp -rf /usr1/package/Ascend-cann-kernels-${element}_*_linux.run .
    if [ ${element} == '910' ]; then
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-centos7-x64 --no-cache --build-arg BASE_VERSION=centos7-x64 . || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-ubuntu18.04-x64 --no-cache --build-arg BASE_VERSION=ubuntu18.04-x64 . || exit 1
    else
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-centos7-x64 --no-cache --build-arg BASE_VERSION=centos7-x64 . || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-ubuntu18.04-x64 --no-cache --build-arg BASE_VERSION=ubuntu18.04-x64 . || exit 1
    fi
  done
else
  for element in "${arr[@]}"; do
    rm -f Ascend-cann-*.run
    cp -rf /usr1/package/Ascend-cann-toolkit_*-$(arch).run .
    cp -rf /usr1/package/Ascend-cann-kernels-${element}_*_linux.run .
    if [ ${element} == '910' ]; then
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-centos7-arm64 --no-cache --build-arg BASE_VERSION=centos7-arm64 . -f Dockerfile_aarch64 || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-ubuntu18.04-arm64 --no-cache --build-arg BASE_VERSION=ubuntu18.04-arm64 . -f Dockerfile_aarch64 || exit 1
    else
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-centos7-arm64 --no-cache --build-arg BASE_VERSION=centos7-arm64 . -f Dockerfile_aarch64 || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-ubuntu18.04-arm64 --no-cache --build-arg BASE_VERSION=ubuntu18.04-arm64 . -f Dockerfile_aarch64 || exit 1
    fi
  done
fi
