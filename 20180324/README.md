# Python做简单监控
### 目的
用于临时监控一些机器,周期收集CPU,内存,磁盘,网络,进程等信息,要求跨平台.
### 代码
```python
#!/usr/bin/python
# -*- coding:utf-8 -*-

import psutil, logging, os, time
os.chdir(os.path.split(os.path.realpath(__file__))[0])
logging.basicConfig(
    level=logging.NOTSET,
    format='%(asctime)s[runtime:%(relativeCreated)d]~'
    '%(filename)s[line:%(lineno)d]~%(levelname)s~%(message)s',
    filename='r.log')
logging.getLogger().addHandler(logging.StreamHandler())

logging.info('start')
disk_status = {}
net_status = {}
while True:
    status = {}
    # CPU使用率,%,按核算,[10.6, 1.9, 7.4, 6.9]
    status['cpu'] = psutil.cpu_percent(percpu=True)
    # 内存使用率,%,30.7
    status['memery'] = psutil.virtual_memory().percent

    # 硬盘读写,{'PhysicalDrive0': 'read:0.00MB/write:0.00MB', 'PhysicalDrive1': 'read:0.00MB/write:0.02MB'}
    status['disk'] = {}
    for k, v in psutil.disk_io_counters(perdisk=True).items():
        disk_status.setdefault(k + ' old_read_bytes', 0)
        disk_status.setdefault(k + ' old_write_bytes', 0)
        status['disk'][k]=f"read:{(v.read_bytes - disk_status[k + ' old_read_bytes'])/1024/1024:.2f}MB" + \
            f"/write:{(v.write_bytes - disk_status[k + ' old_write_bytes'])/1024/1024:.2f}MB"
        disk_status[k + ' old_read_bytes'] = v.read_bytes
        disk_status[k + ' old_write_bytes'] = v.write_bytes

    # 网卡流量,{'以太网': 'sent:0.00KB/recv:0.00KB', '本地连接* 1': 'sent:0.00KB/recv:0.00KB', '以太网 2': 'sent:0.00KB/recv:0.00KB', 'WLAN': 'sent:0.20KB/recv:22.55KB', 'Loopback Pseudo-Interface 1': 'sent:0.00KB/recv:0.00KB'}
    status['net'] = {}
    for k, v in psutil.net_io_counters(pernic=True).items():
        net_status.setdefault(k + ' old_bytes_sent', 0)
        net_status.setdefault(k + ' old_bytes_recv', 0)
        status['net'][k] = f"sent:{(v.bytes_sent - net_status[k + ' old_bytes_sent'])/1024:.2f}KB" + \
            f"/recv:{(v.bytes_recv - net_status[k + ' old_bytes_recv'])/1024:.2f}KB"
        net_status[k + ' old_bytes_sent'] = v.bytes_sent
        net_status[k + ' old_bytes_recv'] = v.bytes_recv

    # 收集进程CPU和内存的占用(%)
    process_info = []
    for p in psutil.process_iter(attrs=[
            'pid', 'name', 'cpu_percent', 'memory_percent', 'connections'
    ]):
        p.info['connections'] = len(p.info['connections'])
        p.info['memory_percent'] = '%.2f' % p.info['memory_percent']
        process_info.append(p.info)
    # 取CPU使用率最高前10,和内存使用率最高前10
    status['process'] = {
        'cpu_top10':
        sorted(process_info, key=lambda x: x['cpu_percent'],
               reverse=True)[:10],
        'memery_top10':
        sorted(process_info, key=lambda x: x['memory_percent'],
               reverse=True)[:10]
    }

    logging.info(status)
    time.sleep(60)
```