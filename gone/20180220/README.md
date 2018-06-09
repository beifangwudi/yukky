# Windows上的Linux
### 安装
1. 开启功能  
`控制面板` -> `启用或关闭 Windows 功能` -> 选中 `适用于 Linux 的 Windows 子系统`  
    ```powershell
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    ```
2. 安装([参考](https://docs.microsoft.com/zh-cn/windows/wsl/install-on-server))
    * 旧分发版
        ```
        lxrun /install /y
        ```
    * 应用商店  
    搜索`WSL`,任选其一  
    * 服务器版
        ```powershell
        Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1604 -OutFile ~/Ubuntu.zip -UseBasicParsing
        Expand-Archive ~/Ubuntu.zip ~/Ubuntu
        ~/Ubuntu/ubuntu.exe
        ```
### VSCode
打算让VSCode使用WSL中的git
1. 在[andy-5/wslgit](https://github.com/andy-5/wslgit)下载wslgit.exe
2. 在VSCode中加入配置`"git.path": "C:\\CHANGE\\TO\\PATH\\TO\\wslgit.exe"`
3. 如果无法正常运行,有可能是缺少`vcruntime140.dll`,需要安装[VC2015运行库](https://www.microsoft.com/en-us/download/confirmation.aspx?id=48145)
4. 所有WSL的终端都要以相同的权限运行,包括VSCode里的