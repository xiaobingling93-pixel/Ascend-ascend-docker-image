#!/usr/bin/env python3
# coding: utf-8
# Copyright 2024 Huawei Technologies Co., Ltd

import glob
import json
import re
import shlex
import subprocess
import sys


def run_cmd(cmd, input_=None):
    result = subprocess.Popen(
        shlex.split(cmd),
        shell=False,
        stdout=subprocess.PIPE,
        stdin=subprocess.PIPE,
        universal_newlines=True,
    )
    out, _ = result.communicate(input=input_)
    return result.returncode, out


def flops_test(args):
    npu_id, chip_name = args
    flops_info = {
        "chip_name": chip_name,
        "npu_id": npu_id,
        "ops": "",
        "ops_type": "fp16",
    }

    ret, stdout = run_cmd(
        f"ascend-dmi -f --fmt json -d {npu_id} -t fp16", input_="y"
    )
    if ret != 0 or "error" in stdout:
        flops_result = "can not test the device"
        flops_info["ops"] = flops_result
        return flops_result, flops_info

    # 解析dmi的结果stdout，保存device_id和tflops_fp16
    parts = stdout.split("\n", 1)
    if "y" in parts[0]:
        stdout = parts[1]
    flops_dict = json.loads(stdout)
    device_id = flops_dict["computing_power"]["device_id"]
    flops_result = str(flops_dict["computing_power"]["tflops_fp16"])

    if "/" in device_id:
        flops_result = float(flops_result) / len(device_id.split("/"))
    flops_info["ops"] = flops_result
    return flops_result, flops_info


def get_chip_name_list(npu_number):
    _, stdout = run_cmd("ascend-dmi -i --dt")
    if "failed" in stdout:
        raise RuntimeError(
            "The chip is not available, please ensure that no other containers are occupying the chip"
        )
    find_chip_name = re.findall("Chip Name.*: (.*)", stdout)
    if len(find_chip_name) > 0:
        res = [i for i in find_chip_name]
        con = -1
        if "Ascend 310" in res or "Ascend 310P3" in stdout:
            con = 1
        return res, con
    else:
        ret, stdout = run_cmd("npu-smi info")
        if ret == 0:
            find_chip_name = re.findall(r"310\w*|910\w*", stdout)
            if len(find_chip_name) > 0:
                res = [i for i in find_chip_name]
                con = -1
                if "310" in res or "310P3" in res:
                    con = 1
                return res, con
            else:
                return ["310P" for _ in range(npu_number)], 1
        else:
            return ["unknown" for _ in range(npu_number)], 1


def get_npu_count():
    npu_number = len(glob.glob("/dev/davinci[0-9]*"))
    if npu_number == 0:
        raise FileNotFoundError("davinci device is not exists")
    return npu_number


def main():
    chip_name_list, _ = get_chip_name_list(npu_count)
    flops_info_dict = {}
    total_flops = 0.0
    for i in range(npu_count):
        flops_result, flops_info = flops_test((i, chip_name_list[i]))
        if flops_result != "can not test the device":
            total_flops += float(flops_result)
        flops_info_dict[i] = flops_info
    flops_info_dict['total_flops'] = total_flops
    flops_info_json = json.dumps(flops_info_dict, indent=4, sort_keys=True)
    print(flops_info_json)


if __name__ == "__main__":
    try:
        npu_count = get_npu_count()
    except FileNotFoundError as e:
        print(e)
        sys.exit(1)
    main()
