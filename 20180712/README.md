# 记录命令行
### script
```bash
if [ "x$xCx" = x ]; then
    export xCx=XcX
    m=$(date +%Y.%m.%d-%H:%M:%S)
    exec script -t -f -q $m.his 2> $m.tme
fi
```
将这几行命令添加到`~/.profile`末尾,可以录制所有用户的命令行操作,用`scriptreplay $m.tme $m.his`回放.
### history
```bash
PROMPT_COMMAND='history 1 | logger -t Luffy'
```
`CentOS 7`会将bash的历史纪录到`/var/log/messages`中,也可以重新编译4.1及以上版本的bash获得类似功能.
### snoopy
用于审计,记录所有execve()系统调用,不限于命令行
```bash
wget -O snoopy-install.sh https://github.com/a2o/snoopy/raw/install/doc/install/bin/snoopy-install.sh
bash ./snoopy-install.sh stable
snoopy-enable
```
`CentOS 7`上,日志记录在`/var/log/secure`
### auditctl
专业审计,比`snoopy`更加强大,`CentOS 7`默认安装
```bash
auditctl -a exit,always -S execve
```
记录execve系统调用