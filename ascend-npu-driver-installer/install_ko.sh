#!/bin/bash

echo "start depmod..."
depmod
echo "finish depmod."
kernel_version=$(uname -r)
dir="/lib/modules/$kernel_version/npu_driver"
if [ -d "$dir" ]; then
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
           fi
        fi
    done
else
    echo "Directory $dir does not exist."
fi