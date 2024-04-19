#!/bin/bash

arch=$(uname -m)
arr=("910" "910b")
if [[ "$PYVERSION" =~ 3.10. ]];then
  pytag="-py310"
else
  pytag=""
fi

if [ "$arch" == "x86_64" ]; then
  for element in "${arr[@]}"; do
    rm -f Ascend-cann-*.run
    cp -rf /usr1/package/Ascend-cann-toolkit_*-"$(arch)".run .
    cp -rf /usr1/package/Ascend-cann-kernels-"${element}"_*_linux.run .
    if [ "${element}" == '910' ]; then
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-ubuntu20.04"$pytag"-x64 --no-cache --build-arg BASE_VERSION=ubuntu20.04"$pytag"-x64 . || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-openeuler20.03"$pytag"-x64 --no-cache --build-arg BASE_VERSION=openeuler20.03"$pytag"-x64 . || exit 1
    else
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-ubuntu20.04"$pytag"-x64 --no-cache --build-arg BASE_VERSION=ubuntu20.04"$pytag"-x64 . || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-openeuler20.03"$pytag"-x64 --no-cache --build-arg BASE_VERSION=openeuler20.03"$pytag"-x64 . || exit 1
    fi
  done
else
  for element in "${arr[@]}"; do
    rm -f Ascend-cann-*.run
    cp -rf /usr1/package/Ascend-cann-toolkit_*-"$(arch)".run .
    cp -rf /usr1/package/Ascend-cann-kernels-"${element}"_*_linux.run .
    if [ "${element}" == '910' ]; then
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-openeuler20.03"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=openeuler20.03"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-ubuntu20.04"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=ubuntu20.04"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
    else
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-openeuler20.03"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=openeuler20.03"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-ubuntu20.04"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=ubuntu20.04"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
    fi
  done
fi
