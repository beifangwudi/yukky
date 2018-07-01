# 唯一的进程
```bash
#!/bin/bash
lock='/tmp/only_'"$(which "$1" | md5sum | cut -d' ' -f1)"
flock -xn "$lock" -c "$*" && rm -f "$lock"
```
简单装饰了下`flock`,用法如下
```bash
./only.sh ping 163.com
```
使用`only.sh`运行的同一个程序在系统中只会存在一个,尝试运行多个会失败