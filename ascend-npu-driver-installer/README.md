# 如何使用容器安装 NPU 驱动

## 依赖

- ascend-npu-driver-installer 基础镜像:

- [NPU 驱动 zip 包下载](https://www.hiascend.com/developer/download/commercial/result?module=cann)

- 宿主机已安装 `docker` 和 `kernel-headers`、`kernel-dev`

## 加载 ascend-npu-driver-installer 基础镜像

请参考 已适配 OS 拉取对应的版本的镜像。

如果使用 `docker pull ascend-npu-driver-installer:openeuler-22.03` 已经拉取了基础镜像，忽略本段。  
如果是下载的基础镜像压缩包，需要提前使用 docker 进行加载。  
基础镜像名按 CPU 架构做区分：

- ascend-npu-driver-installer_x86_64.tar.gz
- ascend-npu-driver-installer_aarch64.tar.gz

使用命令 `docker load -i {镜像名}` 来加载基础镜像。  
如：`docker load -i ascend-npu-driver-installer-openeuler-22.03_aarch64.tar.gz`

完成后，可以通过 `docker images` 查看当前系统所有的镜像。

## 启动容器进行 NPU 驱动安装

`
docker run --privileged -it -d -v /lib:/mnt/lib -v /lib/modules:/lib/modules -v /usr/src:/usr/src -v /usr/local:/mnt/usr/local -v /root/.bashrc:/host_bashrc -v /etc:/mnt/etc -v {npu_zip_folder}:/app/npu_driver_zip -e "KO_COMPILE=0" --name npu-installer-container ascend-npu-driver-installer:{version}
`

启动命令详解：

命令 | 作用 
-- | -- 
--privileged | 特权容器，容器安装驱动必须要
-v /lib:/mnt/lib | 将宿主机 /lib 挂在到容器中 /mnt/lib 中
-v /lib/modules:/lib/modules  | 将宿主机 /lib/modules 挂在到容器 /lib/modules 中，用于安装和编译 ko 文件
-v /usr/src:/usr/src | 将宿主机 /usr/src 挂在到容器 /usr/src 中，实际的 kernel 映射地址
-v /usr/local:/mnt/usr/local  | 将宿主机 /usr/loca 挂在到容器 /mnt/usr/local 中，驱动的相关数据会放到这里
-v /root/.bashrc:/host_bashrc | 将宿主机 /root/.bashrc 挂在到容器 /host_bashrc 中，添加启动项，用于激活 npu-smi 等命令
-v /etc:/mnt/etc | 将宿主机 /etc 挂在到容器 /mnt/etc 中，部分 npu 参数会放到这里
-v {npu_zip_folder}:/app/npu_driver_zip | 将宿主机中 npu 驱动 zip 包挂在到容器 /app/npu_driver_zip 中，处理驱动信息
-e "KO_COMPILE=0" | 环境变量，1 则通过 make 编译的方式编译 ko 文件，其他则是通过 repack 的方式获取 ko

需要修改的参数说明：

- 请将 {npu_zip_folder} 替换为 NPU 驱动 zip 包所在的文件夹， 如果 /home/huawei/npu_driver_zip 中有多个 npu 驱动包，那么会随机选择一个进行安装。
- 请将 {version} 替换为实际的镜像版本，如 `openeuler-22.03` 或 `ubuntu-20.04`, 可以通过 `docker images | grep ascend-npu-driver-installer` 进行查看。
- 如果宿主机是 openeuler 24.03，请将 KO_COMPILE 设置成 1

## 查询结果

可以通过 `docker logs -f npu-installer-container` 查看运行情况。  
如果看到：`NPU driver installed successfully.` 即代表 NPU 驱动安装成功。

可以通过 `npu-smi info` 查看 NPU 信息。  

## 已适配 OS

OS | 适配镜像 | 备注
-- | -- | --
`OpenEuler 20.03` | `ascend-npu-driver-installer:openeuler-22.03` |
`OpenEuler 22.03` | `ascend-npu-driver-installer:openeuler-22.03` |
`OpenEuler 24.03` | `ascend-npu-driver-installer:openeuler-24.03` | KO_COMPILE=1
`Ubuntu 20.04` | `ascend-npu-driver-installer:ubuntu-20.04` |
`Ubuntu 22.04` | `ascend-npu-driver-installer:openeuler-22.03` |
`CTYunOS 23.01` | `ascend-npu-driver-installer:openeuler-22.03` |

## 升级 NPU 驱动

如果是通过驱动安装包或 [Ascend-Deopyer](https://gitee.com/ascend/ascend-deployer) 安装的驱动，则不支持使用拉起容器的方式升级。  
如果是容器化安装的驱动，则将更新的 npu 驱动包放到挂载目录中，重新启动容器即可（需要将就容器删除）。  
注意：升级前，请通过 `npu-smi info` 查看是否有训练任务。

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

### 显示安装完成后，执行 `npu-smi info` 报错

优先尝试重启系统，如果不行，删除当前容器，重新启动新容器。将 "KO_COMPILE=1" 值改为 1

## 自行构建镜像

用户若愿意自行构建镜像，可通过以下命令进行构建：

`docker build -f {dockerfile}-t ascend-npu-driver-installer:{your version} .`

跨平台编译，如在 `x86_64` 平台编译 `aarch64` 架构：  
`docker buildx build --platform linux/arm64 -f {dockerfile -t ascend-npu-driver-installer:{your version} .`
