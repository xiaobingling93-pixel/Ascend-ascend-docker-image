#!/bin/bash

arch=$(uname -m)
if [[ "$PYVERSION" =~ 3.10. ]];then
  pytag="-py310"
else
  pytag=""
fi

echo "start build"
if [ $arch == "x86_64" ];then
    cd ubuntu20.04-x64
    DOCKER_BUILDKIT=1  docker build -t ascendbase-toolkit:ubuntu20.04"$pytag"-x64 --build-arg PYVERSION=$PYVERSION . || exit 1
    cd ../openeuler20.03-x64
    DOCKER_BUILDKIT=1  docker build -t ascendbase-toolkit:openeuler20.03"$pytag"-x64 --build-arg PYVERSION=$PYVERSION . || exit 1
else
    cd ubuntu20.04-arm64
    DOCKER_BUILDKIT=1  docker build -t ascendbase-toolkit:ubuntu20.04"$pytag"-arm64 --build-arg PYVERSION=$PYVERSION . || exit 1
    cd ../openeuler20.03-arm64
    DOCKER_BUILDKIT=1  docker build -t ascendbase-toolkit:openeuler20.03"$pytag"-arm64 --build-arg PYVERSION=$PYVERSION . || exit 1
fi


