# 收集ssh密码
[danielmiessler/SecLists](https://github.com/danielmiessler/SecLists/tree/master/Passwords)有很多现成的密码,但如果想自己收集,就需要搭建一个蜜罐,代码来源于[这里](http://www.chokepoint.net/2014/01/more-fun-with-pam-python-failed.html),略作修改
1. 准备一台公网服务器,以CentOS 7为例,密钥登录ssh
2. 编译`pam_python.so`
    ```bash
    yum install gcc patch python-devel pam-devel -y
    curl -o pam-python_1.0.6.orig.tar.gz -#L 'https://netcologne.dl.sourceforge.net/project/pam-python/pam-python-1.0.6-1/pam-python_1.0.6.orig.tar.gz'
    curl -o pam-python-1.0.6-fedora.patch -#L 'https://sourceforge.net/p/pam-python/tickets/_discuss/thread/5dc8cfd5/5839/attachment/pam-python-1.0.6-fedora.patch'
    tar xf pam-python_1.0.6.orig.tar.gz
    patch -p0 < pam-python-1.0.6-fedora.patch
    cd pam-python-1.0.6
    make lib
    cp -f src/build/lib.linux-x86_64-2.7/pam_python.so /lib64/security
    ```
    Ubuntu/Debian系列方便一些,`apt install -y python-pam libpam-python`即可
3. 制作脚本`/lib/security/ssh_auth.py`
    ```python
    import syslog


    def auth_log(msg):
        syslog.openlog(facility=syslog.LOG_AUTH)
        syslog.syslog("AkiyamaMio: " + msg)
        syslog.closelog()


    def pam_sm_authenticate(pamh, flags, argv):
        try:
            user = pamh.get_user()
        except pamh.exception as e:
            return e.pam_result

        if not user:
            return pamh.PAM_USER_UNKNOWN
        try:
        # 若要显示自定义提示符需要在/etc/ssh/sshd_config中
        # 将ChallengeResponseAuthentication设为yes
            resp = pamh.conversation(
                pamh.Message(pamh.PAM_PROMPT_ECHO_OFF, 'Password: '))
        except pamh.exception as e:
            return e.pam_result

        auth_log("%s:%s@%s" % (user, resp.resp, pamh.rhost))
        return pamh.PAM_AUTH_ERR


    def pam_sm_setcred(pamh, flags, argv):
        return pamh.PAM_SUCCESS


    def pam_sm_acct_mgmt(pamh, flags, argv):
        return pamh.PAM_SUCCESS


    def pam_sm_open_session(pamh, flags, argv):
        return pamh.PAM_SUCCESS


    def pam_sm_close_session(pamh, flags, argv):
        return pamh.PAM_SUCCESS


    def pam_sm_chauthtok(pamh, flags, argv):
        return pamh.PAM_SUCCESS
    ```
4. 在`/etc/pam.d/sshd`中,添加`auth requisite pam_python.so ssh_auth.py`到`#%PAM-1.0`下一行
5. 重启sshd服务,日志记录在`/var/log/messages`,可以看到密码已经被记录
