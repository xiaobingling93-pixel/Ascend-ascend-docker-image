FROM ubuntu:22.04

ARG PYTHON_VER=3.10
ARG PLATFORM=910B
ARG CANN_VERSION=8.0.0
ENV DEBIAN_FRONTEND=noninteractive
ENV no_proxy=172.17.0.1,$no_proxy

WORKDIR /tmp

ARG PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

RUN apt-get update && apt-get -y install wget ca-certificates && update-ca-certificates && \
    apt-get install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa && \
    apt-get install -y gcc make net-tools python${PYTHON_VER} python${PYTHON_VER}-dev python${PYTHON_VER}-venv curl wget && \
    ln -sf /usr/bin/python${PYTHON_VER} /usr/bin/python3 && ln -sf /usr/bin/python${PYTHON_VER} /usr/bin/python && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py && rm -rf *

RUN pip3 install attrs cython numpy==1.24.0 decorator sympy cffi pyyaml pathlib2 psutil protobuf==3.20 scipy requests absl-py

RUN wget -q http://172.17.0.1:3000/Ascend-cann-toolkit_${CANN_VERSION}_linux-aarch64.run -P cann/ && \
    platform=$(echo $PLATFORM | tr '[A-Z]' '[a-z]') && \
    wget -q http://172.17.0.1:3000/Ascend-cann-kernels-${platform}_${CANN_VERSION}_linux-aarch64.run -P cann/ && \
    wget -q http://172.17.0.1:3000/Ascend-cann-nnal_${CANN_VERSION}_linux-aarch64.run -P cann/ && \
    /bin/bash cann/Ascend-cann-toolkit*.run --install --quiet && \
    /bin/bash cann/Ascend-cann-kernels*.run --install --quiet && \
    /bin/bash -c "source /usr/local/Ascend/ascend-toolkit/set_env.sh; /bin/bash cann/Ascend-cann-nnal*.run --install --quiet" && \
    rm -rf *

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:/usr/local/Ascend/driver/lib64
