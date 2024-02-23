#!/usr/bin/env python3
# Copyright 2024 Huawei Technologies Co., Ltd

import glob
import os
import platform
import re
import subprocess
import sys


class BenchMark:
    def __init__(self):
        self.arch = platform.machine()
        self.root_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
        try:
            self.type, self.train_data_path, self.eval_data_path = sys.argv[1:-1]
            self.pre_model_path = sys.argv[-1]
            code_dir_list = glob.glob(f"{self.root_dir}/samples/*mindspore_bert*{self.arch}*")
        except ValueError:
            self.type, self.train_data_path, self.eval_data_path = sys.argv[1:]
            code_dir_list = glob.glob(f"{self.root_dir}/samples/*mindspore_resnet*{self.arch}*")
        self.code_dir = code_dir_list[0]
        self.rank_table_file = f"{self.root_dir}/hccl.json"

    def _modify_config_file(self):

        npu_number = len(glob.glob("/dev/davinci[0-9]*"))
        if npu_number == 0:
            raise FileNotFoundError("davinci device is not exists")
        config_file_path = f"{self.code_dir}/code/config/config.sh"
        with open(config_file_path, "r+", encoding="utf-8") as f:
            content = f.readlines()
            for i, v in enumerate(content.copy()):
                if "TRAIN_DATA_PATH" in v:
                    content[i] = f"export TRAIN_DATA_PATH={self.train_data_path}\n"
                if "EVAL_DATA_PATH" in v:
                    content[i] = f"export EVAL_DATA_PATH={self.eval_data_path}\n"
                if "PRETRAIN_MODEL_PATH" in v:
                    content[i] = f"export PRETRAIN_MODEL_PATH={self.pre_model_path}\n"
                if "RANK_TABLE_FILE" in v:
                    content[i] = f"export RANK_TABLE_FILE={self.rank_table_file}\n"
                if "RANK_SIZE" in v:
                    content[i] = f"export RANK_SIZE={npu_number}\n"
                if "DEVICE_NUM" in v:
                    content[i] = f"export DEVICE_NUM={npu_number}\n"
            f.seek(0)
            f.truncate()
            f.writelines(content)

    @staticmethod
    def _check_chip():
        get_npu_info = subprocess.run(
            ["ascend-dmi", "-i"],
            shell=False,
            capture_output=True,
            encoding="utf-8",
        )
        if "failed" in get_npu_info.stdout:
            raise RuntimeError(
                "The chip is not available, please ensure that no other containers are occupying the chip"
            )

    def _run(self):
        os.chdir(self.code_dir)
        p = subprocess.run(
            ["./ais-bench-stubs", "test"], shell=False, stdout=subprocess.DEVNULL
        )
        if p.returncode != 0:
            raise RuntimeError("Training test failed")

    def get_result(self):
        self._check_chip()
        self._modify_config_file()
        self._run()
        log_file_path = f"{self.code_dir}/log/stub.log"
        with open(log_file_path, "r", encoding="utf-8") as f:
            content = f.read()
            res = {}
            pattern = '"throughput_ratio.*'
            throughput_ratio = float(re.findall(pattern, content)[0].split('"')[3])
            if self.type == "resnet50":
                res["throughput_ratio"] = f"{round(throughput_ratio)} images/s"
            else:
                res["throughput_ratio"] = f"{round(throughput_ratio)} sentences/s"
            pattern = '"accuracy.*'
            accuracy = float(re.findall(pattern, content)[0].split('"')[3])
            res["accuracy"] = f"{accuracy:.1%}"
        print(res)


def main():
    ais = BenchMark()
    try:
        ais.get_result()
    except (RuntimeError, FileNotFoundError) as e:
        print(e)
        sys.exit(1)
    except (KeyboardInterrupt, SystemExit):
        sys.exit(1)


if __name__ == "__main__":
    main()
