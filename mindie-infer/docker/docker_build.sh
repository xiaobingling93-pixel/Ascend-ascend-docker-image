http_proxy=your-proxy-here

docker build \
--build-arg http_proxy=$http_proxy \
--build-arg https_proxy=$http_proxy \
--build-arg no_proxy=127.0.0.1,localhost,local,.local,172.17.0.1 \
--build-arg DEBIAN_FRONTEND=noninteractive \
--build-arg DEVICE=910b \
--build-arg ARCH=aarch64 \
--build-arg CANN_VERSION=8.0.RC3 \
--build-arg TORCH_VERSION=2.1.0 \
--build-arg MINDIE_VERSION=1.0.RC3 \
--build-arg MS_VERSION=2.4.0 \
--build-arg MF_VERSION=1.3.0 \
-t mindie:aarch64-800T \
--target prod .
