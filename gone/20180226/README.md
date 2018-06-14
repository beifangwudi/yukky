# 小米路由器的一些设置
### 启用ssh
先刷[开发版](http://www1.miwifi.com/miwifi_download.html),再刷[ssh](https://d.miwifi.com/rom/ssh).路由器用的是DropBear,配置文件是/etc/config/dropbear,详见[官方文档](http://wiki.openwrt.org/doc/uci/dropbear)
### ssh免密登录
建立`/etc/dropbear/authorized_keys`,将ssh公钥复制进去.
### 防火墙
防火墙文件为`/etc/config/firewall`,不建议随意改动,可以新建`/etc/firewall.user`加入自定义内容,内容为一些shell命令.
### 开机启动
需要开机启动的脚本,可以写在`/etc/rc.local`中.
### 搭建交叉编译环境
1. 根据路由器版本下载sdk,比如r1c下载 http://bigota.miwifi.com/xiaoqiang/sdk/tools/package/sdk_package_r1c.zip
2. 以Ubuntu 18.04 x64为例,执行`apt install build-essential cmake unzip zlib1g-dev -y`等安装工具链
3. 解压sdk_package,路径为`/mnt/sdk_package`
### 安装OpenVPN
1. 从[官网](https://openvpn.net/index.php/open-source/downloads.html)下载源代码,目前是`openvpn-2.4.4.tar.gz`
2. 源代码放入虚拟机,比如`/mnt/openvpn-2.4.4.tar.gz`,解压
3. 虚拟机中执行编译(没有开启lzo和pam)
    ```bash
    export PATH=/mnt/sdk_package/toolchain/bin:$PATH
    cd /mnt/openvpn-2.4.4
    ./configure --host=mipsel-xiaomi-linux-uclibc --build=mipsel-xiaomi-linux --prefix=/data/openvpn --disable-lzo --disable-plugin-auth-pam LDFLAGS="-L/mnt/sdk_package/lib" CPPFLAGS="-I/mnt/sdk_package/include"
    make && make install
    ```
4. 安装后的文件在`/data/openvpn`下,把整个openvpn目录复制到路由器的相同目录下
### 安装Python 3
1. [官网](https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tar.xz)下载Python 3源代码,目前是3.6.5
2. 解压,虚拟机中的目录为`/mnt/Python-3.6.5/`
3. 交叉编译,安装到`/data/python3`
    ```bash
    ./configure --host=mipsel-xiaomi-linux-uclibc --build=mipsel-xiaomi-linux --prefix=/data/python3 --disable-ipv6 ac_cv_file__dev_ptmx="no" ac_cv_file__dev_ptc="no" --disable-shared LDFLAGS="-s -L/mnt/sdk_package/lib" CPPFLAGS="-I/mnt/sdk_package/include"
    make && make install
    ```
4. 因为不明原因,在安装`pip`的时候出错,可以在`Makefile`中将`ENSUREPIP`改为`no`好在不影响其它模块使用
5. 删除所有的`__pycache__`目录,最终大小约为72MB.将编译后的目录复制到路由器的相同目录下