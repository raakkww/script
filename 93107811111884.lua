local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- ==================== НАСТРОЙКИ ====================

local TARGET_POSITION = Vector3.new(-1915.5, 3.5, -119.99999237060547)

local RUN_SPEED = 500  -- Скорость бега

-- ===================================================

-- ==================== ОРИГИНАЛЬНАЯ ЗАГРУЗКА ====================

local loadingGui = Instance.new("ScreenGui")

loadingGui.Name = "LoadingGUI"

loadingGui.Parent = player:WaitForChild("PlayerGui")

local darkOverlay = Instance.new("Frame")

darkOverlay.Size = UDim2.new(1, 0, 1, 0)

darkOverlay.Position = UDim2.new(0, 0, 0, 0)

darkOverlay.BackgroundColor3 = Color3.new(0, 0, 0)

darkOverlay.BackgroundTransparency = 0.6

darkOverlay.Parent = loadingGui

local loadingFrame = Instance.new("Frame")

loadingFrame.Size = UDim2.new(0, 300, 0, 120)

loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -60)

loadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

loadingFrame.BackgroundTransparency = 0.1

loadingFrame.Parent = loadingGui

local loadingCorner = Instance.new("UICorner")

loadingCorner.CornerRadius = UDim.new(0, 12)

loadingCorner.Parent = loadingFrame

local loadingStroke = Instance.new("UIStroke")

loadingStroke.Color = Color3.fromRGB(100, 100, 100)

loadingStroke.Thickness = 2

loadingStroke.Parent = loadingFrame

local loadingText = Instance.new("TextLabel")

loadingText.Text = "🔄 LOADING TELEPORT MENU"

loadingText.Size = UDim2.new(1, 0, 0, 40)

loadingText.Position = UDim2.new(0, 0, 0, 10)

loadingText.BackgroundTransparency = 1

loadingText.TextColor3 = Color3.fromRGB(220, 220, 255)

loadingText.Font = Enum.Font.GothamBold

loadingText.TextSize = 16

loadingText.Parent = loadingFrame

local dotsLabel = Instance.new("TextLabel")

dotsLabel.Text = ""

dotsLabel.Size = UDim2.new(1, 0, 0, 30)

dotsLabel.Position = UDim2.new(0, 0, 0, 50)

dotsLabel.BackgroundTransparency = 1

dotsLabel.TextColor3 = Color3.fromRGB(0, 200, 255)

dotsLabel.Font = Enum.Font.GothamBold

dotsLabel.TextSize = 24

dotsLabel.Parent = loadingFrame

-- Анимация точек

local currentDots = 0

local maxDots = 3

local dotsDirection = 1

spawn(function()

    while true do

        wait(0.5)

        if dotsDirection == 1 then

            currentDots = currentDots + 1

            if currentDots >= maxDots then

                dotsDirection = -1

            end

        else

            currentDots = currentDots - 1

            if currentDots <= 0 then

                dotsDirection = 1

            end

        end

        

        local dots = ""

        for i = 1, currentDots do

            dots = dots .. "."

        end

        dotsLabel.Text = dots

    end

end)

-- Задержка загрузки

wait(2)

-- Удаляем загрузку

loadingGui:Destroy()

-- ==================== ОСНОВНОЙ СКРИПТ ====================

local isFarming = false

local farmConnection = nil

local originalPosition = nil

local originalWalkSpeed = nil

local bodyVelocity = nil

-- Функция для бесконечного бега вперед

local function startInfiniteRun()

    local character = player.Character

    if not character or not character:FindFirstChild("HumanoidRootPart") then

        return

    end

    

    local hrp = character.HumanoidRootPart

    

    -- Удаляем старый BodyVelocity если есть

    if bodyVelocity then

        bodyVelocity:Destroy()

        bodyVelocity = nil

    end

    

    -- Создаем BodyVelocity для бесконечного движения вперед

    bodyVelocity = Instance.new("BodyVelocity")

    bodyVelocity.Velocity = Vector3.new(0, 0, RUN_SPEED)  -- Бежим вперед по оси Z

    bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)  -- Только по X и Z

    bodyVelocity.P = 10000

    bodyVelocity.Parent = hrp

    

    -- Устанавливаем скорость ходьбы

    local humanoid = character:FindFirstChild("Humanoid")

    if humanoid then

        if not originalWalkSpeed then

            originalWalkSpeed = humanoid.WalkSpeed

        end

        humanoid.WalkSpeed = RUN_SPEED

    end

end

-- Функция остановки бега

local function stopInfiniteRun()

    -- Удаляем BodyVelocity

    if bodyVelocity then

        bodyVelocity:Destroy()

        bodyVelocity = nil

    end

    

    -- Восстанавливаем оригинальную скорость ходьбы

    local character = player.Character

    if character then

        local humanoid = character:FindFirstChild("Humanoid")

        if humanoid and originalWalkSpeed then

            humanoid.WalkSpeed = originalWalkSpeed

            originalWalkSpeed = nil

        end

    end

end

-- Функция телепортации

local function teleportToFarm()

    local character = player.Character

    if not character or not character:FindFirstChild("HumanoidRootPart") then

        return false

    end

    

    local hrp = character.HumanoidRootPart

    

    -- Сохраняем оригинальную позицию при первом телепорте

    if not originalPosition then

        originalPosition = hrp.CFrame

    end

    

    -- Телепортируем

    hrp.CFrame = CFrame.new(TARGET_POSITION)

    

    -- Запускаем бесконечный бег

    startInfiniteRun()

    

    return true

end

-- Функция сброса игрока

local function resetPlayer()

    -- Останавливаем бег

    stopInfiniteRun()

    

    -- Возвращаем на оригинальную позицию

    if originalPosition then

        local character = player.Character

        if character and character:FindFirstChild("HumanoidRootPart") then

            character.HumanoidRootPart.CFrame = originalPosition

        end

        originalPosition = nil

    end

end

-- Функция старта автофарма

local function startAutoFarm()

    if isFarming then return end

    

    isFarming = true

    

    -- Меняем текст

    if statusText then

        statusText.Text = "STATUS: ON"

        statusText.TextColor3 = Color3.fromRGB(50, 255, 50)

    end

    

    -- Меняем кнопку

    if farmButton then

        farmButton.Text = "TURN OFF"

        farmButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)

    end

    

    -- Запускаем цикл телепортации

    farmConnection = game:GetService("RunService").Heartbeat:Connect(function()

        if not isFarming then return end

        

        -- Телепортируем и запускаем бег

        teleportToFarm()

    end)

end

-- Функция остановки автофарма

local function stopAutoFarm()

    if not isFarming then return end

    

    isFarming = false

    

    if farmConnection then

        farmConnection:Disconnect()

        farmConnection = nil

    end

    

    -- Сбрасываем игрока

    resetPlayer()

    

    -- Меняем текст

    if statusText then

        statusText.Text = "STATUS: OFF"

        statusText.TextColor3 = Color3.fromRGB(255, 50, 50)

    end

    

    -- Меняем кнопку

    if farmButton then

        farmButton.Text = "TURN ON"

        farmButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

    end

end

-- ==================== СОЗДАЕМ МЕНЮ (ОСТАЕТСЯ ПОСЛЕ СМЕРТИ) ====================

local gui = Instance.new("ScreenGui")

gui.Name = "AutoFarmGUI"

gui.ResetOnSpawn = false  -- ОКНО НЕ УДАЛЯЕТСЯ ПРИ СМЕРТИ

gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")

frame.Size = UDim2.new(0, 180, 0, 140)

frame.Position = UDim2.new(0.5, -90, 0.5, -70)

frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

frame.BackgroundTransparency = 0.1

frame.Active = true

frame.Draggable = true

frame.Parent = gui

local UICorner = Instance.new("UICorner")

UICorner.CornerRadius = UDim.new(0, 12)

UICorner.Parent = frame

local UIStroke = Instance.new("UIStroke")

UIStroke.Color = Color3.fromRGB(100, 100, 100)

UIStroke.Thickness = 2

UIStroke.Parent = frame

-- Заголовок

local title = Instance.new("TextLabel")

title.Text = "AUTO TELEPORT"

title.Size = UDim2.new(1, 0, 0, 35)

title.Position = UDim2.new(0, 0, 0, 0)

title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

title.BackgroundTransparency = 0.2

title.TextColor3 = Color3.fromRGB(220, 220, 255)

title.Font = Enum.Font.GothamBold

title.TextSize = 16

title.Parent = frame

local titleCorner = Instance.new("UICorner")

titleCorner.CornerRadius = UDim.new(0, 12)

titleCorner.Parent = title

-- Крестик X

local closeButton = Instance.new("TextButton")

closeButton.Text = "X"

closeButton.Size = UDim2.new(0, 30, 0, 30)

closeButton.Position = UDim2.new(1, -35, 0, 3)

closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)

closeButton.BackgroundTransparency = 0.1

closeButton.TextColor3 = Color3.new(1, 1, 1)

closeButton.Font = Enum.Font.GothamBold

closeButton.TextSize = 16

closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")

closeCorner.CornerRadius = UDim.new(0, 8)

closeCorner.Parent = closeButton

local closeStroke = Instance.new("UIStroke")

closeStroke.Color = Color3.fromRGB(255, 100, 100)

closeStroke.Thickness = 1.5

closeStroke.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()

    stopAutoFarm()

    gui:Destroy()

end)

-- Текст статуса

statusText = Instance.new("TextLabel")

statusText.Name = "StatusText"

statusText.Text = "STATUS: OFF"

statusText.Size = UDim2.new(0, 140, 0, 30)

statusText.Position = UDim2.new(0, 20, 0, 45)

statusText.BackgroundTransparency = 1

statusText.TextColor3 = Color3.fromRGB(255, 50, 50)

statusText.Font = Enum.Font.GothamBold

statusText.TextSize = 18

statusText.Parent = frame

-- Кнопка ON/OFF

farmButton = Instance.new("TextButton")

farmButton.Name = "FarmButton"

farmButton.Text = "TURN ON"

farmButton.Size = UDim2.new(0, 140, 0, 40)

farmButton.Position = UDim2.new(0, 20, 0, 85)

farmButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)

farmButton.BackgroundTransparency = 0.1

farmButton.TextColor3 = Color3.new(1, 1, 1)

farmButton.Font = Enum.Font.GothamBold

farmButton.TextSize = 16

farmButton.Parent = frame

local farmCorner = Instance.new("UICorner")

farmCorner.CornerRadius = UDim.new(0, 10)

farmCorner.Parent = farmButton

local farmStroke = Instance.new("UIStroke")

farmStroke.Color = Color3.fromRGB(100, 255, 100)

farmStroke.Thickness = 2

farmStroke.Parent = farmButton

-- Обработчик кнопки

farmButton.MouseButton1Click:Connect(function()

    if isFarming then

        stopAutoFarm()

    else

        startAutoFarm()

    end

end)

-- Эффекты кнопки

farmButton.MouseEnter:Connect(function()

    farmButton.BackgroundTransparency = 0

end)

farmButton.MouseLeave:Connect(function()

    farmButton.BackgroundTransparency = 0.1

end)

-- Эффекты крестика

closeButton.MouseEnter:Connect(function()

    closeButton.BackgroundColor3 = Color3.fromRGB(240, 70, 70)

end)

closeButton.MouseLeave:Connect(function()

    closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)

end)

-- Тень

local shadow = Instance.new("ImageLabel")

shadow.Image = "rbxassetid://5554236805"

shadow.Size = UDim2.new(1, 20, 1, 20)

shadow.Position = UDim2.new(0, -10, 0, -10)

shadow.BackgroundTransparency = 1

shadow.ImageTransparency = 0.8

shadow.Parent = frame

print("=== AUTO TELEPORT FARM READY ===")

print("Features:")

print("1. Player runs forward INFINITELY at speed 500")

print("2. BodyVelocity forces constant movement")

print("3. Window stays after death")

print("4. Full reset when turned OFF")
