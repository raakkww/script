-- Water Buoyancy System + Custom GUI
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
local isEnabled = true

-- GUI Setup (Mobile-friendly draggable)
local screen = Instance.new("ScreenGui")
screen.Name = "WaterBuoyancyGUI"
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 60)
mainFrame.Position = UDim2.new(0.5, -90, 0.9, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screen

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 20)
dragBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
dragBar.BorderSizePixel = 0
dragBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🌊 Anti-Drown [ON]"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = dragBar

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, 0, 0, 40)
toggleBtn.Position = UDim2.new(0, 0, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
toggleBtn.Text = "Toggle"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.Parent = mainFrame

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

-- Toggle functionality
toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    title.Text = "🌊 Anti-Drown [" .. (isEnabled and "ON" or "OFF") .. "]"
    title.TextColor3 = isEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    if not isEnabled and floatForce then
        floatForce:Destroy()
        floatForce = nil
    end
end)

-- Core buoyancy logic
local function keepAboveWater()
    if not isEnabled or not character or not rootPart or not humanoid then return end
    local pos = rootPart.Position
    local waveY = ocean.Position.Y + math.abs(ocean.Position.Y) + wavemath.GetPosition(pos.X, pos.Z, workspace:GetServerTimeNow()).Y
    if pos.Y < waveY then
        if not floatForce then
            floatForce = Instance.new("VectorForce")
            floatForce.Name = "floatForce"
            floatForce.Attachment0 = rootPart:FindFirstChild("RootAttachment") or Instance.new("Attachment")
            if not rootPart:FindFirstChild("RootAttachment") then floatForce.Attachment0.Parent = rootPart end
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
        if isEnabled and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- Credits as requested
print("NoHub - Noctyra | Anti-Drown System Loaded")
