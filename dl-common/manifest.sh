  version=v7.3.0

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/resilience-controller:${version}  \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/resilience-controller:${version}-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/resilience-controller:${version}-x86
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/resilience-controller:${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/noded:${version}  \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/noded:${version}-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/noded:${version}-x86
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/noded:${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-k8sdeviceplugin:${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-k8sdeviceplugin:${version}-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-k8sdeviceplugin:${version}-x86
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-k8sdeviceplugin:${version}


  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/npu-exporter:${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/npu-exporter:${version}-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/npu-exporter:${version}-x86
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/npu-exporter:${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/hccl-controller:${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/hccl-controller:${version}-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/hccl-controller:${version}-x86
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/hccl-controller:${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/clusterd:${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/clusterd:${version}-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/clusterd:${version}-x86
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/clusterd:${version}


  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-operator:${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-operator:${version}-x86 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-operator:${version}-arm64
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/ascend-operator:${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.9.0-${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.9.0-x86 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.9.0-arm64
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.9.0-${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.7.0-${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.7.0-x86 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.7.0-arm64
  docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-controller-manager:v1.7.0-${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.9.0-${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.9.0-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.9.0-x86
  docker manifest push --insecure  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.9.0-${version}

  docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.7.0-${version} \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.7.0-arm64 \
  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.7.0-x86
  docker manifest push --insecure  swr.cn-east-3.myhuaweicloud.com/ascendhub-test/vc-scheduler:v1.7.0-${version}