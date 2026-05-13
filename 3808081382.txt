local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Load WindUI using the method from the example
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- State Management
local State = {
    OrbitEnabled = false,
    FollowEnabled = false,
    AuraEnabled = false,
    Radius = 7.5, -- Default from original script
    Speed = 5,    -- Default from original script
    AuraRange = 15,
    Targets = {},
}

local Connections = {}

-- */ Helper Functions /* --

local function GetTarget()
    for _, id in ipairs(State.Targets) do
        local p = Players:GetPlayerByUserId(id)
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then return p end
        end
    end
    return nil
end

-- */ Feature Logic /* --

-- Follow & Orbit Loop
Connections.Movement = RunService.Heartbeat:Connect(function()
    local target = GetTarget()
    if not target or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = target.Character.HumanoidRootPart
    if not root or not targetRoot then return end

    if State.OrbitEnabled then
        local timer = tick() * State.Speed
        local offset = Vector3.new(math.cos(timer) * State.Radius, 0, math.sin(timer) * State.Radius)
        root.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
    elseif State.FollowEnabled then
        -- Follows target with a 5-stud offset behind them
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
    end
end)

-- Kill Aura Loop
task.spawn(function()
    while task.wait(0.1) do
        if State.AuraEnabled then
            local target = GetTarget()
            if target and target.Character then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
                if dist <= State.AuraRange then
                    -- PLACEHOLDER: Insert your game's attack remote here
                    -- Example: game.ReplicatedStorage.AttackRemote:FireServer(target)
                    print("Aura attacking: " .. target.Name)
                end
            end
        end
    end
end)

-- */ UI Construction using WindUI Elements /* --

local Window = WindUI:CreateWindow({
    Title = "Anti-Teamer Hub V2",
    Icon = "solar:shield-star-bold",
    Author = "Refined Edition",
    Folder = "AntiTeamerV2",
})

local CombatTab = Window:Tab({
    Title = "Combat Utilities",
    Icon = "solar:sword-bold",
})

-- Selection Section
CombatTab:Section({ Title = "Targeting" })

local PlayerDropdown = CombatTab:Dropdown({
    Title = "Select Teamers",
    Desc = "Choose players to target",
    Multi = true,
    Values = {},
    Callback = function(selected)
        State.Targets = {}
        for _, name in ipairs(selected) do
            local p = Players:FindFirstChild(name)
            if p then table.insert(State.Targets, p.UserId) end
        end
    end
})

CombatTab:Button({
    Title = "Refresh Player List",
    Icon = "refresh-cw",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        PlayerDropdown:Refresh(names)
    end
})

-- Movement Section
CombatTab:Section({ Title = "Movement" })

CombatTab:Toggle({
    Title = "Orbit Mode",
    Desc = "Spin around the teamer",
    Value = false,
    Callback = function(v) 
        State.OrbitEnabled = v 
        if v then State.FollowEnabled = false end -- Disable follow if orbit is on
    end
})

CombatTab:Toggle({
    Title = "Follow Mode",
    Desc = "Sticky follow behind the teamer",
    Value = false,
    Callback = function(v) 
        State.FollowEnabled = v 
        if v then State.OrbitEnabled = false end -- Disable orbit if follow is on
    end
})

-- Aura Section
CombatTab:Section({ Title = "Automation" })

CombatTab:Toggle({
    Title = "Kill Aura",
    Desc = "Automatically attack targeted teamer in range",
    Value = false,
    Callback = function(v) State.AuraEnabled = v end
})

-- Settings Section
CombatTab:Section({ Title = "Fine Tuning" })

CombatTab:Slider({
    Title = "Orbit/Follow Radius",
    Step = 1,
    Value = { Min = 2, Max = 30, Default = 7 },
    Callback = function(v) State.Radius = v end
})

CombatTab:Slider({
    Title = "Aura Range",
    Step = 1,
    Value = { Min = 5, Max = 50, Default = 15 },
    Callback = function(v) State.AuraRange = v end
})

-- Initial Refresh
local initialNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(initialNames, p.Name) end
end
PlayerDropdown:Refresh(initialNames)
