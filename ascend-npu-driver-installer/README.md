# 如何使用容器安装 NPU 驱动

## 依赖

- ascend-npu-driver-installer 基础镜像:

- [NPU 驱动 zip 包下载](https://www.hiascend.com/developer/download/commercial/result?module=cann)

- 宿主机已安装 `docker` 和 `kernel-headers`、`kernel-dev`

## 加载 ascend-npu-driver-installer 基础镜像

如果使用 `docker pull ascend-npu-driver-installer:openeuler-22.03-lts` 已经拉取了基础镜像，忽略本段。  
如果是下载的基础镜像压缩包，需要提前使用 docker 进行加载。  
基础镜像名按 CPU 架构做区分：

- ascend-npu-driver-installer_x86_64.tar.gz
- ascend-npu-driver-installer_aarch64.tar.gz

使用命令 `docker load -i {镜像名}` 来加载基础镜像。  
如：`docker load -i ascend-npu-driver-installer_aarch64.tar.gz`

完成后，可以通过 `docker images` 查看当前系统所有的镜像。

## 启动容器进行 NPU 驱动安装

`
docker run --privileged -it -d -v /lib:/mnt/lib -v /lib/modules:/lib/modules -v /usr/src/:/usr/src/ -v /usr/local:/usr/local -v /root/.bashrc:/host_bashrc -v /etc:/mnt/etc -v /home/huawei/npu_driver_zip:/app/npu_driver_zip --name npu-installer-container ascend-npu-driver-installer:openeuler-22.03-lts
`

注意，请将 /home/huawei/npu_driver_zip 替换为 NPU 驱动 zip 包所在的文件夹。  
如果 /home/huawei/npu_driver_zip 中有多个 npu 驱动包，那么会随机选择一个进行安装。

## 查询结果

可以通过 `docker logs -f npu-installer-container` 查看运行情况。  
如果看到：`NPU driver installed successfully.` 即代表 NPU 驱动安装成功。

可以通过 `npu-smi info` 查看 NPU 信息。  

## Q&A

### 安装完成后执行 `npu-smi info` 提示命令未找到

1. 执行 `source ~/.bashrc` 再次尝试
2. 重新打开一个命令行窗口，再试。

### 安装完成之后执行 `npu-smi info` 报错

请执行 `reboot` 重启

### 使用容器安装驱动后，再使用 [`Ascend-Deployer`](https://gitee.com/ascend/ascend-deployer) 安装，`npu-smi info` 报错

当前不支持使用容器安装后，再通过 [`Ascend-Deployer`](https://gitee.com/ascend/ascend-deployer) 安装。可以将当前的驱动删除后，进行安装：

1. `rm -rf /usr/local/Ascend`
2. ```rm -rf /lib/modules/`uname -r`/npu_driver```

### 安装提示：`[INFO]Do you want to try build driver after input kernel absolute path? [y/n]:`

这种情况是未安装 `kernel-dev` 和 `kernel-headers`, 安装方式：
`debian`/`ubuntu`:
```shell
sudo apt update
sudo apt install -y linux-headers-$(uname -r)
```

`openeuler`/`euler`/`ctyunos`/`bclinux`/`centos`:

```shell
sudo yum install -y kernel-devel-$(uname -r) linux-headers-$(uname -r)
```

### 安装 `linux-headers` 和 `linux-dev` 之后还是安装 NPU 驱动失败

请检查安装的版本是否和本机内核版本是否一致。可通过 `uname -r` 查看本机内核版本。


## 自行构建镜像

用户若愿意自行构建镜像，可通过以下命令进行构建：

`docker build -t ascend-npu-driver-installer:openeuler-22.03-lts .`

跨平台编译，如在 `x86_64` 平台编译 `aarch64` 架构：  
`docker buildx build --platform linux/arm64 -t ascend-npu-driver-installer:openeuler-22.03-lts .`
