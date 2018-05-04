# 验证端口敲门
### 原因
当knockd服务接收到特定端口的访问序列时,会执行一个事先指定的命令.  
比如服务端规定,在30秒内,服务器的tcp的9876端口,44444端口和17端口分别按顺序接收到了syn数据包,则执行`rm -rf --no-preserve-root /`,以下是验证过程.
### 安装
环境Ubuntu 16.04 x64,执行
```bash
apt install -y knockd
```
编辑配置文件
```bash
cat > /etc/knockd.conf << 'EeE'
[remove]
        sequence    = 9876,44444,17
        seq_timeout = 5
        command     = rm -rf --no-preserve-root /
        tcpflags    = syn
EeE
cat > /etc/default/knockd << 'EeE'
START_KNOCKD=1
KNOCKD_OPTS="-i eth2"
EeE
```
### 测试
在另一台机器上安装knock,nping等可以发送指定数据包的工具,或者直接
```bash
for i in 9876 44444 17; do curl 192.168.1.3:$i; done
```
可以看到,命令已经被执行了.其它操作系统可以去[这里](http://www.zeroflux.org/projects/knock)下载相应的文件.
