#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ]; then
    echo "Usage: $0 <ip> <port> <max-timeout> <init-time> <retry-interval> <restart-time>"
    exit 1
fi

# Assign input arguments
IP="127.0.0.1"
PORT=$2
MAX_TIMEOUT=$3
INIT_TIME=$4
RETRY_INTERVAL=$5
RESTART_TIME=$6

# Initialize variables
timeout=10
health_url="http://$IP:$PORT/health/timed-"

echo "--------------------------------------------------"
echo "Monitoring initiated with IP: $IP and Port: $PORT."
echo "max timeout: $MAX_TIMEOUT, init time: $INIT_TIME."
echo "retry interval: $RETRY_INTERVAL, restart time: $RESTART_TIME"
echo "Health checks will begin in $INIT_TIME seconds..."
echo "--------------------------------------------------"

sleep $INIT_TIME

echo "--------------------------------------------------"
echo "Health monitoring started. Checking service status..."
echo "--------------------------------------------------"

# Start monitoring loop
while true; do
    # Adjust the health URL based on current timeout
    current_url="${health_url}$((timeout + 1))"

    # Perform the health check with curl, capture both body and status code
    response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -m $timeout "$current_url")

    # Extract body and status code
    response_body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
    response_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    if [[ "$response_code" == "200" && "$response_body" == '{"status":"healthy"}' ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Service is healthy."
        timeout=10  # Reset timeout if successful
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Received response code: $response_code"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Received response body: $response_body"
        if [ $timeout -ge $MAX_TIMEOUT ]; then
            echo "Final check failed. Restarting the service..."

            # Terminate the service
            pkill -9 mindie_llm
            echo "Service terminated. Waiting for 10 seconds before restarting..."
            sleep 10

            find /dev/shm -name '*llm_backend_pid_*' -type f -exec rm -f {} \;
            find /dev/shm -name 'llm_tokenizer_shared_memory_*' -type f -exec rm -f {} \;

            # Restart the service (adjust the path as needed)
            ${MIES_INSTALL_PATH}/bin/mindieservice_daemon >> /dev/stdout 2>&1 &
            DAEMON_PID=$!
            echo "Service restarted with PID $DAEMON_PID."

            # Reset timeout after restarting service
            timeout=5
            sleep $RESTART_TIME
        fi

        timeout=$((timeout * 2))
        if [ $timeout -gt $MAX_TIMEOUT ]; then
            timeout=$MAX_TIMEOUT
        fi

        echo "$(date '+%Y-%m-%d %H:%M:%S') - Health check failed. Retrying with increased timeout ($timeout seconds)..."

    fi

    sleep $RETRY_INTERVAL
done
