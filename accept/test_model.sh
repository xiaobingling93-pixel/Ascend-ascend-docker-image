#!/bin/bash

# 定义脚本参数
param=${1:-"all"}

# 定义脚本目录
hccl_dir="hccl"
flops_dir="flops"
ais_dir="ais"
distributed_dir="distributed"

if [ "$#" -gt 1 ]; then
    echo "Too many parameters。"
    exit 1
fi

# 检查参数是否为预期值
if [[ "$param" == "all" || "$param" == "hccl-test" || "$param" == "ais-flops" || "$param" == "flops-test" || "$param" == "distributed" ]]; then
    # 如果没有参数或者参数为all，则依次执行所有脚本
    if [[ "$param" == "all" ]]; then
        bash "$hccl_dir/hccl_test.sh"
        bash "$flops_dir/flops_test.sh"
        bash "$distributed_dir/sever_train.sh"
        bash "$ais_dir/ais_bench.sh"
    # 如果参数为hccl-test，则执行hccl_test.sh脚本
    elif [[ "$param" == "hccl-test" ]]; then
        bash "$hccl_dir/hccl_test.sh" &
    # 如果参数为ais-flops，则执行ais_bench.sh脚本
    elif [[ "$param" == "ais-flops" ]]; then
        bash "$ais_dir/ais_bench.sh" &
    # 如果参数为flops-test，则执行flops_test.sh脚本
    elif [[ "$param" == "flops-test" ]]; then
        bash "$flops_dir/flops_test.sh" &
    # 如果参数为distributed，则执行sever_train.sh脚本
    elif [[ "$param" == "distributed" ]]; then
        bash "$distributed_dir/sever_train.sh" &
    else
        echo "Invalid parameter."
        exit 1
    fi
else
    echo "Invalid parameter."
    exit 1

fi