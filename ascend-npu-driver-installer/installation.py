#!/usr/bin/env python3
# coding: utf-8
# Copyright 2025 Huawei Technologies Co., Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# ===========================================================================

import glob
import os
from pathlib import Path
import re
import shutil
import subprocess
from typing import List
import logging
import zipfile

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)


class Commands:
    """
    A class to handle shell commands execution.
    """
    @staticmethod
    def run(command: str) -> None:
        """
        Execute a shell command.
        :param command: The command to execute.
        :return: The output of the command.
        """
        result = subprocess.run(command, check=True, shell=True)
        if result.returncode != 0:
            raise RuntimeError(
                f"Command '{command}' failed with return code {result.returncode}. "
                f"Output: {result.stdout.strip()}, Error: {result.stderr.strip() if result.stderr else ''}"
            )


class Installation:
    """
    A class to handle the installation of NPU drivers in a container environment.
    """

    def __init__(self):
        self.working_dir = "/app"
        self.kernel_version = os.uname().release
        self.ko_folder = f"/lib/modules/{self.kernel_version}/npu_driver"
        self.ascend_tool_path = "/usr/local/Ascend/driver/tools"
        self.npu_pattern = "Ascend-hdk-*-npu_*.zip"
        self.npu_run_file = None
        self.driver_dir = os.path.join(self.working_dir, "npu_driver")
        self.ko_files = Path("/app/ko_files")

    def _unzip_npu_driver(self):
        npu_unzipped_folder = os.path.join(self.working_dir, "npu_unzipped_driver")
        pattern = os.path.join(self.working_dir, self.npu_pattern)
        matches = glob.glob(pattern)
        if not matches:
            raise FileNotFoundError("No NPU driver zip file matching pattern found.")
        outer_zip = matches[0]

        with zipfile.ZipFile(outer_zip, 'r') as zip1:
            zip1.extractall(npu_unzipped_folder)

        inner_zips = glob.glob(os.path.join(npu_unzipped_folder, self.npu_pattern))
        if not inner_zips:
            raise FileNotFoundError("No NPU driver zip file matching pattern found.")
        inner_zip = inner_zips[0]
        with zipfile.ZipFile(inner_zip, 'r') as zip2:
            zip2.extractall(npu_unzipped_folder)

        # 查找 .run 文件
        run_files = glob.glob(os.path.join(npu_unzipped_folder, '*-npu-driver_*.run'))
        if not run_files:
            raise FileNotFoundError("No npu driver .run file found in extracted content.")
        self.npu_run_file = run_files[0]

    def _unzip_npu_run_file(self):
        self._unzip_npu_driver()
        command = "bash {} --noexec --extract={}".format(self.npu_run_file, self.driver_dir)
        Commands.run(command)
        logging.info("Unzipped npu run file successfully.")
        
    def _setup(self):
        """
        Setup the installation environment
        """
        paths = [
            "/usr/local/Ascend",
            "/user/local/Ascend/driver/lib64/common",
            self.ko_folder
        ]

        for path in paths:
            if os.path.exists(path):
                logging.info(f"Removing existing directory: {path}")
                shutil.rmtree(path)
            os.makedirs(path, exist_ok=True)
            logging.info(f"Created directory: {path}")

        logging.info("Setup completed successfully.")

    def _copy_resources(self):
        """
        Copy necessary resources for installation.
        """
        commands = [
            f"cp -r {self.driver_dir}/driver /usr/local/Ascend/",
            "cp -r /app/davinci.conf /mnt/lib/",
            f"cp -r {self.driver_dir}/driver/script/dms_events_conf.lst /etc/",
            "cp /usr/local/Ascend/driver/lib64/*.so /usr/local/Ascend/driver/lib64/common",
            f"cp /app/ko_files/*.ko {self.ko_folder}",
        ]
        for command in commands:
            Commands.run(command)
        logging.info("Resources copied successfully.")

    @staticmethod
    def _update_permissions():
        """
        Update permissions for the copied resources.
        """
        commands = [
            "chmod 777 /mnt/lib/davinci.conf",
            "chmod 777 /etc/dms_events_conf.lst"
        ]
        for command in commands:
            Commands.run(command)
        logging.info("Permission updated successfully.")

    @staticmethod
    def _extract_array(content: str, key: str) -> List[str]:
        """
        Extract an array of strings from a given content based on a key.
        :param content: The content to search in.
        :param key: The key to search for.
        :return: A list of strings extracted from the content.
        """
        pattern = rf"{key}=\((.*?)\)"
        match = re.search(pattern, content, re.DOTALL)
        if not match:
            raise ValueError(f"Key '{key}' not found in content.")
        return match.group(1).strip().split()

    def _update_specific_func(self):
        target_dir = "/usr/local/Ascend/driver/device"
        specific_func_file = f"{self.driver_dir}/driver/script/specific_func.inc"

        with open(specific_func_file, 'r', encoding="utf-8") as file:
            content = file.read()

        src_names = self._extract_array(content, "src_names")
        dst_names = self._extract_array(content, "dst_names")

        if len(src_names) != len(dst_names):
            raise ValueError("The number of source names and destination names do not match.")
        for (i, src) in enumerate(src_names):
            src_file = f"{target_dir}/{src}"
            dst_file = f"{target_dir}/{dst_names[i]}"

            if not glob.glob(src_file):
                raise FileNotFoundError(f"Source file '{src_file}' does not exist.")

            Commands.run(f"mv {src_file} {dst_file}")
            logging.info(f"Renaming {src_file} to {dst_file} successfully.")
    
    @staticmethod
    def _install_ko():
        command = "bash /app/install_ko.sh"
        Commands.run(command)
        logging.info(f"Installed ko files successfully.")

    def _make_file_executable(self):
        command = f"chmod +x {self.ascend_tool_path}/*"
        Commands.run(command)
        logging.info(f"Make all the file in {self.ascend_tool_path} to executable successfully.")

    def _configure_env(self):
        """
        Configure the environment for the installation.
        """
        env_path = Path("/etc/profile.d/ascend.sh")
        env_content = (
            "export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:"
            "/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH\n"
            f"export PATH=$PATH:{self.ascend_tool_path}/"
            )

        try:
            with env_path.open("w", encoding="utf-8") as env_file:
                env_file.write(env_content)
            logging.info("Environment configured successfully.")
        except Exception as e:
            raise RuntimeError(f"Failed to configure environment: {e}") from e
        
        # add env command to bashrc
        # mount: /root/.bashrc:/host_bashrc
        bashrc_path = Path("/host_bashrc")
        env_command = f"bash {env_path}\n"
        try:
            if bashrc_path.exists():
                content = bashrc_path.read_text(encoding="utf-8")
                if env_command.strip() not in content:
                    with bashrc_path.open("a", encoding="utf-8") as bashrc_file:
                        bashrc_file.write(env_command)
        except Exception as e:
            raise RuntimeError(f"Failed to add env command to bashrc: {e}") from e

    def install(self):
        """
        Main installation method that orchestrates the setup, copying of resources,
        updating permissions, installing kernel objects, and configuring the environment.
        """
        self._setup()
        self._unzip_npu_run_file()
        self._copy_resources()
        self._update_permissions()
        self._update_specific_func()
        self._install_ko()
        self._configure_env()


if __name__ == "__main__":
    installer = Installation()
    installer.install()
    logging.info("NPU driver installed successfully.")