-- GZSSF SPLASH SCREEN
-- By GZSSF

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

pcall(function()
	CoreGui:FindFirstChild("GZSSF_SPLASH"):Destroy()
end)

local splashGui = Instance.new("ScreenGui")
splashGui.Name = "GZSSF_SPLASH"
splashGui.IgnoreGuiInset = true
splashGui.ResetOnSpawn = false
splashGui.Parent = CoreGui

local bg = Instance.new("Frame", splashGui)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.new(0,0,0)
bg.BackgroundTransparency = 0

local title = Instance.new("TextLabel", bg)
title.Size = UDim2.new(0,400,0,70)
title.Position = UDim2.new(0.5,-200,0.45,-40)
title.BackgroundTransparency = 1
title.Text = ""
title.Font = Enum.Font.GothamBlack
title.TextSize = 50
title.TextColor3 = Color3.fromRGB(180,180,180)
title.TextTransparency = 0

local sub = Instance.new("TextLabel", bg)
sub.Size = UDim2.new(0,400,0,30)
sub.Position = UDim2.new(0.5,-200,0.45,30)
sub.BackgroundTransparency = 1
sub.Text = "scripts"
sub.Font = Enum.Font.Gotham
sub.TextSize = 18
sub.TextColor3 = Color3.fromRGB(140,140,140)
sub.TextTransparency = 0

local loading = Instance.new("TextLabel", bg)
loading.Size = UDim2.new(0,250,0,25)
loading.Position = UDim2.new(0,10,1,-35)
loading.BackgroundTransparency = 1
loading.Text = "Loading script..."
loading.Font = Enum.Font.Gotham
loading.TextSize = 14
loading.TextXAlignment = Enum.TextXAlignment.Left
loading.TextColor3 = Color3.fromRGB(120,120,120)
loading.TextTransparency = 0

local skip = Instance.new("TextButton", bg)
skip.Size = UDim2.new(0,80,0,30)
skip.Position = UDim2.new(1,-90,1,-40)
skip.Text = "SKIP"
skip.Font = Enum.Font.GothamBold
skip.TextSize = 14
skip.TextColor3 = Color3.new(1,1,1)
skip.BackgroundColor3 = Color3.fromRGB(60,60,60)
skip.BorderSizePixel = 0
Instance.new("UICorner", skip)

local closed = false
local function closeSplash()
	if closed then return end
	closed = true
	splashGui:Destroy()
end

skip.MouseButton1Click:Connect(closeSplash)

task.wait(3)

if not closed then
	local info = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	TweenService:Create(bg, info, {BackgroundTransparency = 1}):Play()
	TweenService:Create(title, info, {TextTransparency = 1}):Play()
	TweenService:Create(sub, info, {TextTransparency = 1}):Play()
	TweenService:Create(loading, info, {TextTransparency = 1}):Play()
	TweenService:Create(skip, info, {
		TextTransparency = 1,
		BackgroundTransparency = 1
	}):Play()

	task.wait(1.6)
	closeSplash()
end

--// GUI
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "ExecuteGUI"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 90, 0, 35)
button.Position = UDim2.new(0.05, 0, 0.5, 0)
button.Text = "Execute"
button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.Active = true
button.Draggable = true

--// Script original (SIN CAMBIOS)
local running = false

button.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    button.Text = "Running"

    while true do
        for i = 1, 100 do
            game:GetService("ReplicatedStorage")
                .Modules
                .EventManagerClient
                .ServerEvent
                :FireServer("ClaimReward")
        end
        task.wait()
    end
end)
