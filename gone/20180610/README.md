# 双守护进程
```bash
#!/bin/bash
: ${D_command="$@"} ${D_command_pid=0} ${I_am_father=0} ${D_face_pid=0}
export D_command D_command_pid D_face_pid I_am_father
tmp=$(mktemp -t)

while :; do
    if [ $((I_am_father%2)) -eq 0 ] && [ ! -d /proc/"$D_command_pid" ]; then
        ($D_command & echo $! > $tmp)
        D_command_pid=$(< $tmp)
    fi
    if [ ! -d /proc/"$D_face_pid" ]; then
        ((I_am_father++))
        D_face_pid=$$
        ("$0" & echo $! > $tmp)
        D_face_pid=$(< $tmp)
        ((I_am_father--))
    fi
    sleep 1
done
```
1. 用法: `./double.sh ping 163.com`.会让ping命令一直运行,它有2个守护进程,ping命令和其中一个挂掉都会被另一个重启.
3. 定义4个变量,`D_command`是要守护的命令行,`D_command_pid`是要守护的命令的进程号,`I_am_father`为偶数就是守护进程,又称作爹进程,为奇数是守护进程的守护进程,称作儿进程,`D_face_pid`对于爹进程来说就是儿进程的pid,对于儿进程来说是爹进程的pid.
4. 爹进程同时守护命令和儿进程,命令挂了重启命令,儿进程挂了重启儿进程.儿进程只守护爹进程,命令挂了儿进程是不管的,命令和爹进程都挂了,儿进程会重启爹进程,再由爹进程启动命令.