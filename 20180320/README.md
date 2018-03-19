# RHEL安装指南
1. 在[红帽官网](https://www.redhat.com/)注册账号,邮箱可以乱填,不需要验证,但是用个人邮箱(比如163,Outlook等)注册的账号无法试用产品.
2. 在[这里](https://access.redhat.com/products/red-hat-enterprise-linux/evaluation)选择合适的iso镜像下载,需要同意[这里](https://www.redhat.com/wapps/tnc/termsack?event[]=signIn)的条款.
3. 安装系统完成后,进入系统,参照[这里](https://access.redhat.com/solutions/253273)登录红帽账号
    ```bash
    subscription-manager register --username=YOURNAME --password=YOURPASSWORD --auto-attach
    ```
    运行`subscription-manager list`,显示类似下面的文字说明成功
    ```
    +-------------------------------------------+
        Installed Product Status
    +-------------------------------------------+
    Product Name:   Red Hat Enterprise Linux Server
    Product ID:     xxxxxxxxxx
    Version:        xxxxxxxxxx
    Arch:           xxxxxxxxxx
    Status:         xxxxxxxxxx
    Status Details: xxxxxxxxxx
    Starts:         xxxxxxxxxx
    Ends:           xxxxxxxxxx
    ```
4. 参照[这里](https://access.redhat.com/solutions/23016),安装`reposync`和`createrepo`
    ```bash
    yum install yum-utils createrepo
    ```
5. 同步仓库
    ```bash
    reposync --gpgcheck -l --repoid=rhel-7-server-rpms --download_path=YOURPATH --downloadcomps --download-metadata
    ```
    `repoid`填的是`/etc/yum.repos.d/redhat.repo`里仓库的名字,以`rhel-7-server-rpms`为例,增量同步可以加上`-n`选项.
6. 插曲,磁盘空间不足,lvm扩容
    ```bash
    # 新建分区,这里为/dev/sda3
    fdisk /dev/sda
    partprobe
    pvcreate /dev/sda3
    vgextend rhel_rhel7 /dev/sda3
    lvextend -l +100%FREE /dev/rhel_rhel7/root
    # 这里不能用resize2fs
    xfs_growfs /dev/rhel_rhel7/root
    ```
7. 创建仓库
    ```bash
    createrepo -v YOURPATH/rhel-7-server-rpms -g comps.xml
    ```
    每次增量同步仓库之后可以用`--update`选项加速.
8. 访问服务  
服务端可以搭建web
    ```bash
    cd YOURPATH
    python -m SimpleHTTPServer 80
    ```
    也可以通过samba或nfs服务  
    客户端使用自建仓库,不必登录红帽账号.
    ```bash
    cat > /etc/yum.repos.d/redhat.repo << EEE
    [rhel-7-server-rpms]
    baseurl = http://192.168.1.111/rhel-7-server-rpms/
    # baseurl = file:///mnt/repo/rhel-7-server-rpms/
    name = rhel-7-server-rpms
    enable = 1
    gpgcheck = 0
    EEE
    ```
9. 一个注册账号只能试用30天,到期需要重新注册账号,方便起见,仓库服务器也可以采用[docker](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_containers/using_red_hat_base_container_images_standard_and_minimal#finding_standard_base_images)的形式
    ```bash
    docker run -it registry.access.redhat.com/rhel7/rhel
    ```