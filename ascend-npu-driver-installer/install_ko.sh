#!/bin/bash

echo "start depmod..."
depmod
echo "finish depmod."

kernel_version=$(uname -r)
dir="/lib/modules/$kernel_version/npu_driver"

if [ ! -d "$dir" ]; then
    echo "ERROR: Directory $dir does not exist."
    exit 1
fi

error_count=0

echo "Files in $dir:"
for file in "$dir"/*.ko; do
    if [ -f "$file" ]; then
        module_name=$(basename "$file" .ko)
        echo "Loading module: $module_name"
        modprobe "$module_name"
        if [ $? -eq 0 ]; then
            echo "Module $module_name loaded successfully."
        else
            echo "Failed to load module $module_name."
            error_count=$((error_count + 1))
        fi
    fi
done

if [ $error_count -eq 0 ]; then
    exit 0
else
    exit 1
fi
