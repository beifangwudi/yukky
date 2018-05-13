# 手机照片去重
有这么几种手机拍的照片混在一起,需要找出重复的或者相似度高的:
1. 源照片
2. 源照片被上传到社交平台,再下载下来(被裁减压缩)
3. 源照片被轻微涂鸦
4. 连拍的照片,每张都类似但不完全一样
5. 同一张自拍,换了造型和姿势,轻微调整了角度
6. 同一个地方的景色,上午去玩耍拍了张,晚上回来又拍了张
7. 拍的合同和文档,白底纯文字

等等.代码如下:
```python
#!/usr/bin/python3
# -*- coding:utf-8 -*-

from PIL import Image
import concurrent.futures, os, sys
os.chdir(sys.argv[1])
img_suf = ('.jpg', '.JPG', '.JPEG', '.jpeg', '.png', '.PNG')


# 计算图片的dHash
def dHash(path):
    print(f'Processing {path} ...')
    try:
        pixels = list(Image.open(path).resize((9, 8)).convert("L").getdata())
    except:
        return []

    res = []
    for row in range(8):
        for col in range(8):
            i = row * 9 + col
            res.append(pixels[i] > pixels[i + 1])
    return res


# 计算汉明距离
def Hamming(dHash1, dHash2):
    dis = 0
    for i in range(len(dHash1)):
        if dHash1[i] != dHash2[i]:
            dis += 1
    return dis


if __name__ == '__main__':
    imgs = [
        os.path.join(r, f) for r, _, fs in os.walk('.') for f in fs
        if os.path.splitext(f)[1] in img_suf
    ]
    # 并行计算图片dHash
    with concurrent.futures.ProcessPoolExecutor() as executor:
        pic = {i: d for i, d in zip(imgs, executor.map(dHash, imgs)) if d}

    while pic:
        image, image_dhash = pic.popitem()
        for image2, image2_dhash in pic.items():
            # 比较汉明距离
            if Hamming(image_dhash, image2_dhash) <= 5:
                print(f'{image} and {image2} are similar.')
```
一个参数,为存放图片的目录.