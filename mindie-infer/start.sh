#!/bin/bash

export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:$LD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH:/home/HwHiAiUser/.local/lib/python3.10/site-packages

#######################################################################################
# Get device info
#######################################################################################
total_count=$(npu-smi info -l | grep "Total Count" | awk -F ':' '{print $2}' | xargs)

if [[ -z "$total_count" ]]; then
    echo "Error: Unable to retrieve device info. Please check if npu-smi is available for current user (id 1001), or if you are specifying an occupied device."
    exit 1
fi

npu_device_ids=$(seq -s, 0 $(($total_count - 1)))
echo "$total_count device(s) detected!"


#######################################################################################
# Set toolkit envs
#######################################################################################
echo "Setting toolkit envs..."
export ASCEND_TOOLKIT_HOME=~/Ascend/ascend-toolkit/latest
export LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/lib64:${ASCEND_TOOLKIT_HOME}/lib64/plugin/opskernel:${ASCEND_TOOLKIT_HOME}/lib64/plugin/nnengine:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe/op_tiling/lib/linux/$(arch):$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${ASCEND_TOOLKIT_HOME}/tools/aml/lib64:${ASCEND_TOOLKIT_HOME}/tools/aml/lib64/plugin:$LD_LIBRARY_PATH
export PYTHONPATH=${ASCEND_TOOLKIT_HOME}/python/site-packages:${ASCEND_TOOLKIT_HOME}/opp/built-in/op_impl/ai_core/tbe:$PYTHONPATH
export PATH=${ASCEND_TOOLKIT_HOME}/bin:${ASCEND_TOOLKIT_HOME}/compiler/ccec_compiler/bin:${ASCEND_TOOLKIT_HOME}/tools/ccec_compiler/bin:$PATH
export ASCEND_AICPU_PATH=${ASCEND_TOOLKIT_HOME}
export ASCEND_OPP_PATH=${ASCEND_TOOLKIT_HOME}/opp
export TOOLCHAIN_HOME=${ASCEND_TOOLKIT_HOME}/toolkit
export ASCEND_HOME_PATH=${ASCEND_TOOLKIT_HOME}
echo "Toolkit envs set!"


#######################################################################################
# Set MindIE envs
#######################################################################################
echo "Setting MindIE envs..."
# mindie-rt
export ASCENDIE_HOME=~/Ascend/mindie/latest/mindie-rt
export TUNE_BANK_PATH="${ASCENDIE_HOME}/aoe"
export LD_LIBRARY_PATH="${ASCENDIE_HOME}/lib":${LD_LIBRARY_PATH}
export ASCEND_CUSTOM_OPP_PATH="${ASCENDIE_HOME}/ops/vendors/customize":${ASCEND_CUSTOM_OPP_PATH}
export ASCEND_CUSTOM_OPP_PATH="${ASCENDIE_HOME}/ops/vendors/aie_ascendc":${ASCEND_CUSTOM_OPP_PATH}
# mindie-torch
export MINDIE_TORCH_HOME=~/Ascend/mindie/latest/mindie-torch
export LD_LIBRARY_PATH="${MINDIE_TORCH_HOME}/lib":${LD_LIBRARY_PATH}
# mindie-service
export MIES_INSTALL_PATH=~/Ascend/mindie/latest/mindie-service
export LD_LIBRARY_PATH=${MIES_INSTALL_PATH}/lib:${MIES_INSTALL_PATH}/lib/grpc:${LD_LIBRARY_PATH}
export PYTHONPATH=${MIES_INSTALL_PATH}/bin:${PYTHONPATH}
export ATB_OPERATION_EXECUTE_ASYNC=1
export TASK_QUEUE_ENABLE=1
export HCCL_BUFFSIZE=120
export MINDIE_LOG_TO_STDOUT=1
export MINDIE_LOG_TO_FILE=0
export MIES_SERVICE_MONITOR_MODE=1
# 运行时日志
export ASCEND_SLOG_PRINT_TO_STDOUT=1
export ASCEND_GLOBAL_LOG_LEVEL=3
export ASCEND_GLOBAL_EVENT_ENABLE=0
# 模型仓日志
export ATB_LOG_TO_FILE=0
export ATB_LOG_TO_FILE_FLUSH=0
export ATB_LOG_TO_STDOUT=1
export ATB_LOG_LEVEL=ERROR
# 算子库和加速库日志
export ASDOPS_LOG_TO_FILE=0
export ASDOPS_LOG_TO_STDOUT=1
export ASDOPS_LOG_LEVEL=ERROR
# 控制流式推理中增量token解码方式的环境变量，范围[0, 50]，代表增量token id解码时参考前方多少个token id。
# 数值越低流式推理性能越好，数值越高流式推理解码准确性越高。不设置时流式推理采用全量解码的方式，准确度最高但性能最低。
# 当流式推理对比非流式推理性能没有显著劣化时无需关注此环境变量。
export MIES_TOKENIZER_SLIDING_WINDOW_SIZE=5
# mindie-llm
export MINDIE_LLM_HOME_PATH=~/Ascend/mindie/latest/mindie-llm
# export POST_PROCESSING_SPEED_MODE_TYPE=3
mindie_llm_path=~/Ascend/mindie/latest/mindie-llm
chmod u+w "${mindie_llm_path}"
py_logs_path=${mindie_llm_path}/logs
if [ ! -d "${py_logs_path}" ]; then
    mkdir "${py_logs_path}"
fi
chmod 750 "${py_logs_path}"

export MINDIE_LLM_PYTHON_LOG_LEVEL=WARNING
export MINDIE_LLM_PYTHON_LOG_TO_STDOUT=1
export MINDIE_LLM_PYTHON_LOG_TO_FILE=0
export MINDIE_LLM_PYTHON_LOG_PATH="${py_logs_path}/pythonlog.log"

export MINDIE_LLM_CONTINUOUS_BATCHING=1
export MINDIE_LLM_RECOMPUTE_THRESHOLD=0.5
export LD_LIBRARY_PATH=$MINDIE_LLM_HOME_PATH/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$MINDIE_LLM_HOME_PATH/lib/grpc:$LD_LIBRARY_PATH
export PYTHONPATH=$MINDIE_LLM_HOME_PATH:$PYTHONPATH
export PYTHONPATH=$MINDIE_LLM_HOME_PATH/lib:$PYTHONPATH

export MATMUL_ND_NZ_ENABLE=1
export ENABLE_ADD_NORM=1
export ENABLE_FLEX_OPTIMIZE=1
echo "MindIE envs set!"


#######################################################################################
# Receive args and modify config.json
#######################################################################################
echo "MindIE-Service is installed in ${MIES_INSTALL_PATH}"
CONFIG_FILE=${MIES_INSTALL_PATH}/conf/config.json

BACKEND_TYPE="atb"
MODEL_WEIGHT_PATH="/path-to-weights/model-name"
MAX_SEQ_LEN=2560
MAX_PREFILL_TOKENS=8192
MAX_ITER_TIMES=512
MAX_INPUT_TOKEN_LEN=2048
TRUNCATION=false
NPU_DEVICE_IDS=$npu_device_ids
WORLD_SIZE=$total_count
HTTPS_ENABLED=false
INTER_NODE_TLS_ENABLED=false
MULTI_NODES_INFER_ENABLED=false
NPU_MEM_SIZE=-1
MAX_PREFILL_BATCH_SIZE=50
ALLOW_ALL_ZERO=true
TEMPLATE_TYPE="Standard"
MAX_PREEMPT_COUNT=0
SUPPORT_SELECT_BATCH=false
IP_ADDRESS="0.0.0.0"
PORT=9811
MANAGEMENT_IP_ADDRESS="0.0.0.0"
MANAGEMENT_PORT=9811
METRICS_PORT=9812
SELF_HEALING_TIMEOUT=0
SELF_HEALING_INIT_TIME=1800
SELF_HEALING_RETRY_INTERVAL=60
SELF_HEALING_RESTART_TIME=240

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --backend) BACKEND_TYPE="$2"; shift ;;
        --model) MODEL_WEIGHT_PATH="$2"; shift ;;
        --model-name) MODEL_NAME="$2"; shift ;;
        --max-seq-len) MAX_SEQ_LEN="$2"; shift ;;
        --max-iter-times) MAX_ITER_TIMES="$2"; shift ;;
        --max-input-token-len) MAX_INPUT_TOKEN_LEN="$2"; shift ;;
        --max-prefill-tokens) MAX_PREFILL_TOKENS="$2"; shift ;;
        --truncation) TRUNCATION="$2"; shift ;;
        --npu-device-ids) NPU_DEVICE_IDS="$2"; shift ;;
        --world-size) WORLD_SIZE="$2"; shift ;;
        --template-type) TEMPLATE_TYPE="$2"; shift ;;
        --max-preempt-count) MAX_PREEMPT_COUNT="$2"; shift ;;
        --support-select-batch) SUPPORT_SELECT_BATCH="$2"; shift ;;
        --npu-mem-size) NPU_MEM_SIZE="$2"; shift ;;
        --max-prefill-batch-size) MAX_PREFILL_BATCH_SIZE="$2"; shift ;;
        --ip) IP_ADDRESS="$2"; shift ;;
        --port) PORT="$2"; shift ;;
        --management-ip) MANAGEMENT_IP_ADDRESS="$2"; shift ;;
        --management-port) MANAGEMENT_PORT="$2"; shift ;;
        --metrics-port) METRICS_PORT="$2"; shift ;;
        --self-healing-timeout) SELF_HEALING_TIMEOUT="$2"; shift ;;
        --self-healing-init-time) SELF_HEALING_INIT_TIME="$2"; shift ;;
        --self-healing-retry-interval) SELF_HEALING_RETRY_INTERVAL="$2"; shift ;;
        --self-healing-restart-time) SELF_HEALING_RESTART_TIME="$2"; shift ;;
        *) 
            echo "Unknown parameter: $1"
            echo "Please check your inputs."
            exit 1
            ;;
    esac
    shift
done

MODEL_NAME=${MODEL_NAME:-$(basename "$MODEL_WEIGHT_PATH")}
echo "MODEL_NAME is set to: $MODEL_NAME"

#########################################
if [[ "$BACKEND_TYPE" != "atb" && "$BACKEND_TYPE" != "ms" ]]; then
    echo "Error: BACKEND must be 'atb' or 'ms'. Current value: $BACKEND_TYPE"
    exit 1
fi

if [[ ! "$IP_ADDRESS" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || 
   [[ ! "$MANAGEMENT_IP_ADDRESS" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Error: IP_ADDRESS and MANAGEMENT_IP_ADDRESS must be valid IP addresses. Current values: IP_ADDRESS=$IP_ADDRESS, MANAGEMENT_IP_ADDRESS=$MANAGEMENT_IP_ADDRESS"
    exit 1
fi

if [[ ! "$PORT" =~ ^[0-9]+$ ]] || (( PORT < 1025 || PORT > 65535 )) ||
   [[ ! "$MANAGEMENT_PORT" =~ ^[0-9]+$ ]] || (( MANAGEMENT_PORT < 1025 || MANAGEMENT_PORT > 65535 )); then
    echo "Error: PORT and MANAGEMENT_PORT must be integers between 1025 and 65535. Current values: PORT=$PORT, MANAGEMENT_PORT=$MANAGEMENT_PORT"
    exit 1
fi

if [[ "$BACKEND_TYPE" == "ms" && "$NPU_MEM_SIZE" == "-1" ]]; then
    NPU_MEM_SIZE=8
fi
#########################################

chmod u+w ${MIES_INSTALL_PATH}/conf/
sed -i "s/\"backendType\"\s*:\s*\"[^\"]*\"/\"backendType\": \"$BACKEND_TYPE\"/" $CONFIG_FILE
sed -i "s/\"modelName\"\s*:\s*\"[^\"]*\"/\"modelName\": \"$MODEL_NAME\"/" $CONFIG_FILE
sed -i "s|\"modelWeightPath\"\s*:\s*\"[^\"]*\"|\"modelWeightPath\": \"$MODEL_WEIGHT_PATH\"|" $CONFIG_FILE
sed -i "s/\"maxSeqLen\"\s*:\s*[0-9]*/\"maxSeqLen\": $MAX_SEQ_LEN/" "$CONFIG_FILE"
sed -i "s/\"maxPrefillTokens\"\s*:\s*[0-9]*/\"maxPrefillTokens\": $MAX_PREFILL_TOKENS/" "$CONFIG_FILE"
sed -i "s/\"maxIterTimes\"\s*:\s*[0-9]*/\"maxIterTimes\": $MAX_ITER_TIMES/" "$CONFIG_FILE"
sed -i "s/\"maxInputTokenLen\"\s*:\s*[0-9]*/\"maxInputTokenLen\": $MAX_INPUT_TOKEN_LEN/" "$CONFIG_FILE"
sed -i "s/\"truncation\"\s*:\s*[a-z]*/\"truncation\": $TRUNCATION/" "$CONFIG_FILE"
sed -i "s|\(\"npuDeviceIds\"\s*:\s*\[\[\)[^]]*\(]]\)|\1$NPU_DEVICE_IDS\2|" "$CONFIG_FILE"
sed -i "s/\"worldSize\"\s*:\s*[0-9]*/\"worldSize\": $WORLD_SIZE/" "$CONFIG_FILE"
sed -i "s/\"httpsEnabled\"\s*:\s*[a-z]*/\"httpsEnabled\": $HTTPS_ENABLED/" "$CONFIG_FILE"
sed -i "s/\"templateType\"\s*:\s*\"[^\"]*\"/\"templateType\": \"$TEMPLATE_TYPE\"/" $CONFIG_FILE
sed -i "s/\"maxPreemptCount\"\s*:\s*[0-9]*/\"maxPreemptCount\": $MAX_PREEMPT_COUNT/" $CONFIG_FILE
sed -i "s/\"supportSelectBatch\"\s*:\s*[a-z]*/\"supportSelectBatch\": $SUPPORT_SELECT_BATCH/" $CONFIG_FILE
sed -i "s/\"interNodeTLSEnabled\"\s*:\s*[a-z]*/\"interNodeTLSEnabled\": $INTER_NODE_TLS_ENABLED/" "$CONFIG_FILE"
sed -i "s/\"multiNodesInferEnabled\"\s*:\s*[a-z]*/\"multiNodesInferEnabled\": $MULTI_NODES_INFER_ENABLED/" "$CONFIG_FILE"
sed -i "s/\"maxPrefillBatchSize\"\s*:\s*[0-9]*/\"maxPrefillBatchSize\": $MAX_PREFILL_BATCH_SIZE/" "$CONFIG_FILE"
sed -i "s/\"allowAllZeroIpListening\"\s*:\s*[a-z]*/\"allowAllZeroIpListening\": $ALLOW_ALL_ZERO/" "$CONFIG_FILE"
sed -i "s/\"ipAddress\"\s*:\s*\"[^\"]*\"/\"ipAddress\": \"$IP_ADDRESS\"/" "$CONFIG_FILE"
sed -i "s/\"port\"\s*:\s*[0-9]*/\"port\": $PORT/" "$CONFIG_FILE"
sed -i "s/\"managementIpAddress\"\s*:\s*\"[^\"]*\"/\"managementIpAddress\": \"$MANAGEMENT_IP_ADDRESS\"/" "$CONFIG_FILE"
sed -i "s/\"managementPort\"\s*:\s*[0-9]*/\"managementPort\": $MANAGEMENT_PORT/" "$CONFIG_FILE"
sed -i "s/\"metricsPort\"\s*:\s*[0-9]*/\"metricsPort\": $METRICS_PORT/" $CONFIG_FILE
sed -i "s/\"npuMemSize\"\s*:\s*-*[0-9]*/\"npuMemSize\": $NPU_MEM_SIZE/" "$CONFIG_FILE"


#######################################################################################
# Set ATB envs
#######################################################################################
if [ $BACKEND_TYPE = "atb" ]; then
    echo "Using ATB backend."
    # source /usr/local/Ascend/llm_model/set_env.sh
    echo "Setting ATB envs..."
    export ATB_SPEED_HOME_PATH=~/Ascend/llm_model
    export LD_LIBRARY_PATH=$ATB_SPEED_HOME_PATH/lib:$LD_LIBRARY_PATH
    export PYTHONPATH=$ATB_SPEED_HOME_PATH:$PYTHONPATH

    export PYTORCH_INSTALL_PATH=~/.local/lib/python3.10/site-packages/torch
    export LD_LIBRARY_PATH=$PYTORCH_INSTALL_PATH/lib:$LD_LIBRARY_PATH
    export PYTORCH_NPU_INSTALL_PATH=~/.local/lib/python3.10/site-packages/torch_npu
    export LD_LIBRARY_PATH=$PYTORCH_NPU_INSTALL_PATH/lib:$LD_LIBRARY_PATH

    export TASK_QUEUE_ENABLE=1 #是否开启TaskQueue, 该环境变量是PyTorch的
    export ATB_OPERATION_EXECUTE_ASYNC=1 # Operation 是否异步运行
    export ATB_CONTEXT_HOSTTILING_RING=1
    export ATB_CONTEXT_HOSTTILING_SIZE=102400
    export ATB_WORKSPACE_MEM_ALLOC_GLOBAL=1
    export ATB_USE_TILING_COPY_STREAM=0 #是否开启双stream功能
    export ATB_OPSRUNNER_KERNEL_CACHE_LOCAL_COUNT=1  # 设置op runner的本地cache 槽位数
    export ATB_OPSRUNNER_KERNEL_CACHE_GLOABL_COUNT=16  # 设置op runner的全局cache 槽位数
    echo "ATB envs set!"

    # source /usr/local/Ascend/nnal/atb/set_env.sh
    export ATB_HOME_PATH=~/Ascend/nnal/atb/latest/atb/cxx_abi_0
    export LD_LIBRARY_PATH=$ATB_HOME_PATH/lib:$ATB_HOME_PATH/examples:$LD_LIBRARY_PATH
    export PATH=$ATB_HOME_PATH/bin:$PATH

    #加速库环境变量
    export ATB_STREAM_SYNC_EVERY_KERNEL_ENABLE=0 #每个Kernel的Execute时就做同步
    export ATB_STREAM_SYNC_EVERY_RUNNER_ENABLE=0 #每个Runner的Execute时就做同步
    export ATB_STREAM_SYNC_EVERY_OPERATION_ENABLE=0 #每个Operation的Execute时就做同步
    export ATB_OPSRUNNER_SETUP_CACHE_ENABLE=1 #是否开启SetupCache，当检查到输入和输出没有变化时，不做setup
    export ATB_OPSRUNNER_KERNEL_CACHE_TYPE=3 #0:不开启, 1:开启本地缓存 2:开启全局缓存 3：同时开启本地和全局缓存
    export ATB_OPSRUNNER_KERNEL_CACHE_LOCAL_COUNT=1 #本地缓存个数，支持范围1~1024
    export ATB_OPSRUNNER_KERNEL_CACHE_GLOABL_COUNT=5 #全局缓存个数，支持范围1~1024
    export ATB_OPSRUNNER_KERNEL_CACHE_TILING_SIZE=10240 #tiling默认大小，支持范围1~1073741824
    export ATB_WORKSPACE_MEM_ALLOC_ALG_TYPE=1 #0:暴力算法 1:block分配算法 2:有序heap算法 3:引入block合并(SOMAS算法退化版)
    export ATB_WORKSPACE_MEM_ALLOC_GLOBAL=0 #0:不开启 1:开启全局中间tensor内存分配
    export ATB_COMPARE_TILING_EVERY_KERNEL=0 #每个Kernel运行后，比较运行前和后的NPU上tiling内容是否变化
    export ATB_HOST_TILING_BUFFER_BLOCK_NUM=128 #Context内部HostTilingBuffer块数，通常使用默认值即可，可配置范围：最小128，最大1024
    export ATB_DEVICE_TILING_BUFFER_BLOCK_NUM=32 #Context内部DeviceTilingBuffer块数，通常使用默认值即可，可配置范围：最小32，最大1024
    export ATB_SHARE_MEMORY_NAME_SUFFIX="" #共享内存命名后缀，多用户同时使用通信算子时，需通过设置该值进行共享内存的区分
    export ATB_LAUNCH_KERNEL_WITH_TILING=1 #tiling拷贝随算子下发功能开关
    export ATB_MATMUL_SHUFFLE_K_ENABLE=1 #Shuffle-K使能，默认开
    export ATB_RUNNER_POOL_SIZE=64 #加速库runner池中可存放runner的个数，支持范围0~1024，为0时不开启runner池功能

    #算子库环境变量
    export ASDOPS_HOME_PATH=$ATB_HOME_PATH
    export ASDOPS_MATMUL_PP_FLAG=1 #算子库开启使用PPMATMUL
    export ASDOPS_LOG_TO_FILE_FLUSH=0 #日志写文件是否刷新
    export ASDOPS_LOG_TO_BOOST_TYPE=atb #算子库对应加速库日志类型，默认atb
    export ASDOPS_LOG_PATH=~ #算子库日志保存路径
    export ASDOPS_TILING_PARSE_CACHE_DISABLE=0 #算子库tilingParse禁止进行缓存优化
    export LCCL_DETERMINISTIC=0 #LCCL确定性AllReduce(保序加)是否开启，0关闭，1开启。
#######################################################################################
# Set MS envs
#######################################################################################
elif [ $BACKEND_TYPE = "ms" ]; then
    echo "Using MindSpore backend."
    export MS_SCHED_HOST="0.0.0.0"
    export MS_SCHED_PORT="8119"
    export MS_ENABLE_LCCL=1
    export LCAL_IF_PORT=8129
    export MS_INTERNAL_DISABLE_CUSTOM_KERNEL_LIST=PagedAttention,FlashAttentionScore
    export CPU_AFFINITY=1
fi


#######################################################################################
# Start service
#######################################################################################
echo "Current configurations are displayed as follows:"
cat $CONFIG_FILE
npu-smi info -m > ~/device_info

# Check if the self-healing feature is enabled
if [ "$SELF_HEALING_TIMEOUT" -ne 0 ]; then
    if [ "$SELF_HEALING_TIMEOUT" -gt 600 ]; then
        SELF_HEALING_TIMEOUT=600
    fi
    if [ "$SELF_HEALING_TIMEOUT" -lt 10 ]; then
        SELF_HEALING_TIMEOUT=10
    fi
    echo "Self-healing is enabled. Starting service with monitoring..."

    # Start the mindieservice_daemon process
    ${MIES_INSTALL_PATH}/bin/mindieservice_daemon >> /dev/stdout 2>&1 &
    DAEMON_PID=$!

    # Trap to handle SIGTERM and SIGINT for graceful shutdown
    trap "echo 'Stopping mindieservice_daemon...'; kill -TERM $DAEMON_PID" SIGTERM SIGINT

    # Start the monitoring script in the background
    ./health_monitor.sh "$MANAGEMENT_IP_ADDRESS" "$MANAGEMENT_PORT" "$SELF_HEALING_TIMEOUT" "$SELF_HEALING_INIT_TIME" "$SELF_HEALING_RETRY_INTERVAL" "$SELF_HEALING_RESTART_TIME" >> /dev/stdout 2>&1 &
    MONITOR_PID=$!

    # Wait for either the service daemon or the monitor to exit
    while true; do
        # Wait for either mindieservice_daemon or health_monitor to exit
        wait -n $DAEMON_PID $MONITOR_PID
        EXITED_PID=$?

        if [ $EXITED_PID -eq $DAEMON_PID ]; then
            # mindieservice_daemon exited
            echo "mindieservice_daemon has exited. Checking exit code..."
            DAEMON_EXIT_CODE=$?
            
            if [ $DAEMON_EXIT_CODE -ne 0 ]; then
                echo "mindieservice_daemon failed. Restarting interactive shell..."
                exec /bin/bash
            else
                echo "mindieservice_daemon exited normally."
                break
            fi
        elif [ $EXITED_PID -eq $MONITOR_PID ]; then
            # health_monitor.sh exited
            echo "Health monitor process exited. Investigate the cause."
            break
        fi
    done

else
    echo "Self-healing is disabled. Starting service without monitoring..."

    # Start the mindieservice_daemon without monitoring
    ${MIES_INSTALL_PATH}/bin/mindieservice_daemon >> /dev/stdout 2>&1 &
    DAEMON_PID=$!

    # Trap to handle SIGTERM and SIGINT for graceful shutdown
    trap "echo 'Stopping mindieservice_daemon...'; kill -TERM $DAEMON_PID" SIGTERM SIGINT

    # Wait for the service to exit
    wait $DAEMON_PID
    DAEMON_EXIT_CODE=$?

    if [ $DAEMON_EXIT_CODE -ne 0 ]; then
        echo "Failed to run mindieservice_daemon. Starting interactive bash shell."
        exec /bin/bash
    fi
fi