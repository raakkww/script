do
    local Library =
        loadstring(game:HttpGet("https://raw.githubusercontent.com/noowtf31-ui/Arcylic/refs/heads/main/src.lua.txt"))()
    local window = Library.new("", "MyHubConfigs")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local CollectionService = game:GetService("CollectionService")
    local Lighting = game:GetService("Lighting")
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local VisualsSection = window:CreateSection("Visuals")
    local ChamsTab = VisualsSection:CreateTab("Chams", "rbxassetid://10709819149")
    local ESPTab = VisualsSection:CreateTab("ESP", "rbxassetid://10709819149")
    local WorldTab = VisualsSection:CreateTab("World", "rbxassetid://10709819149")
    local CrosshairTab = VisualsSection:CreateTab("Crosshair", "rbxassetid://104532559683365")
    local CombatSection = window:CreateSection("Combat")
    local HeadsTab = CombatSection:CreateTab("Heads", "rbxassetid://10709819149")
    ChamsTab:CreateSection("Visuals | Chams")
    ESPTab:CreateSection("Visuals | ESP")
    WorldTab:CreateSection("Visuals | World")
    CrosshairTab:CreateSection("Visuals | Crosshair")
    HeadsTab:CreateSection("Combat | Heads")
    local colorsEnabled = false
    local colorSettings = {Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255)}
    local distEnabled = false
    local distRainbow = false
    local distHue = 0
    local distSettings = {
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        TextOpacity = 1,
        Font = Enum.Font.RobotoMono,
        ShowStudsText = true
    }
    local bagsEnabled = false
    local bagRainbowEnabled = false
    local bagCurrentHue = 0
    local activeBags = {}
    local BagSettings = {
        FillColor = Color3.fromRGB(0, 255, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0
    }
    local fovEnabled = false
    local TARGET_FOV = 80
    local originalFOV = Camera.FieldOfView
    local chamsEnabled, rainbowEnabled, chamsOpacity, currentHue = false, false, 0.5, 0
    local chamsColor = Color3.fromRGB(255, 0, 0)
    local bigHeadsEnabled = false
    local headSize = 1
    local headChamsEnabled = false
    local headRainbowEnabled = false
    local headChamsOpacity = 0.5
    local headCurrentHue = 0
    local headChamsColor = Color3.fromRGB(0, 255, 0)
    local crosshairEnabled, crosshairRainbow, crosshairHue = false, false, 0
    local crosshairSettings = {
        color = Color3.fromRGB(255, 255, 255),
        thickness = 2,
        length = 8,
        opacity = 1,
        x_offset = 0,
        y_offset = 0
    }
    _G.FullBrightEnabled = false
    local function updateStimEffect()
        local stim = Lighting:FindFirstChild("StimEffect")
        if stim then
            stim.Enabled = colorsEnabled
            if colorsEnabled then
                stim.Brightness = colorSettings.Brightness
                stim.Contrast = colorSettings.Contrast
                stim.Saturation = colorSettings.Saturation
                stim.TintColor = colorSettings.TintColor
            end
        end
    end
    local lineX = Drawing.new("Line")
    local lineY = Drawing.new("Line")
    local function updateCrosshair()
        local center = Camera.ViewportSize / 2
        lineX.Visible = crosshairEnabled
        lineX.Color = crosshairSettings.color
        lineX.Thickness = crosshairSettings.thickness
        lineX.Transparency = crosshairSettings.opacity
        lineX.From =
            Vector2.new(
            (center.X - crosshairSettings.x_offset) - crosshairSettings.length,
            center.Y - crosshairSettings.y_offset
        )
        lineX.To =
            Vector2.new(
            (center.X - crosshairSettings.x_offset) + crosshairSettings.length,
            center.Y - crosshairSettings.y_offset
        )
        lineY.Visible = crosshairEnabled
        lineY.Color = crosshairSettings.color
        lineY.Thickness = crosshairSettings.thickness
        lineY.Transparency = crosshairSettings.opacity
        lineY.From =
            Vector2.new(
            center.X - crosshairSettings.x_offset,
            (center.Y - crosshairSettings.y_offset) - crosshairSettings.length
        )
        lineY.To =
            Vector2.new(
            center.X - crosshairSettings.x_offset,
            (center.Y - crosshairSettings.y_offset) + crosshairSettings.length
        )
    end
    local function getMyPos()
        local success, pos =
            pcall(
            function()
                local ignoreFolder = workspace:FindFirstChild("Const") and workspace.Const:FindFirstChild("Ignore")
                local localChar = ignoreFolder and ignoreFolder:FindFirstChild("LocalCharacter")
                if localChar then
                    local reference = localChar:FindFirstChild("Middle") or localChar:FindFirstChild("Top")
                    if reference then
                        return reference.Position
                    end
                end
                return nil
            end
        )
        return (success and pos) or nil
    end
    local function tagModel(model)
        if (model:IsA("Model") and model:FindFirstChild("HumanoidRootPart")) then
            if not CollectionService:HasTag(model, "ChamsTarget") then
                CollectionService:AddTag(model, "ChamsTarget")
            end
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        tagModel(obj)
    end
    Workspace.ChildAdded:Connect(tagModel)
    local function createDistanceTag(model)
        local enemyRoot = model:WaitForChild("HumanoidRootPart", 5) or model:WaitForChild("Torso", 5)
        if (not enemyRoot or (model == LocalPlayer.Character)) then
            return
        end
        if model:FindFirstChild("DistanceESP") then
            model.DistanceESP:Destroy()
        end
        local bbg = Instance.new("BillboardGui")
        bbg.Name = "DistanceESP"
        bbg.Adornee = enemyRoot
        bbg.Size = UDim2.new(0, 150, 0, 50)
        bbg.AlwaysOnTop = true
        bbg.StudsOffset = Vector3.new(0, -3.5, 0)
        bbg.Parent = model
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextColor3 = distSettings.TextColor
        label.TextTransparency = 1 - distSettings.TextOpacity
        label.TextSize = distSettings.TextSize
        label.Font = distSettings.Font
        label.TextStrokeTransparency = 0
        label.Text = ""
        label.Parent = bbg
        task.spawn(
            function()
                while bbg.Parent do
                    if distEnabled then
                        bbg.Enabled = true
                        local myPos = getMyPos()
                        if myPos then
                            local dist = (myPos - enemyRoot.Position).Magnitude
                            label.Text = math.floor(dist) .. ((distSettings.ShowStudsText and " Studs") or "")
                            label.TextColor3 = distSettings.TextColor
                            label.TextSize = distSettings.TextSize
                            label.TextTransparency = 1 - distSettings.TextOpacity
                        end
                    else
                        bbg.Enabled = false
                    end
                    task.wait(0.05)
                end
            end
        )
    end
    local function isTargetBag(model)
        if ((model.Name == "Model") and (#model:GetChildren() == 2)) then
            local p1 = model:FindFirstChild("Part")
            if (p1 and p1:IsA("BasePart")) then
                local s = p1.Size
                if ((s.Y < 3) and (s.X < 3) and (s.Z < 3)) then
                    return true
                end
            end
        end
        return false
    end
    local function updateBagProperties(hl)
        if hl then
            hl.FillColor = BagSettings.FillColor
            hl.FillTransparency = BagSettings.FillTransparency
            hl.OutlineColor = BagSettings.OutlineColor
            hl.OutlineTransparency = BagSettings.OutlineTransparency
        end
    end
    local function applyHighlight(model)
        if not bagsEnabled then
            if activeBags[model] then
                activeBags[model]:Destroy()
                activeBags[model] = nil
            end
            return
        end
        if isTargetBag(model) then
            task.defer(
                function()
                    if not model:IsDescendantOf(Workspace) then
                        return
                    end
                    local highlight = model:FindFirstChild("BagHighlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "BagHighlight"
                        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        highlight.Parent = model
                        model.AncestryChanged:Connect(
                            function(_, parent)
                                if not parent then
                                    activeBags[model] = nil
                                end
                            end
                        )
                    end
                    activeBags[model] = highlight
                    updateBagProperties(highlight)
                end
            )
        end
    end
    Workspace.DescendantAdded:Connect(
        function(descendant)
            if descendant:IsA("Model") then
                applyHighlight(descendant)
                if ((descendant.Name == "Model") and descendant:FindFirstChild("AnimationController")) then
                    createDistanceTag(descendant)
                end
            end
        end
    )
    local function refreshAllBags()
        if not bagsEnabled then
            for model, hl in pairs(activeBags) do
                if hl then
                    hl:Destroy()
                end
            end
            activeBags = {}
        else
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    applyHighlight(obj)
                end
            end
        end
    end
    ESPTab:CreateToggle(
        {Name = "Bags", Default = false, Callback = function(v)
                bagsEnabled = v
                refreshAllBags()
            end}
    )
    ESPTab:CreateToggle(
        {Name = "Rainbow Mode", Default = false, Callback = function(v)
                bagRainbowEnabled = v
            end}
    )
    ESPTab:CreateColorPicker(
        {Name = "Bag Color", Default = Color3.fromRGB(0, 255, 255), Callback = function(color)
                BagSettings.FillColor = color
                if not bagRainbowEnabled then
                    for _, hl in pairs(activeBags) do
                        hl.FillColor = color
                    end
                end
            end}
    )
    ESPTab:CreateSlider(
        {Name = "Opacity", Min = 0, Max = 100, Default = 50, Callback = function(v)
                local trans = 1 - (v / 100)
                BagSettings.FillTransparency = trans
                for _, hl in pairs(activeBags) do
                    hl.FillTransparency = trans
                end
            end}
    )
    ESPTab:CreateSection("Visuals | Distance")
    ESPTab:CreateToggle(
        {Name = "Distance", Default = false, Callback = function(v)
                distEnabled = v
            end}
    )
    ESPTab:CreateToggle(
        {Name = "Rainbow Mode", Default = false, Callback = function(v)
                distRainbow = v
            end}
    )
    ESPTab:CreateColorPicker(
        {Name = "Text Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(color)
                distSettings.TextColor = color
            end}
    )
    ESPTab:CreateSlider(
        {Name = "Opacity", Min = 0, Max = 100, Default = 100, Callback = function(v)
                distSettings.TextOpacity = v / 100
            end}
    )
    ESPTab:CreateSlider(
        {Name = "Size", Min = 10, Max = 50, Default = 18, Callback = function(v)
                distSettings.TextSize = v
            end}
    )
    WorldTab:CreateToggle(
        {Name = "Fullbright", Default = false, Callback = function(v)
                _G.FullBrightEnabled = v
            end}
    )
    WorldTab:CreateToggle(
        {
            Name = "Enable FOV",
            Default = false,
            Callback = function(v)
                fovEnabled = v
                if v then
                    RunService:BindToRenderStep(
                        "FOVLock",
                        201,
                        function()
                            Camera.FieldOfView = TARGET_FOV
                        end
                    )
                else
                    RunService:UnbindFromRenderStep("FOVLock")
                    Camera.FieldOfView = originalFOV
                end
            end
        }
    )
    WorldTab:CreateSlider(
        {Name = "Field of View", Min = 30, Max = 120, Default = 80, Callback = function(v)
                TARGET_FOV = v
            end}
    )
    WorldTab:CreateSection("Visuals | Colors")
    WorldTab:CreateToggle(
        {Name = "Enable Colors", Default = false, Callback = function(v)
                colorsEnabled = v
                updateStimEffect()
            end}
    )
    WorldTab:CreateSlider(
        {Name = "Brightness", Min = 0, Max = 50, Default = 0, Precise = true, Callback = function(v)
                colorSettings.Brightness = v
                updateStimEffect()
            end}
    )
    WorldTab:CreateSlider(
        {Name = "Contrast", Min = 0, Max = 50, Default = 0, Precise = true, Callback = function(v)
                colorSettings.Contrast = v
                updateStimEffect()
            end}
    )
    WorldTab:CreateSlider(
        {Name = "Saturation", Min = 0, Max = 50, Default = 0, Precise = true, Callback = function(v)
                colorSettings.Saturation = v
                updateStimEffect()
            end}
    )
    HeadsTab:CreateToggle(
        {Name = "Enable Big Heads", Default = false, Callback = function(v)
                bigHeadsEnabled = v
            end}
    )
    HeadsTab:CreateSlider(
        {Name = "Head Size", Min = 1, Max = 9, Default = 1, Callback = function(v)
                headSize = v
            end}
    )
    HeadsTab:CreateSection("Head Chams")
    HeadsTab:CreateToggle(
        {Name = "Enable Head Chams", Default = false, Callback = function(v)
                headChamsEnabled = v
            end}
    )
    HeadsTab:CreateToggle(
        {Name = "Rainbow Mode", Default = false, Callback = function(v)
                headRainbowEnabled = v
            end}
    )
    HeadsTab:CreateColorPicker(
        {Name = "Head Color", Default = Color3.fromRGB(0, 255, 0), Callback = function(color)
                headChamsColor = color
            end}
    )
    HeadsTab:CreateSlider(
        {Name = "Opacity", Min = 0, Max = 100, Default = 50, Callback = function(v)
                headChamsOpacity = v / 100
            end}
    )
    ChamsTab:CreateToggle(
        {Name = "Enable Chams", Default = false, Callback = function(v)
                chamsEnabled = v
            end}
    )
    ChamsTab:CreateToggle(
        {Name = "Rainbow Mode", Default = false, Callback = function(v)
                rainbowEnabled = v
            end}
    )
    ChamsTab:CreateColorPicker(
        {Name = "Chams Color", Default = Color3.fromRGB(255, 0, 0), Callback = function(color)
                chamsColor = color
            end}
    )
    ChamsTab:CreateSlider(
        {Name = "Opacity", Min = 0, Max = 100, Default = 50, Callback = function(v)
                chamsOpacity = v / 100
            end}
    )
    CrosshairTab:CreateToggle(
        {Name = "Toggle Crosshair", Default = false, Callback = function(v)
                crosshairEnabled = v
                updateCrosshair()
            end}
    )
    CrosshairTab:CreateToggle(
        {Name = "Rainbow Color", Default = false, Callback = function(v)
                crosshairRainbow = v
            end}
    )
    CrosshairTab:CreateColorPicker(
        {Name = "Crosshair Color", Default = Color3.fromRGB(255, 255, 255), Callback = function(c)
                crosshairSettings.color = c
                updateCrosshair()
            end}
    )
    CrosshairTab:CreateSlider(
        {Name = "Thickness", Min = 1, Max = 10, Default = 2, Callback = function(v)
                crosshairSettings.thickness = v
                updateCrosshair()
            end}
    )
    CrosshairTab:CreateSlider(
        {Name = "Length", Min = 1, Max = 50, Default = 8, Callback = function(v)
                crosshairSettings.length = v
                updateCrosshair()
            end}
    )
    CrosshairTab:CreateSlider(
        {Name = "Opacity", Min = 0, Max = 100, Default = 100, Callback = function(v)
                crosshairSettings.opacity = v / 100
                updateCrosshair()
            end}
    )
    RunService.Heartbeat:Connect(
        function(deltaTime)
            if _G.FullBrightEnabled then
                Lighting.Brightness, Lighting.ClockTime, Lighting.GlobalShadows = 2, 14, false
            end
            if crosshairRainbow then
                crosshairHue = (crosshairHue + (deltaTime * 0.5)) % 1
                crosshairSettings.color = Color3.fromHSV(crosshairHue, 1, 1)
            end
            if rainbowEnabled then
                currentHue = (currentHue + (deltaTime * 0.2)) % 1
                chamsColor = Color3.fromHSV(currentHue, 1, 1)
            end
            if headRainbowEnabled then
                headCurrentHue = (headCurrentHue + (deltaTime * 0.2)) % 1
                headChamsColor = Color3.fromHSV(headCurrentHue, 1, 1)
            end
            if (bagRainbowEnabled and bagsEnabled) then
                bagCurrentHue = (bagCurrentHue + (deltaTime * 0.2)) % 1
                local newColor = Color3.fromHSV(bagCurrentHue, 1, 1)
                BagSettings.FillColor = newColor
                for _, hl in pairs(activeBags) do
                    hl.FillColor = newColor
                end
            end
            if (distRainbow and distEnabled) then
                distHue = (distHue + (deltaTime * 0.2)) % 1
                distSettings.TextColor = Color3.fromHSV(distHue, 1, 1)
            end
            if crosshairEnabled then
                updateCrosshair()
            end
            for _, model in pairs(CollectionService:GetTagged("ChamsTarget")) do
                local head = model:FindFirstChild("Head")
                if head then
                    head.Size =
                        (bigHeadsEnabled and Vector3.new(headSize, headSize, headSize)) or Vector3.new(1.2, 1.2, 1.2)
                    head.CanCollide = not bigHeadsEnabled
                    local hHL = head:FindFirstChild("HeadCham")
                    if headChamsEnabled then
                        if not hHL then
                            hHL = Instance.new("Highlight", head)
                            hHL.Name = "HeadCham"
                            hHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        hHL.FillColor = headChamsColor
                        hHL.FillTransparency = 1 - headChamsOpacity
                    elseif hHL then
                        hHL:Destroy()
                    end
                end
                local uHL = model:FindFirstChild("UniversalCham")
                if chamsEnabled then
                    if not uHL then
                        uHL = Instance.new("Highlight", model)
                        uHL.Name = "UniversalCham"
                        uHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    end
                    uHL.FillColor = chamsColor
                    uHL.FillTransparency = 1 - chamsOpacity
                elseif uHL then
                    uHL:Destroy()
                end
            end
        end
    )
    for _, obj in ipairs(workspace:GetChildren()) do
        if ((obj.Name == "Model") and obj:IsA("Model") and obj:FindFirstChild("AnimationController")) then
            task.spawn(createDistanceTag, obj)
        end
    end
end
