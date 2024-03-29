FROM ubuntu:20.04

WORKDIR /tmp
COPY . ./
RUN chmod 777 /tmp
ENV GIT_SSL_NO_VERIFY=1
ENV DEBIAN_FRONTEND=noninteractive
ARG TORCH_VERSION=2.1.0


RUN apt-get update && apt-get install -y build-essential python3.9 curl python3.9-dev python3.9-distutils \
    python3-pip vim tar zip unzip git wget dos2unix make gcc g++ ccache gfortran libssl-dev swig git unzip wget
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

# cmake
RUN wget --no-check-certificate https://cmake.org/files/v3.24/cmake-3.24.3.tar.gz && \
    tar -zxf cmake-3.24.3.tar.gz && \
    cd cmake-3.24.3 && \
    ./bootstrap && make -j && make install

# 生成index算子的python依赖
RUN pip3 install --upgrade pip setuptools && pip3 install numpy==1.26.4 decorator==5.1.1 sympy==1.12 cffi==1.16.0 \
    pyyaml==6.0.1 pathlib2==2.3.7.post1 protobuf==5.26.0 scipy==1.12.0 requests==2.31.0 psutil==5.9.8 \
    absl-py==2.1.0 attrs==23.2.0

# torch_npu包
RUN pip3 install torch=="${TORCH_VERSION}" torch_npu-"${TORCH_VERSION}"*-cp39-*aarch64.whl

# rag服务依赖
RUN pip3 install gradio==4.19.2 pydantic==2.6.3 urllib3==2.2.1 requests==2.31.0 selenium==4.18.1 flask==3.0.2 loguru==0.7.2 \
    uvicorn==0.27.1 fastapi==0.110.0 transformers==4.36.0 tokenizers==0.15.2 sentence-transformers==2.5.1 fschat==0.2.36 \
    accelerate==0.27.2 pymilvus==2.4.0 && \
    pip3 install bs4==0.0.2 pypdf==4.1.0 openai==1.12.0 markdownify==0.11.6 openai-whisper==20231117 jieba==0.42.1 \
    datasets==2.18.0 rank_bm25==0.2.2 langchain==0.0.354 langchain-community==0.0.19 langchain-core==0.1.23 \
    langsmith==0.0.87 packaging==23.2 PySocks==1.7.1
RUN patch -f /usr/local/lib/python3.9/dist-packages/langchain_community/vectorstores/milvus.py < milvus.patch

# cann-toolkit和kernel
RUN useradd -d /home/HwHiAiUser -u 1000 -m -s /bin/bash HwHiAiUser && \
    bash Ascend-cann-toolkit*.run --install --quiet && \
    bash Ascend-cann-kernels*.run --install --quiet

# OpenBLAS
RUN wget --no-check-certificate https://github.com/xianyi/OpenBLAS/archive/v0.3.10.tar.gz -O OpenBLAS-0.3.10.tar.gz && \
    tar -xf OpenBLAS-0.3.10.tar.gz && \
    cd OpenBLAS-0.3.10 && \
    make FC=gfortran USE_OPENMP=1 -j && make install && \
    ldconfig

ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:$LD_LIBRARY_PATH

#faiss
ARG FAISS_INSTALL_PATH=/usr/local/faiss/faiss1.7.4
RUN wget https://github.com/facebookresearch/faiss/archive/v1.7.4.tar.gz --no-check-certificate && \
    tar -xf v1.7.4.tar.gz && \
    cd faiss-1.7.4/faiss && \
    sed -i "131 i virtual void search_with_filter (idx_t n, const float *x, idx_t k, float *distances, idx_t *lables, const void *mask = nullptr) const{}" Index.h && \
    sed -i "38 i template <typename IndexT> IndexIDMapTemplate<IndexT>::IndexIDMapTemplate (IndexT *index, std::vector<idx_t> &ids): index (index), own_fields (false) { this->is_trained = index->is_trained; this->metric_type = index->metric_type; this->verbose = index->verbose; this->d = index->d; id_map = ids; }" IndexIDMap.cpp && \
    sed -i "29 i explicit IndexIDMapTemplate (IndexT *index, std::vector<idx_t> &ids);" IndexIDMap.h && \
    sed -i "199 i utils/sorting.h" CMakeLists.txt && \
    cd .. && cmake -B build . -DFAISS_ENABLE_GPU=OFF -DPython_EXECUTABLE=/usr/bin/python3 -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${FAISS_INSTALL_PATH} && \
    make -C build -j faiss && \
    make -C build -j swigfaiss && \
    cd build/faiss/python && python3 setup.py install && \
    cd ../../.. && make -C build install && cp ./build/faiss/python/libfaiss_python_callbacks.so ${FAISS_INSTALL_PATH}/lib

# index
RUN bash Ascend-mindxsdk-mxindex_*.run --quiet --install --install-path=/usr/local/Ascend --platform=310P
ENV MX_INDEX_MODELPATH=/home/ascend/modelpath
RUN cd /usr/local/Ascend/mxIndex/ops && ./custom_opp_aarch64.run && mkdir -p /home/ascend/modelpath

# 安装ascendfaiss
ARG FAISS_INSTALL_PATH=/usr/local/faiss/faiss1.7.4
ARG MXINDEX_INSTALL_PATH=/usr/local/Ascend/mxIndex
ARG OPENBLAS_INSTALL_PATH=/opt/OpenBLAS
ARG PYTHON_HEADER=/usr/include/python3.9/
ARG ASCEND_INSTALL_PATH=/usr/local/Ascend/ascend-toolkit/latest
ARG DRIVER_INSTALL_PATH=/usr/local/Ascend
COPY driver /usr/local/Ascend/driver
RUN cp -r driver /usr/local/Ascend/driver && \
    git clone https://gitee.com/bme_pioneer/ascend-referenceapps.git && \
    cd ascend-referenceapps/mxIndex_samples/faiss-python && \
    swig -python -c++ -Doverride= -module swig_ascendfaiss -I${PYTHON_HEADER} -I${FAISS_INSTALL_PATH}/include -I${MXINDEX_INSTALL_PATH}/include -DSWIGWORDSIZE64 -o swig_ascendfaiss.cpp swig_ascendfaiss.swig && \
    g++ -std=c++11 -DFINTEGER=int -fopenmp -I/usr/local/include -I${ASCEND_INSTALL_PATH}/acllib/include -I${ASCEND_INSTALL_PATH}/runtime/include -I${DRIVER_INSTALL_PATH}/driver/kernel/inc/driver -I${DRIVER_INSTALL_PATH}/driver/kernel/libc_sec/include -fPIC -fstack-protector-all -Wall -Wreturn-type -D_FORTIFY_SOURCE=2 -g -O3 -Wall -Wextra -I${PYTHON_HEADER} -I/usr/local/lib/python3.9/dist-packages/numpy/core/include -I${FAISS_INSTALL_PATH}/include -I${MXINDEX_INSTALL_PATH}/include -c swig_ascendfaiss.cpp -o swig_ascendfaiss.o && \
    g++ -std=c++11 -shared -fopenmp -L${ASCEND_INSTALL_PATH}/acllib/lib64 -L${ASCEND_INSTALL_PATH}/runtime/lib64 -L${DRIVER_INSTALL_PATH}/driver/lib64 -L${DRIVER_INSTALL_PATH}/driver/lib64/common -L${DRIVER_INSTALL_PATH}/driver/lib64/driver -L${FAISS_INSTALL_PATH}/lib -L${OPENBLAS_INSTALL_PATH}/lib -L${MXINDEX_INSTALL_PATH}/lib -Wl,-rpath-link=${ASCEND_INSTALL_PATH}/acllib/lib64:${ASCEND_INSTALL_PATH}/runtime/lib64:${DRIVER_INSTALL_PATH}/driver/lib64:${DRIVER_INSTALL_PATH}/driver/lib64/common:${DRIVER_INSTALL_PATH}/driver/lib64/driver -L/usr/local/lib -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -s -o _swig_ascendfaiss.so swig_ascendfaiss.o -L.. -lascendfaiss -lfaiss -lascend_hal -lacl_retr -lascendcl -lc_sec -lopenblas && \
    python3.9 setup.py build && \
    python3.9 setup.py install
ENV LD_LIBRARY_PATH=/usr/local/Ascend/mxIndex/lib:/usr/local/faiss/faiss1.7.4/lib:/opt/OpenBLAS/lib
ENV LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1

RUN rm -rf ./* && rm -rf /usr/local/Ascend/driver
WORKDIR /root