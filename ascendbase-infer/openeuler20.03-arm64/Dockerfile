FROM openeuler-20.03-lts-sp2:latest

WORKDIR /tmp
COPY . ./

# 安装编译环境
RUN yum install -y pciutils sudo&& \
    sed -i '$d' /etc/bashrc && \
    yum clean all && \
    rm -rf /var/cache/yum
