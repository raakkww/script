-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
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

-- FOV circle created once at script load — always exists, slider updates radius,
-- visibility is just toggled by silent aim on/off
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

-- FOV circle position updater (always running to keep circle centered)
-- Also recreates circle if it gets destroyed by anti-cheat
RunService.RenderStepped:Connect(function()
    -- Check if circle still exists, recreate if destroyed
    local circleExists = pcall(function()
        return fovCircle.Visible
    end)
    
    if not circleExists then
        print("[Silent Aim] FOV circle was destroyed! Recreating...")
        createFOVCircle()
    end
    
    -- Update circle
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
                
                -- ENHANCED 4-LAYER TEAM DETECTION
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

-- Single optimized ESP update — one GetDescendants() call, one pass for everything
local espConnection = nil

local function updateAllESP()
    local myTeam = LocalPlayer.Team
    
    -- Track which IDs are still valid this frame
    local activePlayer = {}
    local activeCorpse = {}
    local activeCash = {}
    
    -- ---- PLAYER ESP ----
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
                
                -- Check if existing ESP's adornee is still valid
                if espObjects[espId] then
                    local adornee = espObjects[espId].Adornee
                    if not adornee or adornee ~= hrp then
                        -- Adornee changed (respawn) or gone — remove and recreate
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
    
    -- ---- CORPSE + CASH ESP (single shared scan) ----
    if Settings.CorpseESP or Settings.CashESP then
        local descendants = Workspace:GetDescendants()
        
        for _, descendant in pairs(descendants) do
            -- CORPSE ESP — find by LickPrompt on HumanoidRootPart (same method as auto-loot)
            if Settings.CorpseESP and myTeam and descendant:IsA("ProximityPrompt") and descendant.Name == "LickPrompt" then
                local hrp = descendant.Parent
                if hrp and hrp.Name == "HumanoidRootPart" then
                    local corpseModel = hrp.Parent
                    if corpseModel and corpseModel:IsA("Model") then
                        -- Skip if it's a living player (has Humanoid with health > 0)
                        local humanoid = corpseModel:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            -- living player, not a corpse
                        else
                            -- Team filter
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
            
            -- CASH ESP
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
    
    -- ---- CLEANUP: collect stale IDs first, then remove ----
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

-- Start ESP system
startESP()

-- ========================================
-- GUI SETUP
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LucidsHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    screenGui.Parent = CoreGui
end)
if screenGui.Parent ~= CoreGui then
    screenGui.Parent = playerGui
end

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Animated Border
local borderFrame = Instance.new("Frame")
borderFrame.Name = "BorderFrame"
borderFrame.Size = UDim2.new(0, 504, 0, 354)
borderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
borderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
borderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
borderFrame.BorderSizePixel = 0
borderFrame.ZIndex = -1
borderFrame.Parent = screenGui

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 10)
borderCorner.Parent = borderFrame

local borderGradient = Instance.new("UIGradient")
borderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
}
borderGradient.Rotation = 0
borderGradient.Parent = borderFrame

spawn(function()
    local rotateTween = TweenService:Create(borderGradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
        Rotation = 360
    })
    rotateTween:Play()
end)

-- Shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = 0
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(23, 23, 277, 277)
shadow.Parent = mainFrame

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = topBar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
}
gradient.Rotation = 90
gradient.Parent = topBar

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = ""
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.Code
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextTransparency = 1
titleLabel.Parent = topBar

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Thickness = 1
titleStroke.Transparency = 0.3
titleStroke.Parent = titleLabel

-- Settings Button
local settingsBtn = Instance.new("TextButton")
settingsBtn.Name = "SettingsBtn"
settingsBtn.Size = UDim2.new(0, 30, 0, 30)
settingsBtn.Position = UDim2.new(1, -105, 0.5, 0)
settingsBtn.AnchorPoint = Vector2.new(0, 0.5)
settingsBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
settingsBtn.BorderSizePixel = 0
settingsBtn.Text = "⚙️"
settingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsBtn.TextSize = 18
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.AutoButtonColor = false
settingsBtn.Parent = topBar

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsBtn

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -70, 0.5, 0)
minimizeBtn.AnchorPoint = Vector2.new(0, 0.5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, 0)
closeBtn.AnchorPoint = Vector2.new(0, 0.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 24
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -30, 1, -60)
contentFrame.Position = UDim2.new(0, 15, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Visible = true
contentFrame.Parent = mainFrame

-- ========================================
-- FEATURE BUTTONS
-- ========================================

-- Silent Aim Button
local silentAimBtn = Instance.new("TextButton")
silentAimBtn.Name = "SilentAimBtn"
silentAimBtn.Size = UDim2.new(1, 0, 0, 45)
silentAimBtn.Position = UDim2.new(0, 0, 0, 0)
silentAimBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF (darker black)
silentAimBtn.BorderSizePixel = 0
silentAimBtn.Text = "Silent Aim"
silentAimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
silentAimBtn.TextSize = 16
silentAimBtn.Font = Enum.Font.GothamBold
silentAimBtn.AutoButtonColor = false
silentAimBtn.Parent = contentFrame

local silentAimCorner = Instance.new("UICorner")
silentAimCorner.CornerRadius = UDim.new(0, 8)
silentAimCorner.Parent = silentAimBtn

-- FOV Slider (directly under Silent Aim)
local fovSliderFrame = Instance.new("Frame")
fovSliderFrame.Name = "FOVSliderFrame"
fovSliderFrame.Size = UDim2.new(1, 0, 0, 60)
fovSliderFrame.Position = UDim2.new(0, 0, 0, 55)
fovSliderFrame.BackgroundTransparency = 1
fovSliderFrame.Parent = contentFrame

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, 0, 0, 20)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "Silent Aim FOV: " .. Settings.FOV
fovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fovLabel.TextSize = 14
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = fovSliderFrame

local fovSliderBG = Instance.new("Frame")
fovSliderBG.Size = UDim2.new(1, 0, 0, 8)
fovSliderBG.Position = UDim2.new(0, 0, 0, 30)
fovSliderBG.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
fovSliderBG.BorderSizePixel = 0
fovSliderBG.Parent = fovSliderFrame

local fovSliderBGCorner = Instance.new("UICorner")
fovSliderBGCorner.CornerRadius = UDim.new(0, 4)
fovSliderBGCorner.Parent = fovSliderBG

local fovSliderFill = Instance.new("Frame")
fovSliderFill.Size = UDim2.new(0.5, 0, 1, 0) -- Start at 50% (200 FOV)
fovSliderFill.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
fovSliderFill.BorderSizePixel = 0
fovSliderFill.Parent = fovSliderBG

local fovSliderFillCorner = Instance.new("UICorner")
fovSliderFillCorner.CornerRadius = UDim.new(0, 4)
fovSliderFillCorner.Parent = fovSliderFill

local fovSliderButton = Instance.new("TextButton")
fovSliderButton.Size = UDim2.new(0, 20, 0, 20)
fovSliderButton.Position = UDim2.new(0.5, -10, 0.5, -10)
fovSliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovSliderButton.BorderSizePixel = 0
fovSliderButton.Text = ""
fovSliderButton.Parent = fovSliderBG

local fovSliderButtonCorner = Instance.new("UICorner")
fovSliderButtonCorner.CornerRadius = UDim.new(1, 0)
fovSliderButtonCorner.Parent = fovSliderButton

-- Auto-Loot Button
local autoLootBtn = Instance.new("TextButton")
autoLootBtn.Name = "AutoLootBtn"
autoLootBtn.Size = UDim2.new(1, 0, 0, 45)
autoLootBtn.Position = UDim2.new(0, 0, 0, 125)
autoLootBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF (darker black)
autoLootBtn.BorderSizePixel = 0
autoLootBtn.Text = "Auto-Loot"
autoLootBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLootBtn.TextSize = 16
autoLootBtn.Font = Enum.Font.GothamBold
autoLootBtn.AutoButtonColor = false
autoLootBtn.Parent = contentFrame

local autoLootCorner = Instance.new("UICorner")
autoLootCorner.CornerRadius = UDim.new(0, 8)
autoLootCorner.Parent = autoLootBtn

-- Small text under Auto-Loot
local mustBeCloseLabel = Instance.new("TextLabel")
mustBeCloseLabel.Size = UDim2.new(1, 0, 0, 15)
mustBeCloseLabel.Position = UDim2.new(0, 0, 0, 175)
mustBeCloseLabel.BackgroundTransparency = 1
mustBeCloseLabel.Text = "(MUST BE CLOSE)"
mustBeCloseLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
mustBeCloseLabel.TextSize = 11
mustBeCloseLabel.Font = Enum.Font.Gotham
mustBeCloseLabel.TextXAlignment = Enum.TextXAlignment.Center
mustBeCloseLabel.Parent = contentFrame

-- ESP Buttons Container
local espFrame = Instance.new("Frame")
espFrame.Name = "ESPFrame"
espFrame.Size = UDim2.new(1, 0, 0, 45)
espFrame.Position = UDim2.new(0, 0, 0, 200)
espFrame.BackgroundTransparency = 1
espFrame.Parent = contentFrame

-- Player ESP Button (1/3 width)
local playerESPBtn = Instance.new("TextButton")
playerESPBtn.Name = "PlayerESPBtn"
playerESPBtn.Size = UDim2.new(0.32, 0, 1, 0)
playerESPBtn.Position = UDim2.new(0, 0, 0, 0)
playerESPBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF
playerESPBtn.BorderSizePixel = 0
playerESPBtn.Text = "Player ESP"
playerESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playerESPBtn.TextSize = 14
playerESPBtn.Font = Enum.Font.GothamBold
playerESPBtn.AutoButtonColor = false
playerESPBtn.Parent = espFrame

local playerESPCorner = Instance.new("UICorner")
playerESPCorner.CornerRadius = UDim.new(0, 8)
playerESPCorner.Parent = playerESPBtn

-- Corpse ESP Button (1/3 width)
local corpseESPBtn = Instance.new("TextButton")
corpseESPBtn.Name = "CorpseESPBtn"
corpseESPBtn.Size = UDim2.new(0.32, 0, 1, 0)
corpseESPBtn.Position = UDim2.new(0.34, 0, 0, 0)
corpseESPBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF
corpseESPBtn.BorderSizePixel = 0
corpseESPBtn.Text = "Corpse ESP"
corpseESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
corpseESPBtn.TextSize = 14
corpseESPBtn.Font = Enum.Font.GothamBold
corpseESPBtn.AutoButtonColor = false
corpseESPBtn.Parent = espFrame

local corpseESPCorner = Instance.new("UICorner")
corpseESPCorner.CornerRadius = UDim.new(0, 8)
corpseESPCorner.Parent = corpseESPBtn

-- Cash ESP Button (1/3 width)
local cashESPBtn = Instance.new("TextButton")
cashESPBtn.Name = "CashESPBtn"
cashESPBtn.Size = UDim2.new(0.32, 0, 1, 0)
cashESPBtn.Position = UDim2.new(0.68, 0, 0, 0)
cashESPBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF
cashESPBtn.BorderSizePixel = 0
cashESPBtn.Text = "Cash ESP"
cashESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cashESPBtn.TextSize = 14
cashESPBtn.Font = Enum.Font.GothamBold
cashESPBtn.AutoButtonColor = false
cashESPBtn.Parent = espFrame

local cashESPCorner = Instance.new("UICorner")
cashESPCorner.CornerRadius = UDim.new(0, 8)
cashESPCorner.Parent = cashESPBtn

-- Settings Frame
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsFrame"
settingsFrame.Size = UDim2.new(0, 500, 0, 310)
settingsFrame.Position = UDim2.new(0.5, 0, 0.5, 20)
settingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.ClipsDescendants = true
settingsFrame.Parent = screenGui

local settingsFrameCorner = Instance.new("UICorner")
settingsFrameCorner.CornerRadius = UDim.new(0, 8)
settingsFrameCorner.Parent = settingsFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Name = "SettingsTitle"
settingsTitle.Size = UDim2.new(1, -30, 0, 30)
settingsTitle.Position = UDim2.new(0, 15, 0, 15)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Settings"
settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTitle.TextSize = 20
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.TextYAlignment = Enum.TextYAlignment.Top
settingsTitle.Parent = settingsFrame

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Name = "KeybindLabel"
keybindLabel.Size = UDim2.new(1, -30, 0, 20)
keybindLabel.Position = UDim2.new(0, 15, 0, 60)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Toggle GUI Keybind:"
keybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
keybindLabel.TextSize = 14
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.TextYAlignment = Enum.TextYAlignment.Top
keybindLabel.Parent = settingsFrame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Name = "KeybindBtn"
keybindBtn.Size = UDim2.new(1, -30, 0, 45)
keybindBtn.Position = UDim2.new(0, 15, 0, 90)
keybindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
keybindBtn.BorderSizePixel = 0
keybindBtn.Text = "RightShift"
keybindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindBtn.TextSize = 16
keybindBtn.Font = Enum.Font.GothamBold
keybindBtn.AutoButtonColor = false
keybindBtn.Parent = settingsFrame

local keybindBtnCorner = Instance.new("UICorner")
keybindBtnCorner.CornerRadius = UDim.new(0, 8)
keybindBtnCorner.Parent = keybindBtn

local creditLabel = Instance.new("TextLabel")
creditLabel.Name = "CreditLabel"
creditLabel.Size = UDim2.new(1, 0, 0, 25)
creditLabel.Position = UDim2.new(0, 0, 1, -35)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = ""
creditLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
creditLabel.TextSize = 12
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextXAlignment = Enum.TextXAlignment.Center
creditLabel.TextYAlignment = Enum.TextYAlignment.Bottom
creditLabel.Parent = settingsFrame

-- ========================================
-- BUTTON LOGIC
-- ========================================

-- Silent Aim Toggle
silentAimBtn.MouseButton1Click:Connect(function()
    Settings.SilentAim = not Settings.SilentAim
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if Settings.SilentAim then
        TweenService:Create(silentAimBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- ON (lighter black)
        }):Play()
        enableCameraSilentAim()
    else
        TweenService:Create(silentAimBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF (darker black)
        }):Play()
        disableCameraSilentAim()
    end
end)

-- Auto-Loot Toggle
autoLootBtn.MouseButton1Click:Connect(function()
    Settings.AutoLoot = not Settings.AutoLoot
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if Settings.AutoLoot then
        TweenService:Create(autoLootBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- ON (lighter black)
        }):Play()
        enableAutoLoot()
    else
        TweenService:Create(autoLootBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF (darker black)
        }):Play()
        disableAutoLoot()
    end
end)

-- Player ESP Toggle
playerESPBtn.MouseButton1Click:Connect(function()
    Settings.PlayerESP = not Settings.PlayerESP
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if Settings.PlayerESP then
        TweenService:Create(playerESPBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- ON
        }):Play()
        print("[ESP] Player ESP enabled")
    else
        TweenService:Create(playerESPBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF
        }):Play()
        print("[ESP] Player ESP disabled")
    end
end)

-- Corpse ESP Toggle
corpseESPBtn.MouseButton1Click:Connect(function()
    Settings.CorpseESP = not Settings.CorpseESP
    
    local tweenModel = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if Settings.CorpseESP then
        TweenService:Create(corpseESPBtn, tweenModel, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- ON
        }):Play()
        print("[ESP] Corpse ESP enabled")
    else
        TweenService:Create(corpseESPBtn, tweenModel, {
            BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF
        }):Play()
        print("[ESP] Corpse ESP disabled")
    end
end)

-- Cash ESP Toggle
cashESPBtn.MouseButton1Click:Connect(function()
    Settings.CashESP = not Settings.CashESP
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if Settings.CashESP then
        TweenService:Create(cashESPBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- ON
        }):Play()
        print("[ESP] Cash ESP enabled")
    else
        TweenService:Create(cashESPBtn, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- OFF
        }):Play()
        print("[ESP] Cash ESP disabled")
    end
end)

-- FOV Slider Logic
local draggingFOV = false

local function updateFOVSlider(input)
    local relativeX = math.clamp((input.Position.X - fovSliderBG.AbsolutePosition.X) / fovSliderBG.AbsoluteSize.X, 0, 1)
    
    local newFOV = math.floor(100 + (relativeX * 200))
    Settings.FOV = newFOV
    
    -- Safely update FOV circle radius
    if fovCircle then
        pcall(function()
            fovCircle.Radius = newFOV
        end)
    end
    
    fovSliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
    fovSliderButton.Position = UDim2.new(relativeX, -10, 0.5, -10)
    fovLabel.Text = "Silent Aim FOV: " .. newFOV
end

fovSliderButton.MouseButton1Down:Connect(function()
    draggingFOV = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFOV and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateFOVSlider(input)
    end
end)

fovSliderBG.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        updateFOVSlider(input)
        draggingFOV = true
    end
end)

-- ========================================
-- GUI ANIMATIONS & CONTROLS
-- ========================================

local isMinimized = false
local isHidden = false
local settingsOpen = false
local settingKeybind = false
local currentKeybind = Enum.KeyCode.RightShift
local dragToggle = nil
local dragSpeed = 0.15
local dragStart = nil
local startPos = nil

-- Opening Animation
local function playOpeningAnimation()
    mainFrame.Size = UDim2.new(0, 0, 0, 40)
    borderFrame.Size = UDim2.new(0, 0, 0, 44)
    
    local topBarAppear = TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 40)
    })
    
    local borderAppear = TweenService:Create(borderFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 504, 0, 44)
    })
    
    local titleAppear = TweenService:Create(titleLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.4), {
        TextTransparency = 0
    })
    
    topBarAppear:Play()
    borderAppear:Play()
    titleAppear:Play()
    
    topBarAppear.Completed:Wait()
    wait(0.2)
    
    local mainExpand = TweenService:Create(mainFrame, TweenInfo.new(0.9, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 350)
    })
    
    local borderExpand = TweenService:Create(borderFrame, TweenInfo.new(0.9, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 504, 0, 354)
    })
    
    mainExpand:Play()
    borderExpand:Play()
    mainExpand.Completed:Wait()
end

-- Dragging
local function updateDrag(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    
    TweenService:Create(mainFrame, TweenInfo.new(dragSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = position
    }):Play()
    
    TweenService:Create(borderFrame, TweenInfo.new(dragSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = position
    }):Play()
    
    local settingsPos = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 20)
    TweenService:Create(settingsFrame, TweenInfo.new(dragSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = settingsPos
    }):Play()
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- Settings Toggle
settingsBtn.MouseButton1Click:Connect(function()
    settingsOpen = not settingsOpen
    settingsFrame.Visible = settingsOpen
    
    if settingsOpen and isMinimized then
        settingsFrame.Size = UDim2.new(0, 500, 0, 0)
    end
end)

-- Keybind Setting
keybindBtn.MouseButton1Click:Connect(function()
    if not settingKeybind then
        settingKeybind = true
        keybindBtn.Text = "Press any key..."
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if settingKeybind and not gameProcessed then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            currentKeybind = input.KeyCode
            keybindBtn.Text = input.KeyCode.Name
            settingKeybind = false
        end
    end
    
    if input.KeyCode == currentKeybind and not gameProcessed and not settingKeybind then
        isHidden = not isHidden
        
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        if isHidden then
            if settingsOpen then
                settingsFrame.Visible = false
            end
            
            TweenService:Create(mainFrame, tweenInfo, {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            TweenService:Create(borderFrame, tweenInfo, {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
        else
            if settingsOpen then
                settingsFrame.Visible = true
                if isMinimized then
                    settingsFrame.Size = UDim2.new(0, 500, 0, 0)
                else
                    settingsFrame.Size = UDim2.new(0, 500, 0, 310)
                end
            end
            
            if isMinimized then
                TweenService:Create(mainFrame, tweenInfo, {
                    Size = UDim2.new(0, 500, 0, 40)
                }):Play()
                TweenService:Create(borderFrame, tweenInfo, {
                    Size = UDim2.new(0, 504, 0, 44)
                }):Play()
            else
                TweenService:Create(mainFrame, tweenInfo, {
                    Size = UDim2.new(0, 500, 0, 350)
                }):Play()
                TweenService:Create(borderFrame, tweenInfo, {
                    Size = UDim2.new(0, 504, 0, 354)
                }):Play()
            end
        end
    end
end)

-- Minimize Toggle
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    
    if isMinimized then
        minimizeBtn.Text = "+"
        if settingsOpen then
            TweenService:Create(settingsFrame, tweenInfo, {
                Size = UDim2.new(0, 500, 0, 0)
            }):Play()
        end
        TweenService:Create(mainFrame, tweenInfo, {
            Size = UDim2.new(0, 500, 0, 40)
        }):Play()
        TweenService:Create(borderFrame, tweenInfo, {
            Size = UDim2.new(0, 504, 0, 44)
        }):Play()
    else
        minimizeBtn.Text = "−"
        if settingsOpen then
            TweenService:Create(settingsFrame, tweenInfo, {
                Size = UDim2.new(0, 500, 0, 310)
            }):Play()
        end
        TweenService:Create(mainFrame, tweenInfo, {
            Size = UDim2.new(0, 500, 0, 350)
        }):Play()
        TweenService:Create(borderFrame, tweenInfo, {
            Size = UDim2.new(0, 504, 0, 354)
        }):Play()
    end
end)

-- Close GUI
closeBtn.MouseButton1Click:Connect(function()
    disableCameraSilentAim()
    disableAutoLoot()
    stopESP()
    
    if fovCircle then
        fovCircle.Visible = false
        fovCircle:Remove()
    end
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    
    local closeTween = TweenService:Create(mainFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 40)
    })
    
    local borderCloseTween = TweenService:Create(borderFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 44)
    })
    
    local fadeTween = TweenService:Create(titleLabel, tweenInfo, {
        TextTransparency = 1
    })
    
    closeTween:Play()
    borderCloseTween:Play()
    fadeTween:Play()
    
    closeTween.Completed:Wait()
    screenGui:Destroy()
end)

-- Hover Effects
local function addHoverEffect(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = normalColor
        }):Play()
    end)
end

addHoverEffect(settingsBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(30, 30, 30))
addHoverEffect(minimizeBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(30, 30, 30))
addHoverEffect(closeBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(30, 30, 30))
addHoverEffect(keybindBtn, Color3.fromRGB(45, 45, 45), Color3.fromRGB(30, 30, 30))

-- Handle respawns
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Camera = Workspace.CurrentCamera
    print("[Respawn] Character reloaded")
end)

playOpeningAnimation()
