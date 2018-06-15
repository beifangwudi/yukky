# flask发邮件
```python
#!/usr/bin/python3
# -*- coding: utf-8 -*-
from flask import Flask, request
from flask_mail import Mail, Message
app = Flask(__name__)

app.config['MAIL_SERVER'] = 'smtp.exmail.qq.com'
app.config['MAIL_PORT'] = 25
app.config['MAIL_USERNAME'] = 'sunyuyang@58.com'
app.config['MAIL_PASSWORD'] = 'X.JzpVkzx8zPHs3I'
mail = Mail(app)


@app.route('/mail', methods=['POST'])
def send_mail():
    rcp = request.form.get('r', 'recipient')
    sbj = request.form.get('s', 'subject')
    ctn = request.form.get('c', 'content')

    if rcp.find('@') == -1:
        return 'error'
    msg = Message(sbj, sender='sunyuyang@58.com', recipients=[rcp])
    msg.body = ctn
    mail.send(msg)
    return 'ok'


app.run(host='0.0.0.0', port=6996, debug=False)
```
封装邮件api,内网使用,方便开发