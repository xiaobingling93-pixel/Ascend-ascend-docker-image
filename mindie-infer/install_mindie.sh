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

source ~/Ascend/ascend-toolkit/set_env.sh

mkdir -p ~/Ascend/llm_model
MINDIE="Ascend-mindie_*_linux-*.run"
MODEL="Ascend-mindie-atb-models_*_linux-aarch64_torch2.1.0-abi0.tar.gz"
chmod +x *.run
tar -xzf ./${MODEL} -C ~/Ascend/llm_model
yes | ./${MINDIE} --install --quiet 2> /dev/null
mindie_status=$?
if [ ${mindie_status} -eq 0 ]; then
    echo "install mindie successfully"
else
    echo "install mindie failed with status ${mindie_status}"
fi
