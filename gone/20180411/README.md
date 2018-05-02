# 用OpenVPN组网
### 背景
有几台内网设备需要互相访问,现在有一台公网服务器做中转,要求不能影响各设备的默认网关.
### 服务端安装OpenVPN
0. 服务端使用CentOS 7 x64.
1. 安装
    ```bash
    yum install epel-release iptables-services -y
    yum update
    yum install openvpn easy-rsa -y
    ```
2. 配置证书
    ```bash
    cp -r /usr/share/easy-rsa/ /etc/openvpn/
    vim /etc/openvpn/easy-rsa/2.0/vars
    ```
    编辑vars文件,设置好这些参数,分别是:国家,省份,城市,组织,电子邮件,单位
    ```
    export KEY_COUNTRY="CN"
    export KEY_PROVINCE="JS"
    export KEY_CITY="NANJING"
    export KEY_ORG="beifangwudi"
    export KEY_EMAIL="beifangwudi@outlook.com"
    export KEY_OU="beifangwudi"
    ```
    最好别瞎填
3. 生成证书
    ```bash
    cd /etc/openvpn/easy-rsa/2.0
    source ./vars
    ./clean-all
    ./build-ca
    ./build-key-server server
    ./build-dh
    ./build-key client
    cp -r keys/ /etc/openvpn/
    ```
    大致过程就是需要按y的就按y,其它一路回车
4. 配置文件
    ```
    port 12345
    proto tcp
    dev tun

    ca /etc/openvpn/keys/ca.crt
    cert /etc/openvpn/keys/server.crt
    key /etc/openvpn/keys/server.key
    dh /etc/openvpn/keys/dh2048.pem

    server 172.16.61.0 255.255.255.0
    push "route 172.16.61.0 255.255.255.0"
    push "dhcp-option DNS 223.5.5.5"
    push "dhcp-option DNS 114.114.114.114"

    client-to-client
    topology subnet
    duplicate-cn
    keepalive 10 120
    persist-key
    persist-tun
    verb 3
    log-append  /var/run/log/openvpn.log
    status /var/run/log/openvpn-status.log
    ```
### 客户端
```
client
proto tcp
dev tun
remote 服务器ip 12345
resolv-retry infinite
nobind
persist-key
persist-tun

<ca>
-----BEGIN CERTIFICATE-----
你的/etc/openvpn/easy-rsa/2.0/keys/ca.crt的BEGIN和END之间的内容
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
你的/etc/openvpn/easy-rsa/2.0/keys/client.crt的BEGIN和END之间的内容
-----END CERTIFICATE-----
</cert>
<key>
-----BEGIN PRIVATE KEY-----
你的/etc/openvpn/easy-rsa/2.0/keys/client.key的BEGIN和END之间的内容
-----END PRIVATE KEY-----
</key>
```