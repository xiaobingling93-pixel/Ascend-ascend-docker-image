# 获取基础镜像
在能够访问Docker Hub的网络环境中执行：
```sh
docker pull ubuntu:22.04
```
执行以下命令检查Ubuntu镜像是否拉取成功：
```sh
docker images | grep ubuntu
```

# 获取软件包
正确组织的文件夹内容应当如下：
```
.
├── build.md
├── docker
│   ├── docker_build.sh
│   ├── Dockerfile
│   └── Dockerfile.ms
├── Ascend-cann-kernels-910b_8.0.RC3_linux.run
├── Ascend-cann-nnal_8.0.RC3_linux-aarch64.run
├── Ascend-cann-toolkit_8.0.RC3_linux-aarch64.run
├── Ascend-mindie_1.0.RC3_linux-aarch64.run
├── Ascend-mindie-atb-models_1.0.RC3_linux-aarch64_torch2.1.0-abi0.tar.gz
├── install_cann.sh
├── install_mindie.sh
├── install_ms.sh
├── install_pta.sh
├── mindformers-1.3.0-py3-none-any.whl
├── mindspore-2.4.0-cp310-cp310-linux_aarch64.whl
├── pytorch_v2.1.0_py310.tar.gz
├── README.md
├── requirements-2.1.0.txt
├── server.js
├── start.sh
├── usage.md
└── torch-2.1.0-cp310-cp310-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
```
联系相关人员获取软件包，以下是各软件包所属组件。

## CANN
```
Ascend-cann-kernels-910b_8.0.RC3_linux.run
Ascend-cann-nnal_8.0.RC3_linux-aarch64.run
Ascend-cann-toolkit_8.0.RC3_linux-aarch64.run
```
## PTA
```
pytorch_v2.1.0_py310.tar.gz
torch-2.1.0-cp310-cp310-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
```
## MindIE
```
Ascend-mindie_1.0.RC3_linux-aarch64.run
Ascend-mindie-atb-models_1.0.RC3_linux-aarch64_torch2.1.0-abi0.tar.gz
```
## MindSpore
```
mindformers-1.3.0-py3-none-any.whl
mindspore-2.4.0-cp310-cp310-linux_aarch64.whl
```

# 镜像构建说明
## 安装Node.js

首先安装Node.js，用于启动下载服务供镜像构建时使用。访问官网：[Download Node.js](https://nodejs.org/en/download/prebuilt-binaries/current)，假设下载了`node-vXX.X.X-linux-x64.tar.xz`文件：

1. 上传至服务器
2. 解压并移动文件

    解压并移动至/usr/local或其他合适的位置。
    ```sh
    tar -xf node-vXX.X.X-linux-x64.tar.xz
    sudo mv node-vXX.X.X-linux-x64 /usr/local/nodejs
    ```
3. 添加至环境变量

    修改~/.bashrc或其他合适文件。
    ```sh
    export PATH=/usr/local/nodejs/bin:$PATH
    ```
    然后更新配置以生效
    ```sh
    source ~/.bashrc
    ```
4. 验证安装

    ```sh
    node -v
    ```

## 启动服务

    使用Node.js启动服务
    ```
    node server.js
    ```

## 开始构建
    设置`docker_build.sh`中的**版本参数（以及代理）**，并启动脚本：
    ```
    cd docker/
    bash docker_build.sh
    ```