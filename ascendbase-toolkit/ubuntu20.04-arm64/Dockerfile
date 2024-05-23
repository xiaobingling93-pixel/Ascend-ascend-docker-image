FROM ubuntu:20.04

WORKDIR /tmp
ARG PYVERSION
COPY . ./

# 系统包 + Pip3.7
RUN sed -i 's@http://.*.ubuntu.com@http://mirrors.huaweicloud.com@g' /etc/apt/sources.list && \
    apt update && \
    apt install --no-install-recommends ca-certificates -y && \
    apt install --no-install-recommends bc wget -y && \
    apt install --no-install-recommends curl gcc make g++ pkg-config unzip -y && \
    apt install --no-install-recommends libsqlite3-dev libblas3 liblapack3 gfortran vim -y && \
    apt install --no-install-recommends liblapack-dev libblas-dev libhdf5-dev libffi-dev -y && \
    apt install --no-install-recommends libssl-dev zlib1g-dev xz-utils cython3 python3-h5py -y && \
    apt install --no-install-recommends libopenblas-dev libgmpxx4ldbl liblzma-dev -y && \
    apt install --no-install-recommends libicu66 libxml2 pciutils libgl1-mesa-glx libbz2-dev -y && \
    apt clean && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/usr/local/python${PYVERSION}/lib: \
    PATH=/usr/local/python${PYVERSION}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 安装Python
RUN umask 0022  && \
    wget https://repo.huaweicloud.com/python/${PYVERSION}/Python-${PYVERSION}.tar.xz && \
    tar -xf Python-${PYVERSION}.tar.xz && cd Python-${PYVERSION} && ./configure --prefix=/usr/local/python${PYVERSION} --enable-shared && \
    make -j 20 && make install && \
    ln -sf /usr/local/python${PYVERSION}/bin/python3 /usr/bin/python3 && \
    ln -sf /usr/local/python${PYVERSION}/bin/python3 /usr/bin/python && \
    ln -sf /usr/local/python${PYVERSION}/bin/pip3 /usr/bin/pip3 && \
    ln -sf /usr/local/python${PYVERSION}/bin/pip3 /usr/bin/pip && \
    cd .. && \
    rm -rf Python* && \
    mkdir -p ~/.pip  && \
    echo '[global] \n\
    index-url=http://mirrors.aliyun.com/pypi/simple\n\
    trusted-host=mirrors.aliyun.com' >> ~/.pip/pip.conf && \
    pip3 install pip -U

# python包
RUN pip3 install -U pip && \
    pip3 install numpy && \
    pip3 install decorator && \
    pip3 install sympy && \
    pip3 install cffi && \
    pip3 install pyyaml && \
    pip3 install pathlib2 && \
    pip3 install protobuf attrs attr && \
    pip3 install scipy && \
    pip3 install requests psutil absl-py && \
    rm -rf /root/.cache/pip

# 设置环境变量
ENV LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/hdf5/serial:$LD_LIBRARY_PATH
ENV LD_PRELOAD=/lib/aarch64-linux-gnu/libGLdispatch.so.0:$LD_PRELOAD

# 创建lib64下的linker，避免在euler宿主机上运行driver工具出错
RUN if [ ! -d "/lib64" ]; \
    then \
        mkdir /lib64 && ln -sf /lib/ld-linux-aarch64.so.1 /lib64/ld-linux-aarch64.so.1; \
    fi

# 清理临时目录
RUN rm -rf ./*
