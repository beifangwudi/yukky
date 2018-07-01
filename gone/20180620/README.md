# iptables监控端口访问
如下设置
```bash
iptables -A INPUT -p tcp -m state --state NEW -j LOG --log-prefix 'GasaiYuno '
```
尝试访问tcp端口
```bash
echo | telnet 192.168.7.184 22
```
`/var/log/messages`或`/var/log/syslog`会出现如下日志
```
May 13 19:49:17 centos7 kernel: GasaiYuno IN=ens33 OUT= MAC=00:0c:29:d4:50:51:5e:62:3c:18:51:19:08:00 SRC=192.168.7.2 DST=192.168.7.184 LEN=52 TOS=0x00 PREC=0x00 TTL=128 ID=10516 DF PROTO=TCP SPT=51850 DPT=22 WINDOW=62440 RES=0x00 SYN URGP=0
```
可以用脚本做一些分析,也可以用[PSAD](https://github.com/mrash/psad)
```bash
#!/bin/bash
# 上次读取到此行
old_line=0
logfile='/var/log/messages'
output='/var/log/iptables'
# 这次要读到的行
new_line=$(wc -l "$logfile" | grep -oP '^\d+')
# 若新行数小于旧行数说明文件被切割
[ "$old_line" -gt "$new_line" ] && old_line=0
# 更新行数
sed -ri 's/^(old_line=).*/\1'"$new_line"'/' "$0"

# 取出日期,地址和端口
awk 'NR>='"$old_line"'+1 && NR<='"$new_line"' && /GasaiYuno/{
    d=substr($0,0,15)
    match($0,"SRC=[0-9.]+")
    src=substr($0,RSTART+4,RLENGTH-4)
    match($0,"SPT=[0-9]+")
    spt=substr($0,RSTART+4,RLENGTH-4)
    match($0,"DST=[0-9.]+")
    dst=substr($0,RSTART+4,RLENGTH-4)
    match($0,"DPT=[0-9]+")
    dpt=substr($0,RSTART+4,RLENGTH-4)
    print(d": "src":"spt" -> "dst":"dpt)
}' "$logfile" >> "$output"
```
找了台腾讯云的新开服务器测试,结果像下面这样
```
...
May 13 21:45:01: 77.72.82.101:51183 -> 10.105.98.166:9990
May 13 21:45:12: 180.214.176.39:33218 -> 10.105.98.166:88
May 13 21:45:14: 180.140.109.193:57442 -> 10.105.98.166:3389
May 13 21:45:17: 180.140.109.193:57442 -> 10.105.98.166:3389
May 13 21:45:21: 101.227.79.2:57501 -> 10.105.98.166:445
May 13 21:45:23: 180.140.109.193:57442 -> 10.105.98.166:3389
May 13 21:45:26: 121.69.1.196:52375 -> 10.105.98.166:445
May 13 21:45:31: 218.108.59.14:50486 -> 10.105.98.166:445
May 13 21:45:33: 180.168.94.235:61938 -> 10.105.98.166:445
May 13 21:45:40: 109.248.9.9:49182 -> 10.105.98.166:22
...
```
简略做了下分析
```bash
awk -F':' '{print($6)}' /var/log/iptables | sort -n | uniq -c | sort -k1n | tail -10
```
大约100分钟内,445端口被扫描了676遍
```
  2 81
  3 80
  5 8080
  6 8888
  8 22
  9 1433
 10 3306
 11 23
 12 3389
676 445
```
看来Windows确实比Linux受欢迎