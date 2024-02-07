#!/bin/bash

arch=$(uname -m)

cp -rf /usr1/package/mindspore-*linux_"$(arch)".whl .

have_mindspore=$(find mindspore*"${arch}".whl 2>/dev/null | wc -l)
if [ "$have_mindspore" == 0 ]; then
  echo "please put mindspore wheel package here"
  exit 1
fi

arr=("A1" "A2")

if [ "$arch" == "x86_64" ]; then
  for element in "${arr[@]}"; do
    DOCKER_BUILDKIT=1 docker build -t ascend-mindspore:"$element"-centos7-x64 --no-cache --build-arg BASE_VERSION="$element"-centos7-x64 . || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-mindspore:"$element"-ubuntu18.04-x64 --no-cache --build-arg BASE_VERSION="$element"-ubuntu18.04-x64 . || exit 1
  done
else
  for element in "${arr[@]}"; do
    DOCKER_BUILDKIT=1 docker build -t ascend-mindspore:"$element"-centos7-arm64 --no-cache --build-arg BASE_VERSION="$element"-centos7-arm64 . || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-mindspore:"$element"-ubuntu18.04-arm64 --no-cache --build-arg BASE_VERSION="$element"-ubuntu18.04-arm64 . || exit 1
  done
fi
