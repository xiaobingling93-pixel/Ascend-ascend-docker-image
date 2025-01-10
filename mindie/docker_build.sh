docker build \
-f aarch64/Dockerfile.Ubuntu \
--build-arg http_proxy=$http_proxy \
--build-arg https_proxy=$https_proxy \
--build-arg no_proxy=127.0.0.1,*.huawei.com,localhost,local,.local,172.17.0.1 \
--build-arg DEVICE=910b \
--build-arg ARCH=aarch64 \
--build-arg PYTHON_VERSION=3.11.10 \
--build-arg PYTHON_MAJOR_VERSION=3.11 \
--build-arg PYTHON_SHORT_VERSION=311 \
--build-arg PYTHON_MD5=af59e243df4c7019f941ae51891c10bc \
--build-arg CANN_VERSION=8.0.0 \
--build-arg TORCH_VERSION=2.1.0 \
--build-arg MINDIE_VERSION=1.0.0 \
-t mindie:1.0.0-py3.11-800I-A2-aarch64-Ubuntu22.04 \
.
