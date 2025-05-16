ARG BASE_IMAGE=mis-cann:0.1
FROM ${BASE_IMAGE}

ARG ARCH=aarch64
ARG PLATFORM=910B

RUN RUN groupadd HwHiAiUser && useradd -g HwHiAiUser -d /home/HwHiAiUser -m HwHiAiUser -s /bin/bash

WORKDIR /home/HwHiAiUser

RUN apt-get install -y --no-install-recommends build-essential vim tar zip unzip git git-lfs \
curl dos2unix make gcc g++ ccache gfortran libssl-dev swig ffmpeg libopenblas-dev pkg-config patch

RUN pip install cn_clip==1.5.1  torch==2.1.0 torch-npu==2.1.0.post8 torchvision==0.16.0 loguru httpx

COPY ./build/clip.patch /tmp

RUN git clone https://github.com/jina-ai/clip-as-service.git && cd clip-as-service && git checkout v0.8.3 && \
	patch -p1 </tmp/clip.patch && pip install --default-timeout=1000 --compile ./server/