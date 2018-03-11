# Windows 10的重装相关
### 重置此电脑
重装Windows 10最简单的方法就是 `设置` -> `更新和安全` -> `恢复` -> 重置此电脑 `开始`
### 系统镜像
对于一些UEFI主板,从[MSDN i tell you](https://msdn.itellyou.cn/)下载系统iso,解压到u盘根目录,主板启动项设置为u盘即可.
### 制作Windows 10安装U盘
1. 进入 https://www.microsoft.com/zh-cn/software-download/windows10
2. 点击立即下载工具,下载`MediaCreationTool.exe`
3. 运行它,并选择U盘相关的选项
### 制作Windows PE
0. 参考 [WinPE: Create a Boot CD, DVD, ISO, or VHD](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-a-boot-cd-dvd-iso-or-vhd)
1. 下载并安装 [Windows ADK](https://docs.microsoft.com/zh-cn/windows-hardware/get-started/adk-install)
2. 选中 `Deployment Tools` 和 `Windows Preinstallation Environment`,中文环境下是 `部署工具` 和 `Windows 预安装环境`
3. 开始菜单右键以管理员身份运行 `Deployment and Imaging Tools Environment`,即 `部署和映象工具环境`
4. `copype amd64 C:\WinPE_amd64`,提取64位Windows PE文件
5. `MakeWinPEMedia /ISO C:\WinPE_amd64 C:\WinPE_amd64\WinPE_amd64.iso`,制作成iso文件
6. 将iso文件刻录到u盘或光盘