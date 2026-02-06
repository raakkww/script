-- if you gonna take ts atleast leave credit bruh [MADE BY JOYFUL_PIZZAPARTYL]
-- slap farmer

if not game:IsLoaded() then
    game.Loaded:Wait()
end 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- THE MOST IMPORTANT PART anti afk
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Character wait
local function getChar()
    repeat task.wait() until player.Character
    repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")
    return player.Character
end

local character = getChar()
local hrp = character.HumanoidRootPart
local humanoid = character:FindFirstChildOfClass("Humanoid")

-- Freezeah
pcall(function()
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.AutoRotate = false
end)

-- afk platform bor
local PLATFORM_POS = Vector3.new(0, 500000, 0)

local platform = Instance.new("Part")
platform.Size = Vector3.new(40, 2, 40)
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 1
platform.Position = PLATFORM_POS
platform.Parent = workspace

-- (g)UI
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.fromScale(1,1)
bg.BackgroundColor3 = Color3.fromRGB(80,80,80)
bg.BackgroundTransparency = 0.15

local title = Instance.new("TextLabel", bg)
title.Size = UDim2.new(1,0,0,80)
title.Position = UDim2.new(0,0,0.3,0)
title.BackgroundTransparency = 1
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.Text = "your slaps: (loading)"

local subtitle = Instance.new("TextLabel", bg)
subtitle.Size = UDim2.new(1,0,0,50)
subtitle.Position = UDim2.new(0,0,0.42,0)
subtitle.BackgroundTransparency = 1
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.TextColor3 = Color3.fromRGB(220,220,220)
subtitle.Text = "farming slapples!"

-- teleport1(lobby -> arena portal) teleport.
task.wait(0.3)
hrp.CFrame = workspace.Lobby.Teleport1.CFrame + Vector3.new(0,3,0)

task.wait(0.8)
hrp.CFrame = CFrame.new(PLATFORM_POS + Vector3.new(0,5,0))

-- SLAP counter in gui
task.spawn(function()
    while task.wait(0.5) do
        local stats = player:FindFirstChild("leaderstats")
        if stats and stats:FindFirstChild("Slaps") then
            title.Text = "your slaps: (" .. stats.Slaps.Value .. ")"
        end
    end
end)

-- autofarm part :D
task.spawn(function()
    while task.wait(0.4) do
        character = getChar()
        hrp = character.HumanoidRootPart

        -- keep frozen
        pcall(function()
            local hum = character:FindFirstChildOfClass("Humanoid")
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.AutoRotate = false
        end)

        -- this is useless but just In case.
        if not character:FindFirstChild("entered") then
            repeat task.wait(0.25)
                firetouchinterest(hrp, workspace.Lobby.Teleport1, 0)
                firetouchinterest(hrp, workspace.Lobby.Teleport1, 1)
            until character:FindFirstChild("entered")
        end

        -- slapples yay
        for _, v in ipairs(workspace.Arena.island5.Slapples:GetDescendants()) do
            if v.Name == "Glove" and v:FindFirstChildWhichIsA("TouchTransmitter") then
                firetouchinterest(hrp, v, 0)
                firetouchinterest(hrp, v, 1)
            end
        end

        -- teleport on the platform to not get see
        if (hrp.Position - PLATFORM_POS).Magnitude > 60 then
            hrp.CFrame = CFrame.new(PLATFORM_POS + Vector3.new(0,5,0))
        end
    end
end)
