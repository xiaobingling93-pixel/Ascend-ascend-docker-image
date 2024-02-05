#!/bin/bash

arch=$(uname -m)

if [[ $arch != "x86_64" ]]; then
  exit 0
fi

cp -rf /usr1/package/torch-2.1.0*linux_"$(arch)".whl .
cp -rf /usr1/package/torch_npu-2.1.0*_"$(arch)".whl .
cp -rf /usr1/package/Ascend-cann-toolkit_*-"$(arch)".run .
cp -rf /usr1/package/Ascend-cann-kernels-910b_*_linux.run .

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

have_toolkit=$(find Ascend-cann-toolkit*.run 2>/dev/null | wc -l)
if [ "$have_toolkit" == 0 ]; then
  echo "please put toolkit run package here"
  exit 1
fi

have_kernels=$(find Ascend-cann-kernels-910b*.run 2>/dev/null | wc -l)
if [ "$have_kernels" == 0 ]; then
  echo "please put kernels run package here"
  exit 1
fi

DOCKER_BUILDKIT=1 docker build -t ascend-pytorch2.1.0:A2-ubuntu18.04-x64 . || exit 1
