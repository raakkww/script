--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- ZOMBIE KILLER
local player = game.Players.LocalPlayer
local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
local Gunshot = Remotes and Remotes:FindFirstChild("Gunshot")
local running = false

local function getGun()
    for _, t in pairs((player.Character or {}):GetChildren()) do
        if t:IsA("Tool") and t:FindFirstChild("Handle") then return t end
    end
end

local function killAll()
    local gun, folder = getGun(), workspace:FindFirstChild("AliveZombies")
    if not gun or not folder then return end
    for _, z in pairs(folder:GetChildren()) do
        local h = z:FindFirstChild("Head")
        if h then pcall(function() Gunshot:FireServer(gun, {z}, true, h.Position) end) end
    end
end

-- GUI
local gui = Instance.new("ScreenGui") gui.Name = "ZombieKiller" gui.ResetOnSpawn = false
local main = Instance.new("Frame", gui) main.Size = UDim2.new(0,140,0,60) main.Position = UDim2.new(0,10,0.5,-30) main.BackgroundColor3 = Color3.fromRGB(25,25,35) main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", main) title.Size = UDim2.new(1,0,0,20) title.BackgroundColor3 = Color3.fromRGB(150,50,50) title.Text = "Zombie Killer" title.TextColor3 = Color3.new(1,1,1) title.Font = Enum.Font.GothamBold title.TextSize = 10
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local btn = Instance.new("TextButton", main) btn.Size = UDim2.new(1,-12,0,28) btn.Position = UDim2.new(0,6,0,26) btn.BackgroundColor3 = Color3.fromRGB(150,50,50) btn.Text = "OFF" btn.TextColor3 = Color3.new(1,1,1) btn.Font = Enum.Font.GothamBold btn.TextSize = 14
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    running = not running
    btn.Text = running and "ON" or "OFF"
    btn.BackgroundColor3 = running and Color3.fromRGB(50,150,50) or Color3.fromRGB(150,50,50)
    if running then task.spawn(function() while running do killAll() task.wait(0.1) end end) end
end)

-- Drag
local d, ds, sp
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d, ds, sp = true, i.Position, main.Position end end)
main.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
    if d and i.UserInputType == Enum.UserInputType.MouseMovement then main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + i.Position.X - ds.X, sp.Y.Scale, sp.Y.Offset + i.Position.Y - ds.Y) end
end)

if gethui then gui.Parent = gethui() elseif syn and syn.protect_gui then syn.protect_gui(gui) gui.Parent = game:GetService("CoreGui") else gui.Parent = player:WaitForChild("PlayerGui") end
print("Zombie Killer")
