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
version=6.0.RC3
arch=$(arch)
if [[ ${arch} == "x86_64" ]];then
  ARCH=x86
else
  ARCH=arm64
fi

repository=swr.cn-east-3.myhuaweicloud.com/ascendhub-test

push_resilience_controller(){
  docker tag resilience-controller:v${version} ${repository}/resilience-controller:v${version}-${ARCH}
  docker push ${repository}/resilience-controller:v${version}-${ARCH}
}

push_hccl_controller(){
  docker tag hccl-controller:v${version} ${repository}/hccl-controller:v${version}-${ARCH}
  docker push ${repository}/hccl-controller:v${version}-${ARCH}
}

push_noded(){
  docker tag noded:v${version} ${repository}/noded:v${version}-${ARCH}
  docker push ${repository}/noded:v${version}-${ARCH}
}

push_ascend_operator(){
  docker tag ascend-operator:v${version} ${repository}/ascend-operator:v${version}-${ARCH}
  docker push ${repository}/ascend-operator:v${version}-${ARCH}
}

push_device_plugin(){
  docker tag ascend-k8sdeviceplugin:v${version} ${repository}/ascend-k8sdeviceplugin:v${version}-${ARCH}
  docker push ${repository}/ascend-k8sdeviceplugin:v${version}-${ARCH}
}

push_npu_exporter(){
  docker tag npu-exporter:v${version} ${repository}/npu-exporter:v${version}-${ARCH}
  docker push ${repository}/npu-exporter:v${version}-${ARCH}
}

push_volcano(){
  docker tag volcanosh/vc-controller-manager:v1.7.0 ${repository}/vc-controller-manager:v1.7.0-${ARCH}
  docker tag volcanosh/vc-scheduler:v1.7.0 ${repository}/vc-scheduler:v1.7.0-${ARCH}
  docker push ${repository}/vc-controller-manager:v1.7.0-${ARCH}
  docker push ${repository}/vc-scheduler:v1.7.0-${ARCH}

  docker tag volcanosh/vc-controller-manager:v1.9.0 ${repository}/vc-controller-manager:v1.9.0-${ARCH}
  docker tag volcanosh/vc-scheduler:v1.9.0 ${repository}/vc-scheduler:v1.9.0-${ARCH}
  docker push ${repository}/vc-controller-manager:v1.9.0-${ARCH}
  docker push ${repository}/vc-scheduler:v1.9.0-${ARCH}
}

push_clusterd(){
  docker tag clusterd:v${version} ${repository}/clusterd:v${version}-${ARCH}
  docker push ${repository}/clusterd:v${version}-${ARCH}
}

main(){
  case $1 in
  "all")
  push_device_plugin
  push_volcano
  push_npu_exporter
  push_noded
  push_resilience_controller
  push_hccl_controller
  push_ascend_operator
  push_clusterd
    ;;
  "ascend-device-plugin")
  push_device_plugin
    ;;
  "ascend-volcano-plugin")
  push_volcano
    ;;
  "npu-exporter")
  push_npu_exporter
    ;;
  "noded")
  push_noded
    ;;
  "resilience-controller")
  push_resilience_controller
    ;;
  "hccl-controller")
  push_hccl_controller
    ;;
  "ascend-operator")
  push_ascend_operator
    ;;
  "clusterd")
  push_clusterd
    ;;
  *)
  echo "Unsupported parameters: $1"
  exit 1
  ;;
  esac
}

main $1