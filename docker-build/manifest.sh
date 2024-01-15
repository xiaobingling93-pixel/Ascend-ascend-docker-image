version=23.0.0
repository=swr.cn-east-3.myhuaweicloud.com/test-ascendhub

#modelzoo
#mindspore-modelzoo
docker manifest rm ${repository}/mindspore-modelzoo:${version}
docker manifest create ${repository}/mindspore-modelzoo:${version} --amend ${repository}/mindspore-modelzoo:${version}-ubuntu18.04-x64 --amend ${repository}/mindspore-modelzoo:${version}-ubuntu18.04-arm64
docker manifest push ${repository}/mindspore-modelzoo:${version}

#common
#ascend-infer
docker manifest rm ${repository}/ascend-infer:${version}-ubuntu18.04
docker manifest create ${repository}/ascend-infer:${version}-ubuntu18.04 --amend ${repository}/ascend-infer:${version}-ubuntu18.04-x64 --amend ${repository}/ascend-infer:${version}-ubuntu18.04-arm64
docker manifest push ${repository}/ascend-infer:${version}-ubuntu18.04
docker manifest rm ${repository}/ascend-infer:${version}-centos7
docker manifest create ${repository}/ascend-infer:${version}-centos7 --amend ${repository}/ascend-infer:${version}-centos7-x64 --amend ${repository}/ascend-infer:${version}-centos7-arm64
docker manifest push ${repository}/ascend-infer:${version}-centos7

#ascend-toolkit
docker manifest rm ${repository}/ascend-toolkit:${version}-ubuntu18.04
docker manifest create ${repository}/ascend-toolkit:${version}-ubuntu18.04 --amend ${repository}/ascend-toolkit:${version}-ubuntu18.04-x64 --amend ${repository}/ascend-toolkit:${version}-ubuntu18.04-arm64
docker manifest push ${repository}/ascend-toolkit:${version}-ubuntu18.04
docker manifest rm ${repository}/ascend-toolkit:${version}-centos7
docker manifest create ${repository}/ascend-toolkit:${version}-centos7 --amend ${repository}/ascend-toolkit:${version}-centos7-x64 --amend ${repository}/ascend-toolkit:${version}-centos7-arm64
docker manifest push ${repository}/ascend-toolkit:${version}-centos7

#ascend-mindspore
docker manifest rm ${repository}/ascend-mindspore:${version}-ubuntu18.04
docker manifest create ${repository}/ascend-mindspore:${version}-ubuntu18.04 --amend ${repository}/ascend-mindspore:${version}-ubuntu18.04-x64 --amend ${repository}/ascend-mindspore:${version}-ubuntu18.04-arm64
docker manifest push ${repository}/ascend-mindspore:${version}-ubuntu18.04
docker manifest rm ${repository}/ascend-mindspore:${version}-centos7
docker manifest create ${repository}/ascend-mindspore:${version}-centos7 --amend ${repository}/ascend-mindspore:${version}-centos7-x64 --amend ${repository}/ascend-mindspore:${version}-centos7-arm64
docker manifest push ${repository}/ascend-mindspore:${version}-centos7

#ascend-pytorch1.11.0
docker manifest rm ${repository}/ascend-pytorch:${version}-1.11.0-ubuntu18.04
docker manifest create ${repository}/ascend-pytorch:${version}-1.11.0-ubuntu18.04 --amend ${repository}/ascend-pytorch:${version}-1.11.0-ubuntu18.04-x64 --amend ${repository}/ascend-pytorch:${version}-1.11.0-ubuntu18.04-arm64
docker manifest push ${repository}/ascend-pytorch:${version}-1.11.0-ubuntu18.04
docker manifest rm ${repository}/ascend-pytorch:${version}-1.11.0-centos7
docker manifest create ${repository}/ascend-pytorch:${version}-1.11.0-centos7 --amend ${repository}/ascend-pytorch:${version}-1.11.0-centos7-x64 --amend ${repository}/ascend-pytorch:${version}-1.11.0-centos7-arm64
docker manifest push ${repository}/ascend-pytorch:${version}-1.11.0-centos7

#ascend-tensorflow
docker manifest rm ${repository}/ascend-tensorflow:${version}-ubuntu18.04
docker manifest create ${repository}/ascend-tensorflow:${version}-ubuntu18.04 --amend ${repository}/ascend-tensorflow:${version}-ubuntu18.04-x64 --amend ${repository}/ascend-tensorflow:${version}-ubuntu18.04-arm64
docker manifest push ${repository}/ascend-tensorflow:${version}-ubuntu18.04
docker manifest rm ${repository}/ascend-tensorflow:${version}-centos7
docker manifest create ${repository}/ascend-tensorflow:${version}-centos7 --amend ${repository}/ascend-tensorflow:${version}-centos7-x64 --amend ${repository}/ascend-tensorflow:${version}-centos7-arm64
docker manifest push ${repository}/ascend-tensorflow:${version}-centos7

#hccl-test
docker manifest rm ${repository}/hccl-test:${version}-ubuntu18.04
docker manifest create ${repository}/hccl-test:${version}-ubuntu18.04 --amend ${repository}/hccl-test:${version}-ubuntu18.04-x64 --amend ${repository}/hccl-test:${version}-ubuntu18.04-arm64
docker manifest push ${repository}/hccl-test:${version}-ubuntu18.04

#cluster
docker manifest rm ${repository}/cluster-flops-test:${version}-ubuntu18.04
docker manifest create ${repository}/cluster-flops-test:${version}-ubuntu18.04 --amend ${repository}/cluster-flops-test:${version}-ubuntu18.04-x64 --amend ${repository}/cluster-flops-test:${version}-ubuntu18.04-arm64
docker manifest push ${repository}/cluster-flops-test:${version}-ubuntu18.04
