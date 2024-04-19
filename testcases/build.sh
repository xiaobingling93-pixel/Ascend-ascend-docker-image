#!/bin/bash

arch=$(uname -m)

#准备依赖包
cp -rf /usr1/package/mindspore-*linux_$(arch).whl .
cp -rf /usr1/package/mindx_elastic-0.0.1-py39-none-linux_$(arch).whl .
cp -rf /usr1/package/Ascend-mindx-toolbox*-$(arch).run .
cp -rf /usr1/package/torch-1.11.0*-cp39-cp39*_"$(arch)".whl .
cp -rf /usr1/package/torch_npu-1.11.0*-cp39-cp39-linux_"$(arch)".whl .
cp -rf /usr1/package/apex-0.1_ascend_*-cp39-cp39-linux_"${arch}".whl .
cp -rf /usr1/package/Ascend-mindx-toolbox*-$(arch).run .
cp -r  /usr1/package/train_huawei_train_mindspore_resnet-Ais-Benchmark-Stubs-$(arch)-1.0-r2.3 .
cp -r  /usr1/package/train_huawei_train_mindspore_bert-Ais-Benchmark-Stubs-$(arch)-1.0-r2.3 .

get_megatron(){
  git clone https://github.com/NVIDIA/Megatron-LM.git
  cd Megatron-LM || exit 1
  git checkout 285068c8108e0e8e6538f54fe27c3ee86c5217a2
  git clone https://gitee.com/ascend/Megatron-LM.git megatron_npu
  cd - || exit 1
}

#检查依赖包
have_mindspore=$(find . |grep "mindspore"|grep $arch|wc -l)
if [ $have_mindspore == 0 ]; then
    echo "please put mindspore wheel package here"
    exit 1
fi
have_elastic=$(find . |grep "mindx_elastic"|grep $arch|wc -l)
if [ $have_elastic == 0 ]; then
    echo "please put mindx_elastic wheel package here"
    exit 1
fi
have_torch=$(find . |grep "torch-1.11.0"|grep $arch|wc -l)
if [ $have_torch == 0 ]; then
    echo "please put torch wheel package here"
    exit 1
fi
have_torch_npu=$(find . |grep "torch_npu"|grep $arch|wc -l)
if [ $have_torch_npu == 0 ]; then
    echo "please put torch_npu wheel package here"
    exit 1
fi
have_apex=$(find . |grep "apex"|grep $arch|wc -l)
if [ $have_apex == 0 ]; then
    echo "please put apex wheel package here"
    exit 1
fi
have_toolbox=$(find . |grep toolbox|grep $arch|wc -l)
if [ $have_toolbox == 0 ]; then
    echo "please put toolbox package here"
    exit 1
fi

get_megatron

echo "start build"
if [ $arch == "x86_64" ];then
  exit 0
    DOCKER_BUILDKIT=1  docker build -t testcases:ubuntu20.04-x64 --build-arg BASE_VERSION=A2-ubuntu20.04-x64 .
else
    DOCKER_BUILDKIT=1  docker build -f Dockerfile_aarch64 -t testcases:ubuntu20.04-arm64 --build-arg BASE_VERSION=A2-ubuntu20.04-arm64 .
fi