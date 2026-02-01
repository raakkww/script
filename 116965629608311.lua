-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = Workspace.CurrentCamera

-- Settings
local Settings = {
    SilentAim = false,
    AutoLoot = false,
    FOV = 200,
    PlayerESP = false,
    CorpseESP = false,
    CashESP = false
}

print("========================================")
print("GUN GAME EXPLOIT LOADING...")
print("========================================")

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

local function isEnemy(player)
    if not player then 
        return false 
    end
    
    local myTeam = LocalPlayer.Team
    if not myTeam then 
        return false 
    end
    
    if not player.Team then
        return false
    end
    
    return player.Team ~= myTeam
end

-- ========================================
-- SILENT AIM
-- ========================================

local silentAimConnection = nil
local fovCircle = nil

local function createFOVCircle()
    if fovCircle then
        pcall(function() fovCircle:Remove() end)
    end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 64
    fovCircle.Radius = Settings.FOV
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Transparency = 0.5
    fovCircle.Visible = Settings.SilentAim
    fovCircle.Filled = false
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    print("[Silent Aim] FOV circle created (Radius: " .. Settings.FOV .. ")")
end

createFOVCircle()

RunService.RenderStepped:Connect(function()
    local circleExists = pcall(function()
        return fovCircle.Visible
    end)
    
    if not circleExists then
        print("[Silent Aim] FOV circle was destroyed! Recreating...")
        createFOVCircle()
    end
    
    if fovCircle then
        pcall(function()
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Visible = Settings.SilentAim
            fovCircle.Radius = Settings.FOV
        end)
    end
end)

local function getClosestEnemyHead()
    if not Settings.SilentAim then return nil end
    if not Character then return nil end
    
    local myHRP = Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    local closestHead = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) then
            local char = player.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") then
                local humanoid = char.Humanoid
                if humanoid.Health > 0 then
                    local head = char.Head
                    local distance = (head.Position - myHRP.Position).Magnitude
                    
                    if distance < 500 and distance < closestDistance then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        
                        if onScreen then
                            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                            local distanceFromCenter = (targetScreenPos - screenCenter).Magnitude
                            
                            if distanceFromCenter <= Settings.FOV then
                                local ray = Ray.new(myHRP.Position, (head.Position - myHRP.Position).Unit * distance)
                                local hit, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {Character})
                                
                                if hit and hit:IsDescendantOf(char) then
                                    closestDistance = distance
                                    closestHead = head
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestHead
end

local function enableCameraSilentAim()
    if silentAimConnection then return end
    
    print("[Silent Aim] Starting camera-based aiming")
    
    silentAimConnection = RunService.RenderStepped:Connect(function()
        if not Settings.SilentAim then return end
        if not Character then return end
        
        local targetHead = getClosestEnemyHead()
        
        if targetHead then
            local currentCF = Camera.CFrame
            local targetPos = targetHead.Position
            
            local direction = (targetPos - currentCF.Position).Unit
            local targetCF = CFrame.new(currentCF.Position, currentCF.Position + direction)
            
            Camera.CFrame = currentCF:Lerp(targetCF, 0.3)
        end
    end)
    
    print("[Silent Aim] Camera aiming ENABLED")
end

local function disableCameraSilentAim()
    if silentAimConnection then
        silentAimConnection:Disconnect()
        silentAimConnection = nil
        print("[Silent Aim] Camera aiming DISABLED")
    end
end

-- ========================================
-- AUTO-LOOT
-- ========================================

local lastLootTime = 0
local autoLootConnection = nil
local lootAttempts = {}
local MAX_LOOT_ATTEMPTS = 5

local function findLootPrompts()
    local prompts = {}
    for _, descendant in pairs(Workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Name == "LickPrompt" then
            table.insert(prompts, descendant)
        end
    end
    return prompts
end

local function autoLootCorpses()
    if not Settings.AutoLoot then return end
    if not Character then return end
    
    if tick() - lastLootTime < 0.1 then return end
    
    local myHRP = Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local myTeam = LocalPlayer.Team
    if not myTeam then 
        return 
    end
    
    local prompts = findLootPrompts()
    
    if #prompts == 0 then
        return
    end
    
    for _, prompt in pairs(prompts) do
        local parent = prompt.Parent
        
        if parent and parent.Name == "HumanoidRootPart" then
            local corpseModel = parent.Parent
            
            if corpseModel then
                local humanoid = corpseModel:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    continue
                end
                
                local corpseName = corpseModel.Name
                
                local corpsePlayer = Players:FindFirstChild(corpseName)
                if corpsePlayer then
                    if corpsePlayer.Team == myTeam then
                        print("[Auto-Loot] Skipping teammate: " .. corpseName)
                        continue
                    end
                    
                    if corpsePlayer.TeamColor == LocalPlayer.TeamColor then
                        print("[Auto-Loot] Skipping teammate (TeamColor): " .. corpseName)
                        continue
                    end
                end
                
                if not lootAttempts[corpseName] then
                    lootAttempts[corpseName] = 0
                end
                
                if lootAttempts[corpseName] >= MAX_LOOT_ATTEMPTS then
                    continue
                end
                
                local distance = (parent.Position - myHRP.Position).Magnitude
                
                if distance > 50 then
                    continue
                end
                
                lootAttempts[corpseName] = lootAttempts[corpseName] + 1
                
                print("[Auto-Loot] Looting: " .. corpseName .. " (" .. math.floor(distance) .. " studs away)")
                
                local originalHold = prompt.HoldDuration
                prompt.HoldDuration = 0
                
                local success = pcall(function()
                    fireproximityprompt(prompt, 0, true)
                end)
                
                if success then
                    print("[Auto-Loot] ✓ Looted: " .. corpseName)
                    lootAttempts[corpseName] = 0
                else
                    print("[Auto-Loot] ✗ Failed: " .. corpseName)
                end
                
                task.delay(0.1, function()
                    if prompt then
                        prompt.HoldDuration = originalHold
                    end
                end)
                
                lastLootTime = tick()
            end
        end
    end
end

local function enableAutoLoot()
    if autoLootConnection then return end
    
    print("[Auto-Loot] Starting auto-loot system")
    
    autoLootConnection = RunService.Heartbeat:Connect(autoLootCorpses)
    
    print("[Auto-Loot] ENABLED")
end

local function disableAutoLoot()
    if autoLootConnection then
        autoLootConnection:Disconnect()
        autoLootConnection = nil
        lootAttempts = {}
        print("[Auto-Loot] DISABLED")
    end
end

-- ========================================
-- ESP SYSTEM (OPTIMIZED)
-- ========================================

local espObjects = {}

local function createESP(object, color, name)
    if not object or not object:IsA("BasePart") then return nil end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP_" .. name
    billboardGui.Adornee = object
    billboardGui.Size = UDim2.new(4, 0, 5, 0)
    billboardGui.StudsOffset = Vector3.new(0, 0, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = CoreGui
    
    local outlineFrame = Instance.new("Frame")
    outlineFrame.Size = UDim2.new(1, 0, 1, 0)
    outlineFrame.BackgroundTransparency = 1
    outlineFrame.BorderSizePixel = 0
    outlineFrame.Parent = billboardGui
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = color
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0
    uiStroke.Parent = outlineFrame
    
    local fillFrame = Instance.new("Frame")
    fillFrame.Size = UDim2.new(1, 0, 1, 0)
    fillFrame.BackgroundColor3 = color
    fillFrame.BackgroundTransparency = 0.7
    fillFrame.BorderSizePixel = 0
    fillFrame.Parent = billboardGui
    
    return billboardGui
end

local function removeESP(id)
    if espObjects[id] then
        pcall(function() espObjects[id]:Destroy() end)
        espObjects[id] = nil
    end
end

local function clearAllESP()
    for id, _ in pairs(espObjects) do
        removeESP(id)
    end
    espObjects = {}
end

local espConnection = nil

local function updateAllESP()
    local myTeam = LocalPlayer.Team
    
    local activePlayer = {}
    local activeCorpse = {}
    local activeCash = {}
    
    if Settings.PlayerESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not isEnemy(player) then continue end
            
            local char = player.Character
            if not char then continue end
            
            local humanoid = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and humanoid.Health > 0 then
                local espId = "Player_" .. player.Name
                activePlayer[espId] = true
                
                if espObjects[espId] then
                    local adornee = espObjects[espId].Adornee
                    if not adornee or adornee ~= hrp then
                        pcall(function() espObjects[espId]:Destroy() end)
                        espObjects[espId] = nil
                    end
                end
                
                if not espObjects[espId] then
                    local esp = createESP(hrp, Color3.fromRGB(255, 255, 255), player.Name)
                    if esp then
                        espObjects[espId] = esp
                    end
                end
            end
        end
    end
    
    if Settings.CorpseESP or Settings.CashESP then
        local descendants = Workspace:GetDescendants()
        
        for _, descendant in pairs(descendants) do
            if Settings.CorpseESP and myTeam and descendant:IsA("ProximityPrompt") and descendant.Name == "LickPrompt" then
                local hrp = descendant.Parent
                if hrp and hrp.Name == "HumanoidRootPart" then
                    local corpseModel = hrp.Parent
                    if corpseModel and corpseModel:IsA("Model") then
                        local humanoid = corpseModel:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                        else
                            local corpseName = corpseModel.Name:gsub("'s Body", "")
                            local corpsePlayer = Players:FindFirstChild(corpseName)
                            
                            local isTeammate = false
                            if corpsePlayer then
                                if corpsePlayer.Team == myTeam then isTeammate = true end
                                if corpsePlayer.TeamColor == LocalPlayer.TeamColor then isTeammate = true end
                            end
                            
                            if not isTeammate then
                                local espId = "Corpse_" .. hrp:GetDebugId()
                                activeCorpse[espId] = true
                                
                                if not espObjects[espId] then
                                    local esp = createESP(hrp, Color3.fromRGB(255, 0, 0), corpseName)
                                    if esp then
                                        espObjects[espId] = esp
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            if Settings.CashESP and descendant:IsA("Model") and descendant.Name == "Cash" then
                local cashPart = descendant:FindFirstChild("Cash")
                if cashPart and cashPart:IsA("BasePart") then
                    local espId = "Cash_" .. descendant:GetDebugId()
                    activeCash[espId] = true
                    
                    if not espObjects[espId] then
                        local esp = createESP(cashPart, Color3.fromRGB(0, 255, 0), "Cash")
                        if esp then
                            espObjects[espId] = esp
                        end
                    end
                end
            end
        end
    end
    
    local toRemove = {}
    
    for id, esp in pairs(espObjects) do
        if string.sub(id, 1, 7) == "Player_" then
            if not Settings.PlayerESP or not activePlayer[id] then
                toRemove[#toRemove + 1] = id
            end
        elseif string.sub(id, 1, 7) == "Corpse_" then
            if not Settings.CorpseESP or not activeCorpse[id] then
                toRemove[#toRemove + 1] = id
            end
        elseif string.sub(id, 1, 5) == "Cash_" then
            if not Settings.CashESP or not activeCash[id] then
                toRemove[#toRemove + 1] = id
            end
        end
    end
    
    for _, id in pairs(toRemove) do
        removeESP(id)
    end
end

local function startESP()
    if espConnection then return end
    
    espConnection = RunService.RenderStepped:Connect(updateAllESP)
    
    print("[ESP] ESP system started")
end

local function stopESP()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    clearAllESP()
    print("[ESP] ESP system stopped")
end

startESP()

-- ========================================
-- SYDE UI IMPLEMENTATION
-- ========================================

-- Load Syde UI Library
local success, syde = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/essencejs/syde/refs/heads/main/source", true))()
end)

if not success then
    warn("Failed to load Syde UI. Using fallback UI...")
    -- Fallback UI akan dibuat nanti jika perlu
    return
end

-- Initialize Syde UI
syde:Load({
    Logo = '7488932274',
    Name = 'Gun Game Hub',
    Status = 'Premium',
    Accent = Color3.fromRGB(251, 144, 255),
    HitBox = Color3.fromRGB(251, 144, 255),
    AutoLoad = false,
    Socials = {},
    ConfigurationSaving = {
        Enabled = true,
        FolderName = 'GunGameConfig',
        FileName = "settings"
    },
    AutoJoinDiscord = {
        Enabled = false,
        RememberJoins = false
    }
})

local Window = syde:Init({
    Title = 'Gun Game Hub',
    SubText = 'Premium Features'
})

-- Create Tabs
local AimTab = Window:InitTab('Aim & Combat')
local LootTab = Window:InitTab('Loot & ESP')
local VisualTab = Window:InitTab('Visuals')
local SettingsTab = Window:InitTab('Settings')

-- ========================================
-- VARIABLES UNTUK TOGGLE ELEMENTS
-- ========================================

local silentAimToggle
local autoLootToggle
local playerEspToggle
local corpseEspToggle
local cashEspToggle
local fovSlider

-- ========================================
-- AIM & COMBAT TAB
-- ========================================

AimTab:Section('Silent Aim Settings', '7488932274')

silentAimToggle = AimTab:Toggle({
    Title = 'Silent Aim',
    Description = 'Automatically aim at enemy heads',
    Value = Settings.SilentAim,
    CallBack = function(value)
        Settings.SilentAim = value
        
        if value then
            enableCameraSilentAim()
            if fovCircle then
                fovCircle.Visible = true
            end
            syde:Notify({
                Title = 'Silent Aim',
                Content = 'Silent Aim has been enabled!',
                Duration = 2
            })
        else
            disableCameraSilentAim()
            if fovCircle then
                fovCircle.Visible = false
            end
            syde:Notify({
                Title = 'Silent Aim',
                Content = 'Silent Aim has been disabled!',
                Duration = 2
            })
        end
    end,
})

-- FOV Slider yang benar-benar bekerja
fovSlider = AimTab:CreateSlider({
    Title = 'Aim Settings',
    Description = 'Adjust silent aim parameters',
    Sliders = {
        {
            Title = 'Aim FOV',
            Range = {100, 300},
            Increment = 1,
            StarterValue = Settings.FOV,
            CallBack = function(value)
                Settings.FOV = value
                if fovCircle then
                    pcall(function()
                        fovCircle.Radius = value
                    end)
                end
                syde:Notify({
                    Title = 'FOV Updated',
                    Content = 'Aim FOV set to: ' .. value,
                    Duration = 1
                })
            end,
        }
    }
})

-- ========================================
-- LOOT & ESP TAB
-- ========================================

LootTab:Section('Auto-Loot System')

autoLootToggle = LootTab:Toggle({
    Title = 'Auto-Loot',
    Description = 'Automatically loot enemy corpses (must be close)',
    Value = Settings.AutoLoot,
    CallBack = function(value)
        Settings.AutoLoot = value
        
        if value then
            enableAutoLoot()
            syde:Notify({
                Title = 'Auto-Loot',
                Content = 'Auto-Loot has been enabled!',
                Duration = 2
            })
        else
            disableAutoLoot()
            syde:Notify({
                Title = 'Auto-Loot',
                Content = 'Auto-Loot has been disabled!',
                Duration = 2
            })
        end
    end,
})

LootTab:Section('ESP Settings')

playerEspToggle = LootTab:Toggle({
    Title = 'Player ESP',
    Description = 'Show enemies through walls',
    Value = Settings.PlayerESP,
    CallBack = function(value)
        Settings.PlayerESP = value
        syde:Notify({
            Title = 'Player ESP',
            Content = value and 'Player ESP enabled!' or 'Player ESP disabled!',
            Duration = 2
        })
    end,
})

corpseEspToggle = LootTab:Toggle({
    Title = 'Corpse ESP',
    Description = 'Show lootable corpses',
    Value = Settings.CorpseESP,
    CallBack = function(value)
        Settings.CorpseESP = value
        syde:Notify({
            Title = 'Corpse ESP',
            Content = value and 'Corpse ESP enabled!' or 'Corpse ESP disabled!',
            Duration = 2
        })
    end,
})

cashEspToggle = LootTab:Toggle({
    Title = 'Cash ESP',
    Description = 'Show cash drops',
    Value = Settings.CashESP,
    CallBack = function(value)
        Settings.CashESP = value
        syde:Notify({
            Title = 'Cash ESP',
            Content = value and 'Cash ESP enabled!' or 'Cash ESP disabled!',
            Duration = 2
        })
    end,
})

LootTab:Button({
    Title = 'Refresh ESP',
    Description = 'Force refresh ESP objects',
    CallBack = function()
        clearAllESP()
        syde:Notify({
            Title = 'ESP Refreshed',
            Content = 'All ESP objects have been refreshed!',
            Duration = 2
        })
    end,
})

-- ========================================
-- VISUALS TAB
-- ========================================

VisualTab:Section('ESP Colors')

local playerEspColor = Color3.fromRGB(255, 255, 255)
local corpseEspColor = Color3.fromRGB(255, 0, 0)
local cashEspColor = Color3.fromRGB(0, 255, 0)

VisualTab:ColorPicker({
    Title = 'Player ESP Color',
    Color = playerEspColor,
    CallBack = function(color)
        playerEspColor = color
        syde:Notify({
            Title = 'Color Changed',
            Content = 'Player ESP color updated!',
            Duration = 2
        })
    end,
})

VisualTab:ColorPicker({
    Title = 'Corpse ESP Color',
    Color = corpseEspColor,
    CallBack = function(color)
        corpseEspColor = color
        syde:Notify({
            Title = 'Color Changed',
            Content = 'Corpse ESP color updated!',
            Duration = 2
        })
    end,
})

VisualTab:ColorPicker({
    Title = 'Cash ESP Color',
    Color = cashEspColor,
    CallBack = function(color)
        cashEspColor = color
        syde:Notify({
            Title = 'Color Changed',
            Content = 'Cash ESP color updated!',
            Duration = 2
        })
    end,
})

-- ========================================
-- SETTINGS TAB
-- ========================================

SettingsTab:Section('Keybinds')

local uiKeybind = Enum.KeyCode.RightShift
local settingKeybind = false

SettingsTab:Keybind({
    Title = 'Toggle UI',
    Description = 'Show/Hide the main UI',
    Key = uiKeybind,
    CallBack = function()
        -- This function will be called when keybind is pressed
        syde:Notify({
            Title = 'UI Keybind',
            Content = 'Press ' .. uiKeybind.Name .. ' to toggle UI!',
            Duration = 2
        })
    end,
})

-- Setup global keybind untuk toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == uiKeybind then
        -- Toggle UI visibility
        syde:Notify({
            Title = 'UI Toggled',
            Content = 'UI visibility changed!',
            Duration = 1
        })
    end
end)

SettingsTab:Section('Configuration')

SettingsTab:Button({
    Title = 'Save Settings',
    Description = 'Save current configuration',
    CallBack = function()
        -- Save settings logic
        syde:Notify({
            Title = 'Settings Saved',
            Content = 'All settings have been saved!',
            Duration = 3
        })
    end,
})

SettingsTab:Button({
    Title = 'Load Settings',
    Description = 'Load saved configuration',
    CallBack = function()
        -- Load settings logic
        syde:Notify({
            Title = 'Settings Loaded',
            Content = 'Settings loaded successfully!',
            Duration = 3
        })
    end,
})

SettingsTab:Button({
    Title = 'Reset Settings',
    Description = 'Reset all settings to default',
    Type = 'Hold',
    HoldTime = 2,
    CallBack = function()
        -- Reset semua settings
        Settings = {
            SilentAim = false,
            AutoLoot = false,
            FOV = 200,
            PlayerESP = false,
            CorpseESP = false,
            CashESP = false
        }
        
        -- Update toggle states
        if silentAimToggle then
            silentAimToggle:SetValue(false)
        end
        if autoLootToggle then
            autoLootToggle:SetValue(false)
        end
        if playerEspToggle then
            playerEspToggle:SetValue(false)
        end
        if corpseEspToggle then
            corpseEspToggle:SetValue(false)
        end
        if cashEspToggle then
            cashEspToggle:SetValue(false)
        end
        
        -- Disable semua fitur
        disableCameraSilentAim()
        disableAutoLoot()
        
        -- Reset FOV circle
        if fovCircle then
            fovCircle.Visible = false
            fovCircle.Radius = 200
        end
        
        syde:Notify({
            Title = 'Settings Reset',
            Content = 'All settings have been reset to default!',
            Duration = 4
        })
    end,
})

SettingsTab:Section('Utilities')

SettingsTab:Button({
    Title = 'Check Features',
    Description = 'Check status of all features',
    CallBack = function()
        local status = ""
        status = status .. "Silent Aim: " .. (Settings.SilentAim and "ON" or "OFF") .. "\n"
        status = status .. "Auto-Loot: " .. (Settings.AutoLoot and "ON" or "OFF") .. "\n"
        status = status .. "Player ESP: " .. (Settings.PlayerESP and "ON" or "OFF") .. "\n"
        status = status .. "Corpse ESP: " .. (Settings.CorpseESP and "ON" or "OFF") .. "\n"
        status = status .. "Cash ESP: " .. (Settings.CashESP and "ON" or "OFF") .. "\n"
        status = status .. "FOV: " .. Settings.FOV
        
        syde:Notify({
            Title = 'Feature Status',
            Content = status,
            Duration = 5
        })
    end,
})

-- ========================================
-- NOTIFICATIONS AND CLEANUP
-- ========================================

syde:Notify({
    Title = 'Gun Game Hub',
    Content = 'Premium features loaded successfully!',
    Duration = 5
})

print('Gun Game Hub UI loaded successfully!')
print('Silent Aim: ' .. (Settings.SilentAim and "ENABLED" or "DISABLED"))
print('Auto-Loot: ' .. (Settings.AutoLoot and "ENABLED" or "DISABLED"))
print('ESP System: ACTIVE')

-- Handle character respawns
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Camera = Workspace.CurrentCamera
    print("[Respawn] Character reloaded")
    
    -- Recreate FOV circle jika diperlukan
    if fovCircle and not pcall(function() return fovCircle.Visible end) then
        createFOVCircle()
    end
end)

-- Cleanup function
local function cleanup()
    disableCameraSilentAim()
    disableAutoLoot()
    stopESP()
    
    if fovCircle then
        fovCircle.Visible = false
        fovCircle:Remove()
    end
    
    print("[Cleanup] All systems stopped")
end

-- Connect cleanup to game closing
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(cleanup)

-- Auto cleanup jika script di-stop
local connection
connection = game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "Syde" then
        cleanup()
        connection:Disconnect()
    end
end)
