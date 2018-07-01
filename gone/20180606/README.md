# VSCode和Golang
要在VSCode里舒服使用Golang,需要额外安装一些包,因为网络问题,`github.com`上的包可以顺利下载,但`golang.org`上的就不行,记录一下解决过程.

1. 假设GOPATH为`~/go`,若git命令无法直接访问`github.com`,需要配置一下代理.
    ```bash
    git config --global http.proxy socks5://ip:port
    git config --global https.proxy socks5://ip:port
    ```
2. 需要安装的包来自于[Microsoft/vscode-go](https://github.com/Microsoft/vscode-go/wiki/Go-tools-that-the-Go-extension-depends-on)
3. 首先从`github.com`的镜像下载位于`golang.org`的两个包
    ```bash
    go get -u -v github.com/golang/tools
    go get -u -v github.com/golang/lint
    ```
    将`~/go/github.com/src`复制为`~/go/src/golang.org`
4. 再依次下载剩下的包
    ```bash
    go get -u -v github.com/ramya-rao-a/go-outline
    go get -u -v github.com/acroca/go-symbols
    go get -u -v github.com/nsf/gocode
    go get -u -v github.com/rogpeppe/godef
    go get -u -v github.com/zmb3/gogetdoc
    go get -u -v github.com/golang/lint/golint
    go get -u -v github.com/fatih/gomodifytags
    go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
    go get -u -v sourcegraph.com/sqs/goreturns
    go get -u -v github.com/cweill/gotests
    go get -u -v github.com/josharian/impl
    go get -u -v github.com/haya14busa/goplay/cmd/goplay
    go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs
    go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
    go get -u -v github.com/derekparker/delve
    ```
    会自动下载依赖,顺序无关紧要