version=24.0.RC3
repository=swr.cn-east-3.myhuaweicloud.com/ascendhub-test

#modelzoo
#mindspore-modelzoo
docker manifest rm ${repository}/mindspore-modelzoo:${version}
docker manifest create ${repository}/mindspore-modelzoo:${version} --amend ${repository}/mindspore-modelzoo:${version}-ubuntu20.04-x64 --amend ${repository}/mindspore-modelzoo:${version}-ubuntu20.04-arm64
docker manifest push ${repository}/mindspore-modelzoo:${version}

#common
#ascend-infer
docker manifest rm ${repository}/ascend-infer:${version}-ubuntu20.04
docker manifest create ${repository}/ascend-infer:${version}-ubuntu20.04 --amend ${repository}/ascend-infer:${version}-ubuntu20.04-x64 --amend ${repository}/ascend-infer:${version}-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-infer:${version}-ubuntu20.04
docker manifest rm ${repository}/ascend-infer:${version}-openeuler20.03
docker manifest create ${repository}/ascend-infer:${version}-openeuler20.03 --amend ${repository}/ascend-infer:${version}-openeuler20.03-x64 --amend ${repository}/ascend-infer:${version}-openeuler20.03-arm64
docker manifest push ${repository}/ascend-infer:${version}-openeuler20.03

#ascend-toolkit
docker manifest rm ${repository}/ascend-toolkit:${version}-ubuntu20.04
docker manifest create ${repository}/ascend-toolkit:${version}-ubuntu20.04 --amend ${repository}/ascend-toolkit:${version}-ubuntu20.04-x64 --amend ${repository}/ascend-toolkit:${version}-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-toolkit:${version}-ubuntu20.04
docker manifest rm ${repository}/ascend-toolkit:${version}-openeuler20.03
docker manifest create ${repository}/ascend-toolkit:${version}-openeuler20.03 --amend ${repository}/ascend-toolkit:${version}-openeuler20.03-x64 --amend ${repository}/ascend-toolkit:${version}-openeuler20.03-arm64
docker manifest push ${repository}/ascend-toolkit:${version}-openeuler20.03

#ascend-mindspore
docker manifest rm ${repository}/ascend-mindspore:${version}-A1-ubuntu20.04
docker manifest create ${repository}/ascend-mindspore:${version}-A1-ubuntu20.04 --amend ${repository}/ascend-mindspore:${version}-A1-ubuntu20.04-x64 --amend ${repository}/ascend-mindspore:${version}-A1-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-mindspore:${version}-A1-ubuntu20.04
docker manifest rm ${repository}/ascend-mindspore:${version}-A1-openeuler20.03
docker manifest create ${repository}/ascend-mindspore:${version}-A1-openeuler20.03 --amend ${repository}/ascend-mindspore:${version}-A1-openeuler20.03-x64 --amend ${repository}/ascend-mindspore:${version}-A1-openeuler20.03-arm64
docker manifest push ${repository}/ascend-mindspore:${version}-A1-openeuler20.03
docker manifest rm ${repository}/ascend-mindspore:${version}-A2-ubuntu20.04
docker manifest create ${repository}/ascend-mindspore:${version}-A2-ubuntu20.04 --amend ${repository}/ascend-mindspore:${version}-A2-ubuntu20.04-x64 --amend ${repository}/ascend-mindspore:${version}-A2-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-mindspore:${version}-A2-ubuntu20.04
docker manifest rm ${repository}/ascend-mindspore:${version}-A2-openeuler20.03
docker manifest create ${repository}/ascend-mindspore:${version}-A2-openeuler20.03 --amend ${repository}/ascend-mindspore:${version}-A2-openeuler20.03-x64 --amend ${repository}/ascend-mindspore:${version}-A2-openeuler20.03-arm64
docker manifest push ${repository}/ascend-mindspore:${version}-A2-openeuler20.03


#ascend-pytorch2.1.0
docker manifest rm ${repository}/ascend-pytorch:${version}-A1-2.1.0-ubuntu20.04
docker manifest create ${repository}/ascend-pytorch:${version}-A1-2.1.0-ubuntu20.04 --amend ${repository}/ascend-pytorch:${version}-A1-2.1.0-ubuntu20.04-x64 --amend ${repository}/ascend-pytorch:${version}-A1-2.1.0-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-pytorch:${version}-A1-2.1.0-ubuntu20.04
docker manifest rm ${repository}/ascend-pytorch:${version}-A1-2.1.0-openeuler20.03
docker manifest create ${repository}/ascend-pytorch:${version}-A1-2.1.0-openeuler20.03 --amend ${repository}/ascend-pytorch:${version}-A1-2.1.0-openeuler20.03-x64 --amend ${repository}/ascend-pytorch:${version}-A1-2.1.0-openeuler20.03-arm64
docker manifest push ${repository}/ascend-pytorch:${version}-A1-2.1.0-openeuler20.03
docker manifest rm ${repository}/ascend-pytorch:${version}-A2-2.1.0-ubuntu20.04
docker manifest create ${repository}/ascend-pytorch:${version}-A2-2.1.0-ubuntu20.04 --amend ${repository}/ascend-pytorch:${version}-A2-2.1.0-ubuntu20.04-x64 --amend ${repository}/ascend-pytorch:${version}-A2-2.1.0-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-pytorch:${version}-A2-2.1.0-ubuntu20.04
docker manifest rm ${repository}/ascend-pytorch:${version}-A2-2.1.0-openeuler20.03
docker manifest create ${repository}/ascend-pytorch:${version}-A2-2.1.0-openeuler20.03 --amend ${repository}/ascend-pytorch:${version}-A2-2.1.0-openeuler20.03-x64 --amend ${repository}/ascend-pytorch:${version}-A2-2.1.0-openeuler20.03-arm64
docker manifest push ${repository}/ascend-pytorch:${version}-A2-2.1.0-openeuler20.03

#ascend-tensorflow
docker manifest rm ${repository}/ascend-tensorflow:${version}-A1-ubuntu20.04
docker manifest create ${repository}/ascend-tensorflow:${version}-A1-ubuntu20.04 --amend ${repository}/ascend-tensorflow:${version}-A1-ubuntu20.04-x64 --amend ${repository}/ascend-tensorflow:${version}-A1-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-tensorflow:${version}-A1-ubuntu20.04
docker manifest rm ${repository}/ascend-tensorflow:${version}-A1-openeuler20.03
docker manifest create ${repository}/ascend-tensorflow:${version}-A1-openeuler20.03 --amend ${repository}/ascend-tensorflow:${version}-A1-openeuler20.03-x64 --amend ${repository}/ascend-tensorflow:${version}-A1-openeuler20.03-arm64
docker manifest push ${repository}/ascend-tensorflow:${version}-A1-openeuler20.03
docker manifest rm ${repository}/ascend-tensorflow:${version}-A2-ubuntu20.04
docker manifest create ${repository}/ascend-tensorflow:${version}-A2-ubuntu20.04 --amend ${repository}/ascend-tensorflow:${version}-A2-ubuntu20.04-x64 --amend ${repository}/ascend-tensorflow:${version}-A2-ubuntu20.04-arm64
docker manifest push ${repository}/ascend-tensorflow:${version}-A2-ubuntu20.04
docker manifest rm ${repository}/ascend-tensorflow:${version}-A2-openeuler20.03
docker manifest create ${repository}/ascend-tensorflow:${version}-A2-openeuler20.03 --amend ${repository}/ascend-tensorflow:${version}-A2-openeuler20.03-x64 --amend ${repository}/ascend-tensorflow:${version}-A2-openeuler20.03-arm64
docker manifest push ${repository}/ascend-tensorflow:${version}-A2-openeuler20.03

#hccl-test
docker manifest rm ${repository}/hccl-test:${version}-ubuntu20.04
docker manifest create ${repository}/hccl-test:${version}-ubuntu20.04 --amend ${repository}/hccl-test:${version}-ubuntu20.04-x64 --amend ${repository}/hccl-test:${version}-ubuntu20.04-arm64
docker manifest push ${repository}/hccl-test:${version}-ubuntu20.04

#cluster
docker manifest rm ${repository}/cluster-flops-test:${version}-ubuntu20.04
docker manifest create ${repository}/cluster-flops-test:${version}-ubuntu20.04 --amend ${repository}/cluster-flops-test:${version}-ubuntu20.04-x64 --amend ${repository}/cluster-flops-test:${version}-ubuntu20.04-arm64
docker manifest push ${repository}/cluster-flops-test:${version}-ubuntu20.04
