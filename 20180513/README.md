# 试验用Ubuntu 18.04初始化
### 登录
```bash
# 登录系统,切换到root
sudo -i
# 给root设置密码
chpasswd <<< 'root:iampassword'
# 关闭密码登录,开启密钥登录
sed -ri 's/^#? *(PermitRootLogin ).*/\1yes/' /etc/ssh/sshd_config
sed -ri 's/^#? *(PasswordAuthentication ).*/\1no/' /etc/ssh/sshd_config
# 保持连接
sed -ri 's/^#? *(TCPKeepAlive ).*/\1yes/' /etc/ssh/sshd_config
sed -ri 's/^#? *(ClientAliveInterval ).*/\19/' /etc/ssh/sshd_config
sed -ri 's/^#? *(ClientAliveCountMax ).*/\19/' /etc/ssh/sshd_config
# root添加公钥
mkdir ~/.ssh
echo 'ssh-rsa AAAAB......YYYYZ' > ~/.ssh/authorized_keys
# 登录时忽略known_hosts
echo -e 'Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null' > ~/.ssh/config
# 重启sshd,退出普通用户,以root登录,删除普通用户
systemctl restart sshd.service
userdel -r xxxxx
```
### 软件  
```bash
# 换阿里云的源
mv /etc/apt/sources.list{,.ori}
echo 'deb http://mirrors.ustc.edu.cn/ubuntu/ bionic'{,-updates,-security,-backports}' main restricted universe multiverse' | xargs -n7 > /etc/apt/sources.list
# 卸载一些用不上的
apt purge -y ufw snapd landscape-common
# 更新
apt clean && apt update && apt dist-upgrade -y && apt autoremove -y
# 关闭自动更新
sed -i 's/"1"/"0"/g' /etc/apt/apt.conf.d/10periodic
# 关闭apport
systemctl disable apport.service
# 关闭popularity-contest,默认是关闭
sed -ri 's/^(PARTICIPATE=).*/\1"no"/' /etc/popularity-contest.conf
```
### 网络
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
echo '@reboot root /sbin/iptables-restore < /etc/iptables.rules' > /etc/cron.d/iptables
# 开启ipv4转发
sed -ri 's/^#? *(net\.ipv4\.ip_forward).*/\1=1/' /etc/sysctl.conf
```
### 开机显示IP  
```bash
# 修改grub等待时间
sed -ri 's/^(GRUB_TIMEOUT=).*/\11/' /etc/default/grub
# 关闭ipv6
sed -ri '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"$/ ipv6.disable=1"/' /etc/default/grub
update-grub
# 在控制台登录界面显示ip
sed -i '1aIP:\\4' /etc/issue
# \4是显示对外ipv4的地址,\4{ens33}是指定显示ens33网卡的ipv4地址
```
### 命令历史时间  
```bash
echo "export HISTTIMEFORMAT='| %F %T | '" >> ~/.bashrc
rm -f ~/.bash_history; history -c; exit
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
 # 安装虚拟机支持
apt install -y open-vm-tools*
# 自动登录root
sed -i '/root/s/^/#/' /etc/pam.d/gdm-autologin
sed -ri '/\[daemon\]/aWaylandEnable=true\nAutomaticLoginEnable=true\nAutomaticLogin=root' /etc/gdm3/custom.conf
sed -i '/mesg n/s/^/# /' /root/.profile
```