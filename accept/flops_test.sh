#!/bin/bash

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
  mount_davincis="--device=/dev/davinci_manager --device=/dev/devmm_svm --device=/dev/hisi_hdc"
  for i in $get_davincis;do mount_davincis="$mount_davincis --device=$i";done
  docker run --rm -it --shm-size=16g --ipc=host --net=host --name=acceptance $mount_davincis \
  -v /usr/local/sbin/npu-smi:/usr/local/sbin/npu-smi \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  -v /usr/local/Ascend/add-ons/:/usr/local/Ascend/add-ons \
  -v /home/hwtest:/home/hwtest \
  ascendhub.huawei.com/public-ascendhub/acceptance:24.0.RC1-ubuntu18.04 /bin/bash -c "bash /home/hwtest/flops/flops_test.sh"
else
  #  docker命令不存在，当前在容器内
  cd /home/HwHiAiUser/flops
  source /usr/local/Ascend/ascend-toolkit/set_env.sh
  export LD_LIBRARY_PATH=/usr/local/python3.7.5/lib:$LD_LIBRARY_PATH
  export PATH=/usr/local/python3.7.5/bin:$PATH
  export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH
  python3 flops_test.py > /home/hwtest/flops/flops_test.log 2>&1
fi