local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "",
   LoadingSubtitle = "",
   ShowText = "", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "a"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🏠Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Welcome!",
   Content = "Happy to see you!",
   Image = nil,

   OnClick = function()

   end,
})

local Button = MainTab:CreateButton({
   Name = "💸Fly (F to toggle/ P for speed)",
   Interact = 'Click',
   Callback = function()
         local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 150
local bv, bg, conn

-- Create UI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FlySpeedUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 70)
Frame.Position = UDim2.new(0.5, -90, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Visible = false

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 8)

local TextLabel = Instance.new("TextLabel", Frame)
TextLabel.Text = "Fly Speed:"
TextLabel.Size = UDim2.new(1, 0, 0, 24)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.TextSize = 18
TextLabel.Position = UDim2.new(0, 0, 0, 5)

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(1, -20, 0, 30)
TextBox.Position = UDim2.new(0, 10, 0, 35)
TextBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.ClearTextOnFocus = false
TextBox.Text = tostring(flySpeed)
TextBox.Font = Enum.Font.SourceSans
TextBox.TextSize = 18
TextBox.PlaceholderText = "Enter speed and press Enter"
local TextBoxCorner = Instance.new("UICorner", TextBox)
TextBoxCorner.CornerRadius = UDim.new(0, 6)

-- Make Frame draggable
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                              startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Fly functions
function fly()
    if flying then return end
    flying = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    conn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local move = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += cam.CFrame.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= cam.CFrame.UpVector end

        if move.Magnitude > 0 then
            bv.Velocity = move.Unit * flySpeed
        else
            bv.Velocity = Vector3.zero
        end

        bg.CFrame = cam.CFrame
    end)
end

function stopFly()
    flying = false
    if conn then conn:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

-- TextBox input handler to update speed on Enter
TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(TextBox.Text)
        if num and num > 0 then
            flySpeed = num
            print("Fly speed set to", flySpeed)
        else
            TextBox.Text = tostring(flySpeed) -- revert to last valid speed
        end
        TextBox:ReleaseFocus()
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.F then
        if flying then
            stopFly()
            print("Fly OFF")
        else
            fly()
            print("Fly ON with speed:", flySpeed)
        end
    elseif input.KeyCode == Enum.KeyCode.P then
        Frame.Visible = not Frame.Visible
        if not Frame.Visible then
            UserInputService:SetModalEnabled(false)
            TextBox:ReleaseFocus()
        end
        print("Fly Speed UI", Frame.Visible and "Shown" or "Hidden")
    end
end)

print("Fly script loaded. Press F to toggle flying, P to toggle speed UI.")

   end,
})


local Button = MainTab:CreateButton({
   Name = "🥏FLING (G toggle/ENABLE FLY MODE)",
   Callback = function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local walkflinging = false
local flingConnection

local FLING_POWER = 1000  -- увеличь это значение для сильнее отдачи
local UPWARD_FORCE = 500  -- вертикальная сила

local function startWalkFling(character)
    local root = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid.BreakJointsOnDeath = false
    humanoid.Health = humanoid.MaxHealth

    root.CanCollide = false
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    walkflinging = true

    flingConnection = RunService.Heartbeat:Connect(function()
        if not walkflinging then return end

        -- Применяем мощный импульс в сторону взгляда игрока + вверх
        local direction = root.CFrame.LookVector
        local flingForce = direction * FLING_POWER + Vector3.new(0, UPWARD_FORCE, 0)
        root.Velocity = flingForce
    end)
end

local function stopWalkFling()
    walkflinging = false
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end

    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if root then root.CanCollide = true end
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
    end
end

-- G - переключение
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        if walkflinging then
            stopWalkFling()
            print("WalkFling OFF")
        else
            if LocalPlayer.Character then
                startWalkFling(LocalPlayer.Character)
                print("WalkFling ON")
            end
        end
    end
end)

-- Если режим включён, активировать при спавне
LocalPlayer.CharacterAdded:Connect(function(char)
    if walkflinging then
        startWalkFling(char)
    end
end)

   end,
})

local Button = MainTab:CreateButton({
   Name = "🖱️Click to TP (C to toggle)",
   Callback = function()
        --// Click to TP with Toggle (C)
local UIS = game:GetService("UserInputService")
local Plr = game.Players.LocalPlayer
local Mouse = Plr:GetMouse()
local On = false

-- Notify toggle state
local function notify(state)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Click TP",
        Text = "Click TP is now " .. (state and "ON" or "OFF"),
        Duration = 2
    })
end

-- Toggle keybind
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.C then
        On = not On
        notify(On)
    end
end)

-- Teleport logic
Mouse.Button1Down:Connect(function()
    if not On then return end

    local target = Mouse.Hit
    if target then
        Plr.Character:MoveTo(target.Position + Vector3.new(0, 3, 0))
    end
end)


   end,
})

PlayerTab = Window:CreateTab("🔫Arsenal", nil) -- Title, Image
PlayerSection = PlayerTab:CreateSection("Player")

local Button = PlayerTab:CreateButton({
   Name = "⚔️Aimbot (Right click to aim)",
   Interact = 'Click',
   Callback = function()
        local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local aiming = false

-- Function to find nearest enemy to your mouse cursor
local function getClosestEnemyHead()
    local mousePos = UserInputService:GetMouseLocation()
    local closestDist = math.huge
    local closestHead = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChild("Humanoid")
                if head and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestHead = head
                        end
                    end
                end
            end
        end
    end

    return closestHead
end

RunService.RenderStepped:Connect(function()
    if aiming then
        local targetHead = getClosestEnemyHead()
        if targetHead then
            -- Snap camera CFrame to look exactly at the target head
            local camPos = Camera.CFrame.Position
            Camera.CFrame = CFrame.new(camPos, targetHead.Position)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

   end,
})

local Button = PlayerTab:CreateButton({
   Name = "☠️Kill ALL (J to toggle)",
   Callback = function()
        local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local killAllActive = false
local teleportDistanceBehind = 3
local shootInterval = 0.1
local lastShoot = 0
local teleportCooldown = 0.5 -- cooldown between teleports in seconds
local lastTeleport = 0

-- Find shooting remote event (adjust if needed)
local shootingEvent
for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
    if remote:IsA("RemoteEvent") and remote.Name:lower():find("shoot") then
        shootingEvent = remote
        break
    end
end

if not shootingEvent then
    warn("Shooting remote not found. Please update manually!")
end

-- Check if a character belongs to a real player and enemy team
local function isValidEnemy(character)
    if not character then return false end
    local player = Players:GetPlayerFromCharacter(character)
    if not player then return false end -- skips dummy parts etc
    if player.Team == LocalPlayer.Team then return false end -- skip teammates
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end -- dead or no humanoid
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return true
end

local function getEnemiesInRadius()
    local char = LocalPlayer.Character
    if not char then return {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end

    local enemiesInRange = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isValidEnemy(player.Character) then
            local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if enemyHRP then
                local horizontalDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(enemyHRP.Position.X, 0, enemyHRP.Position.Z)).Magnitude
                local verticalDist = math.abs(hrp.Position.Y - enemyHRP.Position.Y)
                if horizontalDist <= 300 and verticalDist <= 100 then
                    table.insert(enemiesInRange, player)
                end
            end
        end
    end
    return enemiesInRange
end

local function lookAt(position)
    local camCF = Camera.CFrame
    Camera.CFrame = CFrame.new(camCF.Position, position)
end

local function teleportBehindAndAim(enemy)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local enemyChar = enemy.Character
    if not enemyChar then return end
    local enemyHRP = enemyChar:FindFirstChild("HumanoidRootPart")
    local enemyHead = enemyChar:FindFirstChild("Head")
    if not enemyHRP or not enemyHead then return end

    -- Position teleportDistanceBehind studs behind enemy based on their look vector
    local backPos = enemyHRP.CFrame * CFrame.new(0, 0, teleportDistanceBehind)

    hrp.CFrame = backPos
    lookAt(enemyHead.Position)
end

local killAllConnection

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.J then
        killAllActive = not killAllActive
        print("KillAll toggled:", killAllActive)

        if killAllActive then
            killAllConnection = RunService.Heartbeat:Connect(function(dt)
                local enemies = getEnemiesInRadius()
                if #enemies > 0 then
                    for _, enemy in ipairs(enemies) do
                        if tick() - lastTeleport >= teleportCooldown then
                            teleportBehindAndAim(enemy)
                            lastTeleport = tick()

                            if tick() - lastShoot >= shootInterval then
                                if shootingEvent then
                                    shootingEvent:FireServer()
                                end
                                lastShoot = tick()
                            end
                        end
                    end
                end
            end)
        else
            if killAllConnection then
                killAllConnection:Disconnect()
                killAllConnection = nil
            end
        end
    end
end)

   end,
})

local Button = PlayerTab:CreateButton({
   Name = "🔎ESP (H to toggle)",
   Callback = function()
        -- ✅ Arsenal ESP with Skeleton + Tracers + Nametags + Distance + HP
-- Works with custom rigs, enemies only, toggle with H

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = true
local ToggleKey = Enum.KeyCode.H
local ESPObjects = {}

-- Utility functions
local function createBox()
    local box = Drawing.new("Square")
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 1
    box.Visible = false
    return box
end

local function createLine(color, thickness, transparency)
    local line = Drawing.new("Line")
    line.Color = color
    line.Thickness = thickness
    line.Transparency = transparency
    line.Visible = false
    return line
end

local function createText(size)
    local text = Drawing.new("Text")
    text.Size = size or 14
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Color = Color3.new(1, 0, 0)
    text.Visible = false
    return text
end

local function removeESP(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Remove()
        for _, line in pairs(ESPObjects[player].Skeleton) do line:Remove() end
        ESPObjects[player].Tracer:Remove()
        ESPObjects[player].NameTag:Remove()
        ESPObjects[player].HPTag:Remove()
        ESPObjects[player].DistTag:Remove()
        ESPObjects[player] = nil
    end
end

local function isEnemy(player)
    return player.TeamColor ~= LocalPlayer.TeamColor
end

-- Main ESP loop
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if hrp and head and humanoid then
                if not ESPObjects[player] then
                    ESPObjects[player] = {
                        Box = createBox(),
                        Skeleton = {
                            createLine(Color3.new(1, 0, 0), 1, 1), -- Head to HRP
                            createLine(Color3.new(1, 0, 0), 1, 1), -- Left Arm
                            createLine(Color3.new(1, 0, 0), 1, 1), -- Right Arm
                            createLine(Color3.new(1, 0, 0), 1, 1), -- Left Leg
                            createLine(Color3.new(1, 0, 0), 1, 1), -- Right Leg
                        },
                        Tracer = createLine(Color3.new(1, 0, 0), 1, 0.3),
                        NameTag = createText(16),
                        HPTag = createText(14),
                        DistTag = createText(14)
                    }
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position)

                -- Box
                local box = ESPObjects[player].Box
                if onScreen then
                    local height = (headPos - screenPos).Y * 2
                    local width = height / 2
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
                    box.Visible = ESPEnabled
                else
                    box.Visible = false
                end

                -- Skeleton (simplified, uses offsets from HRP)
                local skel = ESPObjects[player].Skeleton
                local function drawSkelLine(i, offsetA, offsetB)
                    local from = Camera:WorldToViewportPoint(hrp.Position + offsetA)
                    local to = Camera:WorldToViewportPoint(hrp.Position + offsetB)
                    skel[i].From = Vector2.new(from.X, from.Y)
                    skel[i].To = Vector2.new(to.X, to.Y)
                    skel[i].Visible = ESPEnabled and onScreen
                end

                drawSkelLine(1, Vector3.new(0, 1.5, 0), Vector3.new(0, 0, 0))        -- Head to chest
                drawSkelLine(2, Vector3.new(0, 0.5, 0), Vector3.new(-1, 0.5, 0))     -- Left arm
                drawSkelLine(3, Vector3.new(0, 0.5, 0), Vector3.new(1, 0.5, 0))      -- Right arm
                drawSkelLine(4, Vector3.new(-0.3, -1, 0), Vector3.new(-0.3, -2.2, 0)) -- Left leg
                drawSkelLine(5, Vector3.new(0.3, -1, 0), Vector3.new(0.3, -2.2, 0))  -- Right leg

                -- Tracer
                local tracer = ESPObjects[player].Tracer
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                tracer.Visible = ESPEnabled and onScreen

                -- Nametag
                local nameTag = ESPObjects[player].NameTag
                nameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
                nameTag.Text = player.Name
                nameTag.Visible = ESPEnabled and onScreen

                -- HP Tag
                local hpTag = ESPObjects[player].HPTag
                hpTag.Position = Vector2.new(headPos.X, headPos.Y - 5)
                hpTag.Text = "HP: " .. math.floor(humanoid.Health)
                hpTag.Visible = ESPEnabled and onScreen

                -- Distance Tag
                local distTag = ESPObjects[player].DistTag
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0
                distTag.Position = Vector2.new(headPos.X, headPos.Y + 10)
                distTag.Text = tostring(math.floor(distance)) .. " studs"
                distTag.Visible = ESPEnabled and onScreen

            else
                removeESP(player)
            end
        else
            removeESP(player)
        end
    end
end)

-- Toggle key
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == ToggleKey then
        ESPEnabled = not ESPEnabled
    end
end)

-- Clean up players that leave
Players.PlayerRemoving:Connect(removeESP)
       
   end,
})

local Button = MainTab:CreateButton({
   Name = "🚤TP to Players (T for toggle) ",
   Callback = function()
        local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create UI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "InstantTPGui"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 270, 0, 120)
Frame.Position = UDim2.new(0.5, -135, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0)

-- Rounded corners for Frame
local frameCorner = Instance.new("UICorner", Frame)
frameCorner.CornerRadius = UDim.new(0, 12)

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(0, 250, 0, 35)
TextBox.Position = UDim2.new(0, 10, 0, 10)
TextBox.PlaceholderText = "Enter player name"
TextBox.ClearTextOnFocus = false
TextBox.TextColor3 = Color3.new(1,1,1)
TextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TextBox.BorderSizePixel = 0

-- Rounded corners for TextBox
local tbCorner = Instance.new("UICorner", TextBox)
tbCorner.CornerRadius = UDim.new(0, 10)

local TeleportButton = Instance.new("TextButton", Frame)
TeleportButton.Size = UDim2.new(0, 250, 0, 35)
TeleportButton.Position = UDim2.new(0, 10, 0, 55)
TeleportButton.Text = "Teleport"
TeleportButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
TeleportButton.TextColor3 = Color3.new(1, 1, 1)
TeleportButton.BorderSizePixel = 0

-- Rounded corners for Button
local btnCorner = Instance.new("UICorner", TeleportButton)
btnCorner.CornerRadius = UDim.new(0, 10)

local InfoLabel = Instance.new("TextLabel", Frame)
InfoLabel.Size = UDim2.new(0, 250, 0, 20)
InfoLabel.Position = UDim2.new(0, 10, 0, 95)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
InfoLabel.Text = ""
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 14

-- Floating motion parameters
local baseY = Frame.Position.Y.Scale
local floatAmplitude = 0.005
local floatSpeed = 2

-- Instant teleport function
local function instantTeleport(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0,3,0))
end

TeleportButton.MouseButton1Click:Connect(function()
    local inputName = TextBox.Text:lower()
    if inputName == "" then
        InfoLabel.Text = "Please enter a name."
        return
    end

    local targetPlayer = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():sub(1, #inputName) == inputName then
            targetPlayer = plr
            break
        end
    end

    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = targetPlayer.Character.HumanoidRootPart.Position
        instantTeleport(targetPos)
        InfoLabel.Text = "Teleported to " .. targetPlayer.Name
    else
        InfoLabel.Text = "Player not found or not loaded."
    end
end)

-- UI toggle with T key
local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        uiVisible = not uiVisible
        ScreenGui.Enabled = uiVisible
    end
end)

-- Animate floating motion
RunService.RenderStepped:Connect(function(t)
    if uiVisible then
        local yOffset = math.sin(t * floatSpeed) * floatAmplitude
        Frame.Position = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset, baseY + yOffset, Frame.Position.Y.Offset)
    end
end)

   end,
})

local Button = PlayerTab:CreateButton({
   Name = "🐇Bunny Hop",
   Callback = function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local bunnyHopEnabled = false

-- Toggle bunnyhop with B key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        bunnyHopEnabled = not bunnyHopEnabled
        print("Bunny Hop:", bunnyHopEnabled and "Enabled" or "Disabled")
    end
end)

RunService.Heartbeat:Connect(function()
    if bunnyHopEnabled then
        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid.Jump = true
        end
    end
end)

   end,
})

local Button = MainTab:CreateButton({
   Name = "🌪️Spin(Z toggle)",
   Callback = function()
        local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local plr = game.Players.LocalPlayer

local spinning = false
local speed = 90 -- super fast spin speed

local char = plr.Character or plr.CharacterAdded:Wait()
plr.CharacterAdded:Connect(function(c)
    char = c
end)

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Z then
        spinning = not spinning
    end
end)

RS.RenderStepped:Connect(function()
    if spinning and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed), 0)
    end
end)

   end,
})

