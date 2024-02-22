#!/bin/bash

stop_and_remove_container() {
    local container_name="$1"
    local container_id=$(docker ps -aqf "name=$container_name")

    if [ -n "$container_id" ]; then
        docker stop "$container_id" > /dev/null 2>&1
        docker rm "$container_id" > /dev/null 2>&1
        echo "容器 $container_name 已停止并删除。"
    else
        echo "容器 $container_name 不存在。"
    fi
}

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
        bash "$hccl_dir/hccl_test.sh" &
        wait $!
        bash "$flops_dir/flops_test.sh" &
        wait $!
        bash "$ais_dir/ais_bench.sh" &
        wait $!
        rm -f /root/.ssh/config
        bash "$distributed_dir/sever_train.sh" &
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
        rm -f /root/.ssh/config
        bash "$distributed_dir/sever_train.sh" &
    else
        echo "Invalid parameter."
        exit 1
    fi
    # 等待所有脚本执行完成
    wait
    stop_and_remove_container "acceptance"
else
    echo "Invalid parameter."
    exit 1

fi