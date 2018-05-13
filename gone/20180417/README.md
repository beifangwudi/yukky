# 通过git远程控制
### 原理
控制端通过浏览器往git仓库上传一个脚本,等着每台被控端来同步,被控端会把脚本拉倒本地执行,执行结果写在仓库的目录下,等到下一次再同步的时候,会把这次的结果同步上去.
### 目录结构
```
gitstack
|-- 20171223.192243
|   |-- files
|   |-- main.bash
|   `-- results
|       `-- beifangdermbp.log
`-- 20171223.193229
    |-- main.ps1
    |-- main.sh
    `-- results
        |-- CN.log
        `-- DESKTOP.log
```
根目录为gitstack,子目录以时间命名,便于排序.每个目录里面的main文件就是要执行的代码,Windows的被控端执行ps1,macOS执行bash,Linux执行sh,files目录可以用来放一些附件,results存放执行结果.

### 设置
1. 建立git私有仓库,这里选择`阿里云code`,在网页端发布脚本的时候,换行为`\n`而不是`\r\n`.
2. 在项目根目录下建立名为`0`的目录,目录下建立3个文件,分别是`main.sh`,`main.bash`,`main.ps1`.
3. `main.sh`的内容
    ```bash
    #!/bin/bash
    cd "$(dirname "$0")"/..
    export PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

    # 未同步时的所有main.sh
    before="$(find . -name 'main.sh')"
    # 如果本地出现更改,则提交
    if git status -s | grep .; then
        git add -A
        git commit -m "$HOSTNAME@$(date +%F_%T)"
    fi
    # 同步
    git pull origin master --no-edit
    git push origin master
    # 同步后的所有main.sh
    after="$(find . -name 'main.sh')"

    # 如果未出现新的main.sh,则退出,否则执行它
    script="$(diff <(echo "$before") <(echo "$after") | sed -n '/^>/s/^..//p' | tail -1)"
    [ -z "$script" ] && exit
    cd "$(dirname "$script")"
    mkdir results
    bash main.sh &> results/${HOSTNAME}.log
    ```
    其它两个文件内容省略
4. 被控端的初始化
    ```bash
    # 全局设置
    git config --global user.name "beifangwudi"
    git config --global user.email "beifangwudi@outlook.com"
    git config --global core.autocrlf input
    git config --global core.filemode false
    # 将私钥复制到~/.ssh下
    echo '-----BEGIN RSA PRIVATE KEY-----
    XXXXXXX...........................XXXXXXX
    -----END RSA PRIVATE KEY-----' > ~/.ssh/id_rsa
    chmod 400 ~/.ssh/id_rsa
    git clone git@code.aliyun.com:beifangwudi/gitstack.git
    # 加入crond执行
    echo '* * * * * root bash /home/beifang/gitstack/0/main.sh' >> /etc/crontab
    ```
