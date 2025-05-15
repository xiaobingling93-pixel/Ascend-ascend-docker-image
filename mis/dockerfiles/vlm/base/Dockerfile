ARG BASE_IMAGE=mis-vlm-cann:0.1
FROM ${BASE_IMAGE}

WORKDIR /opt

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ARG PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

RUN apt-get update && apt-get install -y git gcc g++ libnuma-dev wget && mkdir -p /opt/vllm-ascend/

RUN cd /opt/vllm-ascend/ && \
    git clone --depth 1 --branch v0.8.5.post1 https://github.com/vllm-project/vllm && \
    cd vllm && VLLM_TARGET_DEVICE=empty pip3 install -e .

ARG TORCH_DEVICE_BACKEND_AUTOLOAD=0
RUN pip3 install --ignore-installed --upgrade blinker==1.9.0
RUN /bin/bash -c "source /usr/local/Ascend/ascend-toolkit/set_env.sh; source /usr/local/Ascend/nnal/atb/set_env.sh; pip3 install vllm-ascend==0.8.5rc1"