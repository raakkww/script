--// faven.lua UI
local DiscordLib = loadstring(game:HttpGet("https://pastefy.app/pZDkr0AW/raw"))()
local win = DiscordLib:Window("")
local serv = win:Server("Survive The Sniper", "")

local tools = serv:Channel("Tools")
local sldrs = serv:Channel("Player Tweaks")
local credits = serv:Channel("madebysteppin0nsteppas")


local function BadgeNotify(title, text)
    local p = game.Players.LocalPlayer
    local gui = Instance.new("ScreenGui", p:WaitForChild("PlayerGui"))
    gui.ResetOnSpawn = false

    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 260, 0, 70)
    f.Position = UDim2.new(1, 300, 0, 20)
    f.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local t1 = Instance.new("TextLabel", f)
    t1.Size = UDim2.new(1, -10, 0, 28)
    t1.Position = UDim2.new(0, 10, 0, 5)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = Color3.fromRGB(255, 255, 255)
    t1.TextScaled = true
    t1.Font = Enum.Font.GothamBold

    local t2 = Instance.new("TextLabel", f)
    t2.Size = UDim2.new(1, -10, 0, 30)
    t2.Position = UDim2.new(0, 10, 0, 35)
    t2.BackgroundTransparency = 1
    t2.Text = text
    t2.TextColor3 = Color3.fromRGB(200, 200, 200)
    t2.TextScaled = true
    t2.Font = Enum.Font.Gotham

    local s = Instance.new("Sound", f)
    s.SoundId = "rbxassetid://6026984224"
    s.Volume = 1
    s:Play()

    f:TweenPosition(UDim2.new(1, -280, 0, 20), "Out", "Quad", 0.35, true)
    task.wait(5)
    f:TweenPosition(UDim2.new(1, 300, 0, 20), "In", "Quad", 0.35, true)
    task.wait(0.4)
    gui:Destroy()
end


local function findSniperTouchPart()
    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Name == "BecomeSniper-DONOTTOUCH" then
            for _, c in ipairs(o:GetDescendants()) do
                if c:IsA("TouchTransmitter") or c.Name == "TouchInterest" then
                    return c.Parent
                end
            end
        end
    end
end

local function fireRealTouch(t)
    local c = game.Players.LocalPlayer.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    firetouchinterest(hrp, t, 0)
    task.wait()
    firetouchinterest(hrp, t, 1)
end

local function equipSniper()
    local p = findSniperTouchPart()
    if p then
        fireRealTouch(p)
        BadgeNotify("", "Sniper Equipped")
    end
end


local function removeKillBricks()
    for _, o in ipairs(workspace:GetDescendants()) do
        if (o:IsA("Folder") and o.Name == "Killbricks") or (o:IsA("BasePart") and o.Name == "KillBrick") then
            o:Destroy()
        end
    end
end


local espEnabled = false

local function clearESP()
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Highlight") and o.Name == "ESP" then
            o:Destroy()
        end
    end
end

local function createESP(m, c)
    if not m or not m:IsDescendantOf(workspace) then return end
    local h = Instance.new("Highlight")
    h.Name = "ESP"
    h.FillTransparency = 1
    h.OutlineColor = c
    h.Parent = m
end

local function updateESP()
    clearESP()

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            createESP(plr.Character, Color3.fromRGB(255, 0, 0))
        end
    end

    for _, o in ipairs(workspace:GetDescendants()) do
        if o.Name == "Sniper" and o:IsA("Model") then
            createESP(o, Color3.fromRGB(0, 255, 0))
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then updateESP() end
    end
end)


local hitboxEnabled = false
local hitboxSize = 0
local originalHRPSize = {}

local function applyRealHitbox(char)
    if not hitboxEnabled then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not originalHRPSize[hrp] then
        originalHRPSize[hrp] = hrp.Size
    end

    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.Massless = true
end

local function restoreHitbox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and originalHRPSize[hrp] then
        hrp.Size = originalHRPSize[hrp]
    end
end

local function setup(plr)
    if plr == game.Players.LocalPlayer then return end

    if plr.Character then
        task.wait(0.2)
        applyRealHitbox(plr.Character)
    end

    plr.CharacterAdded:Connect(function(c)
        task.wait(0.2)
        applyRealHitbox(c)
    end)
end

for _, plr in ipairs(game.Players:GetPlayers()) do
    setup(plr)
end

game.Players.PlayerAdded:Connect(setup)


local wsEnabled = false
local wsValue = 16

local function forceWS()
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    hum.WalkSpeed = wsValue

    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if wsEnabled and hum.WalkSpeed ~= wsValue then
            hum.WalkSpeed = wsValue
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if wsEnabled then forceWS() end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    if wsEnabled then forceWS() end
end)


local infJumpEnabled = false

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)


sldrs:Slider("Player Hitbox", 2, 100, 2, function(v)
    hitboxSize = v
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            applyRealHitbox(plr.Character)
        end
    end
end)

sldrs:Toggle("Player Hitbox/Freeze", false, function(s)
    hitboxEnabled = s
    BadgeNotify("", s and "Hitbox/Freeze Enabled" or "Hitbox/Freeze Disabled")

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            if s then
                applyRealHitbox(plr.Character)
            else
                restoreHitbox(plr.Character)
            end
        end
    end
end)

sldrs:Slider("WalkSpeed", 16, 200, 16, function(v)
    wsValue = v
end)

sldrs:Toggle("WalkSpeed Enabled", false, function(s)
    wsEnabled = s
    BadgeNotify("", s and "WalkSpeed Enabled" or "WalkSpeed Disabled")
end)

tools:Toggle("Infinite Jump", false, function(s)
    infJumpEnabled = s
    BadgeNotify("", s and "Infinite Jump Enabled" or "Infinite Jump Disabled")
end)

tools:Button("Become Sniper", function()
    equipSniper()
end)

tools:Button("Remove Kill Bricks", function()
    removeKillBricks()
    BadgeNotify("", "Kill Bricks Removed")
end)

tools:Toggle("ESP (Players + Sniper)", false, function(s)
    espEnabled = s
    if s then updateESP() end
    BadgeNotify("", s and "ESP Enabled" or "ESP Disabled")
end)
