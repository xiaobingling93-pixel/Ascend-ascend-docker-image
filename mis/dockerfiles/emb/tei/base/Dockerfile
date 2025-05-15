ARG BASE_IMAGE=mis-cann:0.1
FROM ${BASE_IMAGE}

ARG ARCH=aarch64
ARG PLATFORM=910B
ARG RAG_SDK_VERSION=7.1.RC1
ARG TORCH_VERSION=2.1.0

ENV DEBIAN_FRONTEND=noninteractive
ENV GIT_SSL_NO_VERIFY=1
# 配置环境变量
ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
ENV PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa && apt-get update
RUN apt-get update && apt-get install -y curl wget git git-lfs ca-certificates libssl-dev zlib1g-dev unzip tar gcc make cmake libffi-dev g++ libprotobuf-dev pkg-config build-essential libbz2-dev libreadline-dev libsqlite3-dev llvm xz-utils liblzma-dev libopenblas-dev vim

RUN wget --no-check-certificate https://github.com/protocolbuffers/protobuf/releases/download/v30.2/protoc-30.2-linux-aarch_64.zip -P /tmp
RUN mv /tmp/protoc-*-linux-aarch_64.zip /tmp && \
	unzip /tmp/protoc-*-linux-aarch_64.zip -d /tmp/protoc3 && \
	mv /tmp/protoc3/bin/protoc /usr/local/bin && \
	mv /tmp/protoc3/include/* /usr/local/include && \
	rm -rf /tmp/*

ARG PYTHON_VERSION=python3.11

RUN apt-get update && apt-get install -y build-essential ${PYTHON_VERSION}  ${PYTHON_VERSION}-dev ${PYTHON_VERSION}-distutils ${PYTHON_VERSION}-venv 
RUN curl -k https://bootstrap.pypa.io/get-pip.py | ${PYTHON_VERSION} &&  update-alternatives --install /usr/bin/python3 python3 /usr/bin/${PYTHON_VERSION} 1
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN pip3 install grpcio-tools mypy-protobuf


RUN groupadd HwHiAiUser && useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash

WORKDIR /tmp

# 安装torch
RUN pip3 install torch=="${TORCH_VERSION}" --index-url https://download.pytorch.org/whl/cpu 
# 安装torch-npu
RUN pip3 install torch-npu=="${TORCH_VERSION}".post8


#安装pip依赖
RUN pip3 install poetry transformers==4.41.1 scikit-learn


# 安装gcc10
RUN apt-get remove -y gcc g++
RUN apt update && apt install -y gcc-10 g++-10
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 60 && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-10 60 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 60 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-10 60


USER HwHiAiUser:HwHiAiUser

#安装RUST
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-update-default-toolchain
#RUN bash -c "source  $HOME/.cargo/env && rustup toolchain install 1.83.0"

#安装 TEI
WORKDIR /home/HwHiAiUser

RUN git clone https://github.com/huggingface/text-embeddings-inference.git && cd text-embeddings-inference && git checkout v1.6.1
COPY ./package/tei.patch /tmp
RUN cd /home/HwHiAiUser/text-embeddings-inference && patch -p1 < /tmp/tei.patch
#RUN sed -i 's/channel = .*/channel = "1.83.0"/g' /home/HwHiAiUser/text-embeddings-inference/rust-toolchain.toml
WORKDIR /home/HwHiAiUser/text-embeddings-inference
RUN  bash -c "source $HOME/.cargo/env && cargo install --path router -F python -F http --no-default-features"

# 以HwHiAiUser用户安装RAG SDK
COPY wget -q http://172.17.0.1:3000/Ascend-mindxsdk-mxrag_$RAG_SDK_VERSION_linux-${ARCH}.run /tmp
RUN bash /tmp/Ascend-mindxsdk-mxrag_$RAG_SDK_VERSION_linux-${ARCH}.run --install --install-path=/home/HwHiAiUser/Ascend --quiet --platform=${PLATFORM} --whitelist=operator

USER root

RUN cd /home/HwHiAiUser/text-embeddings-inference/backends/python/server && make -j16 && make install

#升级python依赖软件
RUN pip3 install safetensors==0.4.1 sentence_transformers==3.4.1

# 以root用户安装RAG SDK
RUN bash /tmp/Ascend-mindxsdk-mxrag_$RAG_SDK_VERSION_linux-${ARCH}.run--install --install-path=/usr/local/Ascend --quiet --platform=${PLATFORM} --whitelist=operator


#拷贝执行脚本
COPY --chown=HwHiAiUser:HwHiAiUser ./package/start.sh /home/HwHiAiUser

RUN chmod 661 /home/HwHiAiUser
# 添加环境变量
ENV PATH=/usr/local/bin:$PATH

#清理临时目录
USER root
RUN rm -rf /tmp/* && rm -rf /home/HwHiAiUser/text-embeddings-inference/target
