FROM centos:7

ARG LIBSTDCXX=libstdc++.so.6.0.24
WORKDIR /tmp
COPY . ./

RUN sed -i "s@gpgcheck=1@gpgcheck=0@g" /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i "s@mirrorlist@#mirrorlist@g" /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i "s@#baseurl=http://mirror.centos.org/altarch@baseurl=http://mirrors.huaweicloud.com/centos-altarch@g" /etc/yum.repos.d/CentOS-Base.repo && \
    yum update -y && \
    yum makecache && \
    yum install -y pciutils && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    cp -f ./$LIBSTDCXX /lib64/ && \
    chmod +x /lib64/$LIBSTDCXX && \
    ldconfig && \
    rm -rf ./* && \
    echo "export LC_ALL=en_US.UTF-8"  >> ~/.bashrc && localedef -i en_US -f UTF-8 en_US.UTF-8
