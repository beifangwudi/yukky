# 试验用CentOS 7初始化
### 登录
```bash
# 设置密码
echo iampassword | passwd root --stdin
# ssh相关
sed -ri 's/^#? *(PermitRootLogin ).*/\1yes/' /etc/ssh/sshd_config
sed -ri 's/^#? *(PasswordAuthentication ).*/\1no/' /etc/ssh/sshd_config
sed -ri 's/^#? *(TCPKeepAlive ).*/\1yes/' /etc/ssh/sshd_config
sed -ri 's/^#? *(ClientAliveInterval ).*/\19/' /etc/ssh/sshd_config
sed -ri 's/^#? *(ClientAliveCountMax ).*/\19/' /etc/ssh/sshd_config
mkdir ~/.ssh
echo 'ssh-rsa AAAAB......YYYYZ' > ~/.ssh/authorized_keys
```
### 软件
```bash
# 换源
mv /etc/yum.repos.d/CentOS-Base.repo{,.ori}
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sed -i '/aliyuncs/d' /etc/yum.repos.d/CentOS-Base.repo
yum -y update
# epel
yum install epel-release -y
curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
```
### 网络
```bash
# 关闭firewalld
yum remove firewalld* -y
# 安装iptables
yum install iptables-services -y
echo '*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
COMMIT' > /etc/sysconfig/iptables
# 开启
systemctl enable iptables
# 关闭selinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.d/99-sysctl.conf
```
### 开机显示IP
```bash
sed -ri 's/^(GRUB_TIMEOUT=).*/\11/' /etc/default/grub
sed -i 's/rhgb quiet/ipv6.disable=1/' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
sed -i '2aIP:\\4' /etc/issue
```
### bashrc配置
```bash
sed -i '/^alias/d' ~/.bashrc
echo "export HISTTIMEFORMAT='| %F %T | '" >> ~/.bashrc
```