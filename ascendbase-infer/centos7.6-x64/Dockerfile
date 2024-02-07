FROM centos:7

ARG LIBSTDCXX=libstdc++.so.6.0.24
WORKDIR /tmp
COPY . ./

RUN sed -i "s@gpgcheck=1@gpgcheck=0@g" /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i "s@#baseurl=http://mirror.centos.org@baseurl=http://mirrors.huaweicloud.com@g" /etc/yum.repos.d/CentOS-Base.repo && \
    yum update -y && \
    yum makecache && \
    yum install -y pciutils && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    cp -f ./$LIBSTDCXX /lib64/ && \
    chmod +x /lib64/$LIBSTDCXX && \
    ldconfig && \
    rm -rf ./*
