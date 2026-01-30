-- 🌊🐠💰 NoHub - Noctyra | Triple System v3.0
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Cleanup previous instances
local folder = workspace:FindFirstChild(player.Name)
if folder then
    local uw = folder:FindFirstChild("UnderwaterDetection")
    if uw then uw:Destroy() end
end

local ocean = workspace:FindFirstChild("OceanTile1")
local wavemath = require(game.ReplicatedStorage.WaveMath)
local floatForce
local buoyancyEnabled = true
local cashEnabled = false
local creaturesEnabled = false
local cashConnection
local creatureConnection

-- Remote references
local grantReward = game:GetService("ReplicatedStorage"):WaitForChild("GrantReward")

-- GUI Setup (Mobile-friendly draggable)
local screen = Instance.new("ScreenGui")
screen.Name = "NoHub_TripleSystem"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 145)
mainFrame.Position = UDim2.new(0.5, -120, 0.9, -165)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screen

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 26)
dragBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
dragBar.BorderSizePixel = 0
dragBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "NoHub - Noctyra"
title.TextColor3 = Color3.fromRGB(50, 200, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.Parent = dragBar

-- Buoyancy Toggle
local buoyancyBtn = Instance.new("TextButton")
buoyancyBtn.Size = UDim2.new(1, -12, 0, 34)
buoyancyBtn.Position = UDim2.new(0, 6, 0, 32)
buoyancyBtn.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
buoyancyBtn.Text = "🌊 Buoyancy: ON"
buoyancyBtn.TextColor3 = Color3.new(0, 1, 0)
buoyancyBtn.TextSize = 15
buoyancyBtn.Font = Enum.Font.GothamSemibold
buoyancyBtn.Parent = mainFrame

-- Cash Toggle
local cashBtn = Instance.new("TextButton")
cashBtn.Size = UDim2.new(1, -12, 0, 34)
cashBtn.Position = UDim2.new(0, 6, 0, 70)
cashBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
cashBtn.Text = "💰 Auto Cash: OFF"
cashBtn.TextColor3 = Color3.new(1, 0.2, 0.2)
cashBtn.TextSize = 15
cashBtn.Font = Enum.Font.GothamSemibold
cashBtn.Parent = mainFrame

-- Creatures Toggle
local creatureBtn = Instance.new("TextButton")
creatureBtn.Size = UDim2.new(1, -12, 0, 34)
creatureBtn.Position = UDim2.new(0, 6, 0, 108)
creatureBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
creatureBtn.Text = "🐠 Sea Creatures: OFF"
creatureBtn.TextColor3 = Color3.new(0.7, 0.7, 0.9)
creatureBtn.TextSize = 15
creatureBtn.Font = Enum.Font.GothamSemibold
creatureBtn.Parent = mainFrame

-- Draggable support (mobile + PC)
local dragging, dragStart, startPos
dragBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        if dragging then
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Buoyancy Toggle Logic
buoyancyBtn.MouseButton1Click:Connect(function()
    buoyancyEnabled = not buoyancyEnabled
    buoyancyBtn.Text = "🌊 Buoyancy: " .. (buoyancyEnabled and "ON" or "OFF")
    buoyancyBtn.TextColor3 = buoyancyEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0.6, 0)
    buoyancyBtn.BackgroundColor3 = buoyancyEnabled and Color3.fromRGB(35, 55, 35) or Color3.fromRGB(55, 35, 35)
    if not buoyancyEnabled and floatForce then
        floatForce:Destroy()
        floatForce = nil
    end
end)

-- Cash Toggle Logic
cashBtn.MouseButton1Click:Connect(function()
    cashEnabled = not cashEnabled
    cashBtn.Text = "💰 Auto Cash: " .. (cashEnabled and "ON" or "OFF")
    cashBtn.TextColor3 = cashEnabled and Color3.new(1, 0.95, 0) or Color3.new(1, 0.2, 0.2)
    cashBtn.BackgroundColor3 = cashEnabled and Color3.fromRGB(65, 55, 30) or Color3.fromRGB(60, 40, 40)
    
    if cashConnection then
        cashConnection:Disconnect()
        cashConnection = nil
    end
    
    if cashEnabled then
        cashConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not cashEnabled then return end
            pcall(function()
                grantReward:InvokeServer({
                    type = "Money",
                    rarity = "Common",
                    value = 500,
                    color = Color3.new(0.83, 0.83, 0.83),
                    icon = "💰",
                    displayName = "500 Cash"
                })
            end)
            wait(1.3) -- Rate-limited
        end)
    end
end)

-- Creatures Toggle Logic
creatureBtn.MouseButton1Click:Connect(function()
    creaturesEnabled = not creaturesEnabled
    creatureBtn.Text = "🐠 Sea Creatures: " .. (creaturesEnabled and "ON" or "OFF")
    creatureBtn.TextColor3 = creaturesEnabled and Color3.new(0.5, 0.9, 1) or Color3.new(0.7, 0.7, 0.9)
    creatureBtn.BackgroundColor3 = creaturesEnabled and Color3.fromRGB(55, 40, 80) or Color3.fromRGB(45, 35, 65)
    
    if creatureConnection then
        creatureConnection:Disconnect()
        creatureConnection = nil
    end
    
    if creaturesEnabled then
        local creaturesList = {
            {rarity = "Common", name = "Archelon"},
            {rarity = "Rare", name = "Metriorhynchus"},
            {rarity = "Legendary", name = "Mosasaurus"}
        }
        
        creatureConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not creaturesEnabled then return end
            for _, info in ipairs(creaturesList) do
                pcall(function()
                    grantReward:InvokeServer({
                        type = "SeaCreature",
                        rarity = info.rarity,
                        creatureId = 1,
                        value = 1,
                        color = Color3.new(0.83, 0.83, 0.83),
                        icon = "🦕",
                        displayName = info.name
                    })
                end)
                wait(0.4) -- Small delay between spawns
            end
            wait(2.5) -- Cycle delay
        end)
    end
end)

-- Core buoyancy logic
local function keepAboveWater()
    if not buoyancyEnabled or not character or not rootPart or not humanoid then return end
    if not ocean or not wavemath then return end
    
    local pos = rootPart.Position
    local waveY = ocean.Position.Y + math.abs(ocean.Position.Y) + wavemath.GetPosition(pos.X, pos.Z, workspace:GetServerTimeNow()).Y
    if pos.Y < waveY then
        if not floatForce then
            floatForce = Instance.new("VectorForce")
            floatForce.Name = "floatForce"
            floatForce.Attachment0 = rootPart:FindFirstChild("RootAttachment") or Instance.new("Attachment")
            if not rootPart:FindFirstChild("RootAttachment") then 
                floatForce.Attachment0.Name = "RootAttachment"
                floatForce.Attachment0.Parent = rootPart 
            end
            floatForce.RelativeTo = Enum.ActuatorRelativeTo.World
            floatForce.Parent = rootPart
        end
        local mass = rootPart.AssemblyMass
        floatForce.Force = Vector3.new(0, math.clamp(mass * 150 * (waveY - pos.Y), 0, mass * 2000), 0)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    elseif floatForce then
        floatForce:Destroy()
        floatForce = nil
    end
end

game:GetService("RunService").Heartbeat:Connect(keepAboveWater)

if character:FindFirstChild("IsRagdoll") then
    character.IsRagdoll.Changed:Connect(function()
        if buoyancyEnabled and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- Auto-reconnect character
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    wait(1)
    if character:FindFirstChild("IsRagdoll") then
        character.IsRagdoll.Changed:Connect(function()
            if buoyancyEnabled and humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end)

print("✅ NoHub - Noctyra | Triple System Loaded: Buoyancy + Cash + Sea Creatures")
