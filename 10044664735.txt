-- THIS ISNT AS OP OK? I WA SBORED also im too  lazy to add a readme so figure it outurselfs lol.. man im tired blehhhh :P
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local Window = SimpleLib:Window("punch wall game thing")
local MainTab = Window:AddSection("main")
local WinTab = Window:AddSection("win zone tps")

local PunchEvent = game:GetService("ReplicatedStorage").Remotes.Server.PunchWall
local StrengthEvent = game:GetService("ReplicatedStorage").Remotes.Server.GainStrength
local RebirthEvent = game:GetService("ReplicatedStorage").Remotes.Server.Rebirth

local punchLooping = false
local punchThread = nil
local strengthLooping = false
local strengthThread = nil
local autoWinLooping = false
local autoWinThread = nil
local jumpSpamThread = nil
local rebirthLooping = false
local rebirthThread = nil
local rebirthDelay = 5

local player = game.Players.LocalPlayer
local autoWinStage = 1

local function teleportToWinsHitbox(stageNum)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        player.CharacterAdded:Wait()
        char = player.Character
        char:WaitForChild("HumanoidRootPart")
    end
    
    local stage = game:GetService("Workspace").Stages["Stage " .. stageNum]
    if stage and stage.Wins and stage.Wins.WinsHitbox then
        char.HumanoidRootPart.CFrame = CFrame.new(stage.Wins.WinsHitbox.Position)
    end
end

local function punchAllWalls()
    for i = 1, 17 do
        PunchEvent:FireServer(i)
    end
end

MainTab:Toggle("loop punch all walls (1-17)", false, function(state)
    punchLooping = state
    if punchLooping then
        punchThread = task.spawn(function()
            while punchLooping do
                punchAllWalls()
                task.wait()
            end
        end)
    else
        punchLooping = false
        if punchThread then
            task.cancel(punchThread)
            punchThread = nil
        end
    end
end)

MainTab:Toggle("auto strength", false, function(state)
    strengthLooping = state
    if strengthLooping then
        strengthThread = task.spawn(function()
            while strengthLooping do
                StrengthEvent:FireServer()
                task.wait()
            end
        end)
    else
        strengthLooping = false
        if strengthThread then
            task.cancel(strengthThread)
            strengthThread = nil
        end
    end
end)

MainTab:Button("punch all walls once", function()
    punchAllWalls()
end)

MainTab:Button("punch wall 1", function() PunchEvent:FireServer(1) end)
MainTab:Button("punch wall 2", function() PunchEvent:FireServer(2) end)
MainTab:Button("punch wall 3", function() PunchEvent:FireServer(3) end)
MainTab:Button("punch wall 4", function() PunchEvent:FireServer(4) end)
MainTab:Button("punch wall 5", function() PunchEvent:FireServer(5) end)
MainTab:Button("punch wall 6", function() PunchEvent:FireServer(6) end)
MainTab:Button("punch wall 7", function() PunchEvent:FireServer(7) end)
MainTab:Button("punch wall 8", function() PunchEvent:FireServer(8) end)
MainTab:Button("punch wall 9", function() PunchEvent:FireServer(9) end)
MainTab:Button("punch wall 10", function() PunchEvent:FireServer(10) end)
MainTab:Button("punch wall 11", function() PunchEvent:FireServer(11) end)
MainTab:Button("punch wall 12", function() PunchEvent:FireServer(12) end)
MainTab:Button("punch wall 13", function() PunchEvent:FireServer(13) end)
MainTab:Button("punch wall 14", function() PunchEvent:FireServer(14) end)
MainTab:Button("punch wall 15", function() PunchEvent:FireServer(15) end)
MainTab:Button("punch wall 16", function() PunchEvent:FireServer(16) end)
MainTab:Button("punch wall 17", function() PunchEvent:FireServer(17) end)

WinTab:TextBox("set auto teleport stage (1-17)", 1, function(text)
    local num = tonumber(text)
    if num and num >= 1 and num <= 17 then
        autoWinStage = num
    end
end)

WinTab:Toggle("auto tp to stage", false, function(state)
    autoWinLooping = state
    if autoWinLooping then
        autoWinThread = task.spawn(function()
            while autoWinLooping do
                teleportToWinsHitbox(autoWinStage)
                task.wait(1)
            end
        end)
        jumpSpamThread = task.spawn(function()
            while autoWinLooping do
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    local hum = char.Humanoid
                    if hum.FloorMaterial ~= Enum.Material.Air then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
                task.wait(0.3)
            end
        end)
    else
        autoWinLooping = false
        if autoWinThread then
            task.cancel(autoWinThread)
            autoWinThread = nil
        end
        if jumpSpamThread then
            task.cancel(jumpSpamThread)
            jumpSpamThread = nil
        end
    end
end)

WinTab:Button("teleport to selected stage (useless)", function()
    teleportToWinsHitbox(autoWinStage)
end)

WinTab:Button("win 1", function() teleportToWinsHitbox(1) end)
WinTab:Button("win 2", function() teleportToWinsHitbox(2) end)
WinTab:Button("win 3", function() teleportToWinsHitbox(3) end)
WinTab:Button("win 4", function() teleportToWinsHitbox(4) end)
WinTab:Button("win 5", function() teleportToWinsHitbox(5) end)
WinTab:Button("win 6", function() teleportToWinsHitbox(6) end)
WinTab:Button("win 7", function() teleportToWinsHitbox(7) end)
WinTab:Button("win 8", function() teleportToWinsHitbox(8) end)
WinTab:Button("win 9", function() teleportToWinsHitbox(9) end)
WinTab:Button("win 10", function() teleportToWinsHitbox(10) end)
WinTab:Button("win 11", function() teleportToWinsHitbox(11) end)
WinTab:Button("win 12", function() teleportToWinsHitbox(12) end)
WinTab:Button("win 13", function() teleportToWinsHitbox(13) end)
WinTab:Button("win 14", function() teleportToWinsHitbox(14) end)
WinTab:Button("win 15", function() teleportToWinsHitbox(15) end)
WinTab:Button("win 16", function() teleportToWinsHitbox(16) end)
WinTab:Button("win 17", function() teleportToWinsHitbox(17) end)

local RebirthTab = Window:AddSection("auto rebirth")

RebirthTab:TextBox("set rebirth delay ig", 1, function(text)
    local num = tonumber(text)
    if num and num > 0 then
        rebirthDelay = num
    end
end)

RebirthTab:Toggle("auto rebirthish", false, function(state)
    rebirthLooping = state
    if rebirthLooping then
        rebirthThread = task.spawn(function()
            while rebirthLooping do
                RebirthEvent:FireServer("Rebirth")
                task.wait(rebirthDelay)
            end
        end)
    else
        rebirthLooping = false
        if rebirthThread then
            task.cancel(rebirthThread)
            rebirthThread = nil
        end
    end
end)

RebirthTab:Button("rebirth 1 time", function()
    RebirthEvent:FireServer("Rebirth")
end)
