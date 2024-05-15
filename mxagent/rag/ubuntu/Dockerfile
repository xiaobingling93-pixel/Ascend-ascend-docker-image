FROM ubuntu:20.04

WORKDIR /tmp
COPY . ./
RUN chmod 777 /tmp
ENV GIT_SSL_NO_VERIFY=1
ENV DEBIAN_FRONTEND=noninteractive
ARG TORCH_VERSION=2.1.0
ARG PLATFORM=910B


RUN apt-get update && apt-get install -y build-essential python3.9 python3.9-dev python3.9-distutils vim tar zip unzip git curl wget dos2unix make gcc g++ ccache gfortran libssl-dev swig ffmpeg libopenblas-dev
RUN curl -k https://bootstrap.pypa.io/get-pip.py | python3.9 &&  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1

RUN wget --no-check-certificate https://cmake.org/files/v3.24/cmake-3.24.3.tar.gz && \
    tar -zxf cmake-3.24.3.tar.gz && \
    cd cmake-3.24.3 && \
    ./bootstrap && make -j && make install

RUN pip3 install --upgrade setuptools && pip3 install numpy==1.26.4 decorator==5.1.1 sympy==1.12 cffi==1.16.0 pyyaml==6.0.1 pathlib2==2.3.7.post1 protobuf==5.26.0 scipy==1.12.0 requests==2.31.0 psutil==5.9.8 absl-py==2.1.0 attrs==23.2.0

RUN pip3 install torch=="${TORCH_VERSION}" torch_npu-"${TORCH_VERSION}"*-cp39-*.whl --index-url https://download.pytorch.org/whl/cpu

RUN pip3 install mxaiagent-*.whl

RUN useradd -d /home/HwHiAiUser -u 1000 -m -s /bin/bash HwHiAiUser && \
    bash Ascend-cann-toolkit*.run --install --quiet && \
    bash Ascend-cann-kernels*.run --install --quiet
ENV ASCEND_HOME_PATH=/usr/local/Ascend/ascend-toolkit/latest
ENV TOOLCHAIN_HOME=/usr/local/Ascend/ascend-toolkit/latest/toolkit
ENV ASCEND_TOOLKIT_HOME=/usr/local/Ascend/ascend-toolkit/latest
ENV ASCEND_OPP_PATH=/usr/local/Ascend/ascend-toolkit/latest/opp
ENV ASCEND_AICPU_PATH=/usr/local/Ascend/ascend-toolkit/latest
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH


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
    cd build/faiss/python && python3 setup.py install --install-lib=/usr/local/lib/python3.9/dist-packages && \
    cd ../../.. && make -C build install && cp ./build/faiss/python/libfaiss_python_callbacks.so ${FAISS_INSTALL_PATH}/lib

RUN bash Ascend-mindxsdk-mxindex_*.run --quiet --install --install-path=/usr/local/Ascend --platform=${PLATFORM}
ENV MX_INDEX_MODELPATH=/home/ascend/modelpath
RUN cd /usr/local/Ascend/mxIndex/ops && ./custom_opp_*.run && mkdir -p /home/ascend/modelpath

ARG FAISS_INSTALL_PATH=/usr/local/faiss/faiss1.7.4
ARG MXINDEX_INSTALL_PATH=/usr/local/Ascend/mxIndex
ARG PYTHON_HEADER=/usr/include/python3.9/
ARG ASCEND_INSTALL_PATH=/usr/local/Ascend/ascend-toolkit/latest
ARG DRIVER_INSTALL_PATH=/usr/local/Ascend
COPY driver /usr/local/Ascend/driver
RUN cp -r driver /usr/local/Ascend/driver && \
    git clone https://gitee.com/bme_pioneer/ascend-referenceapps.git && \
    cd ascend-referenceapps/mxIndex_samples/faiss-python && \
    swig -python -c++ -Doverride= -module swig_ascendfaiss -I${PYTHON_HEADER} -I${FAISS_INSTALL_PATH}/include -I${MXINDEX_INSTALL_PATH}/include -DSWIGWORDSIZE64 -o swig_ascendfaiss.cpp swig_ascendfaiss.swig && \
    g++ -std=c++11 -DFINTEGER=int -fopenmp -I/usr/local/include -I${ASCEND_INSTALL_PATH}/acllib/include -I${ASCEND_INSTALL_PATH}/runtime/include -I${DRIVER_INSTALL_PATH}/driver/kernel/inc/driver -I${DRIVER_INSTALL_PATH}/driver/kernel/libc_sec/include -fPIC -fstack-protector-all -Wall -Wreturn-type -D_FORTIFY_SOURCE=2 -g -O3 -Wall -Wextra -I${PYTHON_HEADER} -I/usr/local/lib/python3.9/dist-packages/numpy/core/include -I${FAISS_INSTALL_PATH}/include -I${MXINDEX_INSTALL_PATH}/include -c swig_ascendfaiss.cpp -o swig_ascendfaiss.o && \
    g++ -std=c++11 -shared -fopenmp -L${ASCEND_INSTALL_PATH}/acllib/lib64 -L${ASCEND_INSTALL_PATH}/runtime/lib64 -L${DRIVER_INSTALL_PATH}/driver/lib64 -L${DRIVER_INSTALL_PATH}/driver/lib64/common -L${DRIVER_INSTALL_PATH}/driver/lib64/driver -L${FAISS_INSTALL_PATH}/lib -L${MXINDEX_INSTALL_PATH}/lib -Wl,-rpath-link=${ASCEND_INSTALL_PATH}/acllib/lib64:${ASCEND_INSTALL_PATH}/runtime/lib64:${DRIVER_INSTALL_PATH}/driver/lib64:${DRIVER_INSTALL_PATH}/driver/lib64/common:${DRIVER_INSTALL_PATH}/driver/lib64/driver -L/usr/local/lib -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -s -o _swig_ascendfaiss.so swig_ascendfaiss.o -L.. -lascendfaiss -lfaiss -lascend_hal -lacl_retr -lascendcl -lc_sec -lopenblas && \
    python3.9 setup.py build && \
    python3.9 setup.py install --install-lib=/usr/local/lib/python3.9/dist-packages
ENV LD_LIBRARY_PATH=/usr/local/Ascend/mxIndex/lib:/usr/local/faiss/faiss1.7.4/lib:/opt/OpenBLAS/lib:$LD_LIBRARY_PATH

RUN rm -rf ./* && rm -rf /usr/local/Ascend/driver
WORKDIR /root