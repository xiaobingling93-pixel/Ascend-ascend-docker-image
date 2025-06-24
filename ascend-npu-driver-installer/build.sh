#! /bin/bash

docker build -t ascend-npu-driver-installer:openeuler-22.03-lts . || exit 1
