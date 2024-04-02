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
version=6.0.RC1
root_dir=$(pwd $0)
arch=$(arch)

build_resilience_controller(){
  unzip Ascend-mindxdl-resilience-controller_${version}_linux-${arch}.zip -d resilience-controller
  cd ${root_dir}/resilience-controller || exit 1
  docker build --no-cache -t resilience-controller:v${version} ./
}

build_hccl_controller(){
  unzip Ascend-mindxdl-hccl-controller_${version}_linux-${arch}.zip -d hccl-controller
  cd ${root_dir}/hccl-controller || exit 1
  docker build --no-cache -t hccl-controller:v${version} ./
}

build_noded(){
  unzip Ascend-mindxdl-noded_${version}_linux-${arch}.zip -d ascend-noded
  cd ${root_dir}/ascend-noded || exit 1
  docker build --no-cache -t noded:${version} ./
}

build_ascend_operator(){
  unzip Ascend-mindxdl-ascend-operator_${version}_linux-${arch}.zip -d ascend-operator
  cd ${root_dir}/ascend-operator || exit 1
  docker build --no-cache -t ascend-operator:v${version} ./
}

build_device_plugin(){
  unzip Ascend-mindxdl-device-plugin_${version}_linux-${arch}.zip -d ascend-device-plugin
  cd ${root_dir}/ascend-device-plugin || exit 1
  cp ${root_dir}/Dockerfile-dp-common ./
  docker build --no-cache -t ascend-k8sdeviceplugin:v${version} -f Dockerfile-dp-common .
}

build_npu_exporter(){
  unzip Ascend-mindxdl-npu-exporter_${version}_linux-${arch}.zip -d ascend-npu-exporter
  cd ${root_dir}/ascend-npu-exporter || exit 1
  cp ${root_dir}/Dockerfile-exporter-common ./
  docker build --no-cache -t npu-exporter:v${version} -f Dockerfile-exporter-common .
}

build_volcano_v1.7(){
  cd ${root_dir}/ascend-volcano-plugin/volcano-v1.7.0 || exit 1
  docker build --no-cache -t volcanosh/vc-scheduler:v1.7.0 ./ -f ./Dockerfile-scheduler
  docker build --no-cache -t volcanosh/vc-controller-manager:v1.7.0 ./ -f ./Dockerfile-controller
}

build_volcano_v1.4(){
  cd ${root_dir}/ascend-volcano-plugin/volcano-v1.4.0 || exit 1
  docker build --no-cache -t volcanosh/vc-scheduler:v1.4.0 ./ -f ./Dockerfile-scheduler
  docker build --no-cache -t volcanosh/vc-controller-manager:v1.4.0 ./ -f ./Dockerfile-controller
}

build_volcano(){
  unzip Ascend-mindxdl-volcano_${version}_linux-${arch}.zip -d ascend-volcano-plugin
  build_volcano_v1.7
  build_volcano_v1.4
}

main(){
  case $1 in
  "all")
  build_device_plugin
  build_volcano
  build_npu_exporter
  build_noded
  build_resilience_controller
  build_hccl_controller
  build_ascend_operator
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
  "resilience-controller")
  build_resilience_controller
    ;;
  "hccl-controller")
  build_hccl_controller
    ;;
  "ascend-operator")
  build_ascend_operator
    ;;
  *)
  echo "Unsupported parameters: $1"
  exit 1
  ;;
  esac
}

main $1