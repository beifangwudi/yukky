# 在Linux上使用Citrix云桌面
### 环境
本地为Ubuntu 16.04 x64,服务器Citrix Xendesktop版本为7.1.现在打算在本地安装Citrix Receiver,使用Xendesktop中的Windows 10.[参考](https://help.ubuntu.com/community/CitrixICAClientHowTo).
### 步骤
1. 安装Ubuntu桌面系统,装上显卡驱动
2. [这里](https://www.citrix.com.cn/downloads/citrix-receiver/linux/receiver-for-linux-latest.html)下载`Full Packages`和`USB Support Packages`
3. 安装浏览器,这里选用`Chromium`
    ```bash
    apt install -y chromium-browser
    ```
4. 安装`Receiver`相关依赖
    ```bash
    apt install -y libwebkitgtk-dev
    ```
5. 安装`Receiver`
    ```bash
    dpkg -i icaclient_*.deb ctxusb_*.deb
    ```
6. 添加证书
    ```bash
    ln -s /usr/share/ca-certificates/mozilla/* /opt/Citrix/ICAClient/keystore/cacerts/
    c_rehash /opt/Citrix/ICAClient/keystore/cacerts/
    ```
7. 打开`Chromium`,访问Xendesktop,成功.
