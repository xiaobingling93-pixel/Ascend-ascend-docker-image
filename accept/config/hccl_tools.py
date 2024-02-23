# Copyright 2024 Huawei Technologies Co., Ltd
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
# ============================================================================
"""generate hccl config file script"""
import os
import sys
import json
import socket
from typing import Dict, Any


def get_host_ip():
    """
    get host ip
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    ip = None

    try:
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except EOFError:
        pass
    finally:
        s.close()

    return ip


def check_digit(device_num, visible_device):
    """
    check param
    :return:
    """
    if not str(device_num).isdigit() and not str(visible_device).isdigit():
        return False
    return True


def generate_hccl(device_num, visible_device, server_ip):
    """
    generate hccl.json file
    :return:
    """
    server_id = server_ip if server_ip else get_host_ip()
    if not server_id:
        raise ValueError("get server ip failed, please input server ip!")
    visible_devices = list(map(str, range(int(visible_device))))

    device_num_list = list(range(int(device_num)))

    if len(visible_devices) < len(device_num_list):
        raise ValueError("the number of available devices is less than the number of devices required ")

    # construct hccn_table
    device_ips: Dict[str, str] = {}
    try:
        for device_id in device_num_list:
            """
                ipaddr:192.168.100.100
                netmask:255.255.255.0
            """
            ret = os.popen("hccn_tool -i %d -ip -g" % device_id).readlines()
            if ret:
                device_ips[str(device_id)] = ret[0].split(":")[-1].replace('\n', '')
    except Exception as e:
        print("Failed to call hccn_tool, try to read /etc/hccn.conf instead, error: {}".format(str(e)))
        try:
            with open('/etc/hccn.conf', 'r') as fin:
                for hccn_item in fin.readlines():
                    if hccn_item.strip().startswith('address_') and "=" in hccn_item:
                        device_id, device_ip = hccn_item.split('=')
                        device_id = device_id.split('_')[-1]
                        device_ips[device_id] = device_ip.strip()
        except OSError:
            print("Failed to read /etc/hccn.conf")
            raise SystemError("Failed to find information for hccl")

    hccn_table = {'version': '1.0', 'server_count': '1', 'server_list': []}
    device_list = []
    rank_id = 0
    for instance_id in device_num_list:
        device_id = visible_devices[instance_id]
        device_ip = device_ips.get(device_id, "")
        device = {'device_id': device_id, 'device_ip': device_ip, 'rank_id': str(rank_id)}
        rank_id += 1
        device_list.append(device)
    hccn_table['server_list'].append({'server_id': server_id, 'device': device_list, 'host_nic_ip': 'reserve'})
    hccn_table['status'] = 'completed'

    # save hccn_table to file
    table_path = os.getcwd()
    table_fn = os.path.join(table_path, 'hccl.json')
    with open(table_fn, 'w') as table_fp:
        json.dump(hccn_table, table_fp, indent=4)
    sys.stdout.flush()
    print("Completed: hccl file was save in :", table_fn)


def main():
    print("start", __file__)
    device_num, visible_device, server_ip = 0, 0, ''
    if len(sys.argv) == 3:
        device_num, visible_device = sys.argv[1:]
    if len(sys.argv) == 4:
        device_num, visible_device, server_ip = sys.argv[1:]

    # visible_devices
    if not check_digit(device_num, visible_device):
        raise ValueError("input parameter  ddevice_num or visible_device number not is digit")
    generate_hccl(device_num, visible_device, server_ip)


if __name__ == "__main__":
    main()
