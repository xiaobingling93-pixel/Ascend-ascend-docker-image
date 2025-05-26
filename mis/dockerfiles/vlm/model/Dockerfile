ARG BASE_IMAGE=mis-vlm-base:0.1
FROM ${BASE_IMAGE}

WORKDIR /opt/mis

ARG MODEL=Qwen2.5-VL-7B-Instruct
ENV MIS_MODEL=MindSDK/${MODEL}
ENV MIS_SERVED_MODEL_NAME=${MODEL}

ENV ASCEND_HOME_PATH /usr/local/Ascend/ascend-toolkit/latest
ENV ASCEND_OPP_PATH /usr/local/Ascend/ascend-toolkit/latest/opp
ENV LD_LIBRARY_PATH /usr/local/Ascend/ascend-toolkit/latest/tools/aml/lib64:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH /usr/local/Ascend/ascend-toolkit/latest/tools/aml/lib64/plugin:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH /usr/local/Ascend/ascend-toolkit/latest/lib64:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH /usr/local/Ascend/ascend-toolkit/latest/lib64/plugin/opskernel:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH /usr/local/Ascend/ascend-toolkit/latest/lib64/plugin/nnengine:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH /usr/local/Ascend/ascend-toolkit/latest/opp/built-in/op_impl/ai_core/tbe/op_tiling/lib/linux/aarch64:$LD_LIBRARY_PATH

COPY build/mis*.whl ./
COPY build/configs ./configs/

RUN pip3 install mis*.whl
RUN pip3 install openmind_hub

CMD ["mis_run"]