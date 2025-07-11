# <a name="url">免责说明</a>
本代码仓库提供示例镜像构建脚本和Dockerfile给开发者进行参考学习。不建议直接用于生成环境


# <a name="url">构建镜像所需文件获取链接</a>
|                         软件或文件                          |                                                                        获取方法                                                                         |
|:------------------------------------------------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------:|
|     mindspore-2.3.0rc1-cp39-cp39-linux_aarch64.whl      |     [获取链接](https://ms-release.obs.cn-north-4.myhuaweicloud.com/2.3.0rc1/MindSpore/unified/aarch64/mindspore-2.3.0rc1-cp39-cp39-linux_aarch64.whl)      |
|      mindspore-2.3.0rc1-cp39-cp39-linux_x86_64.whl      |      [获取链接](https://ms-release.obs.cn-north-4.myhuaweicloud.com/2.3.0rc1/MindSpore/unified/x86_64/mindspore-2.3.0rc1-cp39-cp39-linux_x86_64.whl)       |
|     Ascend-mindxdl-elastic_6.0.RC1_linux-aarch64.zip     |           [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/MindX%206.0.RC1/Ascend-mindxdl-elastic_6.0.RC1_linux-aarch64.zip)            |
|     Ascend-mindxdl-elastic_6.0.RC1_linux-x86_64.zip      |            [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/MindX%206.0.RC1/Ascend-mindxdl-elastic_6.0.RC1_linux-x86_64.zip)            |
|        torch-1.8.1-cp37-cp37m-linux_aarch64.whl        |                    [获取链接](https://repo.huaweicloud.com/kunpeng/archive/Ascend/PyTorch/torch-1.8.1-cp37-cp37m-linux_aarch64.whl)                     |
|      torch-1.8.1+cpu-cp37-cp37m-linux_x86_64.whl       |                             [获取链接](https://download.pytorch.org/whl/cpu/torch-1.8.1%2Bcpu-cp37-cp37m-linux_x86_64.whl)                              |
|   torch_npu-1.8.1.post2-cp37-cp37m-linux_aarch64.whl   |         [获取链接](https://gitee.com/ascend/pytorch/releases/download/v5.0.rc2-pytorch1.8.1/torch_npu-1.8.1.post2-cp37-cp37m-linux_aarch64.whl)         |
|   torch_npu-1.8.1.post2-cp37-cp37m-linux_x86_64.whl    |         [获取链接](https://gitee.com/ascend/pytorch/releases/download/v5.0.rc2-pytorch1.8.1/torch_npu-1.8.1.post2-cp37-cp37m-linux_x86_64.whl)          |
|       torch-1.11.0-cp39-cp39m-linux_aarch64.whl        |       [获取链接](https://download.pytorch.org/whl/torch-1.11.0-cp39-cp39-manylinux2014_aarch64.whl)        |
|        torch-1.11.0-cp39-cp39m-linux_x86_64.whl        |        [获取链接](https://download.pytorch.org/whl/cpu/torch-1.11.0%2Bcpu-cp39-cp39-linux_x86_64.whl)        |
|  torch_npu-1.11.0.post11-cp39-cp39-linux_aarch64.whl   |        [获取链接](https://gitee.com/ascend/pytorch/releases/download/v6.0.rc1-pytorch1.11.0/torch_npu-1.11.0.post11-cp39-cp39-linux_aarch64.whl)        |
|   torch_npu-1.11.0.post11-cp39-cp39-linux_x86_64.whl   |        [获取链接](https://gitee.com/ascend/pytorch/releases/download/v6.0.rc1-pytorch1.11.0/torch_npu-1.11.0.post11-cp39-cp39-linux_x86_64.whl)         |
| tensorflow-1.15.0-cp37-cp37m-manylinux2010_x86_64..whl | [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/OpenSource/python/packages/tensorflow-1.15.0-cp37-cp37m-manylinux2010_x86_64.whl)  |
| tensorflow-1.15.0-cp37-cp37m-manylinux2014_aarch64.whl | [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/OpenSource/python/packages/tensorflow-1.15.0-cp37-cp37m-manylinux2014_aarch64.whl) |
| tensorflow_cpu-2.6.5-cp39-cp39-manylinux2010_x86_64.whl  |  [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/OpenSource/python/packages/tensorflow_cpu-2.6.5-cp39-cp39-manylinux2010_x86_64.whl)  |
| tensorflow-2.6.5-cp39-cp39-linux_aarch64.whl  | [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com:443/MindX/OpenSource/packages/tensorflow-2.6.5-cp39-cp39-linux_aarch64.whl)  |
|      Ascend-cann-nnrt_8.0.RC1_linux-x86_64.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17SPC703/Ascend-cann-nnrt_8.0.RC1.alpha003_linux-x86_64.run)                |
|      Ascend-cann-toolkit_8.0.RC1_linux-x86_64.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17SPC703/Ascend-cann-toolkit_8.0.RC1.alpha003_linux-x86_64.run)                |
|      Ascend-cann-kernels-910_8.0.RC1_linux.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17SPC703/Ascend-cann-kernels-910_8.0.RC1.alpha003_linux.run)                |
|      Ascend-cann-kernels-910b_8.0.RC1_linux.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17SPC703/Ascend-cann-kernels-910b_8.0.RC1.alpha003_linux.run)                |
|     Ascend-cann-nnrt_8.0.RC1_linux-aarch64.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17SPC703/Ascend-cann-nnrt_8.0.RC1.alpha003_linux-aarch64.run)               |
|     Ascend-cann-toolkit_8.0.RC1_linux-aarch64.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17SPC703/Ascend-cann-toolkit_8.0.RC1.alpha003_linux-aarch64.run)               |
|     Ascend-cann-tfplugin_8.0.RC1_linux-x86_64.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17B800TP025/Ascend-cann-tfplugin_8.0.RC1.alpha003_linux-x86_64.run)               |
|     Ascend-cann-tfplugin_8.0.RC1_linux-aarch64.run         |                [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/Milan-ASL/Milan-ASL%20V100R001C17B800TP025/Ascend-cann-tfplugin_8.0.RC1.alpha003_linux-aarch64.run)               |
|      Ascend-mindx-toolbox_6.0.RC1_linux-aarch64.run      |            [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/MindX%206.0.RC1/Ascend-mindx-toolbox_6.0.RC1_linux-aarch64.run)             |
|      Ascend-mindx-toolbox_6.0.RC1_linux-x86_64.run       |             [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/MindX%206.0.RC1/Ascend-mindx-toolbox_6.0.RC1_linux-x86_64.run)             |
|   Ascend-mindxsdk-mxvision_5.0.RC2_linux-aarch64.run   |        [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/MindX%205.0.RC2/Ascend-mindxsdk-mxvision_5.0.RC2_linux-aarch64.run)         |
|   Ascend-mindxsdk-mxvision_5.0.RC2_linux-x86_64.run    |         [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com/MindX/MindX%205.0.RC2/Ascend-mindxsdk-mxvision_5.0.RC2_linux-x86_64.run)         |
|    h5py-3.1.0-cp39-cp39-linux_aarch64.whl     |    [获取链接](https://ascend-repo.obs.cn-east-2.myhuaweicloud.com:443/MindX/OpenSource/packages/h5py-3.1.0-cp39-cp39-linux_aarch64.whl)     |
|                  libstdc++.so.6.0.24                   |                                              OS为CentOS时，通过find命令查询libstdc++.so.6.0.24文件所在路径，然后从host拷贝。                                              |

# 构建推理容器镜像

## 简介

基于镜像树结构来构建容器镜像，具有可扩展性。推理镜像树示意图如图1所示。

![输入图片说明](assets/133958_ffadd850_8238396.png)

表1 昇腾基础镜像树说明

|       镜像名        |       说明        |
|:----------------:|:---------------:|
| ascendbase-infer |    安装系统组件等。     |
|   ascend-infer   | 安装离线推理引擎包nnrt等。 |

## 前提条件

- 容器场景，需用户自行安装docker（版本要求大于等于18.03）。
- 宿主机已安装驱动和固件，安装操作可参考[《CANN 软件安装指南》](https://www.hiascend.com/document/detail/zh/canncommercial/700/envdeployment/instg/instg_0019.html)。

## 构建推理镜像步骤

1.以root用户登录服务器。

2.构建镜像ascendbase-infer。

a.进入Dockerfile所在路径（请根据实际路径修改）。

```
cd ascendbase-infer/{os}-{arch}
```

其中{os}表示容器镜像操作系统版本，{arch}表示架构，请根据实际情况替换。

b.请在当前目录准备以下文件

表2 所需文件

|         文件          |    说明     |                                            获取方法                                            |
|:-------------------:|:---------:|:------------------------------------------------------------------------------------------:|
|     Dockerfile      |  制作镜像需要。  |                                  已存在于当前目录。用户可根据实际需要自行定制。                                   |
|    EulerOS.repo     | yum源配置文件。 |                                  仅容器镜像OS为EulerOS2.8时需准备。                                   | 
| libstdc++.so.6.0.24 |  动态库文件。   | 仅当容器镜像OS为CentOS时需要准备libstdc++.so.6.0.24文件。可以通过find命令查询libstdc++.so.6.0.24文件所在路径，然后从host拷贝。 |

c.在当前目录执行以下命令构建镜像ascendbase-infer。

```
DOCKER_BUILDKIT=1 docker build -t ascendbase-infer:base_TAG .
```

注意不要遗漏命令结尾的“.”，命令解释如表3所示。
如需在此步骤配置系统网络代理，命令参考如下：

```
DOCKER_BUILDKIT=1 docker build -t ascendbase-infer:base_TAG --build-arg http_proxy=http://proxyserverip:port --build-arg https_proxy=http://proxyserverip:port .
```

其中proxyserverip为代理服务器的ip地址，port为端口。

表3 命令参数说明

|            参数             |                                 说明                                  |
|:-------------------------:|:-------------------------------------------------------------------:|
| ascendbase-infer:base_TAG | 镜像名称与标签，建议将base_TAG命名为“日期-容器OS-架构”（例如“20210106-ubuntu18.04-arm64”）。 |

当出现“Successfully built xxx”表示镜像构建成功。

4.基于镜像ascendbase-infer，构建镜像ascend-infer。
a.进入Dockerfile所在路径（请根据实际路径修改）。

```
cd ascend-infer
```

b.请在当前目录准备以下软件包和相关文件。

表4 所需软件或文件

|                    软件或文件                    |                   说明                   |                获取方法                |
|:-------------------------------------------:|:--------------------------------------:|:----------------------------------:|
| Ascend-cann-nnrt_{version}_linux-{arch}.run | 离线推理引擎包。其中{version}表示软件包版本，{arch}表示架构。 | 可参考<a href="#url">构建镜像所需文件获取链接</a> |
|                 Dockerfile                  |                制作镜像需要。                 |      已存在于当前目录。用户可根据实际需要自行定制。       |
|             ascend_install.info             |               软件包安装日志文件                |             已存在于当前目录。              |
|                version.info                 |             driver包版本信息文件              |             已存在于当前目录。              |

c.在当前目录执行以下命令构建镜像ascend-infer。

```
DOCKER_BUILDKIT=1 docker build -t ascend-infer:infer_TAG --no-cache --build-arg BASE_VERSION=base_TAG --build-arg .
```

注意不要遗漏命令结尾的“.”命令解释如表5所示。

表5 命令参数说明

|           参数           |                                   说明                                    |
|:----------------------:|:-----------------------------------------------------------------------:|
| ascend-infer:infer_TAG | 镜像名称与标签，建议将infer_TAG命名为“软件包版本-容器OS-架构”（例如“20.2.rc1-ubuntu18.04-arm64”）。 |
|      --build-arg       |                           指定dockerfile文件内的参数。                           |
|      BASE_VERSION      |                          base_TAG为3.c中设置的镜像标签。                          |

当出现“Successfully built xxx”表示镜像构建成功。

5.构建完成后，执行以下命令查看镜像信息。

```
docker images
```

# 构建训练镜像步骤

## 简介

本文档基于镜像树结构来构建容器镜像，具有可扩展性。
训练镜像树示意图如图2所示。

图2 训练镜像树示意图

![输入图片说明](assets/asdfsfd.png)

表6 昇腾基础镜像树说明

|        镜像名         |              说明               |
|:------------------:|:-----------------------------:|
| ascendbase-toolkit |     安装系统组件及python第三方依赖等。      |
|   ascend-toolkit   |       安装训练软件包toolkit等。        |
| ascend-tensorflow  | 安装框架插件包tfplugin和Tensorflow框架。 |

## 前提条件

- 容器场景，需用户自行安装docker（版本要求大于等于18.03）。
- openeuler 20.03 的镜像，如果需要可参考以下网址自行获取：
    - aarch64：http://repo.openeuler.org/openEuler-20.03-LTS-SP2/docker_img/aarch64/
    - x86_64：http://repo.openeuler.org/openEuler-20.03-LTS-SP2/docker_img/x86_64/
- 宿主机已安装驱动和固件，详情请参见[《CANN 软件安装指南》](https://www.hiascend.com/document/detail/zh/canncommercial/700/envdeployment/instg/instg_0019.html)。

## 操作步骤

1.以root用户登录服务器。

2.构建镜像ascendbase-toolkit。

a.进入Dockerfile所在路径（请根据实际路径修改）。

```
cd ascendbase-toolkit/{os}-{arch}
```

其中{os}表示容器镜像操作系统版本，{arch}表示架构，请根据实际情况替换。

b.请在当前目录准备以下文件。

表7 所需文件

|         文件          |   说明    |                                            获取方法                                            |
|:-------------------:|:-------:|:------------------------------------------------------------------------------------------:|
|     Dockerfile      | 制作镜像需要。 |                                  已存在于当前目录。用户可根据实际需要自行定制。                                   |
| libstdc++.so.6.0.24 | 动态库文件。  | 仅当容器镜像OS为CentOS时需要准备libstdc++.so.6.0.24文件。可以通过find命令查询libstdc++.so.6.0.24文件所在路径，然后从host拷贝。 |

c.在当前目录执行以下命令构建镜像ascendbase-toolkit。

```
DOCKER_BUILDKIT=1 docker build -t ascendbase-toolkit:base_TAG .
```

注意不要遗漏命令结尾的“.”，命令解释如表8所示。构建镜像时，如果在pip安装python依赖包时出现超时或证书错误，请修改Dockerfile更换pip源。
如需在此步骤配置系统网络代理，命令参考如下：

```
DOCKER_BUILDKIT=1 docker build -t ascendbase-toolkit:base_TAG --build-arg http_proxy=http://proxyserverip:port --build-arg https_proxy=http://proxyserverip:port .
```

其中proxyserverip为代理服务器的ip地址，port为端口。该镜像中的python版本默认为3.10.5，如果需要其他版本，需要额外指定`--build-arg PYVERSION={version}`，并将`{version}`替换为具体的python版本。

表8 命令参数说明

|             参数              |                                 说明                                  |
|:---------------------------:|:-------------------------------------------------------------------:|
| ascendbase-toolkit:base_TAG | 镜像名称与标签，建议将base_TAG命名为“日期-容器OS-架构”（例如“20210106-ubuntu18.04-arm64”）。 |

当出现“Successfully built xxx”表示镜像构建成功。

3.基于镜像ascendbase-toolkit，构建镜像ascend-toolkit。

a.进入Dockerfile所在路径（请根据实际路径修改）。

```
cd ascend-toolkit
```

请在当前目录准备以下软件包和相关文件。

表9 所需软件或文件

|                       软件或文件                        |                    说明                    |                获取方法                |
|:--------------------------------------------------:|:----------------------------------------:|:----------------------------------:|
|   Ascend-cann-toolkit_{version}_linux-{arch}.run   | 深度学习加速引擎包。其中{version}表示软件包版本，{arch}表示架构。 | 可参考<a href="#url">构建镜像所需文件获取链接</a> |
| Ascend-cann-kernels-{910/910b}_{version}_linux.run |        二进制算子包。其中{version}表示软件包版本。        | 可参考<a href="#url">构建镜像所需文件获取链接</a> |
|                     Dockerfile                     |                 制作镜像需要。                  |      已存在于当前目录。用户可根据实际需要自行定制。       |

c.在当前目录执行以下命令构建镜像ascend-toolkit。

```
x86_64: DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:toolkit_TAG --no-cache --build-arg BASE_VERSION=base_TAG .
aarch64: DOCKER_BUILDKIT=1 docker build -t ascend-toolkit:toolkit_TAG --no-cache --build-arg BASE_VERSION=base_TAG -f Dockerfile_aarch64 .
```

注意不要遗漏命令结尾的“.”，命令解释如表4-5所示。

表10 命令参数说明

|             参数             |                                    说明                                     |
|:--------------------------:|:-------------------------------------------------------------------------:|
| ascend-toolkit:toolkit_TAG | 镜像名称与标签，建议将toolkit_TAG命名为“软件包版本-容器OS-架构”（例如“20.2.rc1-ubuntu18.04-arm64”）。 |
|        --build-arg         |                            指定dockerfile文件内的参数。                            |
|        BASE_VERSION        |                           base_TAG为3.c中设置的镜像标签。                           |

当出现“Successfully built xxx”表示镜像构建成功。

4.基于镜像ascend-toolkit，构建镜像ascend-tensorflow。

a.进入Dockerfile所在路径(请根据实际路径修改）。

```
cd ascend-tensorflow
```

b.请在当前目录准备以下软件包和相关文件。

表11 所需软件或文件

|                      软件或文件                      |                  说明                  |                获取方法                |
|:-----------------------------------------------:|:------------------------------------:|:----------------------------------:|
| Ascend-cann-tfplugin_{version}_linux-{arch}.run | 框架插件包。其中{version}表示软件包版本，{arch}表示架构。 | 可参考<a href="#url">构建镜像所需文件获取链接</a> |
|        tensorflow-2.6.5-cp37-cp37m-*.whl        |           tensorflow框架whl包           | 可参考<a href="#url">构建镜像所需文件获取链接</a> |
|                   Dockerfile                    |               制作镜像需要。                |      已存在于当前目录。用户可根据实际需要自行定制。       |
|               ascend_install.info               |              软件包安装日志文件               |             已存在于当前目录。              |
|                  version.info                   |            driver包版本信息文件             |             已存在于当前目录。              |

c.在当前目录执行以下命令构建镜像ascend-tensorflow。

```
DOCKER_BUILDKIT=1 docker build -t ascend-tensorflow:tensorflow_TAG --no-cache --build-arg BASE_VERSION=toolkit_TAG .
```

注意不要遗漏命令结尾的“.”，命令解释如表12所示
如需在此步骤配置系统网络代理，命令参考如下：

```
DOCKER_BUILDKIT=1 docker build -t ascend-tensorflow:tensorflow_TAG --no-cache --build-arg BASE_VERSION=toolkit_TAG --build-arg http_proxy=http://proxyserverip:port --build-arg https_proxy=http://proxyserverip:port .
```

其中proxyserverip为代理服务器的ip地址，port为端口。

表12 命令参数说明

|                参数                |                                      说明                                      |
|:--------------------------------:|:----------------------------------------------------------------------------:|
| ascend-tensorflow:tensorflow_TAG | 镜像名称与标签，建议将tensorflow_TAG命名为“软件包版本-容器OS-架构”（例如“20.2.rc1-ubuntu18.04-arm64”）。 |
|           --build-arg            |                             指定dockerfile文件内的参数。                              |
|           BASE_VERSION           |                           toolkit_TAG为4.c中设置的镜像标签。                           |

当出现“Successfully built xxx”表示镜像构建成功。

5.构建完成后，执行以下命令查看镜像信息。

```
docker images
```

## 公网URL，用于下载系统依赖或python第三方库

```
ubuntu.com
gcc.gnu.org
myhuaweicloud.com
pypi.doubanio.com
bootstrap.pypa.io
repo.huaweicloud.com
mirrors.huaweicloud.com
pypi.mirrors.ustc.edu.cn
mirrors.tuna.tsinghua.edu.cn

```

## 注意事项

- 如果下载系统依赖时官方源太慢的话，可以自行设置其他源。
- 如果pip官方源太慢的话，可以自行设置其他源。

## License

[Apache License 2.0](LICENSE)
