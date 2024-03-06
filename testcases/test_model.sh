#!/bin/bash

# 定义脚本参数
param=${1:-"all"}

# 定义脚本目录
hccl_dir="hccl"
flops_dir="flops"
ais_dir="ais"
distributed_dir="distributed"

if [ "$#" -eq 1 ]; then
  if [[ "$param" == "all" ]]; then
    bash "$hccl_dir/hccl_test.sh" >/dev/null 2>&1
    bash "$flops_dir/flops_test.sh" >/dev/null 2>&1
    bash "$distributed_dir/server_train.sh" >/dev/null 2>&1
    bash "$ais_dir/ais_bench.sh" >/dev/null 2>&1
    # 如果参数为hccl-test，则执行hccl_test.sh脚本
    elif [[ "$param" == "hccl-test" ]]; then
      bash "$hccl_dir/hccl_test.sh" >/dev/null 2>&1 &
    # 如果参数为ais-flops，则执行ais_bench.sh脚本
    elif [[ "$param" == "ais-flops" ]]; then
      bash "$ais_dir/ais_bench.sh" >/dev/null 2>&1 &
    # 如果参数为flops-test，则执行flops_test.sh脚本
    elif [[ "$param" == "flops-test" ]]; then
      bash "$flops_dir/flops_test.sh" >/dev/null 2>&1 &
    # 如果参数为distributed，则执行server_train.sh脚本
    elif [[ "$param" == "distributed" ]]; then
      bash "$distributed_dir/server_train.sh" >/dev/null 2>&1 &
    else
      echo "Invalid parameter."
  fi
else
    echo "Too many parameters。"
fi