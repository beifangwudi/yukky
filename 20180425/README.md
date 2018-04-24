# Linux找回被删除的文件
在Ubuntu 16.04 x64上,因为占用磁盘空间,我删除了nginx的access.log访问日志文件,并建立了一个新的空文件,但是几天后我发现nginx并没有往里面写日志,而是写在了被删除的那个文件里,下面是恢复日志文件的步骤
1. 在`nginx.pid`查看进程号,记做`$pid`
2. 执行`ls -al /proc/$pid/fd`,找出标记为`deleted`的access.log文件对应的文件描述符,记做`$fd`
3. `cp -f /proc/$pid/fd/$fd ./access.log`,用`$fd`覆盖日志文件
4. `nginx -s reload`,重启nginx