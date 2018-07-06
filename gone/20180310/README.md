# SSH内网穿透
### 服务端
1. 需要一台有公网IP的服务器,假设IP为a.b.c.d
2. 创建新用户,名为ssh,无登录shell
    ```bash
    useradd ssh -s /bin/false
    ```
3. 切换到ssh用户,生成密钥和authorized_keys文件
    ```bash
    sudo -Hu ssh /bin/bash
    ssh-keygen
    mv -f /home/ssh/.ssh/{id_rsa.pub,authorized_keys}
    ```
### 内网机器
1. 取得ssh的私钥,存到文件key
2. 发起连接
    ```bash
    ssh ssh@a.b.c.d -i key -CNR 0.0.0.0:13580:192.168.1.1:3306
    ```
    将访问`a.b.c.d`的`13580`端口的流量通过隧道转发到该内网机器能访问到的`192.168.1.1`的`3306`端口,sshd默认只在localhost转发,如过需要转发到本机的其它网卡,要将`GatewayPorts`设为`yes`
3. 解释  
流量方向为
    ```
    内网机器 ----SSH----> 公网机器a.b.c.d的SSH端口
    访问 ----> 公网机器a.b.c.d的13580端口 ----> 内网机器 ----> 内网机器能访问到的192.168.1.1的3306端口
    ```
    还有一个`ssh -L`,正好相反,比如`ssh ssh@a.b.c.d -L 0.0.0.0:13580:8.8.8.8:53`流量为
    ```
    内网机器 ----SSH----> 公网机器a.b.c.d的SSH端口
    访问 ----> 内网机器的13580端口 ----> 公网机器 ----> 公网机器能访问到的8.8.8.8的53端口
    ```
### sshd的一些配置
* 长时间保持连接
    ```
    TCPKeepAlive yes
    ClientAliveInterval 9
    ClientAliveCountMax 9
    ```
* 安全方面
    ```
    AllowAgentForwarding no
    X11Forwarding no
    ```
    X11Forwarding和AllowAgentForwarding是全局设置,如果只对ssh用户生效,可以在authorized_keys的最前面加上`no-x11-forwarding,no-agent-forwarding`,也可以在.ssh/config中做相应设置