local VioletSyn = {}
VioletSyn.Windows = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")


-- Notification Function
local function createNotification(text, duration)
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "VioletNotify"
    notifyGui.Parent = gui
    notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 60)
    frame.Position = UDim2.new(1, 10, 1, -10)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = notifyGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(93, 118, 203)
    stroke.Thickness = 2
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 18
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = frame

    frame.Position = UDim2.new(1, 350, 1, -10)
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 10, 1, -10)}):Play()

    task.delay(duration or 6, function()
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 350, 1, -10)}):Play()
        task.delay(0.5, function()
            notifyGui:Destroy()
        end)
    end)
end

-- Create Window
function VioletSyn:createWindow(options)
    options = options or {}
    local title = options.Title or "Violet Syn"


    createNotification("by @astromacc < telegram buy premium", 7)

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VioletSynGui"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = gui
screenGui.ResetOnSpawn = false
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 40)
    mainFrame.Position = UDim2.new(0.01, 0, 0.05, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(238, 196, 182)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.4
    mainStroke.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 17
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Discord Button
    local discordBtn = Instance.new("ImageButton")
    discordBtn.Size = UDim2.new(0, 30, 0, 30)
    discordBtn.Position = UDim2.new(1, -80, 0.5, -15)
    discordBtn.BackgroundTransparency = 1
    discordBtn.Image = "rbxassetid://9471409169"
    discordBtn.ImageColor3 = Color3.fromRGB(238, 196, 182)
    discordBtn.ScaleType = Enum.ScaleType.Fit
    discordBtn.Parent = titleBar

    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/Ty5r4A398J")
        createNotification("Discord link copied to clipboard!", 3)
    end)

    discordBtn.MouseEnter:Connect(function()
        discordBtn.ImageColor3 = Color3.new(1, 1, 1)
    end)
    discordBtn.MouseLeave:Connect(function()
        discordBtn.ImageColor3 = Color3.fromRGB(140, 100, 255)
    end)

    local arrowBtn = Instance.new("TextButton")
    arrowBtn.Size = UDim2.new(0, 40, 0, 40)
    arrowBtn.Position = UDim2.new(1, -40, 0, 0)
    arrowBtn.BackgroundTransparency = 1
    arrowBtn.Text = "⤵"
    arrowBtn.TextColor3 = Color3.fromRGB(238, 196, 182)
    arrowBtn.TextSize = 24
    arrowBtn.Font = Enum.Font.SourceSansBold
    arrowBtn.Parent = titleBar

    -- Scrolling Content
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 45)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(238, 196, 182)
    scrollingFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 15)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = scrollingFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.Parent = scrollingFrame

    -- Draggable (Mobile + PC)
    local dragging = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Open/Close Animation
    local isOpen = false
    arrowBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetSize = isOpen and UDim2.new(0, 220, 0, 420) or UDim2.new(0, 220, 0, 40)
        local targetArrow = isOpen and "⤴" or "⤵"

        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = targetSize}):Play()
        TweenService:Create(arrowBtn, TweenInfo.new(0.3), {Rotation = isOpen and 180 or 0}):Play()
        arrowBtn.Text = targetArrow

        if isOpen then
            scrollingFrame.CanvasPosition = Vector2.new(0, 0)
        end
    end)

    -- Elements
    local window = {}

    function window:createToggle(name, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 35)
        frame.BackgroundTransparency = 1
        frame.Parent = scrollingFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 16
        label.Font = Enum.Font.SourceSansSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 25)
        toggle.Position = UDim2.new(1, -50, 0.5, -12.5)
        toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        toggle.Text = ""
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggle

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 22, 0, 22)
        circle.Position = UDim2.new(0, 3, 0.5, -11)
        circle.BackgroundColor3 = Color3.new(1, 1, 1)
        circle.Parent = toggle
        circle.BackgroundTransparency = 0.5

        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle

        local state = false
        toggle.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(circle, TweenInfo.new(0.4), {Position = state and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)}):Play()
            TweenService:Create(toggle, TweenInfo.new(0.4), {BackgroundColor3 = state and Color3.fromRGB(238, 196, 182) or Color3.fromRGB(50, 50, 50)}):Play()
            if callback then callback(state) end
        end)
    end

    function window:createSlider(name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -20, 0, 60)
        frame.BackgroundTransparency = 1
        frame.Parent = scrollingFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 16
        label.Font = Enum.Font.SourceSansSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, 0, 0, 10)
        sliderBar.Position = UDim2.new(0, 0, 0, 30)
        sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderBar.Parent = frame

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 5)
        barCorner.Parent = sliderBar

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Color3.fromRGB(238, 196, 182)
        fill.Parent = sliderBar

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 5)
        fillCorner.Parent = fill

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, 0, 0, 20)
        valueLabel.Position = UDim2.new(0, 0, 0, 40)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        valueLabel.TextSize = 14
        valueLabel.Parent = frame

        local function updateValue(val)
            val = math.floor(val)
            local rel = (val - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(val)
            if callback then callback(val) end
        end

        updateValue(default or min)

        local dragging = false

        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)

        sliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                local clamped = math.clamp(relX, 0, 1)
                local value = min + (max - min) * clamped
                updateValue(value)
            end
        end)
    end

    function window:createButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        btn.BackgroundTransparency = 0.3
        btn.Text = name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 16
        btn.Font = Enum.Font.SourceSansSemibold
        btn.Parent = scrollingFrame
        btn.AutoButtonColor = false

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn

        

        btn.MouseButton1Click:Connect(callback or function() end)
    end

    -- Auto Canvas Size
    listLayout.Changed:Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 40)
    end)

    return window
end

return VioletSyn
