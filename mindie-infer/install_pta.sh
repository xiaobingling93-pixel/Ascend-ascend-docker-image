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

pip3 install torch-2.1.0-cp310-cp310-manylinux_2_17_*.manylinux2014_*$(arch).whl

PYTORCH_MANYLINUX=pytorch_v2.1.0_py310.tar.gz
TORCH_NPU_IN_PYTORCH_MANYLINUX=torch_npu*2.1.0*cp310*cp310*manylinux*$(arch).whl
APEX_IN_PYTORCH_MANYLINUX=apex*cp310*cp310*$(arch).whl

mkdir torch
cp ${PYTORCH_MANYLINUX} torch \
    && cd torch \
    && tar -xzvf ${PYTORCH_MANYLINUX} \
    && cd ..

echo "start install pytorch, wait for a minute..."
pip3 install torch/${TORCH_NPU_IN_PYTORCH_MANYLINUX} --quiet 2> /dev/null
if [ $? -eq 0 ]; then
    echo "pip3 install torchnpu successfully"
else
    echo "pip3 install torchnpu failed"
fi

pip3 install torch/${APEX_IN_PYTORCH_MANYLINUX} --quiet 2> /dev/null
if [ $? -eq 0 ]; then
    echo "pip3 install apex successfully"
else
    echo "pip3 install apex failed"
fi

rm -rf torch