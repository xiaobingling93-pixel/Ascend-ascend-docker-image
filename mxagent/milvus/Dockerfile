FROM openeuler-22.03-lts-sp3:latest

WORKDIR /tmp
COPY . ./
RUN chmod 777 /tmp
ENV GIT_SSL_NO_VERIFY=1

RUN yum update -y && yum install -y gcc g++ make tar openssl-devel vim libatomic libstdc++-static git openblas-devel python3-pip python3-devel ninja-build && \
    yum install -y net-tools git gfortran tbb tbb-devel boost boost-devel thrift thrift-devel.aarch64 re2 re2-devel zip wget dos2unix unzip ccache xz-devel

# CMAKE
RUN wget --no-check-certificate https://cmake.org/files/v3.24/cmake-3.24.3.tar.gz && \
    tar -zxf cmake-3.24.3.tar.gz && \
    cd cmake-3.24.3 && \
    ./bootstrap && make -j && make install && \
    rm -rf ../cmake-3.24.3* && cd

# GOLANG
RUN wget --no-check-certificate https://golang.google.cn/dl/go1.19.1.linux-arm64.tar.gz && \
    tar -zxf go1.19.1.linux-arm64.tar.gz -C /usr/local
ENV GOROOT=/usr/local/go
ENV GOPATH=/data/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH
ENV GO111MODULE=on

RUN pip3 install numpy==1.26.4 decorator==5.1.1 sympy==1.12 cffi==1.16.0 pyyaml==6.0.1 pathlib2==2.3.7.post1 protobuf==5.26.0 scipy==1.12.0 requests==2.31.0 psutil==5.9.8 absl-py==2.1.0 attrs==23.2.0 conan==1.60.2

RUN conan remote add conancenter https://center.conan.io False -f && \
    conan remote add default-conan-local https://milvus01.jfrog.io/artifactory/api/conan/default-conan-local False -f && \
    sed -i '32s/self._verify_ssl = verify/self._verify_ssl = False/' /usr/local/lib/python3.9/site-packages/conans/client/downloaders/file_downloader.py && \
    cp -f conan_setting.yml ~/.conan/settings.yml

RUN wget --no-check-certificate https://github.com/xianyi/OpenBLAS/archive/v0.3.10.tar.gz -O OpenBLAS-0.3.10.tar.gz && \
    tar -xf OpenBLAS-0.3.10.tar.gz && \
    cd OpenBLAS-0.3.10 && \
    make FC=gfortran USE_OPENMP=1 -j && make install && \
    ldconfig

ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:/usr/lib:$LD_LIBRARY_PATH

ARG FAISS_INSTALL_PATH=/usr/local/faiss/faiss1.7.4
RUN wget https://github.com/facebookresearch/faiss/archive/v1.7.4.tar.gz --no-check-certificate && \
    tar -xf v1.7.4.tar.gz && \
    cd faiss-1.7.4/faiss && \
    sed -i "131 i virtual void search_with_filter (idx_t n, const float *x, idx_t k, float * distances, idx_t *lables, const void *mask = nullptr) const{}" Index.h && \
    sed -i "38 i template <typename IndexT> IndexIDMapTemplate<IndexT>::IndexIDMapTemplate (IndexT *index, std::vector<idx_t> &ids): index (index), own_fields (false) { this->is_trained = index->is_trained; this->metric_type = index->metric_type; this->verbose = index->verbose; this->d = index->d; id_map = ids; }" IndexIDMap.cpp && \
    sed -i "29 i explicit IndexIDMapTemplate (IndexT *index, std::vector<idx_t> &ids);" IndexIDMap.h && \
    sed -i "199 i utils/sorting.h" CMakeLists.txt && \
    cd .. && cmake -B build . -DFAISS_ENABLE_GPU=OFF -DFAISS_ENABLE_PYTHON=OFF -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${FAISS_INSTALL_PATH} && \
    cd build && make -j && make install 

RUN useradd -d /home/HwHiAiUser -u 1000 -m -s /bin/bash HwHiAiUser && \
    bash Ascend-cann-toolkit*.run --install --quiet
ENV ASCEND_HOME_PATH=/usr/local/Ascend/ascend-toolkit/latest
ENV TOOLCHAIN_HOME=/usr/local/Ascend/ascend-toolkit/latest/toolkit
ENV ASCEND_TOOLKIT_HOME=/usr/local/Ascend/ascend-toolkit/latest
ENV ASCEND_OPP_PATH=/usr/local/Ascend/ascend-toolkit/latest/opp
ENV PYTHONPATH=/usr/local/Ascend/ascend-toolkit/latest/python/site-packages:/usr/local/Ascend/ascend-toolkit/latest/opp/built-in/op_impl/ai_core/tbe
ENV ASCEND_AICPU_PATH=/usr/local/Ascend/ascend-toolkit/latest
ENV PATH=/usr/local/Ascend/ascend-toolkit/latest/bin:/usr/local/Ascend/ascend-toolkit/latest/compiler/ccec_compiler/bin:/usr/local/Ascend/ascend-toolkit/latest/tools/ccec_compiler/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN bash Ascend-mindxsdk-mxindex_*.run --quiet --install --install-path=/usr/local/Ascend --platform=910B
ENV MX_INDEX_MODELPATH=/home/ascend/modelpath
RUN cd /usr/local/Ascend/mxIndex/ops && ./custom_opp_aarch64.run && mkdir -p /home/ascend/modelpath

ENV MX_INDEX_HOME=/usr/local/Ascend
ENV ASCEND_DEPEND_FAISS_DIR=/usr/local/faiss/faiss1.7.4
ENV KNOWHERE_SOURCE_DIR=/tmp/knowhere-v2.2.2-ascend
RUN unzip knowhere-v2.2.2-ascend.zip && unzip milvus-v2.3.3-ascend.zip && \
    cd milvus-v2.3.3-ascend && \
    make milvus -j && make install && \
    cd ../ && cp -r milvus-v2.3.3-ascend /usr/local/milvus

ENV PATH=/usr/local/milvus/bin:$PATH
ENV LD_PRELOAD=/usr/local/milvus/lib/libjemalloc.so
ENV LD_LIBRARY_PATH=/usr/lib:/usr/lib64:/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:/usr/lib:/usr/local/Ascend/ascend-toolkit/latest/tools/aml/lib64:/usr/local/Ascend/ascend-toolkit/latest/tools/aml/lib64/plugin:/usr/local/Ascend/ascend-toolkit/latest/lib64:/usr/local/Ascend/ascend-toolkit/latest/lib64/plugin/opskernel:/usr/local/Ascend/ascend-toolkit/latest/lib64/plugin/nnengine:/usr/local/Ascend/ascend-toolkit/latest/opp/built-in/op_impl/ai_core/tbe/op_tiling/lib/linux/aarch64:/usr/local/milvus/lib:/usr/local/Ascend/mxIndex/lib:/usr/local/faiss/faiss1.7.4/lib64:/opt/OpenBLAS/lib

RUN rm -rf ./*
WORKDIR /usr/local/milvus
