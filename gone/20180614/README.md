# 简易内存数据库
有时候服务器之间需要传递共享一些数据,但又不打算安装远程共享或者数据库,所以写了一个简单的自用.
```python
#!/usr/bin/python3
# -*- coding:utf-8 -*-

from flask import Flask, request, abort
app = Flask(__name__)
data = {}


@app.route('/get', methods=['GET'])
def get_value():
    key = request.args.get('k', '_')
    if key == '_': abort(404)
    return '{"msg":"ok","%s":"%s"}' % (key, data[key])


@app.route('/set', methods=['POST'])
def set_value():
    key = request.args.get('k', '_')
    value = request.form.get('v', '_')
    if key == '_' or value == '_': abort(404)
    data[key] = value
    return '{"msg":"ok"}'


@app.errorhandler(401)
@app.errorhandler(404)
@app.errorhandler(500)
@app.errorhandler(Exception)
def something_wrong(e):
    return '{"msg":"no such key or value"}'


app.run(host='0.0.0.0', port=80, debug=False)
```
有些简陋,用法如下
```
$ curl http://127.0.0.1/get?k=suzumiya
{"msg":"no such key or value"}
$ curl -d 'v=haruhi' http://127.0.0.1/set?k=suzumiya
{"msg":"ok"}
$ curl http://127.0.0.1/get?k=suzumiya
{"msg":"ok","suzumiya":"haruhi"}
```