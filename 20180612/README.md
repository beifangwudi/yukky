# Javascript检测Selenium.webdriver
* 环境: Windows 10 Pro 1803
* Chrome版本: 版本 66.0.3359.170（正式版本） （64 位）
* chromedriver版本: [2.38](http://npm.taobao.org/mirrors/chromedriver/2.38/chromedriver_win32.zip)
* Selenium: 3.12.0

分别用webdriver和手动打开网页`test.html`
```html
<script>
    setTimeout(function () {
        if ('$cdc_asdjflasutopfhvcZLmcfl_' in document)
            document.write('webdriver detected')
        else
            document.write('not detected')
    }, 1000)
</script>
```
可以看到,顺利检测出了webdriver.可以通过替换chromedriver里的字符串来绕过检测
```python
with open('./chromedriver.exe', 'rb') as f:
    x = f.read().replace(b'$cdc_asdjflasutopfhvcZLmcfl_',
                         b'ahahahahahahahahahahahahaha_')
    with open('./chromedriver.exe.new', 'wb') as f2:
        f2.write(x)
```
用生成的`chromedriver.exe.new`覆盖掉`chromedriver.exe`即可.[参考](https://stackoverflow.com/questions/33225947/can-a-website-detect-when-you-are-using-selenium-with-chromedriver).