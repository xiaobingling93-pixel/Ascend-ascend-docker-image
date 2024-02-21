#!/bin/bash

arch=$(uname -m)

#准备依赖包
cp -rf /usr1/package930/mindspore-*linux_$(arch).whl .
cp -rf /usr1/package930/mindx_elastic-0.0.1-py37-none-linux_$(arch).whl .
cp -rf /usr1/package930/Ascend-mindx-toolbox*-$(arch).run .
cp -rf /usr1/package930/torch_npu-1.11.0.post*-$(arch).whl .
cp -rf /usr1/package930/torch-1.11.0-*-$(arch).whl .
cp -rf /usr1/package930/apex-0.1_ascend_*-$(arch).whl .
cp -rf /usr1/package930/Ascend-mindx-toolbox*-$(arch).run .
rm -f Ascend-cann-*-$(arch).run
cp -rf /usr1/package930/Ascend-cann-toolkit_7.0*-$(arch).run .
cp -rf /usr1/package930/Ascend-cann-kernels-910*.run .

cp -rf /usr1/package930/train_huawei_train_mindspore_bert-Ais-Benchmark-Stubs-$(arch)-1.0-r2.2 .
cp -rf /usr1/package930/train_huawei_train_mindspore_resnet-Ais-Benchmark-Stubs-$(arch)-1.0-r2.2 .

#准备模型和数据集
if [ -d Megatron-LM ]; then
    rm -rf Megatron-LM
fi

cp -r /usr1/package930/acceptance-data-model/Megatron-LM .

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
if [ $apex == 0 ]; then
    echo "please put apex wheel package here"
    exit 1
fi
have_toolbox=$(find . |grep toolbox|grep $arch|wc -l)
if [ $have_toolbox == 0 ]; then
    echo "please put toolbox package here"
    exit 1
fi

echo "start build"
if [ $arch == "x86_64" ];then
    DOCKER_BUILDKIT=1  docker build . -t acceptance:ubuntu18.04-x64
else
    DOCKER_BUILDKIT=1  docker build . -f Dockerfile_aarch64 -t acceptance:ubuntu18.04-arm64
fi