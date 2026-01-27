--//========================================================================================================
--// NoHub By Noctyra - Universal Auto Features (WindUI)
--// Credits: NoHub - Noctyra | WindUI by Footagesus
--// Mobile & PC Optimized | Zero Original Names Preserved
--//========================================================================================================

-- Safety check for LocalPlayer
if not game:GetService("Players").LocalPlayer then
    warn("NoHub: LocalPlayer not found - aborting initialization")
    return
end

-- Load WindUI library (mobile/PC compatible)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- MANDATORY STARTUP BRANDING
print("NoHub By Noctyra Loaded")
WindUI:Notify({
    Title = "NoHub",
    Content = "Universal features loaded successfully!",
    Icon = "check",
    Duration = 4
})

-- Services & Core Variables
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

--//========================================================================================================
--// FEATURE 1: BALL PARRY SYSTEM (Death Ball)
--//========================================================================================================
local BallShadow, RealBall
local WhiteColor = Color3.new(1, 1, 1)
local LastBallPos
local SpeedMulty = 3
local AutoParryEnabled = true
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
local BallVelocityHistory = {}
local MaxVelocityHistory = 5

--//========================================================================================================
--// FEATURE 2: SAFE ZONE TELEPORT (New Feature)
--//========================================================================================================
local TP_Enabled = false
local TP_ZonePos = Vector3.new(569.09, 284.59, -779.90) -- Default coordinates (configurable via UI)
local TP_YOffset = 3
local TP_CheckInterval = 0.8
local TP_IntermissionDelay = 1.2
local TP_PostJoinCooldown = 6
local TP_LastJoinTime = 0
local TP_LastPos = nil

--//========================================================================================================
--// WINDUI WINDOW CREATION WITH MANDATORY BRANDING
--//========================================================================================================
local Window = WindUI:CreateWindow({
    Title = "NoHub By Noctyra",
    Folder = "NoHub_Universal",
    Icon = "solar:cube-bold",
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

-- MANDATORY CREDIT TAG
Window:Tag({
    Title = "NoHub • Noctyra",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

--//========================================================================================================
--// TAB 1: BALL PARRY (Death Ball Features)
--//========================================================================================================
local ParryTab = Window:Tab({
    Title = "Ball Parry",
    Icon = "solar:target-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    Border = true
})

local ParrySection = ParryTab:Section({
    Title = "Parry Controls",
    Box = true,
    BoxBorder = true,
    Opened = true
})

ParrySection:Toggle({
    Flag = "AutoParry",
    Title = "Auto Parry",
    Desc = "Automatically parry incoming projectiles",
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

ParrySection:Slider({
    Flag = "ParryDistance",
    Title = "Parry Distance",
    Desc = "Detection radius for projectiles",
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

ParrySection:Toggle({
    Flag = "AutoClicker",
    Title = "Auto Clicker",
    Desc = "Automatically press F key",
    Value = AutoClickerEnabled,
    Callback = function(state)
        AutoClickerEnabled = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Auto Clicker " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

-- Visual Zone Toggle
ParrySection:Toggle({
    Flag = "VisualZone",
    Title = "Visual Zone",
    Desc = "Show parry range sphere",
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

--//========================================================================================================
--// TAB 2: SAFE ZONE TELEPORT (New Feature)
--//========================================================================================================
local TPTab = Window:Tab({
    Title = "Safe Zone TP",
    Icon = "solar:location-bold",
    IconColor = Color3.fromHex("#30FF6A"),
    Border = true
})

local TPSection = TPTab:Section({
    Title = "Teleport Settings",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Auto TP Toggle
TPSection:Toggle({
    Flag = "AutoTP",
    Title = "Auto Teleport",
    Desc = "Teleport to safe zone during intermission",
    Value = false,
    Callback = function(state)
        TP_Enabled = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Auto TP " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

-- Coordinate Inputs (using Flags for auto-save)
TPSection:Input({
    Flag = "TP_X",
    Title = "Zone X Coordinate",
    Desc = "Safe zone X position",
    Value = "569.09",
    Placeholder = "Enter number",
    Callback = function(val)
        local num = tonumber(val)
        if num then TP_ZonePos = Vector3.new(num, TP_ZonePos.Y, TP_ZonePos.Z) end
    end
})

TPSection:Input({
    Flag = "TP_Y",
    Title = "Zone Y Coordinate",
    Desc = "Safe zone Y position",
    Value = "284.59",
    Placeholder = "Enter number",
    Callback = function(val)
        local num = tonumber(val)
        if num then TP_ZonePos = Vector3.new(TP_ZonePos.X, num, TP_ZonePos.Z) end
    end
})

TPSection:Input({
    Flag = "TP_Z",
    Title = "Zone Z Coordinate",
    Desc = "Safe zone Z position",
    Value = "-779.90",
    Placeholder = "Enter number",
    Callback = function(val)
        local num = tonumber(val)
        if num then TP_ZonePos = Vector3.new(TP_ZonePos.X, TP_ZonePos.Y, num) end
    end
})

-- Y Offset Slider
TPSection:Slider({
    Flag = "TP_YOffset",
    Title = "Y Offset",
    Desc = "Height adjustment above zone",
    Step = 0.1,
    Value = {
        Min = -10,
        Max = 20,
        Default = 3
    },
    Callback = function(val)
        TP_YOffset = val
    end
})

-- Cooldown Slider
TPSection:Slider({
    Flag = "TP_Cooldown",
    Title = "Post-Join Cooldown",
    Desc = "Seconds to wait after joining arena",
    Step = 1,
    Value = {
        Min = 3,
        Max = 15,
        Default = 6
    },
    Callback = function(val)
        TP_PostJoinCooldown = val
    end
})

-- Manual Teleport Button
TPSection:Button({
    Title = "Teleport Now",
    Desc = "Instantly teleport to safe zone",
    Icon = "solar:arrow-right-bold",
    Color = Color3.fromHex("#30FF6A"),
    Callback = function()
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
            WindUI:Notify({
                Title = "NoHub",
                Content = "⚠️ Character not loaded!",
                Color = "Yellow",
                Duration = 3
            })
            return
        end
        
        pcall(function()
            local hrp = LP.Character.HumanoidRootPart
            hrp.CFrame = CFrame.new(TP_ZonePos + Vector3.new(0, TP_YOffset, 0))
            hrp.Anchored = true
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            hrp.Anchored = false
            
            WindUI:Notify({
                Title = "NoHub",
                Content = "✅ Teleported to safe zone!",
                Duration = 2
            })
        end)
    end
})

--//========================================================================================================
--// TAB 3: REAL-TIME STATS
--//========================================================================================================
local StatsTab = Window:Tab({
    Title = "Stats",
    Icon = "solar:graph-bold",
    IconColor = Color3.fromHex("#257AF7"),
    Border = true
})

local StatsSection = StatsTab:Section({
    Title = "Tracking Data",
    Box = true,
    BoxBorder = true,
    Opened = true
})

local CoordinatesDisplay = StatsSection:Section({
    Title = "X: 0.0 | Y: 0.0 | Z: 0.0\nSpeed: 0.0 | Height: 0.0\nStatus: Ready",
    TextSize = 14,
    TextTransparency = 0.4
})

local StatusDisplay = StatsSection:Section({
    Title = "System: Idle",
    TextSize = 16,
    TextTransparency = 0.2,
    FontWeight = Enum.FontWeight.SemiBold
})

--//========================================================================================================
--// TAB 4: CONTROLS & INFO
--//========================================================================================================
local InfoTab = Window:Tab({
    Title = "Controls",
    Icon = "solar:keyboard-bold",
    IconColor = Color3.fromHex("#ECA201"),
    Border = true
})

InfoTab:Section({
    Title = "Ball Parry Controls",
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
    Desc = "Toggle Auto Clicker",
    Box = true,
    BoxBorder = true
})

InfoTab:Section({
    Title = "F",
    Desc = "Manual parry",
    Box = true,
    BoxBorder = true
})

InfoTab:Divider()

InfoTab:Section({
    Title = "Teleport Controls",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold
})

InfoTab:Section({
    Title = "Manual TP",
    Desc = "Use 'Teleport Now' button in Safe Zone TP tab",
    Box = true,
    BoxBorder = true
})

--//========================================================================================================
--// CORE FUNCTIONS (Ball Parry)
--//========================================================================================================
local function CreateZoneSphere()
    if ZoneSphere then ZoneSphere:Destroy() end
    
    ZoneSphere = Instance.new("Part")
    ZoneSphere.Name = "NoHub_ParryZone"
    ZoneSphere.Anchored = true
    ZoneSphere.CanCollide = false
    ZoneSphere.Material = Enum.Material.Neon
    ZoneSphere.BrickColor = BrickColor.new("Bright green")
    ZoneSphere.Transparency = VisualZoneEnabled and 0.7 or 1
    ZoneSphere.Shape = Enum.PartType.Ball
    ZoneSphere.Size = Vector3.new(ParryDistance * 2, ParryDistance * 2, ParryDistance * 2)
    ZoneSphere.Parent = workspace
end

local function UpdateZoneSphere()
    if not ZoneSphere or not VisualZoneEnabled then return end
    if not LP.Character or not LP.Character.PrimaryPart then return end
    
    ZoneSphere.Position = LP.Character.PrimaryPart.Position
    ZoneSphere.Size = Vector3.new(ParryDistance * 2, ParryDistance * 2, ParryDistance * 2)
    ZoneSphere.BrickColor = AutoParryEnabled and BrickColor.new("Bright green") or BrickColor.new("Bright red")
end

local function GetBallColor()
    if not RealBall then return WhiteColor end
    local highlight = RealBall:FindFirstChildOfClass("Highlight")
    if highlight then return highlight.FillColor end
    local surfaceGui = RealBall:FindFirstChildOfClass("SurfaceGui")
    if surfaceGui then
        local frame = surfaceGui:FindFirstChildOfClass("Frame")
        if frame and frame.BackgroundColor3 then return frame.BackgroundColor3 end
    end
    if RealBall:IsA("Part") and RealBall.BrickColor ~= BrickColor.new("White") then
        return RealBall.Color
    end
    return WhiteColor
end

local function UltraAutoClicker()
    if not AutoClickerEnabled then return end
    local currentTime = tick()
    if currentTime - LastClickTime >= 1 / ClickSpeed then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        LastClickTime = currentTime
    end
end

local function Parry()
    if IsParrying then return end
    IsParrying = true
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    
    LastParryTime = tick()
    task.delay(0.05, function() IsParrying = false end)
    
    -- Visual feedback
    if StatusDisplay.Set then
        StatusDisplay:Set("⚡ PARRY EXECUTED!")
        task.delay(0.5, function() 
            if StatusDisplay.Set then StatusDisplay:Set("System: Active") end 
        end)
    end
end

local function UpdateVelocityHistory(velocity)
    table.insert(BallVelocityHistory, velocity)
    if #BallVelocityHistory > MaxVelocityHistory then table.remove(BallVelocityHistory, 1) end
end

local function GetAverageVelocity()
    if #BallVelocityHistory == 0 then return Vector3.new(0, 0, 0) end
    local sum = Vector3.new(0, 0, 0)
    for _, v in ipairs(BallVelocityHistory) do sum = sum + v end
    return sum / #BallVelocityHistory
end

local function PredictBallPosition(currentPos, velocity, frames)
    return currentPos + (velocity * (0.016667 * frames))
end

local function CalculateBallHeight(shadowSize)
    local base = 5
    local mult = 8
    return math.min(math.max(0, shadowSize - base) * mult, 50)
end

local function GetMaxHeightBySpeed(speed)
    return speed < 10 and 225 or 240
end

local function CalculateOptimalParryDistance(speed, hDist, height, pY, bY)
    local maxH = GetMaxHeightBySpeed(speed)
    if bY - pY > maxH then return math.huge end
    
    local base = ParryDistance
    local react = speed * ReactionTime * SafetyMargin
    local opt = base + react
    
    if speed > 25 then opt = opt * 1.6
    elseif speed > 20 then opt = opt * 1.5
    elseif speed > 15 then opt = opt * 1.4
    elseif speed > 12 then opt = opt * 1.3
    elseif speed > 8 then opt = opt * 1.2 end
    
    return opt
end

local function IsBallComingTowardsPlayer(ballPos, lastPos, playerPos)
    if not lastPos then return true end
    local toPlayer = (playerPos - ballPos).Unit
    local movement = (ballPos - lastPos).Unit
    return toPlayer:Dot(movement) > 0.05
end

--//========================================================================================================
--// CORE FUNCTIONS (Safe Zone Teleport)
--//========================================================================================================
local function GetHRP()
    local char = LP.Character or LP.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function DistanceToZone()
    return (GetHRP().Position - TP_ZonePos).Magnitude
end

local function NearZone()
    return DistanceToZone() < 10
end

local function InArena()
    return DistanceToZone() > 80
end

local function DetectIntermission()
    for _, obj in ipairs(LP.PlayerGui:GetDescendants()) do
        if obj:IsA("TextLabel") and string.find(string.upper(obj.Text or ""), "INTERMISSION") then
            return true
        end
    end
    return false
end

local function TeleportToZone()
    pcall(function()
        local hrp = GetHRP()
        hrp.CFrame = CFrame.new(TP_ZonePos + Vector3.new(0, TP_YOffset, 0))
        hrp.Anchored = true
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        hrp.Anchored = false
        TP_LastJoinTime = os.clock()
    end)
end

-- Detect arena joins (large position changes)
RunService.Heartbeat:Connect(function()
    if not LP.Character then return end
    local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if TP_LastPos then
        if (hrp.Position - TP_LastPos).Magnitude > 60 then
            TP_LastJoinTime = os.clock()
        end
    end
    TP_LastPos = hrp.Position
end)

-- Main TP loop
task.spawn(function()
    while task.wait(TP_CheckInterval) do
        if not TP_Enabled then continue end
        if not LP.Character then continue end
        
        -- Skip if in arena
        if InArena() then continue end
        
        -- Skip if recently joined
        if os.clock() - TP_LastJoinTime < TP_PostJoinCooldown then continue end
        
        -- Teleport during intermission
        if DetectIntermission() and not NearZone() then
            task.wait(TP_IntermissionDelay)
            TeleportToZone()
            WindUI:Notify({
                Title = "NoHub",
                Content = "✅ Teleported to safe zone!",
                Duration = 2
            })
        end
    end
end)

--//========================================================================================================
--// MAIN GAME LOOP (Ball Tracking)
--//========================================================================================================
CreateZoneSphere()

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.K then Window:SetVisible(not Window.Visible)
    elseif input.KeyCode == Enum.KeyCode.E then AutoClickerEnabled = not AutoClickerEnabled
    elseif input.KeyCode == Enum.KeyCode.F then Parry() end
end)

RunService.Heartbeat:Connect(function()
    UpdateZoneSphere()
    UltraAutoClicker()
    
    -- Ball detection
    if not BallShadow then
        BallShadow = workspace:FindFirstChild("FX") and workspace.FX:FindFirstChild("BallShadow")
    end
    if not RealBall then
        RealBall = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Part")
    end
    
    if BallShadow and LP.Character and LP.Character.PrimaryPart then
        local bp = BallShadow.Position
        local pp = LP.Character.PrimaryPart.Position
        
        if not LastBallPos then LastBallPos = bp end
        
        -- Physics calculations
        local vel = (bp - LastBallPos) / 0.016667
        UpdateVelocityHistory(vel)
        local avgVel = GetAverageVelocity()
        local predPos = PredictBallPosition(bp, avgVel, PredictionFrames)
        
        local shadowSize = BallShadow.Size.X
        local height = CalculateBallHeight(shadowSize)
        local bY = bp.Y + height
        local hSpeed = Vector3.new((LastBallPos.X - bp.X), 0, (LastBallPos.Z - bp.Z)).Magnitude
        local speed = (hSpeed + 0.25) * SpeedMulty
        local hDist = (Vector3.new(pp.X, 0, pp.Z) - Vector3.new(bp.X, 0, bp.Z)).Magnitude
        local predDist = (Vector3.new(pp.X, 0, pp.Z) - Vector3.new(predPos.X, 0, predPos.Z)).Magnitude
        local vDist = bY - pp.Y
        local color = GetBallColor()
        local isWhite = color == WhiteColor
        local maxH = GetMaxHeightBySpeed(speed)
        local coming = IsBallComingTowardsPlayer(bp, LastBallPos, pp)
        local optDist = CalculateOptimalParryDistance(speed, hDist, height, pp.Y, bY)
        
        -- Update UI stats
        if tick() % 0.1 < 0.016 and CoordinatesDisplay.Set then
            CoordinatesDisplay:Set(string.format("X: %.1f | Y: %.1f | Z: %.1f\nSpeed: %.1f | Height: %.1f\nDist: %.1f", 
                bp.X, bY, bp.Z, speed, height, hDist))
        end
        
        -- Status updates
        if StatusDisplay.Set then
            if isWhite then
                StatusDisplay:Set("⚪ White projectile - Ignoring")
            elseif vDist > maxH then
                StatusDisplay:Set("⚠️ Too high - Ignoring")
            else
                StatusDisplay:Set("⚡ Tracking active")
            end
        end
        
        -- Auto parry logic
        if AutoParryEnabled and not isWhite and vDist <= maxH and coming and not IsParrying then
            local shouldParry = (predDist <= optDist or hDist <= optDist * 0.8)
            if shouldParry then Parry() end
        end
        
        LastBallPos = bp
    elseif StatusDisplay.Set then
        StatusDisplay:Set("System: Idle")
    end
end)

--//========================================================================================================
--// FINAL SETUP & MOBILE OPTIMIZATION
--//========================================================================================================
Window:SetToggleKey(Enum.KeyCode.RightShift)

if UserInputService:GetPlatform() == Enum.Platform.Mobile then
    Window:SetUIScale(0.85)
    if Window.OpenButton then
        Window.OpenButton.Size = UDim2.new(0, 120, 0, 50)
    end
end

-- Enforce NoHub branding on all notifications
WindUI._originalNotify = WindUI.Notify
WindUI.Notify = function(self, params)
    params.Title = params.Title and "NoHub • " .. params.Title or "NoHub"
    return WindUI._originalNotify(self, params)
end

task.wait(1)
WindUI:Notify({
    Title = "NoHub",
    Content = "NoHub By Noctyra fully operational!\n⚡ Press RIGHT SHIFT to toggle UI",
    Icon = "cube",
    Duration = 5
})

warn("NoHub By Noctyra initialized successfully (Mobile & PC Optimized)")
