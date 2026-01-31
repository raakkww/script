local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local binds = {
    aim           = {inputType = "KeyCode", value = Enum.KeyCode.E},
    toggle_esp    = {inputType = "KeyCode", value = Enum.KeyCode.T},
    toggle_gui    = {inputType = "KeyCode", value = Enum.KeyCode.Minus},
    visible_check = {inputType = "KeyCode", value = Enum.KeyCode.U},
    fov_circle    = {inputType = "KeyCode", value = Enum.KeyCode.L},
    destroy       = {inputType = "KeyCode", value = Enum.KeyCode.J},
    undo          = {inputType = "KeyCode", value = Enum.KeyCode.K},
}

local AIM_PART     = "UpperTorso"
local AIM_SPEED    = 1
local FOV_RADIUS   = 180
local FOV_COLOR    = Color3.fromRGB(220,220,255)
local VISIBLE_CHECK = false
local ESP_ENABLED  = false
local aimMode      = "Toggle"
local currentLanguage = "EN"

local aimLocked    = false
local lockedPart   = nil
local changingBind = nil
local destroyed    = {}

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness     = 2
fovCircle.NumSides      = 100
fovCircle.Radius        = FOV_RADIUS
fovCircle.Filled        = false
fovCircle.Transparency  = 0.85
fovCircle.Color         = FOV_COLOR
fovCircle.Visible       = true
fovCircle.Position      = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

local espFolder = Instance.new("Folder")
espFolder.Name = "BraveESP"
espFolder.Parent = Camera
local playerESP = {}

local function safeDestroy(obj)
    pcall(function() if obj then obj:Destroy() end end)
end

local function disconnectConnections(data)
    if not data or not data.conns then return end
    for _, conn in ipairs(data.conns) do pcall(function() conn:Disconnect() end) end
    data.conns = nil
end

local function isValidTarget(player)
    if not player or not player.Character then return false end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not player.Character:FindFirstChild("HumanoidRootPart") then return false end
    return true
end

local function getPlayerColor(player)
    if player.Team == LocalPlayer.Team then return Color3.fromRGB(255,255,255) end
    if player.Team and player.Team.Name == "Police"    then return Color3.fromRGB(0,0,255)    end
    if player.Team and player.Team.Name == "Prisoners" then return Color3.fromRGB(200,100,0)  end
    if player.Team and player.Team.Name == "Criminals" then return Color3.fromRGB(255,100,100)end
    return Color3.fromRGB(255,60,60)
end

local function removeESP(player)
    local data = playerESP[player]
    if data then
        disconnectConnections(data)
        safeDestroy(data.highlight)
        safeDestroy(data.nameTag)
        playerESP[player] = nil
    end
end

local function createESP(player)
    if not player.Character then return end
    removeESP(player)

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = getPlayerColor(player)
    highlight.Parent = espFolder

    local head = player.Character:FindFirstChild("Head")
    local nameTag = nil
    if head then
        nameTag = Instance.new("BillboardGui")
        nameTag.Adornee = head
        nameTag.Size = UDim2.new(0,140,0,24)
        nameTag.StudsOffset = Vector3.new(0,1.6,0)
        nameTag.AlwaysOnTop = true
        nameTag.Parent = highlight

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextStrokeTransparency = 0.7
        label.TextColor3 = getPlayerColor(player)
        label.Parent = nameTag
    end

    playerESP[player] = {
        highlight = highlight,
        nameTag = nameTag,
        conns = {}
    }

    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        table.insert(playerESP[player].conns, hum.Died:Connect(function()
            removeESP(player)
            if aimLocked and lockedPart and lockedPart.Parent == player.Character then
                aimLocked = false
                lockedPart = nil
            end
        end))
    end
end

for _, p in Players:GetPlayers() do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function() task.wait(0.1) if ESP_ENABLED then createESP(p) end end)
        if p.Character and ESP_ENABLED then task.wait(0.1) createESP(p) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(0.1) if ESP_ENABLED then createESP(p) end end)
end)

Players.PlayerRemoving:Connect(removeESP)

local function isPartVisible(position, character)
    if not VISIBLE_CHECK then return true end
    local origin = Camera.CFrame.Position
    local direction = position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or game, Camera}
    local result = workspace:Raycast(origin, direction, rayParams)
    return result and result.Instance and result.Instance:IsDescendantOf(character)
end

local function getClosestTarget()
    local best, bestDist = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in Players:GetPlayers() do
        if p == LocalPlayer or not isValidTarget(p) or p.Team == LocalPlayer.Team then continue end
        local part = p.Character:FindFirstChild(AIM_PART) or p.Character:FindFirstChild("Head")
        if not part then continue end
        local screen, visible = Camera:WorldToViewportPoint(part.Position)
        if not visible then continue end
        local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
        if dist <= FOV_RADIUS and dist < bestDist and isPartVisible(part.Position, p.Character) then
            bestDist = dist
            best = part
        end
    end
    return best
end

local function smoothAimTo(part)
    if not part then return end
    local target = CFrame.new(Camera.CFrame.Position, part.Position)
    Camera.CFrame = Camera.CFrame:Lerp(target, AIM_SPEED)
end

local function getBindDisplay(bind)
    if bind.inputType == "KeyCode" then return bind.value.Name end
    if bind.inputType == "MouseButton" then
        if bind.value == Enum.UserInputType.MouseButton1 then return "LMB" end
        if bind.value == Enum.UserInputType.MouseButton2 then return "RMB" end
        if bind.value == Enum.UserInputType.MouseButton3 then return "MMB" end
    end
    return "?"
end

local function isPressed(inputObj, bind)
    if bind.inputType == "KeyCode" then
        return inputObj.UserInputType == Enum.UserInputType.Keyboard and inputObj.KeyCode == bind.value
    elseif bind.inputType == "MouseButton" then
        return inputObj.UserInputType == bind.value
    end
    return false
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or changingBind then return end

    if isPressed(input, binds.aim) then
        if aimMode == "Toggle" then
            aimLocked = not aimLocked
            if aimLocked then
                lockedPart = getClosestTarget()
                if lockedPart then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
                else
                    aimLocked = false
                end
            else
                lockedPart = nil
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        else
            lockedPart = getClosestTarget()
            aimLocked = lockedPart ~= nil
            UserInputService.MouseBehavior = aimLocked and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
        end

    elseif isPressed(input, binds.toggle_esp) then
        ESP_ENABLED = not ESP_ENABLED
        if ESP_ENABLED then
            for _,p in Players:GetPlayers() do if p ~= LocalPlayer then createESP(p) end end
        else
            for p,_ in pairs(playerESP) do removeESP(p) end
        end

    elseif isPressed(input, binds.toggle_gui) then
        local gui = LocalPlayer.PlayerGui:FindFirstChild("BraveGUILIP")
        if gui then gui.Enabled = not gui.Enabled end

    elseif isPressed(input, binds.visible_check) then
        VISIBLE_CHECK = not VISIBLE_CHECK

    elseif isPressed(input, binds.fov_circle) then
        fovCircle.Visible = not fovCircle.Visible

    elseif isPressed(input, binds.destroy) then
        local target = Mouse.Target
        if target and target ~= workspace.Terrain and not target:IsDescendantOf(LocalPlayer.Character) then
            local model = target:FindFirstAncestorWhichIsA("Model")
            if not (model and Players:GetPlayerFromCharacter(model)) then
                table.insert(destroyed, {target, target.Parent})
                target.Parent = nil
            end
        end

    elseif isPressed(input, binds.undo) then
        if #destroyed > 0 then
            local entry = table.remove(destroyed)
            entry[1].Parent = entry[2]
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or changingBind then return end
    if aimMode == "Hold" and isPressed(input, binds.aim) then
        aimLocked = false
        lockedPart = nil
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = FOV_RADIUS

    if aimLocked and lockedPart and lockedPart.Parent then
        local player = Players:GetPlayerFromCharacter(lockedPart.Parent)
        if not player or not isValidTarget(player) or player.Team == LocalPlayer.Team then
            aimLocked = false
            lockedPart = nil
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        else
            local screen, onScreen = Camera:WorldToViewportPoint(lockedPart.Position)
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude

            if not onScreen or dist > FOV_RADIUS or (VISIBLE_CHECK and not isPartVisible(lockedPart.Position, player.Character)) then
                aimLocked = false
                lockedPart = nil
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            else
                smoothAimTo(lockedPart)
            end
        end
    end

    if ESP_ENABLED then
        for p, data in pairs(playerESP) do
            if isValidTarget(p) and data.highlight then
                data.highlight.OutlineColor = getPlayerColor(p)
                if data.nameTag then
                    local lbl = data.nameTag:FindFirstChild("TextLabel")
                    if lbl then lbl.TextColor3 = getPlayerColor(p) end
                end
            end
        end
    end
end)

local function getText(key)
    if currentLanguage == "PL" then
        local dict = {
            ["Main"]          = "Główne",
            ["Keybinds"]      = "Klawisze",
            ["Aim Mode"]      = "Tryb celowania",
            ["Aimbot"]        = "Celownik",
            ["Toggle ESP"]    = "Włącz/wyłącz ESP",
            ["Visible Check"] = "Sprawdzanie widoczności",
            ["FOV Circle"]    = "Okrąg FOV",
            ["Destroy"]       = "Niszcz",
            ["Undo"]          = "Cofnij",
            ["Toggle GUI"]    = "Pokaż/ukryj GUI",
            ["Aimbot Range"]  = "Zasięg celownika",
        }
        return dict[key] or key
    end
    return key
end

local function createGUI()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local oldGui = pg:FindFirstChild("BraveGUILIP")
    local savedPos = oldGui and oldGui.Panel.Position or UDim2.new(0.5, -170, 0.5, -170)
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "BraveGUILIP"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000
    gui.Parent = pg

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 340, 0, 340)
    panel.Position = savedPos
    panel.BackgroundColor3 = Color3.fromRGB(25,25,25)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel = 0
    panel.Active = true
    panel.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,34)
    title.BackgroundTransparency = 1
    title.Text = ""
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Parent = panel

    task.spawn(function()
        while title.Parent do
            title.TextColor3 = Color3.fromHSV(tick() * 0.12 % 1, 1, 1)
            task.wait(0.03)
        end
    end)

    local mainTab = Instance.new("TextButton", panel)
    mainTab.Size = UDim2.new(0.5,0,0,30)
    mainTab.Position = UDim2.new(0,0,0,36)
    mainTab.Text = getText("Main")
    mainTab.Font = Enum.Font.Gotham
    mainTab.TextSize = 14
    mainTab.BackgroundColor3 = Color3.fromRGB(45,45,45)
    mainTab.TextColor3 = Color3.fromRGB(255,255,255)

    local keysTab = Instance.new("TextButton", panel)
    keysTab.Size = UDim2.new(0.5,0,0,30)
    keysTab.Position = UDim2.new(0.5,0,0,36)
    keysTab.Text = getText("Keybinds")
    keysTab.Font = Enum.Font.Gotham
    keysTab.TextSize = 14
    keysTab.BackgroundColor3 = Color3.fromRGB(70,70,70)
    keysTab.TextColor3 = Color3.fromRGB(255,255,255)

    local mainPage = Instance.new("Frame", panel)
    mainPage.Size = UDim2.new(1,0,1,-80)
    mainPage.Position = UDim2.new(0,0,0,72)
    mainPage.BackgroundTransparency = 1

    local keysPage = Instance.new("Frame", panel)
    keysPage.Size = UDim2.new(1,0,1,-80)
    keysPage.Position = UDim2.new(0,0,0,72)
    keysPage.BackgroundTransparency = 1
    keysPage.Visible = false

    local function showMain()
        mainPage.Visible = true
        keysPage.Visible = false
        mainTab.BackgroundColor3 = Color3.fromRGB(45,45,45)
        keysTab.BackgroundColor3 = Color3.fromRGB(70,70,70)
    end

    local function showKeys()
        mainPage.Visible = false
        keysPage.Visible = true
        mainTab.BackgroundColor3 = Color3.fromRGB(70,70,70)
        keysTab.BackgroundColor3 = Color3.fromRGB(45,45,45)
    end

    mainTab.MouseButton1Click:Connect(showMain)
    keysTab.MouseButton1Click:Connect(showKeys)
    showMain()

    local langBtn = Instance.new("TextButton", panel)
    langBtn.Size = UDim2.new(0,40,0,24)
    langBtn.Position = UDim2.new(1,-48,1,-32)
    langBtn.BackgroundColor3 = Color3.fromRGB(50,50,80)
    langBtn.Text = currentLanguage
    langBtn.Font = Enum.Font.GothamBold
    langBtn.TextSize = 14
    langBtn.TextColor3 = Color3.fromRGB(220,220,255)

    langBtn.MouseButton1Click:Connect(function()
        currentLanguage = currentLanguage == "EN" and "PL" or "EN"
        langBtn.Text = currentLanguage
        createGUI()
    end)

    local yOffset = 0
    local function addLabel(text)
        local lbl = Instance.new("TextLabel", mainPage)
        lbl.Size = UDim2.new(1,0,0,20)
        lbl.Position = UDim2.new(0,0,0,yOffset)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(220,220,255)
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        yOffset = yOffset + 22
    end

    addLabel(getBindDisplay(binds.aim) .. " = " .. getText("Aimbot"))
    addLabel(getBindDisplay(binds.toggle_esp) .. " = " .. getText("Toggle ESP"))
    addLabel(getBindDisplay(binds.visible_check) .. " = " .. getText("Visible Check"))
    addLabel(getBindDisplay(binds.fov_circle) .. " = " .. getText("FOV Circle"))
    addLabel(getBindDisplay(binds.destroy) .. " = " .. getText("Destroy"))
    addLabel(getBindDisplay(binds.undo) .. " = " .. getText("Undo"))

    local guiHint = Instance.new("TextLabel", mainPage)
    guiHint.Size = UDim2.new(1,-10,0,18)
    guiHint.Position = UDim2.new(0,5,1,-28)
    guiHint.BackgroundTransparency = 1
    guiHint.Text = getBindDisplay(binds.toggle_gui) .. " = " .. getText("Toggle GUI")
    guiHint.Font = Enum.Font.SourceSansBold
    guiHint.TextSize = 13
    guiHint.TextColor3 = Color3.fromRGB(200,200,255)
    guiHint.TextXAlignment = Enum.TextXAlignment.Center

    local function createStatus(y)
        local s = Instance.new("TextLabel", mainPage)
        s.Size = UDim2.new(0,110,0,20)
        s.Position = UDim2.new(1,-120,0,y)
        s.BackgroundTransparency = 1
        s.Font = Enum.Font.SourceSansBold
        s.TextSize = 13
        s.TextColor3 = Color3.fromRGB(255,0,0)
        s.TextXAlignment = Enum.TextXAlignment.Right
        return s
    end

    local stAimbot  = createStatus(2)
    local stESP     = createStatus(24)
    local stVis     = createStatus(46)
    local stFOV     = createStatus(68)
    local stDestroy = createStatus(90)
    local stUndo    = createStatus(112)

    local modeBtn = Instance.new("TextButton", mainPage)
    modeBtn.Size = UDim2.new(0,180,0,26)
    modeBtn.Position = UDim2.new(0.5, -90, 0, 132)
    modeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    modeBtn.Text = getText("Aim Mode") .. ": " .. aimMode:upper()
    modeBtn.Font = Enum.Font.Gotham
    modeBtn.TextSize = 14
    modeBtn.TextColor3 = Color3.fromRGB(255,255,255)

    modeBtn.MouseButton1Click:Connect(function()
        aimMode = aimMode == "Toggle" and "Hold" or "Toggle"
        modeBtn.Text = getText("Aim Mode") .. ": " .. aimMode:upper()
    end)

    local sliderLabel = Instance.new("TextLabel", mainPage)
    sliderLabel.Size = UDim2.new(0,180,0,20)
    sliderLabel.Position = UDim2.new(0,20,0,170)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = getText("Aimbot Range")
    sliderLabel.Font = Enum.Font.SourceSansBold
    sliderLabel.TextSize = 14
    sliderLabel.TextColor3 = Color3.fromRGB(255,255,255)
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local valueLabel = Instance.new("TextLabel", mainPage)
    valueLabel.Size = UDim2.new(0,80,0,20)
    valueLabel.Position = UDim2.new(0,210,0,170)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = math.floor(FOV_RADIUS)
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextSize = 13
    valueLabel.TextColor3 = Color3.fromRGB(200,200,200)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBg = Instance.new("Frame", mainPage)
    sliderBg.Size = UDim2.new(0,240,0,14)
    sliderBg.Position = UDim2.new(0,20,0,195)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,60)
    sliderBg.BorderSizePixel = 0

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((FOV_RADIUS - 50)/450, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0,200,120)

    local knob = Instance.new("TextButton", sliderBg)
    knob.Size = UDim2.new(0,12,0,14)
    knob.Position = UDim2.new((FOV_RADIUS - 50)/450, 0, 0, 0)
    knob.BackgroundColor3 = Color3.fromRGB(180,180,180)
    knob.Text = ""

    local dragging = false
    sliderBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    sliderBg.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    sliderBg.InputChanged:Connect(function(inp)
        if not dragging or inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local absPos  = sliderBg.AbsolutePosition
        local absSize = sliderBg.AbsoluteSize
        local x = math.clamp(inp.Position.X - absPos.X, 0, absSize.X)
        local ratio = x / absSize.X
        FOV_RADIUS = 50 + ratio * 450
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0, 0)
        valueLabel.Text = math.floor(FOV_RADIUS)
        fovCircle.Radius = FOV_RADIUS
    end)

    local keyItems = {
        {key = "aim",           name = "Aimbot"},
        {key = "toggle_esp",    name = "Toggle ESP"},
        {key = "visible_check", name = "Visible Check"},
        {key = "fov_circle",    name = "FOV Circle"},
        {key = "toggle_gui",    name = "Toggle GUI"},
        {key = "destroy",       name = "Destroy"},
        {key = "undo",          name = "Undo"},
    }

    for i, item in ipairs(keyItems) do
        local row = (i-1) * 32

        local label = Instance.new("TextLabel", keysPage)
        label.Size = UDim2.new(0.55, -10, 0, 26)
        label.Position = UDim2.new(0,12,0,row)
        label.BackgroundTransparency = 1
        label.Text = getText(item.name)
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", keysPage)
        btn.Size = UDim2.new(0.35, 0, 0, 26)
        btn.Position = UDim2.new(0.6, -12, 0, row)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.Text = getBindDisplay(binds[item.key])
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14

        btn.MouseButton1Click:Connect(function()
            btn.Text = currentLanguage == "PL" and "Naciśnij..." or "Press..."
            changingBind = item.key

            local conn; conn = UserInputService.InputBegan:Connect(function(inp, proc)
                if proc then return end
                local changed = false
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    binds[changingBind].inputType = "KeyCode"
                    binds[changingBind].value = inp.KeyCode
                    changed = true
                elseif inp.UserInputType.Name:match("MouseButton") then
                    binds[changingBind].inputType = "MouseButton"
                    binds[changingBind].value = inp.UserInputType
                    changed = true
                end
                if changed then
                    btn.Text = getBindDisplay(binds[changingBind])
                    changingBind = nil
                    conn:Disconnect()
                    createGUI()
                end
            end)
        end)
    end

    local drag, dragStart, startPos
    title.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = inp.Position
            startPos = panel.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            panel.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    title.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)

    task.spawn(function()
        while gui.Parent do
            local onText  = (currentLanguage == "PL") and "WŁĄCZONY" or "ON"
            local offText = (currentLanguage == "PL") and "WYŁĄCZONY" or "OFF"
            local naText  = (currentLanguage == "PL") and "N/D" or "N/A"

            local green = Color3.fromRGB(0, 255, 0)
            local red   = Color3.fromRGB(255, 0, 0)
            local gray  = Color3.fromRGB(150,150,150)

            stAimbot.Text  = aimLocked    and onText or offText
            stAimbot.TextColor3  = aimLocked    and green or red

            stESP.Text     = ESP_ENABLED  and onText or offText
            stESP.TextColor3     = ESP_ENABLED  and green or red

            stVis.Text     = VISIBLE_CHECK and onText or offText
            stVis.TextColor3     = VISIBLE_CHECK and green or red

            stFOV.Text     = fovCircle.Visible and onText or offText
            stFOV.TextColor3     = fovCircle.Visible and green or red

            stDestroy.Text = naText
            stDestroy.TextColor3 = gray

            stUndo.Text    = naText
            stUndo.TextColor3    = gray

            task.wait(0.1)
        end
    end)
end

createGUI()
