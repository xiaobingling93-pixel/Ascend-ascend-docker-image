FROM ascendhub.huawei.com/public-ascendhub/centos:7.6.1810

ENV LD_LIBRARY_PATH=/usr/lib64
WORKDIR /tmp
COPY . ./
RUN chmod 777 /tmp
# 安装编译环境
RUN yum makecache && \
    yum -y install gcc gcc-c++ make && \
    yum -y install epel-release && \
    yum -y install wget zlib-devel bzip2 bzip2-devel openssl-devel ncurses-devel \
    openssh-clients \
    sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel \
    xz-devel libffi-devel hdf5-devel patch pciutils zlib zlib-devel xz-devel lzma libuuid uuid-devel && \
    yum clean all && \
    rm -rf /var/cache/yum

# 安装gcc-9.3.0
RUN wget --no-check-certificate https://ftp.gnu.org/gnu/gcc/gcc-9.3.0/gcc-9.3.0.tar.gz && \
    tar -zxf gcc-9.3.0.tar.gz && \
    cd gcc-9.3.0 && \
    wget --no-check-certificate https://mirrors.huaweicloud.com/gnu/gmp/gmp-6.1.0.tar.bz2 && \
    wget --no-check-certificate https://mirrors.huaweicloud.com/gnu/mpfr/mpfr-3.1.4.tar.bz2 && \
    wget --no-check-certificate https://mirrors.huaweicloud.com/gnu/mpc/mpc-1.0.3.tar.gz && \
    wget --no-check-certificate https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2 && \
    ./contrib/download_prerequisites && \
    mkdir build && \
    cd build && \
    ../configure --enable-checking=release --enable-language=c,c++ --disable-multilib --prefix=/usr/local/gcc-9.3.0 && \
    make -j && make -j install && cd .. && \
    rm -rf gcc-9.3.0*

ENV LD_LIBRARY_PATH=/usr/local/gcc-9.3.0/lib64:$LD_LIBRARY_PATH
ENV PATH=/usr/local/gcc-9.3.0/bin:$PATH

# 安装make
RUN wget --no-check-certificate https://mirrors.ustc.edu.cn/gnu/make/make-4.3.tar.gz && \
    tar -zxf make-4.3.tar.gz && \
    cd make-4.3 && \
    ./configure --prefix=/usr/local/make-4.3 && make -j && make install && \
    rm -rf ../make-4.3*
ENV PATH=/usr/local/make-4.3/bin:$PATH
RUN yum remove -y gcc gcc-c++ make

# 安装cmake
RUN wget --no-check-certificate https://cmake.org/files/v3.29/cmake-3.29.0-rc2.tar.gz && \
    tar -zxf cmake-3.29.0-rc2.tar.gz && \
    cd cmake-3.29.0-rc2 && \
    ./bootstrap && make -j && make install && \
    rm -rf ../cmake-3.29.0-rc2* && cd

# 安装openssl
RUN wget --no-check-certificate https://www.openssl.org/source/openssl-1.1.1w.tar.gz && \
    tar zxvf openssl-1.1.1w.tar.gz && \
    cd openssl-1.1.1w && \
    ./config --prefix=/usr/local/openssl-1.1.1 && \
    make -j && make install
ENV LD_LIBRARY_PATH=/usr/local/openssl-1.1.1/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/local/openssl-1.1.1/bin:$PATH

# 安装python
RUN wget --no-check-certificate https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz && \
    tar -xf Python-3.9.18.tgz && \
    cd Python-3.9.18 && \
    mkdir build && cd build && \
    ../configure --enable-shared --prefix=/usr/local/python3.9.18 --with-openssl=/usr/local/openssl-1.1.1 && \
    make -j && make install && \
    cd .. && rm -rf build && cd .. && rm -rf Python-3.9.18* && \
    ldconfig

ENV PATH=/usr/local/python3.9.18/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/python3.9.18/lib:$LD_LIBRARY_PATH

# python包
RUN pip3 install -U pip && \
    pip3 install numpy && \
    pip3 install decorator && \
    pip3 install sympy && \
    pip3 install cffi && \
    pip3 install pyyaml && \
    pip3 install pathlib2 && \
    pip3 install protobuf && \
    pip3 install scipy && \
    pip3 install requests && \
    pip3 install psutil && \
    pip3 install absl-py && \
    pip3 install attrs && \
    pip3 install langchain==0.0.354 && \
    pip3 install langchain_community && \
    pip3 install torch==2.1.0 && \
    pip3 install transformers==4.32.0 && \
    rm -rf /root/.cache/pip

# CANN安装
ARG ASCEND_BASE=/usr/local/Ascend
ARG TOOLKIT_PKG=Ascend-cann-toolkit*.run
ARG KERNEL_PKG=Ascend-cann-kernels*.run
RUN yum install -y which && \
    useradd -d /home/HwHiAiUser -u 1000 -m -s /bin/bash HwHiAiUser && \
    bash $TOOLKIT_PKG --install --quiet && \
    bash $KERNEL_PKG --install --quiet && \
    rm -f $TOOLKIT_PKG && \
    rm -f $KERNEL_PKG

# 安装OpenBLAS
RUN yum install -y gcc-gfortran perl && \
    yum remove -y gcc gcc-c++ && \
    wget --no-check-certificate https://github.com/xianyi/OpenBLAS/archive/v0.3.10.tar.gz -O OpenBLAS-0.3.10.tar.gz && \
    tar -xf OpenBLAS-0.3.10.tar.gz && \
    cd OpenBLAS-0.3.10 && \
    make FC=gfortran USE_OPENMP=1 -j && make install && \
    ldconfig

ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH

# torch_npu包
RUN wget --no-check-certificate https://gitee.com/ascend/pytorch/releases/download/v5.0.1-pytorch2.1.0/torch_npu-2.1.0.post1-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl && \
    pip3 install torch_npu-2.1.0.post1-cp39-cp39-manylinux_2_17_aarch64.manylinux2014_aarch64.whl

# swig 安装
RUN wget --no-check-certificate https://downloads.sourceforge.net/swig/swig-4.0.2.tar.gz && \
    tar zxf swig-4.0.2.tar.gz && \
    cd swig-4.0.2 && \
    ./configure --prefix=/usr/local/swig-4.0.2 && \
    make -j && make -j install
ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH
ENV PATH=/usr/local/python3.9.18/bin:/usr/local/swig-4.0.2/bin:$PATH

# 安装mxIndex faiss
ARG FAISS_INSTALL_PATH=/usr/local/faiss/faiss1.7.1
ARG PYTHON=/usr/local/python3.9.18/bin/python3.9
RUN wget https://github.com/facebookresearch/faiss/archive/v1.7.1.tar.gz --no-check-certificate && \
    tar -xf v1.7.1.tar.gz

RUN arch="$(uname -m)" \
    && if [ "${arch}" = "aarch64" ]; then \
        gcc_version="$(gcc -dumpversion)" \
        && if [ "${gcc_version}" = "4.8.5" ];then \
            sed -i '20i /*' /usr/src/utils/simdlib.h \
            && sed -i '24i */' /usr/src/utils/simdlib.h \
            && sed -i '/vdups_laneq_f32/s/vdups_laneq_f32/vdups_lane_f32/g' /usr/src/utils/distances_simd.cpp; \
            fi; \
        fi

RUN cd faiss-1.7.1/faiss && \
    sed -i "118 i virtual void search_with_filter (idx_t n, const float *x, idx_t k, float *distances, idx_t *lables, const void *mask = nullptr) const {}" /tmp/faiss-1.7.1/faiss/Index.h && \
    sed -i "39 i template <typename IndexT> IndexIDMapTemplate<IndexT>::IndexIDMapTemplate (IndexT *index, std::vector<idx_t> &ids): index (index), own_fields (false) { this->is_trained = index->is_trained; this->metric_type = index->metric_type; this->verbose=index->verbose; this->d = index->d; id_map = ids;}" /tmp/faiss-1.7.1/faiss/MetaIndexes.cpp && \
    sed -i "33 i explicit IndexIDMapTemplate (IndexT *index, std::vector<idx_t> &ids);" /tmp/faiss-1.7.1/faiss/MetaIndexes.h

RUN cd faiss-1.7.1/ && \
    cmake -B build . -DFAISS_ENABLE_GPU=OFF -DPython_EXECUTABLE=${PYTHON} -DBUILD_TESTING=OFF -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${FAISS_INSTALL_PATH} && \
    make -C build -j faiss && \
    make -C build -j swigfaiss && \
    cd build/faiss/python && python3 setup.py install && \
    cd ../../.. && \
    make -C build install
RUN cp faiss-1.7.1/build/faiss/python/libfaiss_python_callbacks.so ${FAISS_INSTALL_PATH}/lib64

ENV LD_LIBRARY_PATH=/usr/local/faiss/faiss1.7.1/lib64:$LD_LIBRARY_PATH


# 安装mxIndex
RUN chmod +x Ascend-mindxsdk-mxindex_6.0.RC1_linux-aarch64.run && \
    ./Ascend-mindxsdk-mxindex_6.0.RC1_linux-aarch64.run --check && \
    ./Ascend-mindxsdk-mxindex_6.0.RC1_linux-aarch64.run --quiet --install --install-path=/usr/local/Ascend --platform=910B
ENV LD_LIBRARY_PATH=/usr/local/Ascend/mxIndex-6.0.RC1/lib:$LD_LIBRARY_PATH
ENV ASCEND_HOME=/usr/local/Ascend
ENV ASCEND_OPP_PATH=/usr/local/Ascend/ascend-toolkit/latest/opp
RUN cd /usr/local/Ascend/mxIndex-6.0.RC1 && \
    cd ops && ./custom_opp_aarch64.run && \
    cd ../tools

# 安装ascendfaiss
ENV GIT_SSL_NO_VERIFY=1
ARG PYTHON_INSTALL_PATH=/usr/local/python3.9.18
ARG FAISS_INSTALL_PATH=/usr/local/faiss/faiss1.7.1
ARG MXINDEX_INSTALL_PATH=/usr/local/Ascend/mxIndex-6.0.RC1
ARG OPENBLAS_INSTALL_PATH=/opt/OpenBLAS
ARG PYTHON_HEADER=$(python3-config --cflags | awk '{print $1}')
ARG ASCEND_INSTALL_PATH=/usr/local/Ascend/ascend-toolkit/latest
ARG DRIVER_INSTALL_PATH=/usr/local/Ascend
COPY driver /usr/local/Ascend/driver

RUN yum -y install git unzip && \
    git clone https://gitee.com/bme_pioneer/ascend-referenceapps.git && \
    cd ascend-referenceapps/mxIndex_samples/faiss-python && swig -python -c++ -Doverride= -module swig_ascendfaiss -I${PYTHON_HEADER} -I${FAISS_INSTALL_PATH}/include -I${MXINDEX_INSTALL_PATH}/include -DSWIGWORDSIZE64 -o swig_ascendfaiss.cpp swig_ascendfaiss.swig && \
    g++ -std=c++11 -DFINTEGER=int -fopenmp -I/usr/local/include -I${ASCEND_INSTALL_PATH}/acllib/include -I${ASCEND_INSTALL_PATH}/runtime/include -I${DRIVER_INSTALL_PATH}/driver/kernel/inc/driver -I${DRIVER_INSTALL_PATH}/driver/kernel/libc_sec/include -fPIC -fstack-protector-all -Wall -Wreturn-type -D_FORTIFY_SOURCE=2 -g -O3 -Wall -Wextra -I${PYTHON_INSTALL_PATH}/include/python3.9 -I${PYTHON_INSTALL_PATH}/lib/python3.9/site-packages/numpy/core/include -I${FAISS_INSTALL_PATH}/include -I${MXINDEX_INSTALL_PATH}/include -c swig_ascendfaiss.cpp -o swig_ascendfaiss.o && \
    g++ -std=c++11 -shared -fopenmp -L${ASCEND_INSTALL_PATH}/acllib/lib64 -L${ASCEND_INSTALL_PATH}/runtime/lib64 -L${DRIVER_INSTALL_PATH}/driver/lib64 -L${DRIVER_INSTALL_PATH}/driver/lib64/common -L${DRIVER_INSTALL_PATH}/driver/lib64/driver -L${FAISS_INSTALL_PATH}/lib64 -L${OPENBLAS_INSTALL_PATH}/lib -L${MXINDEX_INSTALL_PATH}/lib -Wl,-rpath-link=${ASCEND_INSTALL_PATH}/acllib/lib64:${ASCEND_INSTALL_PATH}/runtime/lib64:${DRIVER_INSTALL_PATH}/driver/lib64:${DRIVER_INSTALL_PATH}/driver/lib64/common:${DRIVER_INSTALL_PATH}/driver/lib64/driver -L/usr/local/lib -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -s -o _swig_ascendfaiss.so swig_ascendfaiss.o -L.. -lascendfaiss -lfaiss -lascend_hal -lacl_retr -lascendcl -lc_sec -lopenblas && \
    ${PYTHON_INSTALL_PATH}/bin/python3.9 setup.py build && \
    ${PYTHON_INSTALL_PATH}/bin/python3.9 setup.py install && \
    cd ${PYTHON_INSTALL_PATH}/lib/python3.9/site-packages && \
    unzip faiss-1.7.1-py3.9.egg

# 设置环境变量
RUN echo "export LD_LIBRARY_PATH=/usr/local/openssl-1.1.1/lib:/usr/local/Ascend/mxIndex-6.0.RC1/host/lib:/usr/local/faiss/faiss1.7.1/lib64:/usr/local/Ascend/driver/lib64/driver:/opt/OpenBLAS/lib:/usr/local/Ascend/driver/lib64/driver:/opt/OpenBLAS/lib:/usr/local/python3.9.18/lib:/usr/local/gcc-9.3.0/lib64:/usr/lib64" >> /etc/profile && \
    echo "export PATH=/usr/local/openssl-1.1.1/bin:/usr/local/python3.9.18/bin:/usr/local/swig-4.0.2/bin:/usr/local/gcc-9.3.0/bin:/usr/local/make-4.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> /etc/profile && \
    echo "source /usr/local/Ascend/ascend-toolkit/set_env.sh" >> /etc/profile

RUN yum -y install gcc gcc-c++ && unlink /usr/bin/gcc && unlink /usr/bin/g++
CMD ["source" "/etc/profile"]

# 清理临时目录
RUN rm -rf ./* && rm -rf /usr/local/Ascend/driver