# 自定义Ubuntu镜像
1. 准备Ubuntu系统,以`Ubuntu 18.04 x64`为例
2. 准备`base system`
    ```bash
    # 建立镜像文件存放目录
    mkdir /mnt/xxxx
    # 安装debootstrap
    apt install -y debootstrap
    # 安装基础包,--include 指定额外安装的软件
    debootstrap --arch=amd64 --variant=minbase bionic /mnt/xxxx "http://mirrors.ustc.edu.cn/ubuntu/"
    ```
3. chroot
    ```bash
    mount --bind /dev /mnt/xxxx/dev
    mount --bind /dev/pts /mnt/xxxx/dev/pts
    mount --bind /proc /mnt/xxxx/proc
    mount --bind /sys /mnt/xxxx/sys
    chroot /mnt/xxxx
    ```
4. 用于docker的自定义安装(可选)  
比如配置源,安装mysql,nginx等.完成后,退出chroot
    ```bash
    exit
    umount /mnt/xxxx/{sys,proc,dev/pts,dev}
    ```
    打包镜像
    ```bash
    tar -cC /mnt/xxxx . | docker import - saki
    ```
5. 用于host的自定义安装(可选)
    1. 在准备`base system`之前,需要挂载硬盘分区到/mnt/xxxx
    2. chroot之后,至少要安装grub,内核,systemd,然后设置登录密码
        ```bash
        apt install -y linux-image-generic init
        chpasswd <<< 'root:SatenRuiko'
        ```
    3. 其它操作,比如设置主机名,网络,时区和语言等,可以参考[archlinux](https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))和[gentoo](https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation/zh-cn)的文档
    4. 安装软件,重启进入新的系统