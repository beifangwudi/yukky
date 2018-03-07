# 验证BBR加速
### 前面
Google写了个TCP拥塞算法-BBR,听说不错,试验一下.准备了两台服务器,一台阿里云香港,ip为a.b.c.d,另一台腾讯云上海,ip为w.x.y.z.系统为Ubuntu 16.04 x86_64,除了默认内核配置,加了以下几行
```
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
```
### 搭建gre隧道
* 香港
    ```bash
    ip tunnel add gre-HK mode gre remote w.x.y.z
    ip link set gre-HK up
    # 给网卡设置ip为10.0.0.1,并设置路由
    ip addr add 10.0.0.1 peer 10.0.0.2 dev gre-HK
    ```
* 上海
    ```
    ip tunnel add gre-CN mode gre remote a.b.c.d
    ip link set gre-CN up
    ip addr add 10.0.0.2 peer 10.0.0.1 dev gre-CN
    ```
在香港机器执行`ping -c4 10.0.0.2`,在上海机器上执行`ping -c4 10.0.0.1`,都通说明隧道搭建成功.  
这里有一点要注意,因为在腾讯云和阿里云上,服务器本身是没有公网ip的,之所以能在公网被访问,是因为云主机服务商映射了一个公网ip到内网,所以`ip tunnel add gre-CN mode gre remote a.b.c.d local w.x.y.z`是行不通的.
### 第一次测速
在启用BBR之前,简单测个下载速度
```bash
# 生成一个128M的文件
dd if=/dev/zero of=test.dd bs=1M count=128
# 运行http服务器
python -m SimpleHTTPServer 8848
# 或python3 -m http.server 8848
```
实测20KB/s
### 开启BBR
```bash
# 安装hwe内核,4.9及以上的内核才支持BBR
apt install linux-generic-hwe-16.04-edge
# 开启它
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
reboot
```
重启之后用`sysctl net.ipv4.tcp_congestion_control`检查,出现bbr则说明成功.
### 第二次测速
实测200KB/s,效果还不错,可以考虑用iperf和mtr进行进一步测试.