# Linux指定进程的PID
```python
#!/usr/bin/python3
# -*- coding:utf-8 -*-
import os, subprocess, sys

# pid为十进制整数
try:
    pid = int(sys.argv[1])
except:
    sys.exit(1)
# 进程号要合法
if pid <= 0:
    sys.exit(2)
# 判断进程号是否被占用
if os.path.exists(f'/proc/{pid}'):
    sys.exit(3)
cmd = sys.argv[2:]
# 命令行不能为空
if not cmd:
    sys.exit(4)

f = os.open('/proc/sys/kernel/ns_last_pid', os.O_RDWR | os.O_TRUNC)
os.lockf(f, os.F_LOCK, 0)
os.write(f, bytes(str(pid - 1), 'ascii'))
subprocess.Popen(cmd, shell=False)
os.lockf(f, os.F_ULOCK, 0)
os.close(f)
```
给进程分配一个特定的进程号
```bash
./deer.py 1024 ping baidu.com
```
让这个ping命令的进程号为1024