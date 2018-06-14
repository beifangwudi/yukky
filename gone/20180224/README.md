# 命运:冠位指定
### 前面
我从鬼岛入坑,700W下载弃坑,为了刷技能,用触动精灵写了个自动刷材料的脚本,没有做机型适配,分辨率只支持1920*1080,需要root.不支持多血条的识别,有些活动中关底BOSS血条特别长,也是不支持的.脚本主要用在借好友的打手单刷,或者是不能稳定3回合的补刀.
### 刷友情点
在说刷怪之前,先贴一段利用反复登录刷友情点的脚本.
```lua
init(0)
function sleep(t) mSleep(t*1000) end
function click(x,y) touchDown(x,y) sleep(0.05) touchUp(x,y) end

while 1 do
    r=runApp("com.bilibili.fatego")
    sleep(60)
    if r==0 then
        click(960,800)
        sleep(40)
        click(1867,52)
        sleep(60)
        closeApp("com.bilibili.fatego")
    end
    sleep(60)
end
```
大意就是启动fgo,如果启动成功就关闭情报页面,关闭友情点窗口,最后关闭fgo.  
### 代码分析
另附完整代码,这里只说大概的思路.
1. 进入游戏前
    ```lua
    -- 等待进入选关页面
    while not isColor(240,1047,0x9f6245,100) do
        ...省略...
    end
    -- 如果关卡出现红色,说明当前ap不够,自动吃金苹果,金苹果吃完吃石头.不吃银铜.
    if haveColor(1270,308,1319,345,0xe60000,100) then
        ...省略...
    end
    -- 选择好友,职介和排序要先预设好,这里只能选择第几位
    -- 只要好友少于12位,都可以选到
    selectSupport(1)
    ```
2. 游戏中  
    进入游戏后,要不右下角出现蓝色的"攻击"按钮,要不游戏结束出现"请点击画面"字样.
    ```lua
    -- 判断是否进入攻击按钮页面
    if isColor(1733,975,0x0069cc,90) and isColor(1715,818,0x00eafa,90) and isColor(1900,170,0x0040dc,100) and isColor(1318,38,0xffffff,100) then

        -- 只考虑小于等于3场的战斗,不是1不是3的都算2
        if isColor(1297,32,0xffffff,100) then
            new_battle=1
        elseif isColor(1297,32,0x636363,100) then
            new_battle=3
        else
            new_battle=2
        end
        
        -- 计算敌方hp和np.没有做ocr,所以hp用百分比表示,敌方np是按格算的,所以0格算0,满格算100,其它算50.
        -- 某敌方挂了hp和np都为-1.
        if isColor(125,80,0x514030,100) then
            m1Hp=readPercent(324,60)
            if isColor(228,120,0x646464,90) then
                m1Np=0
            elseif isColor(228,120,0xffce24,90) then
                m1Np=50
            elseif isColor(228,120,0xff5858,90) then
                m1Np=100
            else
                m1Np=-1
            end
        else
            m1Hp,m1Np=-1,-1
        end
        -- 3个敌人所以上面的步骤x3

        -- 判断卡牌颜色,通过攻击按钮上方的卡牌计算颜色,有时候被晕住会出现错误.
        -- 通过右上角的助战小字来区分助战.只能区分色卡和助战,并不能做到某张卡对应到的正确人.
        card={}
        if isColor(1492,863,0xc40000,90) then
            card[1]="red"
        elseif isColor(1503,872,0x003bcf,90) then
            card[1]="blue"
        elseif isColor(1503,858,0x01980c,90) then
            card[1]="green"
        else
            card[1]="unknown"
        end
        -- 5张卡,所以x5

        -- 计算我方hp和np.原理和敌方的差不多,都是计算百分比.其实如果是反复刷同一场,血量都是固定值,可以事先算好.
        -- 有一点不同,就是我方充能会到200%,甚至300%.这里没有做区分,凡是np满的统统记为101.我方如果有空位,该位的np和hp记为-1
        if isColor(301,951,0xf2f2f2,95) then
            s1Hp=readPercent(440,962)
            if not b1 or not b11 then
                s1Np=101
            else
                s1Np=readPercent(440,1018)
            end
        else
            s1Hp,s1Np=-1,-1
        end
        -- 以上x3

        -- 主函数,是我们自定义的地方.上面都是在收集界面数据,收集到之后在这里做判断
        -- 比如何时放技能,何时换人,点了攻击之后第几位放宝具等.
        main()
    -- 判断是否出现"请点击画面"字样,因为字一直在闪,所以判断依赖的点有些多.
    elseif (isColor(1462,1029,0x87773e,100) and isColor(1498,1032,0x8e8e8e,100) and isColor(1107,68,0xf7f7f7,100) and isColor(1318,38,0x8e8e8e,100)) or (isColor(1020,972,0xf7fcfd,99) and isColor(1021,972,0xffffff,100) and isColor(1024,972,0xffffff,100) and isColor(1025,972,0xeff5f8,99)) then
        -- 一直点某个坐标直到进入黑屏加载页面
        while not isColor(1020,972,0,100) do
            pp("waiting to end")
            click(1464,982)
            sleep(1)
        end
        break
    end
    ```
3. 一些函数的意思
    ```lua
    -- 暂停,以秒计
    sleep(t)
    -- 点击,左上角(0,0),右上角(1920,0),左下角(0,1080)
    click(x,y)
    -- 打印日志,调试用的,可以用adb来看,可以忽略
    pp(s)
    -- 原来有一个keepscreen的函数,我做了一些修改,可以忽略
    keepScreen(b)
    -- x,y是横坐标和纵坐标,c是颜色,s是精确度
    -- 意思就是判断x,y这个坐标的颜色是否是c,允许的误差不超过s
    -- 本来触动精灵是自带这个功能,但用起来有奇怪的bug,所以就自己实现了
    isColor(x,y,c,s)
    -- 判断某个区域是否有c这个颜色,允许误差s
    haveColor(x1,y1,x2,y2,c,s)
    -- 选择助战,1就是第1个,10就是第10个,超过3它会自己滑动
    selectSupport(n)
    -- 读hp和np用的
    -- 老实说精确度不怎么样,差2%左右,实际上hp和np数据很少能用到.因为可以用孔明精确充能.
    readPercent(x,y)
    -- 选牌算法
    -- 用起来看上去很复杂,其实原理很简单,比如这样
    -- selectCard("3,support,blue","3,support,green","2,support,green","1,any,blue")
    -- 意思是3号位先选择助战蓝卡,如果5张卡中没有助战蓝卡则将3号位空出,进行下一轮选择,如果有,则3号位不再选择
    -- 下一轮当中,如果还没有助战绿卡,则继续空出,再一轮给2号位选择助战绿卡,有则选,无则空
    -- 然后为1号位选任意从者的蓝卡,有蓝则入,无则空.
    -- 候选完成之后,将剩下的卡牌随机填充还空着的位置.
    -- 写得时候偷了懒,导致没办法自由选择3红3蓝等特殊顺序,也算是自食恶果.
    selectCard(...)
    ```

4. main函数  
    main是唯一需要自定义的部分.在main中,可以读取在游戏当中预设的所有变量和读取界面的数据.举个例子
    ```lua
    -- round是第几场,battle是每场的第几面,turn是每场的第几回合,turnInBattle是每面的第几回合
    -- 大王单刷枪阶修炼场,带1级炎头和乔老师
    function main()
        if turn==1 then                       -- 如果是第1回合
            click(580,866)                    -- 炎头2号位放嘲讽
            sleep(3.6)
        elseif turn==2 and s1Hp~=-1 then      -- 第2回合,如果1号位乔老师没挂,就放嘲讽
            click(104,866)
            sleep(3.6)
        elseif battle==3 and turnInBattle==1 then
            click(1060,866)                   -- 第3面第1回合,大王开3个技能
            sleep(3.6)
            click(1200,866)
            sleep(3.6)
            click(1340,866)
            sleep(3.6)

            click(1793,470)                   -- 放完技能后再放master衣服的第1个技能
            sleep(1)
            click(1359,467)
            sleep(3.6)
        end

        click(1733,975)                       -- 点击攻击
        sleep(1.5)

        -- 如果1号位的乔老师和2号位的炎头都挂了,而且到了第3面,大王的np也满了,那么
        if s1Hp==-1 and s2Hp==-1 and s3Np==101 and battle==3 then
            for i,v in ipairs(selectCard("3,support,red","2,support,red")) do
                sleep(0.5)                   -- 第1张卡大王宝具,2,3尽量为红色
                if i==1 then
                    click(600,300)
                else
                    click(400*v-200,800)
                end
            end
        else
            -- 如果上面的如果没成立,就按这个顺序来选卡
            for i,v in ipairs(selectCard("3,support,blue","1,support,red","3,support,any","2,support,any","1,any,red","1,any,blue")) do
                sleep(0.5)
                click(400*v-200,800)
            end
        end
    end
    ```
### 一些main的例子
1. 黑狗狩猎单刷肃正骑士
    ```lua
    function main()
        if turn==1 then
            click(580,866) -- 炎头嘲讽
            sleep(3.6)
        elseif turn==2 and s1Hp~=-1 then
            click(104,866) -- 乔老师嘲讽
            sleep(3.6)
        elseif battle==3 and turnInBattle==1 then
            click(423,64)
            sleep(1)

            click(1060,866)
            sleep(3.6)
            click(1200,866)
            sleep(3.6)
            click(1340,866)
            sleep(3.6)

            click(1793,470)
            sleep(1)
            click(1492,467) -- 主加攻
            sleep(1)
            if s1Hp==-1 and s2Hp==-1 then
                click(956,670)
            elseif s1Hp~=-1 and s2Hp~=-1 then
                click(1450,670)
            else
                click(1200,670)
            end
            sleep(3.6)
        end
        if tmp1~=round and s3Hp<=80 then
            tmp1=round
            click(1793,470)
            sleep(1)
            click(1359,467) -- 主加血
            sleep(1)
            if s1Hp==-1 and s2Hp==-1 then
                click(956,670)
            elseif s1Hp~=-1 and s2Hp~=-1 then
                click(1450,670)
            else
                click(1200,670)
            end
            sleep(3.6)
        end
        if tmp2~=round and not (battle==3 and turnInBattle==1) and (
                m1Hp*m2Hp*m3Hp~=m1Hp+m2Hp+m3Hp+2 and s1Hp==-1 and (s3Np~=101 or battle==1 or s2Hp~=-1)
            ) then
            tmp2=round
            click(1793,470)
            sleep(1)
            click(1625,467) -- 主闪避
            sleep(1)
            if s1Hp==-1 and s2Hp==-1 then
                click(956,670)
            elseif s1Hp~=-1 and s2Hp~=-1 then
                click(1450,670)
            else
                click(1200,670)
            end
            sleep(3.6)
        end

        click(1733,975)
        sleep(1.5)

        if s1Hp==-1 and s2Hp==-1 then
            if s3Np==101 then
                if battle==2 then
                    for i,v in ipairs(selectCard("1,support,red","2,support,red")) do
                        sleep(0.5)
                        if i==3 then
                            click(600,300)
                        else
                            click(400*v-200,800)
                        end
                    end
                elseif battle==3 then
                    for i,v in ipairs(selectCard("3,support,red","2,support,red")) do
                        sleep(0.5)
                        if i==1 then
                            click(600,300)
                        else
                            click(400*v-200,800)
                        end
                    end
                else
                    for i,v in ipairs(selectCard("1,support,red","2,support,red","3,support,red")) do
                        sleep(0.5)
                        click(400*v-200,800)
                    end
                end
            else
                if battle==3 then
                    for i,v in ipairs(selectCard("1,support,red","2,support,red","3,support,red")) do
                        sleep(0.5)
                        click(400*v-200,800)
                    end
                else
                    for i,v in ipairs(selectCard("1,support,red","2,support,green","3,support,blue")) do
                        sleep(0.5)
                        click(400*v-200,800)
                    end
                end
            end
        else
            for i,v in ipairs(selectCard("3,support,blue","3,support,red","3,support,green","1,support,red","2,support,any","1,support,any","1,any,blue")) do
                sleep(0.5)
                click(400*v-200,800)
            end
        end
    end
    ```
2. 船长单刷qp
    ```lua
    function main()
    -- 技能:104/244/384-580/720/860-1060/1200/1340,866
    -- 对方位置:65/423/781,64
        if turn==1 then
            click(580,866) -- 炎头嘲讽
            sleep(3.6)
        end
        if turn==2 and s1Hp~=-1 then
            click(104,866) -- 乔老师嘲讽
            sleep(3.6)
        end
        if battle==3 and turnInBattle==1 then
            click(1793,470)
            sleep(1)
            click(1625,467) -- 主闪避
            sleep(1)
            if s1Hp==-1 and s2Hp==-1 then
                click(956,670)
            elseif s1Hp~=-1 and s2Hp~=-1 then
                click(1450,670)
            else
                click(1200,670)
            end
            sleep(3.6)
        end
        if tmp1~=round and s3Hp<=70 then
            tmp1=round
            click(1793,470)
            sleep(1)
            click(1359,467) -- 主加血
            sleep(1)
            if s1Hp==-1 and s2Hp==-1 then
                click(956,670)
            elseif s1Hp~=-1 and s2Hp~=-1 then
                click(1450,670)
            else
                click(1200,670)
            end
            sleep(3.6)
        end

        click(1733,975)
        sleep(1.5)

        if s1Hp==-1 and s2Hp==-1 then
            for i,v in ipairs(selectCard("1,support,red","2,support,green","3,support,red")) do
                sleep(0.5)
                click(400*v-200,800)
            end
        else
            for i,v in ipairs(selectCard("1,support,red","3,support,red","1,support,any","2,support,any","3,support,any")) do
                sleep(0.5)
                click(400*v-200,800)
            end
        end
    end
    ```
3. 灭世三红
    ```lua
    function main()
        click(1733,975)
        sleep(1.5)
        for i,v in ipairs(selectCard("1,any,red","3,any,red","2,any,red")) do
            sleep(0.5)
            click(400*v-200,800)
        end
    end
    ```
4. 杰克单数骑阶修炼场
    ```lua
    function main()
    -- 技能:104/244/384-580/720/860-1060/1200/1340,866
    -- 对方位置:65/423/781,64
        if turn==1 then
            click(580,866) -- 炎头嘲讽
            sleep(3.6)
        end
        if turn==2 and s1Hp~=-1 then
            click(104,866) -- 乔老师嘲讽
            sleep(3.6)
        end
        if battle==3 and turnInBattle==1 then
            click(1060,866)
            sleep(3.6)
            click(1200,866)
            sleep(3.6)
        end
        if tmp1~=round and s3Hp<=70 then
            tmp1=round
            click(1340,866)
            sleep(1)
            if s1Hp==-1 and s2Hp==-1 then
                click(956,670)
            elseif s1Hp~=-1 and s2Hp~=-1 then
                click(1450,670)
            else
                click(1200,670)
            end
            sleep(3.6)
        end

        click(1733,975)
        sleep(1.5)

        if s1Hp==-1 and s2Hp==-1 and s3Np==101 and battle==3 then
            for i,v in ipairs(selectCard("3,support,green","2,support,green")) do
                sleep(0.5)
                if i==1 then
                    click(600,300)
                else
                    click(400*v-200,800)
                end
            end
        else
            for i,v in ipairs(selectCard("3,support,green","2,support,green","1,support,green","1,support,red","1,support,blue","2,support,any","3,support,any")) do
                sleep(0.5)
                click(400*v-200,800)
            end
        end
    end
    ```
### 完整代码
```lua
init(0)
-- mSleep,touchDown,touchUp,touchMove,sysLog,getColorRGB,keepScreen
function sleep(t) mSleep(t*1000) end
function click(x,y) touchDown(x,y) sleep(0.05) touchUp(x,y) end
function pp(s) sysLog("fgo_solo~"..s) end
old_keepScreen,if_keepScreen=keepScreen,0
function keepScreen(b)
    -- 确保嵌套的keepScreen工作正常
    if b then
        if_keepScreen=if_keepScreen+1
        if if_keepScreen==1 then
            old_keepScreen(true)
        end
    else
        if_keepScreen=if_keepScreen-1
        if if_keepScreen==0 then
            old_keepScreen(false)
        end
    end
end
function isColor(x,y,c,s)
    s=math.floor(0xff*(100-s)*0.01)
    local r1,g1,b1=math.floor(c/0x10000),math.floor(c%0x10000/0x100),c%0x100
    local r2,g2,b2=getColorRGB(x,y)
    if math.abs(r1-r2)<=s and math.abs(g1-g2)<=s and math.abs(b1-b2)<=s then
        return true
    end
end
function haveColor(x1,y1,x2,y2,c,s)
    keepScreen(true)
    -- 若s>0,找到符合要求的一个点就返回true
    -- 否则,必须所有点都符合才返回true
    if s>0 then
        for x=x1,x2 do
            for y=y1,y2 do
                if isColor(x,y,c,s) then
                    keepScreen(false)
                    return true
                end
            end
        end
        keepScreen(false)
        return false
    else
        for x=x1,x2 do
            for y=y1,y2 do
                if not isColor(x,y,c,-s) then
                    keepScreen(false)
                    return false
                end
            end
        end
        keepScreen(false)
        return true
    end
end
function selectSupport(n)
    for i=1,math.floor((n-1)/3) do
        touchDown(1200,1000)
        for j=50,900,50 do
            touchMove(1200,1000-j)
            sleep(0.01)
        end
        sleep(0.8)
        touchUp(1200,100)
        sleep(0.8)
    end
    click(1200,400+(n-1)%3*300)
end
function readPercent(x,y)
    -- 略有误差
    keepScreen(true)
    for i=x,x-199,-1 do
        local r,g,b=getColorRGB(i,y)
        if r>150 or b>176 then
            keepScreen(false)
            return (200+i-x)/2
        end
    end
    keepScreen(false)
    return 0
end
function selectCard(...)
    -- 从给定的五张卡牌中选择符合要求的卡牌
    -- 像这样调用,selectCard("3,support,blue","3,support,green","2,support,green","1,any,blue","1,any,green")
    -- 意思是:最高优先级在3号位上选择助战的蓝卡,其次是3号位上助战的绿卡,再次是2号位上助战的绿卡,再再次是1号位任意的蓝卡,最后是1号位任意绿卡
    local tmpCard,result,args={},{-1,-1,-1},{...}
    for i,v in ipairs(card) do tmpCard[i]=v end
    for i=3,1,-1 do table.insert(args,i..",any,any") end

    local tmp,s2,s3
    for i,v in ipairs(args) do
        tmp={}
        for j in string.gmatch(v,"[^,]+") do
            table.insert(tmp,j)
        end
        tmp[1]=tonumber(tmp[1])
        if result[tmp[1]]==-1 then
            if tmp[2]=="any" then
                s2={"support","normal"}
            else
                s2={tmp[2]}
            end
            if tmp[3]=="any" then
                s3={"red","blue","green"}
            else
                s3={tmp[3]}
            end
            for a,b in ipairs(s3) do
                for c,d in ipairs(s2) do
                    for e,f in ipairs(tmpCard) do
                        if f==b..","..d then
                            result[tmp[1]]=e
                            tmpCard[e]="unkown,unkown"
                            goto afterloop
                        end
                    end
                end
            end
            ::afterloop::
        end
    end

    for i,v in ipairs(result) do
        if v==-1 then
            return {1,2,3}
        end
    end
    return result
end

-- round,battle,turn,turnInBattle
-- m1Hp,m2Hp,m3Hp,m1Np,m2Np,m3Np
-- s1Hp,s2Hp,s3Hp,s1Np,s2Np,s3Np
-- card[1],card[2],card[3],card[4],card[5]
function main()
-- 技能:104/244/384-580/720/860-1060/1200/1340,866
-- 对方位置:65/423/781,64
-- 技能对象:500/960/1420,650
-- 御主技能:1793,470/1359,1492,1625,467
    if battle==1 and turnInBattle==1 then
        click(384,866)
        sleep(3.6)

        click(1733,975)
        sleep(2)
        click(600,300)
        sleep(0.5)
        click(200,800)
        sleep(0.5)
        click(600,800)
    elseif battle==2 and turnInBattle==1 then
        click(384,866)
        sleep(3.6)
        click(860,866)
        sleep(3.6)
        click(104,866)
        sleep(1)
        click(1420,650)
        sleep(3.6)

        click(1733,975)
        sleep(2)
        click(1300,300)
        sleep(0.5)
        click(200,800)
        sleep(0.5)
        click(600,800)
    elseif battle==3 and turnInBattle==1 then
        click(244,866)
        sleep(3.6)
        click(720,866)
        sleep(3.6)
        click(580,866)
        sleep(1)
        click(1420,650)
        sleep(3.6)
        click(1060,866)
        sleep(3.6)
        click(1340,866)
        sleep(3.6)

        click(1733,975)
        sleep(2)
        click(1300,300)
        sleep(0.5)
        click(200,800)
        sleep(0.5)
        click(600,800)
    else
        click(1733,975)
        sleep(1.5)
        for i,v in ipairs(selectCard("1,any,red","3,any,red","2,any,red")) do
            sleep(0.5)
            click(400*v-200,800)
        end
    end
end


round=0
while 1 do
    round=round+1
    while not isColor(240,1047,0x9f6245,100) do
        sleep(2)
        pp("waiting to start")
        if isColor(240,1047,0x124ca7,100) then
            click(1464,982)
        end
    end
    pp("round "..round)
    if haveColor(1270,308,1319,345,0xe60000,100) then
        pp("ap not enough")
        click(249,1042)
        sleep(2)
        if isColor(1000,420,0xf1e9d8,100) then
            pp("eat apple")
            click(1000,420)
         elseif isColor(1000,200,0xf1e9d8,100) then
            pp("eat stone")
            click(1000,200)
        else
            pp("no food, exit")
            lua_exit()
        end
        sleep(2)
        click(1200,840)
        sleep(2)
    end
    click(1495,325)
    sleep(2)
    selectSupport(1)
    sleep(2)
    click(1800,1000)

    battle,turn=0,0
    while 1 do
        -- 判断是否进入attack页面
        if isColor(1733,975,0x0069cc,90) and isColor(1715,818,0x00eafa,90) and isColor(1900,170,0x0040dc,100) and isColor(1318,38,0xffffff,100) then

            b1=isColor(301,1029,0xa29a92,100)
            b2=isColor(777,1029,0xa29a92,100)
            b3=isColor(1256,1029,0xa29a92,100)
            sleep(0.5)
            b11=isColor(301,1029,0xa29a92,100)
            b22=isColor(777,1029,0xa29a92,100)
            b33=isColor(1256,1029,0xa29a92,100)

            keepScreen(true)
            turn=turn+1
            -- 只考虑最多只有3场的战斗
            if isColor(1297,32,0xffffff,100) then
                new_battle=1
            elseif isColor(1297,32,0x636363,100) then
                new_battle=3
            else
                new_battle=2
            end
            if new_battle==battle then
                turnInBattle=turnInBattle+1
            else
                battle=new_battle
                turnInBattle=1
            end
            pp("into battle "..battle.." turn "..turnInBattle.." total "..turn)

            -- 计算敌方hp和np
            if isColor(125,80,0x514030,100) then
                m1Hp=readPercent(324,60) -- 怪1的HP
                if isColor(228,120,0x646464,90) then
                    m1Np=0
                elseif isColor(228,120,0xffce24,90) then
                    m1Np=50
                elseif isColor(228,120,0xff5858,90) then
                    m1Np=100
                else
                    m1Np=-1
                end
            else
                m1Hp,m1Np=-1,-1
            end
            if isColor(487,80,0x514030,100) then
                m2Hp=readPercent(686,60) -- 怪2的HP
                if isColor(590,120,0x646464,90) then
                    m2Np=0
                elseif isColor(590,120,0xffce24,90) then
                    m2Np=50
                elseif isColor(590,120,0xff5858,90) then
                    m2Np=100
                else
                    m2Np=-1
                end
            else
                m2Hp,m2Np=-1,-1
            end
            if isColor(845,80,0x514030,100) then
                m3Hp=readPercent(1044,60) -- 怪3的HP
                if isColor(948,120,0x646464,90) then
                    m3Np=0
                elseif isColor(948,120,0xffce24,90) then
                    m3Np=50
                elseif isColor(948,120,0xff5858,90) then
                    m3Np=100
                else
                    m3Np=-1
                end
            else
                m3Hp,m3Np=-1,-1
            end
            pp("MHP:"..m1Hp..","..m2Hp..","..m3Hp)
            pp("MNP:"..m1Np..","..m2Np..","..m3Np)

            -- 判断从者的卡牌
            card={}
            if isColor(1492,863,0xc40000,90) then
                card[1]="red"
            elseif isColor(1503,872,0x003bcf,90) then
                card[1]="blue"
            elseif isColor(1503,858,0x01980c,90) then
                card[1]="green"
            else
                card[1]="unknown"
            end
            if haveColor(1457,772,1468,780,0xffffff,-90) then
                card[1]=card[1]..",support"
            else
                card[1]=card[1]..",normal"
            end
            if isColor(1541,772,0xf20000,90) then
                card[2]="red"
            elseif isColor(1538,786,0x003bcf,90) then
                card[2]="blue"
            elseif isColor(1542,772,0x00940a,90) then
                card[2]="green"
            else
                card[2]="unknown"
            end
            if haveColor(1532,679,1544,685,0xffffff,-90) then
                card[2]=card[2]..",support"
            else
                card[2]=card[2]..",normal"
            end
            if isColor(1600,718,0xc40000,90) then
                card[3]="red"
            elseif isColor(1603,733,0x004ffb,90) then
                card[3]="blue"
            elseif isColor(1604,721,0x019a12,90) then
                card[3]="green"
            else
                card[3]="unknown"
            end
            if haveColor(1633,628,1641,640,0xffffff,-90) then
                card[3]=card[3]..",support"
            else
                card[3]=card[3]..",normal"
            end
            if isColor(1688,695,0xd00202,90) then
                card[4]="red"
            elseif isColor(1679,705,0x0146da,90) then
                card[4]="blue"
            elseif isColor(1693,700,0x08a316,90) then
                card[4]="green"
            else
                card[4]="unknown"
            end
            if haveColor(1753,629,1760,640,0xffffff,-90) then
                card[4]=card[4]..",support"
            else
                card[4]=card[4]..",normal"
            end
            if isColor(1779,700,0xc40000,90) then
                card[5]="red"
            elseif isColor(1770,709,0x0041d5,90) then
                card[5]="blue"
            elseif isColor(1783,709,0x019a16,90) then
                card[5]="green"
            else
                card[5]="unknown"
            end
            if haveColor(1863,669,1871,680,0xffffff,-90) then
                card[5]=card[5]..",support"
            else
                card[5]=card[5]..",normal"
            end
            pp("card:"..card[1].."/"..card[2].."/"..card[3].."/"..card[4].."/"..card[5])

            -- 计算我方hp和np
            if isColor(301,951,0xf2f2f2,95) then
                s1Hp=readPercent(440,962) -- 从者1的HP
                if not b1 or not b11 then
                    s1Np=101
                else
                    s1Np=readPercent(440,1018) -- 从者1的NP
                end
            else
                s1Hp,s1Np=-1,-1
            end
            if isColor(777,951,0xf2f2f2,95) then
                s2Hp=readPercent(916,962) -- 从者2的HP
                if not b2 or not b22 then
                    s2Np=101
                else
                    s2Np=readPercent(916,1018) -- 从者2的NP
                end
            else
                s2Hp,s2Np=-1,-1
            end
            if isColor(1256,951,0xf2f2f2,95) then
                s3Hp=readPercent(1395,962) -- 从者3的HP
                if not b3 or not b33 then
                    s3Np=101
                else
                    s3Np=readPercent(1395,1018) -- 从者3的NP
                end
            else
                s3Hp,s3Np=-1,-1
            end
            pp("HP:"..s1Hp..","..s2Hp..","..s3Hp)
            pp("NP:"..s1Np..","..s2Np..","..s3Np)
            keepScreen(false)

            main()
        -- 判断是否出现"请点击画面"字样
        elseif (isColor(1462,1029,0x87773e,100) and isColor(1498,1032,0x8e8e8e,100) and isColor(1107,68,0xf7f7f7,100) and isColor(1318,38,0x8e8e8e,100)) or (isColor(1020,972,0xf7fcfd,99) and isColor(1021,972,0xffffff,100) and isColor(1024,972,0xffffff,100) and isColor(1025,972,0xeff5f8,99)) then
            while not isColor(1020,972,0,100) do
                pp("waiting to end")
                click(1464,982)
                sleep(1)
            end
            break
        end
        pp("==========split==========")
        sleep(1)
    end
end
```
本篇不再维护