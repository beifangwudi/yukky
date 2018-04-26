# 搭建NTP服务
以Ubuntu 14.04为例,安装
```bash
apt-get install -y ntp
```
修改配置文件`/etc/ntp.conf`的server部分,添加ntp上游服务器
```
server ntp1.aliyun.com
server ntp2.aliyun.com
server 202.120.2.101
```
重启ntp服务
```bash
service ntp restart
```