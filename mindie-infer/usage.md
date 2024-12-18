> 注意，该镜像中包含的健康探测，启动脚本等功能，均为项目定制，在后续版本中功能可能失效，请注意甄别与修改。

# 获取镜像
参考[构建指南](./build.md)自行构建镜像，或者联系相关人员获取。
# 加载镜像
如果是自行构建的镜像，则无需加载。

如果是获取到的镜像压缩包，例如`mindie_aarch64-800T.tar.gz`，则运行如下命令：
```sh
docker load -i mindie_aarch64-800T.tar.gz
```
加载完成之后，请使用`docker images`命令查找具体镜像名称与标签。

# 容器启动命令
**注意同步修改挂载目录`/path-to-weights`与模型路径：**
例如模型权重在/data/weights/Qwen1.5-72B-Chat，同时其他模型权重也在/data/weights路径下，那么建议挂载/data/weights，也就是`-v /data/weights:/data/weights`，同时设置模型路径为`--model /data/weights/Qwen1.5-72B-Chat`。然后执行以下启动命令：
```sh
docker run --net=host --shm-size=1g \
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
    -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
    -v /usr/local/sbin:/usr/local/sbin \
    -v /path-to-weights:/path-to-weights \
    mindie:aarch64-800T \
    --model /path-to-weights/Qwen1.5-72B-Chat
```

执行命令后，首先会打印本次启动所用的所有参数，然后直到出现以下输出：
```
Daemon start success!
```
则认为服务成功启动。

通过修改`mindie:aarch64-800T`后的参数（比如`--model`参数），来实现不同的操作，比如切换后端，指定NPU卡等。

更多信息可参考官网信息：[MindIE Server](https://www.hiascend.com/document/detail/zh/mindie/10RC2/mindieservice/servicedev/mindie_service0034.html)

## 服务框架参数

在启动MindIE Server服务时，除了通过 `--model` 参数来指定模型权重路径（**必须是本地权重路径**，目前不支持在线下载模型），还可以配置以下参数来优化服务性能和定制运行环境，更多参数说明请参考[配置参数说明文档](https://www.hiascend.com/document/detail/zh/mindie/10RC2/mindieservice/servicedev/mindie_service0004.html)：

1. **`--backend`**  
   - **说明**：指定后端类型，不同的后端类型会影响模型的执行方式。  
   - **默认值**：`"atb"`  
   - **取值规范**：字符串类型，取值范围为`"atb"`或`"ms"`。

2. **`--model`**  
   - **说明**：设置模型的本地权重路径，系统会从此路径加载模型。  
   - **默认值**：`"/path-to-weights/model-name"`  
   - **取值规范**：字符串类型，路径必须指向有效的本地模型文件夹。

3. **`--model-name`**  
   - **说明**：指定模型的名称，用户可以通过此参数直接设置模型名称。  
   - **默认值**：模型权重路径中的文件夹名称（通过`--model`路径提取）。  
   - **取值规范**：字符串类型，如果未指定，将自动从`--model`的路径中提取名称。

4. **`--max-seq-len`**  
   - **说明**：设定最大序列长度，输入长度与输出长度之和应小于等于此值。根据推理场景选择合适的长度。  
   - **默认值**：`2560`  
   - **取值规范**：整数类型，表示允许的最大序列长度。

5. **`--max-iter-times`**  
   - **说明**：指定最大迭代次数，用于推理生成的最大token个数限制。  
   - **默认值**：`512`  
   - **取值规范**：整数类型，与`--max-seq-len`相关，表示最大生成长度。

6. **`--max-input-token-len`**  
   - 说明：设置最大输入的 token 长度。  
   - 默认值：`2048`
   - 取值规范：整数类型。

7. **`--max-prefill-tokens`**  
   - 说明：设置预填充的最大 token 数量。  
   - 默认值：`8192`
   - 取值规范：整数类型。

8. **`--npu-device-ids`**  
   - **说明**：指定用于推理的NPU设备ID列表。  
   - **默认值**：取决于系统配置，会自动识别可用的设备。  
   - **取值规范**：字符串类型，包含设备ID的逗号分隔列表（如`"0,1,2,3"`）。

9. **`--world-size`**  
   - **说明**：指定参与推理的设备总数。  
   - **默认值**：根据系统配置自动计算。  
   - **取值规范**：整数类型，表示推理时使用的设备数量，如果手动配置了`--npu-device-ids`，必须要保证此项与其数量一致。

10. **`--template-type`**
   - **说明**：指定模板类型，用于Splitfuse相关操作。  
   - **默认值**：`"Standard"`  
   - **取值规范**：字符串类型，可选列表："Standard"，"SplitwisePrefill"，"SplitwiseDecode"，"Mix"。

11. **`--max-preempt-count`**  
   - **说明**：每一批次最大可抢占请求的上限，即限制一轮调度最多抢占请求的数量，取值大于0则表示开启可抢占功能。。  
   - **默认值**：`0`  
   - **取值规范**：整数类型，[0, `maxBatchSize`]，当取值大于0时，cpuMemSize取值不可为0。

12. **`--support-select-batch`**  
   - **说明**：batch选择策略：`false`表示每一轮调度时，优先调度和执行prefill阶段的请求。`true`表示每一轮调度时，根据当前prefill与decode请求的数量，自适应调整prefill和decode阶段请求调度和执行的先后顺序。 
   - **默认值**：`false`  
   - **取值规范**：布尔类型，`true`或`false`。

13. **`--npu-mem-size`**  
   - **说明**：每个NPU设备的内存大小，单位为GB，指定为`-1`时自动分配。  
   - **默认值**：`-1`，当后端为`ms`时，默认值为`8`
   - **取值规范**：整数类型，指定NPU设备的内存大小。

14. **`--max-prefill-batch-size`**  
   - **说明**：预填充阶段的最大批处理大小，该参数主要是在明确需要限制prefill阶段batch size的场景下使用。  
   - **默认值**：`50`  
   - **取值规范**：整数类型，指定每次推理时的最大输入批量大小。

15. **`--ip`**  
   - **说明**：设置服务的监听IP地址。  
   - **默认值**：`"0.0.0.0"`  
   - **取值规范**：字符串类型，必须是合法的IP地址。

16. **`--port`**  
   - **说明**：设置服务的监听端口。  
   - **默认值**：`9811`  
   - **取值规范**：整数类型，合法的端口范围为1025到65535。

17. **`--management-ip`**  
   - **说明**：设置管理服务的IP地址。  
   - **默认值**：`"0.0.0.0"`  
   - **取值规范**：字符串类型，合法的IP地址。

18. **`--management-port`**  
   - **说明**：设置管理服务的监听端口。  
   - **默认值**：`9811`  
   - **取值规范**：整数类型，合法端口范围为1025到65535。

19. **`--metrics-port`**  
   - **说明**：设置用于暴露指标的监听端口。  
   - **默认值**：`9812`  
   - **取值规范**：整数类型，合法的端口范围为1025到65535，**注意不得与`--management-port`设为相同值**。

20. **`--self-healing-timeout`**  
   - **说明**：自愈机制的最大超时时间，单位为“秒”，总共超时时间计算公式：10 + 20 + 40 + ... + 最大时长 + 重试次数 * 重试间隔。  
   - **默认值**：`0`  
   - **取值规范**：数值类型，不小于零，设置为`0`将关闭自愈机制，如果设置为0至10之间，会被默认修改为10，如果超过600，则会被修改为最大值600。

22. **`--self-healing-init-time`**  
   - **说明**：设定启动自愈机制之前的等待时长，单位为“秒”，需要根据网络速度（如拉取在线权重）、模型大小来综合判断。  
   - **默认值**：`1800`  
   - **取值规范**：数值类型，不小于零。

23. **`--self-healing-retry-interval`**  
   - **说明**：设定自愈机制中每两次健康监测之间的间隔时间，单位为“秒”。  
   - **默认值**：`60`  
   - **取值规范**：数值类型，不小于零。

24. **`--self-healing-restart-time`**  
   - **说明**：设定健康监测失败，重启服务后，在重启自愈机制之前等待的时间，单位为“秒”。  
   - **默认值**：`240`  
   - **取值规范**：数值类型，不小于零。

# 监控运维

现在所有的日志的全部会打印至标准输出终端（一般来讲也就是屏幕），如需保存日志，需要自行重定向输出来进行保存。

从宿主机上访问容器中的日志，可以执行以下命令：
```sh
docker logs -f <container-id>
```

# 如何切换后端
默认使用ATB作为后端，修改`--backend`参数可以修改后端框架，例如：
```sh
docker run --net=host --shm-size=1g \
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
    -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
    -v /usr/local/sbin:/usr/local/sbin \
    -v /path-to-weights:/path-to-weights \
    mindie:aarch64-800T \
    --model /path-to-weights/Qwen1.5-72B-Chat \
    --backend ms
```

# 如何指定NPU卡
直接修改挂载的`--device`，即可指定使用哪些卡。

**注意，只能挂载1/2/4/8这样的数量，不能挂载3/5/6/7这样的数量。**
```sh
docker run --net=host --shm-size=1g \
    --device=/dev/davinci_manager \
    --device=/dev/hisi_hdc \
    --device=/dev/devmm_svm \
    --device=/dev/davinci0 \
    --device=/dev/davinci2 \
    -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
    -v /usr/local/sbin:/usr/local/sbin \
    -v /path-to-weights:/path-to-weights \
    mindie:aarch64-800T \
    --model /path-to-weights/Qwen1.5-72B-Chat
```
此时便指定了服务框架将在0号和2号卡上运行。

# 如何在单机上启动多实例
目前支持在单机上启动多个容器，各自挂载不同设备，具体有以下几点要求：

- 单一容器只挂载需要使用的设备，比如只想使用前两张卡：
    ```sh
    docker run --net=host --shm-size=1g \
    --device=/dev/davinci_manager \
    --device=/dev/hisi_hdc \
    --device=/dev/devmm_svm \
    --device=/dev/davinci0 \
    --device=/dev/davinci1 \
    ...
    ```
- 不能设置`--ipc==host`，会导致进程间通信出问题，第一个容器可以启动，第二个容器就无法启动，必须设置`--shm-size=1g`。
- 多个容器之间的端口不能冲突，包括`--port`，`--management-port`和`--metrics-port`。

下面给出一个具体的例子，首先是第一个容器启动，使用6和7卡：
```sh
docker run --net=host --shm-size=1g \
--device=/dev/davinci_manager \
--device=/dev/hisi_hdc \
--device=/dev/devmm_svm \
--device=/dev/davinci6 \
--device=/dev/davinci7 \
-v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
-v /usr/local/sbin:/usr/local/sbin \
-v /data/weights:/data/weights \
mindie:aarch64-800T \
--model /data/weights/chatglm3_6b \
--port 9811 \
--management-port 9811 \
--metrics-port 9812
```
等待第一个容器启动成功后，再使用以下命令启动第二个容器，使用4和5卡：
```sh
docker run --net=host --shm-size=1g \
--device=/dev/davinci_manager \
--device=/dev/hisi_hdc \
--device=/dev/devmm_svm \
--device=/dev/davinci4 \
--device=/dev/davinci5 \
-v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
-v /usr/local/sbin:/usr/local/sbin \
-v /data/weights:/data/weights \
mindie:aarch64-800T \
--model /data/weights/chatglm3_6b \
--port 9813 \
--management-port 9813 \
--metrics-port 9814
```

# 常见问题

## 驱动与用户属组问题
使用本镜像需要保证“在宿主机上ID是1001的用户（默认的HwHiAiUser）可以使用设备”，也就是说需要保证ID为1001的用户（一般就是HwHiAiUser）可以执行`npu-smi`指令，正确识别设备。如果ID为1001的用户无法使用，需要重装驱动并添加`--install-for-all`参数。


## 权重路径权限问题
注意保证权重路径是可用的，执行以下命令修改权限，**注意是整个父级目录的权限**：
```sh
chown -R HwHiAiUser:HwHiAiUser /path-to-weights
chmod -R 750 /path-to-weights
```

## 权重文件内容问题
注意检查权重文件和官方权重保持一致，不得残留任何外来文件或临时文件，避免服务启动失败。

## 进程间通信参数问题
请优先使用`--shm-size=1g`参数，避免使用`--ipc=host`参数，已知后者可能会出现空间不足，导致多实例启动失败等问题。

## 服务启动失败后行为
如果想在服务启动失败后停留在容器内排查问题，可以在`docker run`命令后添加`-it`参数，添加后，如果服务启动失败，则会进入/bin/bash，方便调试。如果不添加，则默认服务启动失败后容器终止。但是如果默认启动了`--self-healing-enabled`，则无法自动退回至bash。

## 检查用户与权限

启动容器后，`docker exec -it <container-id> bash`进入容器，发现命令提示符前缀为`HwHiAiUser`，则证明为非root用户运行，如下：
```sh
HwHiAiUser@localhost:~$
```

## Jmeter输出乱码
如果遇到Jmeter请求返回乱码的问题，请在Jmeter中添加`BeanShell PostProcessor`并添加`prev.setDataEncoding("UTF-8");`，使其使用`UTF-8`解码，即可正常显示中文。
