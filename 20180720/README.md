# 安装禅道
```bash
#!/bin/bash

# docker build -t zentao:empty . -f - << '666'
docker build -t zentao:empty - << 'megumin'
FROM ubuntu:xenial
RUN apt-get update && apt-get install -y wget php-ldap --no-install-recommends && rm -rf /var/lib/apt/lists/*
VOLUME /opt/zbox
EXPOSE 80
ENTRYPOINT /opt/zbox/zbox start && tail -f /dev/null
megumin

mv -f /opt/zbox /opt/zbox_$(date +%s.%N)
curl -sL http://dl.cnezsoft.com/zentao/9.8.3/ZenTaoPMS.9.8.3.zbox_64.tar.gz | tar zxv -C /opt
docker run -d --restart=always -p 80:80 -v /opt/zbox:/opt/zbox zentao:empty
```
[参考](https://github.com/idoop/zentao)