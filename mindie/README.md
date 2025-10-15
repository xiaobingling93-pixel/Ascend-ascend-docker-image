# MindIE镜像构建工程

## 项目简介

此仓库提供了用于构建多平台/架构的 MindiE 镜像的脚本。用户可以根据需要准备好所需的软件包，修改相关配置并构建镜像。

## 前提条件
### 1. 网络连接

在整个构建过程中，必须保持稳定的网络连接。此构建工程依赖于在线下载多个资源，包括但不限于 Python 源码、编译工具以及各种依赖，无法离线构建。

### 2. Docker

- **推荐版本**：Docker 20.10.x 及以上
- **最低版本要求**：Docker 19.03.x
- **安装方式**：请参考 [Docker 官方安装文档](https://docs.docker.com/engine/install/) 进行安装。

> **注意**：确保 Docker 服务正在运行，并且您具有执行 Docker 命令的权限。可通过运行 `docker --version` 来确认当前版本。

### 3. Node.js

- **推荐版本**：Node.js 18.x LTS 或更高版本
- **最低版本要求**：Node.js 16.x LTS
- **安装方式**：请参考 [Node.js 官方下载页面](https://nodejs.org/en/download/) 获取最新的 LTS 版本并安装。使用官方预先编译好的程序足以满足本项目中的轻度使用需求，也可以使用 `nvm`（Node Version Manager）来管理不同版本的 Node.js。

> **注意**：确认安装成功后，可运行 `node --version` 来检查安装的版本。

### 4. 其他注意事项

此构建工程主要面向具备一定技术能力的用户。**如果您想使用本仓库进行轻度的定制工作，您应具备以下基础能力和知识：**

- **Docker 使用经验**：对 Docker 的基本操作有充分的了解，特别是构建镜像时使用的参数及其作用，理解和调整它们以满足不同的构建需求，并且了解 Dockerfile 的基本语法。
- **Linux 系统基础知识**：对 Linux 操作系统有一定了解，包括但不限于文件系统、命令行操作以及其他基本操作。
- **配置与调试能力**：定制工作涉及到不同文件的修改和调试，用户应能根据需求编辑配置文件（如修改 `docker_build.sh` 脚本或 `Dockerfile`），并能够根据错误信息进行调试和修复。请确保在执行每一步操作时，仔细阅读文档，确认所需的每一项配置和参数无误。

## 目录结构

**本仓库仅包含必须的脚本文件，不包含任何软件包，以下展示的目录结构是自行获取软件包之后的情况。**

**目前`Ascend-mindie-atb-models_*.tar.gz`软件包属于定向开源，请按照官方指南获取。**

**其中各变量对应构建脚本`docker_build.sh`中的参数，须在脚本中设定好对应的参数才可开始构建。**

```sh
.
├── Ascend-cann-kernels-${DEVICE}_${CANN_VERSION}_linux-${ARCH}.run
├── Ascend-cann-nnal_${CANN_VERSION}_linux-${ARCH}.run
├── Ascend-cann-toolkit_${CANN_VERSION}_linux-${ARCH}.run
├── Ascend-mindie_${MINDIE_VERSION}_linux-${ARCH}.run
├── Ascend-mindie-atb-models_${MINDIE_VERSION}_linux-${ARCH}_py${PYTHON_SHORT_VERSION}_torch${TORCH_VERSION}-abi0.tar.gz
├── docker_build.sh
├── README.md
├── requirements-${TORCH_VERSION}.txt
├── server.js
├── torch-${TORCH_VERSION}+cpu-cp${PYTHON_SHORT_VERSION}-cp${PYTHON_SHORT_VERSION}-linux_${ARCH}.whl
├── torch_npu-${TORCH_VERSION}.post10*-cp${PYTHON_SHORT_VERSION}-cp${PYTHON_SHORT_VERSION}-manylinux_2_17_${ARCH}.manylinux2014_${ARCH}.whl
├── aarch64
│   ├── Dockerfile.openEuler
│   └── Dockerfile.Ubuntu
└── x86_64
    ├── Dockerfile.openEuler
    └── Dockerfile.Ubuntu
```

---

例如针对以下的构建脚本 `docker_build.sh`：
```sh
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
```
正确的目录结构是：
```sh
.
├── Ascend-cann-kernels-910b_8.0.0_linux-aarch64.run
├── Ascend-cann-nnal_8.0.0_linux-aarch64.run
├── Ascend-cann-toolkit_8.0.0_linux-aarch64.run
├── Ascend-mindie_1.0.0_linux-aarch64.run
├── Ascend-mindie-atb-models_1.0.0_linux-aarch64_py311_torch2.1.0-abi0.tar.gz
├── docker_build.sh
├── README.md
├── requirements-2.1.0.txt
├── server.js
├── torch_npu-2.1.0.post10-cp311-cp311-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
├── aarch64
│   ├── Dockerfile.openEuler
│   └── Dockerfile.Ubuntu
└── x86_64
    ├── Dockerfile.openEuler
    └── Dockerfile.Ubuntu
```

## 构建镜像

> 为确保构建过程的顺利进行，建议宿主机与目标镜像中的系统版本保持一致。一般来说，宿主机和镜像系统版本相同将避免潜在的兼容性问题和不必要的构建麻烦。

> 跨架构构建（如在 x86_64 宿主机上构建 aarch64 镜像）较为复杂且对环境有额外要求，通常情况下并不推荐。如果必须进行跨架构构建，请参考官方文档，确保宿主机上已正确配置相关工具和模拟环境，在此不展开指导。

---

在按照前文所述准备好软件包之后，可按以下步骤开始构建：

1. 启动本地服务；
2. 修改配置文件；
3. 启动构建脚本。

以下是各部分详细说明：

1. ### 启动本地服务：
    在本工程文件夹目录下，运行以下命令启动本地服务
    ```sh
    node server.js
    ```

    启动本地服务后，您应该能够看到类似如下输出，表示服务正常启动：

    ```sh
    [2025-01-01T00:00:00.000Z] Server started and listening at http://localhost:3000
    [2025-01-01T00:00:00.000Z] Serving files from directory: /mindie-images
    [2025-01-01T00:00:00.000Z] Please open another window to execute docker_build.sh
    ```

    **请保留此服务程序，不要关闭窗口，在新窗口中执行后续步骤。**在实际构建过程中，出现类似以下输出，表示正在传输文件：

    ```sh
    [2025-01-01T00:00:00.000Z] Incoming request: GET /Ascend-mindie_1.0.0_linux-aarch64.run from ::ffff:172.17.0.3
    [2025-01-01T00:00:00.000Z] Successfully served file: Ascend-mindie_1.0.0_linux-aarch64.run (128794074 bytes)

    ...
    ```
    > **若出现文件获取报错，请检查参数配置是否正确，软件包是否齐全，以及两者名称是否可对应上。**

    ---

    启动本地服务的目的是为了确保在构建过程中，镜像能够从本地服务器获取到对应的软件包。具体而言，Dockerfile 中的 `wget` 命令将从本地服务（而非外部网络）下载之前准备好的软件包。

    #### 作用与目的：
    启动本地服务的核心作用是通过本地网络为构建过程提供所需的软件包，而不是通过 `COPY` 命令将它们直接包含在镜像中。这种方式的优势体现在：
    - **缩减镜像体积**：使用本地服务的方式可以显著减小构建出的镜像体积。例如，构建 `aarch64` 架构镜像时，传统使用 `COPY` 命令直接复制软件包到镜像中，可能导致镜像体积超过 20GB；而采用 `wget` 命令从本地服务动态获取软件包，可以将镜像体积缩减至 13GB 左右。
    - **提高构建效率**：通过本地服务获取软件包，可以减少外部依赖，避免了每次构建时都需要从外部网络下载相同的文件，从而提升构建速度和稳定性。

    #### 与构建过程的关系：
    在 Dockerfile 中，您将看到类似以下的 `wget` 命令：

    ```dockerfile
    RUN wget -q http://172.17.0.1:3000/Ascend-cann-toolkit_${CANN_VERSION}_linux-${ARCH}.run -P /home/mindieuser/package
    ```
    其中，`172.17.0.1:3000` 为本地服务器的地址，wget 命令会从该地址获取对应的软件包并将其存放在指定路径中。
    - **宿主机 IP 地址**：`172.17.0.1` 是 Docker 默认 `bridge` 网络中宿主机的 IP 地址，容器可以通过这个 IP 访问宿主机。**通常情况下不用修改这个IP地址。**
    - **服务端口**：`3000` 是由 `server.js` 文件中固定的端口号，您可以根据需要调整该端口，但通常保持为 `3000` 以便与容器中的命令一致。

2. ### 配置构建参数

    根据自身需要，修改 `docker_build.sh` 中的参数。

    如果想更换Python版本，请填写正确版本号，**以及对应的XZ压缩包的校验值**（可从官网版本发布页获取），例如[Python 3.11.10](https://www.python.org/downloads/release/python-31110/)中所需的值即为 `af59e243df4c7019f941ae51891c10bc`：
    <table style="user-select: auto;">
    <thead style="user-select: auto;">
        <tr style="user-select: auto;">
        <th style="user-select: auto;">Version</th>
        <th style="user-select: auto;">Operating System</th>
        <th style="user-select: auto;">Description</th>
        <th style="user-select: auto;">MD5 Sum</th>
        <th style="user-select: auto;">File Size</th>
        <th style="user-select: auto;">GPG</th>
        <th colspan="2" style="user-select: auto;"><a href="https://www.python.org/download/sigstore/" style="user-select: auto;">Sigstore</a></th>
        </tr>
    </thead>
    <tbody style="user-select: auto;">
        <tr style="user-select: auto;">
        <td style="user-select: auto;"><a href="https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tgz" style="user-select: auto;">Gzipped source tarball</a></td>
        <td style="user-select: auto;">Source release</td>
        <td style="user-select: auto;"></td>
        <td style="user-select: auto;">35c36069a43dd57a7e9915deba0f864e</td>
        <td style="user-select: auto;">25.3&nbsp;MB</td>
        <td style="user-select: auto;"><a href="https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tgz.asc" style="user-select: auto;">SIG</a></td>
        <td colspan="2" style="user-select: auto;"><a href="https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tgz.sigstore" style="user-select: auto;">.sigstore</a></td>
        </tr>
        <tr style="user-select: auto;">
        <td style="user-select: auto;"><a href="https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tar.xz" style="user-select: auto;">XZ compressed source tarball</a></td>
        <td style="user-select: auto;">Source release</td>
        <td style="user-select: auto;"></td>
        <td style="user-select: auto;">af59e243df4c7019f941ae51891c10bc</td>
        <td style="user-select: auto;">19.1&nbsp;MB</td>
        <td style="user-select: auto;"><a href="https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tar.xz.asc" style="user-select: auto;">SIG</a></td>
        <td colspan="2" style="user-select: auto;"><a href="https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tar.xz.sigstore" style="user-select: auto;">.sigstore</a></td>
        </tr>
    </tbody>
    </table>

    > 当前仅有Ubuntu镜像支持更换Python版本，openEuler镜像由于其中的系统工具依赖于默认的Python，暂不推荐更换默认的Python 3.11.6。

    ---

    | 类别               | 参数                                                 | 说明                                    |
    | ------------------ | ---------------------------------------------------- | --------------------------------------- |
    | **构建文件**       | `-f aarch64/Dockerfile.Ubuntu`                       | `-f` 参数指定了使用的 Dockerfile 路径。 |
    | **代理配置**       | `--build-arg http_proxy=$http_proxy`                 | 设置 HTTP 代理地址                      |
    |                    | `--build-arg https_proxy=$https_proxy`               | 设置 HTTPS 代理地址                     |
    |                    | `--build-arg no_proxy=172.17.0.1,localhost,...`      | 设置不需要通过代理的地址或域名          |
    | **Python 配置**    | `--build-arg PYTHON_VERSION=3.11.10`                 | 设置 Python 版本号                      |
    |                    | `--build-arg PYTHON_MAJOR_VERSION=3.11`              | 设置 Python 主版本号                    |
    |                    | `--build-arg PYTHON_SHORT_VERSION=311`               | 设置简化的 Python 版本号                |
    |                    | `--build-arg PYTHON_MD5=af59e243...`                 | 设置 Python 安装包的 SHA256 校验值      |
    | **设备与架构**     | `--build-arg DEVICE=910b`                            | 设置设备版本，需与软件包名对应          |
    |                    | `--build-arg ARCH=aarch64`                           | 设置架构类型，需与软件包名对应          |
    | **软件版本**       | `--build-arg CANN_VERSION=8.0.0`                     | 设置 CANN 版本，需与软件包名对应        |
    |                    | `--build-arg TORCH_VERSION=2.1.0`                    | 设置 PyTorch 版本，需与软件包名对应     |
    |                    | `--build-arg MINDIE_VERSION=1.0.0`                   | 设置 Mindie 框架版本，需与软件包名对应  |
    | **镜像标签与输出** | `-t mindie:1.0.0-py3.11-800I-A2-aarch64-Ubuntu22.04` | 设置构建后的镜像标签                    |
    | **构建上下文**     | `.`                                                  | 指定当前目录作为构建上下文路径          |

3. ### 运行构建脚本：
    准备好后，运行构建脚本：
    ```sh
    bash docker_build.sh
    ```
    根据 Docker 版本不同，将看到不同的回显信息。

    > 若构建中出错，请考虑参考官方 `Docker build` 文档，进行问题定位，例如可以使用 `--no-cache` 与 `--progress plain` （新版本特有）参数，修改 `docker_build.sh` 来帮助查明报错原因。

## 启动容器
### 启动命令
如果您在开发环境中，使用的是root用户镜像（例如从Ascend Hub上取得），并且可以使用特权容器，请使用以下命令启动容器。

**说明：`--privileged` 仅用于开发环境，不能用于生产环境，否则有容器逃逸等安全风险。**
```sh
docker run -it -d --net=host --shm-size=1g \
    --privileged \
    --name <container-name> \
    -v /usr/local/Ascend/driver:/usr/local/Ascend/driver:ro \
    -v /usr/local/sbin:/usr/local/sbin:ro \
    -v /path-to-weights:/path-to-weights:ro \
    mindie:1.0.0-800I-A2-py311-openeuler24.03-lts bash
```

如果您希望使用自行构建的普通用户镜像，并且规避容器相关权限风险，可以使用以下命令指定用户与设备：
```sh
docker run -it -d --net=host --shm-size=1g \
    --user mindieuser:<HDK-user-group> \
    --name <container-name> \
    --device=/dev/davinci_manager \
    --device=/dev/hisi_hdc \
    --device=/dev/devmm_svm \
    --device=/dev/davinci0 \
    --device=/dev/davinci1 \
    --device=/dev/davinci2 \
    --device=/dev/davinci3 \
    --device=/dev/davinci4 \
    --device=/dev/davinci5 \
    --device=/dev/davinci6 \
    --device=/dev/davinci7 \
    -v /usr/local/Ascend/driver:/usr/local/Ascend/driver:ro \
    -v /usr/local/sbin:/usr/local/sbin:ro \
    -v /path-to-weights:/path-to-weights:ro \
    mindie:1.0.0-800I-A2-py311-openeuler24.03-lts bash
```
> 注意，以上启动命令仅供参考，请根据需求自行修改再启动容器，尤其需要注意：
>
> 1. `--user`，如果您的环境中HDK是通过普通用户安装（例如默认的`HwHiAiUser`，可以通过`id HwHiAiUser`命令查看该用户组ID），请设置好对应的用户组，例如用户组1001可以使用HDK，则`--user mindieuser:1001`，镜像中默认使用的是用户组1000。如果您的HDK是由root用户安装，且指定了`--install-for-all`参数，则无需指定`--user`参数。
>
> 2. 设定容器名称`--name`与镜像名称，例如`mindie:1.0.0-800I-A2-py311-openeuler24.03-lts`。
>
> 3. 当不使用`--priviliged`参数时，可通过`--device`参数将主机容器暴露给容器，例如设置NPU卡管理设备和NPU卡设备：
>       ```sh
>       ...
>       --name <container-name> \
>       --device=/dev/davinci_manager \
>       --device=/dev/hisi_hdc \
>       --device=/dev/davinci0 \
>       ...
>       ```
> 4. 设定权重挂载的路径，`-v /path-to-weights:/path-to-weights:ro`，注意，权重路径权限应当设置为750。如果使用普通用户镜像，权重路径所属应为镜像内默认的1000用户。可参考以下命令进行修改：
>       ```sh
>       chmod -R 755 /path-to-weights
>       chown -R 1000:1000 /path-to-weights
>       ```
> 5. **在普通用户镜像中，注意所有文件均在 `/home/mindieuser` 下，请勿直接挂载 `/home` 目录，以免宿主机上存在相同目录，将容器内文件覆盖清除。**

### 进入容器
```sh
docker exec -it <container-name> bash
```

## 检查可用性
### 检验HDK是否可用
输入以下命令，应当正确显示设备信息：
```sh
npu-smi info
```

如果出现以下信息：
```sh
bash: npu-smi: command not found
```
说明宿主机上的 `npu-smi` 工具不在 `/usr/local/sbin` 路径中，可能是由于HDK版本过旧或其他原因导致，可以使用以下命令找到该工具，并在启动容器时将其挂载到容器内：
```sh
find / -name npu-smi
```
一般来说，可能出现在 `/usr/local/bin/npu-smi` 路径下。

### 检验Torch是否可用
启动Python，并输入以下命令：
```python
import torch
import torch_npu
```
若无报错信息，则说明Torch组件正常。

### 检查MindIE各组件
输入以下命令：
```sh
pip list | grep mindie
```
应出现类似如下输出：
```sh
mindie_llm                        1.0.0
mindiebenchmark                   1.0.0
mindieclient                      1.0.0
mindiesd                          1.0.0
mindietorch                       1.0.0+torch2.1.0.abi0
```
或者输入以下命令：
```sh
cat /home/mindieuser/Ascend/mindie/latest/version.info
```
应出现类似如下输出：
```sh
Ascend-mindie : MindIE 1.0.0
mindie-rt: 1.0.0
mindie-torch: 1.0.0
mindie-service: 1.0.0
mindie-llm: 1.0.0
mindie-sd:1.0.0
Platform : aarch64
```
说明各组件正常。

## 开始推理
### 纯模型推理
以Llama 3系列模型为例，具体可参考容器中`$ATB_SPEED_HOME_PATH/examples/models/llama3/README.md`中的说明
```sh
cd $ATB_SPEED_HOME_PATH
python examples/run_pa.py --model_path /path-to-weights
```
> 请修改权重路径`/path-to-weights`，另外`$ATB_SPEED_HOME_PATH`已默认设置好，无需自行设置。

启动后会执行推理，显示默认问题`Question`和推理结果`Answer`，若用户想要自定义输入问题，可使用`--input_texts`参数设置，如：

```shell
python examples/run_pa.py --model_path /path-to-weights --input_texts "What is deep learning?"
```

### 启动服务
MindIE Service是面向通用模型场景的推理服务化框架，通过开放、可扩展的推理服务化平台架构提供推理服务化能力，支持对接业界主流推理框架接口，满足大语言模型的高性能推理需求。请参考[MindIE Service开发指南](https://www.hiascend.com/document/detail/zh/mindie/10RC3/mindieservice/servicedev/mindie_service0001.html)。

以下给出最为简单的启动方法；
1. 修改`$MIES_INSTALL_PATH/conf/config.json`，具体参数含义与配置规则请参考[配置参数说明](https://www.hiascend.com/document/detail/zh/mindie/10RC3/mindieservice/servicedev/mindie_service0215.html)。
2. 使用后台进程方式启动服务：
```sh
cd $MIES_INSTALL_PATH
nohup ./bin/mindieservice_daemon > output.log 2>&1 &
```
3. 在标准输出流捕获到的文件中，打印如下信息说明启动成功:
```sh
Daemon start success!
```
> `$MIES_INSTALL_PATH`已默认设置好，无需自行设置。

## 定制化修改
若有更进一步的定制化需求，可先参考以下内容：
- [定制修改指南](./CUSTOMIZATION.md) - 深入了解 MindIE 镜像构建的高级技巧和复杂场景
