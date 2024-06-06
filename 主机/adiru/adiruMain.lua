--计算反正切函数
function arctan(x)
    return 0.5*math.atan(2*x,1-x*x)
end

--(自定义主机协议(频道)名称为lunatic)lunatic是主机的协议(频道)    
--rednet.host（协议，主机名）
rednet.host("lunatic","adiru")

local Protocol_F="FrontSensor"
local Protocol_B="BackSensor"
local Protocol_L="LeftSensor"
local Protocol_R="RightSensor"

local Protocol_Pitch_Str="PS"
local Protocol_Pitch="P"

local Protocol_Roll_Str="RS"
local Protocol_Roll="R"

local Protocol_Yaw_Str="YS"
local Protocol_Yaw="Y"

--方位变量
local side="left"

--时间变量0.01s
local time=0.01

rednet.open(side)

--传回来前传感器的坐标
local x_FrontSensor = 0.123456
local y_FrontSensor = 0.123456
local z_FrontSensor = 0.123456

--传回来后传感器的坐标
local x_BackSensor = 0.123456
local y_BackSensor = 0.123456
local z_BackSensor = 0.123456

--传回来左传感器的坐标
local x_LeftSensor = 0.123456
local y_LeftSensor = 0.123456
local z_LeftSensor = 0.123456

--传回来右传感器的坐标
local x_RightSensor = 0.123456
local y_RightSensor = 0.123456
local z_RightSensor = 0.123456

--记录发送给主机消息的传感器id
local id_front = 0
local id_back = 0
local id_left = 0
local id_right = 0


--纪录此主机的x,y,z坐标分别为px,py,pz
local x_adiru = 0.000000
local y_adiru = 0.000000
local z_adiru = 0.000000
x_adiru,y_adiru,z_adiru = gps.locate()

--记录临时坐标
local x_tmpF=x_FrontSensor
local z_tmpF=z_FrontSensor

local x_tmpB=x_BackSensor
local z_tmpB=z_BackSensor

local x_tmpL=x_LeftSensor
local z_tmpL=z_LeftSensor

local x_tmpR=x_RightSensor
local z_tmpR=z_RightSensor

local x_tmpadiru=x_adiru
local y_tmpadiru=y_adiru
local z_tmpadiru=z_adiru

 while true do

    --使用repeat接收前后左右四个传感器传回来此时的坐标，以及此时主机的坐标(更新坐标)
    repeat 

        id_front,x_FrontSensor = rednet.receive(Protocol_F)
        id_front,y_FrontSensor = rednet.receive(Protocol_F)
        id_front,z_FrontSensor = rednet.receive(Protocol_F)
    
        id_back,x_BackSensor = rednet.receive(Protocol_B)
        id_back,y_BackSensor = rednet.receive(Protocol_B)
        id_back,z_BackSensor = rednet.receive(Protocol_B)
    
        id_left,x_LeftSensor = rednet.receive(Protocol_L)
        id_left,y_LeftSensor = rednet.receive(Protocol_L)
        id_left,z_LeftSensor = rednet.receive(Protocol_L)
    
        id_right,x_RightSensor = rednet.receive(Protocol_R)
        id_right,y_RightSensor = rednet.receive(Protocol_R)
        id_right,z_RightSensor = rednet.receive(Protocol_R)

        x_adiru,y_adiru,z_adiru = gps.locate()
            
    until (x_adiru ~= x_tmpadiru) and (y_adiru ~= y_tmpadiru) and (z_adiru ~= z_tmpadiru)
    
    --计算水平x轴速度
    local vx = math.abs((x_adiru-x_tmpadiru)/time)
    --计算垂直y轴速度
    local vy = math.abs((y_adiru-y_tmpadiru)/time)
    --计算水平z轴速度
    local vz = math.abs((z_adiru-z_tmpadiru)/time)

    --计算水平面(x轴,z轴)向量速度
    local v_horizontal_vector = math.sqrt((vx*vx)+(vz*vz))

    
    --左侧传感器变换位置后水平面(x轴,z轴)向量
    local vector_horizontal_leftsensor = {x_LeftSensor-x_tmpL , z_LeftSensor-z_tmpL}
    --右侧传感器变换位置后水平面(x轴,z轴)向量
    local vector_horizontal_rightsensor = {x_RightSensor-x_tmpR , z_RightSensor-z_tmpR}
    --左右两侧传感器矢量和(向量)
    local vector_horizontal_LRsensor = {vector_horizontal_leftsensor[1]+vector_horizontal_rightsensor[1] , vector_horizontal_leftsensor[2]+vector_horizontal_rightsensor[2]}
    --后传感器与前传感器的向量(希望是沿机身x轴)
    local vector_horizontal_aF = {x_tmpB-x_tmpF , z_tmpB-z_tmpF}
    --adiru主机变换位置后的水平面(x轴,z轴)向量
    local vector_horizontal_adiru = {x_adiru-x_tmpadiru , y_adiru-y_tmpadiru}

    --计算两侧传感器矢量和(向量)长度
    local Len_vector_horizontal_LRsensor = math.sqrt(vector_horizontal_LRsensor[1]^2 + vector_horizontal_LRsensor[2]^2)


    --计算俯仰角(垂直速度比水平面速度的反正切)
    local angle_of_pitch = arctan(vy/v_horizontal_vector)

    --计算滚转角(左侧垂直高度 减 （右侧垂直高度比左右两侧xz矢量和）的差 的 反正切)
    local angle_of_roll = arctan(math.abs(y_LeftSensor-(y_RightSensor/(Len_vector_horizontal_LRsensor))))

    --计算偏航角()
    local tmp_yaw = (vector_horizontal_aF[1]*vector_horizontal_adiru[1]+vector_horizontal_aF[2]*vector_horizontal_adiru[2]) 
                     / (math.sqrt((vector_horizontal_adiru[1])^2 + vector_horizontal_adiru[2]^2) * math.sqrt((vector_horizontal_aF[1])^2+(vector_horizontal_aF[2])^2))
    
    local angle_of_yaw = math.acos(tmp_yaw)

    --发送俯仰角
    rednet.send(12,("pitch=%6f"):format(angle_of_pitch),Protocol_Pitch_Str)
    rednet.send(12,("%6f"):format(angle_of_pitch),Protocol_Pitch)

    --发送滚转角
    rednet.send(12,("roll=%6f"):format(angle_of_roll),Protocol_Roll_Str)
    rednet.send(12,("%6f"):format(angle_of_roll),Protocol_Roll)

    --发送偏航角
    rednet.send(12,("yaw=%6f"):format(angle_of_yaw),Protocol_Yaw_Str)
    rednet.send(12,("%6f"):format(angle_of_yaw),Protocol_Yaw)

    --保存此次坐标给临时坐标,为下一次循环提供上一次循环的坐标
    x_tmpF=x_FrontSensor
    z_tmpF=z_FrontSensor
    
    x_tmpB=x_BackSensor
    z_tmpB=z_BackSensor
    
    x_tmpL=x_LeftSensor
    z_tmpL=z_LeftSensor
    
    x_tmpR=x_RightSensor
    z_tmpR=z_RightSensor
    
    x_tmpadiru=x_adiru
    y_tmpadiru=y_adiru
    z_tmpadiru=z_adiru
    

        sleep(time)
    end
    
    rednet.close(side)
    