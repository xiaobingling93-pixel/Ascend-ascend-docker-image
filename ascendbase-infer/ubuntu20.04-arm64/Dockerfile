FROM ubuntu:20.04

WORKDIR /tmp
COPY . ./

RUN sed -i 's@http://.*.ubuntu.com@http://mirrors.huaweicloud.com@g' /etc/apt/sources.list && \
    apt update && \
    apt install --no-install-recommends pciutils -y && \
    apt clean && \
    if [ ! -d "/lib64" ]; \
    then \
        mkdir /lib64 && ln -sf /lib/ld-linux-aarch64.so.1 /lib64/ld-linux-aarch64.so.1; \
    fi && \
    rm -rf ./*
