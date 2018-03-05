# 试验用Ubuntu 16.04初始化
### 登录
```bash
# 先切换到root
sudo -i
# 修改密码,不支持`passwd --stdin`
chpasswd <<< 'root:iampassword'
# sshd允许root登录
sed -i 's/^\(PermitRootLogin\)/#\1/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
# root添加公钥
mkdir ~/.ssh
echo 'ssh-rsa AAAAB......YYYYZ' > ~/.ssh/authorized_keys
# 退出root,退出普通用户,以root重新登录,删除普通用户
userdel -r xxxxx
```
### 修改主机名
```bash
echo macOS > /etc/hostname
```
### 换源  
```bash
# 换阿里云的源
mv /etc/apt/sources.list{,.ori}
echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial'{,-updates,-security,-backports}' main restricted universe multiverse' | xargs -n7 > /etc/apt/sources.list
# 卸载一些不需要的
apt purge -y ufw snapd
# 更新
apt clean && apt update && apt dist-upgrade -y && apt autoremove -y
# 关闭自动更新
sed -i 's/"1"/"0"/g' /etc/apt/apt.conf.d/10periodic
```
### 防火墙
```bash
# 制作一个iptables规则文件
echo '*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
COMMIT' > /etc/iptables.rules
# 让这个配置开机加载
echo 'iptables-restore < /etc/iptables.rules' > /etc/network/if-pre-up.d/iptables
# 开启转发
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
```
### 开机显示IP  
```bash
# 修改grub等待时间
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
update-grub
# 在控制台登录界面显示ip
sed -i '1aIP:\\4' /etc/issue
# \4是显示对外ipv4的地址,\4{ens33}是指定显示ens33网卡的ipv4地址
```
### 命令历史时间  
```bash
echo "export HISTTIMEFORMAT='| %F %T | '" >> ~/.bashrc
```
### 开启samba匿名共享
```bash
apt install samba -y
mv /etc/samba/smb.conf{,.bak}
echo '[global]
workgroup = WORKGROUP
security = user
map to guest = bad user
[share]
comment = share
path = /mnt/share
browseable = yes
writeable = yes
available = yes
public = yes
guest ok = yes' > /etc/samba/smb.conf
mkdir /mnt/share
chown -R nobody:nogroup /mnt/share
```
### 安装最小桌面
```bash
apt install -y --no-install-recommends ubuntu-desktop
echo '[SeatDefaults]
autologin-user=root
autologin-user-timeout=0
' > /etc/lightdm/lightdm.conf.d/1-autologin.conf
sed -i '/mesg n/s/^/# /' /root/.profile
```