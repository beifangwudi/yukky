# Windows,VMware与Docker
### 前面
在Windows 10 Pro上,Hyper-V和VMware Workstation只能二选一,Docker for Windows依赖Hyper-V,如果不想放弃VMware Workstation,就只好在VMware Workstation上安装Linux虚拟机,通过tcp连接模拟原生体验.
### 安装Docker
以Ubuntu 16.04为例,参照[官方文档](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)
```bash
# 添加ustc源
add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) edge"
# 添加GPG密钥
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | apt-key add -
apt update
# 安装
apt install docker-ce -y
```
### 虚拟机上的配置
Docker默认只接受本机连接,要让它监听端口,比如6656
1. 修改`/etc/systemd/system/multi-user.target.wants/docker.service`,在ExecStart项最后加上`-H tcp://0.0.0.0:6656`,像这样
    ```
    ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:6656
    ```
2. 可以用ustc的[镜像加速器](https://lug.ustc.edu.cn/wiki/mirrors/help/docker)为镜像下载加速
    ```bash
    echo '{"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]}' > /etc/docker/daemon.json
    ```
3. 重启服务
    ```bash
    systemctl daemon-reload
    systemctl restart docker.service
    ```
4. 验证`curl 127.0.0.1:6656/version`,返回json字符串说明成功
5. 第1步也可以这样做
    ```bash
    socat TCP-LISTEN:6656,reuseaddr,fork UNIX:/var/run/docker.sock
    ```
### Windows上的配置
我打算在WSL中使用,所以选择[Linux版本的docker客户端](https://download.docker.com/linux/static/stable/x86_64/docker-17.12.1-ce.tgz),如果要在PowerShell中使用,请选择[Windows版本](https://download.docker.com/win/static/stable/x86_64/docker-17.09.0-ce.zip),以WSL为例说明
1. 解压出docker文件,放到/usr/local/bin目录下
2. 在.bashrc文件中添加
    ```bash
    # 192.168.66.213为虚拟机的ip
    export DOCKER_HOST='192.168.66.213:6656'
    ```
3. 重新加载.bashrc,执行`docker version`,看到Server说明成功
4. 安装自动补全
    ```bash
    curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker
    ```
    安装完成之后再打开新终端就可以用了
5. 从[docker/compose](https://github.com/docker/compose/releases)下载docker-compose的Linux版本,重命名为docker-compose放到/usr/local/bin下
6. 安装docker-compose的自动补全
    ```bash
    curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
    ```
### 启动
需要用到Docker时启动虚拟机,开机启动命令如下
```powershell
& 'C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe' start 'C:\Users\gushi\Documents\Virtual Machines\
docker\docker.vmx' nogui
```
像这样