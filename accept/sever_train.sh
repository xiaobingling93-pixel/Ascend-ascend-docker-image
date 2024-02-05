#!/bin/bash

train_data=/home/hwtest/output
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
  images_stat=`echo $docker_stat |grep "accept" |grep "6.0.RC1-ubuntu18.04"`
  if [ "$images_stat" ]; then
    echo "image exist"
  else
    echo "import accept image"
    docker import accept.tar accept:6.0.RC1-ubuntu18.04
  fi
  docker stop $(docker ps -aq)
  ps -ef |grep -i python |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  ps -ef |grep -i all_reduce_test |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  ps -ef |grep -i ascend-dmi |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  container_stat=`docker ps -af name=accept | grep accept`
  if [ "$container_stat" ]; then
    echo "container exist"
    docker rm accept
  fi
  get_davincis=$(find /dev -name 'davinci[0-9]+')
  mount_davincis="--device=/dev/davinci_manager --device=/dev/devmm_svm --device=/dev/hisi_hdc"
  for i in $get_davincis;do mount_davincis="$mount_davincis --device=$i";done
  docker run --rm -it --shm-size=16g --ipc=host --net=host --name=accept $mount_davincis \
   -v /etc/ascend_install.info:/etc/ascend_install.info \
   -v /etc/hccn.conf:/etc/hccn.conf \
   -v /usr/local/sbin/npu-smi:/usr/local/sbin/npu-smi \
   -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
   -v /usr/local/Ascend/add-ons/:/usr/local/Ascend/add-ons \
   -v $train_data:/home/HwHiAiUser/distributed/Megatron-LM/megatron_npu/output \
   -v /home/hwtest:/home/hwtest accept:6.0.RC1-ubuntu18.04 /bin/bash \
   -c "bash /home/hwtest/distributed/sever_train.sh; while true; do sleep 10; done"
else
  #  docker命令不存在，当前在容器内
  cd /home/HwHiAiUser/distributed/Megatron-LM/megatron_npu/tests_gpt
  rm -rf checkpoint_dist
  rm -rf kernel_meta_*
  rm -rf /root/ascend/log
  rm -f pretrain_gpt_distributed_bf16_test.sh
  rm -f node_rank
  cp /home/hwtest/config/node_rank ./
  cp /home/hwtest/distributed/pretrain_gpt_distributed_bf16_test.sh ./
  chmod +x pretrain_gpt_distributed_bf16.sh
  source /usr/local/Ascend/ascend-toolkit/set_env.sh
  export LD_LIBRARY_PATH=/usr/local/python3.7.5/lib:$LD_LIBRARY_PATH
  export PATH=/usr/local/python3.7.5/bin:$PATH
  export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH
  bash pretrain_gpt_distributed_bf16.sh --pre_tokensckens=2048 --next_tockens=0 --shape_order=SBH > /home/hwtest/distributed/train_auto.log 2>&1 &
fi