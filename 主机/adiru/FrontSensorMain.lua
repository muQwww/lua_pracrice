--计算反正切函数
function arctan(x)
    return 0.5*math.atan(2*x,1-x*x)
end

--(自定义主机协议(频道)名称为lunatic)lunatic是主机的协议(频道)    
--rednet.host（协议，主机名）
rednet.host("lunatic","adiru")

--(自定义协议名称为EEE)EEE是发送信息的协议,只接受EEE协议发送的信息，其他的都过滤
--receive方法自带暂停，没有接收到消息时，receive下面的语句都不运行
local protocol="EEE"

--方位变量
local side="left"

rednet.open(side)

--传回来前面传感器的坐标
local x_frontSensor = nil
local y_frontSensor = nil
local z_frontSensor = nil

repeat 
    id,x_frontSensor = rednet.receive(protocol)
    id,y_frontSensor = rednet.receive(protocol)
    id,z_frontSensor = rednet.receive(protocol)
until (x_frontSensor ~= nil) and (y_frontSensor ~= nil) and (z_frontSensor ~=nil)

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
    sleep(0.01)

    rx,ry,rz = gps.locate()--rx,ry,rz存放主机坐标

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
