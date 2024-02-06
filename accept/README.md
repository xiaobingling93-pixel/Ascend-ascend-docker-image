# accept介绍

镜像基于ubuntu18.04基础镜像构建，包含训练、集合通信测试、物理算力测试和有效算力验收功能。镜像中包含MindSpore框架、pytorch1.11.0、python3.7.5、toolkit和toolbox软件包，并且内置了用于集群训练的GPT3模型和用于有效算力验收的resnet50、bert-large模型。

## hccl-test集合通信

1. 检查集群环境的健康状态，可使用hccn_tool工具进行检查。
2. 免密配置，主节点需可免密登录其他工作节点，配置方法如下：
```
    ssh-keygen        #生成密钥
    ssh-copy-id -i /root/.ssh/id_rsa.pub root@192.168.150.148  # 复制密钥到要免密登录的设备
```

3. 配置参与集群测试的节点的ssh服务端口，在每个节点的~/.ssh/config文件中添加如下格式内容，Host为参与测试的节点ip，Port统一填33333。
```
    Host 51.38.65.157
    Port 33333
    Host 51.38.68.149
    Port 33333
```
4. 修改hostfile文件，文件位于config目录下，配置格式”节点IP:每节点进程数“，该配置方式仅支持使用IPv4协议进行通信的场景，第一个节点IP为主节点。
```
    # 训练节点ip:每节点进程数
    10.78.130.22：8
    10.78.130.21：8
```
5. 准备hccl_test.sh测试脚本，可参考代码中hccl_test.sh进行修改。
```
    mkdir -p /home/hwtest/hccl
    cp hccl_test.sh /home/hwtest/hccl
```
6. 执行`bash test_model.sh hccl-test`。

## 物理算力测试

## 集群训练

集群训练支持gpt3模型，数据集为enwiki数据集，需从物理机挂载。

1. 默认镜像：`ascendhub.huawei.com/public-ascendhub/accept:6.0.RC1-ubuntu18.04`，可修改image字段来修改使用的镜像。

## 有效算力验收

mindspore-modelzoo镜像作为有效算力验收时使用的镜像，支持resnet50和bert-large模型。

1. 所有待验收节点请获取[mindspore-modelzoo](https://ascendhub.huawei.com/#/detail/mindspore-modelzoo)镜像，镜像版本>=23.0.RC1。
2. 所有节点获取镜像后，选择一个节点作为管理节点，在管理节点获取[有效算力验收工具](https://gitee.com/ascend/ascend-toolbox/tags)，相关使用说明请参考该工具的使用文档。

**有效算力验收镜像中使用文件的来源**：
  |文件|获取方法|
  |:-----------:| :-------------:|
  |run_ais.py|[ascend-toolbox](https://gitee.com/ascend/ascend-toolbox/tree/dev)工具中|
  |train_*Ais-Benchmark-Stubs\*|参考[tools文档](https://gitee.com/ascend/tools/blob/master/ais-bench_workload/doc/ais-bench_workload%E6%9E%84%E5%BB%BA%E6%95%99%E7%A8%8B.md)|
