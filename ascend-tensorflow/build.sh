#!/bin/bash

arch=$(uname -m)

if [[ $(arch) == "x86_64" ]]; then
  cp -rf /usr1/package/tensorflow_cpu-2.6.5-cp39-cp39-manylinux2010_x86_64.whl .
else
  cp -rf /usr1/package/tensorflow-2.6.5-cp39-cp39-linux_aarch64.whl .
  cp -rf /usr1/package/h5py-3.1.0-cp39-cp39-linux_aarch64.whl .
fi

have_tensorflow=$(find tensorflow*-2.6.5-*"${arch}".whl 2>/dev/null | wc -l)
if [ "$have_tensorflow" == 0 ]; then
  echo "please put tensorflow wheel package here"
  exit 1
fi
arr=("A1" "A2")
if [ "$arch" == "x86_64" ]; then
  for element in "${arr[@]}"; do
    rm -f Ascend-cann-tfplugin*-"$(arch)".run
    cp -rf /usr1/package/Ascend-cann-tfplugin_*-"$(arch)".run .
    DOCKER_BUILDKIT=1 docker build -t ascend-tensorflow:"$element"-openeuler20.03-x64 --no-cache --build-arg BASE_VERSION="$element"-openeuler20.03-x64 . || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-tensorflow:"$element"-ubuntu20.04-x64 --no-cache --build-arg BASE_VERSION="$element"-ubuntu20.04-x64 . || exit 1
  done
else
  for element in "${arr[@]}"; do
    rm -f Ascend-cann-tfplugin*-"$(arch)".run
    cp -rf /usr1/package/Ascend-cann-tfplugin_*-"$(arch)".run .
    DOCKER_BUILDKIT=1 docker build -t ascend-tensorflow:"$element"-openeuler20.03-arm64 --no-cache --build-arg BASE_VERSION="$element"-openeuler20.03-arm64 . -f Dockerfile_aarch64 || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-tensorflow:"$element"-ubuntu20.04-arm64 --no-cache --build-arg BASE_VERSION="$element"-ubuntu20.04-arm64 . -f Dockerfile_aarch64 || exit 1
  done
fi
