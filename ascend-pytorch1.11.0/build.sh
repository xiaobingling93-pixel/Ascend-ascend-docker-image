#!/bin/bash

arch=$(uname -m)

cp -rf /usr1/package/torch-1.11.0*-cp39-cp39*_"$(arch)".whl .
cp -rf /usr1/package/torch_npu-1.11.0*-cp39-cp39-linux_"$(arch)".whl .
cp -rf /usr1/package/apex-0.1_ascend_*-cp39-cp39-linux_"${arch}".whl .


have_torch=$(find torch-1.11.0*"${arch}".whl 2>/dev/null | wc -l)
if [ "$have_torch" == 0 ]; then
  echo "please put pytorch wheel package here"
  exit 1
fi

have_torch_npu=$(find torch_npu-1.11.0*"${arch}".whl 2>/dev/null | wc -l)
if [ "$have_torch_npu" == 0 ]; then
  echo "please put torch_npu wheel package here"
  exit 1
fi

have_apex=$(find apex-0.1_ascend_*-cp39-cp39-linux_"${arch}".whl 2>/dev/null | wc -l)
if [ "$have_apex" == 0 ]; then
  echo "please put apex wheel package here"
  exit 1
fi

arr=("A1" "A2")
if [ "$arch" == "x86_64" ]; then
  for element in "${arr[@]}"; do
    DOCKER_BUILDKIT=1 docker build -t ascend-pytorch1.11.0:"$element"-openeuler20.03-x64 --no-cache --build-arg BASE_VERSION="$element"-openeuler20.03-x64 . || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-pytorch1.11.0:"$element"-ubuntu20.04-x64 --no-cache --build-arg BASE_VERSION="$element"-ubuntu20.04-x64 . || exit 1
  done
else
  for element in "${arr[@]}"; do
    DOCKER_BUILDKIT=1 docker build -t ascend-pytorch1.11.0:"$element"-openeuler20.03-arm64 --no-cache --build-arg BASE_VERSION="$element"-openeuler20.03-arm64 . || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-pytorch1.11.0:"$element"-ubuntu20.04-arm64 --no-cache --build-arg BASE_VERSION="$element"-ubuntu20.04-arm64 . || exit 1
  done
fi
