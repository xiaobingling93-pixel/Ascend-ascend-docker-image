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

import json
import glob
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
from typing import List, Tuple
import logging
import zipfile

# constants for container
CTR_WORKING_DIR = "/app"

# constants for host
HOST_OS_RELEASE = "/host-os-release"
HOST_ETC = "/mnt/etc"
# mount lib of host to container: -v /lib:/mnt/lib
# avoid some protential issues
HOST_LIB = "/mnt/lib"
HOST_ASCEND_DIR = "/mnt/usr/local/Ascend"


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

def get_os_info() -> Tuple[str, str]:
    os_name, os_version = "", ""
    try: 
        with open(HOST_OS_RELEASE, "r", encoding="utf-8") as f: 
            for line in f: 
                if line.startswith("NAME="): 
                    os_name = line.split("=")[1].strip().strip('"') 
                elif line.startswith("VERSION_ID="): 
                    os_version = line.split("=")[1].strip().strip('"') 
    except Exception as e: 
        raise RuntimeError(f"Failed to read OS information: {e}") from e
    return os_name, os_version

# constants for os info
OS_NAME, OS_VERSION = get_os_info()
ARCH = platform.machine()
KERNEL_VERSION = platform.release()


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
        logging.info("Executing command: %s", command)
        result = subprocess.run(command, check=True, shell=True)
        if result.returncode != 0:
            raise RuntimeError(
                f"Command '{command}' failed with return code {result.returncode}. "
                f"Output: {result.stdout.strip()}, "
                f"Error: {result.stderr.strip() if result.stderr else ''}"
            )


class Base:
    """ A base class for installation handling."""

    def __init__(self):
        self.using_ko_compile = os.getenv("KO_COMPILE", "0")

        # dir in container
        self.ctr_npu_zip_dir = os.path.join(CTR_WORKING_DIR, "npu_driver_zip")
        self.ctr_npu_pattern = "*-*-npu_*.zip"
        self.ctr_npu_unzipped_folder = os.path.join(
            CTR_WORKING_DIR, "npu_unzipped_driver")
        self.ctr_driver_dir = os.path.join(CTR_WORKING_DIR, "npu_driver")
        self.ctr_ko_files = os.path.join(CTR_WORKING_DIR, "ko_files")
        self.ctr_precompiled_ko_files = os.path.join(
            CTR_WORKING_DIR, 
            "precompiled-ko-files", 
            OS_NAME, 
            OS_VERSION, 
            ARCH
        )

        # dir in host
        self.host_ascend_driver_path = os.path.join(
            HOST_ASCEND_DIR, "driver")
        self.host_ascend_tool_path = os.path.join(
            self.host_ascend_driver_path, "tools")
        self.host_ascend_lib64_path = os.path.join(
            self.host_ascend_driver_path, "lib64")
        self.host_kernel_path = f"/lib/modules/{KERNEL_VERSION}/build"
        self.host_ko_files = f"/lib/modules/{KERNEL_VERSION}/npu_driver"
        self.install_info = os.path.join(HOST_ETC, "ascend_install.info") 

        self.pre_check()

    def find_file(self, pattern: str) -> str:
        """
        Find a file matching the given pattern.
        :param pattern: The pattern to search for.
        :return: The path of the found file.
        """
        matches = glob.glob(pattern)
        if not matches:
            raise FileNotFoundError(f"No file matching pattern '{pattern}' found")
        return matches[0]

    def pre_check(self):
        """
        Pre-check the environment before installation.
        """
        if not os.path.exists(self.host_kernel_path):
            raise FileNotFoundError(
                f"{self.host_kernel_path} does not exist, please ensure the kernel headers are installed")
        logging.info("Pre-check successfully")

class NpuProcessor(Base):
    """ A class to handle NPU driver processing operations.
    """
    FILE_NAME = "os_version.json"
    DEFAULT_PATH = "/app"

    def __init__(self, force_compile: bool=False):
        super().__init__()
        self.force_compile = force_compile
        self.using_precompiled_ko = False

    @staticmethod
    def read_json() -> dict:
        """
        Read a JSON file and return its content as a dictionary.
        :param file_path: The path to the JSON file.
        :return: A dictionary containing the JSON content.
        """
        file_path = os.path.join(
            NpuProcessor.DEFAULT_PATH, NpuProcessor.FILE_NAME)
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                return json.load(file)
        except Exception as e:
            raise RuntimeError(f"Failed to read JSON file {file_path}: {e}") from e

    def _compile_ko_files(self, npu_run_file: str):
        Commands.run(f"bash {npu_run_file} --noexec --extract={self.ctr_driver_dir}")
        kernel_path = os.path.join(self.ctr_driver_dir, "driver", "kernel")
        makefile = self.find_file(os.path.join(kernel_path, "Makefile_*"))
        dkms_conf = self.find_file(os.path.join(kernel_path, "dkms_*.conf"))
        logging.info("Found makefile: %s, dkms_conf: %s", makefile, dkms_conf)

        os.chdir(f"{self.ctr_driver_dir}/driver/kernel")
        origin_make = ""
        try:
            with open(dkms_conf, "r", encoding="utf-8") as file:
                content = file.read()
            for line in content.splitlines():
                if line.startswith("MAKE[0]"):
                    origin_make = line.split("MAKE[0]=")[1].strip()
        except Exception as e:
            raise RuntimeError(f"Failed to read {dkms_conf}: {e}") from e
        origin_make = origin_make.strip("\"").replace("KERNEL_UNAME=${kernelver}", "")
        commands = [
            f"cp {makefile} {kernel_path}/Makefile",
            origin_make,
            f"find . -type f -name '*.ko' -exec cp {{}} {self.ctr_ko_files} \\;",
        ]
        for command in commands:
            Commands.run(command)
        logging.info("Unzip NPU file and compile ko files: %s successfully",  self.ctr_driver_dir)
    
    def _repack_npu(self, npu_run_file: str):
        """
        step 1: extract *.run to temp
        step 2: repack temp
        step 3: extract temp-custom.run
        step 4: get ko files from self.ctr_driver_dir/driver/host
        """
        repack_npu = os.path.join(self.ctr_npu_unzipped_folder, "repack_npu")

        Commands.run(f"bash {npu_run_file} --noexec --extract={repack_npu}")

        repack_cmd = f"bash {npu_run_file} --repack-path={repack_npu} {repack_npu}.run"
        logging.info(f"execute cmd: {repack_cmd}")
        proc = subprocess.Popen(
            repack_cmd, 
            stdin=subprocess.PIPE, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            text=True, 
            shell=True)
        user_input = f"y\n{self.host_kernel_path}"
        stdout, stderr = proc.communicate(user_input)
        logging.info(stderr)
        logging.info(stdout)

        commands = [
            f"bash {repack_npu}.run --noexec --extract={self.ctr_driver_dir}",
            f"cp {self.ctr_driver_dir}/driver/host/*.ko {self.ctr_ko_files}/"
        ]
        for command in commands:
            Commands.run(command)
        logging.info(f"Unzipped and repack NPU file: {npu_run_file} successfully")
    
    def unzip_npu_driver(self) -> Tuple[str, str]:
        """ Unzip the NPU driver zip file and extract the .run file.
        :return: A tuple containing the NPU name without extension and the path to the .run file.
        """
        outer_zip = self.find_file(os.path.join(
            self.ctr_npu_zip_dir, self.ctr_npu_pattern))
        logging.info("Detected NPU driver zip package: %s", outer_zip)

        with zipfile.ZipFile(outer_zip, 'r') as zip1:
            zip1.extractall(self.ctr_npu_unzipped_folder)

        inner_zip = self.find_file(os.path.join(
            self.ctr_npu_unzipped_folder, self.ctr_npu_pattern))
        with zipfile.ZipFile(inner_zip, 'r') as zip2:
            zip2.extractall(self.ctr_npu_unzipped_folder)

        # query npu run file, like: Ascend-hdk-910-npu-driver_25.2.0_linux-x86-64.run
        run_file = self.find_file(
            os.path.join(self.ctr_npu_unzipped_folder, '*-npu-driver_*.run'))
        npu_name = Path(outer_zip)
        npu_name_without_extension = npu_name.stem
        logging.info("Unzipped NPU driver package:%s successfully, got run file: %s", outer_zip, run_file)
        return npu_name_without_extension, run_file

    def process_ko(self, npu_version: str, npu_run_file: str):
        """ Copy compiled .ko files to the container directory.
        """
        # An example of precompiled ko files path:
        # /app/precompiled-ko-files/openEuler/22.03/aarch64/5.10.0-60.18.0.50.oe2203.aarch64/npu_version
        src_path = os.path.join(self.ctr_precompiled_ko_files, KERNEL_VERSION, npu_version)
        if os.path.exists(src_path) and not self.force_compile:
            self.using_precompiled_ko = True
            logging.info("Find precompiled ko files: %s, No need to compile ko files", src_path)
            commands = [
                    f"cp {src_path}/*.ko {self.ctr_ko_files}/",
                    f"bash {npu_run_file} --noexec --extract={self.ctr_driver_dir}"
                ]
            for command in commands:
                Commands.run(command)
            logging.info(
                "Copied precompiled .ko files to container directory: %s successfully", 
                self.ctr_ko_files,
            )
            return
        logging.info("start to compile from source")
        if self.using_ko_compile == "1":
            logging.info("ENV: KO_COMPILE=%s, compile ko files.", self.using_ko_compile)
            self._compile_ko_files(npu_run_file)
        else:
            logging.info("ENV: KO_COMPILE=%s, repack npu files.", self.using_ko_compile)
            self._repack_npu(npu_run_file)

    def is_using_precompiled_ko(self) -> bool:
        return self.using_precompiled_ko


class Installation(Base):
    """
    A class to handle the installation of NPU drivers in a container environment.
    """

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
                logging.info("Removing existing directory: %s", path)
                shutil.rmtree(path)

    def _make_file_executable(self):
        command = f"chmod +x {self.host_ascend_tool_path}/*"
        Commands.run(command)
        logging.info("Make all the file in %s to executable successfully",
                     self.host_ascend_tool_path)

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
            raise ValueError(f"Key '{key}' not found in content")
        return match.group(1).strip().split()

    def setup(self):
        """
        Setup the installation environment
        """
        self._clear()
        paths = [
            HOST_ASCEND_DIR,
            os.path.join(self.host_ascend_lib64_path, "common"),
            self.ctr_ko_files,
            self.host_ko_files
        ]

        for path in paths:
            os.makedirs(path, exist_ok=True)
            logging.info("Created directory: %s", path)
        logging.info("Setup successfully")

    def copy_resources(self):
        """
        Copy necessary resources for installation.
        """
        commands = [
            f"cp -r {self.ctr_driver_dir}/driver {HOST_ASCEND_DIR}",
            f"cp -r /app/davinci.conf {HOST_LIB}",
            f"cp -r {self.host_ascend_driver_path}/script/dms_events_conf.lst {HOST_ETC}",
            f"cp {self.host_ascend_lib64_path}/*.so '{self.host_ascend_lib64_path}/common'",
            f"cp {self.ctr_ko_files}/*.ko {self.host_ko_files}",
        ]
        for command in commands:
            Commands.run(command)
        logging.info("Resources copied successfully")

    def update_permissions(self):
        """
        Update permissions for the copied resources.
        """
        commands = [
            f"chmod 777 {os.path.join(HOST_LIB, 'davinci.conf')}",
            f"chmod 777 {os.path.join(HOST_ETC, 'dms_events_conf.lst')}"
        ]
        for command in commands:
            Commands.run(command)
        logging.info("Permission updated successfully")

    def update_specific_func(self):
        """
        update the spcific_func.inc file to rename some files
        """
        target_dir = os.path.join(self.host_ascend_driver_path, "device")
        specific_func_file = f"{self.host_ascend_driver_path}/script/specific_func.inc"

        with open(specific_func_file, 'r', encoding="utf-8") as file:
            content = file.read()

        src_names = self._extract_array(content, "src_names")
        dst_names = self._extract_array(content, "dst_names")

        if len(src_names) != len(dst_names):
            raise ValueError("The number of source names and destination names do not match")
        
        for (i, src) in enumerate(src_names):
            src_file = f"{target_dir}/{src}"
            dst_file = f"{target_dir}/{dst_names[i]}"

            if not glob.glob(src_file):
                raise FileNotFoundError(f"Source file '{src_file}' does not exist.")

            Commands.run(f"mv {src_file} {dst_file}")
            logging.info("Renaming %s to %s successfully", src_file, dst_file)

    @staticmethod
    def install_ko() -> bool:
        """ Install kernel object files using the provided script.
        """
        command = "bash /app/install_ko.sh"
        try:
            Commands.run(command)
            logging.info("Installed ko files successfully")
            return True
        except Exception as e:
            logging.info(f"Installed ko files failed: {str(e)}")
            return False

    def configure_env(self):
        """
        Configure the environment for the installation.
        """
        env_path = Path(f"{HOST_ETC}/profile.d/ascend.sh")
        env_content = (
            "export LD_LIBRARY_PATH=/usr/local/Ascend/driver/lib64/common:"
            "/usr/local/Ascend/driver/lib64/driver:$LD_LIBRARY_PATH\n"
            "export PATH=$PATH:/usr/local/Ascend/driver/tools/\n"
        )

        try:
            with env_path.open("w", encoding="utf-8") as env_file:
                env_file.write(env_content)
            logging.info("Environment configured successfully")
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
            with open(self.install_info, "w", encoding="utf-8") as f:
                f.write(f"{prefix}=complete")
            return
        with open(self.install_info, "r", encoding="utf-8") as f:
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

        with open(self.install_info, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        logging.info("Write install complete info to %s successfully", self.install_info)

    def install(self):
        """
        Main installation including following methods: 
        - orchestrates the setup
        - copying of resources,
        - updating permissions
        - installing kernel objects
        - configuring the environment.
        """
        retry = 1
        force_compile = os.getenv("FORCE_COMPILE", False)
        while retry <= 2:
            npu_processor = NpuProcessor(force_compile)
            self.setup()
            npu_name, npu_run_file = npu_processor.unzip_npu_driver()
            npu_processor.process_ko(npu_name, npu_run_file)
            self.copy_resources()
            self.update_permissions()
            self.update_specific_func()
            if not self.install_ko() and npu_processor.is_using_precompiled_ko():
                logging.info("Install the precompiled ko failed, try to build ko from source and install again")
                force_compile = True
                retry+=1
                continue
            break
        self.configure_env()
        self.write_complete_signal()


if __name__ == "__main__":
    installer = Installation()
    installer.install()
    logging.info("NPU driver installed successfully")
