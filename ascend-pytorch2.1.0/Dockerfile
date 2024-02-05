FROM ubuntu:18.04 as buildtemp

WORKDIR /tmp
COPY . ./

FROM ubuntu:18.04

WORKDIR /tmp

# 安装系统包
RUN sed -i 's@http://.*.ubuntu.com@http://mirrors.huaweicloud.com@g' /etc/apt/sources.list && \
    apt update && \
    apt install --no-install-recommends ca-certificates -y && \
    apt install --no-install-recommends -y bc wget curl gcc make g++ pkg-config unzip libblas3 liblapack3 gfortran \
    vim liblapack-dev libblas-dev libhdf5-dev libffi-dev libssl-dev zlib1g-dev xz-utils libopenblas-dev libgmpxx4ldbl \
    liblzma-dev libicu60 libxml2 pciutils libgl1-mesa-glx libbz2-dev && \
    apt clean && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/usr/local/python3.8.0/lib: \
    PATH=/usr/local/python3.8.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 安装Python+Python包
RUN --mount=type=cache,target=/tmp,from=buildtemp,source=/tmp \
    umask 0022  && \
    groupadd  HwHiAiUser -g 1000 && \
    useradd -d /home/HwHiAiUser -u 1000 -g 1000 -m -s /bin/bash HwHiAiUser && \
    wget https://repo.huaweicloud.com/python/3.8.0/Python-3.8.0.tar.xz && \
    tar -xf Python-3.8.0.tar.xz && cd Python-3.8.0 && ./configure --prefix=/usr/local/python3.8.0 --enable-shared && \
    make -j 20 && make install && \
    ln -sf /usr/local/python3.8.0/bin/python3 /usr/bin/python3 && \
    ln -sf /usr/local/python3.8.0/bin/python3 /usr/bin/python && \
    ln -sf /usr/local/python3.8.0/bin/pip3 /usr/bin/pip3 && \
    ln -sf /usr/local/python3.8.0/bin/pip3 /usr/bin/pip && \
    cd .. && \
    rm -rf Python* && \
    mkdir -p ~/.pip  && \
    echo '[global] \n\
    index-url=http://mirrors.aliyun.com/pypi/simple\n\
    trusted-host=mirrors.aliyun.com' >> ~/.pip/pip.conf && \
    pip3 install -U pip && \
    pip3 install -r /tmp/requirements.txt && \
    pip3 install -U /tmp/torch-2.1.0*.whl /tmp/torch_npu-2.1.0*.whl torchvision && \
    rm -rf /root/.cache/pip

ARG ASCEND_BASE=/usr/local/Ascend
ARG TOOLKIT_PATH=$ASCEND_BASE/ascend-toolkit/latest
ENV LD_LIBRARY_PATH=\
$ASCEND_BASE/driver/lib64:\
$ASCEND_BASE/driver/lib64/common:\
$ASCEND_BASE/driver/lib64/driver:\
$ASCEND_BASE/driver/tools/hccn_tool/:\
$TOOLKIT_PATH/opp/built-in/op_impl/ai_core/tbe/op_tiling/lib/linux/x86_64/:\
/usr/lib/x86_64-linux-gnu/hdf5/serial:\
$TOOLKIT_PATH/lib64:\
$LD_LIBRARY_PATH

ENV GLOG_v=2 \
    TBE_IMPL_PATH=$TOOLKIT_PATH/opp/op_impl/built-in/ai_core/tbe \
    PATH=$TOOLKIT_PATH/ccec_compiler/bin:$PATH \
    ASCEND_OPP_PATH=$TOOLKIT_PATH/opp \
    ASCEND_AICPU_PATH=$TOOLKIT_PATH \
    PYTHONPATH=$TBE_IMPL_PATH:$PYTHONPATH

RUN --mount=type=cache,target=/tmp,from=buildtemp,source=/tmp \
    mkdir -p $ASCEND_BASE/driver && \
    bash /tmp/Ascend-cann-toolkit_*.run --quiet --install --install-path=$ASCEND_BASE --install-for-all && \
    bash /tmp/Ascend-cann-kernels-910b_*.run --quiet --install --install-path=$ASCEND_BASE --install-for-all

USER HwHiAiUser
COPY --chown=HwHiAiUser:HwHiAiUser Open_Source_Software_Notice.txt /home/HwHiAiUser/Open_Source_Software_Notice.txt
WORKDIR /home/HwHiAiUser/
