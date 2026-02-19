--// Wizard UI Library
local Library = loadstring(Game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Window
local Window = Library:NewWindow("AbstZdero Hub")
local MainTab = Window:NewSection("Main")
local ESPSection = Window:NewSection("ESP Toggles")

--// Toggle states
local MonsterESP = false
local SheriffESP = false
local InnocentESP = false
local NameESP = false

--// Item Check
local function itemCheck(player, itemName)
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item.Name == itemName then return true end
    end
    if player.Character then
        for _, item in pairs(player.Character:GetChildren()) do
            if item:IsA("Tool") and item.Name == itemName then
                return true
            end
        end
    end
    return false
end

--// HIGHLIGHT ESP
local function updateHighlight(player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local hasMonster = itemCheck(player, "Monster")
    local hasGun = itemCheck(player, "Gun")
    local innocent = not hasMonster and not hasGun

    local highlight = player.Character:FindFirstChild("ESPHighlight")

    local enable =
        (MonsterESP and hasMonster) or
        (SheriffESP and hasGun) or
        (InnocentESP and innocent)

    if enable then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Adornee = player.Character
            highlight.Parent = player.Character
        end

        if hasMonster and MonsterESP then
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
        elseif hasGun and SheriffESP then
            highlight.FillColor = Color3.fromRGB(0, 0, 255)
        elseif innocent and InnocentESP then
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
        end
    else
        if highlight then highlight:Destroy() end
    end
end

--// NAME ESP
local function updateNameESP(player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    local gui = head:FindFirstChild("NameESP")

    if not NameESP then
        if gui then gui:Destroy() end
        return
    end

    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "NameESP"
        gui.Size = UDim2.new(0, 200, 0, 40)
        gui.StudsOffset = Vector3.new(0, 2.5, 0)
        gui.AlwaysOnTop = true
        gui.Parent = head

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 0.5, 0)
        txt.BackgroundTransparency = 1
        txt.TextScaled = true
        txt.Font = Enum.Font.SourceSansBold
        txt.Parent = gui
    end

    local text = gui:FindFirstChildOfClass("TextLabel")
    text.Text = player.Name

    local hasMonster = itemCheck(player, "Monster")
    local hasGun = itemCheck(player, "Gun")

    if hasMonster then
        text.TextColor3 = Color3.fromRGB(255, 0, 0)
    elseif hasGun then
        text.TextColor3 = Color3.fromRGB(0, 0, 255)
    else
        text.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

--// Highlight loop
task.spawn(function()
    while true do
        for _, plr in pairs(Players:GetPlayers()) do
            pcall(updateHighlight, plr)
        end
        task.wait(0.2)
    end
end)

--// Name ESP loop
task.spawn(function()
    while true do
        if NameESP then
            for _, plr in pairs(Players:GetPlayers()) do
                pcall(updateNameESP, plr)
            end
        else
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    local gui = plr.Character.Head:FindFirstChild("NameESP")
                    if gui then gui:Destroy() end
                end
            end
        end
        wait(0.2)
    end
end)

--// Player support
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        updateHighlight(player)
        updateNameESP(player)
    end)
end)

--// UI Toggles
ESPSection:CreateToggle("Monster ESP", function(v) MonsterESP = v end)
ESPSection:CreateToggle("Sheriff ESP", function(v) SheriffESP = v end)
ESPSection:CreateToggle("Innocent ESP", function(v) InnocentESP = v end)
ESPSection:CreateToggle("Name ESP", function(v) NameESP = v end)

--// Get Gun Button
MainTab:CreateButton("Get Gun", function()

    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Save position
    local savedCFrame = hrp.CFrame

    -- Find gun safely
    local gunHolder = workspace:FindFirstChild("GunPickupHolder")
    local gunPickup = gunHolder and gunHolder:FindFirstChild("GunPickup")
    local gunPart = gunPickup and gunPickup:FindFirstChild("Part")

    -- If not found, send notification
    if not gunPart then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Not Found Gun Part",
                Text = "GunPickupHolder.GunPickup.Part does not exist!",
                Duration = 3
            })
        end)
        return
    end

    -- Teleport to gun
    hrp.CFrame = gunPart.CFrame
    task.wait(0.1)

    -- Teleport back
    hrp.CFrame = savedCFrame
end)
