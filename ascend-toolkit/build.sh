#!/bin/bash
download_resources(){
  flag=$(cat /usr1/package/flag)
  if [[ $flag == "completed" ]];then
    return
  fi
  if [[ $(arch) == "x86_64" ]];then
    download_cann
    down_ms
    wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/OpenSource/python/packages/tensorflow_cpu-2.6.5-cp39-cp39-manylinux2010_x86_64.whl -P  /usr1/package/
    wget https://gitee.com/ascend/pytorch/releases/download/v6.0.rc3-pytorch2.1.0/torch_npu-2.1.0.post8-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -P /usr1/package/
    wget https://download.pytorch.org/whl/cpu/torch-2.1.0%2Bcpu-cp39-cp39-linux_x86_64.whl -P /usr1/package/
  else
    download_cann
    down_ms
    wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/OpenSource/packages/h5py-3.1.0-cp39-cp39-linux_aarch64.whl -P /usr1/package/
    wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/OpenSource/packages/tensorflow-2.6.5-cp39-cp39-linux_aarch64.whl -P /usr1/package/
    wget https://gitee.com/ascend/pytorch/releases/download/v6.0.rc3-pytorch2.1.0/torch_npu-2.1.0.post8-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl -P /usr1/package/
    wget https://download.pytorch.org/whl/cpu/torch-2.1.0-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl -P /usr1/package/
  fi
  echo "completed" > /usr1/package/flag
}

download_cann(){
      wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-kernels-910_8.0.RC3_linux-$(arch).run -P /usr1/package/
      wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-kernels-910b_8.0.RC3_linux-$(arch).run -P /usr1/package/
      wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-nnrt_8.0.RC3_linux-$(arch).run -P /usr1/package/
      wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-toolkit_8.0.RC3_linux-$(arch).run -P /usr1/package/
      wget https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/CANN/CANN%208.0.RC3/Ascend-cann-tfplugin_8.0.RC3_linux-$(arch).run -P /usr1/package/

}

down_ms(){
    wget https://ms-release.obs.cn-north-4.myhuaweicloud.com/2.4.0/MindSpore/unified/$(arch)/mindspore-2.4.0-cp39-cp39-linux_$(arch).whl -P /usr1/package/
}



download_resources

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
    cp -rf /usr1/package/Ascend-cann-kernels-"${element}"_*.run .
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
    cp -rf /usr1/package/Ascend-cann-kernels-"${element}"_*.run .
    if [ "${element}" == '910' ]; then
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-openeuler20.03"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=openeuler20.03"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A1-ubuntu20.04"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=ubuntu20.04"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
    else
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-openeuler20.03"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=openeuler20.03"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
      DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:A2-ubuntu20.04"$pytag"-arm64 --no-cache --build-arg BASE_VERSION=ubuntu20.04"$pytag"-arm64 . -f Dockerfile_aarch64 || exit 1
    fi
  done
fi