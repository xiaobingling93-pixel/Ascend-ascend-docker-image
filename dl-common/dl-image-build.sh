#!/bin/bash
# Perform  build volcano-huawei-npu-scheduler plugin
# Copyright @ Huawei Technologies CO., Ltd. 2020-2022. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
version=26.0.0
root_dir=$(pwd $0)
arch=$(arch)

if [[ ${arch} == "x86_64" ]];then
  ARCH=x86
  base_image=swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/ubuntu:22.04
else
  ARCH=arm64
  base_image=swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/ubuntu:22.04-linuxarm64
fi

if [[ ${arch} == "x86_64" ]];then
  ARCH=x86
  alpine_image=swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/alpine:latest
else
  ARCH=arm64
  alpine_image=swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/alpine:latest-linuxarm64
fi

build_noded(){
  cd ${root_dir} ||  exit 1
  unzip Ascend-mindxdl-noded_${version}_linux-${arch}.zip -d ascend-noded
  cd ${root_dir}/ascend-noded || exit 1
  sed -i "s@ubuntu:22.04@${base_image}@g" Dockerfile
  docker build --no-cache -t noded:v${version} ./
}

build_ascend_operator(){
  cd ${root_dir} ||  exit 1
  unzip Ascend-mindxdl-ascend-operator_${version}_linux-${arch}.zip -d ascend-operator
  cd ${root_dir}/ascend-operator || exit 1
    sed -i "s@ubuntu:22.04@${base_image}@g" Dockerfile
  docker build --no-cache -t ascend-operator:v${version} ./
}

build_infer_operator(){
  cd ${root_dir} ||  exit 1
  unzip Ascend-mindxdl-infer-operator_${version}_linux-${arch}.zip -d infer-operator
  cd ${root_dir}/infer-operator || exit 1
    sed -i "s@ubuntu:22.04@${base_image}@g" Dockerfile
  docker build --no-cache -t infer-operator:v${version} ./
}

build_device_plugin(){
  cd ${root_dir} ||  exit 1
  unzip Ascend-mindxdl-device-plugin_${version}_linux-${arch}.zip -d ascend-device-plugin
  cd ${root_dir}/ascend-device-plugin || exit 1
  cp ${root_dir}/Dockerfile-dp-common ./
  sed -i "s@ubuntu:22.04@${base_image}@g" Dockerfile-dp-common
  docker build --no-cache -t ascend-k8sdeviceplugin:v${version} -f Dockerfile-dp-common .
}

build_npu_exporter(){
  cd ${root_dir} ||  exit 1
  unzip Ascend-mindxdl-npu-exporter_${version}_linux-${arch}.zip -d ascend-npu-exporter
  cd ${root_dir}/ascend-npu-exporter || exit 1
  cp ${root_dir}/Dockerfile-exporter-common ./
  sed -i "s@ubuntu:22.04@${base_image}@g" Dockerfile-exporter-common
  docker build --no-cache -t npu-exporter:v${version} -f Dockerfile-exporter-common .
}

build_clusterd(){
  cd ${root_dir} ||  exit 1
  unzip Ascend-mindxdl-clusterd_${version}_linux-${arch}.zip -d clusterd
  cd ${root_dir}/clusterd || exit 1
  sed -i "s@ubuntu:22.04@${base_image}@g" Dockerfile
  docker build --no-cache -t clusterd:v${version}  .
}

build_volcano_v1.7(){
  cd ${root_dir}/ascend-volcano-plugin/volcano-v1.7.0 || exit 1
  sed -i "s@alpine:latest@${alpine_image}@g" ./Dockerfile-scheduler
  sed -i "s@alpine:latest@${alpine_image}@g" ./Dockerfile-controller
  docker build --no-cache -t volcanosh/vc-scheduler:v1.7.0 ./ -f ./Dockerfile-scheduler
  docker build --no-cache -t volcanosh/vc-controller-manager:v1.7.0 ./ -f ./Dockerfile-controller
}

build_volcano_v1.9(){
  cd ${root_dir}/ascend-volcano-plugin/volcano-v1.9.0 || exit 1
  sed -i "s@alpine:latest@${alpine_image}@g" ./Dockerfile-scheduler
  sed -i "s@alpine:latest@${alpine_image}@g" ./Dockerfile-controller
  docker build --no-cache -t volcanosh/vc-scheduler:v1.9.0 ./ -f ./Dockerfile-scheduler
  docker build --no-cache -t volcanosh/vc-controller-manager:v1.9.0 ./ -f ./Dockerfile-controller
}

build_volcano(){
  cd ${root_dir} ||  exit 1
  unzip Ascend-mindxdl-volcano_${version}_linux-${arch}.zip -d ascend-volcano-plugin
  build_volcano_v1.7
  build_volcano_v1.9
}

get_image_resource(){
  flag=$(cat /usr1/mindxdl_package/version)
  if [[ $flag == $version ]];then
      return
  fi
  rm -rf /usr1/mindxdl_package/*
  wget https://gitcode.com/ascend/mind-cluster/releases/download/v${version}/Ascend-mindxdl-noded_${version}_linux-$(arch).zip -P /usr1/mindxdl_package/
  wget https://gitcode.com/ascend/mind-cluster/releases/download/v${version}/Ascend-mindxdl-npu-exporter_${version}_linux-$(arch).zip -P /usr1/mindxdl_package/
  wget https://gitcode.com/ascend/mind-cluster/releases/download/v${version}/Ascend-mindxdl-ascend-operator_${version}_linux-$(arch).zip -P /usr1/mindxdl_package/
  wget https://gitcode.com/ascend/mind-cluster/releases/download/v${version}/Ascend-mindxdl-infer-operator_${version}_linux-$(arch).zip -P /usr1/mindxdl_package/
  wget https://gitcode.com/ascend/mind-cluster/releases/download/v${version}/Ascend-mindxdl-clusterd_${version}_linux-$(arch).zip -P /usr1/mindxdl_package/
  wget https://gitcode.com/ascend/mind-cluster/releases/download/v${version}/Ascend-mindxdl-device-plugin_${version}_linux-$(arch).zip -P /usr1/mindxdl_package/
  wget https://gitcode.com/ascend/mind-cluster/releases/download/v${version}/Ascend-mindxdl-volcano_${version}_linux-$(arch).zip -P /usr1/mindxdl_package/
  echo $version > /usr1/mindxdl_package/version
}

main(){
  get_image_resource
  cp /usr1/mindxdl_package/* ${root_dir}/
  case $1 in
  "all")
  build_device_plugin
  build_volcano
  build_npu_exporter
  build_noded
  build_ascend_operator
  build_infer_operator
  build_clusterd
    ;;
  "ascend-device-plugin")
  build_device_plugin
    ;;
  "ascend-volcano-plugin")
  build_volcano
    ;;
  "npu-exporter")
  build_npu_exporter
    ;;
  "noded")
  build_noded
    ;;
  "ascend-operator")
  build_ascend_operator
    ;;
  "infer-operator")
  build_infer_operator
    ;;
  "clusterd")
  build_clusterd
    ;;
  *)
  echo "Unsupported parameters: $1"
  exit 1
  ;;
  esac
}

main $1