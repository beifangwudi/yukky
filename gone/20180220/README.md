# Windows上的Linux
### 开启
`控制面板` -> `启用或关闭 Windows 功能` -> 选中 `适用于 Linux 的 Windows 子系统`  
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
### 安装
```powershell
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1604 -OutFile ~/Ubuntu.zip -UseBasicParsing
Expand-Archive ~/Ubuntu.zip ~/Ubuntu
~/Ubuntu/ubuntu.exe
```
### 使用
1. 在Linux中调用Windows程序
    ```
    root@DESKTOP:~# ipconfig.exe | grep IPv4
        IPv4 Address. . . . . . . . . . . : 192.168.1.17
        IPv4 Address. . . . . . . . . . . : 10.66.2.5
    ```
2. 在Windows上使用Linux命令
    ```
    PS C:\> Get-ChildItem | wsl grep P
    d-----        2018/4/12      7:38                PerfLogs
    d-r---        2018/5/13     17:29                Program Files
    d-r---        2018/5/18     10:57                Program Files (x86)
    ```
3. 共享变量
    ```
    C:\Users\beifa>set a=666

    C:\Users\beifa>set WSLENV=a

    C:\Users\beifa>bash
    root@DESKTOP:/mnt/c/Users/beifang# echo $a
    666
    root@DESKTOP:/mnt/c/Users/beifang#
    ```
    反过来也行
    ```
    root@DESKTOP:~# export b=999
    root@DESKTOP:~# export WSLENV=b
    root@DESKTOP:~# cmd.exe
    Microsoft Windows [Version 10.0.17134.81]
    (c) 2018 Microsoft Corporation。保留所有权利。

    C:\Windows\system32>set b
    set b
    b=999

    C:\Windows\system32>
    ```
以上[参考](https://docs.microsoft.com/zh-cn/windows/wsl/about)