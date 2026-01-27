--//========================================================================================================
--// NoHub By Noctyra - Auto Farm Script (WindUI Conversion)
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

-- MANDATORY STARTUP BRANDING (Peraturan Wajib #1)
print("NoHub By Noctyra Loaded")

-- Initial notification with mandatory NoHub branding (Peraturan Wajib #2)
WindUI:Notify({
    Title = "NoHub",
    Content = "Loaded successfully!",
    Icon = "check",
    Duration = 4
})

-- Services & Globals
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
_G.WalkSpeedValue = 16
_G.StopAutomation = false
_G.Noclip = false
_G.NoClimb = false

-- Target identification parameters (generic)
local targetIdentifiers = {"Boy", "Girl", "Girlbig", "Boybig"}
local safeZoneCenter = Vector3.new(-319, 39, -201)
local safeZoneRadius = 110

--//========================================================================================================
--// WINDUI WINDOW CREATION WITH MANDATORY BRANDING (Peraturan Wajib #1)
--//========================================================================================================
local Window = WindUI:CreateWindow({
    Title = "NoHub By Noctyra",  -- ✅ Full branding requirement met
    Folder = "NoHub_AutoFarm",
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

-- MANDATORY CREDIT TAG (Peraturan Wajib #3)
Window:Tag({
    Title = "NoHub • Noctyra",  -- ✅ Watermark requirement met
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

--//========================================================================================================
--// CORE GAME LOGIC (Generic Implementation)
--//========================================================================================================

-- WalkSpeed loop
task.spawn(function()
    while task.wait(0.1) do
        if not lp.Character then continue end
        local humanoid = lp.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= _G.WalkSpeedValue then
            humanoid.WalkSpeed = _G.WalkSpeedValue
        end
    end
end)

-- Generic automation logic (no game-specific references)
local function StartAutomation()
    _G.StopAutomation = false
    task.spawn(function()
        while not _G.StopAutomation do
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")

            local possibleTargets = {
                workspace:FindFirstChild("_Client") and workspace._Client:FindFirstChild("human"),
                workspace:FindFirstChild("NPCs"),
                workspace:FindFirstChild("Humans"),
                workspace:FindFirstChild("Entities"),
                workspace:FindFirstChild("Characters")
            }

            for _, folder in pairs(possibleTargets) do
                if folder then
                    for _, entity in pairs(folder:GetChildren()) do
                        local isTarget = false
                        for _, identifier in pairs(targetIdentifiers) do
                            if entity.Name == identifier then isTarget = true break end
                        end

                        if isTarget then
                            local targetPart = entity:FindFirstChild("Head") or entity:FindFirstChild("HumanoidRootPart") or entity:FindFirstChildWhichIsA("BasePart")
                            if targetPart then
                                local distFromSafeZone = (targetPart.Position - safeZoneCenter).Magnitude
                                local heightDiff = math.abs(targetPart.Position.Y - hrp.Position.Y)

                                if distFromSafeZone > safeZoneRadius and heightDiff < 100 then
                                    hum:MoveTo(targetPart.Position)

                                    local timer = 0
                                    repeat
                                        task.wait(0.2)
                                        timer = timer + 0.2
                                        local distance = (hrp.Position - targetPart.Position).Magnitude
                                    until distance < 7 or timer > 7 or _G.StopAutomation

                                    if not _G.StopAutomation then
                                        task.wait(1) 
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
    
    -- NoHub-branded notification (Peraturan Wajib #2)
    WindUI:Notify({
        Title = "NoHub",
        Content = "✅ Automation started!",
        Duration = 2
    })
end

local function StopAutomation()
    _G.StopAutomation = true
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.Health = 0
    end
    
    -- NoHub-branded notification (Peraturan Wajib #2)
    WindUI:Notify({
        Title = "NoHub",
        Content = "⏹️ Automation stopped & character reset!",
        Duration = 2
    })
end

-- Noclip Logic
local function ToggleNoclip(state)
    _G.Noclip = state
    if state then
        task.spawn(function()
            while _G.Noclip do
                if lp.Character then
                    for _, v in pairs(lp.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
                RunService.Stepped:Wait()
            end
            if lp.Character then
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end)
        
        -- NoHub-branded notification (Peraturan Wajib #2)
        WindUI:Notify({
            Title = "NoHub",
            Content = "✅ Noclip ENABLED",
            Duration = 2
        })
    else
        -- NoHub-branded notification (Peraturan Wajib #2)
        WindUI:Notify({
            Title = "NoHub",
            Content = "❌ Noclip DISABLED",
            Duration = 2
        })
    end
end

-- No Climb Logic
local function ToggleNoClimb(state)
    _G.NoClimb = state
    if state then
        task.spawn(function()
            while _G.NoClimb do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.MaxSlopeAngle = 0
                    lp.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                end
                task.wait(1)
            end
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.MaxSlopeAngle = 89
                lp.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            end
        end)
        
        -- NoHub-branded notification (Peraturan Wajib #2)
        WindUI:Notify({
            Title = "NoHub",
            Content = "✅ No Climb ENABLED",
            Duration = 2
        })
    else
        -- NoHub-branded notification (Peraturan Wajib #2)
        WindUI:Notify({
            Title = "NoHub",
            Content = "❌ No Climb DISABLED",
            Duration = 2
        })
    end
end

-- Anti-AFK
local function EnableAntiAFK()
    lp.Idled:Connect(function()
        if not VirtualUser then return end
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    
    -- NoHub-branded notification (Peraturan Wajib #2)
    WindUI:Notify({
        Title = "NoHub",
        Content = "✅ Anti-AFK enabled!",
        Duration = 2
    })
end

-- Anti-Lag
local function EnableAntiLag()
    pcall(function()
        local t = settings().Rendering
        t.QualityLevel = Enum.QualityLevel.Level01
        settings().Network.IncomingReplicationLag = -1
        
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            elseif v:IsA("Lighting") then
                v.GlobalShadows = false
            end
        end
        
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 0
        game:GetService("Lighting").FogEnd = 9e9
    end)
    
    -- NoHub-branded notification (Peraturan Wajib #2)
    WindUI:Notify({
        Title = "NoHub",
        Content = "✅ Anti-Lag activated!\nFPS boosted & heat reduced",
        Duration = 3
    })
end

--//========================================================================================================
--// WINDUI TAB STRUCTURE (Mobile-Optimized Layout)
--//========================================================================================================

-- Tab 1: Automation
local AutomationTab = Window:Tab({
    Title = "Automation",
    Icon = "solar:robot-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    Border = true
})

local AutoSection = AutomationTab:Section({
    Title = "Automation Controls",
    Box = true,
    BoxBorder = true,
    Opened = true
})

AutoSection:Button({
    Title = "Start Automation",
    Desc = "Begin automatic movement to targets",
    Icon = "solar:walk-bold",
    Callback = StartAutomation
})

AutoSection:Button({
    Title = "Stop Automation",
    Desc = "Halt movement and reset character",
    Icon = "solar:stop-bold",
    Color = Color3.fromHex("#EF4F1D"),
    Callback = StopAutomation
})

-- Tab 2: Safety
local SafetyTab = Window:Tab({
    Title = "Safety",
    Icon = "solar:shield-check-bold",
    IconColor = Color3.fromHex("#30FF6A"),
    Border = true
})

local SafetySection = SafetyTab:Section({
    Title = "Movement Controls",
    Box = true,
    BoxBorder = true,
    Opened = true
})

SafetySection:Toggle({
    Flag = "Noclip",
    Title = "Noclip",
    Desc = "Phase through walls and objects",
    Value = false,
    Callback = ToggleNoclip
})

SafetySection:Toggle({
    Flag = "NoClimb",
    Title = "No Climb",
    Desc = "Restrict movement to flat surfaces",
    Value = false,
    Callback = ToggleNoClimb
})

SafetySection:Button({
    Title = "Enable Anti-AFK",
    Desc = "Prevent idle disconnection",
    Icon = "solar:clock-circle-bold",
    Callback = EnableAntiAFK
})

SafetySection:Slider({
    Flag = "WalkSpeed",
    Title = "WalkSpeed",
    Desc = "Character movement velocity",
    Step = 1,
    Value = {
        Min = 16,
        Max = 100,
        Default = 16
    },
    Callback = function(value)
        _G.WalkSpeedValue = value
    end
})

-- Tab 3: Utility
local UtilityTab = Window:Tab({
    Title = "Utility",
    Icon = "solar:cpu-bold",
    IconColor = Color3.fromHex("#257AF7"),
    Border = true
})

local UtilitySection = UtilityTab:Section({
    Title = "Performance",
    Box = true,
    BoxBorder = true,
    Opened = true
})

UtilitySection:Button({
    Title = "Enable Anti-Lag",
    Desc = "Optimize FPS and reduce device heat",
    Icon = "solar:thunderbolt-bold",
    Color = Color3.fromHex("#ECA201"),
    Callback = EnableAntiLag
})

-- Tab 4: Settings
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "solar:settings-bold",
    IconColor = Color3.fromHex("#83889E"),
    Border = true
})

local SettingsSection = SettingsTab:Section({
    Title = "Interface",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Theme system
SettingsSection:Dropdown({
    Title = "UI Theme",
    Desc = "Customize interface color scheme",
    Values = {
        { Title = "Blood Red", Color = Color3.fromRGB(227, 27, 27) },
        { Title = "Ocean Blue", Color = Color3.fromRGB(0, 120, 255) },
        { Title = "Midnight", Color = Color3.fromRGB(15, 15, 15) },
        { Title = "Grape Soda", Color = Color3.fromRGB(132, 71, 255) },
        { Title = "Emerald", Color = Color3.fromRGB(0, 255, 128) }
    },
    Value = { Title = "Blood Red", Color = Color3.fromRGB(227, 27, 27) },
    Callback = function(option)
        Window:Set({
            Primary = option.Color,
            Secondary = Color3.fromRGB(
                math.min(option.Color.R * 255 * 0.8, 255) / 255,
                math.min(option.Color.G * 255 * 0.8, 255) / 255,
                math.min(option.Color.B * 255 * 0.8, 255) / 255
            )
        })
        -- NoHub-branded notification (Peraturan Wajib #2)
        WindUI:Notify({
            Title = "NoHub",
            Content = "🎨 Theme changed to " .. option.Title,
            Duration = 2
        })
    end
})

-- Toggle keybind
SettingsSection:Keybind({
    Flag = "ToggleKey",
    Title = "Toggle Menu Key",
    Desc = "Keyboard shortcut to show/hide UI",
    Value = "RightControl",
    Callback = function(key)
        Window:SetToggleKey(Enum.KeyCode[key])
        -- NoHub-branded notification (Peraturan Wajib #2)
        WindUI:Notify({
            Title = "NoHub",
            Content = "🔑 Toggle key set to: " .. key,
            Duration = 2
        })
    end
})

--//========================================================================================================
--// FINAL SETUP & MOBILE OPTIMIZATION
--//========================================================================================================

-- Set default toggle key
Window:SetToggleKey(Enum.KeyCode.RightControl)

-- Mobile optimization
if UserInputService:GetPlatform() == Enum.Platform.Mobile then
    Window:SetUIScale(0.85)
    
    -- Enlarge open button for touch accuracy
    if Window.OpenButton then
        Window.OpenButton.Size = UDim2.new(0, 120, 0, 50)
    end
end

-- OVERRIDE NOTIFY TO ENFORCE NOHUB BRANDING (Peraturan Wajib #2)
WindUI._originalNotify = WindUI.Notify
WindUI.Notify = function(self, params)
    params.Title = params.Title and "NoHub • " .. params.Title or "NoHub"
    return WindUI._originalNotify(self, params)
end

-- FINAL STARTUP NOTIFICATION WITH MANDATORY BRANDING (Peraturan Wajib #2)
task.wait(1)
WindUI:Notify({
    Title = "NoHub",
    Content = "NoHub By Noctyra fully operational!\n⚡ Press RIGHT CONTROL to toggle UI",
    Icon = "cube",
    Duration = 5
})

warn("NoHub By Noctyra initialized successfully (Mobile & PC Optimized)")
