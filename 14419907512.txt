
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local UIListLayout = Instance.new("UIListLayout", Frame)
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

Frame.Size = UDim2.new(0, 220, 0, 240) 
Frame.Position = UDim2.new(0.1, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true 

UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function createButton(text, color)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- English Buttons 🎨
local crimBtn = createButton("CRIMINAL BASE 🏠", Color3.fromRGB(150, 0, 0))
local copBtn = createButton("POLICE TABLE 👮‍♂️", Color3.fromRGB(0, 100, 200))
local shotgunBtn = createButton("GET SHOTGUN 🔫", Color3.fromRGB(120, 120, 120))
local mp5Btn = createButton("GET MP5 🔫", Color3.fromRGB(0, 120, 215))
local exitBtn = createButton("CLOSE MENU ❌", Color3.fromRGB(50, 50, 50))

-- Teleport Function 🌀
local function teleportTo(cf)
    local player = game.Players.LocalPlayer
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = cf end
end

-- 🛠️ BUTTON LOGIC

-- 🏠 Criminal Base
crimBtn.MouseButton1Click:Connect(function()
    teleportTo(CFrame.new(-884.80, 94.13, 2046.90))
end)

-- 👮‍♂️ Police Table
copBtn.MouseButton1Click:Connect(function()
    teleportTo(CFrame.new(851.36, 99.99, 2273.66))
end)

-- 🔫 Shotgun (Remington 870)
shotgunBtn.MouseButton1Click:Connect(function()
    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
    local oldPos = root.CFrame
    teleportTo(CFrame.new(820.97, 99.98, 2231.51))
    task.wait(0.5)
    
    local args = {
        [1] = workspace.Prison_ITEMS.giver:FindFirstChild("Remington 870"):FindFirstChild("Meshes/r870_2")
    }
    game:GetService("ReplicatedStorage").Remotes.InteractWithItem:InvokeServer(unpack(args))
    
    task.wait(0.3)
    teleportTo(oldPos)
end)

-- 🔫 MP5
mp5Btn.MouseButton1Click:Connect(function()
    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
    local oldPos = root.CFrame
    teleportTo(CFrame.new(813, 99, 2232))
    task.wait(0.5)
    game:GetService("ReplicatedStorage").Remotes.InteractWithItem:InvokeServer(workspace.Prison_ITEMS.giver.MP5:FindFirstChild("Meshes/MP5 (2)"))
    task.wait(0.3)
    teleportTo(oldPos)
end)

exitBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
