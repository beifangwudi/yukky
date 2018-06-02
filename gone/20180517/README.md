# 自建软路由
### 前面
有很多基于Linux内核的软路由系统,但是都不同程度的做了阉割.我打算用Ubuntu 16.04搭建一个无线路由,可以同时通过无线和有线两种方式上网.其中无线网卡需要被hostapd支持.网络接入方式,eth0为以太网卡,连接外网,eth1为以太网卡,连接内网,wlan0为无线网卡,也是连接内网.
### 安装
dnsmasq用来提供dhcp和dns服务,hostapd建立WiFi,bridge-utils桥接eth1和wlan0.
```bash
apt install -y dnsmasq hostapd bridge-utils
```
### bridge
配置文件`/etc/network/interfaces`.
```
auto lo
iface lo inet loopback
# 和外网连接的eth0
auto eth0
iface eth0 inet dhcp
# eth0连接外网的方式为拨号
auto dsl-provider
iface dsl-provider inet ppp
pre-up /bin/ip link set eth0 up
provider dsl-provider
# 给eth1设置ip
auto eth1
iface eth1 inet manual
# 把eth1加到br0这个网桥里面
auto br0
iface br0 inet static
bridge_ports eth1
address 192.168.111.1
netmask 255.255.255.0
```
开启转发
```bash
iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p
```
### dnsmasq
配置文件`/etc/dnsmasq.conf`.
```
interface=br0
dhcp-range=br0,192.168.111.10,192.168.111.250,48h
no-resolv
server=114.114.114.114
```
### hostapd
为hostapd指定配置文件,修改`/etc/default/hostapd`
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```
然后新建`/etc/hostapd/hostapd.conf`
```
interface=wlan0
bridge=br0
driver=nl80211
ssid=你的无线网络名称
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=无线密码
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ieee80211n=1
wmm_enabled=1
hw_mode=g
channel=7
```