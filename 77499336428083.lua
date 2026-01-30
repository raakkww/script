-- 🌊💧 NoHub - Noctyra | Buoyancy + Auto Cash System
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
local cashConnection

-- GUI Setup (Mobile-friendly draggable)
local screen = Instance.new("ScreenGui")
screen.Name = "NoHub_WaterCashGUI"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 100)
mainFrame.Position = UDim2.new(0.5, -110, 0.9, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screen

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 24)
dragBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
dragBar.BorderSizePixel = 0
dragBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "NoHub - Noctyra"
title.TextColor3 = Color3.new(0.3, 0.8, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = dragBar

-- Buoyancy Toggle
local buoyancyBtn = Instance.new("TextButton")
buoyancyBtn.Size = UDim2.new(1, -10, 0, 32)
buoyancyBtn.Position = UDim2.new(0, 5, 0, 30)
buoyancyBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
buoyancyBtn.Text = "🌊 Buoyancy: ON"
buoyancyBtn.TextColor3 = Color3.new(0, 1, 0)
buoyancyBtn.TextSize = 15
buoyancyBtn.Font = Enum.Font.GothamSemibold
buoyancyBtn.Parent = mainFrame

-- Cash Toggle
local cashBtn = Instance.new("TextButton")
cashBtn.Size = UDim2.new(1, -10, 0, 32)
cashBtn.Position = UDim2.new(0, 5, 0, 65)
cashBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
cashBtn.Text = "💰 Auto Cash: OFF"
cashBtn.TextColor3 = Color3.new(1, 0.2, 0.2)
cashBtn.TextSize = 15
cashBtn.Font = Enum.Font.GothamSemibold
cashBtn.Parent = mainFrame

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
    buoyancyBtn.TextColor3 = buoyancyEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0.5, 0)
    buoyancyBtn.BackgroundColor3 = buoyancyEnabled and Color3.fromRGB(40, 60, 40) or Color3.fromRGB(60, 40, 40)
    if not buoyancyEnabled and floatForce then
        floatForce:Destroy()
        floatForce = nil
    end
end)

-- Cash Toggle Logic
cashBtn.MouseButton1Click:Connect(function()
    cashEnabled = not cashEnabled
    cashBtn.Text = "💰 Auto Cash: " .. (cashEnabled and "ON" or "OFF")
    cashBtn.TextColor3 = cashEnabled and Color3.new(1, 0.9, 0) or Color3.new(1, 0.2, 0.2)
    cashBtn.BackgroundColor3 = cashEnabled and Color3.fromRGB(60, 50, 30) or Color3.fromRGB(60, 40, 40)
    
    -- Stop existing loop
    if cashConnection then
        cashConnection:Disconnect()
        cashConnection = nil
    end
    
    -- Start new loop if enabled
    if cashEnabled then
        cashConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not cashEnabled then return end
            local args = {
                {
                    type = "Money",
                    rarity = "Common",
                    value = 500,
                    color = Color3.new(0.83, 0.83, 0.83),
                    icon = "💰",
                    displayName = "500 Cash"
                }
            }
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("GrantReward"):InvokeServer(unpack(args))
            end)
            wait(1.2) -- Rate-limited to avoid spam detection
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

print("✅ NoHub - Noctyra | Buoyancy + Auto Cash Loaded")
