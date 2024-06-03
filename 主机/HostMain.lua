--计算反正切函数
function arctan(x)
    return 0.5*math.atan(2*x,1-x*x)
end

--(自定义主机协议(频道)名称为lunatic)lunatic是主机的协议(频道)    
--rednet.host（协议，主机名）
rednet.host("lunatic","Host")

--(自定义协议名称为EEE)EEE是发送信息的协议,只接受EEE协议发送的信息，其他的都过滤
--receive方法自带暂停，没有接收到消息时，receive下面的语句都不运行
local protocol="EEE"

--方位变量
local side="left"

rednet.open(side)

--x,y,z坐标
local x = 0.12121212
local y=0.12121212
local z=0.12121212

--记录发送给主机消息的客机id
local id=0
local id_1=0
local id_2=0

--接收到发送消息协议也为“EEE”的客机消息，
--并且x的值被改变就跳出repeat
--其实可以把until条件改为指定客机id，那就是只接收某个客机的消息才跳出repeat
repeat 
    id,x = rednet.receive(protocol)
    id,y = rednet.receive(protocol)
    id,z = rednet.receive(protocol)
until x ~= 0.12121212

--发送消息给3号电脑，使用protocol="EEE"的协议
rednet.send(3,"align2",protocol)

--纪录此主机的x,y,z坐标分别为px,py,pz
local px = 0
local py = 0
local pz = 0

px,py,pz = gps.locate()

if (px==x)and(py==y)and(pz==z) then
    rednet.send(3,"2Aligned")
end

local rx = 0
local ry =0
local rz =0

 while true do

    --在while循环体外定义的rx ry rz,对于整个HostMain.lua这个文件来说就是全局变量，
    --如果这些全局变量不加locate，意思就是整个windows操作系统都能调用,其他lua文件也能调用
    --lua语言默认变量是全局变量，所以得加locate来限制作用域，限制在只在此HostMain.lua中生效
    --所以在while循环体中不需要再次定义
    --rx,ry,rz = 0
    --不相信的话我们print打印看结果
    print(("rx=%d,ry=%d,rz=%d"):format(rx,ry,rz))

    --一样的道理，其实就是全局变量的作用域问题
    --px,py,pz可以直接使用在循环体外定义的并且值也是主机坐标，不需要在循环体内再次定义
    --px,py,pz = gps.locate()
    --不相信的话我们print打印看结果
    print(("px=%d,py=%d,pz=%d"):format(px,py,pz))--主机坐标

    sleep(0.01)

    rx,ry,rz = gps.locate()--rx,ry,rz存放主机坐标

    --****注意以下在while循环体定义的变量****--
    --vx,vz,gs,adirualt,cs,vs,pitch,xleft,yright,roll
    --这些就叫做局部变量，只能在while循环体内使用，也就是作用域只在while循环体内
    --出了while循环体这些局部变量就会被销毁
    --建议还是加上locate让这些循环体内变量就只在循环体内生效
    local vx = math.abs((rx-px)/0.01)
    local vz = math.abs((rz-pz)/0.01)
    local gs = math.sqrt(vx*vx+vz*vz)
    
    local adirualt = ry

    local cs = math.abs((ry-pz)/0.01)
    local vs = math.sqrt(gs*gs+cs*cs)
    local pitch = arctan(cs/gs)

    local xleft =0
    local yleft =0
    local xright =0
    local yright =0
    
    id_1,xleft= rednet.receive(protocol)
    id_2,yleft= rednet.receive(protocol)
    id_1,xright= rednet.receive(protocol)
    id_2,yright= rednet.receive(protocol)

    local roll = arctan((yleft-yright)/xleft-xright)

    rednet.send(12,"pitch",protocol)
    rednet.send(12,pitch,protocol)
    rednet.send(12,"roll",protocol)
    rednet.send(12,roll,protocol)
    rednet.send(12,"gs",protocol)
    rednet.send(12,gs,protocol)
    rednet.send(12,"alt",protocol)
    rednet.send(12,adirualt,protocol)
    rednet.send(12,"vs",protocol)
    rednet.send(12,vs,protocol)
end

rednet.close(side)
