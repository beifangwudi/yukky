# 加速国外服务器
在国外有一台web服务器`www.avbt.top`,因为一些原因,从国内访问速度不佳,需要在不迁移服务器的情况下改良访问速度.
* 准备  
两台服务器,一台名为CN,位于大陆,ip为`a.b.c.d`,便于用户访问,另一台位于香港,名为HK,ip为`w.x.y.z`,便于代理主站.这里选用`CentOS 7 x64`,防火墙入站,CN开启80和443端口,HK可以全关.
* 开启转发
    ```bash
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv4.conf.all.rp_filter=0
    sysctl -w net.ipv4.conf.default.rp_filter=0
    iptables -P FORWARD ACCEPT
    iptables -A INPUT -p gre -j ACCEPT
    ```
* CN建立隧道
    ```bash
    ip tunnel add gre-CN mode gre remote w.x.y.z ttl 255
    ip link set gre-CN up mtu 1400
    ip addr add 10.0.0.1 peer 10.0.0.2 dev gre-CN
    ```
    方便起见,这里使用GRE隧道,CN的隧道ip为`10.0.0.1`
* HK建立隧道
    ```bash
    ip tunnel add gre-HK mode gre remote a.b.c.d ttl 255
    ip link set gre-HK up mtu 1400
    ip addr add 10.0.0.2 peer 10.0.0.1 dev gre-HK
    ```
    HK的隧道ip为`10.0.0.2`
* CN反向代理
    ```
    server {
        listen 80;
        listen 443 ssl;
        server_name  www.avbt.top;

        location / {
            proxy_pass https://www.avbt.top;
        }
    }
    ```
* CN转发流量到HK
    ```bash
    # 500为nginx用户的id
    iptables -A OUTPUT -m owner --uid-owner 500 -j MARK --set-mark 4
    ip rule add fwmark 4 table 4
    ip route add default via 10.0.0.2 dev gre-CN table 4
    ```
    DNS可以通过CDN配置成主站域名`www.avbt.top`,也可以使用中国分区的域名,比如`cn.avbt.top`.
* HK做转发
    ```bash
    iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
    ```