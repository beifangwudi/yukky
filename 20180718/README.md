# 隐藏Linux进程树
要从`ps`,`top`等命令中彻底隐藏一个进程,就好像该进程不存在一样.[参考](https://unix.stackexchange.com/questions/280860/how-to-hide-a-specific-process/280864#280864)
```bash
mount -o bind $(mktemp -d) /proc/1807
```
这样可以隐藏进程本身,但是无法隐藏其子进程
```bash
#!/bin/bash
t=$(mktemp -d)
pstree -p $1 | grep -oP '(?<=\()\d+(?=\))' | xargs -i mount -o bind $t /proc/{}
```
用`mount`可以查看