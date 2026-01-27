-- ⚠️ WARNING: DO NOT EDIT | Owner: 6day13
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")

-- Load WindUI Library
local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        if RunService:IsStudio() then
            WindUI = require(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init"))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- Colors
local Green = Color3.fromHex("#10C550")
local Red = Color3.fromHex("#EF4F1D")
local Cyan = Color3.fromHex("#30FF6A")
local Purple = Color3.fromHex("#7775F2")
local Grey = Color3.fromHex("#83889E")

-- ===== SETUP ESP =====
connections = connections or {}
mainConns = mainConns or {}
unloaded = false
local useAbilityRF = nil
pcall(function()
    useAbilityRF = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunctions"):WaitForChild("UseAbility")
end)

local Storage = CoreGui:FindFirstChild("Highlight_Storage") or Instance.new("Folder")
Storage.Name = "Highlight_Storage"
Storage.Parent = CoreGui

local espConfigs = {
    Survivor = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,0), OutlineColor=Color3.fromRGB(0,255,0), FillTransparency=0.5, OutlineTransparency=0},
    Killer   = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(255,0,0), OutlineColor=Color3.fromRGB(255,0,0), FillTransparency=0.5, OutlineTransparency=0},
    Ghost    = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,255), OutlineColor=Color3.fromRGB(0,255,255), FillTransparency=0.5, OutlineTransparency=0},
}

local DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
local TextStrokeColor = Color3.fromRGB(0,0,0)

-- ===== CREATE WINDUI WINDOW =====
local Window = WindUI:CreateWindow({
    Title = "NoHub | DbD Exploit",
    Folder = "nohub_dbd",
    Icon = "solar:folder-2-bold-duotone",
    HideSearchBar = false,
    OpenButton = {
        Title = "Open NoHub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.6,
        Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f"))
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

-- Credits tag (sesuai permintaan user)
Window:Tag({
    Title = "NoHub - Noctyra",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

-- ===== ESP FUNCTIONS (100% SAMA DENGAN ASLI) =====
local function createLabel(name,parent,posY)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,0,0.5,0)
    label.Position = UDim2.new(0,0,posY,0)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.TextStrokeColor3 = TextStrokeColor
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.fromRGB(255,255,255)
    return label
end

local function setupHealthDisplay(plr, humanoid, healthLabel)
    local function update()
        local char = plr.Character
        if not char then return end
        local team = char.Parent and char.Parent.Name
        local cfg = team and espConfigs[team]
        if cfg and cfg.HP and cfg.Enabled then
            healthLabel.Visible = true
            healthLabel.Text = ("HP: %d/%d"):format(math.floor(humanoid.Health), humanoid.MaxHealth)
        else
            healthLabel.Visible = false
        end
    end
    update()
    connections[plr] = connections[plr] or {}
    if connections[plr].HealthChanged then pcall(function() connections[plr].HealthChanged:Disconnect() end) end
    connections[plr].HealthChanged = humanoid.HealthChanged:Connect(update)
end

local function updateESPConfig(plr)
    if not plr or not plr.Character then return end
    local char = plr.Character
    local highlight = Storage:FindFirstChild(plr.Name.."_Highlight")
    local nametag = Storage:FindFirstChild(plr.Name.."_Nametag")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local team = char.Parent and char.Parent.Name
    local cfg = espConfigs[team]
    if not cfg or not humanoid then return end
    
    if highlight then
        highlight.Enabled = cfg.Enabled
        highlight.FillColor = cfg.FillColor
        highlight.OutlineColor = cfg.OutlineColor
        highlight.FillTransparency = (cfg.Fill and cfg.FillTransparency) or 1
        highlight.OutlineTransparency = (cfg.Outline and cfg.OutlineTransparency) or 1
    end
    
    if nametag then
        local nameLabel = nametag:FindFirstChild("PlayerName")
        local healthLabel = nametag:FindFirstChild("HealthLabel")
        if nameLabel then
            nameLabel.Visible = cfg.Enabled and cfg.Name
            nameLabel.TextColor3 = cfg.FillColor
            nameLabel.Text = plr.Name
        end
        if healthLabel then
            healthLabel.Visible = cfg.Enabled and cfg.HP
        end
    end
end

local function cleanupESP(plr)
    for _, suffix in ipairs({"_Highlight","_Nametag"}) do
        local obj = Storage:FindFirstChild(plr.Name..suffix)
        if obj then pcall(function() obj:Destroy() end) end
    end
    if connections[plr] and connections[plr].HealthChanged then
        pcall(function() connections[plr].HealthChanged:Disconnect() end)
        connections[plr].HealthChanged = nil
    end
end

local function createOrUpdateESP(plr, char)
    if not char or not char.Parent or plr == lp or unloaded then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local team = char.Parent and char.Parent.Name
    local cfg = espConfigs[team]
    if not cfg or not humanoid then return end
    
    cleanupESP(plr)
    
    local highlight = Instance.new("Highlight")
    highlight.Name = plr.Name.."_Highlight"
    highlight.DepthMode = DepthMode
    highlight.Adornee = char
    highlight.Parent = Storage
    
    if not hrp then return end
    
    local nametag = Instance.new("BillboardGui")
    nametag.Name = plr.Name.."_Nametag"
    nametag.Size = UDim2.new(0,120,0,40)
    nametag.StudsOffset = Vector3.new(0,2.5,0)
    nametag.AlwaysOnTop = true
    nametag.Adornee = hrp
    nametag.Parent = Storage
    
    local nameLabel = createLabel("PlayerName", nametag, 0)
    nameLabel.Text = plr.Name
    local healthLabel = createLabel("HealthLabel", nametag, 0.5)
    
    updateESPConfig(plr)
    setupHealthDisplay(plr, humanoid, healthLabel)
    
    connections[plr].Died = humanoid.Died:Connect(function() cleanupESP(plr) end)
    connections[plr].CharacterRemoving = plr.CharacterRemoving:Connect(function() cleanupESP(plr) end)
end

local function onPlayerAdded(plr)
    if plr == lp then return end
    connections[plr] = connections[plr] or {}
    connections[plr].CharacterAdded = plr.CharacterAdded:Connect(function(char)
        task.wait(2.5)
        createOrUpdateESP(plr, char)
    end)
    if plr.Character then createOrUpdateESP(plr, plr.Character) end
end

local function onPlayerRemoving(plr)
    cleanupESP(plr)
    if connections[plr] then
        for _, conn in pairs(connections[plr]) do
            if typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
        end
        connections[plr] = nil
    end
end

mainConns.playersAdded = Players.PlayerAdded:Connect(onPlayerAdded)
mainConns.playersRemoving = Players.PlayerRemoving:Connect(onPlayerRemoving)
for _,v in ipairs(Players:GetPlayers()) do onPlayerAdded(v) end

local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then updateESPConfig(plr) end
    end
end

-- ===== CREATE ESP TABS (Wind UI) =====
for teamName, cfg in pairs(espConfigs) do
    local tab = Window:Tab({
        Title = teamName .. " ESP",
        Icon = teamName == "Survivor" and "solar:check-square-bold" or (teamName == "Killer" and "solar:cursor-square-bold" or "solar:password-minimalistic-input-bold"),
        IconColor = teamName == "Survivor" and Green or (teamName == "Killer" and Red or Cyan),
        Border = true,
    })
    
    tab:Toggle({
        Flag = "esp_"..teamName:lower().."_enabled",
        Title = "Enable ESP",
        Value = cfg.Enabled,
        Callback = function(v)
            cfg.Enabled = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Flag = "esp_"..teamName:lower().."_name",
        Title = "Show Name",
        Value = cfg.Name,
        Callback = function(v)
            cfg.Name = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Flag = "esp_"..teamName:lower().."_hp",
        Title = "Show HP",
        Value = cfg.HP,
        Callback = function(v)
            cfg.HP = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Flag = "esp_"..teamName:lower().."_fill",
        Title = "Show Fill",
        Value = cfg.Fill,
        Callback = function(v)
            cfg.Fill = v
            updateAllESP()
        end
    })
    
    tab:Colorpicker({
        Flag = "esp_"..teamName:lower().."_fillcolor",
        Title = "Fill Color",
        Default = cfg.FillColor,
        Callback = function(c)
            cfg.FillColor = c
            updateAllESP()
        end
    })
    
    tab:Slider({
        Flag = "esp_"..teamName:lower().."_filltransparency",
        Title = "Fill Transparency",
        Step = 0.05,
        Value = {
            Min = 0,
            Max = 1,
            Default = cfg.FillTransparency,
        },
        Callback = function(v)
            cfg.FillTransparency = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Flag = "esp_"..teamName:lower().."_outline",
        Title = "Show Outline",
        Value = cfg.Outline,
        Callback = function(v)
            cfg.Outline = v
            updateAllESP()
        end
    })
    
    tab:Colorpicker({
        Flag = "esp_"..teamName:lower().."_outlinecolor",
        Title = "Outline Color",
        Default = cfg.OutlineColor,
        Callback = function(c)
            cfg.OutlineColor = c
            updateAllESP()
        end
    })
    
    tab:Slider({
        Flag = "esp_"..teamName:lower().."_outlinetransparency",
        Title = "Outline Transparency",
        Step = 0.05,
        Value = {
            Min = 0,
            Max = 1,
            Default = cfg.OutlineTransparency,
        },
        Callback = function(v)
            cfg.OutlineTransparency = v
            updateAllESP()
        end
    })
end

-- ===== SPEED SETTINGS =====
local character = lp.Character or lp.CharacterAdded:Wait()
if character:GetAttribute("WalkSpeed") == nil then character:SetAttribute("WalkSpeed", 10) end
if character:GetAttribute("SprintSpeed") == nil then character:SetAttribute("SprintSpeed", 27) end

local walkSpeedValue = character:GetAttribute("WalkSpeed") or 10
local sprintSpeedValue = character:GetAttribute("SprintSpeed") or 27
local walkSpeedEnabled = false
local sprintEnabled = false
local speedConnection = nil

local function updateSpeeds()
    if unloaded or not character then return end
    local currentWS = character:GetAttribute("WalkSpeed") or 10
    local currentSS = character:GetAttribute("SprintSpeed") or 27
    if walkSpeedEnabled and currentWS ~= walkSpeedValue then character:SetAttribute("WalkSpeed", walkSpeedValue) end
    if sprintEnabled and currentSS ~= sprintSpeedValue then character:SetAttribute("SprintSpeed", sprintSpeedValue) end
end

local function startSpeedLoop()
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = RunService.Heartbeat:Connect(updateSpeeds)
end

local function stopSpeedLoop()
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
end

local tabSpeed = Window:Tab({
    Title = "Speed Settings",
    Icon = "solar:square-transfer-horizontal-bold",
    IconColor = Purple,
    Border = true,
})

tabSpeed:Slider({
    Flag = "walkspeed_value",
    Title = "WalkSpeed",
    Step = 1,
    Value = {
        Min = 8,
        Max = 200,
        Default = walkSpeedValue,
    },
    Callback = function(val)
        walkSpeedValue = val
        if walkSpeedEnabled then updateSpeeds() end
    end
})

tabSpeed:Toggle({
    Flag = "walkspeed_enabled",
    Title = "Enable WalkSpeed",
    Value = walkSpeedEnabled,
    Callback = function(v)
        walkSpeedEnabled = v
        if v then
            startSpeedLoop()
            updateSpeeds()
        else
            if character then character:SetAttribute("WalkSpeed", 10) end
            stopSpeedLoop()
        end
    end
})

tabSpeed:Slider({
    Flag = "sprintspeed_value",
    Title = "SprintSpeed",
    Step = 1,
    Value = {
        Min = 16,
        Max = 300,
        Default = sprintSpeedValue,
    },
    Callback = function(val)
        sprintSpeedValue = val
        if sprintEnabled then updateSpeeds() end
    end
})

tabSpeed:Toggle({
    Flag = "sprint_enabled",
    Title = "Enable Sprint",
    Value = sprintEnabled,
    Callback = function(v)
        sprintEnabled = v
        if v then
            startSpeedLoop()
            updateSpeeds()
        else
            if character then character:SetAttribute("SprintSpeed", 27) end
            stopSpeedLoop()
        end
    end
})

mainConns.charAdded_speed = lp.CharacterAdded:Connect(function(char)
    character = char
    task.wait(0.5)
    if character:GetAttribute("WalkSpeed") == nil then character:SetAttribute("WalkSpeed", walkSpeedValue) end
    if character:GetAttribute("SprintSpeed") == nil then character:SetAttribute("SprintSpeed", sprintSpeedValue) end
    if walkSpeedEnabled or sprintEnabled then startSpeedLoop() end
end)

-- ===== AUTOBLOCK =====
local BLOCK_DISTANCE = 15
local watcherEnabled = true
local Logged = {}
local UseAbility = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunctions"):WaitForChild("UseAbility")

-- Badware state tracker
local badwareState = { active = false, startTime = 0, lastWS = nil }

local KillerConfigs = {
    ["Pursuer"] = { enabled = true, check = function(_, ws) local v={4,6,7,8,10,12,14,16,20} for _,x in ipairs(v) do if ws==x then return true end end return false end },
    ["Artful"] = { enabled = true, check = function(_, ws) local v={4,7,8,12,16,20,9,13,17,21} for _,x in ipairs(v) do if ws==x then return true end end return false end },
    ["Harken"] = { enabled = true, check = function(pf, ws) local e=pf:GetAttribute("Enraged") local s=e and {7.5,10,5,13.5,17.5,21.5,25.5} or {4,8,12,16,20} if pf:GetAttribute("AgitationCooldown") then return true end for _,x in ipairs(s) do if ws==x then return true end end return false end },
    ["Badware"] = { enabled = true, check = function(_, ws)
        local v={4,8,12,16,20} local f=function(x) for _,y in ipairs(v) do if x==y then return true end end return false end
        local n=tick()
        if f(ws) then
            if not badwareState.active then badwareState.startTime=n; badwareState.active=true; badwareState.lastWS=ws; return false end
            badwareState.lastWS=ws; return false
        else
            if badwareState.active then
                local d=n-badwareState.startTime
                badwareState.active=false; badwareState.lastWS=nil; badwareState.startTime=nil
                return d<0.3
            end
        end
        return false
    end },
    ["Killdroid"] = { enabled = true, check = function(_, ws) local v={-4,0,4,12,16,20} for _,x in ipairs(v) do if ws==x then return true end end return false end }
}

local function sendBlock() UseAbility:InvokeServer("Block") end
local function getWalkSpeedModifier(k) return k:GetAttribute("WalkSpeedModifier") or 0 end
local function getDistanceFromPlayer(k)
    if k:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        return (k.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
    end
    return math.huge
end

local function checkAndBlock(killer)
    if not watcherEnabled or not killer then return end
    local ws = getWalkSpeedModifier(killer)
    local name = killer:GetAttribute("KillerName")
    if not name then return end
    local config = KillerConfigs[name]
    if not config or not config.enabled then return end
    if getDistanceFromPlayer(killer) > BLOCK_DISTANCE then return end
    if config.check(killer, ws) then
        sendBlock()
        Logged[killer] = Logged[killer] or {}
        if not Logged[killer][ws] then
            print("[AutoBlock] "..name.." ("..killer.Name..") WalkSpeedModifier = "..ws.." -> blocked")
            Logged[killer][ws] = true
            task.delay(3, function() Logged[killer][ws] = nil end)
        end
    end
end

local function monitorKiller(killer)
    if not killer then return end
    checkAndBlock(killer)
    if not killer:GetAttribute("__AB_CONNECTED") then
        killer:SetAttribute("__AB_CONNECTED", true)
        killer.AttributeChanged:Connect(function(attr)
            if attr == "WalkSpeedModifier" or attr == "KillerName" or attr == "Enraged" then
                checkAndBlock(killer)
            end
        end)
    end
end

local killersFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")
for _, killer in pairs(killersFolder:GetChildren()) do monitorKiller(killer) end
killersFolder.ChildAdded:Connect(monitorKiller)

-- Cooldown GUI (draggable untuk mobile)
local CooldownGUI = Instance.new("ScreenGui")
CooldownGUI.Name = "AutoBlockCooldown"
CooldownGUI.ResetOnSpawn = false
CooldownGUI.Parent = lp:WaitForChild("PlayerGui")

local CooldownFrame = Instance.new("Frame")
CooldownFrame.Size = UDim2.new(0,65,0,25)
CooldownFrame.Position = UDim2.new(1,-5,0,-50)
CooldownFrame.AnchorPoint = Vector2.new(1,0)
CooldownFrame.BackgroundTransparency = 1
CooldownFrame.Parent = CooldownGUI

local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Size = UDim2.new(1,0,1,0)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.TextColor3 = Color3.fromRGB(0,255,0)
cooldownLabel.Font = Enum.Font.SourceSansBold
cooldownLabel.TextScaled = true
cooldownLabel.Text = "Ready"
cooldownLabel.Parent = CooldownFrame

-- Drag support untuk mobile
local dragging, dragStart, startPos
CooldownFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = CooldownFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

CooldownFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        CooldownFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragStart then
        local delta = input.Position - dragStart
        CooldownFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- AutoBlock Tab
local tabAutoBlock = Window:Tab({
    Title = "AutoBlock",
    Icon = "solar:check-square-bold",
    IconColor = Red,
    Border = true,
})

local removeAnimEnabled = false
tabAutoBlock:Toggle({
    Flag = "autoblock_remove_anim",
    Title = "Delete Block (Animation)",
    Value = removeAnimEnabled,
    Callback = function(v) removeAnimEnabled = v end
})

task.spawn(function()
    while true do
        task.wait(0.1)
        if removeAnimEnabled and lp.Character then
            local humanoid = lp.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    if track.Animation and tostring(track.Animation.AnimationId):match("134233326423882") then
                        track:Stop()
                    end
                end
            end
        end
    end
end)

local showCooldown = true
tabAutoBlock:Toggle({
    Flag = "autoblock_show_cooldown",
    Title = "Show Cooldown",
    Value = showCooldown,
    Callback = function(v)
        showCooldown = v
        CooldownGUI.Enabled = v
    end
})

for killerName, cfg in pairs(KillerConfigs) do
    tabAutoBlock:Toggle({
        Flag = "autoblock_"..killerName:lower(),
        Title = "Enable "..killerName,
        Value = cfg.enabled,
        Callback = function(val) cfg.enabled = val end
    })
end

tabAutoBlock:Slider({
    Flag = "autoblock_distance",
    Title = "Block Distance",
    Step = 1,
    Value = {
        Min = 5,
        Max = 50,
        Default = BLOCK_DISTANCE,
    },
    Callback = function(val) BLOCK_DISTANCE = val end
})

-- Cooldown loop
RunService.Heartbeat:Connect(function()
    local survivorFolder = Workspace:FindFirstChild("GameAssets") and Workspace.GameAssets:FindFirstChild("Teams") and Workspace.GameAssets.Teams:FindFirstChild("Survivor") and Workspace.GameAssets.Teams.Survivor:FindFirstChild(lp.Name)
    local killersFolderCheck = Workspace:FindFirstChild("GameAssets") and Workspace.GameAssets:FindFirstChild("Teams") and Workspace.GameAssets.Teams:FindFirstChild("Killer")
    if killersFolderCheck and lp.Name then
        local inKiller = killersFolderCheck:FindFirstChild(lp.Name) ~= nil
        watcherEnabled = not inKiller and (survivorFolder ~= nil)
    end
    if survivorFolder then
        local onCD = survivorFolder:GetAttribute("BlockCooldown")
        if onCD then
            cooldownLabel.Text = "On Cooldown"
            cooldownLabel.TextColor3 = Color3.fromRGB(255,0,0)
        else
            cooldownLabel.Text = "Ready"
            cooldownLabel.TextColor3 = Color3.fromRGB(0,255,0)
        end
    end
end)

-- ===== SKILLS & SELECTOR =====
local skillList = {"Revolver","Punch","Block","Caretaker","Hotdog","Taunt","Cloak","Dash","Banana","BonusPad","Adrenaline"}
local selectedSkill1, selectedSkill2 = "Revolver", "Caretaker"

local tabSkills = Window:Tab({
    Title = "Skills & Selector",
    Icon = "solar:hamburger-menu-bold",
    IconColor = Purple,
    Border = true,
})

local skillParagraph = tabSkills:Paragraph({
    Title = "Selected Skills",
    Desc = "Skill 1: "..selectedSkill1.."\nSkill 2: "..selectedSkill2,
})

tabSkills:Dropdown({
    Flag = "skill1_select",
    Title = "Select Skill 1",
    Values = skillList,
    Value = selectedSkill1,
    Callback = function(opt)
        selectedSkill1 = opt
        skillParagraph.Desc = "Skill 1: "..selectedSkill1.."\nSkill 2: "..selectedSkill2
    end
})

tabSkills:Dropdown({
    Flag = "skill2_select",
    Title = "Select Skill 2",
    Values = skillList,
    Value = selectedSkill2,
    Callback = function(opt)
        selectedSkill2 = opt
        skillParagraph.Desc = "Skill 1: "..selectedSkill1.."\nSkill 2: "..selectedSkill2
    end
})

tabSkills:Button({
    Title = "Select Skills",
    Icon = "check",
    Callback = function()
        local abilitySelection = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("AbilitySelection")
        abilitySelection:FireServer({selectedSkill1, selectedSkill2})
    end
})

-- Skill buttons draggable (mobile-friendly)
local SkillsModule = require(ReplicatedStorage.ClientModules:WaitForChild("AbilityConfig"))
local guiStorage = lp:FindFirstChild("SkillScreenGui") or Instance.new("ScreenGui")
guiStorage.Name = "SkillScreenGui"
guiStorage.ResetOnSpawn = false
guiStorage.IgnoreGuiInset = true
guiStorage.Parent = lp:WaitForChild("PlayerGui")
local buttonConfigs = {}
local lastUsed = {}

local function makeDraggable(frame, skillName)
    local dragging, dragStart, startPos = false, Vector2.new(), frame.Position
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    buttonConfigs[skillName] = buttonConfigs[skillName] or {size=46,pos={frame.Position.X.Offset, frame.Position.Y.Offset}}
                    buttonConfigs[skillName].pos = {frame.Position.X.Offset, frame.Position.Y.Offset}
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

local function createSkillButton(skillName)
    local skillData = SkillsModule[skillName]
    if not skillData then return end
    local cfg = buttonConfigs[skillName] or {size=46,pos={100,100}}
    buttonConfigs[skillName] = cfg
    
    local old = guiStorage:FindFirstChild(skillName.."_Btn")
    if old then old:Destroy() end
    
    local btnFrame = Instance.new("Frame")
    btnFrame.Name = skillName.."_Btn"
    btnFrame.Size = UDim2.new(0,cfg.size,0,cfg.size)
    btnFrame.Position = UDim2.new(0,cfg.pos[1],0,cfg.pos[2])
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = guiStorage
    
    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Color = Color3.fromRGB(197,197,197)
    border.Parent = btnFrame
    
    local innerFrame = Instance.new("Frame")
    innerFrame.Size = UDim2.new(1,0,1,0)
    innerFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    innerFrame.BackgroundTransparency = 0.5
    innerFrame.BorderSizePixel = 0
    innerFrame.Parent = btnFrame
    
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0.9,0,0.9,0)
    icon.Position = UDim2.new(0.5,0,0.5,0)
    icon.AnchorPoint = Vector2.new(0.5,0.5)
    icon.BackgroundTransparency = 1
    icon.Image = skillData.Icon or ""
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = innerFrame
    
    local cooldownOverlay = Instance.new("Frame")
    cooldownOverlay.Size = UDim2.new(1,0,1,0)
    cooldownOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    cooldownOverlay.BackgroundTransparency = 0.6
    cooldownOverlay.BorderSizePixel = 0
    cooldownOverlay.Visible = false
    cooldownOverlay.Parent = innerFrame
    
    local cdLabel = Instance.new("TextLabel")
    cdLabel.Size = UDim2.new(1,0,1,0)
    cdLabel.BackgroundTransparency = 1
    cdLabel.TextColor3 = Color3.fromRGB(255,255,255)
    cdLabel.TextScaled = true
    cdLabel.Font = Enum.Font.GothamBold
    cdLabel.Visible = false
    cdLabel.Parent = cooldownOverlay
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,0,1,0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = innerFrame
    
    button.MouseButton1Click:Connect(function()
        local cooldown = tonumber(skillData.Cooldown) or 1
        local now = os.clock()
        if not lastUsed[skillName] or now - lastUsed[skillName] >= cooldown then
            lastUsed[skillName] = now
            local remoteFunc = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteFunctions"):WaitForChild("UseAbility")
            pcall(function() remoteFunc:InvokeServer(skillName) end)
            cooldownOverlay.Visible = true
            cdLabel.Visible = true
            task.spawn(function()
                local t = cooldown
                while t > 0 do
                    cdLabel.Text = tostring(math.ceil(t))
                    task.wait(1)
                    t -= 1
                end
                cooldownOverlay.Visible = false
                cdLabel.Visible = false
            end)
        end
    end)
    
    makeDraggable(btnFrame, skillName)
end

local function removeSkillButton(skillName)
    local old = guiStorage:FindFirstChild(skillName.."_Btn")
    if old then old:Destroy() end
end

for _, skillName in ipairs(skillList) do
    local enabled = false
    tabSkills:Toggle({
        Flag = "skill_"..skillName:lower().."_enabled",
        Title = "Enable "..skillName,
        Value = false,
        Callback = function(v)
            enabled = v
            if v then createSkillButton(skillName) else removeSkillButton(skillName) end
        end
    })
    
    tabSkills:Slider({
        Flag = "skill_"..skillName:lower().."_size",
        Title = skillName.." Size",
        Step = 1,
        Value = {
            Min = 40,
            Max = 120,
            Default = 46,
        },
        Callback = function(val)
            if not buttonConfigs[skillName] then
                buttonConfigs[skillName] = {size=val,pos={100,100}}
            else
                buttonConfigs[skillName].size = val
            end
            if enabled then createSkillButton(skillName) end
        end
    })
end

-- ===== GAMEPLAY SETTINGS =====
local tabGameplay = Window:Tab({
    Title = "Gameplay Settings",
    Icon = "solar:file-text-bold",
    IconColor = Grey,
    Border = true,
})

local lockWSM = true
tabGameplay:Toggle({
    Flag = "lock_wsm",
    Title = "Lock WalkSpeedModifier",
    Value = lockWSM,
    Callback = function(v) lockWSM = v end
})

local keepStaminaEnabled = true
local customStamina = 100
local defaultStamina = ((lp.Character or lp.CharacterAdded:Wait()):GetAttribute("MaxStamina")) or 100

tabGameplay:Toggle({
    Flag = "custom_stamina_enabled",
    Title = "Enable Custom MaxStamina",
    Value = keepStaminaEnabled,
    Callback = function(v)
        keepStaminaEnabled = v
        local ch = lp.Character
        if ch then ch:SetAttribute("MaxStamina", v and customStamina or defaultStamina) end
    end
})

tabGameplay:Input({
    Flag = "custom_stamina_value",
    Title = "Custom MaxStamina (0-999999)",
    Placeholder = "Enter number...",
    Value = tostring(customStamina),
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 and num <= 999999 then
            customStamina = num
            if keepStaminaEnabled and lp.Character then
                lp.Character:SetAttribute("MaxStamina", customStamina)
            end
        else
            WindUI:Notify({Title = "Invalid Value", Content = "Enter number between 0-999999", Icon = "alert-triangle", Duration = 3})
        end
    end
})

mainConns.staminaHB = RunService.Heartbeat:Connect(function()
    if unloaded then return end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if lockWSM then
        for _, obj in pairs({hum,char,lp}) do
            if obj and obj.GetAttributes then
                local attrs = obj:GetAttributes()
                if attrs then
                    for name,val in pairs(attrs) do
                        if typeof(name)=="string" and name:lower():find("walkspeedmodifier") then
                            if val <= 0 then obj:SetAttribute(name, 0) end
                        end
                    end
                end
            end
        end
    end
    
    if keepStaminaEnabled and char then
        if char:GetAttribute("MaxStamina") ~= customStamina then
            char:SetAttribute("MaxStamina", customStamina)
        end
    elseif char then
        if char:GetAttribute("MaxStamina") ~= defaultStamina then
            char:SetAttribute("MaxStamina", defaultStamina)
        end
    end
end)

mainConns.charAdded_gameplay = lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    if keepStaminaEnabled then char:SetAttribute("MaxStamina", customStamina)
    else char:SetAttribute("MaxStamina", defaultStamina) end
    
    if lockWSM then
        for _, obj in pairs({hum,char,lp}) do
            if obj and obj.GetAttributes then
                local attrs = obj:GetAttributes()
                if attrs then
                    for name,val in pairs(attrs) do
                        if typeof(name)=="string" and name:lower():find("walkspeedmodifier") then
                            if val <= 0 then obj:SetAttribute(name, 0) end
                        end
                    end
                end
            end
        end
    end
end)

-- AntiWalls
local AntiWalls = false
tabGameplay:Toggle({
    Flag = "antiwalls_enabled",
    Title = "Anti-Artful Walls",
    Value = AntiWalls,
    Callback = function(v) AntiWalls = v end
})

local function HandleWallPart(part)
    if part and part.Name=="HumanoidRootPart" and part.Anchored==true then
        part.CanCollide = false
        part.CanTouch = false
        part.Transparency = 0.5
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if AntiWalls and Workspace:FindFirstChild("GameAssets") then
            local teams = Workspace.GameAssets:FindFirstChild("Teams")
            if teams and teams:FindFirstChild("Other") then
                for _, desc in pairs(teams.Other:GetDescendants()) do
                    HandleWallPart(desc)
                end
            end
        end
    end
end)

local otherTeamFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Other")
otherTeamFolder.DescendantAdded:Connect(function(desc)
    if AntiWalls then HandleWallPart(desc) end
end)

-- Fast Artful
getgenv().ImplementEnabled = false
local canTrigger = true

local function getKillerFolder()
    local ga = Workspace:FindFirstChild("GameAssets")
    if not ga then return nil end
    local teams = ga:FindFirstChild("Teams")
    if not teams then return nil end
    return teams:FindFirstChild("Killer")
end

local function HoldImpl_isKiller()
    local kf = getKillerFolder()
    if not kf then return false end
    return kf:FindFirstChild(lp.Name) ~= nil
end

local function HoldImpl_holdInAir(duration, offsetY)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hrp.Parent then return end
    local bp = Instance.new("BodyPosition")
    bp.Position = hrp.Position + Vector3.new(0, offsetY, 0)
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 100000
    bp.D = 1000
    bp.Parent = hrp
    task.spawn(function()
        task.wait(duration)
        if bp and bp.Parent then bp:Destroy() end
    end)
end

local function HoldImpl_CheckAttributes()
    if not getgenv().ImplementEnabled then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then return end
    if not HoldImpl_isKiller() then return end
    local killerName = char:GetAttribute("KillerName")
    local implementCooldown = char:GetAttribute("ImplementCooldown")
    if killerName == "Artful" and canTrigger and (implementCooldown == true or (type(implementCooldown) == "number" and implementCooldown > 0)) then
        HoldImpl_holdInAir(2, 2.5)
        canTrigger = false
    end
    if implementCooldown == false or implementCooldown == 0 then canTrigger = true end
end

task.spawn(function()
    while task.wait(1) do
        HoldImpl_CheckAttributes()
        if unloaded then break end
    end
end)

lp.CharacterAdded:Connect(function() canTrigger = true end)

tabGameplay:Toggle({
    Flag = "fast_artful_enabled",
    Title = "Implement Fast Artful",
    Value = getgenv().ImplementEnabled,
    Callback = function(v)
        getgenv().ImplementEnabled = v
        if v then HoldImpl_CheckAttributes() end
    end
})

-- No M1 when Blocking
local noM1Enabled = false
local DETECTION_RANGE = 18
local CHECK_INTERVAL = 0.5
local hideState = false
local blockerList = {}

tabGameplay:Toggle({
    Flag = "no_m1_blocking",
    Title = "No M1 when Blocking (You Killer)",
    Value = noM1Enabled,
    Callback = function(v) noM1Enabled = v end
})

tabGameplay:Slider({
    Flag = "blocking_range",
    Title = "Blocking Detect Range",
    Step = 1,
    Value = {
        Min = 5,
        Max = 30,
        Default = DETECTION_RANGE,
    },
    Callback = function(v) DETECTION_RANGE = v end
})

local survivorFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Survivor")
local killerFolder = Workspace:WaitForChild("GameAssets"):WaitForChild("Teams"):WaitForChild("Killer")
local PlayerGui = lp:WaitForChild("PlayerGui")
local ABILITY_FOLDER = PlayerGui.MainGui.Abilities:WaitForChild("Folder")
local TARGET_NAMES = { Swing = true, Cleave = true, Eject = true }

local function hideButtons()
    if hideState then return end
    hideState = true
    for _, child in ipairs(ABILITY_FOLDER:GetChildren()) do
        if TARGET_NAMES[child.Name] and child:IsA("GuiObject") then
            child.Visible = false
            child.Active = false
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                child.AutoButtonColor = false
            end
        end
    end
end

local function showButtons()
    if not hideState then return end
    hideState = false
    for _, child in ipairs(ABILITY_FOLDER:GetChildren()) do
        if TARGET_NAMES[child.Name] and child:IsA("GuiObject") then
            child.Visible = true
            child.Active = true
            if child:IsA("ImageButton") or child:IsA("TextButton") then
                child.AutoButtonColor = true
            end
        end
    end
end

local function isInRange(target)
    local char = lp.Character
    if not (char and char:FindFirstChild("HumanoidRootPart")) then return false end
    local root = char.HumanoidRootPart
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    return (root.Position - targetRoot.Position).Magnitude <= DETECTION_RANGE
end

local function watchPlayer(playerModel)
    if not playerModel:IsDescendantOf(survivorFolder) then return end
    local name = playerModel.Name
    local function updateBlockState()
        local state = playerModel:GetAttribute("Blocking")
        if state then blockerList[name] = playerModel else blockerList[name] = nil end
    end
    if playerModel:GetAttribute("Blocking") then blockerList[name] = playerModel end
    playerModel.AttributeChanged:Connect(function(attr)
        if attr == "Blocking" then updateBlockState() end
    end)
end

for _, survivor in ipairs(survivorFolder:GetChildren()) do watchPlayer(survivor) end
survivorFolder.ChildAdded:Connect(function(plr) task.wait(0.1) watchPlayer(plr) end)

task.spawn(function()
    while task.wait(CHECK_INTERVAL) do
        if not noM1Enabled then showButtons() continue end
        local isKiller = killerFolder:FindFirstChild(lp.Name)
        if not isKiller then showButtons() continue end
        local shouldHide = false
        for _, model in pairs(blockerList) do
            if model and model:IsDescendantOf(survivorFolder) and isInRange(model) then
                shouldHide = true
                break
            end
        end
        if shouldHide then hideButtons() else showButtons() end
    end
end)

-- ===== SETTINGS TAB =====
local tabSettings = Window:Tab({
    Title = "Settings",
    Icon = "solar:folder-with-files-bold",
    IconColor = Purple,
    Border = true,
})

local instantPPEnabled = true
local proximityPrompts = {}

local function updateProximityPrompts()
    for prompt, _ in pairs(proximityPrompts) do
        if prompt and prompt:IsA("ProximityPrompt") then
            if instantPPEnabled then prompt.HoldDuration = 0
            else prompt.HoldDuration = prompt:GetAttribute("OriginalHoldDuration") or 1 end
        end
    end
end

local function handleProximityPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        if prompt:GetAttribute("OriginalHoldDuration") == nil then
            prompt:SetAttribute("OriginalHoldDuration", prompt.HoldDuration)
        end
        proximityPrompts[prompt] = true
        if instantPPEnabled then prompt.HoldDuration = 0 end
        prompt.AncestryChanged:Connect(function()
            if not prompt:IsDescendantOf(Workspace) then proximityPrompts[prompt] = nil end
        end)
    end
end

local otherFolder = Workspace:WaitForChild("GameAssets", 5) and Workspace.GameAssets:WaitForChild("Teams", 5) and Workspace.GameAssets.Teams:WaitForChild("Other", 5)
if otherFolder then
    for _, obj in pairs(otherFolder:GetDescendants()) do handleProximityPrompt(obj) end
    mainConns.workspaceDescendant = otherFolder.DescendantAdded:Connect(handleProximityPrompt)
else
    warn("[InstantPP] Workspace.GameAssets.Teams.Other not found")
end

tabSettings:Toggle({
    Flag = "instant_pp_enabled",
    Title = "Instant ProximityPrompt",
    Value = instantPPEnabled,
    Callback = function(v)
        instantPPEnabled = v
        updateProximityPrompts()
    end
})

tabSettings:Button({
    Title = "Unload Script",
    Icon = "shredder",
    Color = Red,
    Callback = function()
        if unloaded then return end
        unloaded = true
        if Storage and Storage:IsA("Instance") then pcall(function() Storage:ClearAllChildren() end) end
        for plr,conns in pairs(connections) do
            if conns then
                for _,conn in pairs(conns) do
                    if typeof(conn)=="RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
                end
            end
            connections[plr] = nil
        end
        for k,conn in pairs(mainConns) do
            if conn and typeof(conn)=="RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
            mainConns[k] = nil
        end
        local g = CoreGui:FindFirstChild("Rayfield")
        if g then pcall(function() g:Destroy() end) end
        g = CoreGui:FindFirstChild("WindUI")
        if g then pcall(function() g:Destroy() end) end
        CooldownGUI:Destroy()
        guiStorage:Destroy()
        Window:Destroy()
        warn("[NoHub] Script unloaded successfully.")
    end
})

-- ===== ANIMATION TAB =====
local tabAnimation = Window:Tab({
    Title = "Animation",
    Icon = "solar:password-minimalistic-input-bold",
    IconColor = Cyan,
    Border = true,
})

local selectedAnimation = "Old"
local animationSets = {
    Old = {Adrenaline="77399794134778",AdrenalineEnd="92333601998082",Banana="95775571866935",BlockLand="94027412516651",BlockStart="100651795910153",Caretaker="136588017093606",CloakEnd="0",CloakStart="117841747115136",Dash="82265255195607",DynamiteHold="137091713941325",DynamiteThrow="99551865645121",DynamiteWindup="133960279206605",Hotdog="93503428349113",PadBuild="82160380573308",Punch="135619604085485",Revolver="73034688541555",RevolverReload="74813841922695",Taunt="113732291990231"},
    New = {Adrenaline="77399794134778",AdrenalineEnd="92333601998082",Banana="95775571866935",BlockLand="94027412516651",BlockStart="134233326423882",Caretaker="128767098320893",CloakEnd="120142279051418",CloakStart="133960698072483",Dash="78278813483757",DynamiteHold="137091713941325",DynamiteThrow="99551865645121",DynamiteWindup="133960279206605",Hotdog="78595119178919",PadBuild="79104831518074",Punch="124781750889573",Revolver="74108653904830",RevolverReload="79026181033717",Taunt="113732291990231"}
}

local function getAbilitiesFolder()
    local playerName = lp.Name
    local abilitiesFolder
    local survivorPath = Workspace:FindFirstChild("GameAssets") and Workspace.GameAssets:FindFirstChild("Teams") and Workspace.GameAssets.Teams:FindFirstChild("Survivor") and Workspace.GameAssets.Teams.Survivor:FindFirstChild(playerName)
    if survivorPath and survivorPath:FindFirstChild("Animations") and survivorPath.Animations:FindFirstChild("Abilities") then
        abilitiesFolder = survivorPath.Animations.Abilities
    end
    if not abilitiesFolder then
        local localModel = Workspace:FindFirstChild(playerName)
        if localModel and localModel:GetChildren()[13] and localModel:GetChildren()[13]:FindFirstChild("Abilities") then
            abilitiesFolder = localModel:GetChildren()[13].Abilities
        end
    end
    return abilitiesFolder
end

local function replaceAnimations(animationSet)
    local abilitiesFolder = getAbilitiesFolder()
    if not abilitiesFolder then
        WindUI:Notify({Title = "Error", Content = "Abilities folder not found!", Icon = "alert-triangle", Duration = 3})
        return
    end
    for name, id in pairs(animationSet) do
        local anim = abilitiesFolder:FindFirstChild(name)
        if anim and anim:IsA("Animation") then
            anim.AnimationId = "rbxassetid://" .. id
        end
        task.wait(0.05)
    end
end

tabAnimation:Button({
    Title = "Anim Skill Old",
    Icon = "arrow-left",
    Callback = function()
        selectedAnimation = "Old"
        replaceAnimations(animationSets.Old)
        WindUI:Notify({Title = "Animation Changed", Content = "Applied Old animations", Icon = "check", Duration = 2})
    end
})

tabAnimation:Button({
    Title = "Anim Skill New",
    Icon = "arrow-right",
    Callback = function()
        selectedAnimation = "New"
        replaceAnimations(animationSets.New)
        WindUI:Notify({Title = "Animation Changed", Content = "Applied New animations", Icon = "check", Duration = 2})
    end
})

lp.CharacterAdded:Connect(function(char)
    task.wait(1)
    if animationSets[selectedAnimation] then replaceAnimations(animationSets[selectedAnimation]) end
end)

-- ===== OTHER TAB =====
local tabOther = Window:Tab({
    Title = "Other",
    Icon = "solar:info-square-bold",
    IconColor = Grey,
    Border = true,
})

tabOther:Button({
    Title = "Change Animation V2",
    Icon = "refresh-cw",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://gist.githubusercontent.com/tranvanxanh0502-afk/be6bf6dc9e3f5c2beb438418277af445/raw/d66fc9b710a26454b5eb1787f1b79bc00024ecb0/I%2520am%2520not%2520the%2520owner,%2520just%2520an%2520update", true))()
        end)
        if not success then
            WindUI:Notify({Title = "Error", Content = "Failed to load script: " .. tostring(err), Icon = "alert-triangle", Duration = 5})
        else
            WindUI:Notify({Title = "Success", Content = "Animation V2 script loaded!", Icon = "check", Duration = 3})
        end
    end
})

tabOther:Button({
    Title = "Flip Script",
    Icon = "rotate-ccw",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/SHRTRYScriptMANhere/stolenahhfrotflip/refs/heads/main/Flip", true))()
        end)
        if not success then
            WindUI:Notify({Title = "Error", Content = "Failed to load Flip script: " .. tostring(err), Icon = "alert-triangle", Duration = 5})
        else
            WindUI:Notify({Title = "Success", Content = "Flip script loaded!", Icon = "check", Duration = 3})
        end
    end
})

-- ===== MOBILE FIX FOR ESP (Resume Fix) =====
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local lastEspCheck = 0
local ESP_CHECK_INTERVAL = 3

task.spawn(function()
    while not unloaded do
        local now = tick()
        if now - lastEspCheck < ESP_CHECK_INTERVAL then task.wait(0.1) continue end
        lastEspCheck = now
        if not isMobile then task.wait(ESP_CHECK_INTERVAL) continue end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == lp or not plr.Character then continue end
            local char = plr.Character
            local team = char.Parent and char.Parent.Name
            local cfg = espConfigs[team]
            if not cfg or not cfg.Enabled then continue end
            
            local highlight = Storage:FindFirstChild(plr.Name.."_Highlight")
            local nametag = Storage:FindFirstChild(plr.Name.."_Nametag")
            
            if highlight and not highlight.Enabled then updateESPConfig(plr) end
            
            if nametag then
                local nameLabel = nametag:FindFirstChild("PlayerName")
                local healthLabel = nametag:FindFirstChild("HealthLabel")
                if (cfg.Name and nameLabel and not nameLabel.Visible) or (cfg.HP and healthLabel and not healthLabel.Visible) then
                    updateESPConfig(plr)
                end
            end
            
            if not highlight and not nametag then createOrUpdateESP(plr, char) end
        end
        task.wait(ESP_CHECK_INTERVAL)
    end
end)

print("[NoHub] WindUI loaded successfully! | Credits: NoHub - Noctyra")
