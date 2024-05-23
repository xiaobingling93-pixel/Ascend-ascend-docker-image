#!/bin/bash

arch=$(uname -m)

echo "start build"
if [ $arch == "x86_64" ];then
    cd ubuntu20.04-x64 || exit 1
    DOCKER_BUILDKIT=1  docker build -t ascendbase-infer:ubuntu20.04-x64 . || exit 1
    cd ../openeuler20.03-x64 || exit 1
    DOCKER_BUILDKIT=1  docker build -t ascendbase-infer:openeuler20.03-x64 . || exit 1
else
    cd ubuntu20.04-arm64 || exit 1
    DOCKER_BUILDKIT=1  docker build -t ascendbase-infer:ubuntu20.04-arm64 . || exit 1
    cd ../openeuler20.03-arm64 || exit 1
    DOCKER_BUILDKIT=1  docker build -t ascendbase-infer:openeuler20.03-arm64 . || exit 1
fi
