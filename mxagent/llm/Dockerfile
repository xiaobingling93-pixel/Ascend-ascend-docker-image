FROM ubuntu:20.04

WORKDIR /tmp
COPY . ./
RUN chmod 777 /tmp
ENV GIT_SSL_NO_VERIFY=1
ENV DEBIAN_FRONTEND=noninteractive
ARG TORCH_VERSION=2.1.0

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa && apt-get update
RUN apt-get install -y build-essential python3.10 python3.10-dev python3.10-distutils pciutils vim tar zip unzip git wget dos2unix make gcc g++ ccache gfortran libssl-dev swig git unzip wget curl
RUN curl -k https://bootstrap.pypa.io/get-pip.py | python3.10 && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

RUN pip3 install numpy==1.26.4 decorator==5.1.1 sympy==1.12 cffi==1.16.0 pyyaml==6.0.1 pathlib2==2.3.7.post1 protobuf==5.26.0 scipy==1.12.0 requests==2.31.0 psutil==5.9.8 absl-py==2.1.0 attrs==23.2.0

RUN pip3 install torch=="${TORCH_VERSION}" torch_npu-"${TORCH_VERSION}"*-cp310-*aarch64.whl apex-0.1_*-cp310-*aarch64.whl

RUN useradd -d /home/HwHiAiUser -u 1000 -m -s /bin/bash HwHiAiUser && \
    bash Ascend-cann-toolkit*.run --install --quiet && \
    bash Ascend-cann-kernels*.run --install --quiet
ENV ASCEND_HOME_PATH=/usr/local/Ascend/ascend-toolkit/latest
ENV TOOLCHAIN_HOME=/usr/local/Ascend/ascend-toolkit/latest/toolkit
ENV ASCEND_TOOLKIT_HOME=/usr/local/Ascend/ascend-toolkit/latest
ENV ASCEND_OPP_PATH=/usr/local/Ascend/ascend-toolkit/latest/opp
ENV ASCEND_AICPU_PATH=/usr/local/Ascend/ascend-toolkit/latest
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH


RUN mkdir -p /usr/local/Ascend/atb-models/ && tar -zxf Ascend-mindie-atb-models_*-abi0.tar.gz -C /usr/local/Ascend/atb-models/ && \
    bash Ascend-mindie-atb_*_abi0.run --install --quiet && \
    unzip -o Ascend-mindie-service_*.zip && tar -zxf mindie-service_*-aarch64.tar.gz -C /usr/local/Ascend/ && cd /usr/local/Ascend/mindie-service*/bin && pip3 install ock_hntc-*.whl --force-reinstall

RUN rm -rf ./*
WORKDIR /root