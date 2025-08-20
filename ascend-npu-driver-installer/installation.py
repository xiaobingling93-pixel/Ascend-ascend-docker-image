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
        logging.info(f"Executing command: {command}")
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

        self.using_ko_compile = os.getenv("KO_COMPILE", "0")
        
        # dir in container
        self.ctr_working_dir = "/app"
        self.ctr_npu_zip_dir = os.path.join(self.ctr_working_dir, "npu_driver_zip")
        self.ctr_npu_pattern = "*-*-npu_*.zip"
        self.ctr_npu_run_file = None
        self.ctr_npu_unzipped_folder = os.path.join(self.ctr_working_dir, "npu_unzipped_driver")
        self.ctr_driver_dir = os.path.join(self.ctr_working_dir, "npu_driver")
        self.ctr_ko_files = os.path.join(self.ctr_working_dir, "ko_files")

        # dir in host
        self.host_ascend_base_path = "/mnt/usr/local/Ascend"
        self.host_ascend_driver_path = os.path.join(self.host_ascend_base_path, "driver")
        self.host_ascend_tool_path = os.path.join(self.host_ascend_driver_path, "tools")
        self.host_ascend_lib64_path = os.path.join(self.host_ascend_driver_path, "lib64")
        self.kernel_version = os.uname().release
        self.host_ko_files = f"/lib/modules/{self.kernel_version}/npu_driver"
        # mount lib of host to container: -v /lib:/mnt/lib
        # avoid some protential issues
        self.host_mnt_lib = "/mnt/lib"
        self.host_etc = "/mnt/etc"
        self.install_info = os.path.join(self.host_etc, "ascend_install.info")

    def _clear(self):
        """
        Clear the working directory by removing all files and subdirectories.
        """
        for path in [
            self.ctr_driver_dir, 
            self.ctr_npu_unzipped_folder, 
            self.ctr_ko_files,
            self.host_ascend_driver_path, 
            self.host_ko_files
        ]:
            if os.path.exists(path):
                logging.info(f"Removing existing directory: {path}")
                shutil.rmtree(path)

    def _make_file_executable(self):
        command = f"chmod +x {self.host_ascend_tool_path}/*"
        Commands.run(command)
        logging.info(f"Make all the file in {self.host_ascend_tool_path} to executable successfully.")

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
        
    def _unzip_npu_driver(self):
        pattern = os.path.join(self.ctr_npu_zip_dir, self.ctr_npu_pattern)
        matches = glob.glob(pattern)
        if not matches:
            raise FileNotFoundError("No NPU driver zip file matching pattern found.")
        outer_zip = matches[0]
        logging.info(f"Detected NPU driver zip package: {outer_zip}")

        with zipfile.ZipFile(outer_zip, 'r') as zip1:
            zip1.extractall(self.ctr_npu_unzipped_folder)

        inner_zips = glob.glob(os.path.join(self.ctr_npu_unzipped_folder, self.ctr_npu_pattern))
        if not inner_zips:
            raise FileNotFoundError("No NPU driver zip file matching pattern found.")
        inner_zip = inner_zips[0]
        with zipfile.ZipFile(inner_zip, 'r') as zip2:
            zip2.extractall(self.ctr_npu_unzipped_folder)

        # 查找 .run 文件
        run_files = glob.glob(os.path.join(self.ctr_npu_unzipped_folder, '*-npu-driver_*.run'))
        if not run_files:
            raise FileNotFoundError("No npu driver .run file found in extracted content.")
        self.npu_run_file = run_files[0]
    
    def setup(self):
        """
        Setup the installation environment
        """
        self._clear()
        paths = [
            self.host_ascend_base_path,
            os.path.join(self.host_ascend_lib64_path, "common"),
            self.ctr_ko_files,
            self.host_ko_files
        ]

        for path in paths:
            os.makedirs(path, exist_ok=True)
            logging.info(f"Created directory: {path}")
        logging.info("Setup completed successfully.")

    def process_npu(self):
        self._unzip_npu_driver()
        if self.using_ko_compile == "1":
            logging.info(f"ENV: KO_COMPILE={self.using_ko_compile}, compile ko files.")
            self._compile_ko_files()
        else:
            logging.info(f"ENV: KO_COMPILE={self.using_ko_compile}, repack npu files.")
            self._repack_npu()

    def _compile_ko_files(self):
        Commands.run(f"bash {self.npu_run_file} --noexec --extract={self.ctr_driver_dir}")
        kernel_path = os.path.join(self.ctr_driver_dir, "driver", "kernel")
        
        makefile = os.path.join(kernel_path, "Makefile_milan")
        if not os.path.exists(makefile):
            makefile = os.path.join(kernel_path, "Makefile_mini1910p")
        dkms_conf = os.path.join(kernel_path, "dkms_milan.conf")
        if not os.path.exists(dkms_conf):
            dkms_conf =  os.path.join(kernel_path, "dkms_mini1910p.conf")

        os.chdir(f"{self.ctr_driver_dir}/driver/kernel")
        origin_make = ""
        try:
            with open(dkms_conf, "r", encoding="utf-8") as file:
                content = file.read()
            for line in content.splitlines():
                if line.startswith("MAKE[0]"):
                    origin_make = line.split("MAKE[0]=")[1].strip()
        except Exception as e:
            raise RuntimeError(f"Failed to read dkms_milan.conf: {e}") from e
        origin_make = origin_make.strip("\"").replace("KERNEL_UNAME=${kernelver}", "")
        commands = [
            f"cp {makefile} {kernel_path}/Makefile",
            origin_make,
            f"find . -type f -name '*.ko' -exec cp {{}} {self.ctr_ko_files} \\;",
        ]
        for command in commands:
            Commands.run(command)
        logging.info(f"Unzip NPU file and compile ko files: {self.ctr_driver_dir} successfully.")

    def _repack_npu(self):
        """
        step 1: extract *.run to temp
        step 2: repack temp
        step 3: extract temp-custom.run
        step 4: get ko files from self.ctr_driver_dir/driver/host
        """
        repack_npu = os.path.join(self.ctr_npu_unzipped_folder, "repack_npu")

        Commands.run(f"bash {self.npu_run_file} --noexec --extract={repack_npu}")

        repack_cmd = f"bash {self.npu_run_file} --repack-path={repack_npu} {repack_npu}.run"
        logging.info(f"execute cmd: {repack_cmd}")
        proc = subprocess.Popen(
            repack_cmd, 
            stdin=subprocess.PIPE, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            text=True, 
            shell=True)
        user_input = f"y\n/lib/modules/{self.kernel_version}/build"
        stdout, stderr = proc.communicate(user_input)
        logging.info(stderr)
        logging.info(stdout)

        commands = [
            f"bash {repack_npu}.run --noexec --extract={self.ctr_driver_dir}",
            f"cp {self.ctr_driver_dir}/driver/host/*.ko {self.ctr_ko_files}/"
        ]
        for command in commands:
            Commands.run(command)
        logging.info(f"Unzipped and repack NPU file: {self.npu_run_file} successfully.")

    def copy_resources(self):
        """
        Copy necessary resources for installation.
        """
        commands = [
            f"cp -r {self.ctr_driver_dir}/driver {self.host_ascend_base_path}",
            f"cp -r /app/davinci.conf {self.host_mnt_lib}",
            f"cp -r {self.host_ascend_driver_path}/script/dms_events_conf.lst {self.host_etc}",
            f"cp {self.host_ascend_lib64_path}/*.so {os.path.join(self.host_ascend_lib64_path, 'common')}",
            f"cp {self.ctr_ko_files}/*.ko {self.host_ko_files}",
        ]
        for command in commands:
            Commands.run(command)
        logging.info("Resources copied successfully.")

    def update_permissions(self):
        """
        Update permissions for the copied resources.
        """
        commands = [
            f"chmod 777 {os.path.join(self.host_mnt_lib, 'davinci.conf')}",
            f"chmod 777 {self.host_etc}/dms_events_conf.lst"
        ]
        for command in commands:
            Commands.run(command)
        logging.info("Permission updated successfully.")

    def update_specific_func(self):
        target_dir = os.path.join(self.host_ascend_driver_path, "device")
        specific_func_file = f"{self.host_ascend_driver_path}/script/specific_func.inc"

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
    def install_ko():
        command = "bash /app/install_ko.sh"
        Commands.run(command)
        logging.info(f"Installed ko files successfully.")

    def configure_env(self):
        """
        Configure the environment for the installation.
        """
        env_path = Path(f"{self.host_etc}/profile.d/ascend.sh")
        env_content = (
            "export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:"
           "/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH\n"
            "export PATH=$PATH:/usr/local/Ascend/driver/tools/\n"
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
        env_command = "bash /etc/profile.d/ascend.sh\n"
        try:
            if bashrc_path.exists():
                content = bashrc_path.read_text(encoding="utf-8")
                if env_command.strip() not in content:
                    with bashrc_path.open("a", encoding="utf-8") as bashrc_file:
                        bashrc_file.write(env_command)
        except Exception as e:
            raise RuntimeError(f"Failed to add env command to bashrc: {e}") from e

    def write_complete_signal(self):
        """
        Write a completion signal to a file.
        """
        prefix = "Driver_Install_Status"
        if not os.path.exists(self.install_info):
            with open(self.install_info, "w") as f:
                f.write(f"{prefix}=complete")
            return 
        with open(self.install_info, "r") as f:
            lines = f.readlines()

        new_lines = []
        found = False
        for line in lines:
            if line.startswith(prefix):
                new_lines.append(f"{prefix}=complete")
                found = True
            else:
                new_lines.append(line)

        if not found:
            new_lines.append(f"{prefix}=complete")

        with open(self.install_info, "w") as f:
            f.writelines(new_lines)
        logging.info(f"Write install complete info to {self.install_info} successfully.")

    def install(self):
        """
        Main installation method that orchestrates the setup, copying of resources,
        updating permissions, installing kernel objects, and configuring the environment.
        """
        self.setup()
        self.process_npu()
        self.copy_resources()
        self.update_permissions()
        self.update_specific_func()
        self.install_ko()
        self.configure_env()
        self.write_complete_signal()

if __name__ == "__main__":
    installer = Installation()
    installer.install()
    logging.info("NPU driver installed successfully.")
