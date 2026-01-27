local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP = game.Players.LocalPlayer
local BallShadow, RealBall
local WhiteColor = Color3.new(1, 1, 1)
local LastBallPos
local SpeedMulty = 3
local AutoParryEnabled = true

-- Optimized Parry Settings
local ParryDistance = 15
local ReactionTime = 0 -- Instant reaction
local SafetyMargin = 1.5
local PredictionFrames = 0.5 -- Predict ball position

local AutoClickerEnabled = false
local ClickSpeed = 1000
local LastClickTime = 0

local LastParryTime = 0
local ParryCooldown = 0 -- No cooldown for faster response
local IsParrying = false

local VisualZoneEnabled = true
local ZoneSphere = nil
local DarkTheme = true

-- Ball velocity tracking for prediction
local BallVelocityHistory = {}
local MaxVelocityHistory = 5



-- Основная функция инициализации скрипта
function InitializeMainScript()
    -- Создаем основной GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeathBallProGUI"
    ScreenGui.Parent = LP:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    MainFrame.Visible = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    TitleBar.BorderSizePixel = 2
    TitleBar.BorderColor3 = Color3.new(0.4, 0.4, 0.4)
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Death Ball Pro [OPTIMIZED]"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = TitleBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0.15, 0, 1, 0)
    CloseButton.Position = UDim2.new(0.85, 0, 0, 0)
    CloseButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    CloseButton.BorderSizePixel = 2
    CloseButton.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton

    local CoordinatesLabel = Instance.new("TextLabel")
    CoordinatesLabel.Size = UDim2.new(0.9, 0, 0, 50)
    CoordinatesLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
    CoordinatesLabel.BackgroundTransparency = 1
    CoordinatesLabel.Text = "X: 0.0 | Y: 0.0 | Z: 0.0\nSpeed: 0.0 | Height: 0.0\nPrediction: Ready"
    CoordinatesLabel.TextColor3 = Color3.new(1, 1, 1)
    CoordinatesLabel.TextSize = 11
    CoordinatesLabel.Font = Enum.Font.Gotham
    CoordinatesLabel.TextWrapped = true
    CoordinatesLabel.Parent = MainFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
    StatusLabel.Position = UDim2.new(0.05, 0, 0.32, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Searching for ball..."
    StatusLabel.TextColor3 = Color3.new(1, 1, 1)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame

    local DistanceFrame = Instance.new("Frame")
    DistanceFrame.Size = UDim2.new(0.9, 0, 0, 40)
    DistanceFrame.Position = UDim2.new(0.05, 0, 0.42, 0)
    DistanceFrame.BackgroundTransparency = 1
    DistanceFrame.Parent = MainFrame

    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Size = UDim2.new(1, 0, 0, 15)
    DistanceLabel.Position = UDim2.new(0, 0, 0, 0)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.Text = "Parry Distance: 15"
    DistanceLabel.TextColor3 = Color3.new(1, 1, 1)
    DistanceLabel.TextSize = 12
    DistanceLabel.Font = Enum.Font.Gotham
    DistanceLabel.Parent = DistanceFrame

    local DistanceSlider = Instance.new("Frame")
    DistanceSlider.Size = UDim2.new(1, 0, 0, 15)
    DistanceSlider.Position = UDim2.new(0, 0, 0, 20)
    DistanceSlider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    DistanceSlider.BorderSizePixel = 1
    DistanceSlider.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    DistanceSlider.Parent = DistanceFrame

    local DistanceSliderCorner = Instance.new("UICorner")
    DistanceSliderCorner.CornerRadius = UDim.new(0, 7)
    DistanceSliderCorner.Parent = DistanceSlider

    local DistanceFill = Instance.new("Frame")
    DistanceFill.Size = UDim2.new(0.5, 0, 1, 0)
    DistanceFill.Position = UDim2.new(0, 0, 0, 0)
    DistanceFill.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    DistanceFill.BorderSizePixel = 1
    DistanceFill.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    DistanceFill.Parent = DistanceSlider

    local DistanceFillCorner = Instance.new("UICorner")
    DistanceFillCorner.CornerRadius = UDim.new(0, 7)
    DistanceFillCorner.Parent = DistanceFill

    local DistanceThumb = Instance.new("Frame")
    DistanceThumb.Size = UDim2.new(0, 10, 0, 20)
    DistanceThumb.Position = UDim2.new(0.5, -5, -0.15, 0)
    DistanceThumb.BackgroundColor3 = Color3.new(1, 1, 1)
    DistanceThumb.BorderSizePixel = 2
    DistanceThumb.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    DistanceThumb.Parent = DistanceSlider

    local DistanceThumbCorner = Instance.new("UICorner")
    DistanceThumbCorner.CornerRadius = UDim.new(0, 3)
    DistanceThumbCorner.Parent = DistanceThumb

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.45, 0, 0, 25)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.62, 0)
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    ToggleButton.BorderSizePixel = 2
    ToggleButton.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    ToggleButton.Text = "Auto-ON"
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.TextSize = 11
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = MainFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleButton

    local ClickerButton = Instance.new("TextButton")
    ClickerButton.Size = UDim2.new(0.45, 0, 0, 25)
    ClickerButton.Position = UDim2.new(0.52, 0, 0.62, 0)
    ClickerButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    ClickerButton.BorderSizePixel = 2
    ClickerButton.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    ClickerButton.Text = "Clicker OFF"
    ClickerButton.TextColor3 = Color3.new(1, 1, 1)
    ClickerButton.TextSize = 11
    ClickerButton.Font = Enum.Font.Gotham
    ClickerButton.Parent = MainFrame

    local ClickerCorner = Instance.new("UICorner")
    ClickerCorner.CornerRadius = UDim.new(0, 6)
    ClickerCorner.Parent = ClickerButton

    local ZoneButton = Instance.new("TextButton")
    ZoneButton.Size = UDim2.new(0.45, 0, 0, 25)
    ZoneButton.Position = UDim2.new(0.05, 0, 0.74, 0)
    ZoneButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    ZoneButton.BorderSizePixel = 2
    ZoneButton.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    ZoneButton.Text = "Zone ON"
    ZoneButton.TextColor3 = Color3.new(1, 1, 1)
    ZoneButton.TextSize = 11
    ZoneButton.Font = Enum.Font.Gotham
    ZoneButton.Parent = MainFrame

    local ZoneCorner = Instance.new("UICorner")
    ZoneCorner.CornerRadius = UDim.new(0, 6)
    ZoneCorner.Parent = ZoneButton

    local ThemeButton = Instance.new("TextButton")
    ThemeButton.Size = UDim2.new(0.45, 0, 0, 25)
    ThemeButton.Position = UDim2.new(0.52, 0, 0.74, 0)
    ThemeButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    ThemeButton.BorderSizePixel = 2
    ThemeButton.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
    ThemeButton.Text = "Light Theme"
    ThemeButton.TextColor3 = Color3.new(1, 1, 1)
    ThemeButton.TextSize = 11
    ThemeButton.Font = Enum.Font.Gotham
    ThemeButton.Parent = MainFrame

    local ThemeCorner = Instance.new("UICorner")
    ThemeCorner.CornerRadius = UDim.new(0, 6)
    ThemeCorner.Parent = ThemeButton

    local PredictionLabel = Instance.new("TextLabel")
    PredictionLabel.Size = UDim2.new(0.9, 0, 0, 20)
    PredictionLabel.Position = UDim2.new(0.05, 0, 0.87, 0)
    PredictionLabel.BackgroundTransparency = 1
    PredictionLabel.Text = "⚡ Optimized Mode Active"
    PredictionLabel.TextColor3 = Color3.new(0.2, 1, 0.2)
    PredictionLabel.TextSize = 11
    PredictionLabel.Font = Enum.Font.GothamBold
    PredictionLabel.Parent = MainFrame

    local useClickF = true

    local dragging = false
    local dragStart = nil
    local startPos = nil

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local function CreateZoneSphere()
        if ZoneSphere then
            ZoneSphere:Destroy()
        end
        
        ZoneSphere = Instance.new("Part")
        ZoneSphere.Name = "ParryZoneSphere"
        ZoneSphere.Anchored = true
        ZoneSphere.CanCollide = false
        ZoneSphere.Material = Enum.Material.Neon
        ZoneSphere.BrickColor = BrickColor.new("Bright green")
        ZoneSphere.Transparency = 0.7
        ZoneSphere.Shape = Enum.PartType.Ball
        ZoneSphere.Size = Vector3.new(ParryDistance * 2, ParryDistance * 2, ParryDistance * 2)
        ZoneSphere.Parent = workspace
        
        return ZoneSphere
    end

    local function UpdateZoneSphere()
        if not ZoneSphere or not VisualZoneEnabled then return end
        
        if LP.Character and LP.Character.PrimaryPart then
            local characterPos = LP.Character.PrimaryPart.Position
            ZoneSphere.Position = characterPos
            ZoneSphere.Size = Vector3.new(ParryDistance * 2, ParryDistance * 2, ParryDistance * 2)
            
            if AutoParryEnabled then
                ZoneSphere.BrickColor = BrickColor.new("Bright green")
            else
                ZoneSphere.BrickColor = BrickColor.new("Bright red")
            end
        end
    end

    local function ToggleVisualZone()
        VisualZoneEnabled = not VisualZoneEnabled
        
        if VisualZoneEnabled then
            if not ZoneSphere then
                CreateZoneSphere()
            else
                ZoneSphere.Transparency = 0.7
            end
            ZoneButton.Text = "Zone ON"
            ZoneButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        else
            if ZoneSphere then
                ZoneSphere.Transparency = 1
            end
            ZoneButton.Text = "Zone OFF"
            ZoneButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        end
    end

    local function ToggleTheme()
        DarkTheme = not DarkTheme
        
        if DarkTheme then
            MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            TitleBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            Title.TextColor3 = Color3.new(1, 1, 1)
            CoordinatesLabel.TextColor3 = Color3.new(1, 1, 1)
            StatusLabel.TextColor3 = Color3.new(1, 1, 1)
            DistanceLabel.TextColor3 = Color3.new(1, 1, 1)
            ThemeButton.Text = "Light Theme"
        else
            MainFrame.BackgroundColor3 = Color3.new(1, 1, 1)
            TitleBar.BackgroundColor3 = Color3.new(1, 1, 1)
            Title.TextColor3 = Color3.new(0, 0, 0)
            CoordinatesLabel.TextColor3 = Color3.new(0, 0, 0)
            StatusLabel.TextColor3 = Color3.new(0, 0, 0)
            DistanceLabel.TextColor3 = Color3.new(0, 0, 0)
            ThemeButton.Text = "Dark Theme"
        end
    end

    local function GetBallColor()
        if not RealBall then return WhiteColor end
        
        local highlight = RealBall:FindFirstChildOfClass("Highlight")
        if highlight then
            return highlight.FillColor
        end
        
        local surfaceGui = RealBall:FindFirstChildOfClass("SurfaceGui")
        if surfaceGui then
            local frame = surfaceGui:FindFirstChildOfClass("Frame")
            if frame and frame.BackgroundColor3 then
                return frame.BackgroundColor3
            end
        end
        
        if RealBall:IsA("Part") and RealBall.BrickColor ~= BrickColor.new("White") then
            return RealBall.Color
        end
        
        return WhiteColor
    end

    local function UltraAutoClicker()
        if not useClickF or not AutoClickerEnabled then return end
        
        local currentTime = tick()
        local timeBetweenClicks = 1 / ClickSpeed
        
        if currentTime - LastClickTime >= timeBetweenClicks then
            VirtualInputManager:SendKeyEvent(true, "F", false, game)
            VirtualInputManager:SendKeyEvent(false, "F", false, game)
            LastClickTime = currentTime
        end
    end

    local function Parry()
        if IsParrying then return end
        
        IsParrying = true
        local currentTime = tick()
        
        if currentTime - LastParryTime < ParryCooldown then
            IsParrying = false
            return
        end
        
        if useClickF then
            VirtualInputManager:SendKeyEvent(true, "F", false, game)
            VirtualInputManager:SendKeyEvent(false, "F", false, game)
        else 
            mouse1click()
        end
        
        LastParryTime = currentTime
        task.spawn(function()
            task.wait(0.05)
            IsParrying = false
        end)
    end

    -- Optimized ball velocity tracking
    local function UpdateVelocityHistory(velocity)
        table.insert(BallVelocityHistory, velocity)
        if #BallVelocityHistory > MaxVelocityHistory then
            table.remove(BallVelocityHistory, 1)
        end
    end

    local function GetAverageVelocity()
        if #BallVelocityHistory == 0 then return Vector3.new(0, 0, 0) end
        
        local sum = Vector3.new(0, 0, 0)
        for _, v in ipairs(BallVelocityHistory) do
            sum = sum + v
        end
        return sum / #BallVelocityHistory
    end

    local function PredictBallPosition(currentPos, velocity, frames)
        local deltaTime = 0.016667 * frames -- 60 FPS
        return currentPos + (velocity * deltaTime)
    end

    local function CalculateBallHeight(shadowSize)
        local baseShadowSize = 5
        local heightMultiplier = 8
        
        local shadowIncrease = math.max(0, shadowSize - baseShadowSize)
        local estimatedHeight = shadowIncrease * heightMultiplier
        
        return math.min(estimatedHeight, 50)
    end

    local function GetMaxHeightBySpeed(speedStuds)
        if speedStuds < 10 then
            return 225
        else
            return 240
        end
    end

    local function CalculateOptimalParryDistance(speed, horizontalDistance, ballHeight, playerPosY, ballPosY)
        local maxHeight = GetMaxHeightBySpeed(speed)
        if (ballPosY - playerPosY) > maxHeight then
            return math.huge
        end
        
        local baseDistance = ParryDistance
        local reactionDistance = speed * ReactionTime * SafetyMargin
        local optimalDistance = baseDistance + reactionDistance
        
        -- Enhanced speed-based adjustments
        if speed > 25 then
            optimalDistance = optimalDistance * 1.6
        elseif speed > 20 then
            optimalDistance = optimalDistance * 1.5
        elseif speed > 15 then
            optimalDistance = optimalDistance * 1.4
        elseif speed > 12 then
            optimalDistance = optimalDistance * 1.3
        elseif speed > 8 then
            optimalDistance = optimalDistance * 1.2
        end
        
        return optimalDistance
    end

    local function IsBallComingTowardsPlayer(ballPos, lastPos, playerPos)
        if not lastPos then return true end
        
        local ballToPlayer = (playerPos - ballPos).Unit
        local ballMovement = (ballPos - lastPos).Unit
        
        local dotProduct = ballToPlayer:Dot(ballMovement)
        
        return dotProduct > 0.05 -- More sensitive detection
    end

    local function UpdateDistanceSlider(value)
        ParryDistance = 5 + (value / 100) * 20
        DistanceFill.Size = UDim2.new(value / 100, 0, 1, 0)
        DistanceThumb.Position = UDim2.new(value / 100, -5, -0.15, 0)
        DistanceLabel.Text = "Parry Distance: " .. math.floor(ParryDistance)
        
        if ZoneSphere and VisualZoneEnabled then
            ZoneSphere.Size = Vector3.new(ParryDistance * 2, ParryDistance * 2, ParryDistance * 2)
        end
    end

    local function SetupSliderDrag(slider, thumb, fill, callback)
        local dragging = false
        
        local function updateFromMouse()
            if not dragging then return end
            
            local mousePos = UserInputService:GetMouseLocation()
            local sliderAbsPos = slider.AbsolutePosition
            local sliderAbsSize = slider.AbsoluteSize
            
            local relativeX = (mousePos.X - sliderAbsPos.X) / sliderAbsSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            callback(relativeX * 100)
        end
        
        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateFromMouse()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateFromMouse()
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    ToggleButton.MouseButton1Click:Connect(function()
        AutoParryEnabled = not AutoParryEnabled
        ToggleButton.BackgroundColor3 = AutoParryEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.3, 0.3, 0.3)
        ToggleButton.Text = AutoParryEnabled and "Auto-ON" or "Auto-OFF"
    end)

    ClickerButton.MouseButton1Click:Connect(function()
        AutoClickerEnabled = not AutoClickerEnabled
        ClickerButton.BackgroundColor3 = AutoClickerEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.3, 0.3, 0.3)
        ClickerButton.Text = AutoClickerEnabled and "Clicker ON" or "Clicker OFF"
    end)

    ZoneButton.MouseButton1Click:Connect(function()
        ToggleVisualZone()
    end)

    ThemeButton.MouseButton1Click:Connect(function()
        ToggleTheme()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    SetupSliderDrag(DistanceSlider, DistanceThumb, DistanceFill, UpdateDistanceSlider)

    UpdateDistanceSlider(50)

    CreateZoneSphere()

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.K then
            MainFrame.Visible = not MainFrame.Visible
        
        elseif input.KeyCode == Enum.KeyCode.E then
            AutoClickerEnabled = not AutoClickerEnabled
            ClickerButton.BackgroundColor3 = AutoClickerEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.3, 0.3, 0.3)
            ClickerButton.Text = AutoClickerEnabled and "Clicker ON" or "Clicker OFF"
        
        elseif input.KeyCode == Enum.KeyCode.F then
            Parry()
        end
    end)

    -- Main optimized loop
    RunService.Heartbeat:Connect(function()
        UpdateZoneSphere()
        
        if AutoClickerEnabled and useClickF then
            UltraAutoClicker()
        end
        
        if not BallShadow then
            BallShadow = game.Workspace.FX:FindFirstChild("BallShadow")
        end
        
        if not RealBall then
            RealBall = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Part")
        end
        
        if BallShadow then
            if not LastBallPos then
                LastBallPos = BallShadow.Position
                if StatusLabel.Text ~= "Ball detected" then
                    StatusLabel.Text = "Ball detected"
                end
            end
        else
            if StatusLabel.Text ~= "Searching..." then
                StatusLabel.Text = "Searching..."
            end
        end
        
        if BallShadow and (not BallShadow.Parent) then
            if StatusLabel.Text ~= "Ball removed" then
                StatusLabel.Text = "Ball removed"
            end
            BallShadow = nil
            RealBall = nil
            BallVelocityHistory = {}
        end
        
        if BallShadow and LP.Character and LP.Character.PrimaryPart then
            local BallPos = BallShadow.Position
            local PlayerPos = LP.Character.PrimaryPart.Position
            
            if not LastBallPos then 
                LastBallPos = BallPos 
            end

            -- Calculate velocity
            local currentVelocity = (BallPos - LastBallPos) / 0.016667
            UpdateVelocityHistory(currentVelocity)
            local avgVelocity = GetAverageVelocity()
            
            -- Predict future position
            local predictedPos = PredictBallPosition(BallPos, avgVelocity, PredictionFrames)
            
            local currentShadowSize = BallShadow.Size.X
            local ballHeight = CalculateBallHeight(currentShadowSize)
            local ballPosY = BallPos.Y + ballHeight
            
            local moveDir = (LastBallPos - BallPos)
            local horizontalSpeed = Vector3.new(moveDir.X, 0, moveDir.Z).Magnitude
            local speedStuds = (horizontalSpeed + 0.25) * SpeedMulty
            
            local horizontalDistance = (Vector3.new(PlayerPos.X, 0, PlayerPos.Z) - Vector3.new(BallPos.X, 0, BallPos.Z)).Magnitude
            local predictedDistance = (Vector3.new(PlayerPos.X, 0, PlayerPos.Z) - Vector3.new(predictedPos.X, 0, predictedPos.Z)).Magnitude
            local verticalDistance = ballPosY - PlayerPos.Y
            
            local ballColor = GetBallColor()
            local isBallWhite = ballColor == WhiteColor
            
            local maxHeight = GetMaxHeightBySpeed(speedStuds)
            
            local isComingTowardsPlayer = IsBallComingTowardsPlayer(BallPos, LastBallPos, PlayerPos)
            local optimalDistance = CalculateOptimalParryDistance(speedStuds, horizontalDistance, ballHeight, PlayerPos.Y, ballPosY)
            
            -- Update UI only when needed (optimization)
            if tick() % 0.1 < 0.016 then -- Update every 0.1 seconds
                CoordinatesLabel.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f\nSpeed: %.1f | Height: %.1f\nPredicted: %.1f", 
                    BallPos.X, ballPosY, BallPos.Z, speedStuds, ballHeight, predictedDistance)
            end
            
            if isBallWhite then
                if StatusLabel.Text ~= "White ball - Safe mode" then
                    StatusLabel.Text = "White ball - Safe mode"
                    PredictionLabel.TextColor3 = Color3.new(1, 1, 1)
                end
            elseif verticalDistance > maxHeight then
                if not string.find(StatusLabel.Text, "too high") then
                    StatusLabel.Text = "Ball too high"
                    PredictionLabel.TextColor3 = Color3.new(1, 0.5, 0)
                end
            else
                if StatusLabel.Text ~= "⚡ Tracking & Predicting" then
                    StatusLabel.Text = "⚡ Tracking & Predicting"
                    PredictionLabel.TextColor3 = Color3.new(0.2, 1, 0.2)
                end
            end
            
            -- Optimized auto parry with prediction
            if AutoParryEnabled then
                local shouldParryNow = (predictedDistance <= optimalDistance or horizontalDistance <= optimalDistance * 0.8)
                    and isComingTowardsPlayer 
                    and verticalDistance <= maxHeight
                    and not isBallWhite
                    and not IsParrying
                
                if shouldParryNow then
                    Parry()
                    PredictionLabel.Text = "⚡ PARRY EXECUTED!"
                    task.delay(0.5, function()
                        PredictionLabel.Text = "⚡ Optimized Mode Active"
                    end)
                end
            end
            
            LastBallPos = BallPos
        end
    end)
end

-- Jika ключ sudah верифицирован, сразу запускаем основной скрипт
InitializeMainScript()
