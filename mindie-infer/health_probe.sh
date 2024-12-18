#!/bin/bash

#######################################################################################
# Check /health/timed-3
#######################################################################################

config_file="/home/HwHiAiUser/Ascend/mindie/latest/mindie-service/conf/config.json"

management_port=$(grep '"managementPort"' "$config_file" | sed 's/[^0-9]*//g')

# if [[ -z "$management_port" ]]; then
#     echo "Failed to read managementPort from config file."
#     exit 1
# else
#     echo "Management Port is: $management_port"
# fi

# response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -m 3 "http://0.0.0.0:$management_port/health/timed-3")
response_file=~/health_response
curl --silent --write-out "HTTPSTATUS:%{http_code}" -m 3 "http://0.0.0.0:$management_port/health/timed-3" > "$response_file" &


#######################################################################################
# Check npu-smi info
#######################################################################################

npu_id=$(awk 'NR==2 {print $1}' ~/device_info)
# npu_id=$(npu-smi info -m | awk 'NR==2 {print $1}')
max_aicore_usage=0
num_samples=4

for ((i=0; i<num_samples; i++)); do
    output=$(npu-smi info -t usages -i "$npu_id")

    aicore_usage=$(echo "$output" | grep 'Aicore Usage Rate(%)' | awk '{print $NF}' | tr -d '%')
    # echo $aicore_usage

    if [[ -n "$aicore_usage" && "$aicore_usage" -gt "$max_aicore_usage" ]]; then
        max_aicore_usage=$aicore_usage
    fi

    if (( i < num_samples - 1 )); then
        sleep 0.1
    fi
done

# echo "Maximum Aicore Usage Rate(%) recorded: $max_aicore_usage"

if (( max_aicore_usage < 10 )); then
    # echo "Core utilization abnormal: Max Aicore Usage Rate is less than 10."
    core_abnormal=true
else
    # echo "Core utilization is normal."
    core_abnormal=false
fi


#######################################################################################
# Final conclusion
#######################################################################################

wait $!
response=$(<"$response_file")
response_body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
response_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

if [[ "$response_code" -ne 200 ]] || [[ "$response_body" != '{"status":"healthy"}' ]]; then
    # echo "The service might be deadlocked."
    timed_out=true
else
    # echo "The service is healthy."
    timed_out=false
fi

if [[ "$timed_out" == true && "$core_abnormal" == true ]]; then
    # echo "Service may be deadlocked, check again..."
    max_aicore_usage=0
    num_samples=6

    for ((i=0; i<num_samples; i++)); do
        output=$(npu-smi info -t usages -i "$npu_id")

        aicore_usage=$(echo "$output" | grep 'Aicore Usage Rate(%)' | awk '{print $NF}' | tr -d '%')
        # echo $aicore_usage

        if [[ -n "$aicore_usage" && "$aicore_usage" -gt "$max_aicore_usage" ]]; then
            max_aicore_usage=$aicore_usage
        fi

        if (( i < num_samples - 1 )); then
            sleep 0.1
        fi
    done

    # echo "Maximum Aicore Usage Rate(%) recorded: $max_aicore_usage"

    if (( max_aicore_usage < 10 )); then
        # echo "Core utilization abnormal: Max Aicore Usage Rate is less than 10."
        core_abnormal=true
    else
        # echo "Core utilization is normal."
        core_abnormal=false
    fi

    if [[ "$timed_out" == true && "$core_abnormal" == true ]]; then
        echo 501
    else
        echo 200
    fi
else
    echo 200
fi