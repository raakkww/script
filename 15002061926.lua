--//========================================================================================================
--// NoHub By Noctyra - Death Ball Pro (WindUI Conversion)
--// Credits: NoHub - Noctyra | WindUI by Footagesus
--// Mobile & PC Optimized | Full Rebranding Applied
--//========================================================================================================

-- Safety check for LocalPlayer
if not game:GetService("Players").LocalPlayer then
    warn("NoHub: LocalPlayer not found - aborting initialization")
    return
end

-- Load WindUI library (mobile/PC compatible)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Mandatory startup branding
print("NoHub By Noctyra Loaded")
WindUI:Notify({
    Title = "NoHub",
    Content = "Death Ball Pro loaded successfully!",
    Icon = "check",
    Duration = 4
})

-- Services & Variables (preserved from original logic)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local BallShadow, RealBall
local WhiteColor = Color3.new(1, 1, 1)
local LastBallPos
local SpeedMulty = 3
local AutoParryEnabled = true

-- Optimized Parry Settings (preserved)
local ParryDistance = 15
local ReactionTime = 0
local SafetyMargin = 1.5
local PredictionFrames = 0.5

local AutoClickerEnabled = false
local ClickSpeed = 1000
local LastClickTime = 0

local LastParryTime = 0
local ParryCooldown = 0
local IsParrying = false

local VisualZoneEnabled = true
local ZoneSphere = nil
local DarkTheme = true

-- Ball velocity tracking (preserved)
local BallVelocityHistory = {}
local MaxVelocityHistory = 5

--//========================================================================================================
--// WINDUI WINDOW CREATION WITH MANDATORY BRANDING
--//========================================================================================================
local Window = WindUI:CreateWindow({
    Title = "NoHub | Death Ball",
    Folder = "NoHub_DeathBall",
    Icon = "solar:target-bold",
    HideSearchBar = true,
    NewElements = true,
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
    OpenButton = {
        Title = "Open NoHub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.6,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"),
            Color3.fromHex("#ECA201")
        )
    }
})

-- Mandatory credit tag (NoHub branding requirement)
Window:Tag({
    Title = "NoHub • Noctyra",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

--//========================================================================================================
--// WINDUI TAB STRUCTURE (Mobile-Optimized Layout)
--//========================================================================================================

-- Tab 1: Auto Parry Controls
local ParryTab = Window:Tab({
    Title = "Auto Parry",
    Icon = "solar:shield-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    Border = true
})

local ParrySection = ParryTab:Section({
    Title = "Parry Settings",
})

-- Auto-Parry Toggle
local ParryToggle = ParrySection:Toggle({
    Flag = "AutoParry",
    Title = "Auto Parry",
    Desc = "Automatically parry incoming balls",
    Value = AutoParryEnabled,
    Callback = function(state)
        AutoParryEnabled = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Auto Parry " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

-- Parry Distance Slider (5-25 range)
local DistanceSlider = ParrySection:Slider({
    Flag = "ParryDistance",
    Title = "Parry Distance",
    Desc = "Detection radius for incoming balls",
    Step = 1,
    Value = {
        Min = 5,
        Max = 25,
        Default = 15
    },
    Callback = function(value)
        ParryDistance = value
        if ZoneSphere and VisualZoneEnabled then
            ZoneSphere.Size = Vector3.new(ParryDistance * 2, ParryDistance * 2, ParryDistance * 2)
        end
    end
})

-- Prediction Status (real-time updates using :Set())
local PredictionStatus = ParrySection:Section({
    Title = "Prediction Status",
    Box = true,
    BoxBorder = true,
    Opened = true
})

local PredictionLabel = PredictionStatus:Section({
    Title = "⚡ Optimized Mode Active",
    TextSize = 16,
    TextTransparency = 0.2,
    FontWeight = Enum.FontWeight.SemiBold
})

-- Tab 2: Visuals & Zone
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "solar:eye-bold",
    IconColor = Color3.fromHex("#30FF6A"),
    Border = true
})

local VisualsSection = VisualsTab:Section({
    Title = "Visual Settings",
})

-- Visual Zone Toggle (sphere around player)
local ZoneToggle = VisualsSection:Toggle({
    Flag = "VisualZone",
    Title = "Parry Zone",
    Desc = "Show visual sphere for parry range",
    Value = VisualZoneEnabled,
    Callback = function(state)
        VisualZoneEnabled = state
        if state then
            if not ZoneSphere then CreateZoneSphere() end
            ZoneSphere.Transparency = 0.7
        else
            if ZoneSphere then ZoneSphere.Transparency = 1 end
        end
        WindUI:Notify({
            Title = "NoHub",
            Content = "Visual Zone " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

-- Theme Toggle (Dark/Light)
VisualsSection:Button({
    Title = "Toggle Theme",
    Desc = "Switch between dark and light UI themes",
    Icon = "solar:moon-bold",
    Callback = function()
        DarkTheme = not DarkTheme
        if DarkTheme then
            Window:Set({
                Background = Color3.fromHex("#121212"),
                PanelBackground = Color3.fromHex("#1a1a1a"),
                TextColor = Color3.fromHex("#ffffff")
            })
            WindUI:Notify({
                Title = "NoHub",
                Content = "Dark theme activated",
                Duration = 2
            })
        else
            Window:Set({
                Background = Color3.fromHex("#f5f5f5"),
                PanelBackground = Color3.fromHex("#ffffff"),
                TextColor = Color3.fromHex("#000000")
            })
            WindUI:Notify({
                Title = "NoHub",
                Content = "Light theme activated",
                Duration = 2
            })
        end
    end
})

-- Tab 3: Real-time Stats (using :Set() for live updates)
local StatsTab = Window:Tab({
    Title = "Stats",
    Icon = "solar:graph-bold",
    IconColor = Color3.fromHex("#257AF7"),
    Border = true
})

local StatsSection = StatsTab:Section({
    Title = "Ball Tracking",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Coordinates display (updated via :Set() in main loop)
local CoordinatesDisplay = StatsSection:Section({
    Title = "X: 0.0 | Y: 0.0 | Z: 0.0\nSpeed: 0.0 | Height: 0.0\nPrediction: Ready",
    TextSize = 14,
    TextTransparency = 0.4
})

-- Status display (updated via :Set() in main loop)
local StatusDisplay = StatsSection:Section({
    Title = "Searching for ball...",
    TextSize = 16,
    TextTransparency = 0.2,
    FontWeight = Enum.FontWeight.SemiBold
})

-- Tab 4: Controls Info
local InfoTab = Window:Tab({
    Title = "Controls",
    Icon = "solar:keyboard-bold",
    IconColor = Color3.fromHex("#ECA201"),
    Border = true
})

InfoTab:Section({
    Title = "Keybinds",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold
})

InfoTab:Section({
    Title = "K",
    Desc = "Toggle UI visibility",
    Box = true,
    BoxBorder = true
})

InfoTab:Section({
    Title = "E",
    Desc = "Toggle Auto Clicker (F-spam)",
    Box = true,
    BoxBorder = true
})

InfoTab:Section({
    Title = "F",
    Desc = "Manual parry (override auto-parry)",
    Box = true,
    BoxBorder = true
})

--//========================================================================================================
--// CORE GAME LOGIC (Preserved 100% from original script)
--//========================================================================================================

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
    ZoneSphere.Transparency = VisualZoneEnabled and 0.7 or 1
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
    local currentTime = tick()
    local timeBetweenClicks = 1 / ClickSpeed
    
    if currentTime - LastClickTime >= timeBetweenClicks then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
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
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    
    LastParryTime = currentTime
    task.spawn(function()
        task.wait(0.05)
        IsParrying = false
    end)
    
    -- Visual feedback via WindUI notification
    PredictionLabel:Set("⚡ PARRY EXECUTED!")
    task.delay(0.5, function()
        if PredictionLabel.Destroy then
            PredictionLabel:Set("⚡ Optimized Mode Active")
        end
    end)
end

-- Ball physics helpers (preserved)
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
    local deltaTime = 0.016667 * frames
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
    return speedStuds < 10 and 225 or 240
end

local function CalculateOptimalParryDistance(speed, horizontalDistance, ballHeight, playerPosY, ballPosY)
    local maxHeight = GetMaxHeightBySpeed(speed)
    if (ballPosY - playerPosY) > maxHeight then
        return math.huge
    end
    
    local baseDistance = ParryDistance
    local reactionDistance = speed * ReactionTime * SafetyMargin
    local optimalDistance = baseDistance + reactionDistance
    
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
    return ballToPlayer:Dot(ballMovement) > 0.05
end

--//========================================================================================================
--// MAIN GAME LOOP (Optimized with WindUI updates)
--//========================================================================================================

-- Initialize zone sphere
CreateZoneSphere()

-- Keybinds setup
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        Window:SetVisible(not Window.Visible)
    elseif input.KeyCode == Enum.KeyCode.E then
        AutoClickerEnabled = not AutoClickerEnabled
        -- No UI update needed - WindUI toggle handles state
    elseif input.KeyCode == Enum.KeyCode.F then
        Parry()
    end
end)

-- Main optimized loop
RunService.Heartbeat:Connect(function()
    UpdateZoneSphere()
    
    if AutoClickerEnabled then
        UltraAutoClicker()
    end
    
    -- Ball detection logic (preserved)
    if not BallShadow then
        BallShadow = game.Workspace:FindFirstChild("FX") and game.Workspace.FX:FindFirstChild("BallShadow")
    end
    
    if not RealBall then
        RealBall = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Part")
    end
    
    if BallShadow then
        if not LastBallPos then
            LastBallPos = BallShadow.Position
            StatusDisplay:Set("Ball detected")
        end
    else
        if StatusDisplay.Set then
            StatusDisplay:Set("Searching for ball...")
        end
    end
    
    if BallShadow and (not BallShadow.Parent) then
        BallShadow = nil
        RealBall = nil
        BallVelocityHistory = {}
        if StatusDisplay.Set then
            StatusDisplay:Set("Ball removed - resetting")
        end
    end
    
    if BallShadow and LP.Character and LP.Character.PrimaryPart then
        local BallPos = BallShadow.Position
        local PlayerPos = LP.Character.PrimaryPart.Position
        
        if not LastBallPos then 
            LastBallPos = BallPos 
        end

        -- Physics calculations (preserved)
        local currentVelocity = (BallPos - LastBallPos) / 0.016667
        UpdateVelocityHistory(currentVelocity)
        local avgVelocity = GetAverageVelocity()
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
        
        -- Update UI stats (using :Set() for real-time updates)
        if tick() % 0.1 < 0.016 then
            if CoordinatesDisplay.Set then
                CoordinatesDisplay:Set(string.format("X: %.1f | Y: %.1f | Z: %.1f\nSpeed: %.1f | Height: %.1f\nPredicted Dist: %.1f", 
                    BallPos.X, ballPosY, BallPos.Z, speedStuds, ballHeight, predictedDistance))
            end
        end
        
        -- Status updates with proper branding
        if isBallWhite then
            if StatusDisplay.Set then
                StatusDisplay:Set("White ball - Safe mode")
                PredictionLabel:Set("⚪ Safe Mode (White Ball)")
            end
        elseif verticalDistance > maxHeight then
            if StatusDisplay.Set then
                StatusDisplay:Set("Ball too high - ignoring")
                PredictionLabel:Set("⚠️ Too High - Ignoring")
            end
        else
            if StatusDisplay.Set then
                StatusDisplay:Set("⚡ Tracking & Predicting")
                PredictionLabel:Set("⚡ Optimized Mode Active")
            end
        end
        
        -- Optimized auto parry with prediction (preserved logic)
        if AutoParryEnabled then
            local shouldParryNow = (predictedDistance <= optimalDistance or horizontalDistance <= optimalDistance * 0.8)
                and isComingTowardsPlayer 
                and verticalDistance <= maxHeight
                and not isBallWhite
                and not IsParrying
            
            if shouldParryNow then
                Parry()
            end
        end
        
        LastBallPos = BallPos
    end
end)

--//========================================================================================================
--// FINAL SETUP & MOBILE OPTIMIZATION
--//========================================================================================================

-- Set default toggle key (RightShift)
Window:SetToggleKey(Enum.KeyCode.RightShift)

-- Mobile optimization: Scale UI for small screens
if UserInputService:GetPlatform() == Enum.Platform.Mobile then
    Window:SetUIScale(0.85)
    -- Ensure open button is large enough for touch
    Window.OpenButton.Size = UDim2.new(0, 120, 0, 50)
end

-- Override notify to always include NoHub branding
WindUI._originalNotify = WindUI.Notify
WindUI.Notify = function(self, params)
    params.Title = params.Title and "NoHub • " .. params.Title or "NoHub"
    return WindUI._originalNotify(self, params)
end

-- Final notification with mandatory branding
task.wait(1)
WindUI:Notify({
    Title = "NoHub",
    Content = "Death Ball Pro fully operational!\nPress 'K' to toggle UI",
    Icon = "target",
    Duration = 5
})

warn("NoHub By Noctyra - Death Ball Pro initialized successfully (Mobile & PC Optimized)")
