# 删除重复文件
```bash
#!/bin/bash
declare -A a
find "$1" -type f | while read l; do
    md5=$(md5sum "$l" | cut -d' ' -f1)
    [ "x${a[$md5]}" = 'x' ] && a[$md5]=1 || rm -fv "$l"
done
```