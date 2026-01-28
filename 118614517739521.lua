--//========================================================================================================
--// NoHub By Noctyra - Blind Shot Framework (WindUI Conversion)
--// Credits: NoHub - Noctyra | WindUI by Footagesus
--// Mobile & PC Optimized | Zero Original Names Preserved
--//========================================================================================================

-- Safety check for LocalPlayer
repeat task.wait() until game:IsLoaded()
if not game:GetService("Players").LocalPlayer then return end

-- Load WindUI library (mobile/PC compatible) - NO KEY SYSTEM
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- MANDATORY STARTUP BRANDING (Peraturan Wajib #1)
print("NoHub By Noctyra Loaded")

-- Initial notification with mandatory NoHub branding (Peraturan Wajib #2)
WindUI:Notify({
    Title = "NoHub",
    Content = "Blind Shot framework initializing...",
    Icon = "loader",
    Duration = 3,
    CanClose = false
})

-- Services & Core Setup
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")

-- Feature Settings (cleaned of original branding)
local Settings = {
    AutoSkipSpins = false,
    AutoBuySpin = false,
    SkipDelay = 0.5,
    BuyDelay = 1.0,
    PlayerESP = false,
    HighlightPlayers = false,
    RevealPlayers = false,
    AimDetection = false,
    UnanchorHRP = false,
}

-- ESP Storage
local ESPObjects = {}
local HighlightObjects = {}

-- Remote References (with safety checks)
local Net = RS:FindFirstChild("NetRayRemotes")

-- Helper Functions (preserved functionality)
local function ClaimCachedRewards()
    if not Net or not Net:FindFirstChild("Spinner_RF") then return end
    local args = { buffer and buffer.fromstring and buffer.fromstring("@\018ClaimCachedRewards") or nil }
    if args[1] then
        pcall(function()
            Net.Spinner_RF:InvokeServer(unpack(args))
        end)
    end
end

local function BuySpin()
    if not Net or not Net:FindFirstChild("Shop_Purchase") then return end
    local args = {
        buffer and buffer.fromstring and buffer.fromstring("\241C\026\000\000\002\t\a\ashopKey\a\fCashCrate_1x\n") or nil,
        {}
    }
    if args[1] then
        pcall(function()
            Net.Shop_Purchase:FireServer(unpack(args))
        end)
    end
end

-- ESP Functions (preserved logic, cleaned of original branding)
local function CreateESP(player)
    if not player.Character or ESPObjects[player] then return end
    
    local char = player.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NoHub_ESP_" .. player.Name
    billboardGui.Adornee = hrp
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = hrp
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboardGui
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.Parent = billboardGui
    
    ESPObjects[player] = billboardGui
    
    -- Update distance loop
    task.spawn(function()
        while billboardGui and billboardGui.Parent and Settings.PlayerESP do
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and hrp then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                distanceLabel.Text = string.format("%.1f studs", distance)
            end
            task.wait(0.1)
        end
        if billboardGui then billboardGui:Destroy() end
    end)
end

local function CreateHighlight(player)
    if not player.Character or HighlightObjects[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NoHub_Highlight_" .. player.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    
    HighlightObjects[player] = highlight
end

local function RevealPlayers()
    -- Move models from ReplicatedStorage to workspace (simplified safety check)
    for _, obj in pairs(RS:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
            pcall(function() obj.Parent = workspace end)
        end
    end
end

-- Aim Detection System (preserved logic)
local LastAimWarning = 0
local function CheckAimDetection()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    local gunLaser = tool:FindFirstChild("GunLaser", true)
                    
                    if gunLaser and gunLaser:IsA("BasePart") then
                        local laserPos = gunLaser.Position
                        local laserForward = gunLaser.CFrame.LookVector
                        local toMe = (myPos - laserPos)
                        local distance = toMe.Magnitude
                        local directionToMe = toMe.Unit
                        local dotProduct = laserForward:Dot(directionToMe)
                        
                        if dotProduct > 0.98 and distance < 500 then
                            local currentTime = tick()
                            if currentTime - LastAimWarning > 3 then
                                WindUI:Notify({
                                    Title = "NoHub",
                                    Content = "⚠️ " .. player.Name .. " is aiming at you!",
                                    Color = "Yellow",
                                    Duration = 3
                                })
                                LastAimWarning = currentTime
                            end
                        end
                    end
                end
            end
        end
    end
end

--//========================================================================================================
--// WINDUI WINDOW CREATION WITH MANDATORY BRANDING (Peraturan Wajib #3)
--//========================================================================================================
local Window = WindUI:CreateWindow({
    Title = "NoHub By Noctyra",  -- ✅ Full branding requirement met
    Folder = "NoHub_BlindShot",
    Icon = "solar:target-bold",
    HideSearchBar = false,
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

-- MANDATORY CREDIT TAG (Peraturan Wajib #4)
Window:Tag({
    Title = "NoHub • Noctyra",  -- ✅ Watermark requirement met
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

--//========================================================================================================
--// TAB 1: MAIN FEATURES
--//========================================================================================================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "solar:target-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    Border = true
})

-- Auto Features Section
local AutoSection = MainTab:Section({
    Title = "Auto Features",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Auto Skip Spins Toggle
local AutoSkipToggle = AutoSection:Toggle({
    Flag = "AutoSkipSpins",
    Title = "Auto Skip Spins",
    Desc = "Automatically claim cached rewards",
    Value = Settings.AutoSkipSpins,
    Callback = function(state)
        Settings.AutoSkipSpins = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Auto Skip Spins " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

-- Auto Buy Spin Toggle
local AutoBuyToggle = AutoSection:Toggle({
    Flag = "AutoBuySpin",
    Title = "Auto Buy Spin",
    Desc = "Automatically purchase spins",
    Value = Settings.AutoBuySpin,
    Callback = function(state)
        Settings.AutoBuySpin = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Auto Buy Spin " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

-- Unanchor HRP Toggle (cleaned of "xeno was here" reference)
local UnanchorToggle = AutoSection:Toggle({
    Flag = "UnanchorHRP",
    Title = "Unfreeze Character",
    Desc = "Unanchors HRP during shooting stage",
    Value = Settings.UnanchorHRP,
    Callback = function(state)
        Settings.UnanchorHRP = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Character Unfreeze " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

MainTab:Space()

-- Settings Section
local SettingsSection = MainTab:Section({
    Title = "Delays",
    Box = true,
    BoxBorder = true,
    Opened = true
})

SettingsSection:Slider({
    Flag = "SkipDelay",
    Title = "Skip Delay",
    Desc = "Seconds between reward claims",
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 5,
        Default = Settings.SkipDelay
    },
    Callback = function(value)
        Settings.SkipDelay = value
    end
})

SettingsSection:Slider({
    Flag = "BuyDelay",
    Title = "Buy Delay",
    Desc = "Seconds between spin purchases",
    Step = 0.1,
    Value = {
        Min = 0.1,
        Max = 10,
        Default = Settings.BuyDelay
    },
    Callback = function(value)
        Settings.BuyDelay = value
    end
})

--//========================================================================================================
--// TAB 2: VISUALS (ESP & DETECTION)
--//========================================================================================================
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "solar:eye-bold",
    IconColor = Color3.fromHex("#30FF6A"),
    Border = true
})

-- ESP Section
local ESPSection = VisualsTab:Section({
    Title = "Player ESP",
    Box = true,
    BoxBorder = true,
    Opened = true
})

local ESPToggle = ESPSection:Toggle({
    Flag = "PlayerESP",
    Title = "Enable ESP",
    Desc = "Show player names and distance through walls",
    Value = Settings.PlayerESP,
    Callback = function(state)
        Settings.PlayerESP = state
        if not state then
            for player, obj in pairs(ESPObjects) do
                if obj and obj.Parent then obj:Destroy() end
                ESPObjects[player] = nil
            end
        end
        WindUI:Notify({
            Title = "NoHub",
            Content = "Player ESP " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

ESPSection:Toggle({
    Flag = "HighlightPlayers",
    Title = "Highlight Players",
    Desc = "Red outline around all players",
    Value = Settings.HighlightPlayers,
    Callback = function(state)
        Settings.HighlightPlayers = state
        if not state then
            for player, obj in pairs(HighlightObjects) do
                if obj and obj.Parent then obj:Destroy() end
                HighlightObjects[player] = nil
            end
        end
        WindUI:Notify({
            Title = "NoHub",
            Content = "Player Highlights " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

ESPSection:Toggle({
    Flag = "RevealPlayers",
    Title = "Reveal Hidden Players",
    Desc = "Expose hidden player models",
    Value = Settings.RevealPlayers,
    Callback = function(state)
        Settings.RevealPlayers = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Player Reveal " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

VisualsTab:Space()

-- Detection Section
local DetectionSection = VisualsTab:Section({
    Title = "Detection",
    Box = true,
    BoxBorder = true,
    Opened = true
})

DetectionSection:Toggle({
    Flag = "AimDetection",
    Title = "Aim Warning",
    Desc = "Alert when players aim at you",
    Value = Settings.AimDetection,
    Callback = function(state)
        Settings.AimDetection = state
        WindUI:Notify({
            Title = "NoHub",
            Content = "Aim Detection " .. (state and "ENABLED" or "DISABLED"),
            Duration = 2
        })
    end
})

--//========================================================================================================
--// TAB 3: UI SETTINGS & CONFIG
--//========================================================================================================
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "solar:settings-bold",
    IconColor = Color3.fromHex("#ECA201"),
    Border = true
})

local ConfigSection = SettingsTab:Section({
    Title = "Configuration",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Config Name Input
local ConfigNameInput = ConfigSection:Input({
    Flag = "ConfigName",
    Title = "Config Name",
    Desc = "Name for saving/loading settings",
    Value = "Default",
    Placeholder = "Enter config name",
    Callback = function(text) end
})

ConfigSection:Space()

-- Save Config Button
ConfigSection:Button({
    Title = "Save Config",
    Desc = "Save current settings",
    Icon = "solar:save-bold",
    Callback = function()
        local name = ConfigNameInput:Get() or "Default"
        if name == "" then name = "Default" end
        Window.CurrentConfig = Window.ConfigManager:Config(name)
        if Window.CurrentConfig:Save() then
            WindUI:Notify({
                Title = "NoHub",
                Content = "✅ Config saved: " .. name,
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "NoHub",
                Content = "❌ Failed to save config",
                Color = "Red",
                Duration = 3
            })
        end
    end
})

-- Load Config Button
ConfigSection:Button({
    Title = "Load Config",
    Desc = "Load saved settings",
    Icon = "solar:upload-bold",
    Callback = function()
        local name = ConfigNameInput:Get() or "Default"
        if name == "" then name = "Default" end
        local config = Window.ConfigManager:Config(name)
        if config:Load() then
            WindUI:Notify({
                Title = "NoHub",
                Content = "✅ Config loaded: " .. name,
                Duration = 3
            })
            task.wait(0.2) -- Allow UI to refresh
        else
            WindUI:Notify({
                Title = "NoHub",
                Content = "❌ Config not found: " .. name,
                Color = "Yellow",
                Duration = 3
            })
        end
    end
})

SettingsTab:Space()

-- System Info Section
local InfoSection = SettingsTab:Section({
    Title = "System Info",
    Box = true,
    BoxBorder = true,
    Opened = true
})

InfoSection:Section({
    Title = "NoHub Blind Shot v1.0",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold
})

InfoSection:Section({
    Title = "⚠️ Usage Notice",
    Desc = "Use features responsibly. Developer not liable for account actions.",
    Box = true,
    BoxBorder = true,
    Color = Color3.fromHex("#EF4F1D"),
    TextTransparency = 0.3
})

--//========================================================================================================
--// BACKGROUND LOOPS (Preserved Functionality)
--//========================================================================================================

-- Auto Skip Loop
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoSkipSpins then
            ClaimCachedRewards()
            task.wait(Settings.SkipDelay - 0.1)
        end
    end
end)

-- Auto Buy Loop
task.spawn(function()
    while task.wait(0.1) do
        if Settings.AutoBuySpin then
            BuySpin()
            task.wait(Settings.BuyDelay - 0.1)
        end
    end
end)

-- ESP & Detection Loop
RunService.RenderStepped:Connect(function()
    if Settings.PlayerESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not ESPObjects[player] or not ESPObjects[player].Parent then
                    CreateESP(player)
                end
            end
        end
    end
    
    if Settings.HighlightPlayers then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not HighlightObjects[player] or not HighlightObjects[player].Parent then
                    CreateHighlight(player)
                end
            end
        end
    end
    
    if Settings.UnanchorHRP then
        if LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hrp.Anchored then
                hrp.Anchored = false
            end
            if humanoid then
                humanoid.WalkSpeed = 25
            end
        end
    end
    
    if Settings.AimDetection then
        CheckAimDetection()
    end
end)

-- Reveal Players Loop
task.spawn(function()
    while task.wait(1) do
        if Settings.RevealPlayers then
            RevealPlayers()
        end
    end
end)

-- Player Character Handling
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.PlayerESP then CreateESP(player) end
        if Settings.HighlightPlayers then CreateHighlight(player) end
    end)
end)

-- Cleanup on unload
game:GetService("Players").LocalPlayer.ChildRemoved:Connect(function(child)
    if child.Name == "PlayerScripts" then
        -- Clean up ESP objects
        for _, obj in pairs(ESPObjects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        for _, obj in pairs(HighlightObjects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        ESPObjects = {}
        HighlightObjects = {}
    end
end)

--//========================================================================================================
--// FINAL SETUP & MOBILE OPTIMIZATION
--//========================================================================================================

-- Set default toggle key
Window:SetToggleKey(Enum.KeyCode.RightShift)

-- Mobile optimization
if UserInputService:GetPlatform() == Enum.Platform.Mobile then
    Window:SetUIScale(0.85)
    if Window.OpenButton then
        Window.OpenButton.Size = UDim2.new(0, 120, 0, 50)
    end
end

-- Override notify to enforce NoHub branding (Peraturan Wajib #2)
WindUI._originalNotify = WindUI.Notify
WindUI.Notify = function(self, params)
    params.Title = params.Title and "NoHub • " .. params.Title or "NoHub"
    return WindUI._originalNotify(self, params)
end

-- Final startup notification with mandatory branding
task.wait(1.5)
WindUI:Notify({
    Title = "NoHub",
    Content = "NoHub By Noctyra fully operational!\n⚡ Press RIGHT SHIFT to toggle UI",
    Icon = "target",
    Duration = 5
})

warn("NoHub By Noctyra - Blind Shot Framework initialized (Mobile & PC Optimized)")
