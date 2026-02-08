--[[
    Daddy's Home Script
    PlaceId: 14787381917
    Using Rayfield UI Library
]]

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Wait for game to load
repeat task.wait() until LocalPlayer:FindFirstChild("Energy")

-- Connections table
local Connections = {}

-- Refresh character reference
local function RefreshCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
end

LocalPlayer.CharacterAdded:Connect(RefreshCharacter)

-- Get remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ESP Folder
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
pcall(function()
    ESPFolder.Parent = game:GetService("CoreGui")
end)

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- CREATE RAYFIELD WINDOW
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local Window = Rayfield:CreateWindow({
    Name = "",
    LoadingTitle = "",
    LoadingSubtitle = "",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "DaddysHome"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- PLAYER TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local PlayerTab = Window:CreateTab("Player", 4483362458)

local PlayerSection = PlayerTab:CreateSection("Stats")

PlayerTab:CreateToggle({
    Name = "Infinite Stats",
    CurrentValue = false,
    Flag = "InfiniteStats",
    Callback = function(Value)
        if Connections["InfiniteStats"] then
            Connections["InfiniteStats"]:Disconnect()
            Connections["InfiniteStats"] = nil
        end
        
        if Value then
            Connections["InfiniteStats"] = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if LocalPlayer:FindFirstChild("Energy") then
                        LocalPlayer.Energy.Value = 100
                    end
                    if LocalPlayer:FindFirstChild("Hunger") then
                        LocalPlayer.Hunger.Value = 100
                    end
                    if LocalPlayer:FindFirstChild("Thirst") then
                        LocalPlayer.Thirst.Value = 100
                    end
                    if LocalPlayer:FindFirstChild("Oxygen") then
                        LocalPlayer.Oxygen.Value = 100
                    end
                end)
            end)
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(Value)
        if Connections["InfiniteStamina"] then
            Connections["InfiniteStamina"]:Disconnect()
            Connections["InfiniteStamina"] = nil
        end
        
        if Value then
            Connections["InfiniteStamina"] = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if PlayerGui then
                        local Time = PlayerGui:FindFirstChild("Time")
                        if Time and Time:FindFirstChild("Frame") then
                            local stamina = Time.Frame:FindFirstChild("stamina")
                            if stamina then
                                stamina.Value = 100
                            end
                        end
                    end
                end)
            end)
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Flashlight Battery",
    CurrentValue = false,
    Flag = "InfiniteBattery",
    Callback = function(Value)
        if Connections["InfiniteBattery"] then
            Connections["InfiniteBattery"]:Disconnect()
            Connections["InfiniteBattery"] = nil
        end
        
        if Value then
            Connections["InfiniteBattery"] = RunService.Heartbeat:Connect(function()
                pcall(function()
                    Remotes:FindFirstChild("RefillBattery"):InvokeServer()
                end)
            end)
        end
    end,
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- MOVEMENT TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local MovementTab = Window:CreateTab("Movement", 4483362458)

local SpeedValue = 25
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {10, 150},
    Increment = 5,
    Suffix = " Speed",
    CurrentValue = 25,
    Flag = "SpeedSlider",
    Callback = function(Value)
        SpeedValue = Value
        -- Update speed immediately if speed hack is active
        if Connections["SpeedHack"] then
            pcall(function()
                RefreshCharacter()
                Humanoid.WalkSpeed = SpeedValue
            end)
        end
    end,
})

MovementTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        if Connections["SpeedHack"] then
            Connections["SpeedHack"]:Disconnect()
            Connections["SpeedHack"] = nil
        end
        
        if Value then
            -- Find the Speed remote
            local SpeedRemote = nil
            pcall(function()
                -- Try multiple paths
                local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if PlayerGui then
                    -- Path 1: Time.Frame.Speed
                    local Time = PlayerGui:FindFirstChild("Time")
                    if Time then
                        if Time:FindFirstChild("Frame") and Time.Frame:FindFirstChild("Speed") then
                            SpeedRemote = Time.Frame.Speed
                        end
                        -- Path 2: Directly in Time
                        if not SpeedRemote and Time:FindFirstChild("Speed") then
                            SpeedRemote = Time.Speed
                        end
                    end
                end
                -- Path 3: Search all PlayerGui
                if not SpeedRemote then
                    for _, v in pairs(PlayerGui:GetDescendants()) do
                        if v:IsA("RemoteEvent") and v.Name == "Speed" then
                            SpeedRemote = v
                            break
                        end
                    end
                end
            end)
            
            -- Fire remote once
            if SpeedRemote then
                pcall(function()
                    SpeedRemote:FireServer(1055299, SpeedValue)
                end)
            end
            
            -- Keep speed constant every frame (server might reset it)
            Connections["SpeedHack"] = RunService.Heartbeat:Connect(function()
                pcall(function()
                    RefreshCharacter()
                    if Humanoid and Humanoid.WalkSpeed ~= SpeedValue then
                        Humanoid.WalkSpeed = SpeedValue
                        -- Also fire remote again if speed was reset
                        if SpeedRemote then
                            SpeedRemote:FireServer(1055299, SpeedValue)
                        end
                    end
                end)
            end)
            
            Rayfield:Notify({Title = "Speed Hack", Content = "Speed set to " .. SpeedValue, Duration = 2})
        else
            -- Reset to normal
            pcall(function()
                RefreshCharacter()
                Humanoid.WalkSpeed = 10
            end)
        end
    end,
})

local NoClipping = false
MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        NoClipping = Value
        
        if Connections["NoClip"] then
            Connections["NoClip"]:Disconnect()
            Connections["NoClip"] = nil
        end
        
        if Value then
            Connections["NoClip"] = RunService.Stepped:Connect(function()
                if NoClipping and Character then
                    for _, part in pairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end,
})

local Flying = false
local FlySpeed = 50
local BodyGyro, BodyVelocity

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 10,
    Suffix = " Speed",
    CurrentValue = 50,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        FlySpeed = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Fly (E/Q Up/Down)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Flying = Value
        
        if Value then
            RefreshCharacter()
            local HRP = Character:FindFirstChild("HumanoidRootPart")
            
            BodyGyro = Instance.new("BodyGyro")
            BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            BodyGyro.P = 1e4
            BodyGyro.Parent = HRP
            
            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.Parent = HRP
            
            Connections["Fly"] = RunService.RenderStepped:Connect(function()
                if Flying and Character and HRP then
                    local Camera = workspace.CurrentCamera
                    BodyGyro.CFrame = Camera.CFrame
                    
                    local moveDir = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - Camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + Camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end
                    
                    if moveDir.Magnitude > 0 then
                        BodyVelocity.Velocity = moveDir.Unit * FlySpeed
                    else
                        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        else
            if Connections["Fly"] then
                Connections["Fly"]:Disconnect()
                Connections["Fly"] = nil
            end
            if BodyGyro then BodyGyro:Destroy() end
            if BodyVelocity then BodyVelocity:Destroy() end
        end
    end,
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- VISUALS TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                    v.Enabled = false
                end
            end
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 0
            Lighting.FogEnd = 1000
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then
                    v.Enabled = true
                end
            end
        end
    end,
})

-- ESP Function
local function CreateESP(model, color, name)
    if not model or not model:FindFirstChild("HumanoidRootPart") then return end
    
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Name = name .. "_ESP"
    BillboardGui.Adornee = model.HumanoidRootPart
    BillboardGui.Size = UDim2.new(0, 100, 0, 30)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Parent = ESPFolder
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = color
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 14
    TextLabel.Parent = BillboardGui
    
    spawn(function()
        while BillboardGui and BillboardGui.Parent do
            local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
            if HRP and model and model:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((HRP.Position - model.HumanoidRootPart.Position).Magnitude)
                TextLabel.Text = name .. " [" .. dist .. "m]"
            end
            task.wait(0.1)
        end
    end)
    
    return BillboardGui
end

VisualsTab:CreateToggle({
    Name = "Entity ESP (Dad & Monster)",
    CurrentValue = false,
    Flag = "EntityESP",
    Callback = function(Value)
        if Value then
            local Game = workspace:FindFirstChild("Game")
            if Game then
                local Dad = Game:FindFirstChild("dad")
                if Dad and Dad:FindFirstChild("Dad") then
                    CreateESP(Dad.Dad, Color3.fromRGB(255, 0, 0), "DAD")
                end
                
                local Monster = Game:FindFirstChild("Monster")
                if Monster and Monster:FindFirstChild("Xenobus") then
                    CreateESP(Monster.Xenobus, Color3.fromRGB(255, 0, 255), "XENOBUS")
                end
            end
        else
            ESPFolder:ClearAllChildren()
        end
    end,
})

VisualsTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreateESP(player.Character, Color3.fromRGB(0, 255, 0), player.Name)
                end
            end
        else
            for _, esp in pairs(ESPFolder:GetChildren()) do
                if not esp.Name:find("DAD") and not esp.Name:find("XENOBUS") then
                    esp:Destroy()
                end
            end
        end
    end,
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- TELEPORT TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local TeleportTab = Window:CreateTab("Teleport", 4483362458)

local function Teleport(pos)
    RefreshCharacter()
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    if HRP then
        HRP.CFrame = CFrame.new(pos)
    end
end

TeleportTab:CreateButton({
    Name = "Front Door",
    Callback = function()
        local House = workspace:FindFirstChild("House")
        if House and House:FindFirstChild("Doors") then
            local FrontDoor = House.Doors:FindFirstChild("FrontDoor")
            if FrontDoor and FrontDoor.PrimaryPart then
                Teleport(FrontDoor.PrimaryPart.Position + Vector3.new(0, 3, 5))
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Bedroom",
    Callback = function()
        local House = workspace:FindFirstChild("House")
        if House and House:FindFirstChild("Rooms") then
            local Bedroom = House.Rooms:FindFirstChild("Bedroom")
            if Bedroom then
                local Bed = Bedroom:FindFirstChild("Beds")
                if Bed then
                    for _, v in pairs(Bed:GetDescendants()) do
                        if v:IsA("BasePart") then
                            Teleport(v.Position + Vector3.new(0, 5, 0))
                            break
                        end
                    end
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Kitchen",
    Callback = function()
        local House = workspace:FindFirstChild("House")
        if House and House:FindFirstChild("Rooms") then
            local Kitchen = House.Rooms:FindFirstChild("Kitchen")
            if Kitchen then
                for _, v in pairs(Kitchen:GetDescendants()) do
                    if v:IsA("BasePart") then
                        Teleport(v.Position + Vector3.new(0, 5, 0))
                        break
                    end
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Garage",
    Callback = function()
        local House = workspace:FindFirstChild("House")
        if House and House:FindFirstChild("Structure") then
            local GarageDoor = House.Structure:FindFirstChild("GarageDoor")
            if GarageDoor then
                for _, v in pairs(GarageDoor:GetDescendants()) do
                    if v:IsA("BasePart") then
                        Teleport(v.Position + Vector3.new(0, 5, 5))
                        break
                    end
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Generator",
    Callback = function()
        local House = workspace:FindFirstChild("House")
        if House then
            local Generator = House:FindFirstChild("Generator")
            if Generator then
                for _, v in pairs(Generator:GetDescendants()) do
                    if v:IsA("BasePart") then
                        Teleport(v.Position + Vector3.new(0, 5, 0))
                        break
                    end
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Living Room",
    Callback = function()
        local House = workspace:FindFirstChild("House")
        if House and House:FindFirstChild("Rooms") then
            local LivingRoom = House.Rooms:FindFirstChild("Living Room")
            if LivingRoom then
                for _, v in pairs(LivingRoom:GetDescendants()) do
                    if v:IsA("BasePart") then
                        Teleport(v.Position + Vector3.new(0, 5, 0))
                        break
                    end
                end
            end
        end
    end,
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- MISC TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({
    Name = "Block Jumpscares",
    CurrentValue = false,
    Flag = "BlockJumpscares",
    Callback = function(Value)
        if Value then
            local JumpscareRemote = Remotes:FindFirstChild("Jumpscare")
            if JumpscareRemote then
                JumpscareRemote.OnClientInvoke = function()
                    return
                end
            end
        else
            local JumpscareRemote = Remotes:FindFirstChild("Jumpscare")
            if JumpscareRemote then
                JumpscareRemote.OnClientInvoke = function(arg1)
                    require(ReplicatedStorage.JumpScareModule):LoadJumpscare(arg1)
                end
            end
        end
    end,
})

MiscTab:CreateToggle({
    Name = "Instant Interact (No Hold)",
    CurrentValue = false,
    Flag = "InstantInteract",
    Callback = function(Value)
        if Value then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0.5
                end
            end
        end
    end,
})

-- Store original Died event for restoration
local OriginalDiedEvent = nil
local DiedEventBlocked = false

MiscTab:CreateToggle({
    Name = "Block Died Event",
    CurrentValue = false,
    Flag = "BlockDiedEvent",
    Callback = function(Value)
        local DiedRemote = Remotes:FindFirstChild("Died")
        if not DiedRemote then return end
        
        if Value then
            DiedEventBlocked = true
            
            -- Method 1: Hook the event using metatable (for most executors)
            pcall(function()
                if hookmetamethod then
                    local oldNamecall
                    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                        local method = getnamecallmethod()
                        if self == DiedRemote and (method == "Connect" or method == "connect" or method == "Wait" or method == "wait") then
                            return oldNamecall(self, function() end) -- Empty function
                        end
                        return oldNamecall(self, ...)
                    end)
                end
            end)
            
            -- Method 2: Disable by destroying and recreating (backup method)
            pcall(function()
                -- Store the remote's parent for potential restoration
                OriginalDiedEvent = DiedRemote
                -- Block by making a fake connection that does nothing
                local fakeConnection = DiedRemote.OnClientEvent:Connect(function()
                    -- Block everything - do absolutely nothing
                    return
                end)
                Connections["BlockDied"] = fakeConnection
            end)
            
            Rayfield:Notify({Title = "Died Event Blocked", Content = "The Died remote event is now blocked!", Duration = 3})
        else
            DiedEventBlocked = false
            if Connections["BlockDied"] then
                Connections["BlockDied"]:Disconnect()
                Connections["BlockDied"] = nil
            end
            Rayfield:Notify({Title = "Died Event Unblocked", Content = "Death system restored.", Duration = 3})
        end
    end,
})

MiscTab:CreateToggle({
    Name = "God Mode (Infinite Health)",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        if Connections["GodMode"] then
            Connections["GodMode"]:Disconnect()
            Connections["GodMode"] = nil
        end
        
        if Value then
            -- Keep health at max constantly
            Connections["GodMode"] = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if Character and Character:FindFirstChildOfClass("Humanoid") then
                        local hum = Character:FindFirstChildOfClass("Humanoid")
                        hum.Health = hum.MaxHealth
                    end
                end)
            end)
            
            -- Disable death state
            pcall(function()
                if Character and Character:FindFirstChildOfClass("Humanoid") then
                    Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                end
            end)
            
            Rayfield:Notify({Title = "God Mode", Content = "Health locked at max!", Duration = 3})
        else
            pcall(function()
                if Character and Character:FindFirstChildOfClass("Humanoid") then
                    Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                end
            end)
        end
    end,
})

MiscTab:CreateToggle({
    Name = "Anti-Death Effects",
    CurrentValue = false,
    Flag = "AntiDeathEffects",
    Callback = function(Value)
        if Connections["AntiDeath"] then
            Connections["AntiDeath"]:Disconnect()
            Connections["AntiDeath"] = nil
        end
        
        if Value then
            -- If Died event somehow fires, immediately undo everything
            Connections["AntiDeath"] = Remotes:FindFirstChild("Died").OnClientEvent:Connect(function()
                task.spawn(function()
                    task.wait(0.05)
                    pcall(function()
                        -- Re-enable all prompts
                        for _, v in pairs(workspace.House:GetDescendants()) do
                            if v:IsA("ProximityPrompt") then
                                v.Enabled = true
                            end
                        end
                        
                        -- Remove death atmosphere
                        if Lighting:FindFirstChild("AtmosphereDead") then
                            Lighting.AtmosphereDead:Destroy()
                        end
                        
                        -- Restore lighting
                        Lighting.EnvironmentDiffuseScale = 0.33
                        
                        -- Restore camera
                        LocalPlayer.CameraMaxZoomDistance = 0.5
                        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
                        LocalPlayer.CameraMinZoomDistance = 0.5
                        
                        -- Reset sleeping
                        if LocalPlayer:FindFirstChild("IsSleeping") then
                            LocalPlayer.IsSleeping.Value = false
                        end
                        
                        -- Hide spectate UI & show stats
                        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if PlayerGui then
                            local Spectate = PlayerGui:FindFirstChild("Spectate")
                            if Spectate and Spectate:FindFirstChild("Bg") then
                                Spectate.Bg.Visible = false
                            end
                            local Time = PlayerGui:FindFirstChild("Time")
                            if Time then
                                if Time:FindFirstChild("Energy") then Time.Energy.Visible = true end
                                if Time:FindFirstChild("Hunger") then Time.Hunger.Visible = true end
                                if Time:FindFirstChild("Thirst") then Time.Thirst.Visible = true end
                            end
                        end
                        
                        -- Re-enable controls
                        require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls():Enable()
                    end)
                end)
            end)
            
            Rayfield:Notify({Title = "Anti-Death Effects", Content = "Death effects will be instantly reversed!", Duration = 3})
        end
    end,
})

MiscTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        Humanoid.Health = 0
    end,
})

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- FUN/EXTRAS TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local FunTab = Window:CreateTab("Fun", 4483362458)

-- Night Vision (from Night Owl tool)
FunTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = false,
    Flag = "NightVision",
    Callback = function(Value)
        if Value then
            -- Create night vision effect
            pcall(function()
                -- Green ambient like Night Owl goggles
                Lighting.Ambient = Color3.fromRGB(18, 182, 0)
                Lighting.Brightness = 3
                Lighting.OutdoorAmbient = Color3.fromRGB(18, 182, 0)
                
                -- Create color correction for green tint
                local NVE = Instance.new("ColorCorrectionEffect")
                NVE.Name = "NightVisionEffect"
                NVE.TintColor = Color3.fromRGB(18, 255, 0)
                NVE.Saturation = -0.5
                NVE.Contrast = 0.3
                NVE.Brightness = 0.2
                NVE.Parent = Lighting
            end)
            Rayfield:Notify({Title = "Night Vision", Content = "Night vision goggles activated!", Duration = 2})
        else
            pcall(function()
                Lighting.Ambient = Color3.fromRGB(0, 0, 0)
                Lighting.Brightness = 1
                Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
                if Lighting:FindFirstChild("NightVisionEffect") then
                    Lighting.NightVisionEffect:Destroy()
                end
            end)
        end
    end,
})

-- Trigger Sebee Easter Egg
FunTab:CreateButton({
    Name = "Trigger Sebee Easter Egg",
    Callback = function()
        pcall(function()
            Remotes:FindFirstChild("Sebee"):FireServer()
        end)
        Rayfield:Notify({Title = "Sebee", Content = "Easter egg triggered! (if it exists)", Duration = 3})
    end,
})

-- Trigger Green Remote (mystery)
FunTab:CreateButton({
    Name = "Trigger Green Remote",
    Callback = function()
        pcall(function()
            Remotes:FindFirstChild("Green"):FireServer()
        end)
        Rayfield:Notify({Title = "Green", Content = "Green remote fired!", Duration = 2})
    end,
})

-- Voice Emotes Spam
local EmoteCategories = {"Default"}
local EmoteNames = {"Scream", "Laugh", "Cry", "Help"}

FunTab:CreateDropdown({
    Name = "Voice Emote",
    Options = {"Scream", "Laugh", "Cry", "Help", "Yes", "No"},
    CurrentOption = {"Scream"},
    MultipleOptions = false,
    Flag = "VoiceEmoteSelect",
    Callback = function(Option)
        -- Play the emote
        pcall(function()
            local VoiceEmote = nil
            -- Find VoiceEmote remote
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name == "VoiceEmote" then
                    VoiceEmote = v
                    break
                end
            end
            if VoiceEmote then
                VoiceEmote:FireServer("Default", Option[1] or Option)
            end
        end)
    end,
})

-- Camera Shake
FunTab:CreateButton({
    Name = "Trigger Camera Shake",
    Callback = function()
        pcall(function()
            local CameraShaker = require(ReplicatedStorage:FindFirstChild("CameraShaker", true))
            if CameraShaker then
                local shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCFrame
                end)
                shaker:Start()
                shaker:Shake(CameraShaker.Presets.Explosion)
                task.delay(1, function()
                    shaker:Stop()
                end)
            end
        end)
        Rayfield:Notify({Title = "Camera", Content = "Shake triggered!", Duration = 2})
    end,
})

-- Third Person Camera
FunTab:CreateToggle({
    Name = "Third Person Camera",
    CurrentValue = false,
    Flag = "ThirdPerson",
    Callback = function(Value)
        if Value then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMaxZoomDistance = 20
            LocalPlayer.CameraMinZoomDistance = 5
        else
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end,
})

-- FOV Slider
FunTab:CreateSlider({
    Name = "Field of View",
    Range = {30, 120},
    Increment = 5,
    Suffix = " FOV",
    CurrentValue = 70,
    Flag = "FOVSlider",
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
    end,
})

-- Teleport to Lobby
FunTab:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        game:GetService("TeleportService"):Teleport(14787369036, LocalPlayer)
    end,
})

-- Play Jumpscare Sound
FunTab:CreateButton({
    Name = "Play Jumpscare Sound",
    Callback = function()
        pcall(function()
            local JumpScares = ReplicatedStorage:FindFirstChild("JumpScares")
            if JumpScares then
                for _, js in pairs(JumpScares:GetChildren()) do
                    if js:FindFirstChild("Sounds") then
                        for _, sound in pairs(js.Sounds:GetChildren()) do
                            if sound:IsA("Sound") then
                                local s = sound:Clone()
                                s.Parent = workspace
                                s:Play()
                                game:GetService("Debris"):AddItem(s, 5)
                                break
                            end
                        end
                        break
                    end
                end
            end
        end)
    end,
})

-- Anti-AFK
FunTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        if Value then
            local VirtualUser = game:GetService("VirtualUser")
            Connections["AntiAFK"] = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            Rayfield:Notify({Title = "Anti-AFK", Content = "You won't be kicked for being idle!", Duration = 3})
        else
            if Connections["AntiAFK"] then
                Connections["AntiAFK"]:Disconnect()
                Connections["AntiAFK"] = nil
            end
        end
    end,
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- EXPLOITS TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local ExploitsTab = Window:CreateTab("Exploits", 4483362458)

-- Get all tools from ReplicatedStorage
local function GetAvailableTools()
    local tools = {}
    pcall(function()
        local Assets = ReplicatedStorage:FindFirstChild("Assets")
        if Assets then
            local Tools = Assets:FindFirstChild("Tools")
            if Tools then
                for _, tool in pairs(Tools:GetChildren()) do
                    if tool:IsA("Tool") or tool:FindFirstChild("Handle") then
                        table.insert(tools, tool.Name)
                    end
                end
            end
        end
    end)
    if #tools == 0 then
        tools = {"Night Owl", "Push", "Remote", "Drinking Glass", "Banana Peel", "gas can"}
    end
    return tools
end

-- Clone Tool to Backpack
ExploitsTab:CreateDropdown({
    Name = "Give Tool (Client)",
    Options = GetAvailableTools(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "GiveToolSelect",
    Callback = function(Option)
        local toolName = Option[1] or Option
        pcall(function()
            local Assets = ReplicatedStorage:FindFirstChild("Assets")
            if Assets then
                local Tools = Assets:FindFirstChild("Tools")
                if Tools then
                    local tool = Tools:FindFirstChild(toolName)
                    if tool then
                        local clone = tool:Clone()
                        clone.Parent = LocalPlayer.Backpack
                        Rayfield:Notify({Title = "Tool Given", Content = toolName .. " added to backpack!", Duration = 2})
                    end
                end
            end
        end)
    end,
})

ExploitsTab:CreateButton({
    Name = "Give ALL Tools",
    Callback = function()
        pcall(function()
            local Assets = ReplicatedStorage:FindFirstChild("Assets")
            if Assets then
                local Tools = Assets:FindFirstChild("Tools")
                if Tools then
                    local count = 0
                    for _, tool in pairs(Tools:GetChildren()) do
                        if tool:IsA("Tool") or tool:FindFirstChild("Handle") then
                            local clone = tool:Clone()
                            clone.Parent = LocalPlayer.Backpack
                            count = count + 1
                        end
                    end
                    Rayfield:Notify({Title = "Tools Given", Content = count .. " tools added!", Duration = 3})
                end
            end
        end)
    end,
})

-- Duplicate Current Tool
ExploitsTab:CreateButton({
    Name = "Duplicate Equipped Tool",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, item in pairs(char:GetChildren()) do
                    if item:IsA("Tool") then
                        local clone = item:Clone()
                        clone.Parent = LocalPlayer.Backpack
                        Rayfield:Notify({Title = "Duplicated", Content = item.Name .. " duplicated!", Duration = 2})
                        break
                    end
                end
            end
        end)
    end,
})

-- Infinite Tool Use (remove cooldowns)
ExploitsTab:CreateButton({
    Name = "Remove Tool Cooldowns",
    Callback = function()
        pcall(function()
            for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, v in pairs(tool:GetDescendants()) do
                        if v.Name == "Cooldown" and v:IsA("NumberValue") then
                            v.Value = 0
                        end
                    end
                end
            end
            local char = LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in pairs(tool:GetDescendants()) do
                            if v.Name == "Cooldown" and v:IsA("NumberValue") then
                                v.Value = 0
                            end
                        end
                    end
                end
            end
        end)
        Rayfield:Notify({Title = "Cooldowns", Content = "Tool cooldowns removed!", Duration = 2})
    end,
})

-- Spoof as Sebee
local SebeeUserId = 13319792 -- Sebee's actual Roblox UserId

ExploitsTab:CreateButton({
    Name = "Spoof as Sebee (Visual)",
    Callback = function()
        pcall(function()
            -- Fire Sebee remote
            if Remotes:FindFirstChild("Sebee") then
                Remotes.Sebee:FireServer()
            end
            
            -- Change character appearance to look like Sebee (client-side only)
            local char = LocalPlayer.Character
            if char then
                -- Try to change overhead display
                local head = char:FindFirstChild("Head")
                if head then
                    -- Create Sebee nametag
                    local existing = head:FindFirstChild("SebeeTag")
                    if existing then existing:Destroy() end
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "SebeeTag"
                    billboard.Size = UDim2.new(0, 100, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.Adornee = head
                    billboard.AlwaysOnTop = true
                    billboard.Parent = head
                    
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Text = "ð¬ Sebee"
                    text.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
                    text.TextStrokeTransparency = 0
                    text.TextStrokeColor3 = Color3.new(0, 0, 0)
                    text.Font = Enum.Font.GothamBold
                    text.TextSize = 16
                    text.Parent = billboard
                end
            end
        end)
        Rayfield:Notify({Title = "Sebee Spoof", Content = "You now appear as Sebee (client-side)!\nSebee remote fired!", Duration = 4})
    end,
})

-- Fake VIP Tag
ExploitsTab:CreateButton({
    Name = "Add Fake VIP Tag",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    local existing = head:FindFirstChild("VIPTag")
                    if existing then existing:Destroy() end
                    
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "VIPTag"
                    billboard.Size = UDim2.new(0, 80, 0, 25)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.Adornee = head
                    billboard.AlwaysOnTop = true
                    billboard.Parent = head
                    
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                    text.BackgroundTransparency = 0.3
                    text.Text = "â­ VIP â­"
                    text.TextColor3 = Color3.fromRGB(255, 255, 255)
                    text.TextStrokeTransparency = 0
                    text.Font = Enum.Font.GothamBold
                    text.TextSize = 12
                    text.Parent = billboard
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 8)
                    corner.Parent = text
                end
            end
        end)
        Rayfield:Notify({Title = "VIP Tag", Content = "Fake VIP tag added!", Duration = 2})
    end,
})

-- Set Money Display (client visual only)
ExploitsTab:CreateButton({
    Name = "Spoof Money Display (999999)",
    Callback = function()
        pcall(function()
            local Data = LocalPlayer:FindFirstChild("Data")
            if Data then
                local Money = Data:FindFirstChild("Money")
                if Money then
                    Money.Value = 999999
                end
            end
        end)
        Rayfield:Notify({Title = "Money Spoofed", Content = "Money display set to 999999 (visual only)", Duration = 3})
    end,
})

-- Unlock All Emotes (client bypass)
ExploitsTab:CreateButton({
    Name = "Unlock All Emotes (Visual)",
    Callback = function()
        pcall(function()
            local Emotes = ReplicatedStorage:FindFirstChild("Emotes")
            if Emotes then
                for _, category in pairs(Emotes:GetChildren()) do
                    local productId = category:FindFirstChild("ProductId")
                    if productId then
                        productId:Destroy()
                    end
                end
            end
        end)
        Rayfield:Notify({Title = "Emotes Unlocked", Content = "All emotes unlocked (client-side)!", Duration = 3})
    end,
})

-- Fake Gamepass (Better Flashlight)
ExploitsTab:CreateToggle({
    Name = "Fake Better Flashlight Gamepass",
    CurrentValue = false,
    Flag = "FakeFlashlightPass",
    Callback = function(Value)
        if Value then
            -- Find and modify flashlight settings
            pcall(function()
                local Players = workspace:FindFirstChild("Players")
                if Players then
                    local me = Players:FindFirstChild(LocalPlayer.Name)
                    if me then
                        local head = me:FindFirstChild("Head")
                        if head then
                            local light = head:FindFirstChild("Light")
                            if light then
                                light.Range = 60
                                light.Angle = 100
                            end
                        end
                    end
                end
            end)
            Rayfield:Notify({Title = "Flashlight Enhanced", Content = "Flashlight now has better range!", Duration = 3})
        end
    end,
})

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- SETTINGS TAB
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Flag = "ToggleKeybind",
    Callback = function(Keybind)
        -- Handled by Rayfield
    end,
})

SettingsTab:CreateButton({
    Name = "Destroy Script",
    Callback = function()
        for _, conn in pairs(Connections) do
            if conn then
                conn:Disconnect()
            end
        end
        ESPFolder:Destroy()
        Rayfield:Destroy()
    end,
})
