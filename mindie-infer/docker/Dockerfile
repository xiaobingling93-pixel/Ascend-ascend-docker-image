FROM ubuntu_local:22.04.1014 AS base

# Create HwHiAiUser
RUN groupadd -g 1001 HwHiAiUser && \
    useradd -d /home/HwHiAiUser -m -u 1001 -g 1001 -s /bin/bash HwHiAiUser && \
    chmod -R 750 /home/HwHiAiUser

WORKDIR /home/HwHiAiUser

RUN echo 'export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH' >> /home/HwHiAiUser/.bashrc && \
    echo 'export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:$LD_LIBRARY_PATH' >> /home/HwHiAiUser/.bashrc && \
    echo "export LANG=en_US.UTF-8" >> /home/HwHiAiUser/.bashrc && \
    echo "export LANGUAGE=en_US:en" >> /home/HwHiAiUser/.bashrc && \
    echo "export LC_ALL=en_US.UTF-8" >> /home/HwHiAiUser/.bashrc && \
    # Set Huawei apt mirror
    # echo "deb [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    # echo "deb-src [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy main restricted universe multiverse" >> /etc/apt/sources.list && \
    # echo "deb [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    # echo "deb-src [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    # echo "deb [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    # echo "deb-src [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    # echo "deb [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    # echo "deb-src [trusted=yes] https://repo.huaweicloud.com/ubuntu-ports/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    apt-get update && \
    # If FROM ubuntu:22.04, the official image, please install the following deps
    # apt install --no-install-recommends -y gcc g++ make cmake zlib1g zlib1g-dev openssl libsqlite3-dev libssl-dev libffi-dev && \
    # apt install --no-install-recommends -y libbz2-dev libxslt1-dev unzip pciutils net-tools libblas-dev gfortran libblas3 ca-certificates && \
    # apt install --no-install-recommends -y bc wget curl pkg-config liblapack3 vim liblapack-dev libhdf5-dev xz-utils cython3 python3-h5py && \
    # apt install --no-install-recommends -y libopenblas-dev libgmpxx4ldbl liblzma-dev libxml2 libgl1-mesa-glx git numactl linux-tools-common ipmitool -y && \
    apt-get --fix-broken install -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends locales python3-pip python-is-python3 tzdata gdb tcpdump tmux neovim htop && \
    locale-gen en_US.UTF-8

ENV TZ=Asia/Shanghai
USER HwHiAiUser


#######################################################################################
# docker build -t cann --target cann .
#######################################################################################
FROM base AS cann

ARG DEVICE
ARG ARCH
ARG CANN_VERSION

RUN echo "source ~/Ascend/ascend-toolkit/set_env.sh" >> ~/.bashrc && \
    echo "source ~/Ascend/nnal/atb/set_env.sh" >> ~/.bashrc && \
    wget -q http://172.17.0.1:3000/Ascend-cann-toolkit_${CANN_VERSION}_linux-${ARCH}.run -P ~/ && \
    wget -q http://172.17.0.1:3000/Ascend-cann-kernels-${DEVICE}_${CANN_VERSION}_linux-${ARCH}.run -P ~/ && \
    wget -q http://172.17.0.1:3000/Ascend-cann-nnal_${CANN_VERSION}_linux-${ARCH}.run -P ~/ && \
    wget -q http://172.17.0.1:3000/install_cann.sh -P ~/ && \
    cd ~ && \
    bash install_cann.sh && \
    rm -rf ~/*.run ~/install_*.sh


#######################################################################################
# docker build -t pta --target pta .
#######################################################################################
FROM cann AS pta

ARG DEVICE
ARG ARCH
ARG TORCH_VERSION

ENV PATH=$PATH:/home/HwHiAiUser/.local/bin

RUN wget -q http://172.17.0.1:3000/pytorch_v${TORCH_VERSION}_py310.tar.gz -P ~/ && \
    wget -q http://172.17.0.1:3000/torch-${TORCH_VERSION}-cp310-cp310-manylinux_2_17_${ARCH}.manylinux2014_${ARCH}.whl -P ~/ && \
    wget -q http://172.17.0.1:3000/requirements-${TORCH_VERSION}.txt -P ~/ && \
    wget -q http://172.17.0.1:3000/install_pta.sh -P ~/ && \
    cd ~ && \
    pip install -r requirements-${TORCH_VERSION}.txt --no-cache-dir && \
    bash install_pta.sh && \
    pip cache purge && \
    rm -rf ~/*.tar.gz ~/*.whl ~/*.txt ~/torch ~/install_*.sh


#######################################################################################
# docker build -t mindie --target mindie .
#######################################################################################
FROM pta AS mindie

ARG DEVICE
ARG ARCH
ARG TORCH_VERSION
ARG MINDIE_VERSION

RUN echo "source ~/Ascend/mindie/set_env.sh" >> ~/.bashrc && \
    echo "source ~/Ascend/llm_model/set_env.sh" >> ~/.bashrc && \
    echo 'export PYTHONPATH=$PYTHONPATH:~/.local/lib/python3.10/site-packages' >> ~/.bashrc && \
    wget -q http://172.17.0.1:3000/Ascend-mindie_${MINDIE_VERSION}_linux-${ARCH}.run -P ~/ && \
    wget -q http://172.17.0.1:3000/Ascend-mindie-atb-models_${MINDIE_VERSION}_linux-${ARCH}_torch${TORCH_VERSION}-abi0.tar.gz -P ~/ && \
    wget -q http://172.17.0.1:3000/install_mindie.sh -P ~/ && \
    cd ~/ && \
    bash install_mindie.sh && \
    sed -i 's|export PYTORCH_INSTALL_PATH=.*|export PYTORCH_INSTALL_PATH=~/.local/lib/python3.10/site-packages/torch|' ~/Ascend/llm_model/set_env.sh && \
    sed -i 's|export PYTORCH_NPU_INSTALL_PATH=.*|export PYTORCH_NPU_INSTALL_PATH=~/.local/lib/python3.10/site-packages/torch_npu|' ~/Ascend/llm_model/set_env.sh && \
    pip cache purge && \
    rm -rf ~/*.run ~/*.tar.gz ~/install_*.sh


#######################################################################################
# docker build -t ms --target ms .
#######################################################################################
FROM mindie AS ms

ARG MS_VERSION
ARG MF_VERSION

RUN wget -q http://172.17.0.1:3000/mindspore-${MS_VERSION}-cp310-cp310-linux_aarch64.whl -P ~/ && \
    wget -q http://172.17.0.1:3000/mindformers-${MF_VERSION}-py3-none-any.whl -P ~/ && \
    wget -q http://172.17.0.1:3000/install_ms.sh -P ~/ && \
    cd ~/ && \
    bash install_ms.sh && \
    pip cache purge && \
    rm -rf ~/*.whl ~/install_*.sh


#######################################################################################
# docker build -t prod --target prod .
#######################################################################################
FROM ms AS prod

RUN wget -q http://172.17.0.1:3000/start.sh -P ~/ && \
    wget -q http://172.17.0.1:3000/usage.md -P ~/ && \
    wget -q http://172.17.0.1:3000/build.md -P ~/ && \
    wget -q http://172.17.0.1:3000/health_monitor.sh -P ~/ && \
    wget -q http://172.17.0.1:3000/health_probe.sh -P ~/ && \
    pip config --user set global.index https://mirrors.aliyun.com/pypi && \
    pip config --user set global.index-url https://mirrors.aliyun.com/pypi/simple && \
    pip config --user set global.trusted-host mirrors.aliyun.com && \
    chmod +x ~/start.sh ~/health_monitor.sh

ENTRYPOINT ["/home/HwHiAiUser/start.sh"]