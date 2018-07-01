# 打包Python代码
现有一段代码,在Linux上打包,要求生成可以在Windows,macOS以及Linux等各个操作系统上独立运行的二进制文件.
```python
#!/usr/bin/python3
# -*- coding:utf-8 -*-

import requests
r = requests.get('https://www.baidu.com/')
print(r.text)
```
打包环境`Ubuntu 18.04 x64`,测试环境`Ubuntu 16.04 x64`.

0. 打包环境直接运行`./test.py`,成功
1. [PyInstaller](https://www.pyinstaller.org/)
    * 安装
        ```bash
        apt install -y python3-pip
        pip3 install pyinstaller
        ```
    * 编译
        ```bash
        pyinstaller -F ./test.py
        ```
        生成了`dist/test`
    * 运行
        ```
        [70] Error loading Python lib '/tmp/_MEIY6wurF/libpython3.6m.so.1.0': dlopen: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.25' not found (required by /tmp/_MEIY6wurF/libpython3.6m.so.1.0)
        ```
        失败
2. [Cython](http://cython.org/)
    * 安装
        ```bash
        apt install -y python3-pip
        pip3 install Cython
        ```
    * 编译
        ```bash
        cython ./test.py --embed
        gcc -I /usr/include/python3.6m -o test test.c -lpython3.6m
        ```
        生成了`test`
    * 运行
        ```
        ./test: error while loading shared libraries: libpython3.6m.so.1.0: cannot open shared object file: No such file or directory
        ```
        失败
3. [Nuitka](http://nuitka.net/)
    * [安装](http://nuitka.net/pages/download.html)
        ```bash
        CODENAME=`lsb_release -c -s`
        wget -O - http://nuitka.net/deb/archive.key.gpg | apt-key add -
        echo > /etc/apt/sources.list.d/nuitka.list "deb http://nuitka.net/deb/stable/$CODENAME $CODENAME main"
        apt update
        apt install -y nuitka
        ```
    * 编译
        ```bash
        python3 -m nuitka --recurse-all --standalone ./test.py
        ```
        生成了`test.dist`,相关库文件和主程序都在里面
    * 运行
        ```
        test.dist/test.exe: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.25' not found (required by /root/test.dist/libpython3.6m.so.1.0)
        test.dist/test.exe: /lib/x86_64-linux-gnu/libc.so.6: version `GLIBC_2.25' not found (required by /root/test.dist/libexpat.so.1)
        ```
        失败
4. [Miniconda](https://conda.io/miniconda.html)
    * 安装  
    下载[官方的Linux安装脚本](https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh),运行安装
    * 创建环境
        ```bash
        miniconda3/bin/conda create --name test python=3.6
        miniconda3/envs/test/bin/pip install requests
        ```
        生成了`miniconda3/envs/test`,相关依赖都在里面,拷贝目录到测试环境
    * 运行
        ```bash
        test/bin/python ./test.py
        ```
        成功
    * 结论  
    虽然Miniconda主要用途是用来管理多版本Python,但用来打包意外好用.这样只是制作了一个可移植的环境,而不是完全的打包,还需要做一些额外的工作.

简单的测试下,只有一例成功,我故意将测试环境设成较老的系统,这样都不行,跨平台就更不用说了.但如果换成golang
```golang
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	resp, _ := http.Get("https://www.baidu.com/")
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(body))
}
```
* 安装
    ```bash
    apt install -y golang
    ```
* 编译
    ```bash
    GOARCH=amd64 GOOS=linux go build ./test.go
    ```
    生成了`test`
* 运行
    ```html
    <html>
    <head>
            <script>
                    location.replace(location.href.replace("https://","http://"));
            </script>
    </head>
    <body>
            <noscript><meta http-equiv="refresh" content="0;url=http://www.baidu.com/"></noscript>
    </body>
    </html>
    ```

不得不说,语言之间的差异真是大.