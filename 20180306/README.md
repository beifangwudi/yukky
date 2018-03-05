# 用Python取代AutoHotkey
### 前面
对我来说,键盘上最没用的键就是`CapsLock`,占着最好的地方,还那么大一个,我打算用[AutoHotkey](http://ahkcn.github.io/docs/AutoHotkey.htm)给它加点功能.
### SYSTEM权限
Windows上可以用[PsExec](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec)取得系统最高的SYSTEM权限
```powershell
.\PsExec.exe -i -d -s -accepteula powershell
```
目标是按`CapsLock + C`来运行这个命令
```autohotkey
; 不显示托盘图标
#NoTrayIcon
; 只允许一个实例运行
#singleinstance force
; 关闭capslock
setcapslockstate,alwaysoff
; Caps Lock + C
capslock & c::run c:\bin\pstools\psexec.exe -i -s -accepteula powershell,,hide
```
代码存为`caps.ahk`,这里存在一个权限的问题,普通用户运行脚本后快捷键无法在以SYSTEM和管理员身份运行的窗口上生效,因为监听快捷键需要在键盘上挂钩子,而权限不够不能成功,所以也要用psexec启动它.
```powershell
c:\bin\pstools\psexec.exe -i -d -s -accepteula "C:\Program Files\AutoHotkey\AutoHotkey.exe" c:\bin\caps.ahk
```
将以上命令行加入计划任务,用户登录的时候运行.
### 被使用的文件
Windows有一个很让人惆怅的地方,删除文件时被告知无法删除,但又不说是谁在使用,Windows 10上有所改善,但仍然存在.所以目标就是设置快捷键`CapsLock + D`,选中文件后按下,告诉我文件在被哪个进程使用.参考了[这里](https://autohotkey.com/board/topic/60985-get-paths-of-selected-items-in-an-explorer-window/)的脚本来获得选中文件的路径,用[handle](https://docs.microsoft.com/zh-cn/sysinternals/downloads/handle)来获取打开文件的进程.
```autohotkey
capslock & d::
    res=
    my_desktop:=a_desktop?a_desktop:"C:\Users\gushi\Desktop"
    winget,process,processname,% "ahk_id" hwnd:=winexist("a")
    wingetclass,class,% "ahk_id" hwnd
    if(process="explorer.exe"){
        if(class~="Progman|WorkerW"){
            controlget,files,list,selected col1,syslistview321,% "ahk_class" class
            loop,parse,files,`n,`r
                res.=my_desktop "\" a_loopfield "`n"
        }else if(class~="(Cabinet|Explore)WClass"){
            for w in comobjcreate("shell.application").windows
                if (w.hwnd==hwnd)
                    for i in w.document.selecteditems
                        res.=i.path "`n"
        }
    }else{
        tmpclip:=clipboardall
        clipboard=
        send ^c
        ; clipwait,0.1,1
        res:=clipboard
        clipboard:=tmpclip
        tmpclip=
    }
    res:=trim(res,"`n")

    if(res==""){
        msgbox,% "can not get file"
        return
    }

    tmpfile:= % a_temp "\i_cant_at_" a_now ".txt"
    loop,parse,res,`n
        if fileexist(a_loopfield){
            runwait,%comspec% /c C:\bin\handle.exe -accepteula -nobanner %a_loopfield% | findstr "pid:" >> %tmpfile%,,hide
        }else{
            msgbox,% "can not get file"
            return
        }
    fileread,res,% tmpfile
    filedelete,% tmpfile
    res:=regexreplace(res,"(`r?`n)+","`n")

    if(res==""){
        msgbox,% "not in use"
    }else{
        gui,new
        gui,add,text,,% res
        gui,show
    }
return
```
先获得当前活动窗口的id和class,判断是桌面还是资源管理器,然后调用相关函数取得被选中文件路径,如果都不是则发送`Ctrl + C`将文件路径复制到剪贴板来间接获取.获取到路径之后判断获取是否成功以及文件是否存在,最后调用`handle`命令将文件的使用情况存放到临时文件汇总输出.  
如果将这段代码附到`caps.ahk`后面,即以SYSTEM权限运行,那么需要修改第3行的my_desktop,将行尾的字符串改成自己的桌面的路径,因为SYSTEM用户获取桌面路径的方式很复杂,我直接硬编码了.对于资源管理器中的几乎所有文件,都能正确获取到路径,其它的随缘.handle命令有个奇怪的行为,如果以普通权限运行会很慢,而以SYSTEM权限就快很多. 
### 取而代之
AutoHotkey主要用于处理Windows系统上的自动化和快捷键,但不够通用,不如PowerShell背靠.NET大树,也不如Python无比丰富的第三方库.如果Python能够很方便的注册快捷键,就可以大体上取代AutoHotkey.
```python
import keyboard
from subprocess import Popen

# 关闭CapsLock,有bug
keyboard.add_hotkey('caps lock+x', lambda: True, suppress=True)
# 按下CapsLock + x启动记事本,要异步
keyboard.add_hotkey('caps lock+x', lambda: Popen(['notepad.exe']), suppress=True)

keyboard.wait()
```
[这里](https://github.com/boppreh/keyboard)有更详细的文档,就快捷键而言,Python没有AutoHotkey来得优雅,但做为万能胶水,只要能实现80%的功能,就已经足够使用了.  
严格来讲,AutoHotkey的近亲[AutoIt](https://www.autoitscript.com/)更擅长自动化,但Python的[PyAutoGUI](https://github.com/asweigart/pyautogui)集AutoIt和Sikuli之长,[这里](https://muxuezi.github.io/posts/doc-pyautogui.html)有详细的中文文档.如果需要使用一些特殊功能,比如给隐藏窗口发送键盘鼠标消息,可以使用相应的win32库.