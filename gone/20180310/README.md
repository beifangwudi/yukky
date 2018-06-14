# ssh内网穿透
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
    ssh -CNR 127.0.0.1:13580:127.0.0.1:3306 ssh@a.b.c.d -i key
    ```
    将内网机器的3306端口转发到服务器的13580端口
3. 解释  
有4台机器1.1.1.1,2.2.2.2,3.3.3.3和4.4.4.4,在2.2.2.2上执行这条命令`ssh -R 4.4.4.4:44:1.1.1.1:11 user@3.3.3.3`的意思是2.2.2.2和3.3.3.3之间会打通一条ssh隧道,如果有请求连接4.4.4.4的44端口,会被转发到1.1.1.1的11端口  
sshd默认只在localhost转发,如过需要转发到其它网卡,要将GatewayPorts设为yes
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
