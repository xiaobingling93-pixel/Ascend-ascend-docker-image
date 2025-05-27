# MIS(MindSDK Inference Server)

## llm镜像制作

### 版本说明

- 支持硬件 昇腾Atlas 800I A2

| 组件          | 类型           | 版本                                                                                                                               |
|-------------|--------------|----------------------------------------------------------------------------------------------------------------------------------|
| Ubuntu      | 系统镜像         | 22.04                                                                                                                            |
| cann        | 昇腾异构计算架构和算子库 | [8.0.0.beta1](https://www.hiascend.com/developer/download/community/result?module=cann&cann=8.0.0.beta1)                         |
| mindie      | 昇腾推理引擎       | [1.0.0](https://www.hiascend.com/developer/download/community/result?module=ie+pt+cann&ie=1.0.0&pt=6.0.0.beta1&cann=8.0.0.beta1) |
| vLLM        | 推理框架         | [0.7.1](https://github.com/vllm-project/vllm/tree/v0.7.1)                                                                        |
| vllm-ascend | 昇腾vllm框架支持   | [0.7.1rc1](https://github.com/vllm-project/vllm-ascend/tree/v0.7.1rc1) |

### 构建说明

构建镜像前，需要准备mis发布包，并解压至当前目录
```text
configs/
vlm/
llm/
patch/
```
还需要准备cann，mindie相关软件包，并放置于任意目录
```text
Ascend-cann-toolkit_8.0.0_linux-aarch64.run
Ascend-cann-kernels-910b_8.0.0_linux-aarch64.run
Ascend-cann-nnal_8.0.0_linux-aarch64.run
Ascend-mindie_1.0.0_linux-aarch64.run
Ascend-mindie-atb-models_1.0.0_linux-aarch64_py310_torch2.3.1-abi0.tar.gz
```
准备server.js文件，和上述软件包放置于相同目录，server.js文件见附录
使用以下命令启动服务，此时构建镜像可以通过http的方式下载软件包，减少镜像的大小，nodejs版本无要求
```shell
nodejs server.js
```
回到MIS目录，參考以下命令完成镜像构建
```shell
bash build_image.sh llm-cann mis-llm-cann:0.1
bash build_image.sh llm-base mis-llm-cann:0.1 mis-llm-base:0.1
bash build_image.sh llm-model mis-llm-base:0.1 DeepSeek-R1-Distill-Qwen-7B 0.1
```

## vlm镜像制作

### 版本说明

- 支持硬件 昇腾Atlas 800I A2

| 组件          | 类型           | 版本                                                                                                                                     |
|-------------|--------------|----------------------------------------------------------------------------------------------------------------------------------------|
| Ubuntu      | 系统镜像         | 22.04                                                                                                                                  |
| cann        | 昇腾异构计算架构和算子库 | [8.1.RC1.beta1](https://www.hiascend.com/developer/download/community/result?module=cann&cann=8.1.RC1.beta1)                           |
| mindie      | 昇腾推理引擎       | [2.0.RC1](https://www.hiascend.com/developer/download/community/result?module=ie+pt+cann&ie=2.0.RC1&pt=7.0.0.beta1&cann=8.1.RC1.beta1) |
| vLLM        | 推理框架         | [0.8.5.post1](https://github.com/vllm-project/vllm/tree/v0.8.5.post1)                                                                  |
| vllm-ascend | 昇腾vllm框架支持   | [0.8.5rc1](https://github.com/vllm-project/vllm-ascend/tree/v0.8.5rc1)                                                                 |

### 构建说明

构建镜像前，需要准备mis发布包，并解压至当前目录
```text
configs/
llm/
vlm/
patch/
```
还需要准备cann，mindie相关软件包，并放置于任意目录
```text
Ascend-cann-toolkit_8.1.RC1_linux-aarch64.run
Ascend-cann-kernels-910b_8.1.RC1_linux-aarch64.run
Ascend-cann-nnal_8.1.RC1_linux-aarch64.run
Ascend-mindie_2.0.RC1_linux-aarch64.run
Ascend-mindie-atb-models_2.0.RC1_linux-aarch64_py310_torch2.3.1-abi0.tar.gz
```
准备server.js文件，和上述软件包放置于相同目录，server.js文件见附录
使用以下命令启动服务，此时构建镜像可以通过http的方式下载软件包，减少镜像的大小，nodejs版本无要求
```shell
nodejs server.js
```
回到MIS目录，參考以下命令完成镜像构建
```shell
bash build_image.sh vlm-cann mis-vlm-cann:0.1
bash build_image.sh vlm-base mis-vlm-cann:0.1 mis-vlm-base:0.1
bash build_image.sh vlm-model mis-vlm-base:0.1 Qwen2.5-VL-7B-Instruct 0.1
```

## tei镜像制作

### 版本说明

- 支持硬件 昇腾Atlas 800I A2

| 组件          | 类型           | 版本                                                                                                                                     |
|-------------|--------------|----------------------------------------------------------------------------------------------------------------------------------------|
| Ubuntu      | 系统镜像         | 22.04                                                                                                                                  |
| cann        | 昇腾异构计算架构和算子库 | [8.0.0](https://www.hiascend.com/developer/download/community/result?module=cann&cann=8.0.0)                           |
| tei | 文本向量化推理框架  | [v1.6.1](https://github.com/huggingface/text-embeddings-inference.git)                                                                 |

### 构建说明

构建镜像前，需要准备mis发布包，并解压至当前目录
```text
configs/
llm/
vlm/
patch/
```
还需要准备cann，mindie相关软件包，并放置于任意目录
```text
Ascend-cann-toolkit_8.0.0_linux-aarch64.run
Ascend-cann-kernels-910b_8.0.0_linux-aarch64.run
Ascend-cann-nnal_8.0.0_linux-aarch64.run
Ascend-mindxsdk-mxrag_7.0.T15_linux-aarch64.run
```
准备server.js文件，和上述软件包放置于相同目录，server.js文件见附录
使用以下命令启动服务，此时构建镜像可以通过http的方式下载软件包，减少镜像的大小，nodejs版本无要求
```shell
nodejs server.js
```
回到MIS目录，參考以下命令完成镜像构建
```shell
bash build_image.sh tei-cann mis-tei-cann:0.1 910B 3.11
bash build_image.sh tei-base mis-tei-cann:0.1 mis-tei-base:0.1 910B
bash build_image.sh tei-model mis-tei-base:0.1 bge-large-zh-v1.5 0.1
```

## clip镜像制作

### 版本说明

- 支持硬件 昇腾Atlas 800I A2

| 组件          | 类型           | 版本                                                                                                                                     |
|-------------|--------------|----------------------------------------------------------------------------------------------------------------------------------------|
| Ubuntu      | 系统镜像         | 22.04                                                                                                                                  |
| cann        | 昇腾异构计算架构和算子库 | [8.0.0](https://www.hiascend.com/developer/download/community/result?module=cann&cann=8.0.0)                           |
| clip-as-service | 图片向量化推理框架  | [v0.8.3](https://github.com/jina-ai/clip-as-service.git)                                                                 |

### 构建说明

构建镜像前，需要准备mis发布包，并解压至当前目录
```text
configs/
llm/
vlm/
patch/
```
还需要准备cann，mindie相关软件包，并放置于任意目录
```text
Ascend-cann-toolkit_8.0.0_linux-aarch64.run
Ascend-cann-kernels-910b_8.0.0_linux-aarch64.run
```
准备server.js文件，和上述软件包放置于相同目录，server.js文件见附录
使用以下命令启动服务，此时构建镜像可以通过http的方式下载软件包，减少镜像的大小，nodejs版本无要求
```shell
nodejs server.js
```
回到MIS目录，參考以下命令完成镜像构建
```shell
bash build_image.sh clip-cann mis-clip-cann:0.1 910B 3.11
bash build_image.sh clip-base mis-clip-cann:0.1 mis-vlclipm-base:0.1 910B
bash build_image.sh clip-model mis-clip-base:0.1 ViT-B-16 0.1
```

## 附录

### server.js
```js
const http = require('http');
const fs = require('fs');
const path = require('path');

const port = 3000;
const directory = __dirname;

const server = http.createServer((req, res) => {
	const filePath = path.join(directory, req.url);

	if (req.url === '/files') {
		// return all file names in current directory
		fs.readdir(directory, (err, files) => {
			if (err) {
				res.writeHead(500, {
					'Content-Type': 'text/plain'
				});
				res.end('Internal Server Error\n');
				return;
			}
			res.writeHead(200, {
				'Content-Type': 'application/json'
			});
			res.end(JSON.stringify(files));
		});
	} else {
		fs.stat(filePath, (err, stats) => {
			if (err || !stats.isFile()) {
				res.writeHead(404, {
					'Content-Type': 'text/plain'
				});
				res.end('Not Found\n');
				return;
			}
			fs.createReadStream(filePath).pipe(res);
		});
	}
});

server.listen(port, () => {
	console.log(`Server is running at http://localhost:${port}`);
});
```