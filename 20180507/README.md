# 手机照片再去重
用dHash去重图片效果不理想,所以用sift算法重写了一遍.参考了OpenCV文档的[示例代码](https://docs.opencv.org/3.0-beta/doc/py_tutorials/py_feature2d/py_matcher/py_matcher.html),用`pip install opencv-contrib-python`安装
```python
#!/usr/bin/python3
# -*- coding:utf-8 -*-

from cv2 import cv2
import os, sys, concurrent.futures
os.chdir(sys.argv[1])
sift = cv2.xfeatures2d.SIFT_create()
matcher = cv2.FlannBasedMatcher(dict(algorithm=0, trees=5), {})


# 计算sift
def calc_sift(image):
    return sift.detectAndCompute(
        cv2.cvtColor(cv2.imread(image), cv2.COLOR_BGR2GRAY), None)[1]


# 匹配sift,传入二元tuple
def match_sift(ds):
    matches = matcher.knnMatch(ds[0], ds[1], k=2)
    good = [m for m, n in matches if m.distance < 0.7 * n.distance]
    return len(good), len(matches)


if __name__ == '__main__':
    imgs = [
        os.path.join(r, f) for r, _, fs in os.walk('.') for f in fs
        if os.path.splitext(f)[1] in ('.jpg', '.JPG', '.JPEG', '.jpeg', '.png',
                                      '.PNG')
    ]
    # 并行计算图片sift
    with concurrent.futures.ProcessPoolExecutor() as executor:
        pic_ds = {i: d for i, d in zip(imgs, executor.map(calc_sift, imgs))}

    # 图片分组对比
    imgt = []
    while imgs:
        img1 = imgs.pop()
        for img2 in imgs:
            imgt.append((img1, img2))
    # 并行匹配
    with concurrent.futures.ProcessPoolExecutor() as executor:
        pic = [(img1, img2, good, matches)
               for (img1, img2), (good, matches) in zip(
                   imgt,
                   executor.map(match_sift,
                                map(lambda x: (pic_ds[x[0]], pic_ds[x[1]]),
                                    imgt))) if good / matches > 0.1]
    # 到0.1说明已经比较相似了,虽然我不知道有没有标准值

    for img1, img2, good, matches in pic:
        print(f'{img1} + {img2} = {good}/{matches}')
```