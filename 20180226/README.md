# 小米路由器的一些设置
### 启用ssh
先刷[开发版](http://www1.miwifi.com/miwifi_download.html),再刷[ssh](https://d.miwifi.com/rom/ssh),运行`ssh root@192.168.31.1`登录.路由器用得是DropBear,配置文件是/etc/config/dropbear,参考[官方文档](http://wiki.openwrt.org/doc/uci/dropbear.
### ssh免密登录
建立`/etc/dropbear/authorized_keys`,将ssh公钥复制进去.
### 防火墙
防火墙文件为`/etc/config/firewall`,不建议随意改动,可以新建`/etc/firewall.user`加入自定义内容,格式为shell脚本.
### 开机启动
需要开机启动的脚本,可以写在`/etc/rc.local`中.
### 搭建交叉编译环境
1. 根据路由器版本下载sdk,比如r1c下载 http://bigota.miwifi.com/xiaoqiang/sdk/tools/package/sdk_package_r1c.zip
2. 搭建Linux环境,以64位Ubuntu 16.04虚拟机为例,执行`apt install build-essential cmake unzip -y`等安装工具链
3. 解压sdk_package,放在虚拟机的自定义目录下,比如`/mnt/sdk_package`
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
1. [官网](https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz)下载Python 3源代码,目前是3.6.4
2. 解压,虚拟机中的目录为`/mnt/Python-3.6.4/`
3. 给虚拟机临时安装Python 3.6
```bash
mkdir /mnt/pc_python
cd /mnt/Python-3.6.4
./configure --prefix=/mnt/pc_python
make && make install
export PATH=/mnt/sdk_package/toolchain/bin:/mnt/pc_python/bin:$PATH
```
4. 用虚拟机中的Python 3.6和sdk交叉编译路由器中的Python 3.6,因为编译完后体积较大(127MB),可以考虑放在外接硬盘`/extdisks/sda1/python3`或压缩体积后放在`/data/python3`
```bash
make distclean
./configure --host=mipsel-xiaomi-linux-uclibc --build=mipsel-xiaomi-linux --prefix=/extdisks/sda1/python3 --enable-ipv6 ac_cv_file__dev_ptmx="yes" ac_cv_file__dev_ptc="yes" --enable-shared LDFLAGS="-L/mnt/sdk_package/lib" CPPFLAGS="-I/mnt/sdk_package/include"
make && make install
```
5. 将编译后的目录复制到路由器的相同目录下