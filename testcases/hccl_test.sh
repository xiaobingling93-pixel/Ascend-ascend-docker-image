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
  images_stat=`echo $docker_stat |grep "ascendhub.huawei.com/public-ascendhub/testcases" |grep "24.0.RC1-ubuntu20.04"`
  if [ "$images_stat" ]; then
    echo "image exist"
  else
    echo "import testcases image"
    docker import testcases.tar ascendhub.huawei.com/public-ascendhub/testcases:24.0.RC1-ubuntu20.04
  fi
  docker stop $(docker ps -aq)
  ps -ef |grep -i python |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  ps -ef |grep -i all_reduce_test |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  ps -ef |grep -i ascend-dmi |grep -i [name] |grep -v grep |awk '{print $2}' |xargs -t -I {} kill -9 {}
  container_stat=`docker ps -af name=testcases | grep testcases`
  if [ "$container_stat" ]; then
    echo "container exist"
    docker rm testcases

  fi
  get_davincis=$(find /dev -name 'davinci[0-9]*')
  mount_davincis="--device=/dev/davinci_manager --device=/dev/devmm_svm --device=/dev/hisi_hdc"
  for i in $get_davincis;do mount_davincis="$mount_davincis --device=$i";done
  docker run --rm --ipc=host --net=host --user=root --name=testcases -p 33333:33333 $mount_davincis \
  -v /var/log/npu:/usr/slog \
  -v /root/.ssh:/root/.ssh \
  -v /usr/local/sbin/npu-smi:/usr/local/sbin/npu-smi \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  -v /usr/local/Ascend/add-ons/:/usr/local/Ascend/add-ons \
  -v /home/hwtest:/home/hwtest ascendhub.huawei.com/public-ascendhub/testcases:24.0.RC1-ubuntu20.04 /bin/bash \
  -c "bash /home/hwtest/hccl/hccl_test.sh"
else
  #  docker命令不存在，当前在容器内
  cd /home/HwHiAiUser/hccl
  cp /home/hwtest/config/hostfile ./
  mkdir -p /run/sshd && /usr/sbin/sshd -p 33333
  source /usr/local/Ascend/ascend-toolkit/set_env.sh
  export LD_LIBRARY_PATH=/usr/local/python3.9.2/lib:$LD_LIBRARY_PATH
  export PATH=/usr/local/python3.9.2/bin:$PATH
  export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64:/usr/local/Ascend/driver/lib64/common:/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH
  IP=$(grep -v "^#" /home/hwtest/config/hostfile | grep -v "^$" | head -n 1 | awk -F ":" '{print $1}')
  if [[ "${IP}" == "$(hostname -I | awk '{print $1}')" ]]; then
      sleep 10
      awk 'NF && $0 !~ /^#/' hostfile | while IFS=":" read -r ip_address pid_num rest_of_line; do
          ssh-keyscan -p 33333 -t rsa $ip_address >> /root/.ssh/known_hosts 2>/dev/null
      done
      chmod +x hccl_run.sh
      ./hccl_run.sh > /home/hwtest/hccl/hccl_test.log 2>&1
  else
      sleep 30
  fi
fi