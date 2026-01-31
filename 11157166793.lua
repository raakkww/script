local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LP = Players.LocalPlayer
local ServerEvents = ReplicatedStorage:WaitForChild("ServerEvents")
local BiteEvent = ServerEvents:WaitForChild("Bite")
local DigEvent = ServerEvents:WaitForChild("Dig")
local LarvaeEvent = ServerEvents:WaitForChild("Larvae")

-- Global States
_G.AuraEnabled = true
_G.DigAuraEnabled = false
_G.ShowHUD = true
_G.ESPEnabled = true
_G.SpeedBypassEnabled = false 
_G.TargetWalkSpeed = 16 

-- Monitor States 
_G.MonitorEnabled = false
local allyHealthCache = {}
local allyAlertTimer = 0
local lastQueenHealth = 100
_G.QueenAttackTimer = 0
_G.DeathTimer = 0
_G.DeathMsg = ""

-- Auto Farm States
_G.AutoFarm = false
_G.HomePos = nil
_G.CurrentSize = "Minor"
_G.GatherCount = 0
local FARM_WAIT_TIME = 5
local SPAM_DURATION = 0.25 

-- New Global States for Bite Customization
_G.BiteRange = 25
_G.BiteInterval = 0 
local lastBiteTime = 0

local Config = {
    rangeQueen = 25,
    rangePlayer = 25,
    biteAnims = {["11157251132"] = true, ["11157253523"] = true},
    stingId = "11157256255",
    stingEndWindow = 0.35, 
    digForwardDist = 5,
    digInterval = 0.01,
    sizeLimits = {
        ["Minor"] = 6,
        ["Major"] = 6,
        ["Supermajor"] = 6
    },
    teamColors = {
        ["Leaf Kingdom"] = Color3.fromRGB(0, 255, 0),
        ["Fire Nation"] = Color3.fromRGB(255, 165, 0),
        ["Golden Empire"] = Color3.fromRGB(255, 255, 0),
        ["Concrete Clan"] = Color3.fromRGB(200, 200, 200)
    },
    detectionRadius = 150
}

local lastDigTime = 0
local TargetGui, T_Name, T_HP, DigFrame, DigTitle, DigStatus
local MonitorFrame, MonitorLabel 

----------------------------------------------------------------
-- 1. SETUP HUD
----------------------------------------------------------------
local function SetupHUDs()
    local playerGui = LP:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("AntWarVisuals") then playerGui.AntWarVisuals:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AntWarVisuals"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 10 
    ScreenGui.Parent = playerGui

    -- Target HUD
    TargetGui = Instance.new("BillboardGui", ScreenGui)
    TargetGui.Name = "TargetOverhead"; TargetGui.Size = UDim2.new(0, 200, 0, 50)
    TargetGui.StudsOffset = Vector3.new(0, 4, 0); TargetGui.AlwaysOnTop = true; TargetGui.Enabled = false
    local TFrame = Instance.new("Frame", TargetGui)
    TFrame.Size = UDim2.new(1, 0, 1, 0); TFrame.BackgroundTransparency = 1
    T_Name = Instance.new("TextLabel", TFrame)
    T_Name.Size = UDim2.new(1, 0, 0.4, 0); T_Name.BackgroundTransparency = 1; T_Name.TextColor3 = Color3.new(1, 1, 1); T_Name.Font = "GothamBold"; T_Name.TextSize = 14
    T_HP = Instance.new("TextLabel", TFrame)
    T_HP.Size = UDim2.new(1, 0, 0.6, 0); T_HP.Position = UDim2.new(0, 0, 0.4, 0); T_HP.BackgroundTransparency = 1; T_HP.Font = "GothamBold"; T_HP.TextSize = 18

    -- Dig HUD
    DigFrame = Instance.new("Frame", ScreenGui)
    DigFrame.Size = UDim2.new(0, 220, 0, 70); DigFrame.Position = UDim2.new(1, -240, 1, -110)
    DigFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); DigFrame.Visible = false; Instance.new("UICorner", DigFrame)
    DigTitle = Instance.new("TextLabel", DigFrame)
    DigTitle.Size = UDim2.new(1, -20, 0, 25); DigTitle.Position = UDim2.new(0, 10, 0, 8); DigTitle.BackgroundTransparency = 1; DigTitle.TextColor3 = Color3.new(1, 1, 1); DigTitle.Font = "GothamBold"; DigTitle.Text = "⛏️ DIG STATUS"
    DigStatus = Instance.new("TextLabel", DigFrame)
    DigStatus.Size = UDim2.new(1, -20, 0, 30); DigStatus.Position = UDim2.new(0, 10, 0, 33); DigStatus.BackgroundTransparency = 1; DigStatus.TextColor3 = Color3.fromRGB(0, 255, 150); DigStatus.Font = "GothamBold"; DigStatus.Text = "Active"

    -- Monitor Frame 
    MonitorFrame = Instance.new("Frame", ScreenGui)
    MonitorFrame.Size = UDim2.new(0, 280, 0, 90)
    MonitorFrame.Position = UDim2.new(0, 15, 0.4, 0)
    MonitorFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MonitorFrame.BackgroundTransparency = 0.4
    MonitorFrame.Visible = false 
    Instance.new("UICorner", MonitorFrame)
    local stroke = Instance.new("UIStroke", MonitorFrame); stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Thickness = 1; stroke.Transparency = 0.8
    
    MonitorLabel = Instance.new("TextLabel", MonitorFrame)
    MonitorLabel.Size = UDim2.new(1, -20, 1, -10); MonitorLabel.Position = UDim2.new(0, 10, 0, 5); MonitorLabel.BackgroundTransparency = 1; MonitorLabel.TextColor3 = Color3.new(1, 1, 1)
    MonitorLabel.Font = "GothamBold"; MonitorLabel.TextSize = 13; MonitorLabel.TextXAlignment = "Left"; MonitorLabel.RichText = true; MonitorLabel.Text = ""
end

SetupHUDs()
LP.CharacterAdded:Connect(function() task.wait(0.5) allyHealthCache = {} end)
----------------------------------------------------------------
-- 2. MONITOR LOGIC (NEW)
----------------------------------------------------------------
local function isMyTeamQueen(model)
    if not model:IsA("Model") or model.Name ~= "Queen" then return false end
    local teamName = LP.Team and LP.Team.Name or ""
    if model.Parent and (model.Parent.Name == teamName or model.Parent.Name:find(teamName)) then return true end
    return false
end

local function UpdateMonitor()
    if not _G.MonitorEnabled or not MonitorFrame then 
        if MonitorFrame then MonitorFrame.Visible = false end 
        return 
    end
    MonitorFrame.Visible = true
    local displayText = "<b><font color='rgb(200,200,200)'>[ MONITOR V2 ]</font></b>\n"
    
    local myQueen = nil
    for _, obj in pairs(workspace:GetDescendants()) do if isMyTeamQueen(obj) then myQueen = obj break end end

    if myQueen then
        local qH = myQueen:FindFirstChildOfClass("Humanoid")
        local qR = myQueen.PrimaryPart or myQueen:FindFirstChild("HumanoidRootPart")
        if qH then
            local p = math.floor((qH.Health/qH.MaxHealth)*100)
            if qH.Health < lastQueenHealth then _G.QueenAttackTimer = 3 end
            lastQueenHealth = qH.Health
            
            local color = p > 50 and "0,255,0" or (p > 25 and "255,255,0" or "255,0,0")
            displayText = displayText .. "👑 Queen HP: <font color='rgb("..color..")'>" .. p .. "%</font>\n"
            
            if _G.QueenAttackTimer > 0 then
                displayText = displayText .. "⚠️ <font color='rgb(255,0,0)'>QUEEN UNDER ATTACK!</font>\n"
                _G.QueenAttackTimer = _G.QueenAttackTimer - 0.02
            end
        end
        if qR then
            local e = 0
            for _, p in pairs(Players:GetPlayers()) do
                if p.Team ~= LP.Team and p.Character and p.Character.PrimaryPart then
                    if (p.Character.PrimaryPart.Position - qR.Position).Magnitude <= Config.detectionRadius then e = e + 1 end
                end
            end
            if e > 0 then displayText = displayText .. "❗ Enemies near Queen:  <font color='rgb(255,150,0)'>" .. e .. "</font>\n" end
        end
    end

    local allyTakingDmg = false
    for _, p in pairs(Players:GetPlayers()) do
        if p.Team == LP.Team and p ~= LP and p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then 
                if h.Health <= 0 and (not allyHealthCache[p.UserId] or allyHealthCache[p.UserId] > 0) then
                    _G.DeathMsg = p.DisplayName .. (math.random(1,2) == 1 and " Got Bite to death " or " Has ben killed!")
                    _G.DeathTimer = 3
                elseif allyHealthCache[p.UserId] and h.Health < allyHealthCache[p.UserId] and h.Health > 0 then 
                    allyTakingDmg = true 
                end 
                allyHealthCache[p.UserId] = h.Health 
            end
        end
    end

    if allyTakingDmg then allyAlertTimer = 3 end
    if allyAlertTimer > 0 then
        displayText = displayText .. "🛡️ <font color='rgb(0,170,255)'>Ally taking damage!</font>\n"
        allyAlertTimer = allyAlertTimer - 0.02
    end
    if _G.DeathTimer > 0 then
        displayText = displayText .. "💀 " .. _G.DeathMsg .. "\n"
        _G.DeathTimer = _G.DeathTimer - 0.02
    end
    MonitorLabel.Text = displayText
end

----------------------------------------------------------------
-- 3. ESP & FARM
----------------------------------------------------------------
local function CleanESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local h = player.Character:FindFirstChild("TeamESP")
            local b = player.Character:FindFirstChild("FloatingBox")
            if h then h:Destroy() end
            if b then b:Destroy() end
        end
    end
end

local function UpdateESP()
    if not _G.ESPEnabled then CleanESP() return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Team ~= LP.Team and player.Character then
            local char = player.Character
            local teamColor = Config.teamColors[player.Team.Name] or Color3.new(1, 1, 1)
            local highlight = char:FindFirstChild("TeamESP") or Instance.new("Highlight", char)
            highlight.Name = "TeamESP"; highlight.OutlineColor = teamColor; highlight.FillTransparency = 1
            local box = char:FindFirstChild("FloatingBox") or Instance.new("BoxHandleAdornment", char)
            box.Name = "FloatingBox"; box.Size = Vector3.new(1.8, 1.8, 1.8); box.AlwaysOnTop = true; box.ZIndex = 10; box.Transparency = 0.4
            box.Adornee = char:FindFirstChild("HumanoidRootPart"); box.CFrame = CFrame.new(0, 5, 0); box.Color3 = teamColor
        end
    end
end

local function updateCurrentSize()
    local char = LP.Character
    if char then for s, _ in pairs(Config.sizeLimits) do if string.find(char.Name, s) then _G.CurrentSize = s return end end end
end

local function teleportAndSpamGather(targetLarvae, targetCFrame, duration)
    local character = LP.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local startTime = tick()
        while tick() - startTime < duration do
            if not _G.AutoFarm then break end
            character.HumanoidRootPart.CFrame = targetCFrame
            LarvaeEvent:FireServer("Gather", targetLarvae)
            RunService.RenderStepped:Wait()
        end
    end
end

local function isPlayerNearby(larvae)
    local larvaePos = larvae:IsA("Model") and larvae:GetModelCFrame().Position or larvae.Position
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (player.Character.HumanoidRootPart.Position - larvaePos).Magnitude
            if dist <= 5 then return true end
        end
    end
    return false
end

local function runFarmCycle()
    if not _G.HomePos then
        Rayfield:Notify({Title = "Error", Content = "Please Save Home Position first!", Duration = 5})
        _G.AutoFarm = false
        return
    end
    updateCurrentSize()
    local allLarvae = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Larvae" and (v:IsA("BasePart") or v:IsA("Model")) and not v:IsDescendantOf(LP.Character) then table.insert(allLarvae, v) end
    end
    if #allLarvae == 0 then
        local character = LP.Character
        if character and character:FindFirstChild("HumanoidRootPart") then character.HumanoidRootPart.CFrame = _G.HomePos end
        return
    end
    for i, larvae in ipairs(allLarvae) do
        if not _G.AutoFarm then break end
        if larvae.Parent and not isPlayerNearby(larvae) then
            local targetCFrame = larvae:IsA("Model") and larvae:GetModelCFrame() or larvae.CFrame
            teleportAndSpamGather(larvae, targetCFrame, SPAM_DURATION)
            _G.GatherCount = _G.GatherCount + 1
            if _G.GatherCount >= Config.sizeLimits[_G.CurrentSize] then
                local character = LP.Character
                if character and character:FindFirstChild("HumanoidRootPart") then character.HumanoidRootPart.CFrame = _G.HomePos end
                task.wait(8)
                _G.GatherCount = 0
                updateCurrentSize()
            end
        end
    end
end

----------------------------------------------------------------
-- 4. TARGETING
----------------------------------------------------------------
local function GetAuraTarget(hrp)
    local bestTarget = nil
    local minDistance = _G.BiteRange
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Team ~= LP.Team and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDistance and p.Character.Humanoid.Health > 0 then minDistance = dist bestTarget = {hum = p.Character.Humanoid, part = p.Character.HumanoidRootPart, name = p.Name, char = p.Character} end
        end
    end
    if not bestTarget then
        pcall(function()
            local chambers = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Chambers")
            if chambers then
                for _, chamber in ipairs(chambers:GetChildren()) do
                    if LP.Team and chamber.Name ~= LP.Team.Name then
                        local queen = chamber:FindFirstChild("Queen")
                        if queen and queen:FindFirstChild("Humanoid") and queen:FindFirstChild("HumanoidRootPart") then
                            local qDist = (hrp.Position - queen.HumanoidRootPart.Position).Magnitude
                            if qDist < _G.BiteRange and queen.Humanoid.Health > 0 then bestTarget = {hum = queen.Humanoid, part = queen.HumanoidRootPart, name = "Queen " .. chamber.Name, char = queen} end
                        end
                    end
                end
            end
        end)
    end
    return bestTarget
end

----------------------------------------------------------------
-- 5. MAIN LOOP
----------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    local hum = char.Humanoid
    local hrp = char.HumanoidRootPart

    UpdateESP()
    UpdateMonitor() -- Loop Monitor GUI

    if _G.SpeedBypassEnabled then if hum.WalkSpeed ~= _G.TargetWalkSpeed then hum.WalkSpeed = _G.TargetWalkSpeed end end

    local isBitingAnim = false
    local blockBiteForSting = false
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        local id = track.Animation.AnimationId:match("%d+")
        if Config.biteAnims[id] then isBitingAnim = true end
        if id == Config.stingId then local timeLeft = track.Length - track.TimePosition if timeLeft > Config.stingEndWindow then blockBiteForSting = true end end
    end

    if _G.AuraEnabled and isBitingAnim and not blockBiteForSting then
        if tick() - lastBiteTime >= _G.BiteInterval then
            local target = GetAuraTarget(hrp)
            if target then
                if _G.ShowHUD then
                    TargetGui.Adornee = target.char:FindFirstChild("Head") or target.part
                    TargetGui.Enabled = true
                    T_Name.Text = "🎯 " .. target.name
                    T_HP.Text = string.format("%.1f / %.1f HP", target.hum.Health, target.hum.MaxHealth)
                    local pct = (target.hum.Health / target.hum.MaxHealth)
                    T_HP.TextColor3 = pct > 0.3 and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
                end
                BiteEvent:FireServer("Bite", target.hum, target.part)
                lastBiteTime = tick()
            else TargetGui.Enabled = false end
        end
    else TargetGui.Enabled = false end

    if _G.DigAuraEnabled then
        if _G.ShowHUD and DigFrame then DigFrame.Visible = true end
        local currentTime = tick()
        if currentTime - lastDigTime >= Config.digInterval then
            local targetPos = hrp.Position + (hrp.CFrame.LookVector * Config.digForwardDist)
            pcall(function() DigEvent:FireServer(Vector3.new(targetPos.X, targetPos.Y - 1, targetPos.Z)) end)
            lastDigTime = currentTime
        end
    else if DigFrame then DigFrame.Visible = false end end
end)

----------------------------------------------------------------
-- 6. UI RAYFIELD
----------------------------------------------------------------
local Window = Rayfield:CreateWindow({ 
    Name = "Ant War", 
    LoadingTitle = "", 
    LoadingSubtitle = "", 
    ConfigurationSaving = { Enabled = true, FolderName = "AntWarConfigs", FileName = "Main" }, 
    KeySystem = false 
})

local MainTab = Window:CreateTab("Auras")
local FarmTab = Window:CreateTab("Farm")
local MovementTab = Window:CreateTab("Movement") 
local VisualTab = Window:CreateTab("Visuals") 

-- Main Tab
MainTab:CreateLabel("Bite aura work when you biting(animation detection)")
MainTab:CreateToggle({ Name = "Toggle Bite Aura", CurrentValue = true, Flag = "AuraToggle", Callback = function(Value) _G.AuraEnabled = Value end })
MainTab:CreateSection("Bite Settings")
MainTab:CreateInput({ Name = "Bite Range", PlaceholderText =_G.BiteRange , Callback = function(Text) _G.BiteRange = tonumber(Text) or 25 end })
MainTab:CreateInput({ Name = "Bite Speed (Interval)", PlaceholderText =_G.BiteInterval , Callback = function(Text) _G.BiteInterval = tonumber(Text) or 0 end })
MainTab:CreateSection("Dig Settings")
MainTab:CreateToggle({ Name = "Toggle Dig Aura", CurrentValue = false, Flag = "DigToggle", Callback = function(Value) _G.DigAuraEnabled = Value end })

-- Farm Tab
FarmTab:CreateLabel("NOTE: Save Home Position before turning on Auto Farm!")
FarmTab:CreateButton({ Name = "Save Current Position as Home", Callback = function() local char = LP.Character if char and char:FindFirstChild("HumanoidRootPart") then _G.HomePos = char.HumanoidRootPart.CFrame Rayfield:Notify({Title = "Success", Content = "Home Position Saved!", Duration = 3}) end end })
FarmTab:CreateToggle({ Name = "Auto Collect Larvae", CurrentValue = false, Flag = "AutoFarmFlag", Callback = function(Value) _G.AutoFarm = Value if Value then task.spawn(function() while _G.AutoFarm do pcall(runFarmCycle) task.wait(FARM_WAIT_TIME) end end) end end })

-- Movement Tab
MovementTab:CreateSection("WalkSpeed Bypass")
MovementTab:CreateToggle({ Name = "Enable Speed Bypass", CurrentValue = false, Flag = "BypassToggle", Callback = function(Value) _G.SpeedBypassEnabled = Value end })
MovementTab:CreateSlider({ Name = "Walk Speed Amount", Range = {16, 40}, Increment = 1, Suffix = " Speed", CurrentValue = 16, Flag = "SpeedSlider", Callback = function(Value) _G.TargetWalkSpeed = Value end })

-- Visual Tab
VisualTab:CreateSection("ESP Settings")
VisualTab:CreateToggle({ Name = "Toggle Other Team ESP", CurrentValue = true, Flag = "ESPToggle", Callback = function(Value) _G.ESPEnabled = Value end })
VisualTab:CreateButton({ Name = "Fix & Refresh ESP", Callback = function() CleanESP() end })
VisualTab:CreateSection("HUD Settings")
VisualTab:CreateToggle({ Name = "Show Target Enemy HUD Display", CurrentValue = true, Flag = "HUDToggle", Callback = function(Value) _G.ShowHUD = Value end })

-- NEW: Monitor Queen Section inside Visuals
VisualTab:CreateSection("Queen & Team Monitor")
VisualTab:CreateToggle({
    Name = "Monitor queen and ally[Final]",
    CurrentValue = false,
    Flag = "MonitorToggle",
    Callback = function(Value)
      _G.MonitorEnabled = Value
    end
})
