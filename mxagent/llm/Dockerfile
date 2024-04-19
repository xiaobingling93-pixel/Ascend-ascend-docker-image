FROM ubuntu:20.04

WORKDIR /tmp
COPY . ./
RUN chmod -R 777 /tmp
ENV GIT_SSL_NO_VERIFY=1
ENV DEBIAN_FRONTEND=noninteractive
ARG TORCH_VERSION=2.1.0

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa && apt-get update
RUN apt-get install -y build-essential python3.10 python3.10-dev python3.10-distutils pciutils vim tar zip unzip git wget dos2unix make gcc g++ ccache gfortran libssl-dev curl
RUN curl -k https://bootstrap.pypa.io/get-pip.py | python3.10 && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# python depend
RUN pip3 install numpy==1.26.4 decorator==5.1.1 sympy==1.12 cffi==1.16.0 pyyaml==6.0.1 pathlib2==2.3.7.post1 protobuf==5.26.0 scipy==1.12.0 requests==2.31.0 psutil==5.9.8 absl-py==2.1.0 attrs==23.2.0

# llm depend
RUN pip3 install -r requirements.txt
# torch_npu and apex
RUN pip3 install torch=="${TORCH_VERSION}" torch_npu-"${TORCH_VERSION}"*-cp310-*.whl apex-0.1_*-cp310-*.whl --index-url https://download.pytorch.org/whl/cpu

# cann-toolkit and kernel
RUN useradd -d /home/HwHiAiUser -u 1000 -m -s /bin/bash HwHiAiUser && \
    ./Ascend-cann-toolkit*.run --install --quiet && \
    ./Ascend-cann-kernels*.run --install --quiet

# mindie-atb-models
RUN mkdir -p /usr/local/Ascend/atb-models && \
    tar -zxf Ascend-mindie-atb-models_*-abi0.tar.gz -C /usr/local/Ascend/atb-models/ && \
    cd /usr/local/Ascend/atb-models/ && \
    pip3 install atb_llm-0.0.1*.whl

# mindie
RUN source /usr/local/Ascend/ascend-toolkit/set_env.sh && \
    ./Ascend-mindie*.run --install --quiet
   

# clean tmp dir
RUN rm -rf ./*
WORKDIR /root