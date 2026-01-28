--//========================================================================================================
--// NoHub By Noctyra - Universal Feature Hub (WindUI Conversion)
--// Credits: NoHub - Noctyra | WindUI by Footagesus
--// Mobile & PC Optimized | Zero Original Names Preserved
--//========================================================================================================

-- Safety check for LocalPlayer
repeat task.wait() until game:IsLoaded()
if not game:GetService("Players").LocalPlayer then return end

-- Load WindUI library (mobile/PC compatible)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- MANDATORY STARTUP BRANDING (Peraturan Wajib #1)
print("NoHub By Noctyra Loaded")

-- Initial notification with mandatory NoHub branding (Peraturan Wajib #2)
WindUI:Notify({
    Title = "NoHub",
    Content = "Feature Hub initializing...",
    Icon = "loader",
    Duration = 3,
    CanClose = false
})

-- Core framework initialization (cleaned of original branding)
getgenv().NoHubCore = {}
local Core = getgenv().NoHubCore

Core.Version = "1.0.0"
Core.Loaded = true
Core.Services = {}
Core.Features = {}
Core.Connections = {}
Core.Keybinds = {}

-- Services setup
local Services = Core.Services
Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.UserInputService = game:GetService("UserInputService")
Services.TeleportService = game:GetService("TeleportService")

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load ESP library (preserved functionality, UI replaced with WindUI)
local PlayerESPLib = loadstring(game:HttpGet("https://pastefy.app/ik8BXXQX/raw"))()

-- Core utilities (preserved logic)
function Core:GetCharacter(player)
    player = player or LocalPlayer
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    return character, humanoid, root
end

function Core:GetParts(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
    if not humanoid_root_part then return end
    return character, humanoid, humanoid_root_part
end

-- Feature initialization (cleaned of original branding)
Core.Features.AutoQuest = { Enabled = false }
Core.Features.AutoStealItems = { Enabled = false }
Core.Features.AutoStealGems = { Enabled = false }
Core.Features.NoSlow = { Enabled = false }
Core.Features.AutoBreakGlass = { Enabled = false }
Core.Features.Flight = { Enabled = false, VerticalSpeed = 50, HorizontalSpeed = 50 }
Core.Features.Walkspeed = { Enabled = false, Speed = 50 }
Core.Features.FOV = { Enabled = false, Value = 70 }
Core.Features.Gravity = { Enabled = false, Value = 196.2 }
Core.Features.JumpPower = { Enabled = false, Power = 50 }
Core.Features.Phase = { Enabled = false, OriginalCollision = {} }
Core.Features.LongJump = { Enabled = false, Height = 50, Boost = 50 }
Core.Features.WallClimb = { Enabled = false, Speed = 50 }
Core.Features.SpinBot = { Enabled = false, Speed = 50 }
Core.Features.BunnyHop = { Enabled = false, Speed = 50 }
Core.Features.PlayerESP = {
    Enabled = false,
    Box = false,
    Chams = false,
    ChamsFill = false,
    Tracer = false,
    Skeleton = false,
    Arrow = false,
    Name = false,
    Rainbow = false,
    DefaultColor = Color3.fromRGB(255, 255, 255),
    ChamsColor = Color3.fromRGB(255, 255, 255),
    ChamsOutline = Color3.fromRGB(255, 255, 255),
    MaxDistance = 1000
}

--//========================================================================================================
--// WINDUI WINDOW CREATION WITH MANDATORY BRANDING (Peraturan Wajib #3)
--//========================================================================================================
local Window = WindUI:CreateWindow({
    Title = "NoHub By Noctyra",  -- ✅ Full branding requirement met
    Folder = "NoHub_Features",
    Icon = "solar:cube-bold",
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
--// WINDUI TAB STRUCTURE (Mobile-Optimized Layout)
--//========================================================================================================

-- Tab 1: Combat Features
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "solar:sword-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    Border = true
})

local CombatSection = CombatTab:Section({
    Title = "Automation",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Delete Guards Button
CombatSection:Button({
    Title = "Delete Guards",
    Desc = "Remove all guard NPCs",
    Icon = "solar:user-bold",
    Callback = function()
        local map = workspace:FindFirstChild("Map")
        if not map then return end
        local npc_folder = map:FindFirstChild("NPCS")
        if not npc_folder then return end
        pcall(function()
            Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(npc_folder)
        end)
        WindUI:Notify({ Title = "NoHub", Content = "✅ Guards deleted", Duration = 2 })
    end
})

-- Delete Doors Button
CombatSection:Button({
    Title = "Delete Doors",
    Desc = "Remove all doors",
    Icon = "solar:door-open-bold",
    Callback = function()
        local map = workspace:FindFirstChild("Map")
        if not map then return end
        local doors_folder = map:FindFirstChild("Doors")
        if not doors_folder then return end
        pcall(function()
            Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(doors_folder)
        end)
        WindUI:Notify({ Title = "NoHub", Content = "✅ Doors deleted", Duration = 2 })
    end
})

-- Delete Glass Button
CombatSection:Button({
    Title = "Delete Glass",
    Desc = "Remove all breakable glass",
    Icon = "solar:glass-bold",
    Callback = function()
        local map = workspace:FindFirstChild("Map")
        if not map then return end
        local breakable_glass_folder = map:FindFirstChild("BreakableGlass")
        if not breakable_glass_folder then return end
        pcall(function()
            Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(breakable_glass_folder)
        end)
        WindUI:Notify({ Title = "NoHub", Content = "✅ Glass deleted", Duration = 2 })
    end
})

-- Delete Cameras Button
CombatSection:Button({
    Title = "Delete Cameras",
    Desc = "Remove all security cameras",
    Icon = "solar:camera-bold",
    Callback = function()
        local map = workspace:FindFirstChild("Map")
        if not map then return end
        local cameras_folder = map:FindFirstChild("Cameras")
        if not cameras_folder then return end
        pcall(function()
            Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(cameras_folder)
        end)
        WindUI:Notify({ Title = "NoHub", Content = "✅ Cameras deleted", Duration = 2 })
    end
})

CombatTab:Space()

local AutoSection = CombatTab:Section({
    Title = "Auto Features",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Auto Steal Items
local AutoStealItemsToggle = AutoSection:Toggle({
    Flag = "AutoStealItems",
    Title = "Auto Steal Items",
    Desc = "Automatically collect stealable items",
    Value = Core.Features.AutoStealItems.Enabled,
    Callback = function(state)
        Core.Features.AutoStealItems.Enabled = state
        if state then
            Core.Connections.AutoStealItems = Services.RunService.PreRender:Connect(function()
                local map = workspace:FindFirstChild("Map")
                if not map then return end
                local stealable_items = map:FindFirstChild("StealableItems")
                if not stealable_items then return end
                local natural = stealable_items:FindFirstChild("Natural")
                if not natural then return end
                for _, item in natural:GetChildren() do
                    pcall(function()
                        Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(item)
                    end)
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Auto Steal Items ENABLED", Duration = 2 })
        else
            if Core.Connections.AutoStealItems then
                Core.Connections.AutoStealItems:Disconnect()
                Core.Connections.AutoStealItems = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Auto Steal Items DISABLED", Duration = 2 })
        end
    end
})

AutoSection:Keybind({
    Flag = "AutoStealItemsKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Auto Steal Items",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.AutoStealItems.Enabled = not Core.Features.AutoStealItems.Enabled
            AutoStealItemsToggle:Set(Core.Features.AutoStealItems.Enabled)
        end
    end
})

-- Auto Steal Gems
local AutoStealGemsToggle = AutoSection:Toggle({
    Flag = "AutoStealGems",
    Title = "Auto Steal Gems",
    Desc = "Automatically collect gems only",
    Value = Core.Features.AutoStealGems.Enabled,
    Callback = function(state)
        Core.Features.AutoStealGems.Enabled = state
        if state then
            Core.Connections.AutoStealGems = Services.RunService.PreRender:Connect(function()
                local map = workspace:FindFirstChild("Map")
                if not map then return end
                local stealable_items = map:FindFirstChild("StealableItems")
                if not stealable_items then return end
                for _, item in stealable_items:GetChildren() do
                    if item.Name ~= "Gem" then continue end
                    pcall(function()
                        Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(item)
                    end)
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Auto Steal Gems ENABLED", Duration = 2 })
        else
            if Core.Connections.AutoStealGems then
                Core.Connections.AutoStealGems:Disconnect()
                Core.Connections.AutoStealGems = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Auto Steal Gems DISABLED", Duration = 2 })
        end
    end
})

AutoSection:Keybind({
    Flag = "AutoStealGemsKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Auto Steal Gems",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.AutoStealGems.Enabled = not Core.Features.AutoStealGems.Enabled
            AutoStealGemsToggle:Set(Core.Features.AutoStealGems.Enabled)
        end
    end
})

-- Auto Quest
local AutoQuestToggle = AutoSection:Toggle({
    Flag = "AutoQuest",
    Title = "Auto Quest",
    Desc = "Automatically claim quest rewards",
    Value = Core.Features.AutoQuest.Enabled,
    Callback = function(state)
        Core.Features.AutoQuest.Enabled = state
        if state then
            Core.Connections.AutoQuest = Services.RunService.PreRender:Connect(function()
                local quest_folder = LocalPlayer:FindFirstChild("QuestFolder")
                if not quest_folder then return end
                local player_gui = LocalPlayer.PlayerGui
                if not player_gui then return end
                local main_ui = player_gui:FindFirstChild("MainUI")
                if not main_ui then return end
                local free_gift = main_ui:FindFirstChild("FreeGift")
                if free_gift and free_gift.Enabled then
                    free_gift.Enabled = false
                end
                for _, quest in quest_folder:GetChildren() do
                    pcall(function()
                        Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClaimQuestReward"):FireServer(quest.Name)
                    end)
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Auto Quest ENABLED", Duration = 2 })
        else
            if Core.Connections.AutoQuest then
                Core.Connections.AutoQuest:Disconnect()
                Core.Connections.AutoQuest = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Auto Quest DISABLED", Duration = 2 })
        end
    end
})

AutoSection:Keybind({
    Flag = "AutoQuestKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Auto Quest",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.AutoQuest.Enabled = not Core.Features.AutoQuest.Enabled
            AutoQuestToggle:Set(Core.Features.AutoQuest.Enabled)
        end
    end
})

-- No Slow
local NoSlowToggle = AutoSection:Toggle({
    Flag = "NoSlow",
    Title = "No Slow",
    Desc = "Prevent movement slowdown from inventory",
    Value = Core.Features.NoSlow.Enabled,
    Callback = function(state)
        Core.Features.NoSlow.Enabled = state
        if state then
            Core.Connections.NoSlow = Services.RunService.PreRender:Connect(function()
                if LocalPlayer:GetAttribute("BagScale") then
                    LocalPlayer:SetAttribute("BagScale", 0) 
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ No Slow ENABLED", Duration = 2 })
        else
            if Core.Connections.NoSlow then
                Core.Connections.NoSlow:Disconnect()
                Core.Connections.NoSlow = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ No Slow DISABLED", Duration = 2 })
        end
    end
})

AutoSection:Keybind({
    Flag = "NoSlowKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle No Slow",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.NoSlow.Enabled = not Core.Features.NoSlow.Enabled
            NoSlowToggle:Set(Core.Features.NoSlow.Enabled)
        end
    end
})

-- Auto Break Glass
local AutoBreakGlassToggle = AutoSection:Toggle({
    Flag = "AutoBreakGlass",
    Title = "Auto Break Glass",
    Desc = "Automatically break nearby glass",
    Value = Core.Features.AutoBreakGlass.Enabled,
    Callback = function(state)
        Core.Features.AutoBreakGlass.Enabled = state
        if state then
            Core.Connections.AutoBreakGlass = Services.RunService.PreRender:Connect(function()
                local map = workspace:FindFirstChild("Map")
                if not map then return end
                local breakable_glass = map:FindFirstChild("BreakableGlass")
                if not breakable_glass then return end
                for _, glass in breakable_glass:GetChildren() do
                    pcall(function()
                        Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Utilities"):WaitForChild("BreakWindow"):FireServer(glass)
                    end)
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Auto Break Glass ENABLED", Duration = 2 })
        else
            if Core.Connections.AutoBreakGlass then
                Core.Connections.AutoBreakGlass:Disconnect()
                Core.Connections.AutoBreakGlass = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Auto Break Glass DISABLED", Duration = 2 })
        end
    end
})

AutoSection:Keybind({
    Flag = "AutoBreakGlassKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Auto Break Glass",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.AutoBreakGlass.Enabled = not Core.Features.AutoBreakGlass.Enabled
            AutoBreakGlassToggle:Set(Core.Features.AutoBreakGlass.Enabled)
        end
    end
})

-- Tab 2: Mobility Features
local MobilityTab = Window:Tab({
    Title = "Mobility",
    Icon = "solar:rocket-bold",
    IconColor = Color3.fromHex("#30FF6A"),
    Border = true
})

local FlightSection = MobilityTab:Section({
    Title = "Flight",
    Box = true,
    BoxBorder = true,
    Opened = true
})

local FlightToggle = FlightSection:Toggle({
    Flag = "Flight",
    Title = "Flight",
    Desc = "Free flying movement",
    Value = Core.Features.Flight.Enabled,
    Callback = function(state)
        Core.Features.Flight.Enabled = state
        if state then
            Core.Connections.Flight = Services.RunService.PreRender:Connect(function(delta)
                local character, humanoid, humanoid_root_part = Core:GetParts(LocalPlayer)
                if not character or not humanoid or not humanoid_root_part then return end
                local move_direction = Vector3.zero
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) and not Services.UserInputService:GetFocusedTextBox() then
                    move_direction += Vector3.new(0, 0, 1)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) and not Services.UserInputService:GetFocusedTextBox() then
                    move_direction += Vector3.new(0, 0, -1)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) and not Services.UserInputService:GetFocusedTextBox() then
                    move_direction += Vector3.new(-1, 0, 0)
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) and not Services.UserInputService:GetFocusedTextBox() then
                    move_direction += Vector3.new(1, 0, 0)
                end
                local vertical = 0
                if (Services.UserInputService:IsKeyDown(Enum.KeyCode.E) or Services.UserInputService:IsKeyDown(Enum.KeyCode.Space))
                    and not Services.UserInputService:GetFocusedTextBox() then
                    vertical = Core.Features.Flight.VerticalSpeed
                end
                if Services.UserInputService:IsKeyDown(Enum.KeyCode.Q) and not Services.UserInputService:GetFocusedTextBox() then
                    vertical = -Core.Features.Flight.VerticalSpeed
                end
                if move_direction.Magnitude > 0 then
                    move_direction = move_direction.Unit * Core.Features.Flight.HorizontalSpeed
                end
                local forward = Camera.CFrame.LookVector
                local right = Camera.CFrame.RightVector
                local final_move = (forward * move_direction.Z) + (right * move_direction.X) + (Vector3.yAxis * vertical)
                humanoid_root_part.CFrame += final_move * delta
                local velocity = humanoid_root_part.Velocity
                humanoid_root_part.Velocity = Vector3.new(velocity.X, 0.5, velocity.Z)
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Flight ENABLED", Duration = 2 })
        else
            if Core.Connections.Flight then
                Core.Connections.Flight:Disconnect()
                Core.Connections.Flight = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Flight DISABLED", Duration = 2 })
        end
    end
})

FlightSection:Slider({
    Flag = "FlightHorizontalSpeed",
    Title = "Horizontal Speed",
    Desc = "Flight movement speed",
    Step = 1,
    Value = {
        Min = 0,
        Max = 500,
        Default = Core.Features.Flight.HorizontalSpeed
    },
    Callback = function(v) Core.Features.Flight.HorizontalSpeed = v end
})

FlightSection:Slider({
    Flag = "FlightVerticalSpeed",
    Title = "Vertical Speed",
    Desc = "Flight ascent/descent speed",
    Step = 1,
    Value = {
        Min = 0,
        Max = 500,
        Default = Core.Features.Flight.VerticalSpeed
    },
    Callback = function(v) Core.Features.Flight.VerticalSpeed = v end
})

FlightSection:Keybind({
    Flag = "FlightKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Flight",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.Flight.Enabled = not Core.Features.Flight.Enabled
            FlightToggle:Set(Core.Features.Flight.Enabled)
        end
    end
})

MobilityTab:Space()

local MovementSection = MobilityTab:Section({
    Title = "Movement",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Walkspeed
local WalkspeedToggle = MovementSection:Toggle({
    Flag = "Walkspeed",
    Title = "Walkspeed",
    Desc = "Custom movement speed",
    Value = Core.Features.Walkspeed.Enabled,
    Callback = function(enabled)
        Core.Features.Walkspeed.Enabled = enabled
        if enabled then
            Core.Connections.Walkspeed = Services.RunService.PreRender:Connect(function()
                local character, humanoid = Core:GetParts(LocalPlayer)
                if humanoid then humanoid.WalkSpeed = Core.Features.Walkspeed.Speed end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Walkspeed ENABLED", Duration = 2 })
        else
            if Core.Connections.Walkspeed then
                Core.Connections.Walkspeed:Disconnect()
                Core.Connections.Walkspeed = nil
            end
            local character, humanoid = Core:GetParts(LocalPlayer)
            if humanoid then humanoid.WalkSpeed = 16 end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Walkspeed DISABLED", Duration = 2 })
        end
    end
})

MovementSection:Slider({
    Flag = "WalkspeedValue",
    Title = "Speed",
    Desc = "Custom walkspeed value",
    Step = 1,
    Value = {
        Min = 0,
        Max = 250,
        Default = Core.Features.Walkspeed.Speed
    },
    Callback = function(value) Core.Features.Walkspeed.Speed = value end
})

MovementSection:Keybind({
    Flag = "WalkspeedKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Walkspeed",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.Walkspeed.Enabled = not Core.Features.Walkspeed.Enabled
            WalkspeedToggle:Set(Core.Features.Walkspeed.Enabled)
        end
    end
})

-- Jump Power
local JumpPowerToggle = MovementSection:Toggle({
    Flag = "JumpPower",
    Title = "Jump Power",
    Desc = "Custom jump height",
    Value = Core.Features.JumpPower.Enabled,
    Callback = function(enabled)
        Core.Features.JumpPower.Enabled = enabled
        if enabled then
            Core.Connections.JumpPower = Services.RunService.PreRender:Connect(function()
                local character, humanoid = Core:GetParts(LocalPlayer)
                if humanoid then
                    if humanoid.UseJumpPower then
                        humanoid.JumpPower = Core.Features.JumpPower.Power
                    else
                        humanoid.JumpHeight = Core.Features.JumpPower.Power
                    end
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Jump Power ENABLED", Duration = 2 })
        else
            if Core.Connections.JumpPower then
                Core.Connections.JumpPower:Disconnect()
                Core.Connections.JumpPower = nil
            end
            local character, humanoid = Core:GetParts(LocalPlayer)
            if humanoid then
                if humanoid.UseJumpPower then
                    humanoid.JumpPower = 50
                else
                    humanoid.JumpHeight = 7.2
                end
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Jump Power DISABLED", Duration = 2 })
        end
    end
})

MovementSection:Slider({
    Flag = "JumpPowerValue",
    Title = "Power",
    Desc = "Jump height multiplier",
    Step = 1,
    Value = {
        Min = 0,
        Max = 300,
        Default = Core.Features.JumpPower.Power
    },
    Callback = function(value) Core.Features.JumpPower.Power = value end
})

MovementSection:Keybind({
    Flag = "JumpPowerKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Jump Power",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.JumpPower.Enabled = not Core.Features.JumpPower.Enabled
            JumpPowerToggle:Set(Core.Features.JumpPower.Enabled)
        end
    end
})

-- FOV
local FOVToggle = MovementSection:Toggle({
    Flag = "FOV",
    Title = "Field of View",
    Desc = "Custom camera FOV",
    Value = Core.Features.FOV.Enabled,
    Callback = function(enabled)
        Core.Features.FOV.Enabled = enabled
        if enabled then
            Core.Connections.FOV = Services.RunService.PreRender:Connect(function()
                Camera.FieldOfView = Core.Features.FOV.Value
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ FOV ENABLED", Duration = 2 })
        else
            if Core.Connections.FOV then
                Core.Connections.FOV:Disconnect()
                Core.Connections.FOV = nil
            end
            Camera.FieldOfView = 70
            WindUI:Notify({ Title = "NoHub", Content = "❌ FOV DISABLED", Duration = 2 })
        end
    end
})

MovementSection:Slider({
    Flag = "FOVValue",
    Title = "FOV",
    Desc = "Camera field of view",
    Step = 1,
    Value = {
        Min = 0,
        Max = 120,
        Default = Core.Features.FOV.Value
    },
    Callback = function(value) Core.Features.FOV.Value = value end
})

MovementSection:Keybind({
    Flag = "FOVKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle FOV",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.FOV.Enabled = not Core.Features.FOV.Enabled
            FOVToggle:Set(Core.Features.FOV.Enabled)
        end
    end
})

-- Gravity
local GravityToggle = MovementSection:Toggle({
    Flag = "Gravity",
    Title = "Gravity",
    Desc = "Custom world gravity",
    Value = Core.Features.Gravity.Enabled,
    Callback = function(enabled)
        Core.Features.Gravity.Enabled = enabled
        if enabled then
            Core.Connections.Gravity = Services.RunService.PreRender:Connect(function()
                workspace.Gravity = Core.Features.Gravity.Value
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Gravity ENABLED", Duration = 2 })
        else
            if Core.Connections.Gravity then
                Core.Connections.Gravity:Disconnect()
                Core.Connections.Gravity = nil
            end
            workspace.Gravity = 196.2
            WindUI:Notify({ Title = "NoHub", Content = "❌ Gravity DISABLED", Duration = 2 })
        end
    end
})

MovementSection:Slider({
    Flag = "GravityValue",
    Title = "Gravity",
    Desc = "World gravity strength",
    Step = 1,
    Value = {
        Min = 0,
        Max = 300,
        Default = Core.Features.Gravity.Value
    },
    Callback = function(v) Core.Features.Gravity.Value = v end
})

MovementSection:Keybind({
    Flag = "GravityKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Gravity",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.Gravity.Enabled = not Core.Features.Gravity.Enabled
            GravityToggle:Set(Core.Features.Gravity.Enabled)
        end
    end
})

MobilityTab:Space()

local AdvancedSection = MobilityTab:Section({
    Title = "Advanced",
    Box = true,
    BoxBorder = true,
    Opened = true
})

-- Phase
local PhaseToggle = AdvancedSection:Toggle({
    Flag = "Phase",
    Title = "Phase",
    Desc = "Walk through walls and objects",
    Value = Core.Features.Phase.Enabled,
    Callback = function(enabled)
        Core.Features.Phase.Enabled = enabled
        if enabled then
            Core.Features.Phase.OriginalCollision = {}
            Core.Connections.Phase = Services.RunService.PreRender:Connect(function()
                local character = LocalPlayer.Character
                if not character then return end
                for _, part in character:GetDescendants() do
                    if part:IsA("BasePart") and Core.Features.Phase.OriginalCollision[part] == nil then
                        Core.Features.Phase.OriginalCollision[part] = part.CanCollide
                    end
                end
                for part, _ in pairs(Core.Features.Phase.OriginalCollision) do
                    if part and part.Parent then part.CanCollide = false end
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Phase ENABLED", Duration = 2 })
        else
            for part, canCollide in pairs(Core.Features.Phase.OriginalCollision) do
                if part and part.Parent then part.CanCollide = canCollide end
            end
            Core.Features.Phase.OriginalCollision = {}
            if Core.Connections.Phase then
                Core.Connections.Phase:Disconnect()
                Core.Connections.Phase = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Phase DISABLED", Duration = 2 })
        end
    end
})

AdvancedSection:Keybind({
    Flag = "PhaseKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Phase",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.Phase.Enabled = not Core.Features.Phase.Enabled
            PhaseToggle:Set(Core.Features.Phase.Enabled)
        end
    end
})

-- Long Jump
local LongJumpToggle = AdvancedSection:Toggle({
    Flag = "LongJump",
    Title = "Long Jump",
    Desc = "Enhanced jumping distance",
    Value = Core.Features.LongJump.Enabled,
    Callback = function(enabled)
        Core.Features.LongJump.Enabled = enabled
        if enabled then
            local can_boost = true
            Core.Connections.LongJump = Services.RunService.PreRender:Connect(function()
                local character, humanoid, root = Core:GetParts(LocalPlayer)
                if not character or not humanoid or not root then return end
                if humanoid:GetState() == Enum.HumanoidStateType.Jumping and can_boost then
                    local direction = root.CFrame.LookVector * Core.Features.LongJump.Boost
                    root.Velocity += Vector3.new(direction.X, Core.Features.LongJump.Height, direction.Z)
                    can_boost = false
                elseif humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    can_boost = true
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Long Jump ENABLED", Duration = 2 })
        else
            if Core.Connections.LongJump then
                Core.Connections.LongJump:Disconnect()
                Core.Connections.LongJump = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Long Jump DISABLED", Duration = 2 })
        end
    end
})

AdvancedSection:Slider({
    Flag = "LongJumpHeight",
    Title = "Height",
    Desc = "Vertical jump boost",
    Step = 1,
    Value = {
        Min = 0,
        Max = 500,
        Default = Core.Features.LongJump.Height
    },
    Callback = function(value) Core.Features.LongJump.Height = value end
})

AdvancedSection:Slider({
    Flag = "LongJumpBoost",
    Title = "Boost",
    Desc = "Horizontal jump distance",
    Step = 1,
    Value = {
        Min = 0,
        Max = 500,
        Default = Core.Features.LongJump.Boost
    },
    Callback = function(value) Core.Features.LongJump.Boost = value end
})

AdvancedSection:Keybind({
    Flag = "LongJumpKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Long Jump",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.LongJump.Enabled = not Core.Features.LongJump.Enabled
            LongJumpToggle:Set(Core.Features.LongJump.Enabled)
        end
    end
})

-- Wall Climb
local WallClimbToggle = AdvancedSection:Toggle({
    Flag = "WallClimb",
    Title = "Wall Climb",
    Desc = "Climb vertical surfaces",
    Value = Core.Features.WallClimb.Enabled,
    Callback = function(enabled)
        Core.Features.WallClimb.Enabled = enabled
        if enabled then
            Core.Connections.WallClimb = Services.RunService.PreRender:Connect(function()
                local character, humanoid, root = Core:GetParts(LocalPlayer)
                if not character or not root then return end
                local ray_origin = root.Position
                local ray_direction = root.CFrame.LookVector * 2
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = { character }
                params.FilterType = Enum.RaycastFilterType.Exclude
                local hit = workspace:Raycast(ray_origin, ray_direction, params)
                if not hit then return end
                local upperOrigin = ray_origin + Vector3.new(0, 2.5, 0)
                local upperHit = workspace:Raycast(upperOrigin, ray_direction, params)
                if upperHit then
                    root.Velocity = Vector3.new(root.Velocity.X, Core.Features.WallClimb.Speed, root.Velocity.Z)
                else
                    root.CFrame += root.CFrame.LookVector * 1.2
                    root.Velocity = Vector3.zero
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Wall Climb ENABLED", Duration = 2 })
        else
            if Core.Connections.WallClimb then
                Core.Connections.WallClimb:Disconnect()
                Core.Connections.WallClimb = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Wall Climb DISABLED", Duration = 2 })
        end
    end
})

AdvancedSection:Slider({
    Flag = "WallClimbSpeed",
    Title = "Speed",
    Desc = "Climbing velocity",
    Step = 1,
    Value = {
        Min = 0,
        Max = 100,
        Default = Core.Features.WallClimb.Speed
    },
    Callback = function(value) Core.Features.WallClimb.Speed = value end
})

AdvancedSection:Keybind({
    Flag = "WallClimbKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Wall Climb",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.WallClimb.Enabled = not Core.Features.WallClimb.Enabled
            WallClimbToggle:Set(Core.Features.WallClimb.Enabled)
        end
    end
})

-- Spin Bot
local SpinBotToggle = AdvancedSection:Toggle({
    Flag = "SpinBot",
    Title = "Spin Bot",
    Desc = "Automatic camera rotation",
    Value = Core.Features.SpinBot.Enabled,
    Callback = function(enabled)
        Core.Features.SpinBot.Enabled = enabled
        if enabled then
            Core.Connections.SpinBot = Services.RunService.PreRender:Connect(function(delta)
                local character, humanoid, root = Core:GetParts(LocalPlayer)
                if not character or not humanoid or not root then return end
                humanoid.AutoRotate = false
                local rotation = math.rad(Core.Features.SpinBot.Speed) * delta * 60
                root.CFrame *= CFrame.Angles(0, rotation, 0)
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Spin Bot ENABLED", Duration = 2 })
        else
            if Core.Connections.SpinBot then
                Core.Connections.SpinBot:Disconnect()
                Core.Connections.SpinBot = nil
            end
            local character, humanoid = Core:GetParts(LocalPlayer)
            if humanoid then humanoid.AutoRotate = true end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Spin Bot DISABLED", Duration = 2 })
        end
    end
})

AdvancedSection:Slider({
    Flag = "SpinBotSpeed",
    Title = "Speed",
    Desc = "Rotation speed (degrees per second)",
    Step = 1,
    Value = {
        Min = 0,
        Max = 100,
        Default = Core.Features.SpinBot.Speed
    },
    Callback = function(v) Core.Features.SpinBot.Speed = v end
})

AdvancedSection:Keybind({
    Flag = "SpinBotKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Spin Bot",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.SpinBot.Enabled = not Core.Features.SpinBot.Enabled
            SpinBotToggle:Set(Core.Features.SpinBot.Enabled)
        end
    end
})

-- Bunny Hop
local BunnyHopToggle = AdvancedSection:Toggle({
    Flag = "BunnyHop",
    Title = "Bunny Hop",
    Desc = "Continuous automatic jumping",
    Value = Core.Features.BunnyHop.Enabled,
    Callback = function(enabled)
        Core.Features.BunnyHop.Enabled = enabled
        if enabled then
            Core.Connections.BunnyHop = Services.RunService.PreRender:Connect(function()
                local character = LocalPlayer.Character
                if not character then return end
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            WindUI:Notify({ Title = "NoHub", Content = "✅ Bunny Hop ENABLED", Duration = 2 })
        else
            if Core.Connections.BunnyHop then
                Core.Connections.BunnyHop:Disconnect()
                Core.Connections.BunnyHop = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Bunny Hop DISABLED", Duration = 2 })
        end
    end
})

AdvancedSection:Keybind({
    Flag = "BunnyHopKeybind",
    Title = "Toggle Keybind",
    Desc = "Hold to toggle Bunny Hop",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.BunnyHop.Enabled = not Core.Features.BunnyHop.Enabled
            BunnyHopToggle:Set(Core.Features.BunnyHop.Enabled)
        end
    end
})

-- Tab 3: Render Features (ESP)
local RenderTab = Window:Tab({
    Title = "Render",
    Icon = "solar:eye-bold",
    IconColor = Color3.fromHex("#257AF7"),
    Border = true
})

local ESPToggle
local EspInstance = nil

local ESPSection = RenderTab:Section({
    Title = "Player ESP",
    Box = true,
    BoxBorder = true,
    Opened = true
})

ESPToggle = ESPSection:Toggle({
    Flag = "PlayerESP",
    Title = "Enable ESP",
    Desc = "Visual indicators for other players",
    Value = Core.Features.PlayerESP.Enabled,
    Callback = function(enabled)
        Core.Features.PlayerESP.Enabled = enabled
        if enabled then
            EspInstance = PlayerESPLib.new({
                Box = Core.Features.PlayerESP.Box,
                Chams = Core.Features.PlayerESP.Chams,
                ChamsFill = Core.Features.PlayerESP.ChamsFill,
                Tracer = Core.Features.PlayerESP.Tracer,
                Arrows = Core.Features.PlayerESP.Arrow,
                Skeleton = Core.Features.PlayerESP.Skeleton,
                Name = Core.Features.PlayerESP.Name,
                Rainbow = Core.Features.PlayerESP.Rainbow,
                DefaultColor = Core.Features.PlayerESP.DefaultColor,
                ChamsColor = Core.Features.PlayerESP.ChamsColor,
                ChamsOutline = Core.Features.PlayerESP.ChamsOutline,
                MaxDistance = Core.Features.PlayerESP.MaxDistance
            })
            EspInstance:Enable()
            WindUI:Notify({ Title = "NoHub", Content = "✅ Player ESP ENABLED", Duration = 2 })
        else
            if EspInstance then
                EspInstance:Disable()
                EspInstance = nil
            end
            WindUI:Notify({ Title = "NoHub", Content = "❌ Player ESP DISABLED", Duration = 2 })
        end
    end
})

RenderTab:Space()

local ESPElements = RenderTab:Section({
    Title = "ESP Elements",
    Box = true,
    BoxBorder = true,
    Opened = true
})

ESPElements:Toggle({
    Flag = "ESPBox",
    Title = "Box",
    Desc = "Draw boxes around players",
    Value = Core.Features.PlayerESP.Box,
    Callback = function(state)
        Core.Features.PlayerESP.Box = state
        if EspInstance then EspInstance.Box = state end
    end
})

ESPElements:Toggle({
    Flag = "ESPChams",
    Title = "Chams",
    Desc = "See players through walls",
    Value = Core.Features.PlayerESP.Chams,
    Callback = function(state)
        Core.Features.PlayerESP.Chams = state
        if EspInstance then EspInstance.Chams = state end
    end
})

ESPElements:Toggle({
    Flag = "ESPChamsFill",
    Title = "Chams Fill",
    Desc = "Solid color fill for chams",
    Value = Core.Features.PlayerESP.ChamsFill,
    Callback = function(state)
        Core.Features.PlayerESP.ChamsFill = state
        if EspInstance then EspInstance.ChamsFill = state end
    end
})

ESPElements:Toggle({
    Flag = "ESPTracer",
    Title = "Tracer",
    Desc = "Lines from screen center to players",
    Value = Core.Features.PlayerESP.Tracer,
    Callback = function(state)
        Core.Features.PlayerESP.Tracer = state
        if EspInstance then EspInstance.Tracer = state end
    end
})

ESPElements:Toggle({
    Flag = "ESPSkeleton",
    Title = "Skeleton",
    Desc = "Draw player bone structure",
    Value = Core.Features.PlayerESP.Skeleton,
    Callback = function(state)
        Core.Features.PlayerESP.Skeleton = state
        if EspInstance then EspInstance.Skeleton = state end
    end
})

ESPElements:Toggle({
    Flag = "ESPArrows",
    Title = "Arrows",
    Desc = "Direction arrows for off-screen players",
    Value = Core.Features.PlayerESP.Arrow,
    Callback = function(state)
        Core.Features.PlayerESP.Arrow = state
        if EspInstance then EspInstance.Arrows = state end
    end
})

ESPElements:Toggle({
    Flag = "ESPName",
    Title = "Name",
    Desc = "Display player usernames",
    Value = Core.Features.PlayerESP.Name,
    Callback = function(state)
        Core.Features.PlayerESP.Name = state
        if EspInstance then EspInstance.Name = state end
    end
})

ESPElements:Toggle({
    Flag = "ESPRainbow",
    Title = "Rainbow",
    Desc = "Animated color cycling",
    Value = Core.Features.PlayerESP.Rainbow,
    Callback = function(state)
        Core.Features.PlayerESP.Rainbow = state
        if EspInstance then EspInstance.Rainbow = state end
    end
})

RenderTab:Space()

local ESPColors = RenderTab:Section({
    Title = "ESP Colors",
    Box = true,
    BoxBorder = true,
    Opened = true
})

ESPColors:Colorpicker({
    Flag = "ESPDefaultColor",
    Title = "Player Color",
    Desc = "Main ESP color",
    Default = Core.Features.PlayerESP.DefaultColor,
    Callback = function(color)
        Core.Features.PlayerESP.DefaultColor = color
        if EspInstance then
            EspInstance.DefaultColor = color
            for _, player in ipairs(Services.Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    EspInstance:SetColor(player, color)
                end
            end
        end
    end
})

ESPColors:Colorpicker({
    Flag = "ESPChamsColor",
    Title = "Chams Color",
    Desc = "Chams surface color",
    Default = Core.Features.PlayerESP.ChamsColor,
    Callback = function(color)
        Core.Features.PlayerESP.ChamsColor = color
        if EspInstance then EspInstance.ChamsColor = color end
    end
})

ESPColors:Colorpicker({
    Flag = "ESPChamsOutline",
    Title = "Chams Outline",
    Desc = "Chams border color",
    Default = Core.Features.PlayerESP.ChamsOutline,
    Callback = function(color)
        Core.Features.PlayerESP.ChamsOutline = color
        if EspInstance then EspInstance.ChamsOutline = color end
    end
})

RenderTab:Keybind({
    Flag = "ESPKeybind",
    Title = "Toggle ESP Keybind",
    Desc = "Hold to toggle Player ESP",
    Value = "None",
    Callback = function(key)
        if key ~= "None" and UserInputService:IsKeyDown(Enum.KeyCode[key]) then
            Core.Features.PlayerESP.Enabled = not Core.Features.PlayerESP.Enabled
            ESPToggle:Set(Core.Features.PlayerESP.Enabled)
        end
    end
})

-- Tab 4: Settings & Config
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

-- Config management using WindUI's built-in system
local ConfigNameInput = ConfigSection:Input({
    Flag = "ConfigName",
    Title = "Config Name",
    Desc = "Name for saving/loading configs",
    Value = "Default",
    Placeholder = "Enter config name",
    Callback = function(text) end -- Handled by save button
})

ConfigSection:Space()

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
            -- Refresh UI to reflect loaded values
            task.wait(0.1)
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

ConfigSection:Button({
    Title = "Delete Config",
    Desc = "Remove saved config",
    Icon = "solar:trash-bold",
    Color = Color3.fromHex("#EF4F1D"),
    Callback = function()
        local name = ConfigNameInput:Get() or "Default"
        if name == "" then name = "Default" end
        local path = "NoHub_Features/settings/" .. name .. ".json"
        pcall(function()
            if isfile and isfile(path) then
                delfile(path)
                WindUI:Notify({
                    Title = "NoHub",
                    Content = "✅ Config deleted: " .. name,
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "NoHub",
                    Content = "⚠️ Config not found: " .. name,
                    Color = "Yellow",
                    Duration = 3
                })
            end
        end)
    end
})

SettingsTab:Space()

local InfoSection = SettingsTab:Section({
    Title = "System Info",
    Box = true,
    BoxBorder = true,
    Opened = true
})

InfoSection:Section({
    Title = "NoHub Feature Hub v" .. Core.Version,
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
--// FINAL SETUP & MOBILE OPTIMIZATION
--//========================================================================================================

-- Set default toggle key
Window:SetToggleKey(Enum.KeyCode.RightAlt)

-- Mobile optimization
local UserInputService = game:GetService("UserInputService")
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

-- Cleanup on script unload
game:GetService("Players").LocalPlayer.ChildRemoved:Connect(function(child)
    if child.Name == "PlayerScripts" then
        if EspInstance then
            EspInstance:Disable()
            EspInstance = nil
        end
        for _, connection in pairs(Core.Connections) do
            if connection and connection.Disconnect then connection:Disconnect() end
        end
        Core.Connections = {}
    end
end)

-- Final startup notification with mandatory branding
task.wait(1.5)
WindUI:Notify({
    Title = "NoHub",
    Content = "NoHub By Noctyra fully operational!\n⚡ Press RIGHT ALT to toggle UI",
    Icon = "cube",
    Duration = 5
})

warn("NoHub By Noctyra - Universal Feature Hub initialized (Mobile & PC Optimized)")
