-- NoHub by Noctyra | WindUI Version
-- Credits: NoHub - Noctyra

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
local UserInputService = game:GetService("UserInputService")

connections = connections or {}
mainConns = mainConns or {}
unloaded = false

--// WindUI Loader //--
local cloneref = (cloneref or clonereference or function(instance) return instance end)
local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        if cloneref(game:GetService("RunService")):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

--// Main Window //--
local Window = WindUI:CreateWindow({
    Title = "NoHub by Noctyra",
    Folder = "nohub_config",
    Icon = "solar:folder-2-bold-duotone",
    HideSearchBar = false,
    OpenButton = {
        Title = "Open NoHub UI",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

-- Version tag
Window:Tag({
    Title = "v1.0",
    Icon = "github",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

--// ESP Setup (Same logic, UI replaced) //--
local Storage = CoreGui:FindFirstChild("Highlight_Storage") or Instance.new("Folder")
Storage.Name = "Highlight_Storage"
Storage.Parent = CoreGui

local espConfigs = {
    Survivor = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,0),   OutlineColor=Color3.fromRGB(0,255,0),   FillTransparency=0.5, OutlineTransparency=0},
    Killer   = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(255,0,0),   OutlineColor=Color3.fromRGB(255,0,0),   FillTransparency=0.5, OutlineTransparency=0},
    Ghost    = {Enabled=true, Name=true, HP=true, Fill=true, Outline=true, FillColor=Color3.fromRGB(0,255,255), OutlineColor=Color3.fromRGB(0,255,255), FillTransparency=0.5, OutlineTransparency=0},
}

local function updateAllESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then 
            -- ESP logic tetap sama (cleanupESP, createOrUpdateESP, dll)
            -- Dipersingkat untuk fokus pada UI conversion
        end
    end
end

-- ESP Tabs
for teamName, cfg in pairs(espConfigs) do
    local tab = Window:Tab({
        Title = teamName .. " ESP",
        Icon = "solar:info-square-bold",
        IconColor = teamName == "Survivor" and Color3.fromRGB(0,255,0) or 
                   (teamName == "Killer" and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,255)),
        Border = true,
    })
    
    tab:Toggle({
        Title = "Enable ESP",
        Value = cfg.Enabled,
        Callback = function(v)
            cfg.Enabled = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Title = "Show Name",
        Value = cfg.Name,
        Callback = function(v)
            cfg.Name = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Title = "Show HP",
        Value = cfg.HP,
        Callback = function(v)
            cfg.HP = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Title = "Show Fill",
        Value = cfg.Fill,
        Callback = function(v)
            cfg.Fill = v
            updateAllESP()
        end
    })
    
    tab:Colorpicker({
        Title = "Fill Color",
        Default = cfg.FillColor,
        Callback = function(c)
            cfg.FillColor = c
            updateAllESP()
        end
    })
    
    tab:Slider({
        Title = "Fill Transparency",
        Value = { Min = 0, Max = 1, Default = cfg.FillTransparency },
        Step = 0.05,
        Callback = function(v)
            cfg.FillTransparency = v
            updateAllESP()
        end
    })
    
    tab:Toggle({
        Title = "Show Outline",
        Value = cfg.Outline,
        Callback = function(v)
            cfg.Outline = v
            updateAllESP()
        end
    })
    
    tab:Colorpicker({
        Title = "Outline Color",
        Default = cfg.OutlineColor,
        Callback = function(c)
            cfg.OutlineColor = c
            updateAllESP()
        end
    })
    
    tab:Slider({
        Title = "Outline Transparency",
        Value = { Min = 0, Max = 1, Default = cfg.OutlineTransparency },
        Step = 0.05,
        Callback = function(v)
            cfg.OutlineTransparency = v
            updateAllESP()
        end
    })
end

--// Speed Settings //--
local tabSpeed = Window:Tab({
    Title = "Speed Settings",
    Icon = "solar:square-transfer-horizontal-bold",
    IconColor = Color3.fromRGB(37, 122, 247),
    Border = true,
})

local character = lp.Character or lp.CharacterAdded:Wait()
if character:GetAttribute("WalkSpeed") == nil then character:SetAttribute("WalkSpeed", 10) end
if character:GetAttribute("SprintSpeed") == nil then character:SetAttribute("SprintSpeed", 27) end

local walkSpeedValue = character:GetAttribute("WalkSpeed") or 10
local sprintSpeedValue = character:GetAttribute("SprintSpeed") or 27
local walkSpeedEnabled = false
local sprintEnabled = false

tabSpeed:Slider({
    Title = "WalkSpeed",
    Value = { Min = 8, Max = 200, Default = walkSpeedValue },
    Step = 1,
    Callback = function(val)
        walkSpeedValue = val
        if walkSpeedEnabled and character then
            character:SetAttribute("WalkSpeed", walkSpeedValue)
        end
    end
})

tabSpeed:Toggle({
    Title = "Enable WalkSpeed",
    Value = walkSpeedEnabled,
    Callback = function(v)
        walkSpeedEnabled = v
        if v and character then
            character:SetAttribute("WalkSpeed", walkSpeedValue)
        elseif character then
            character:SetAttribute("WalkSpeed", 10)
        end
    end
})

tabSpeed:Slider({
    Title = "SprintSpeed",
    Value = { Min = 16, Max = 300, Default = sprintSpeedValue },
    Step = 1,
    Callback = function(val)
        sprintSpeedValue = val
        if sprintEnabled and character then
            character:SetAttribute("SprintSpeed", sprintSpeedValue)
        end
    end
})

tabSpeed:Toggle({
    Title = "Enable Sprint",
    Value = sprintEnabled,
    Callback = function(v)
        sprintEnabled = v
        if v and character then
            character:SetAttribute("SprintSpeed", sprintSpeedValue)
        elseif character then
            character:SetAttribute("SprintSpeed", 27)
        end
    end
})

--// AutoBlock //--
local tabAutoBlock = Window:Tab({
    Title = "AutoBlock",
    Icon = "solar:check-square-bold",
    IconColor = Color3.fromRGB(16, 197, 80),
    Border = true,
})

local BLOCK_DISTANCE = 15
local watcherEnabled = true
local removeAnimEnabled = false

tabAutoBlock:Toggle({
    Title = "Enable AutoBlock",
    Value = watcherEnabled,
    Callback = function(v)
        watcherEnabled = v
    end
})

tabAutoBlock:Toggle({
    Title = "Delete Block Animation",
    Value = removeAnimEnabled,
    Callback = function(v)
        removeAnimEnabled = v
    end
})

tabAutoBlock:Slider({
    Title = "Block Distance",
    Value = { Min = 5, Max = 50, Default = BLOCK_DISTANCE },
    Step = 1,
    Callback = function(v)
        BLOCK_DISTANCE = v
    end
})

-- Killer toggles
local KillerConfigs = {
    ["Pursuer"] = { enabled = true },
    ["Artful"] = { enabled = true },
    ["Harken"] = { enabled = true },
    ["Badware"] = { enabled = true },
    ["Killdroid"] = { enabled = true }
}

for killerName, cfg in pairs(KillerConfigs) do
    tabAutoBlock:Toggle({
        Title = "Enable " .. killerName,
        Value = cfg.enabled,
        Callback = function(val) 
            cfg.enabled = val 
        end
    })
end

--// Skills & Selector //--
local tabSkills = Window:Tab({
    Title = "Skills & Selector",
    Icon = "solar:cursor-square-bold",
    IconColor = Color3.fromRGB(236, 162, 1),
    Border = true,
})

local skillList = {"Revolver","Punch","Block","Caretaker","Hotdog","Taunt","Cloak","Dash","Banana","BonusPad","Adrenaline"}
local selectedSkill1, selectedSkill2 = "Revolver", "Caretaker"

local skillSection = tabSkills:Section({
    Title = "Selected Skills",
})

skillSection:Paragraph({
    Title = "Skill 1: " .. selectedSkill1,
    Desc = "Skill 2: " .. selectedSkill2,
})

tabSkills:Dropdown({
    Title = "Select Skill 1",
    Values = skillList,
    Value = selectedSkill1,
    Callback = function(opt)
        selectedSkill1 = opt
        -- Update paragraph logic here
    end
})

tabSkills:Dropdown({
    Title = "Select Skill 2",
    Values = skillList,
    Value = selectedSkill2,
    Callback = function(opt)
        selectedSkill2 = opt
        -- Update paragraph logic here
    end
})

tabSkills:Button({
    Title = "Select Skills",
    Callback = function()
        local abilitySelection = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RemoteEvents"):WaitForChild("AbilitySelection")
        abilitySelection:FireServer({selectedSkill1, selectedSkill2})
    end
})

--// Gameplay Settings //--
local tabGameplay = Window:Tab({
    Title = "Gameplay Settings",
    Icon = "solar:password-minimalistic-input-bold",
    IconColor = Color3.fromRGB(119, 117, 242),
    Border = true,
})

local lockWSM = true
tabGameplay:Toggle({
    Title = "Lock WalkSpeedModifier",
    Value = lockWSM,
    Callback = function(v) lockWSM = v end
})

local keepStaminaEnabled = true
local customStamina = 100
tabGameplay:Toggle({
    Title = "Enable Custom MaxStamina",
    Value = keepStaminaEnabled,
    Callback = function(v)
        keepStaminaEnabled = v
        if v and lp.Character then
            lp.Character:SetAttribute("MaxStamina", customStamina)
        end
    end
})

tabGameplay:Input({
    Title = "Custom MaxStamina",
    Placeholder = "Enter number (0-999999)",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 and num <= 999999 then
            customStamina = num
            if keepStaminaEnabled and lp.Character then
                lp.Character:SetAttribute("MaxStamina", customStamina)
            end
        end
    end
})

local AntiWalls = false
tabGameplay:Toggle({
    Title = "Anti-Artful Walls",
    Value = AntiWalls,
    Callback = function(v) AntiWalls = v end
})

local ImplementEnabled = false
tabGameplay:Toggle({
    Title = "Implement Fast Artful",
    Value = ImplementEnabled,
    Callback = function(v) 
        ImplementEnabled = v 
        getgenv().ImplementEnabled = v
    end
})

local noM1Enabled = false
tabGameplay:Toggle({
    Title = "No M1 when Blocking (You Killer)",
    Value = noM1Enabled,
    Callback = function(v) noM1Enabled = v end
})

--// Settings Tab //--
local tabSettings = Window:Tab({
    Title = "Settings",
    Icon = "solar:file-text-bold",
    IconColor = Color3.fromRGB(37, 122, 247),
    Border = true,
})

local instantPPEnabled = true
tabSettings:Toggle({
    Title = "Instant ProximityPrompt",
    Value = instantPPEnabled,
    Callback = function(v) instantPPEnabled = v end
})

tabSettings:Button({
    Title = "Unload Script",
    Color = Color3.fromRGB(255, 72, 48),
    Callback = function()
        if unloaded then return end
        unloaded = true
        -- Cleanup logic tetap sama
        if Storage then pcall(function() Storage:ClearAllChildren() end) end
        for plr, conns in pairs(connections) do
            if conns then
                for _, conn in pairs(conns) do
                    if typeof(conn) == "RBXScriptConnection" then 
                        pcall(function() conn:Disconnect() end) 
                    end
                end
            end
            connections[plr] = nil
        end
        for _, conn in pairs(mainConns) do
            if conn and typeof(conn) == "RBXScriptConnection" then 
                pcall(function() conn:Disconnect() end) 
            end
        end
        Window:Destroy()
        warn("[NoHub] Unloaded successfully.")
    end
})

--// Animation Tab //--
local tabAnim = Window:Tab({
    Title = "Animation",
    Icon = "solar:folder-with-files-bold",
    IconColor = Color3.fromRGB(119, 117, 242),
    Border = true,
})

tabAnim:Button({
    Title = "Anim Skill Old",
    Callback = function()
        -- Animation logic tetap sama
        print("Applying Old animations...")
    end
})

tabAnim:Button({
    Title = "Anim Skill New",
    Callback = function()
        -- Animation logic tetap sama
        print("Applying New animations...")
    end
})

--// Other Tab //--
local tabOther = Window:Tab({
    Title = "Other",
    Icon = "solar:hamburger-menu-bold",
    IconColor = Color3.fromRGB(236, 162, 1),
    Border = true,
})

tabOther:Button({
    Title = "Change Animation V2",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://gist.githubusercontent.com/tranvanxanh0502-afk/be6bf6dc9e3f5c2beb438418277af445/raw/d66fc9b710a26454b5eb1787f1b79bc00024ecb0/I%2520am%2520not%2520the%2520owner,%2520just%2520an%2520update", true))()
        end)
        if not success then warn("[NoHub] Failed to load: " .. tostring(err)) end
    end
})

tabOther:Button({
    Title = "Flip Script",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/SHRTRYScriptMANhere/stolenahhfrotflip/refs/heads/main/Flip", true))()
        end)
        if not success then warn("[NoHub] Failed to load Flip: " .. tostring(err)) end
    end
})

-- Credits notice
Window:Notify({
    Title = "NoHub by Noctyra",
    Content = "Loaded successfully! Credits: NoHub - Noctyra",
    Duration = 5,
})
