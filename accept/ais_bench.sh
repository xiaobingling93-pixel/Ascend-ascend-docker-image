#!/bin/bash

TRAIN_DATA_PATH=/home/datasets/Bert-Dataset
EVAL_DATA_PATH=/home/datasets/Bert-TestData
PRETRAIN_MODEL_PATH=/home/models/ms_bert_large.ckpt
TYPE=bert-large

arch=$(uname -m)
# 检查type的值
if [ "$TYPE" != "resnet50" ] && [ "$TYPE" != "bert-large" ]; then
    echo "错误：无效的type值。类型应为resnet50或bert-large。"
    exit 1
fi
current_stat=`docker --help`
cmd_ret=$?
if [ $cmd_ret -eq 0 ]; then
  #  docker命令正常，当前在裸机上
  docker_stat=`docker images`
  cmd_ret=$?
  if [ $cmd_ret -ne 0 ]; then
    echo "the docker is not running, restart docker"
    systemctl restart docker
  fi
  images_stat=`echo $docker_stat |grep "ascendhub.huawei.com/public-ascendhub/acceptance" |grep "24.0.RC1-ubuntu18.04"`
  if [ "$images_stat" ]; then
    echo "image exist"
  else
    echo "import acceptance image"
    docker import acceptance.tar ascendhub.huawei.com/public-ascendhub/acceptance:24.0.RC1-ubuntu18.04
  fi
  docker stop $(docker ps -aq)
  ps -ef |grep -i python |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  ps -ef |grep -i all_reduce_test |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  ps -ef |grep -i ascend-dmi |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  container_stat=`docker ps -af name=acceptance | grep acceptance`
  if [ "$container_stat" ]; then
    echo "container exist"
    docker rm acceptance
  fi
  get_davincis=$(find /dev -name 'davinci[0-9]*')
  npu_per_node=$(echo "$get_davincis" | wc -l)
  cd ./config && python3 hccl_tools.py $npu_per_node $npu_per_node && sleep 5 && cd ..
  rank_table=`pwd`/config/hccl.json
  mount_davincis="--device=/dev/davinci_manager --device=/dev/devmm_svm --device=/dev/hisi_hdc"
  for i in $get_davincis;do mount_davincis="$mount_davincis --device=$i";done
  ais_bert_log_dir=/home/HwHiAiUser/samples/train_huawei_train_mindspore_bert-Ais-Benchmark-Stubs-${arch}-1.0-r2.2/log
  ais_resnet_log_dir=/home/HwHiAiUser/samples/train_huawei_train_mindspore_resnet-Ais-Benchmark-Stubs-${arch}-1.0-r2.2/log
  data_path="-v $rank_table:/home/HwHiAiUser/$(basename "$rank_table") -v $TRAIN_DATA_PATH:/home/HwHiAiUser/$(basename "$TRAIN_DATA_PATH") -v $EVAL_DATA_PATH:/home/HwHiAiUser/$(basename "$EVAL_DATA_PATH")"
  if [ $TYPE == "bert-large" ]; then
    data_path="$data_path -v $PRETRAIN_MODEL_PATH:/home/HwHiAiUser/$(basename "$PRETRAIN_MODEL_PATH")"
  fi
  mkdir -p ~/ais_log/resnet_log ~/ais_log/bert_log
  chown -R HwHiAiUser:HwHiAiUser ~/ais_log/resnet_log ~/ais_log/bert_log
  docker run --rm -it --shm-size=16g --ipc=host --net=host --name=acceptance $mount_davincis $data_path \
  -v /etc/ascend_install.info:/etc/ascend_install.info \
  -v /etc/hccn.conf:/etc/hccn.conf \
  -v /usr/local/sbin/npu-smi:/usr/local/sbin/npu-smi \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  -v /usr/local/Ascend/add-ons/:/usr/local/Ascend/add-ons \
  -v /home/hwtest:/home/hwtest \
  -v /root/ais_log/bert_log:${ais_bert_log_dir} \
  -v /root/ais_log/resnet_log:${ais_resnet_log_dir} \
  ascendhub.huawei.com/public-ascendhub/acceptance:24.0.RC1-ubuntu18.04 /bin/bash \
  -c "bash /home/hwtest/ais/ais_bench.sh; while true; do sleep 10; done"
else
  #  docker命令不存在，当前在容器内
  cd /home/HwHiAiUser/ais
  parameter="$TYPE /home/HwHiAiUser/$(basename "$TRAIN_DATA_PATH") /home/HwHiAiUser/$(basename "$EVAL_DATA_PATH")"
  if [ $TYPE == "bert-large" ]; then
    parameter="$parameter /home/HwHiAiUser/$(basename "$PRETRAIN_MODEL_PATH")"
  fi
  source /usr/local/Ascend/ascend-toolkit/set_env.sh
  export LD_LIBRARY_PATH=/usr/local/python3.7.5/lib:$LD_LIBRARY_PATH
  export PATH=/usr/local/python3.7.5/bin:$PATH
  export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH
  python3 run_ais.py  $parameter  > /home/hwtest/ais/ais_bench.log 2>&1 &
fi
