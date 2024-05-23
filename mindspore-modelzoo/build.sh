#!/bin/bash

arch=$(uname -m)

rm -rf mindspore*.whl mindx_elastic*.whl Ascend*.run train_huawei_train_mindspore* Resnet50_* vpc_resnet50_*

#准备依赖包
cp -rf /usr1/package/mindspore-*linux_"$(arch)".whl .
cp -rf /usr1/package/mindx_elastic*"$arch".whl .
cp -rf /usr1/package/Ascend-mindx-toolbox*-"$(arch)".run .
cp -rf /usr1/package/Ascend-cann-kernels-910b*.run .
if [ "$arch" == "x86_64" ]; then
    cp -rf /usr1/package/train_huawei_train_mindspore_bert-Ais-Benchmark-Stubs-x86_64-1.0-r2.3 . || exit 1
    cp -rf /usr1/package/train_huawei_train_mindspore_resnet-Ais-Benchmark-Stubs-x86_64-1.0-r2.3 . || exit 1
else
    cp -rf /usr1/package/train_huawei_train_mindspore_bert-Ais-Benchmark-Stubs-aarch64-1.0-r2.3 . || exit 1
    cp -rf /usr1/package/train_huawei_train_mindspore_resnet-Ais-Benchmark-Stubs-aarch64-1.0-r2.3 . || exit 1
fi
cp -rf /usr1/package/run_ais.py . || exit 1

#准备模型和数据集
cp -r /usr1/package/mindspore-modelzoo-data-model/Resnet50_Cifar_for_MindSpore . || exit 1
cp -r /usr1/package/mindspore-modelzoo-data-model/Resnet50_imagenet2012_for_MindSpore . || exit 1
cp -r /usr1/package/mindspore-modelzoo-data-model/vpc_resnet50_imagenet_classification . || exit 1

#检查依赖包
have_mindspore=$(find mindspore*"$arch".whl 2>/dev/null | wc -l)
if [ "$have_mindspore" == 0 ]; then
    echo "please put mindspore wheel package here"
    exit 1
fi
have_elastic=$(find mindx_elastic*"$arch".whl 2>/dev/null | wc -l)
if [ "$have_elastic" == 0 ]; then
    echo "please put mindx_elastic wheel package here"
    exit 1
fi
have_toolbox=$(find Ascend-mindx-toolbox*"$arch".run 2>/dev/null | wc -l)
if [ "$have_toolbox" == 0 ]; then
    echo "please put toolbox package here"
    exit 1
fi
have_kernels=$(find Ascend-cann-kernels-910b*.run 2>/dev/null | wc -l)
if [ "$have_kernels" != 1 ]; then
    echo "please put kernels run package here"
    exit 1
fi

if [ "$arch" == "x86_64" ]; then
    DOCKER_BUILDKIT=1 docker build . -t mindspore-modelzoo:ubuntu20.04-x64 --build-arg BASE_VERSION=A1-ubuntu20.04-x64
else
    DOCKER_BUILDKIT=1 docker build . -f Dockerfile_aarch64 -t mindspore-modelzoo:ubuntu20.04-arm64 --build-arg BASE_VERSION=A1-ubuntu20.04-arm64
fi
