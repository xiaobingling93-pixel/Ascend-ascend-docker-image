#!/bin/bash

arch=$(uname -m)

if [[ $arch != "x86_64" ]]; then
  exit 0
fi

cp -rf /usr1/package/torch-2.1.0*linux_"$(arch)".whl .
cp -rf /usr1/package/torch_npu-2.1.0*_"$(arch)".whl .
cp -rf /usr1/package/apex-0.1_ascend_*-cp39-cp39-linux_"${arch}".whl .

have_torch=$(find torch-2.1.0*.whl 2>/dev/null | wc -l)
if [ "$have_torch" == 0 ]; then
  echo "please put pytorch wheel package here"
  exit 1
fi

have_torch_npu=$(find torch_npu-2.1.0*.whl 2>/dev/null | wc -l)
if [ "$have_torch_npu" == 0 ]; then
  echo "please put torch_npu wheel package here"
  exit 1
fi

have_apex=$(find apex-0.1_ascend_*-cp39-cp39-linux_"${arch}".whl 2>/dev/null | wc -l)
if [ "$have_apex" == 0 ]; then
  echo "please put apex wheel package here"
  exit 1
fi


DOCKER_BUILDKIT=1 docker build -t ascend-pytorch2.1.0:A2-ubuntu20.04-x64 --no-cache --build-arg BASE_VERSION=A2-ubuntu20.04-x64 -f Dockerfile_new . || exit 1
