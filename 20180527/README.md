# 花椰菜到长城的距离
问: 从百度百科的[花椰菜页面](https://baike.baidu.com/item/花椰菜)开始,最少需要点几次鼠标能到达[长城页面](https://baike.baidu.com/item/长城/14251)
```bash
#!/bin/bash
cd "$(dirname "$0")"
# 花椰菜
echo '->%E8%8A%B1%E6%A4%B0%E8%8F%9C' > ./will.txt
echo -n > ./visited.txt 2> ./tmp.txt

while :; do
    while read l; do
        ll=$(echo $l | grep -oP '(?<=>)[^>]*$')
        # 长城
        [ "x$ll" = 'x%E9%95%BF%E5%9F%8E/14251' ] && { echo $l >&2; exit; }
        grep -xq "$ll" ./visited.txt && continue
        echo $ll >> ./visited.txt
        curl -sL 'https://baike.baidu.com/item/'"$ll" | grep -oP '(?<="/item/).*?(?="|\?|#)' | sed 's@^@'"$l->@"
    done >> ./tmp.txt < <(grep . ./will.txt)
    mv ./tmp.txt ./will.txt
done
```
简单写了个脚本验证了下,答案是2次  
第1次,从花椰菜到中国  
![](pic/1.png)  
第2次,从中国到长城  
![](pic/2.png)