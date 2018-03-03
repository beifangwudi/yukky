# 注册表清理右键菜单
1. 删除资源管理器中的腾讯微云图标  
注册表删除`HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3B11AB24-9AF1-45f3-8998-9BCF061D13D8}`
2. 删除右键菜单的上传到腾讯微云  
在注册表`HKEY_CLASSES_ROOT`中搜索`DiskMenuShellEx`,删除找到的注册表项
3. 删除右键菜单的上传到百度云盘  
在注册表`HKEY_CLASSES_ROOT`中搜索`YunShellExt`,删除找到的注册表项
4. 删除右键菜单的`Open with Code`  
在注册表`HKEY_CURRENT_USER`中搜索`Open w&ith Code`,删除找到的注册表项