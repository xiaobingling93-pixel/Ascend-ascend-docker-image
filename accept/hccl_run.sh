#!/bin/bash

declare -i node_num=$(grep -v "^#" hostfile | grep -v "^$" | wc -l)
declare -i npu_per_sever=$(grep -v "^#" hostfile | grep -v "^$" | head -n 1 | awk -F ":" '{print $2}' | tr -d [:blank:])
device_size=`expr $node_num \* $npu_per_sever`
net_name=$(ip addr | grep -B 2 `hostname -I | awk '{print $1}'` | tail -n 1 | awk '{print $NF}' | tr -d [:blank:])

export HCCL_SOCKET_IFNAME=$net_name

echo ---------------all_gather_test---------------
mpirun -f hostfile -n $device_size all_gather_test -b 1G -e 1G -f 2 -d fp32 -p $npu_per_sever -c 0