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