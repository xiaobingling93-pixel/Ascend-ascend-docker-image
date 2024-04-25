version=v6.0.RC1

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/resilience-controller:${version}  \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/resilience-controller:${version}-arm64 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/resilience-controller:${version}-x86
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/resilience-controller:${version}

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/noded:${version}  \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/noded:${version}-arm64 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/noded:${version}-x86
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/noded:${version}

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-k8sdeviceplugin:${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-k8sdeviceplugin:${version}-arm64 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-k8sdeviceplugin:${version}-x86
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-k8sdeviceplugin:${version}


docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/npu-exporter:${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/npu-exporter:${version}-arm64 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/npu-exporter:${version}-x86
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/npu-exporter:${version}

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/hccl-controller:${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/hccl-controller:${version}-arm64 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/hccl-controller:${version}-x86
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/hccl-controller:${version}


docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-operator:${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-operator:${version}-x86 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-operator:${version}-arm64
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/ascend-operator:${version}

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.4.0-${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.4.0-x86 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.4.0-arm64
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.4.0-${version}

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.7.0-${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.7.0-x86 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.7.0-arm64
docker manifest push --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-controller-manager:v1.7.0-${version}

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.4.0-${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.4.0-arm64 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.4.0-x86
docker manifest push --insecure  swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.4.0-${version}

docker manifest create --insecure swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.7.0-${version} \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.7.0-arm64 \
swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.7.0-x86
docker manifest push --insecure  swr.cn-east-3.myhuaweicloud.com/test-ascendhub/vc-scheduler:v1.7.0-${version}