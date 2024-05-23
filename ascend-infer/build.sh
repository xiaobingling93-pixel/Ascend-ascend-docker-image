#!/bin/bash

arch=$(uname -m)

cp -rf /usr1/package/Ascend-cann-nnrt*-$(arch).run .

have_nnrt=$(find . |grep cann|grep nnrt|grep $arch|wc -l)
if [ $have_nnrt == 0 ]; then
    echo "please put nnrt package here"
    exit 1
fi

echo "start build"
if [ $arch == "x86_64" ];then
    DOCKER_BUILDKIT=1 docker build -t ascend-infer:ubuntu20.04-x64 --no-cache --build-arg BASE_VERSION=ubuntu20.04-x64 . || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-infer:openeuler20.03-x64 --no-cache  --build-arg BASE_VERSION=openeuler20.03-x64 . || exit 1
else
    DOCKER_BUILDKIT=1 docker build -t ascend-infer:ubuntu20.04-arm64 --no-cache  --build-arg BASE_VERSION=ubuntu20.04-arm64 . || exit 1
    DOCKER_BUILDKIT=1 docker build -t ascend-infer:openeuler20.03-arm64 --no-cache  --build-arg BASE_VERSION=openeuler20.03-arm64 . || exit 1
fi
