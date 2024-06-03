print("Running startup.lua...")

local i=0

for i = 0, 1, 1 do

    --运行前传感器主程序
    shell.run("bg FrontSensorMain.lua")
    --如果前传感器运行失败，则输出异常
    if  (shell.run("bg FrontSensorMain.lua")) then
        print("FrontSensorMain Error ! ! ! ")
    end


    shell.run("bg FrontSensorMain.lua")
    --如果前传感器运行失败，则输出异常
    if  (shell.run("bg FrontSensorMain.lua")) then
        print("FrontSensorMain Error ! ! ! ")
    end


    shell.run("bg FrontSensorMain.lua")
    --如果前传感器运行失败，则输出异常
    if  (shell.run("bg FrontSensorMain.lua")) then
        print("FrontSensorMain Error ! ! ! ")
    end

    
    shell.run("bg FrontSensorMain.lua")
    --如果前传感器运行失败，则输出异常
    if  (shell.run("bg FrontSensorMain.lua")) then
        print("FrontSensorMain Error ! ! ! ")
    end

end