# 生成随机密码
一个简单的生成随机密码的小工具,像这样使用
```bash
python ./passgen.py -n 400 -f 1.txt 2.txt 3.txt -s '()-_=+`~' -c '1@'
```
生成一个400位的密码,包含数字和特殊字符,特殊字符为'()-_=+`~',生成的密码写到标准输出和1.txt,2.txt,3.txt这几个文件,具体可以看代码和注释,希望我写清楚了.
```python
#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys, argparse, random
number = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
uppercase = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
]
lowercase = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
    'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
]

p = argparse.ArgumentParser(description='密码生成器')
# 生成的密码中包含的字符类型,有'aA1@'4种,一个字符出现多次即表示该密码中至少出现该类型字符多次
p.add_argument(
    '-c',
    '--character',
    default='aA1@',
    help='含有"aA1@"其中一个或多个的字符串,a表示生成的密码中含小写字符,A大写字符,1数字,@特殊字符')
p.add_argument(
    '-s', '--special', default='!@#$%^&*', help='指定特殊字符包含的内容,默认是!@#$%%^&*')
p.add_argument('-n', '--number', type=int, default=10, help='密码位数')
p.add_argument(
    '-f',
    '--files',
    nargs='+',
    type=argparse.FileType('w'),
    help='一个或多个需要写入生成的密码的文件')
args = p.parse_args()
# 以上各参数均可以省略

# 一些预处理
args.special = list(set([i for i in args.special]))
if len(args.character) > args.number:
    sys.exit('密码过短')

# 生成密码字符串
password = []
pre_password = [i for i in args.character]
t = set(pre_password)
for _ in range(args.number - len(args.character)):
    pre_password += random.sample(t, 1)
random.shuffle(pre_password)
for i in pre_password:
    if i == 'a':
        password += random.sample(lowercase, 1)
    elif i == 'A':
        password += random.sample(uppercase, 1)
    elif i == '1':
        password += random.sample(number, 1)
    elif i == '@':
        password += random.sample(args.special, 1)
    else:
        sys.exit('不明字符')
password = ''.join(password)

# 将密码输出到文件
if not args.files:
    args.files = []
args.files += [sys.stdout]
for i in args.files:
    print(password, file=i)
```