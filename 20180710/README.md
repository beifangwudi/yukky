# 伪装命令行
想在Linux系统里运行`airodump -w KanekiKen -c 3 wlan0`这个命令,但又不想被别人发现,所以需要伪装成普通命令.
```c
#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dlfcn.h>

int __libc_start_main(int (*main)(int, char**, char**),
    int argc, char** argv,
    void (*init)(void),
    void (*fini)(void),
    void (*rtld_fini)(void),
    void(*stack_end))
{
    static int (*real_libc_start_main)() = NULL;
    if (!real_libc_start_main) {
        real_libc_start_main = dlsym(RTLD_NEXT, "__libc_start_main");
        if (!real_libc_start_main)
            abort();
    }

    int i, len, newargc = argc;
    char *tmp, **newargv = calloc(argc, sizeof(*argv));

    for (i = 0; i < argc; i++) {
        if (strcmp("--bfwd", argv[i]) == 0) {
            newargc = i;
            /* 初始化argv[0] */
            memset(argv[0], '\0', strlen(argv[0]));
            /* 将伪装命令全部复制进argv[0],前提是argv[0]足够大 */
            for (i = newargc + 1; i < argc; i++) {
                strcat(argv[0], argv[i]);
                strcat(argv[0], " ");
            }
            /* 重置除argv[0]的所有命令行参数 */
            for (i = 1; i < argc; i++)
                memset(argv[i], '\0', strlen(argv[i]));
            break;
        }
        else {
            /* 生成实际运行的命令 */
            len = strlen(argv[i]);
            tmp = calloc(1, len + 1);
            memcpy(tmp, argv[i], len);
            newargv[i] = tmp;
        }
    }
    return (real_libc_start_main(main, newargc, newargv, init, fini, rtld_fini, stack_end));
}
```
命名为`touka.c`,大意就是在main函数加载之前修改传入的argc和argv.编译成动态库
```bash
gcc -Wall -O2 -fpic -shared -Wl,--no-as-needed -ldl -o touka.so touka.c
```
因为Linux命令行的限制,这段代码是有缺陷的,即argv[0]的长度必须大于伪装命令的总长度,所以需要借助一个脚本完成余下的工作.
```bash
#!/bin/bash

for i in "$@"; do
    [ "x$flag" = 'x666' ] && fake_cmd+="$i "
        [ "x$i" = "x--bfwd" ] && flag=666
done

preload="$1"; shift
cmd=$(which "$1"); shift
len1=${#cmd}
len2=${#fake_cmd}
[ $len1 -le 1 ] && exit 1
[ $len1 -lt $len2 ] && cmd="$(for i in $(seq 1 $((len2-len1))); do echo -n /; done)$cmd"

LD_PRELOAD="$preload" exec "$cmd" "$@"
```
命名为`hide.sh`,用法也很简单,像这样
```bash
./hide.sh ./touka.so yes --bfwd ping 163.com
```
结果是,在`Ubuntu 18.04`和`CentOS 7`上实际运行的命令是`yes`,但用`ps`查看却是`ping 163.com`.对`htop`也有效,但`top`无效.因为`ps`读取的是`/proc/$pid/cmdline`,而`top`读取的是`/proc/$pid/stat`.真伪命令用`--bfwd`分隔.