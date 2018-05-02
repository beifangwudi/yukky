# 简单分析nginx日志
### 目标
日志的格式像这样
```
60.255.27.244 - - [14/Mar/2018:18:10:52 +0800] "GET /favicon.ico HTTP/1.1" 200 0 "-" "Mozilla/5.0 (Linux; Android 6.0; HUAWEI NXT-AL10 Build/HUAWEINXT-AL10) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/35.0.1916.138 Mobile Safari/537.36 T7/7.1 baiduboxapp/8.0 (Baidu; P1 6.0)"
```
要求取得网站最近一周的每天访问量和被访问最多的页面
### 代码
```python
#!/usr/bin/python
# -*- coding:utf-8 -*-
import re, sys, time

# 取一周前的时间,比如今天是周五,取上周五零点的时间
now = time.time()
s7_days_ago = time.localtime(now - (now % 86400) - 86400 * 7 + time.timezone)
# 取今天0点,即时间范围是上周五到本周四这7天
s_today = time.localtime(now - (now % 86400) + time.timezone)

# 记录网站pv
page_view = {}
# 访问频数topN
url_frequency = {}

# 开始解析日志
with open(sys.argv[1]) as file:
    for line in file:
        seg = re.match(r'^(\S+).*?\[(.*?) .*?".*? (.*?) .*".*$', line.strip())
        # 60.255.27.244
        remote_ip = seg.group(1)
        # 14/Mar/2018:18:10:52
        # time.struct_time(tm_year=2018, tm_mon=3, tm_mday=14, tm_hour=18, tm_min=10, tm_sec=52, tm_wday=2, tm_yday=73, tm_isdst=-1)
        access_time = time.strptime(seg.group(2), '%d/%b/%Y:%H:%M:%S')
        # /favicon.ico
        access_url = seg.group(3)
        # 在时间范围内且url合法则处理
        if s7_days_ago < access_time < s_today and access_url.startswith('/'):
            # 去掉后面的问号,多个斜杠换成一个
            access_url = re.sub('/+', '/', access_url)
            access_url = re.sub('\?.*$', '', access_url)
            # 正则匹配有效url,此处略
            if re.match(r'^/(a|b|c)(/.*)?$', access_url):
                # 计算pv
                date_key = time.strftime("%Y-%m-%d", access_time)
                page_view.setdefault(date_key, 0)
                page_view[date_key] += 1
                # 计算topN
                url_frequency.setdefault(access_url, 0)
                url_frequency[access_url] += 1

for k, v in page_view.items():
    print(f"{k}:{v}")
for k, v in sorted(
        url_frequency.items(), key=lambda x: x[1], reverse=True)[:10]:
    print(f"{k}:{v}")
```