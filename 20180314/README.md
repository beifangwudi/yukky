# 搭建KMS激活服务器
1. 需要一台能被访问的机器,假设IP为`192.168.66.66`
2. 去[Wind4/vlmcsd](https://github.com/Wind4/vlmcsd/releases)下载最新的二进制文件
3. 解压,Windows机器运行
    ```powershell
    \binaries\Windows\intel\vlmcsd-Windows-x64.exe
    ```
    Linux机器运行
    ```bash
    ./binaries/Linux/intel/static/vlmcsd-x64-musl-static
    ```
    防火墙放行1688端口
4. 客户端运行
    ```powershell
    \binaries\Windows\intel\vlmcs-Windows-x64.exe -v -l 15 192.168.66.66
    ```
    模拟Windows 10专业版的激活请求,如果得到回应,说明搭建成功
5. 支持Windows Vista以上的所有Windows版本和Office 2010以上的所有Office版本,不支持Office 365,只对VL版有效,有效期180天,不过只要服务正常运行,会自动续期
6. Windows 10激活脚本,自行替换激活密钥
    ```powershell
    slmgr /upk
    slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
    slmgr /skms 192.168.66.66
    slmgr /ato
    slmgr /xpr
    ```
    Office 2016激活脚本
    ```powershell
    cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /inpkey:XQNVK-8JYDB-WJ9W3-YJ8YR-WFG99
    cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /sethst:192.168.66.66
    cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /act
    ```
7. 激活密钥在这里  
https://docs.microsoft.com/en-us/windows-server/get-started/kmsclientkeys  
https://technet.microsoft.com/en-us/library/dn385360(v=office.16).aspx  