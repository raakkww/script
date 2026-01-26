-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TimeMachineHack"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main window
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 250, 0, 140)
window.Position = UDim2.new(0.5, -125, 0.5, -70)
window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
window.BorderSizePixel = 0
window.Active = true
window.Draggable = false
window.Parent = screenGui

-- Title bar (for dragging)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
titleBar.BorderSizePixel = 0
titleBar.Parent = window

-- Drag pad (works on mobile & PC)
local dragPad = Instance.new("TextButton")
dragPad.Size = UDim2.new(1, 0, 1, 0)
dragPad.BackgroundTransparency = 1
dragPad.Text = ""
dragPad.AutoButtonColor = false
dragPad.Parent = titleBar

-- Title text
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⏱️ Time Machine Hack"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.Text = "✕"
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Toggle OFF"
toggleBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
toggleBtn.TextSize = 18
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = window

-- Credits
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 16)
credits.Position = UDim2.new(0, 0, 1, -16)
credits.BackgroundTransparency = 1
credits.Text = "NoHub - Noctyra"
credits.TextColor3 = Color3.fromRGB(120, 120, 140)
credits.TextSize = 12
credits.Font = Enum.Font.Gotham
credits.Parent = window

-- Rounded corners
local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

addCorner(window, 8)
addCorner(titleBar, 8)
addCorner(toggleBtn, 6)
addCorner(closeBtn, 6)

-- === Mobile + PC Drag System ===
local dragging = false
local dragStart = nil
local startPos = nil

dragPad.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = window.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragPad.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or 
        input.UserInputType == Enum.UserInputType.Touch) and dragging then
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- === Toggle Logic ===
local isEnabled = false
local upgradeName = "Time Machine" -- Change this to any upgrade name you want

toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        toggleBtn.Text = "✅ ACTIVE"
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        toggleBtn.Text = "Toggle OFF"
        toggleBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    end
end)

-- === Auto Fire Events ===
spawn(function()
    while wait(1) do -- Runs every 1 second
        if not isEnabled then continue end
        
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        
        -- Fire Keep event
        if ReplicatedStorage:FindFirstChild("Events") and 
           ReplicatedStorage.Events:FindFirstChild("RollingEvents") and
           ReplicatedStorage.Events.RollingEvents:FindFirstChild("Keep") then
            pcall(function()
                ReplicatedStorage.Events.RollingEvents.Keep:FireServer(upgradeName)
            end)
        end

        -- Fire InsertMoneyEvent
        if ReplicatedStorage:FindFirstChild("Events") and 
           ReplicatedStorage.Events:FindFirstChild("MachineEvents") and
           ReplicatedStorage.Events.MachineEvents:FindFirstChild("InsertMoneyEvent") then
            pcall(function()
                ReplicatedStorage.Events.MachineEvents.InsertMoneyEvent:FireServer(
                    0/0,  -- ohNumber1
                    0/0,  -- ohNumber2
                    "Plinko", -- ohString3
                    0     -- ohNumber4
                )
            end)
        end
    end
end)

-- Cleanup on leave
game.Players.LocalPlayer.AncestryChanged:Connect(function()
    if not game.Players.LocalPlayer:IsDescendantOf(game) then
        screenGui:Destroy()
    end
end)

print("✅ Time Machine Hack by NoHub - Noctyra | Mobile & PC Ready")
