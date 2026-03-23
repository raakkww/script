local coordinate1 = Vector3.new(121.82, 3.00, -1.91)
local coordinate2 = Vector3.new(-449640.91, 16.70, -32.50)
local player = game.Players.LocalPlayer
local autoTeleportEnabled = false
local useFirstCoordinate = true

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm Wins"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0, 35)
toggleButton.Position = UDim2.new(0.1, 0, 0, 35)
toggleButton.BackgroundColor3 = Color3.new(0, 0.5, 0)
toggleButton.Text = "start"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.SourceSans
toggleButton.Parent = frame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 20)
statusText.Position = UDim2.new(0, 0, 0, 75)
statusText.BackgroundTransparency = 1
statusText.Text = "Status: Stopped"
statusText.TextColor3 = Color3.new(1, 0, 0)
statusText.TextScaled = true
statusText.Font = Enum.Font.SourceSans
statusText.Parent = frame

local targetText = Instance.new("TextLabel")
targetText.Size = UDim2.new(1, 0, 0, 20)
targetText.Position = UDim2.new(0, 0, 0, 95)
targetText.BackgroundTransparency = 1
targetText.Text = "Next: Location 1"
targetText.TextColor3 = Color3.new(1, 1, 0)
targetText.TextScaled = true
targetText.Font = Enum.Font.SourceSans
targetText.Parent = frame

local function teleportToTarget(coordinate, locationName)
    local success, errorMsg = pcall(function()
        local character = player.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(coordinate)
                return true
            end
        end
        return false
    end)
    
    if success then
        print("Teleported to " .. locationName)
        return true
    else
        print("Teleport failed: " .. tostring(errorMsg))
        return false
    end
end

local function teleportLoop()
    while autoTeleportEnabled do
        if useFirstCoordinate then
            teleportToTarget(coordinate1, "Location 1")
            targetText.Text = "Next: Location 2"
        else
            teleportToTarget(coordinate2, "Location 2")
            targetText.Text = "Next: Location 1"
        end
        
        useFirstCoordinate = not useFirstCoordinate
        
        local startTime = tick()
        while autoTeleportEnabled and tick() - startTime < 1.5 do
            wait(0.1)
        end
    end
end

local function startAutoTeleport()
    if autoTeleportEnabled then return end
    
    autoTeleportEnabled = true
    toggleButton.Text = "Stop Teleport"
    toggleButton.BackgroundColor3 = Color3.new(0.5, 0, 0)
    statusText.Text = "Status: Running"
    statusText.TextColor3 = Color3.new(0, 1, 0)
    useFirstCoordinate = true
    targetText.Text = "Next: Location 1"
    
    coroutine.wrap(teleportLoop)()
end

local function stopAutoTeleport()
    autoTeleportEnabled = false
    toggleButton.Text = "Start Teleport"
    toggleButton.BackgroundColor3 = Color3.new(0, 0.5, 0)
    statusText.Text = "Status: Stopped"
    statusText.TextColor3 = Color3.new(1, 0, 0)
    targetText.Text = "Next: None"
end

toggleButton.MouseButton1Click:Connect(function()
    if autoTeleportEnabled then
        stopAutoTeleport()
    else
        startAutoTeleport()
    end
end)

wait(1)
local character = player.Character
if character then
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = CFrame.new(coordinate1)
        print("Test teleport to Location 1 successful")
    else
        warn("HumanoidRootPart not found - make sure you're in a game")
    end
else
    warn("Character not found - join a game first")
end

print("@gravedf on ig and github")
