ARG BASE_IMAGE=mis-llm-cann:0.1
FROM ${BASE_IMAGE}

WORKDIR /opt

ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ARG PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple

RUN wget -q http://172.17.0.1:3000/Ascend-mindie_1.0.0_linux-aarch64.run -P cann/ && \
    wget -q http://172.17.0.1:3000/Ascend-mindie-atb-models_1.0.0_linux-aarch64_py310_torch2.3.1-abi0.tar.gz -P cann/ && \
    /bin/bash -c "source /usr/local/Ascend/ascend-toolkit/set_env.sh; /bin/bash cann/Ascend-mindie_*.run --install --quiet" && \
    /bin/bash -c "mkdir -p /usr/local/Ascend/atb; tar -zxvf cann/Ascend-mindie-atb-models*.tar.gz -C /usr/local/Ascend/atb/" && \
    RM -rf *

RUN apt-get install -y git && mkdir -p /opt/vllm-ascend/
RUN cd /opt/vllm-ascend/ && \
    git clone https://github.com/vllm-project/vllm.git && \
    cd vllm && git checkout 4f4d427 && \
    pip3 install -r requirements-build.txt && VLLM_TARGET_DEVICE=empty pip3 install -e .
RUN cd /opt/vllm-ascend/ && \
    git clone https://github.com/vllm-project/vllm-ascend.git && \
    cd vllm-ascend && git checkout f17417f && \
    pip3 install -e .
RUN cd /opt/vllm-ascend/ && mkdir pta && \
    curl https://pytorch-package.obs.cn-north-4.myhuaweicloud.com/pta/Daily/v2.5.1/20250218.4/pytorch_v2.5.1_py310.tar.gz -o pta.tar.gz && \
    tar -zxvf pta.tar.gz -C pta && \
    pip3 install pta/torch_npu-2.5.1.dev20250218-cp310-cp310-manylinux_2_17_aarch64.*.whl
RUN pip3 install transformers==4.45.0 # mindie needed