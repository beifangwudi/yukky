# crond的前端
在一些Linux系统上,crond是周期执行命令的守护进程,通过crontab来配置,但只能根据`分,时,日,月,星`5个条件,如果遇到以下几种情况:
1. 每73分钟执行一次
2. 根据某个命令的返回值
3. 开机10分钟后

则无法直接达成目的,需要绕一个圈子.像这样:
1. `* * * * * /usr/bin/awk 'BEGIN{if(int(systime()/60)%73!=0) exit 1}' && echo 'run'`
2. `* * * * * /run/test.sh && echo 'run'`
3. `* * * * * /usr/bin/awk 'BEGIN{if(int(systime()/60)-int('"$(date -d "$(uptime -s)" +%s)"'/60)!=10) exit 1}' && echo 'run'`

遇到再复杂一些的,可读性很差,所以我写了个脚本,可以将以下形式的配置文件,转换成上面这种:
```json
[
    {
        "will_execute": "echo 'run'",
        "if_command_true": [
            "/run/test.sh"
        ]
    },
    {
        "will_execute": "echo 'run'",
        "if_time_true": [
            "minute == 15",
            "hour >= 21 or hour <= 7",
            "week == 6 or week == 0"
        ]
    },
    {
        "will_execute": "systemctl reboot",
        "if_time_true": [
            "timestamp % 100 == 0"
        ],
        "if_command_true": [
            "! /run/test2.sh"
        ]
    }
]
```
1. 每分钟执行一遍`/run/test.sh`,返回值为0则执行`echo 'run'`
2. 每周六周日晚上9点到早上7点间的每小时的15分执行`echo 'run'`
3. 每100分钟执行一次`/run/test2.sh`,如果返回值不为0则重启

代码如下
```bash
#!/bin/bash
cd "$(dirname "$0")"
hash jq &> /dev/null || { echo 'need jq'; exit 1; }
hash awk &> /dev/null || { echo 'need awk'; exit 1; }
hash sed &> /dev/null || { echo 'need sed'; exit 1; }

echo 'SHELL=/bin/bash'
echo 'PATH='$PATH

jq -cr .[] ./config.json | while read l; do
    will_execute=$(echo $l | jq -cr .will_execute)
    if_time_true=$(echo $l | jq -cr .if_time_true)
    if_command_true=$(echo $l | jq -cr .if_command_true)

    # 构造awk表达式
    cmd='* * * * * root awk '"'"'BEGIN{'
    cmd+='t=systime();'
    cmd+='minute=int(strftime("%M",t));'
    cmd+='hour=int(strftime("%H",t));'
    cmd+='day=int(strftime("%d",t));'
    cmd+='month=int(strftime("%m",t));'
    cmd+='week=int(strftime("%w",t));'
    cmd+='timestamp=int(t/60);'
    # cmd+='uptime=int('"'"'"$(uptime -p | sed s/[^0-9]//g)"'"'"'/60);'
    cmd+='uptime=timestamp-int('"'"'"$(date -d "$(uptime -s)" +%s)"'"'"'/60);'
    cmd+='if('

    cmd+=$(echo $if_time_true | jq -cr .[] 2> /dev/null | while read ll; do
        # 替换为逻辑运算符
        ll=$(echo $ll | sed 's/and/\&\&/g;s/or/||/g')
        echo -n "($ll) && "
    done)
    cmd+=$(echo $if_command_true | jq -cr .[] 2> /dev/null | while read ll; do
        # 执行系统命令
        echo -n 'system("'"$ll"'") && '
    done)

    cmd+='1){exit 0;}else{exit 1;}}'"'"
    cmd+=' && '"$will_execute"
    echo "$cmd"
done
```
代码很简单,不多说,要注意的是,最好在要运行命令的机器上运行,否则PATH会不准确.  
本篇不再维护