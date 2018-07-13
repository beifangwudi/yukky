# 基于Ubuntu的Kiosk
当操作系统启动时,自动进入某个全屏的图形界面的应用程序,并且无法退出,就像银行的ATM机和路边的自动贩卖机.以`Ubuntu 18.04`为例,启动`Chromium`浏览器.
1. 最小化安装服务器操作系统
2. 安装必须的软件
```bash
apt install -y chromium-browser xorg
```
3. 新建一个普通用户
```bash
useradd kusuo -m
```
4. 让该用户自动登录
```bash
# 修改/lib/systemd/system/getty@.service,'[Service]'下的'ExecStart'
sed -i '/^ExecStart/s@^.*$@ExecStart=-/sbin/agetty --autologin kusuo --noclear %I $TERM@' /lib/systemd/system/getty@.service
```
5. 配置Chromium
```bash
echo 'exec bash -c "while :; do /usr/bin/startx /usr/bin/chromium-browser --kiosk https://www.xvideos.com; done"' >> /home/kusuo/.profile
```
6. 重启系统,会直接启动`Chromium`浏览器,进入网页.需要注意的是,`kusuo`这个用户无法用常规的方式登录,因为登录时会启动`startx`.在实际应用中,还需要屏蔽按键以及安装相应字体.