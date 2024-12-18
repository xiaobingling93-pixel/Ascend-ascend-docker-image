#!/bin/bash

# Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "start install mindspore, wait for a minute..."
pip3 install mindspore-2.4.0-cp310-cp310-linux_aarch64.whl
if [ $? -eq 0 ]; then
    echo "pip3 install mindspore successfully"
else
    echo "pip3 install mindspore failed"
fi

echo "start install mindformers, wait for a minute..."
pip3 install mindformers-1.3.0-py3-none-any.whl
if [ $? -eq 0 ]; then
    echo "pip3 install mindspore successfully"
else
    echo "pip3 install mindspore failed"
fi

# Resolve the deps conflict with MindIE
pip3 install tokenizers==0.19.1
