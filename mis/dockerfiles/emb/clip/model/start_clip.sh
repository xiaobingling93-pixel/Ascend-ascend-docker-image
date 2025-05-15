#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2024. All rights reserved.
CUR_PATH=$(dirname "$(readlink -f "$0")")
ROOT_PATH=$(readlink -f "$CUR_PATH")

if [[ "$#" -ne 2 ]]; then
    echo "Need param:<listen_ip> <listen_port>"
    exit 1
fi


source /usr/local/Ascend/ascend-toolkit/set_env.sh

export MIS_ENGINE_TYPE="clip-service"
export CLIP_CONFIG_PATH=$CUR_PATH/config.yaml
export MIS_CACHE_PATH="/opt/mis/.cache"
export MIS_MODEL=MindSDK/ViT-B-16

export JINA_HIDE_SURVEY=1

export MIS_HOST=$1
export MIS_PORT=$2
export no_proxy=127.0.0.1,localhost


#modify inner port
if [[ ! -z $MIS_INNER_PORT ]]; then
    sed -i "s|2025|$MIS_INNER_PORT|g" "$CUR_PATH"/config.yaml
fi


function check_model_exists() {
	ret=$(ls ${MIS_CACHE_PATH}/${MIS_MODEL}/*.pt | wc -l)

    if [[ $ret -eq 0 ]]; then
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
    echo "Downloading model '${MIS_MODEL}' from modelscope ..."
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

if ! check_model_exists; then
	if ! download_model; then
		echo "Download model $MIS_MODEL failed" 
		exit 1
	fi
fi

mis_clip
