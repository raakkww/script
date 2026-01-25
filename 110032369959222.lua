--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- QUIZ AUTO-WIN + ANTI-AFK
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local GameRemotes = RS:WaitForChild("Remotes"):WaitForChild("Game")
local StartGame = GameRemotes:WaitForChild("StartGame")
local SubmitAnswer = GameRemotes:WaitForChild("SubmitAnswer")

local autoWin = true
local currentWord = nil
local wins = 0

-- Auto-Win: Capture word and submit
StartGame.OnClientEvent:Connect(function(role, word)
    currentWord = word
    if role == "Guesser" and autoWin then
        task.wait(math.random(1, 3))
        SubmitAnswer:FireServer(word)
        wins = wins + 1
        print("[WIN] " .. word .. " | Total: " .. wins)
    end
end)

-- Anti-AFK: Disable idle connections
pcall(function()
    for _, c in pairs(getconnections(player.Idled)) do c:Disable() end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "QuizWin"
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 180, 0, 100)
main.Position = UDim2.new(0, 10, 0.5, -50)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
title.Text = "Auto Win"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local wordLabel = Instance.new("TextLabel")
wordLabel.Size = UDim2.new(1, -10, 0, 20)
wordLabel.Position = UDim2.new(0, 5, 0, 28)
wordLabel.BackgroundTransparency = 1
wordLabel.Text = "Word: -- | Wins: 0"
wordLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
wordLabel.Font = Enum.Font.Gotham
wordLabel.TextSize = 11
wordLabel.Parent = main

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 35)
toggleBtn.Position = UDim2.new(0, 10, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
toggleBtn.Text = "AUTO-WIN: ON"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = main
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    autoWin = not autoWin
    toggleBtn.Text = autoWin and "AUTO-WIN: ON" or "AUTO-WIN: OFF"
    toggleBtn.BackgroundColor3 = autoWin and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
end)

-- Update display
task.spawn(function()
    while task.wait(0.5) do
        wordLabel.Text = "Word: " .. (currentWord or "--") .. " | Wins: " .. wins
    end
end)

-- Draggable
local d, ds, sp
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d, ds, sp = true, i.Position, main.Position end end)
main.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
    if d and i.UserInputType == Enum.UserInputType.MouseMovement then
        main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + i.Position.X - ds.X, sp.Y.Scale, sp.Y.Offset + i.Position.Y - ds.Y)
    end
end)

-- Parent GUI (executor compatible)
if gethui then gui.Parent = gethui()
elseif syn and syn.protect_gui then syn.protect_gui(gui) gui.Parent = game:GetService("CoreGui")
else gui.Parent = player:WaitForChild("PlayerGui") end

print("Auto-Win Active | Anti-AFK Active")
