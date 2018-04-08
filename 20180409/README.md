# 获取阿里云云监控数据
```python
#!/usr/bin/python
# -*- coding:utf-8 -*-

AccessKeyId = 'LTAIuTwUhClreJjx'
AccessKeySecret = 'XnbewJKRVR1pLAUhz3TsZx86Rs6n1P'
# 需要获得的数据
instance = [
    {
        'id': 'i-94vkpccfgk5kyh6v2d7i',
        'name': '博客服务器',
        'device': {
            'cpu': {
                'CPUUtilization': [],
            },
            'memory': {
                'memory_usedutilization': [],
            },
            'eth0': {
                'networkin_rate': [],
                'networkout_rate': []
            },
            '/dev/vda1': {
                'disk_readbytes': [],
                'disk_writebytes': []
            }
        }
    },
]

from urllib import parse
import hmac, base64, hashlib
import json, time, requests

# 今天0点的秒级时间戳
end_time = time.time() // 86400 * 86400 + time.timezone - 60
args = {
    'Format': 'JSON',
    'Version': '2017-03-01',
    'AccessKeyId': AccessKeyId,
    'SignatureMethod': 'HMAC-SHA1',
    'SignatureVersion': '1.0',
    'Action': 'QueryMetricList',
    'Project': 'acs_ecs_dashboard',
    'Period': 60,
    'Length': 720,
    'Signature': ''
}


def percentEncode(s):
    return parse.quote(str(s).encode('utf-8')).replace('+', '%20').replace(
        '*', '%2A').replace('%7E', '~').replace('/', '%2F')


# 遍历实例
for ins in instance:
    for dev, val in ins['device'].items():
        for k, v in val.items():
            args['Dimensions'] = '{"instanceId":"%s","device":"%s"}' % (
                ins['id'], dev)
            args['Metric'] = k
            # 遍历时间,一次取12小时数据,7天取14次
            for day in range(14, 0, -1):
                args['StartTime'] = int(end_time - day * 43200) * 1000
                # 请求失败的话重试两次
                for retry in range(1, 4):
                    try:
                        args['Timestamp'] = time.strftime(
                            '%FT%XZ', time.gmtime())
                        args['SignatureNonce'] = time.time()
                        # 生成Signature,下次使用前要清空
                        del args['Signature']
                        args['Signature'] = base64.encodestring(
                            hmac.new(
                                (AccessKeySecret + "&").encode('utf-8'),
                                ('GET&%2F&' +
                                 percentEncode('&'.join([
                                     f'{percentEncode(k)}={percentEncode(v)}'
                                     for k, v in sorted(
                                         args.items(), key=lambda x: x[0])
                                 ]))).encode('utf-8'),
                                hashlib.sha1).digest()).strip()
                        # 正式请求,可以加上一些结果验证
                        j = requests.get(
                            'http://metrics.aliyuncs.com/', params=args)
                        j = json.loads(j.text)
                        break
                    except:
                        pass
                else:
                    continue
                # 将结果写入instance
                for res in j['Datapoints']:
                    v.append((int(res['timestamp'] / 1000), res['Average']))

# 保存数据
with open('/Users/beifang/instance.txt', 'r') as f:
    print(instance, file=f)

# 直接用阿里云SDK获取数据
# pip install aliyun-python-sdk-core-v3 aliyun-python-sdk-ecs aliyun-python-sdk-cms
# from aliyunsdkcore import client
# from aliyunsdkcms.request.v20170301 import QueryMetricListRequest
# clt = client.AcsClient('AccessKeyId', 'AccessKeySecret')
# request = QueryMetricListRequest.QueryMetricListRequest()
# request.set_accept_format('json')
# request.set_Project('acs_ecs_dashboard')
# request.set_Metric('disk_readbytes')
# request.set_Dimensions({'instanceId': 'i-94vkpccfgk5kyh6v2d7i'})
# print(clt.do_action_with_exception(request))
```