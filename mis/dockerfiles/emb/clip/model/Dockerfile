ARG BASE_IMAGE=mis-clip-base:0.1
FROM ${BASE_IMAGE}

ARG ARCH=aarch64
ARG PLATFORM=910B

RUN pip3 install uvicorn pydantic==1.10.21 fastapi

COPY --chown=HwHiAiUser:HwHiAiUser build/config.yaml /home/HwHiAiUser/mis

RUN wget -q http://172.17.0.1/mis-7.1+t2-cp311-cp311-linux_${ARCH}.whl -P /tmp && pip3 install /tmp/is-7.1+t2-cp311-cp311-linux_${ARCH}.whl && rm -rf /tmp/*

COPY --chown=HwHiAiUser:HwHiAiUser ./start_clip.sh /home/HwHiAiUser/mis

USER HwHiAiUser:HwHiAiUser

ENTRYPOINT ["bash", "/home/HwHiAiUser/mis/start_clip.sh"]

CMD ["127.0.0.1", "8080"]