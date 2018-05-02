# Windows 10打Meltdown和Spectre补丁
### 检测
```powershell
# 允许数字证书签名过的脚本运行
Set-ExecutionPolicy Allsigned
# 安装检测的Powershell模块
Install-Module SpeculationControl
# 检测
Get-SpeculationControlSettings
```
### 更新BIOS
结果为红字,需要去硬件官网下载固件更新BIOS
### 接收更新
结果仍然为红字,原因是微软没有推送补丁.微软强制要求用户必须安装防病毒软件,否则不推送安全更新.参考[这里](https://support.microsoft.com/en-us/help/4072699/january-3-2018-windows-security-updates-and-antivirus-software)解决办法是:  
在`Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat`创建`DWORD(32位)`,命名为`cadca5fe-87d3-4b96-b7fb-a231484277cc`,值为0.