local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

-- Global State
_G.SWILL = {
    ESP = false,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    AutoFarm = false,
    GodMode = false,
    AutoCoins = false,
    AutoSkins = false,
    Speed = 16,
    JumpPower = 50,
    FOV = 70
}
_G.AutoKillHomer = false
_G.AutoCollectItems = false
_G.Aimbot = false

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- WindUI Loader
local WindUI
do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        if RunService:IsStudio() then
            -- Fallback for Studio testing if WindUI module is present in ReplicatedStorage
             local success, mod = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("WindUI", 1):WaitForChild("Init") end)
             if success and mod then
                 WindUI = require(mod)
             end
        else
             -- Load from URL
            local success, func = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua") end)
            if success then
                WindUI = loadstring(func)()
            end
        end
    end
end

-- Fallback if WindUI fails to load (prevents crash, though UI won't show)
if not WindUI then
    warn("WindUI could not be loaded.")
    return
end

-- ============================================
-- GAME LOGIC FUNCTIONS (Preserved)
-- ============================================

local Homer = nil
local CoinService = nil
local SkinService = nil

-- Auto-find objects
spawn(function()
    while task.wait(1) do
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name:lower():find("homer") or obj.Name:lower():find("хомер") then
                Homer = obj
                break
            end
        end
        for _, obj in pairs(game:GetDescendants()) do
            if obj.Name:lower():find("coin") or obj.Name:lower():find("money") then
                CoinService = obj
            end
            if obj.Name:lower():find("skin") or obj.Name:lower():find("outfit") then
                SkinService = obj
            end
        end
    end
end)

local function getAllSkins()
    local skins = {}
    if ReplicatedStorage:FindFirstChild("Skins") then
        for _, skin in pairs(ReplicatedStorage.Skins:GetChildren()) do
            table.insert(skins, skin.Name)
        end
    end
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("NumberValue") and obj.Name == "SkinID" then
            table.insert(skins, "Skin_" .. obj.Value)
        end
    end
    local defaultSkins = {
        "Default", "Pro", "Gold", "Diamond", "Rainbow",
        "Fire", "Ice", "Shadow", "Light", "Toxic",
        "VIP", "Admin", "God", "Ultimate", "Legendary"
    }
    for _, skin in ipairs(defaultSkins) do
        table.insert(skins, skin)
    end
    return skins
end

local function applySkin(skinName)
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("skin") or remote.Name:lower():find("outfit")) then
            pcall(function()
                remote:FireServer(skinName)
                remote:FireServer("EquipSkin", skinName)
                remote:FireServer("SelectSkin", skinName)
            end)
        end
    end
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteFunction") and (remote.Name:lower():find("skin") or remote.Name:lower():find("outfit")) then
            pcall(function()
                remote:InvokeServer(skinName)
                remote:InvokeServer("Equip", skinName)
            end)
        end
    end
    if player.Character then
        local character = player.Character
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                if skinName == "Gold" then
                    part.Color = Color3.fromRGB(255, 215, 0)
                elseif skinName == "Diamond" then
                    part.Color = Color3.fromRGB(185, 242, 255)
                elseif skinName == "Fire" then
                    part.Color = Color3.fromRGB(255, 100, 0)
                elseif skinName == "Ice" then
                    part.Color = Color3.fromRGB(100, 200, 255)
                end
            end
        end
        if skinName == "Fire" then
            local fire = Instance.new("Fire")
            fire.Size = 5
            fire.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        end
    end
    return "Skin '" .. skinName .. "' applied!"
end

local function unlockAllSkins()
    local skins = getAllSkins()
    local unlocked = 0
    for _, skin in ipairs(skins) do
        for _, remote in pairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote:FireServer("UnlockSkin", skin)
                    remote:FireServer("PurchaseSkin", skin)
                    remote:FireServer("BuySkin", skin)
                    unlocked = unlocked + 1
                end)
            end
        end
    end
    return "Unlocked " .. unlocked .. " skins"
end

local function getCoins()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in pairs(leaderstats:GetChildren()) do
            if stat.Name:lower():find("coin") or stat.Name:lower():find("money") 
               or stat.Name:lower():find("cash") or stat.Name:lower():find("credit") then
                return stat.Value
            end
        end
    end
    local playergui = player:FindFirstChild("PlayerGui")
    if playergui then
        for _, gui in pairs(playergui:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextButton") then
                local text = gui.Text
                if text and text:find("%d+") then
                    local coins = text:match("%d+")
                    if coins then return tonumber(coins) end
                end
            end
        end
    end
    return 0
end

local function addCoins(amount)
    local added = 0
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") and (remote.Name:lower():find("coin") or remote.Name:lower():find("money")) then
            for i = 1, math.min(amount, 1000) do
                pcall(function()
                    remote:FireServer(amount)
                    remote:FireServer("AddCoins", amount)
                    remote:FireServer("ClaimCoins", amount)
                    added = added + amount
                end)
                if i % 10 == 0 then task.wait() end
            end
        end
    end
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteFunction") and (remote.Name:lower():find("coin") or remote.Name:lower():find("money")) then
            pcall(function()
                remote:InvokeServer(amount)
                remote:InvokeServer("Add", amount)
                added = added + amount
            end)
        end
    end
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in pairs(leaderstats:GetChildren()) do
            if stat.Name:lower():find("coin") or stat.Name:lower():find("money") then
                stat.Value = stat.Value + amount
                added = amount
            end
        end
    end
    return "Added coins: " .. added
end

local function autoCollectCoins()
    while _G.SWILL.AutoCoins do
        for _, coin in pairs(Workspace:GetDescendants()) do
            if coin.Name:lower():find("coin") or coin.Name:lower():find("money") 
               or coin.Name:lower():find("gem") or coin.Name:lower():find("dollar") then
                if coin:IsA("BasePart") then
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = coin.CFrame
                        firetouchinterest(root, coin, 0)
                        firetouchinterest(root, coin, 1)
                    end
                end
            end
        end
        addCoins(1000)
        task.wait(0.5)
    end
end

local function controlHomer()
    if not Homer then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:FindFirstChild("Humanoid") then
                if obj.Name:lower():find("homer") or obj.Name:lower():find("хомер") 
                   or obj.Name:lower():find("enemy") or obj.Name:lower():find("boss") then
                    Homer = obj
                    break
                end
            end
        end
    end
    return Homer
end

local function stopHomer()
    local homer = controlHomer()
    if homer then
        local humanoid = homer:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            for _, part in pairs(homer:GetChildren()) do
                if part:IsA("BasePart") then part.Anchored = true end
            end
        end
    end
end

local function killHomer()
    local homer = controlHomer()
    if homer then
        local humanoid = homer:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end
end

local function teleportToHomer()
    local homer = controlHomer()
    if homer then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local homerRoot = homer:FindFirstChild("HumanoidRootPart") or homer:FindFirstChild("Head")
        if root and homerRoot then
            root.CFrame = homerRoot.CFrame * CFrame.new(0, 0, -5)
        end
    end
end

local function setupESP()
    if _G.SWILL.ESP then
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = "SWILL_ESP"
                highlight.Adornee = target.Character
                highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.FillTransparency = 0.9
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = target.Character
                
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESP_Name"
                billboard.Size = UDim2.new(0, 200, 0, 40)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Adornee = target.Character:WaitForChild("Head")
                billboard.Parent = target.Character
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = target.Name
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 16
                nameLabel.TextStrokeTransparency = 0
                nameLabel.Parent = billboard
            end
        end
    else
        for _, target in pairs(Players:GetPlayers()) do
            if target.Character then
                local esp = target.Character:FindFirstChild("SWILL_ESP")
                if esp then esp:Destroy() end
                local billboard = target.Character:FindFirstChild("ESP_Name")
                if billboard then billboard:Destroy() end
            end
        end
    end
end

local flyBodyVelocity
local function setupFly()
    if _G.SWILL.Fly then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        end
        RunService.Heartbeat:Connect(function()
            if not _G.SWILL.Fly then return end
            local character = player.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    flyBodyVelocity.Parent = root
                    local camera = Workspace.CurrentCamera.CFrame
                    local direction = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.RightVector end
                    
                    direction = direction.Unit * _G.SWILL.Speed * 2
                    flyBodyVelocity.Velocity = Vector3.new(direction.X, 0, direction.Z)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        flyBodyVelocity.Velocity = Vector3.new(direction.X, _G.SWILL.Speed, direction.Z)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        flyBodyVelocity.Velocity = Vector3.new(direction.X, -_G.SWILL.Speed, direction.Z)
                    end
                end
            end
        end)
    else
        if flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
        end
    end
end

-- ============================================
-- WindUI Setup
-- ============================================

local Window = WindUI:CreateWindow({
    Title = "Script Hub | No Key",
    Folder = "scripthub",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    HideSearchBar = false,
    
    OpenButton = {
        Title = "Open Script Hub",
        CornerRadius = UDim.new(1,0), 
        StrokeThickness = 3, 
        Enabled = true,
        Draggable = true,
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

-- Home Tab
local HomeTab = Window:Tab({ Title = "Home", Icon = "solar:home-2-bold" })
HomeTab:Section({ Title = "Welcome", TextSize = 24 })
HomeTab:Paragraph({ 
    Title = "Status", 
    Desc = "Script Loaded Successfully\nKey System: Removed\nAll features active." 
})

-- Skins Tab
local SkinsTab = Window:Tab({ Title = "Skins", Icon = "solar:t-shirt-bold" })
SkinsTab:Button({
    Title = "Unlock All Skins",
    Callback = function()
        local result = unlockAllSkins()
        WindUI:Notify({ Title = "Skins", Content = result, Duration = 5 })
    end
})
local SkinsGroup = SkinsTab:Group({ Title = "Quick Skins" })
SkinsGroup:Button({ Title = "Apply Gold", Callback = function() applySkin("Gold") end })
SkinsGroup:Button({ Title = "Apply Diamond", Callback = function() applySkin("Diamond") end })
SkinsGroup:Button({ Title = "Apply Fire", Callback = function() applySkin("Fire") end })

SkinsTab:Toggle({
    Title = "Auto Skins",
    Callback = function(state)
        _G.SWILL.AutoSkins = state
        if state then
            spawn(function()
                local skins = getAllSkins()
                local index = 1
                while _G.SWILL.AutoSkins do
                    applySkin(skins[index] or "Default")
                    index = (index % #skins) + 1
                    task.wait(3)
                end
            end)
        end
    end
})

-- Coins Tab
local CoinsTab = Window:Tab({ Title = "Coins", Icon = "solar:wallet-money-bold" })
CoinsTab:Button({
    Title = "Check Coin Balance",
    Callback = function()
        WindUI:Notify({ Title = "Coins", Content = "Current Coins: " .. getCoins() })
    end
})
CoinsTab:Button({ Title = "Add 10k Coins", Callback = function() addCoins(10000) end })
CoinsTab:Button({ Title = "Add 100k Coins", Callback = function() addCoins(100000) end })
CoinsTab:Button({ Title = "Add 1M Coins", Callback = function() addCoins(1000000) end })
CoinsTab:Toggle({
    Title = "Infinite Coins (Auto)",
    Callback = function(state)
        _G.SWILL.AutoCoins = state
        if state then spawn(autoCollectCoins) end
    end
})

-- Homer Tab
local HomerTab = Window:Tab({ Title = "Homer", Icon = "solar:skull-bold" })
HomerTab:Button({ Title = "Stop Homer", Callback = stopHomer })
HomerTab:Button({ Title = "Kill Homer", Callback = killHomer })
HomerTab:Button({ Title = "Teleport to Homer", Callback = teleportToHomer })
HomerTab:Toggle({
    Title = "Auto Kill Homer",
    Callback = function(state)
        _G.AutoKillHomer = state
        if state then
            spawn(function()
                while _G.AutoKillHomer do
                    killHomer()
                    task.wait(1)
                end
            end)
        end
    end
})

-- Player Tab
local PlayerTab = Window:Tab({ Title = "Player", Icon = "solar:user-bold" })
PlayerTab:Toggle({
    Title = "God Mode",
    Callback = function(state)
        _G.SWILL.GodMode = state
        if state then
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
            end
        end
    end
})
PlayerTab:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(v) _G.SWILL.Speed = v end
})
PlayerTab:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 300, Default = 50 },
    Callback = function(v) _G.SWILL.JumpPower = v end
})
PlayerTab:Toggle({
    Title = "Infinite Jump",
    Callback = function(state) _G.SWILL.InfiniteJump = state end
})
PlayerTab:Toggle({
    Title = "Fly",
    Callback = function(state)
        _G.SWILL.Fly = state
        setupFly()
    end
})
PlayerTab:Toggle({
    Title = "Noclip",
    Callback = function(state)
        _G.SWILL.Noclip = state
        if state then
            RunService.Stepped:Connect(function()
                if not _G.SWILL.Noclip then return end
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    end
})

-- Visuals Tab
local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "solar:eye-bold" })
VisualsTab:Toggle({
    Title = "ESP Players",
    Callback = function(state)
        _G.SWILL.ESP = state
        setupESP()
    end
})
VisualsTab:Toggle({
    Title = "X-Ray",
    Callback = function(state)
        if state then
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") then part.LocalTransparencyModifier = 0.6 end
            end
        else
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") then part.LocalTransparencyModifier = 0 end
            end
        end
    end
})
VisualsTab:Toggle({
    Title = "Fullbright",
    Callback = function(state)
        if state then
            Lighting.Brightness = 5
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 14
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})
VisualsTab:Slider({
    Title = "FOV",
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(v)
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = v
        end
    end
})

-- Farm Tab
local FarmTab = Window:Tab({ Title = "Farm", Icon = "solar:leaf-bold" })
FarmTab:Toggle({
    Title = "Auto Farm WinPad",
    Callback = function(state)
        _G.SWILL.AutoFarm = state
        if state then
            spawn(function()
                while _G.SWILL.AutoFarm do
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("winpad") or obj.Name:lower():find("win") then
                            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                root.CFrame = obj.CFrame * CFrame.new(0, 3, 0)
                            end
                            break
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})
FarmTab:Toggle({
    Title = "Auto Collect Items",
    Callback = function(state)
        _G.AutoCollectItems = state
        if state then
            spawn(function()
                while _G.AutoCollectItems do
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("coin") or obj.Name:lower():find("money") 
                           or obj.Name:lower():find("gem") or obj.Name:lower():find("item") then
                            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if root and obj:IsA("BasePart") then
                                root.CFrame = obj.CFrame
                            end
                        end
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
})

-- Other Tab
local OtherTab = Window:Tab({ Title = "Other", Icon = "solar:settings-bold" })
OtherTab:Button({
    Title = "Kill All Players",
    Callback = function()
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character then
                local humanoid = target.Character:FindFirstChild("Humanoid")
                if humanoid then humanoid.Health = 0 end
            end
        end
    end
})
OtherTab:Button({
    Title = "Aimbot",
    Callback = function()
         _G.Aimbot = true
        RunService.RenderStepped:Connect(function()
            if not _G.Aimbot then return end
            local closest = nil
            local closestDist = math.huge
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and target.Character then
                    local head = target.Character:FindFirstChild("Head")
                    if head then
                        local screenPoint = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                        local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = target
                        end
                    end
                end
            end
            if closest and closest.Character then
                local head = closest.Character:FindFirstChild("Head")
                if head then mouse.Target = head end
            end
        end)
    end
})
OtherTab:Button({
    Title = "Anti-AFK",
    Callback = function()
        while task.wait(30) do
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
})
OtherTab:Button({
    Title = "Crash Server",
    Color = Color3.fromHex("#FF0000"),
    Callback = function()
        while true do
            for i = 1, 100 do
                Instance.new("Part", Workspace):Destroy()
            end
            task.wait()
        end
    end
})

-- Global Listeners
UserInputService.JumpRequest:Connect(function()
    if _G.SWILL.InfiniteJump and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = _G.SWILL.Speed
        humanoid.JumpPower = _G.SWILL.JumpPower
    end
end)

WindUI:Notify({
    Title = "Scripts Loaded",
    Content = "All functions ready. Enjoy!",
    Duration = 5
})
