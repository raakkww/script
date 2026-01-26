-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyHackGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main window
local window = Instance.new("Frame")
window.Size = UDim2.new(0, 240, 0, 130)
window.Position = UDim2.new(0.5, -120, 0.5, -65)
window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
window.BorderSizePixel = 0
window.Active = true
window.Draggable = false -- We'll handle dragging manually for mobile support
window.Parent = screenGui

-- Title bar (for dragging - works on touch & mouse)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
titleBar.BorderSizePixel = 0
titleBar.Parent = window

-- Invisible drag pad (large touch area)
local dragPad = Instance.new("TextButton")
dragPad.Size = UDim2.new(1, 0, 1, 0)
dragPad.BackgroundTransparency = 1
dragPad.Text = ""
dragPad.AutoButtonColor = false
dragPad.Parent = titleBar

-- Title text
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💰 Money Hack"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.Text = "✕"
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.BorderSizePixel = 0
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Toggle button (larger for mobile)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "Toggle OFF"
toggleBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
toggleBtn.TextSize = 18
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = window

-- Credits
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 16)
credits.Position = UDim2.new(0, 0, 1, -16)
credits.BackgroundTransparency = 1
credits.Text = "NoHub - Noctyra"
credits.TextColor3 = Color3.fromRGB(120, 120, 140)
credits.TextSize = 12
credits.Font = Enum.Font.Gotham
credits.Parent = window

-- Rounded corners
local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

addCorner(window, 8)
addCorner(titleBar, 8)
addCorner(toggleBtn, 6)
addCorner(closeBtn, 6)

-- === Mobile + PC Drag System ===
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStart = nil
local startPos = nil

local function InputBegan(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
        input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = window.Position
    end
end

local function InputChanged(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or 
       input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end

local function InputEnded(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or 
        input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
    end
end

dragPad.InputBegan:Connect(InputBegan)
dragPad.InputChanged:Connect(InputChanged)
dragPad.InputEnded:Connect(InputEnded)

-- === Toggle Logic ===
local isEnabled = false
local moneyAmount = 10000

toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        toggleBtn.Text = "✅ ACTIVE"
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        toggleBtn.Text = "Toggle OFF"
        toggleBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    end
end)

-- === Auto Money Sender ===
spawn(function()
    while wait(0.5) do
        if isEnabled and workspace:FindFirstChild("Tycoons") then
            for _, child in ipairs(workspace.Tycoons:GetChildren()) do
                if child:FindFirstChild("Info") and child.Info:FindFirstChild("Owner") and
                   child.Info.Owner.Value == game.Players.LocalPlayer.Name and
                   child:FindFirstChild("Control") and child.Control:FindFirstChild("Money") then
                    pcall(function()
                        child.Control.Money:FireServer(moneyAmount)
                    end)
                end
            end
        end
    end
end)

print("✅ Money Hack by NoHub - Noctyra | Mobile & PC Ready")
