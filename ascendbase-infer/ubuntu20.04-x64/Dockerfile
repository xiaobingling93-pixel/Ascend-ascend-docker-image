FROM ubuntu:20.04

WORKDIR /tmp
COPY . ./

RUN sed -i 's@http://.*.ubuntu.com@http://mirrors.huaweicloud.com@g' /etc/apt/sources.list && \
    apt update && \
    apt install --no-install-recommends pciutils -y && \
    apt clean && \
    rm -rf ./*
