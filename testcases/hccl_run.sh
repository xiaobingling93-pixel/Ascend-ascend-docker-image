#!/bin/bash

declare -i node_num=$(grep -v "^#" hostfile | grep -v "^$" | wc -l)
declare -i npu_per_sever=$(grep -v "^#" hostfile | grep -v "^$" | head -n 1 | awk -F ":" '{print $2}' | tr -d [:blank:])
device_size=`expr $node_num \* $npu_per_sever`

echo ---------------all_gather_test---------------
mpirun -f hostfile -n $device_size all_gather_test -b 1G -e 1G -f 2 -d fp32 -p $npu_per_sever
echo ---------------all_reduce_test---------------
mpirun -f hostfile -n $device_size all_reduce_test -b 1G -e 1G -f 2 -d fp32 -o sum -p $npu_per_sever
echo ---------------alltoallv_test---------------
mpirun -f hostfile -n $device_size alltoallv_test -b 1G -e 1G -f 2 -d fp32 -p $npu_per_sever
echo ---------------broadcast_test---------------
mpirun -f hostfile -n $device_size broadcast_test -b 1G -e 1G -f 2 -d fp32 -p $npu_per_sever
echo ---------------reduce_scatter_test---------------
mpirun -f hostfile -n $device_size reduce_scatter_test -b 1G -e 1G -f 2 -d fp32 -o sum -p $npu_per_sever
echo ---------------reduce_test---------------
mpirun -f hostfile -n $device_size reduce_test -b 1G -e 1G -f 2 -d fp32 -o sum -p $npu_per_sever