# 小米手机的一些设置
### 解锁
根据官方[刷机教程](http://www.miui.com/shuaji-393.html),部分机型线刷之前需要解锁Bootloader,在[这里](http://www.miui.com/unlock/)解锁
### 开启自带阉割ROOT
线刷MIUI开发版,设置 -> 授权管理 -> ROOT权限管理 -> 开启ROOT
### adb解锁/system
1. 安卓官网下载[adb](https://developer.android.com/studio/releases/platform-tools.html),解压,进入
2. 手机进入开发者模式,打开USB相关选项
3. 按顺序执行命令
    ```powershell
    # 查看设备
    .\adb.exe devices -l
    # 以root身份运行adbd
    .\adb.exe root
    # 关闭dm-verity验证
    .\adb.exe disable-verity
    # 重启
    .\adb.exe reboot
    # 重新挂载
    .\adb.exe root
    .\adb.exe remount
    ```
4. 验证,`.\adb.exe shell "mount | grep /system"`,如果出现rw字样说明成功,ro则失败,也可以尝试直接卸载系统自带应用
5. 手机重启后需要重新运行`.\adb.exe root; .\adb.exe remount`或`.\adb.exe root; .\adb.exe shell "mount -o rw,remount /system"`
### Xposed
对系统调用挂钩子注入,需要root.[xda下载](https://forum.xda-developers.com/showthread.php?t=3034811),需要适配,视手机型号而定,可能需要借助第三方recovery安装,比如:[TWRP](https://twrp.me/Devices/Xiaomi/).对于一些无法root的设备,可以参考[VirtualXposed](http://vxposed.com/)
### Termux
命令行终端模拟器,自带一些Linux命令,可以应急,[Google Play](https://play.google.com/store/apps/details?id=com.termux)下载,或[APK Downloader](https://apps.evozi.com/apk-downloader/?id=com.termux)和[Apkpure](https://apkpure.com/cn/termux/com.termux)
1. 自带包管理,可以安装python,nodejs,gcc,vim等
    ```bash
    apt install python nodejs
    ```
2. apt修改为国内源
    ```bash
    EDITOR=vi apt edit-sources
    ```
    地址修改为`http://mirrors.tuna.tsinghua.edu.cn/termux`
3. 开启ssh服务
    1. 安装`apt install openssh`
    2. 制作`~/.ssh/authorized_keys`,实际目录为`/data/data/com.termux/files/home/.ssh/authorized_keys`,只支持密钥登录
    3. `whoami`查看用户名,`ip a`查看ip
    4. ssh端口默认为8022,配置文件为`/data/data/com.termux/files/usr/etc/ssh/sshd_config`
    5. 运行`sshd`启动,可以`su -`切换到root
4. 同时按音量+和q键可以显示控制键或者下载[Hacker's Keyboard](https://play.google.com/store/apps/details?id=org.pocketworkstation.pckeyboard)
### 本地adb
1. 使adbd监听tcp端口
    ```bash
    su
    setprop service.adb.tcp.port 5555
    stop adbd
    start adbd
    ```
2. 编译adb和fastboot或[这里](https://github.com/Magisk-Modules-Repo/adb-Installer/tree/master/bin)下载arm版本到手机上
3. 连接,可能有bug,多试几次
    ```bash
    ./adb connect 192.168.1.111:5555
    ```
4. 停止监听tcp端口
    ```bash
    setprop service.adb.tcp.port -1
    stop adbd
    start adbd
    ```
### Linux Deploy
1. Termux可以应急,需求再复杂一些,需要完整Linux系统时,可以使用[Linux Deploy](https://play.google.com/store/apps/details?id=ru.meefik.linuxdeploy),原理为chroot
2. 默认只能使用Debian,官方提供的Kali,CentOS等需要购买,可以直接通过url下载,比如`kalilinux_arm`的下载链接为`http://hub.meefik.ru/rootfs/kalilinux_arm.tgz`,也可以使用国内源,比如`http://mirrors.ustc.edu.cn/kali/`
3. 点击屏幕右下角进行配置
    * 发行版: `Kali Linux`
    * 源地址: `http://mirrors.ustc.edu.cn/kali/`
    * 安装路径: `/storage/emulated/0/linux/kali.img`
    * 用户名/用户密码: 自定义
    * SSH: Enable
4. 右上角 -> 安装
5. ssh连接上去,`sudo -i`切换到root,做你想做的
### Limbo PC Emulator
[官网](https://limboemulator.weebly.com/),基于QEMU,在Android上运行,可以分别在ARM和x86架构上运行基于x86,ARM,PowerPC和Sparc架构的操作系统,可定制化程度高,然而性能损失严重,特殊情况下可能有用.
### 本地自动化
* 一些自动化可以借助Xposed,比如:抢火车票,QQ抢红包,微信自动回复等
* [Tasker](https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm),如果满足某条件,则执行某某操作,可能需要会一些编程
* [按键精灵](http://www.mobileanjian.com/),[触动精灵](http://www.touchsprite.com/),对游戏支持不错,不支持读取布局控件,读个文字还得上OCR,而且还不准
* [Auto.js](https://github.com/hyb1996/Auto.js),基于JavaScript,基于控件,是各种精灵的超集,可以调用Java的API,开源
* UiAutomator,Android之真·本地自动化,系统自带,官方支持,美中不足开发必须要在PC上进行
* [Macaca](https://macacajs.github.io/)等一系列必须使用开发PC才能进行的自动化测试手段,其中部分应用如果将adb,Python或Node.js等移植到Android本机上,也可以实现脱离PC运行