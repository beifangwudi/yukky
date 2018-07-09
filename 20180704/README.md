# 简单的socks5代理
```bash
export ALL_PROXY=socks5://127.0.0.1:1080
ssh -NTD 1080 root@195.112.172.152
```
可以通过`127.0.0.1:1080`端口访问代理,可以用`privoxy`将socks5代理转成http代理
```bash
yum install privoxy -y
echo 'forward-socks5t / 127.0.0.1:1080 .' >> /etc/privoxy/config
systemctl start privoxy
```
默认是本地8118端口,或使用[goproxy](https://github.com/snail007/goproxy)
```bash
curl -sL https://github.com/snail007/goproxy/releases/download/v5.2/proxy-linux-amd64.tar.gz | tar zxv
./proxy socks -t tcp -p 0.0.0.0:7474 -a user:pass --forever --log /dev/null --daemon
```
socks5代理,监听7474端口,可以使用用户名密码验证身份