# 腾讯云解析DDNS
### 原因
多个OpenVPN客户端使用同一个用户的配置文件,会导致各客户端分配到的ip不规律,所以需要借助DDNS解决这个问题.
### 代码
```python
#!/usr/bin/python
# -*- coding:utf-8 -*-
import sys, os, requests, time, json, hmac, base64, hashlib, subprocess, socket
os.chdir(os.path.split(os.path.realpath(__file__))[0])

# 运行openvpn,只适用于Windows
with open('.\\1.bat', 'w') as f:
    # VPN要安装在C盘,配置文件要放到代码所在目录下
    f.write(':loop\n"C:\\Program Files\\OpenVPN\\'
            'bin\\openvpn.exe" .\\1.ovpn\ngoto :loop')
subprocess.Popen('.\\1.bat')

# 接受一个参数,子域名
subDomain = sys.argv[1]
domain = 'xvideos.com'
SecretId = 'AK47isMyAddressAtDecember192014oFUCK'
SecretKey = 'butifshegetgreedyImastarveherxto'
sip = '10.168.16.'


# 通过api查询dns
def getdns(**kv):
    args = {
        'Action': kv['Action'],
        'SecretId': SecretId,
        'SignatureMethod': 'HmacSHA1',
        'domain': domain
    }
    try:
        # 如果有ip,说明是添加记录或是修改记录,否则是查询记录
        args['value'] = kv['value']
        args['subDomain'] = subDomain
        args['recordType'] = 'A'
        args['recordLine'] = '默认'
        # 如果有id,说明是修改记录,否则是添加记录
        args['recordId'] = kv['recordId']
    except:
        pass
    for _ in range(3):
        try:
            args['Nonce'] = int(time.time() * 10**7)
            args['Timestamp'] = int(time.time())
            args['Signature'] = base64.encodestring(
                hmac.new(
                    SecretKey.encode('utf-8'),
                    ('GETcns.api.qcloud.com/v2/index.php?' + '&'.join([
                        f'{k}={v}'
                        for k, v in sorted(args.items(), key=lambda x: x[0])
                    ])).encode('utf-8'), hashlib.sha1).digest()).strip()
            j = requests.get(
                'https://cns.api.qcloud.com/v2/index.php', params=args)
            return json.loads(j.text)
        except:
            pass
    return {'data': {'records': {'name': ''}, 'record': {'id': ''}}}


# 获取本机以sip开头的ip
def getip():
    for ip in socket.gethostbyname_ex(socket.gethostname())[2]:
        if ip.startswith(sip):
            return ip
    return '0.0.0.0'


# 查询子域名是否存在
subDomain_id = [(l['id'], l['value'])
                for l in getdns(Action='RecordList')['data']['records']
                if l['name'] == subDomain]

# 不存在则创建
if not subDomain_id:
    old_ip = getip()
    subDomain_id = getdns(
        Action='RecordCreate', value=old_ip)['data']['record']['id']
else:
    old_ip = subDomain_id[0][1]
    subDomain_id = subDomain_id[0][0]

while True:
    time.sleep(10)
    new_ip = getip()
    # 如果ip变了则更新
    if new_ip != old_ip:
        old_ip = new_ip
        getdns(Action='RecordModify', value=old_ip, recordId=subDomain_id)

```