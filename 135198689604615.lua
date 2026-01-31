--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local auto = false
local currentMode = "normal" -- "normal" или "tornado"
local tornadoAngle = 0
local flyEnabled = false
local currentSlap = "None"

-- Настройки полета из твоего кода
local flySpeed = 100
local flyButton = "e"
local controls = {
    front = "w",
    back = "s",
    right = "d",
    left = "a",
    up = " ",
    down = "q"
}
local flyControl = {F = 0, R = 0, B = 0, L = 0, U = 0, D = 0}

-- ПАПКА С ИНСТРУМЕНТАМИ
local ToolsFolder = ReplicatedStorage:WaitForChild("Tools")

---------------------------------------------------------
-- УЛУЧШЕННЫЙ ПОЛЁТ (FLY)
---------------------------------------------------------
local function startFly()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    if not hrp or not humanoid then return end
    
    flyEnabled = true
    
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
    bg.Name = "FlyGyro"
    bg.CFrame = hrp.CFrame
    bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
    bg.P = 9e4
    bv.Parent = hrp
    bg.Parent = hrp
    
    -- Отключение коллизий
    task.spawn(function()
        while flyEnabled do
            for _, child in pairs(character:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                end
            end
            RunService.Stepped:Wait()
        end
        -- Возвращаем коллизию после полета
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = true
            end
        end
    end)
    
    -- Цикл перемещения
    task.spawn(function()
        while flyEnabled do
            RunService.RenderStepped:Wait()
            humanoid.PlatformStand = true
            
            local cameraCF = workspace.CurrentCamera.CFrame
            bv.Velocity = (cameraCF.LookVector * ((flyControl.F - flyControl.B) * flySpeed)) 
                        + (cameraCF.RightVector * ((flyControl.R - flyControl.L) * flySpeed)) 
                        + (cameraCF.UpVector * ((flyControl.U - flyControl.D) * flySpeed))
            
            bg.CFrame = cameraCF
        end
        
        bv:Destroy()
        bg:Destroy()
        humanoid.PlatformStand = false
    end)
end

local function stopFly()
    flyEnabled = false
end

local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then
        startFly()
    else
        stopFly()
    end
    -- Обновление UI если он существует
    if _G.UpdateFlyUI then _G.UpdateFlyUI() end
end

-- Обработка клавиш для полета
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode.Name:lower()
    
    if key == flyButton then toggleFly()
    elseif key == "w" then flyControl.F = 1
    elseif key == "s" then flyControl.B = 1
    elseif key == "d" then flyControl.R = 1
    elseif key == "a" then flyControl.L = 1
    elseif key == "space" then flyControl.U = 1
    elseif key == "q" then flyControl.D = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode.Name:lower()
    if key == "w" then flyControl.F = 0
    elseif key == "s" then flyControl.B = 0
    elseif key == "d" then flyControl.R = 0
    elseif key == "a" then flyControl.L = 0
    elseif key == "space" then flyControl.U = 0
    elseif key == "q" then flyControl.D = 0 end
end)

---------------------------------------------------------
-- ФУНКЦИИ СЛЕПА
---------------------------------------------------------
local function GetCurrentSlap()
    local myChar = LocalPlayer.Character
    if not myChar then return "None" end
    for _, tool in ipairs(ToolsFolder:GetChildren()) do
        if myChar:FindFirstChild(tool.Name) then return tool.Name end
    end
    return "None"
end

local function SlapWithAllTools(targetChar, directionVector)
    local myChar = LocalPlayer.Character
    if not myChar then return end
    for _, tool in ipairs(ToolsFolder:GetChildren()) do
        local toolInChar = myChar:FindFirstChild(tool.Name)
        if toolInChar then
            local event = toolInChar:FindFirstChild("Event") or toolInChar:FindFirstChild("SlapEvent")
            if event then event:FireServer("slash", targetChar, directionVector) end
        end
    end
end

local function SlapAllTowardsMe()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = myChar.HumanoidRootPart
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = plr.Character.HumanoidRootPart
            local dir = (myRoot.Position - targetRoot.Position)
            if dir.Magnitude > 0 then
                SlapWithAllTools(plr.Character, dir.Unit * 25)
            end
        end
    end
end

local function SlapTornado()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = myChar.HumanoidRootPart
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = plr.Character.HumanoidRootPart
            local toMe = (myRoot.Position - targetRoot.Position)
            if toMe.Magnitude > 0 then
                local tangent = Vector3.new(-toMe.Z, 0, toMe.X).Unit
                local slapDirection = (toMe.Unit * 12) + (tangent * 22) + Vector3.new(0, 8, 0)
                SlapWithAllTools(plr.Character, slapDirection)
            end
        end
    end
end

---------------------------------------------------------
-- GUI
---------------------------------------------------------
local function CreateModernGui()
    local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("VoidSlapModernGUI")
    if oldGui then oldGui:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "VoidSlapModernGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(0, 300, 0, 290)
    shadow.Position = UDim2.new(0, 20, 0, 150)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0,0,0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = gui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 260, 0, 265)
    mainFrame.Position = UDim2.new(0, 20, 0, 12)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = shadow
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(100, 100, 200)
    stroke.Thickness = 2
    
    local strokeGradient = Instance.new("UIGradient", stroke)
    strokeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 150)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 255, 150))
    }
    
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 14)
    
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = ""
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18

    local slapIndicator = Instance.new("TextLabel", mainFrame)
    slapIndicator.Size = UDim2.new(0.88, 0, 0, 20)
    slapIndicator.Position = UDim2.new(0.06, 0, 0, 53)
    slapIndicator.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    slapIndicator.TextColor3 = Color3.fromRGB(255, 200, 100)
    slapIndicator.Font = Enum.Font.GothamSemibold
    slapIndicator.TextSize = 12
    Instance.new("UICorner", slapIndicator).CornerRadius = UDim.new(0, 6)
    
    local toggleBtn = Instance.new("TextButton", mainFrame)
    toggleBtn.Size = UDim2.new(0.88, 0, 0, 38)
    toggleBtn.Position = UDim2.new(0.06, 0, 0, 78)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggleBtn.Text = "⚡ OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 15
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

    local flyBtn = Instance.new("TextButton", mainFrame)
    flyBtn.Size = UDim2.new(0.88, 0, 0, 38)
    flyBtn.Position = UDim2.new(0.06, 0, 0, 188)
    flyBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 120)
    flyBtn.Text = "✈️ FLY: OFF"
    flyBtn.TextColor3 = Color3.new(1,1,1)
    flyBtn.Font = Enum.Font.GothamBold
    flyBtn.TextSize = 14
    Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 10)

    local modeContainer = Instance.new("Frame", mainFrame)
    modeContainer.Size = UDim2.new(0.88, 0, 0, 35)
    modeContainer.Position = UDim2.new(0.06, 0, 0, 145)
    modeContainer.BackgroundTransparency = 1

    local normalBtn = Instance.new("TextButton", modeContainer)
    normalBtn.Size = UDim2.new(0.48, 0, 1, 0)
    normalBtn.BackgroundColor3 = Color3.fromRGB(70, 160, 100)
    normalBtn.Text = "📍 NORMAL"
    normalBtn.TextColor3 = Color3.new(1,1,1)
    normalBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", normalBtn)

    local tornadoBtn = Instance.new("TextButton", modeContainer)
    tornadoBtn.Size = UDim2.new(0.48, 0, 1, 0)
    tornadoBtn.Position = UDim2.new(0.52, 0, 0, 0)
    tornadoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    tornadoBtn.Text = "🌪️ TORNADO"
    tornadoBtn.TextColor3 = Color3.new(1,1,1)
    tornadoBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", tornadoBtn)

    -- Функции обновления UI
    _G.UpdateFlyUI = function()
        if flyEnabled then
            flyBtn.Text = "✈️ FLY: ON"
            TweenService:Create(flyBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(120, 70, 180)}):Play()
        else
            flyBtn.Text = "✈️ FLY: OFF"
            TweenService:Create(flyBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 50, 120)}):Play()
        end
    end

    -- Логика кнопок
    toggleBtn.MouseButton1Click:Connect(function()
        auto = not auto
        toggleBtn.Text = auto and "⚡ ON" or "⚡ OFF"
        TweenService:Create(toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = auto and Color3.fromRGB(60, 140, 80) or Color3.fromRGB(50, 50, 70)}):Play()
    end)

    flyBtn.MouseButton1Click:Connect(toggleFly)

    normalBtn.MouseButton1Click:Connect(function()
        currentMode = "normal"
        normalBtn.BackgroundColor3 = Color3.fromRGB(70, 160, 100)
        tornadoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)

    tornadoBtn.MouseButton1Click:Connect(function()
        currentMode = "tornado"
        tornadoBtn.BackgroundColor3 = Color3.fromRGB(160, 70, 160)
        normalBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = shadow.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    -- Цикл обновления индикатора инструмента
    task.spawn(function()
        while true do
            local slap = GetCurrentSlap()
            slapIndicator.Text = "🔨 Slap: " .. slap
            slapIndicator.TextColor3 = slap == "None" and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
            task.wait(0.5)
        end
    end)

    -- Анимация градиента
    task.spawn(function()
        local r = 0
        while true do
            r = (r + 2) % 360
            strokeGradient.Rotation = r
            task.wait(0.03)
        end
    end)
end

CreateModernGui()

-- Главный цикл атаки
task.spawn(function()
    while true do
        if auto then
            pcall(function()
                if currentMode == "normal" then SlapAllTowardsMe()
                else SlapTornado() end
            end)
        end
        task.wait(0.12)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    stopFly()
end)

print("✅ VoidSlap Pro + Advance Fly Loaded!")
