#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2024. All rights reserved.
CUR_PATH=$(dirname "$(readlink -f "$0")")
ROOT_PATH=$(readlink -f "$CUR_PATH"/..)

source /usr/local/Ascend/ascend-toolkit/set_env.sh
source /usr/local/Ascend/nnal/atb/set_env.sh
export LD_PRELOAD=$(ls /usr/local/lib/python3.11/dist-packages/scikit_learn.libs/libgomp-*):$LD_PRELOAD
export PATH="/home/HwHiAiUser/.cargo/bin:$PATH"

if [[ -n $(id | grep uid=0) ]];then
    source /usr/local/Ascend/mxRag/script/set_env.sh
else
    source /home/HwHiAiUser/Ascend/mxRag/script/set_env.sh
fi

if [[ "$#" -ne 2 ]]; then
    echo "Need param:<listen_ip> <listen_port>"
    exit 1
fi


export MIS_ENGINE_TYPE="tei-service"
export MIS_CACHE_PATH="/opt/mis/.cache"
export MIS_MODEL=MindSDK/bge-large-zh-v1.5
export MIS_HOST=$1
export MIS_PORT=$2
export no_proxy=127.0.0.1,localhost


function check_model_exists() {
    if [[ ! -e "${MIS_CACHE_PATH}/${MIS_MODEL}/config.json" ]]; then
        echo "Model '${MIS_CACHE_PATH}/${MIS_MODEL}' does not exist."
        return 1
    else
        echo "Model '${MIS_CACHE_PATH}/${MIS_MODEL}' exists."
        return 0
    fi
}

function download_model() {
    local retry_time=1
    local max_retries=5
    echo "Downloading model '${MIS_MODEL}' from modelers ..."
    while [[ ${retry_time} -le ${max_retries} ]]; do
		rm -rf "${MIS_CACHE_PATH}/${MIS_MODEL}"
		mkdir -p "${MIS_CACHE_PATH}/MindSDK"

        if cd "${MIS_CACHE_PATH}/MindSDK" && git clone "https://modelers.cn/${MIS_MODEL}.git" "${MIS_MODEL##*/}" && cd "${MIS_MODEL##*/}" && git lfs pull; then
            echo "Download successful."
            return 0
        else
            retry_time=$((retry_time + 1))
            echo "Download failed, try again."
            sleep 5
        fi
    done
    echo "Maximum retries ${max_retries} reached. Download failed."
    return 1
}

function config_env() {
    eval "$(jq -r 'to_entries[] | "export \(.key | ascii_upcase | gsub("[^A-Za-z0-9_]"; "_"))=\(.value | @sh)"' $CUR_PATH/config.json)"
}

if ! check_model_exists; then
	if ! download_model; then
		echo "Download model ${MIS_MODEL} failed" 
		exit 1
	fi
fi

config_env

mis_tei
