# Windows 7 删除多余的网卡
1. 打开注册表`regedit.exe`
2. 进入`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles`和`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\Unmanaged`,清空下面的子项
3. 重启

或

1. `cmd.exe`中运行
    ```
    set devmgr_show_nonpresent_devices=1
    start devmgmt.msc
    ```
    打开设备管理器
2. 对于 Windows 8 或更新的系统,可以在设备管理器上查看显示隐藏的设备
3. 找到多余的设备,删掉