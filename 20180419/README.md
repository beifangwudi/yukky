# 通过邮箱远程控制
和git远控原理一样,向指定邮箱发送邮件,客户端定期访问邮箱,查找特定主题的邮件,找到则执行邮件里包含的指令,然后将执行结果以回复的方式再投送到邮箱.但是因为不同邮箱发送的邮件编码不同,比如Outlook是gb2312,QQ是utf8,有的还带有html代码,这里偷了个懒,只支持text/plain,邮件标题和内容也只能含有ascii字符.
```python
#!/usr/bin/python
# -*- coding:utf-8 -*-
import imaplib, smtplib, email, os, subprocess
import email.mime.text
os.chdir(os.path.split(os.path.realpath(__file__))[0])

# 以腾讯企业邮箱为例
imap = ('imap.exmail.qq.com', 993)
smtp = ('smtp.exmail.qq.com', 465)
user = ('redmine@taolesoft.com', 'qazQAZ123456@')
# 每台设备唯一id,自定义,用在标题中
mcid = '89757'

client = imaplib.IMAP4_SSL(host=imap[0], port=imap[1])
client.login(user[0], user[1])
client.select(readonly=True, mailbox='INBOX')
for mailid in client.search(None, 'ALL')[1][0].split()[::-1]:
    try:
        # 倒序遍历邮件(从新到旧),获取subject
        mail = email.message_from_string(
            client.fetch(mailid, '(RFC822)')[1][0][1].decode('utf-8'))
        subject = email.header.decode_header(mail.get('subject'))[0][0]

        # 如果已经被回复,说明没有新邮件,退出
        if subject == f're: {mcid}':
            os._exit(0)
        # 如果不符合mcid,则忽略
        if subject != mcid:
            continue

        # 如果获得cmd命令,则退出两层循环,否则忽略
        for part in mail.walk():
            if 'text/plain' in part.get('Content-Type'):
                script = part.get_payload(decode=True).decode('utf-8')
                break
        else:
            continue
        break
    except:
        continue
else:
    # 如果没有匹配到任何邮件,则退出
    os._exit(0)

# 处理邮件内容,做运行前的处理
script = script.replace('\r\n', '\n').split('\n')
if script[0].endswith('bash'):
    name = './1.sh'
    cmd = ['bash', name]
elif script[0].endswith('python'):
    name = './1.py'
    cmd = ['python', name]
elif script[0].endswith('powershell'):
    name = './1.ps1'
    cmd = [
        'powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', name
    ]
else:
    os._exit(0)

with open(name, 'w', newline='\n') as f:
    for i in script[1:]:
        print(i, file=f)

# 运行脚本,保存结果
result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

# 将结果发送到邮箱
mail = email.mime.text.MIMEText(
    result.stdout.decode('utf-8'), 'plain', 'utf-8')
mail['from'] = user[0]
mail['to'] = user[0]
mail['Subject'] = f're: {mcid}'
client = smtplib.SMTP(host=smtp[0])
client.login(user[0], user[1])
client.sendmail(user[0], [user[0]], mail.as_string())
```