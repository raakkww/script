local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- 1. LOADING SCREEN

local loadingGui = Instance.new("ScreenGui")

loadingGui.Name = "LoadingGUI"

loadingGui.Parent = player:WaitForChild("PlayerGui")

local darkOverlay = Instance.new("Frame")

darkOverlay.Size = UDim2.new(1, 0, 1, 0)

darkOverlay.Position = UDim2.new(0, 0, 0, 0)

darkOverlay.BackgroundColor3 = Color3.new(0, 0, 0)

darkOverlay.BackgroundTransparency = 0.6

darkOverlay.Parent = loadingGui

local loadingFrame = Instance.new("Frame")

loadingFrame.Size = UDim2.new(0, 300, 0, 120)

loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -60)

loadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

loadingFrame.BackgroundTransparency = 0.1

loadingFrame.Parent = loadingGui

local loadCorner = Instance.new("UICorner")

loadCorner.CornerRadius = UDim.new(0, 12)

loadCorner.Parent = loadingFrame

local loadStroke = Instance.new("UIStroke")

loadStroke.Color = Color3.fromRGB(100, 100, 100)

loadStroke.Thickness = 2

loadStroke.Parent = loadingFrame

local loadText = Instance.new("TextLabel")

loadText.Text = "LOADING SCRIPT"

loadText.Size = UDim2.new(1, 0, 0, 40)

loadText.Position = UDim2.new(0, 0, 0, 10)

loadText.BackgroundTransparency = 1

loadText.TextColor3 = Color3.fromRGB(220, 220, 255)

loadText.Font = Enum.Font.GothamBold

loadText.TextSize = 16

loadText.Parent = loadingFrame

local dotsLabel = Instance.new("TextLabel")

dotsLabel.Text = ""

dotsLabel.Size = UDim2.new(1, 0, 0, 30)

dotsLabel.Position = UDim2.new(0, 0, 0, 50)

dotsLabel.BackgroundTransparency = 1

dotsLabel.TextColor3 = Color3.fromRGB(0, 200, 255)

dotsLabel.Font = Enum.Font.GothamBold

dotsLabel.TextSize = 24

dotsLabel.Parent = loadingFrame

local currentDots = 0

local maxDots = 3

local dotsDirection = 1

-- 2. NOTEBOOK MENU (STYLISH VERSION)

local function showNotebook()

    local notebookGui = Instance.new("ScreenGui")

    notebookGui.Name = "NotebookGUI"

    notebookGui.Parent = player:WaitForChild("PlayerGui")

    

    local notebook = Instance.new("Frame")

    notebook.Size = UDim2.new(0, 400, 0, 280) -- Увеличил высоту до 280

    notebook.Position = UDim2.new(0.5, -200, 0.5, -140)

    notebook.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

    notebook.BackgroundTransparency = 0.15

    notebook.Parent = notebookGui

    

    local notebookCorner = Instance.new("UICorner")

    notebookCorner.CornerRadius = UDim.new(0, 12)

    notebookCorner.Parent = notebook

    

    local notebookStroke = Instance.new("UIStroke")

    notebookStroke.Color = Color3.fromRGB(80, 120, 50)

    notebookStroke.Thickness = 3

    notebookStroke.Transparency = 0.3

    notebookStroke.Parent = notebook

    

    -- Gradient background

    local gradient = Instance.new("UIGradient")

    gradient.Color = ColorSequence.new({

        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),

        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))

    })

    gradient.Parent = notebook

    

    -- Glow effect

    local glow = Instance.new("ImageLabel")

    glow.Image = "rbxassetid://5554236805"

    glow.Size = UDim2.new(1, 20, 1, 20)

    glow.Position = UDim2.new(0, -10, 0, -10)

    glow.BackgroundTransparency = 1

    glow.ImageColor3 = Color3.fromRGB(60, 90, 180)

    glow.ImageTransparency = 0.8

    glow.Parent = notebook

    

    local title = Instance.new("TextLabel")

    title.Text = "📓 GAME GUIDE"

    title.Size = UDim2.new(1, 0, 0, 50)

    title.Position = UDim2.new(0, 0, 0, 0)

    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    title.BackgroundTransparency = 0.3

    title.TextColor3 = Color3.fromRGB(220, 220, 255)

    title.Font = Enum.Font.GothamBold

    title.TextSize = 22

    title.Parent = notebook

    

    local titleCorner = Instance.new("UICorner")

    titleCorner.CornerRadius = UDim.new(0, 12)

    titleCorner.Parent = title

    

    local contentFrame = Instance.new("Frame")

    contentFrame.Size = UDim2.new(0.9, 0, 0, 150) -- Уменьшил высоту контента до 150

    contentFrame.Position = UDim2.new(0.05, 0, 0, 60)

    contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

    contentFrame.BackgroundTransparency = 0.4

    contentFrame.Parent = notebook

    

    local contentCorner = Instance.new("UICorner")

    contentCorner.CornerRadius = UDim.new(0, 8)

    contentCorner.Parent = contentFrame

    

    local noteText = Instance.new("TextLabel")

    noteText.Text = "🎮 IN THIS GAME:\n\n💰 HOW TO GET CROWNS:\n1. Click on the COIN in the top right corner\n2. Select 'Convert to crowns' option\n3. Confirm the exchange\n"

    noteText.Size = UDim2.new(0.95, 0, 0.95, 0)

    noteText.Position = UDim2.new(0.025, 0, 0.025, 0)

    noteText.BackgroundTransparency = 1

    noteText.TextColor3 = Color3.fromRGB(220, 220, 240)

    noteText.Font = Enum.Font.Gotham

    noteText.TextSize = 14

    noteText.TextXAlignment = Enum.TextXAlignment.Left

    noteText.TextYAlignment = Enum.TextYAlignment.Top

    noteText.TextWrapped = true

    noteText.Parent = contentFrame

    

    local openScriptBtn = Instance.new("TextButton")

    openScriptBtn.Text = "📂 OPEN SCRIPT"

    openScriptBtn.Size = UDim2.new(0, 200, 0, 45)

    openScriptBtn.Position = UDim2.new(0.5, -100, 1, -55)

    openScriptBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)

    openScriptBtn.BackgroundTransparency = 0.1

    openScriptBtn.TextColor3 = Color3.new(1, 1, 1)

    openScriptBtn.Font = Enum.Font.GothamBold

    openScriptBtn.TextSize = 16

    openScriptBtn.Parent = notebook

    

    local openCorner = Instance.new("UICorner")

    openCorner.CornerRadius = UDim.new(0, 10)

    openCorner.Parent = openScriptBtn

    

    local openStroke = Instance.new("UIStroke")

    openStroke.Color = Color3.fromRGB(100, 160, 255)

    openStroke.Thickness = 2

    openStroke.Parent = openScriptBtn

    

    local closeNotebook = Instance.new("TextButton")

    closeNotebook.Text = "X"

    closeNotebook.Size = UDim2.new(0, 35, 0, 35)

    closeNotebook.Position = UDim2.new(1, -40, 0, 8)

    closeNotebook.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

    closeNotebook.BackgroundTransparency = 0.1

    closeNotebook.TextColor3 = Color3.new(1, 1, 1)

    closeNotebook.Font = Enum.Font.GothamBold

    closeNotebook.TextSize = 18

    closeNotebook.Parent = notebook

    

    local closeCorner = Instance.new("UICorner")

    closeCorner.CornerRadius = UDim.new(0, 8)

    closeCorner.Parent = closeNotebook

    

    local closeStroke = Instance.new("UIStroke")

    closeStroke.Color = Color3.fromRGB(255, 100, 100)

    closeStroke.Thickness = 2

    closeStroke.Parent = closeNotebook

    

    -- 3. LOAD AUTO FARM SCRIPT FROM PASTEFY

    local function loadAutoFarmScript()

        notebookGui:Destroy()

        

        local success, errorMessage = pcall(function()

            loadstring(game:HttpGet("https://pastefy.app/hy0jaOPr/raw"))()

        end)

        

        if not success then

            local errorGui = Instance.new("ScreenGui")

            errorGui.Parent = player:WaitForChild("PlayerGui")

            

            local errorFrame = Instance.new("Frame")

            errorFrame.Size = UDim2.new(0, 300, 0, 150)

            errorFrame.Position = UDim2.new(0.5, -150, 0.5, -75)

            errorFrame.BackgroundColor3 = Color3.fromRGB(50, 30, 30)

            errorFrame.Parent = errorGui

            

            local errorText = Instance.new("TextLabel")

            errorText.Text = "ERROR LOADING SCRIPT\n\n" .. errorMessage

            errorText.Size = UDim2.new(1, -20, 1, -20)

            errorText.Position = UDim2.new(0, 10, 0, 10)

            errorText.BackgroundTransparency = 1

            errorText.TextColor3 = Color3.new(1, 0.5, 0.5)

            errorText.Font = Enum.Font.Code

            errorText.TextSize = 12

            errorText.TextWrapped = true

            errorText.Parent = errorFrame

            

            local closeBtn = Instance.new("TextButton")

            closeBtn.Text = "CLOSE"

            closeBtn.Size = UDim2.new(0, 100, 0, 40)

            closeBtn.Position = UDim2.new(0.5, -50, 1, -50)

            closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

            closeBtn.TextColor3 = Color3.new(1, 1, 1)

            closeBtn.Parent = errorFrame

            

            closeBtn.MouseButton1Click:Connect(function()

                errorGui:Destroy()

            end)

        end

    end

    

    -- Button events

    openScriptBtn.MouseButton1Click:Connect(function()

        loadAutoFarmScript()

    end)

    

    closeNotebook.MouseButton1Click:Connect(function()

        loadAutoFarmScript()

    end)

    

    -- Hover effects

    openScriptBtn.MouseEnter:Connect(function()

        openScriptBtn.BackgroundColor3 = Color3.fromRGB(90, 150, 230)

    end)

    

    openScriptBtn.MouseLeave:Connect(function()

        openScriptBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)

    end)

    

    closeNotebook.MouseEnter:Connect(function()

        closeNotebook.BackgroundColor3 = Color3.fromRGB(220, 80, 80)

    end)

    

    closeNotebook.MouseLeave:Connect(function()

        closeNotebook.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

    end)

end

-- Loading animation

spawn(function()

    for i = 1, 4 do

        wait(0.5)

        

        if dotsDirection == 1 then

            currentDots = currentDots + 1

            if currentDots >= maxDots then

                dotsDirection = -1

            end

        else

            currentDots = currentDots - 1

            if currentDots <= 0 then

                dotsDirection = 1

            end

        end

        

        local dots = ""

        for i = 1, currentDots do

            dots = dots .. "."

        end

        dotsLabel.Text = dots

    end

    

    wait(0.5)

    loadingGui:Destroy()

    showNotebook()

end)
