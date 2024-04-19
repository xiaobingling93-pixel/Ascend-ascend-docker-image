FROM openeuler-20.03-lts-sp2:latest

ARG PYVERSION

WORKDIR /tmp
COPY . ./

# 安装编译环境
RUN yum install -y bc wget gcc gcc-c++ make libtool zlib zlib-devel bzip2 bzip2-devel pcre sudo libffi-devel mesa-libGL\
    pcre-devel pcre2-devel perl-devel perl-ExtUtils-Embed openssl openssl-devel python-pip which lzma xz-devel sqlite-devel&& \
    yum clean all && \
    rm -rf /var/cache/yum

ENV LD_LIBRARY_PATH=/usr/local/python${PYVERSION}/lib: \
    PATH=/usr/local/python${PYVERSION}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 安装Python
RUN umask 0022  && \
    wget https://repo.huaweicloud.com/python/${PYVERSION}/Python-${PYVERSION}.tgz && \
    tar -xf Python-${PYVERSION}.tgz && cd Python-${PYVERSION} && ./configure --prefix=/usr/local/python${PYVERSION} --enable-shared && \
    make && make install && \
    ln -sf /usr/local/python${PYVERSION}/bin/python3 /usr/bin/python3 && \
    ln -sf /usr/local/python${PYVERSION}/bin/python3 /usr/bin/python && \
    ln -sf /usr/local/python${PYVERSION}/bin/pip3 /usr/bin/pip3 && \
    ln -sf /usr/local/python${PYVERSION}/bin/pip3 /usr/bin/pip && \
    cd .. && \
    rm -rf Python* && \
    mkdir -p ~/.pip  && \
    echo -e '[global] \n\
    index-url=http://mirrors.aliyun.com/pypi/simple\n\
    trusted-host=mirrors.aliyun.com' >> ~/.pip/pip.conf && \
    pip3 install pip -U

# python包
RUN pip3 install -U pip && \
    pip3 install decorator numpy kiwisolver matplotlib \
    sympy cffi pyyaml pathlib2 cython cycler grpcio grpcio-tools && \
    pip3 install protobuf attrs attr scipy requests psutil absl-py mpmath Pillow && \
    pip3 install pycocotools && \
    rm -rf /root/.cache/pip

# 清理临时目录
RUN rm -rf ./*
