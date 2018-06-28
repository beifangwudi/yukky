# 改善视力
```html
<style>
    html,
    body {
        overflow: hidden;
    }
</style>
<canvas id="c"></canvas>
<script>
    cw = document.body.clientWidth
    ch = document.body.clientHeight
    canvas = document.getElementById("c")
    canvas.width = cw
    canvas.height = ch
    c = canvas.getContext("2d")

    function draw_circle(x, y, radius, color) {
        c.beginPath()
        c.arc(x, y, radius, 0, 360)
        c.fillStyle = color
        c.fill()
        c.closePath()
    }

    t1 = Date.now()
    setInterval(function () {
        c.clearRect(0, 0, cw, ch)
        dd = (Math.cos((Date.now() - t1) / 10000) * 50 + 150)
        draw_circle(cw / 2 - dd, ch / 2, 20, "red")
        draw_circle(cw / 2 + dd, ch / 2, 20, "red")
    }, 50)
</script>
```
一个基于canvas的小程序,画了两个圆,缓慢的靠近和远离,需要通过调整双眼的晶状体将两个圆重合.  
可以自行修改`dd`中最后的50和150来改变圆的距离.每小时使用5-10分钟.