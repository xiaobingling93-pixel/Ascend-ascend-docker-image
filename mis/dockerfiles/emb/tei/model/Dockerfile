ARG BASE_IMAGE=mis-tei-base:0.1
FROM ${BASE_IMAGE}

ARG ARCH=aarch64
ARG PLATFORM=910B

RUN pip3 install uvicorn pydantic==v2.11.3 fastapi

COPY --chown=HwHiAiUser:HwHiAiUser build/config.json /home/HwHiAiUser

RUN wget -q http://172.17.0.1:3000/mis-7.1+t2-cp311-cp311-linux_${ARCH}.whl -P /tmp && pip3 install /tmp/mis-7.1+t2-cp311-cp311-linux_${ARCH}.whl && rm -rf /tmp/*

COPY --chown=HwHiAiUser:HwHiAiUser ./start_tei.sh /home/HwHiAiUser
RUN chmod 755 /home/HwHiAiUser/start_tei.sh
USER HwHiAiUser:HwHiAiUser

WORKDIR /home/HwHiAiUser

ENTRYPOINT ["bash", "/home/HwHiAiUser/start_tei.sh"]

CMD ["127.0.0.1", "8080"]