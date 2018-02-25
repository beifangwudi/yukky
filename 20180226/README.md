# 小米路由器的一些设置
### 启用ssh
先刷[开发版](http://www1.miwifi.com/miwifi_download.html),再刷[ssh](https://d.miwifi.com/rom/ssh),运行`ssh root@192.168.31.1`登录.路由器用得是DropBear,配置文件是/etc/config/dropbear,参考 http://wiki.openwrt.org/doc/uci/dropbear .
### ssh免密登录
建立`/etc/dropbear/authorized_keys`,将ssh公钥复制进去.
### 防火墙
防火墙文件为`/etc/config/firewall`,不建议随意改动,可以新建`/etc/firewall.user`加入自定义内容,格式为shell脚本.
### 开机启动
需要开机启动的脚本,可以写在`/etc/rc.local`中.