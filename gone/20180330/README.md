# Windows 10关闭Hyper-V
1. `启用或关闭 Windows 功能`里取消勾选`Hyper-V`,重启
2. `设备管理器`的`网络适配器`里卸载所有的Hyper-V相关网卡
3. 如果有被Hyper-V设置为交换机的物理网卡,可以在`设备管理器`卸载,再`扫描检测硬件改动`
4. 删除`C:\Users\Public\Documents\Hyper-V`里的硬盘文件
5. 删除`C:\ProgramData\Microsoft\Windows\Hyper-V`里的配置文件