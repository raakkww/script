if identifyexecutor and not identifyexecutor():lower():find("delta") then
    return warn("Delta Executor recommended for best performance")
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
    Name = "Baldi Frenzy",
    LoadingTitle = "Loading Features",
    LoadingSubtitle = "",
    ConfigurationSaving = { Enabled = true, FolderName = "BaldiFrenzyConfig", FileName = "Config" }
})

local MainTab = Window:CreateTab("Main", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Services & Vars
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart", 9)
local hum = char:WaitForChild("Humanoid", 9)

-- Toggles & Values
local toggles = {
    infStamina = false,
    noclip = false,
    infJump = false,
    invisible = false,
    godmode = false,
    fullbright = false,
    baldiESP = false,
    itemESP = false,
    studentESP = false,
    notebookESP = false,
    fly = false,
    autoFinishNotebook = false
}
local values = {
    speed = 16,
    jump = 50,
    flySpeed = 50
}
local espConnections = {}
local colors = {
    baldi = Color3.fromRGB(255, 0, 0),
    item = Color3.fromRGB(0, 255, 0),
    student = Color3.fromRGB(0, 162, 255),
    notebook = Color3.fromRGB(255, 215, 0)
}

-- Character Refresh
local function refreshChar()
    char = lp.Character
    if not char then return end
    hrp = char:WaitForChild("HumanoidRootPart", 9)
    hum = char:WaitForChild("Humanoid", 9)
    hum.WalkSpeed = values.speed
    hum.JumpPower = values.jump
end
lp.CharacterAdded:Connect(refreshChar)

-- Main Tab
MainTab:CreateToggle({
    Name = "Infinite Stamina (Fixed)",
    CurrentValue = false,
    Callback = function(v)
        toggles.infStamina = v
    end
})

MainTab:CreateToggle({
    Name = "Godmode",
    CurrentValue = false,
    Callback = function(v)
        toggles.godmode = v
    end
})

MainTab:CreateToggle({
    Name = "Notebook Auto-Finish",
    CurrentValue = false,
    Callback = function(v)
        toggles.autoFinishNotebook = v
        if v then
            Rayfield:Notify({
                Title = "Notebook Auto-Finish Activated",
                Content = "Scanning for notebook remotes... Spamming correct answers periodically.",
                Duration = 5
            })
        end
    end
})

MainTab:CreateButton({
    Name = "Bring All Items to Me",
    Callback = function()
        for _, obj in ipairs(workspace:GetChildren()) do
            local lower = obj.Name:lower()
            if lower:find("item") or lower:find("pickup") or lower:find("battery") or lower:find("key") or lower:find("slingshot") then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    part.CFrame = hrp.CFrame * CFrame.new(0, 0, -3)
                end
            end
        end
        Rayfield:Notify({Title = "Items Brought", Content = "All detected items moved to your position", Duration = 3})
    end
})

-- Movement Tab
MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = 16,
    Callback = function(v)
        values.speed = v
        if hum then hum.WalkSpeed = v end
    end
})

MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = " power",
    CurrentValue = 50,
    Callback = function(v)
        values.jump = v
        if hum then hum.JumpPower = v end
    end
})

MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v)
        toggles.noclip = v
    end
})

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        toggles.infJump = v
    end
})

MovementTab:CreateToggle({
    Name = "Fly (Space = up, Shift = down)",
    CurrentValue = false,
    Callback = function(v)
        toggles.fly = v
    end
})

-- Visuals Tab
VisualsTab:CreateToggle({
    Name = "Baldi ESP",
    CurrentValue = false,
    Callback = function(v)
        toggles.baldiESP = v
        if v then updateESP("baldi") else clearESP("baldi") end
    end
})

VisualsTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Callback = function(v)
        toggles.itemESP = v
        if v then updateESP("item") else clearESP("item") end
    end
})

VisualsTab:CreateToggle({
    Name = "Student ESP",
    CurrentValue = false,
    Callback = function(v)
        toggles.studentESP = v
        if v then updateESP("student") else clearESP("student") end
    end
})

VisualsTab:CreateToggle({
    Name = "Notebook ESP",
    CurrentValue = false,
    Callback = function(v)
        toggles.notebookESP = v
        if v then updateESP("notebook") else clearESP("notebook") end
    end
})

VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        toggles.fullbright = v
        if v then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 14
            Lighting.FogEnd = 9999999
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
        end
    end
})

-- Player Tab
PlayerTab:CreateToggle({
    Name = "Invisible (Transparency)",
    CurrentValue = false,
    Callback = function(v)
        toggles.invisible = v
    end
})

-- Teleport Tab (unchanged from previous)
TeleportTab:CreateButton({
    Name = "Teleport to Baldi",
    Callback = function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:lower():find("baldi") then
                local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
                if root then
                    hrp.CFrame = root.CFrame * CFrame.new(0, 5, 0)
                    Rayfield:Notify({Title = "Teleport Success", Content = "Moved to Baldi position", Duration = 2})
                    return
                end
            end
        end
        Rayfield:Notify({Title = "Not Found", Content = "Baldi not located", Duration = 3})
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Nearest Student",
    Callback = function()
        local closest, dist = nil, math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local d = (hrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; closest = plr.Character.HumanoidRootPart end
            end
        end
        if closest then
            hrp.CFrame = closest.CFrame * CFrame.new(0, 0, -2)
            Rayfield:Notify({Title = "Teleport Success", Content = "Moved to nearest student", Duration = 2})
        end
    end
})

-- Settings Tab
SettingsTab:CreateSection("ESP Colors")

SettingsTab:CreateColorPicker({
    Name = "Baldi Color",
    Color = colors.baldi,
    Callback = function(v)
        colors.baldi = v
        updateESP("baldi")
    end
})

SettingsTab:CreateColorPicker({
    Name = "Item Color",
    Color = colors.item,
    Callback = function(v)
        colors.item = v
        updateESP("item")
    end
})

SettingsTab:CreateColorPicker({
    Name = "Student Color",
    Color = colors.student,
    Callback = function(v)
        colors.student = v
        updateESP("student")
    end
})

SettingsTab:CreateColorPicker({
    Name = "Notebook Color",
    Color = colors.notebook,
    Callback = function(v)
        colors.notebook = v
        updateESP("notebook")
    end
})

SettingsTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 100},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 50,
    Callback = function(v)
        values.flySpeed = v
    end
})

-- Core Functions
local function getTargetESP(typ)
    local lower
    if typ == "baldi" then
        return function(obj) return obj:IsA("Model") and obj.Name:lower():find("baldi") end
    elseif typ == "item" then
        return function(obj)
            lower = obj.Name:lower()
            return lower:find("item") or lower:find("pickup") or lower:find("battery") or lower:find("key") or lower:find("slingshot")
        end
    elseif typ == "student" then
        return function(obj) return obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= char end
    elseif typ == "notebook" then
        return function(obj)
            lower = obj.Name:lower()
            return lower:find("note") or lower:find("book") or lower:find("notebook") or lower:find("activity") or lower:find("question")
        end
    end
end

function updateESP(typ)
    clearESP(typ)
    espConnections[typ] = RunService.RenderStepped:Connect(function()
        if not toggles[typ .. "ESP"] then
            if espConnections[typ] then espConnections[typ]:Disconnect() end
            return
        end
        for _, obj in ipairs(workspace:GetChildren()) do
            if getTargetESP(typ)(obj) then
                local part = obj:FindFirstChild("Head") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part and not part:FindFirstChild("FrenzyESP_" .. typ) then
                    local bg = Instance.new("BillboardGui")
                    bg.Name = "FrenzyESP_" .. typ
                    bg.Parent = part
                    bg.Size = UDim2.new(0, 150, 0, 50)
                    bg.StudsOffset = Vector3.new(0, 3, 0)
                    bg.AlwaysOnTop = true

                    local txt = Instance.new("TextLabel", bg)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = typ:gsub("^%l", string.upper) .. "\n" .. math.floor((hrp.Position - part.Position).Magnitude) .. " studs"
                    txt.TextColor3 = colors[typ]
                    txt.TextStrokeTransparency = 0
                    txt.TextStrokeColor3 = Color3.new(0,0,0)
                    txt.TextScaled = true
                    txt.Font = Enum.Font.GothamBold
                end
            end
        end
    end)
end

function clearESP(typ)
    if espConnections[typ] then espConnections[typ]:Disconnect() end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BillboardGui") and v.Name == "FrenzyESP_" .. typ then
            v:Destroy()
        end
    end
end

-- Loops
RunService.Stepped:Connect(function()
    if toggles.noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.Stepped:Connect(function()
    if toggles.infJump and hum then
        hum.JumpPower = values.jump
        if hum:GetState() == Enum.HumanoidStateType.Jumping then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if toggles.fly and hrp then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0,0,0)
        local uis = game:GetService("UserInputService")
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
        hrp.Velocity = (cam.CFrame.LookVector * moveDir.Z + cam.CFrame.RightVector * moveDir.X + Vector3.new(0, moveDir.Y, 0)) * values.flySpeed
    end
end)

RunService.Heartbeat:Connect(function()
    if toggles.infStamina then
        hum:ChangeState(Enum.HumanoidStateType.Running)
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("NumberValue") and v.Name:lower():find("stamina") then
                v.Value = 100
            end
        end
        pcall(function() lp.leaderstats.Stamina.Value = 100 end)
    end
    if toggles.godmode and hum then
        hum.Health = 100
    end
end)

RunService.RenderStepped:Connect(function()
    if toggles.invisible and char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = 1
            elseif part:IsA("Accessory") then
                pcall(function() part.Handle.Transparency = 1 end)
            end
        end
        hrp.CanCollide = false
    end
end)

-- Notebook Auto-Finish (periodic spam on likely remotes)
spawn(function()
    while true do
        wait(1.2)
        if not toggles.autoFinishNotebook then continue end

        local possibleRemotes = {"Answer", "Submit", "Question", "Activity", "CompleteActivity", "NotebookAnswer", "AnswerQuestion"}
        for _, namePattern in ipairs(possibleRemotes) do
            for _, remote in ipairs(game:GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find(namePattern:lower()) then
                    -- Spam some "correct" patterns (many games accept any high number or true)
                    pcall(function() remote:FireServer(999999, true) end)
                    pcall(function() remote:FireServer("correct", true) end)
                    pcall(function() remote:FireServer(31718, true) end)  -- classic secret if reused
                    pcall(function() remote:FireServer(1, true) end)
                end
            end
        end
    end
end)

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Notebook Auto-Finish and Notebook ESP added. Configs are saved automatically. Use features responsibly.",
    Duration = 6
})

print("Baldi Frenzy Script loaded")
