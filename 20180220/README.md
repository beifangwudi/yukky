# Windows上的Linux
### 安装
1. 开启功能  
`控制面板` -> `启用或关闭 Windows 功能` -> 选中 `适用于 Linux 的 Windows 子系统`  
`设置` -> `针对开发人员` -> 选中 `开发人员模式`
2. 从应用商店安装  
搜索`WSL`,任选其一  
或从命令行安装,只能使用Ubuntu
    ```
    lxrun /install /y
    ```
### 终端
安装完成后,系统自带的终端对中文会存在一些bug,比如[字体无法保存](https://github.com/Microsoft/WSL/issues/2463),所以建议选择第三方终端[goreliu/wsl-terminal](https://github.com/goreliu/wsl-terminal),配置可以参考[官方README](https://goreliu.github.io/wsl-terminal/README.zh_CN.html)
### VSCode
打算让VSCode使用WSL中的git
1. 在[andy-5/wslgit](https://github.com/andy-5/wslgit)下载wslgit.exe
2. 在VSCode中加入配置`"git.path": "C:\\CHANGE\\TO\\PATH\\TO\\wslgit.exe"`
3. 如果无法正常运行,有可能是缺少`vcruntime140.dll`,需要安装[VC2015运行库](https://www.microsoft.com/en-us/download/confirmation.aspx?id=48145)
4. 注意权限问题,比如VSCode以管理员身份运行,那么终端也要以管理员身份运行,或者都不以管理员身份运行,否则无法打开