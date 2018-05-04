# 无证书进入NSA 3600防火墙
只有管理员的用户名和密码,且在防火墙设置了验证个人证书的情况下,不用证书登录系统的方法
1. 用nmap扫描系统,找出ssh和web端口
2. ssh登录系统
    ```bash
    ssh -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=ssh-rsa -p 7890 admin@10.0.0.252
    ```
3. 禁用证书,[参考](https://www.sonicwall.com/en-us/support/knowledge-base/170505920320074)
    ```
    admin@XXXXXX> config
    config(XXXXXX)# administration
    (config-administration)# no web-management client-certificate-check
    (config-administration)# commit
    % Applying changes...
    % Changes made.
    (config-administration)# exit
    ```
4. 普通浏览器无法登录,因为需要支持相关协议.可以用比如[K-Meleon](https://sourceforge.net/projects/kmeleon/),访问web端口.