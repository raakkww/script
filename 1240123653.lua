local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Player = Players.LocalPlayer
local PlayerName = Player.Name
local PlayerId = Player.UserId

if CoreGui:FindFirstChild("SarpasteZombieHUD") then CoreGui.SarpasteZombieHUD:Destroy() end
if CoreGui:FindFirstChild("UserProfileGUI") then CoreGui.UserProfileGUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SarpasteZombieHUD"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.02, 0, 0.05, 0) 
MainFrame.Size = UDim2.new(0, 220, 0, 185)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel") 
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1.000
TitleLabel.Position = UDim2.new(0.02, 0, 0.05, 0) 
TitleLabel.Size = UDim2.new(0.75, 0, 0, 20)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Zombie Attack Script Autofarm"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13.000 

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
MinimizeButton.Position = UDim2.new(0.85, 0, 0.07, 0) 
MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
MinimizeButton.Font = Enum.Font.SourceSans
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 18.000
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", MinimizeButton).Color = Color3.fromRGB(150, 190, 255)

local NameLabel = Instance.new("TextLabel")
NameLabel.Name = "NameLabel"
NameLabel.Parent = MainFrame
NameLabel.BackgroundTransparency = 1.000
NameLabel.Position = UDim2.new(0, 0, 0.2, 0)
NameLabel.Size = UDim2.new(1, 0, 0, 20)
NameLabel.Font = Enum.Font.GothamBold
NameLabel.Text = "SARPASTES"
NameLabel.TextColor3 = Color3.fromRGB(80, 160, 255)
NameLabel.TextSize = 18.000

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "AutofarmButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ToggleButton.Position = UDim2.new(0.05, 0, 0.35, 0)
ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Text = "Autofarm [OFF]"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14.000
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 6)
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = ToggleButton
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 1

local AfkLoaderButton = Instance.new("TextButton")
AfkLoaderButton.Name = "AfkLoaderButton"
AfkLoaderButton.Parent = MainFrame
AfkLoaderButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0) 
AfkLoaderButton.Position = UDim2.new(0.05, 0, 0.6, 0)
AfkLoaderButton.Size = UDim2.new(0.9, 0, 0, 35)
AfkLoaderButton.Font = Enum.Font.GothamSemibold
AfkLoaderButton.Text = "Run Anti-AFK Loader (Press Once)"
AfkLoaderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AfkLoaderButton.TextSize = 12.000
Instance.new("UICorner", AfkLoaderButton).CornerRadius = UDim.new(0, 6)
local AfkStroke = Instance.new("UIStroke")
AfkStroke.Parent = AfkLoaderButton
AfkStroke.Color = Color3.fromRGB(255, 200, 100)
AfkStroke.Thickness = 1

local afkLoaderRan = false
AfkLoaderButton.MouseButton1Click:Connect(function()
    if not afkLoaderRan then
        loadstring(game:HttpGet("https://pastefy.app/sknpkzZB/raw", true))()
        afkLoaderRan = true
        AfkLoaderButton.Text = "Anti-AFK Loaded!"
        AfkLoaderButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0) 
        AfkLoaderButton:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(0, 200, 0)
    end
end)

local ProfileToggleButton = Instance.new("TextButton")
ProfileToggleButton.Name = "ProfileToggleButton"
ProfileToggleButton.Parent = MainFrame
ProfileToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProfileToggleButton.Position = UDim2.new(0.05, 0, 0.85, 0)
ProfileToggleButton.Size = UDim2.new(0.9, 0, 0, 25)
ProfileToggleButton.Font = Enum.Font.GothamSemibold
ProfileToggleButton.Text = "Show User Profile"
ProfileToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileToggleButton.TextSize = 12.000
Instance.new("UICorner", ProfileToggleButton).CornerRadius = UDim.new(0, 6)

-- USER PROFILE GUI
local UserProfileGUI = Instance.new("ScreenGui")
UserProfileGUI.Name = "UserProfileGUI"
UserProfileGUI.Parent = CoreGui
UserProfileGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UserProfileGUI.Enabled = false 

local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Parent = UserProfileGUI
ProfileFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProfileFrame.Position = UDim2.new(0.5, -110, 0.5, -60)
ProfileFrame.Size = UDim2.new(0, 220, 0, 120)
ProfileFrame.Active = true
ProfileFrame.Draggable = true
Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 10)

local ProfileTitle = Instance.new("TextLabel")
ProfileTitle.Name = "ProfileTitle"
ProfileTitle.Parent = ProfileFrame
ProfileTitle.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
ProfileTitle.Position = UDim2.new(0, 0, 0, 0)
ProfileTitle.Size = UDim2.new(1, 0, 0, 25)
ProfileTitle.Font = Enum.Font.GothamBold
ProfileTitle.Text = "PLAYER PROFILE"
ProfileTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileTitle.TextSize = 16.000
Instance.new("UICorner", ProfileTitle).CornerRadius = UDim.new(0, 10)

local ProfileName = Instance.new("TextLabel")
ProfileName.Name = "ProfileName"
ProfileName.Parent = ProfileFrame
ProfileName.BackgroundTransparency = 1.000
ProfileName.Position = UDim2.new(0, 0, 0.3, 0)
ProfileName.Size = UDim2.new(1, 0, 0, 20)
ProfileName.Font = Enum.Font.SourceSansSemibold
ProfileName.Text = "Username: " .. PlayerName
ProfileName.TextColor3 = Color3.fromRGB(200, 200, 200)
ProfileName.TextSize = 14.000

local ProfileId = Instance.new("TextLabel")
ProfileId.Name = "ProfileId"
ProfileId.Parent = ProfileFrame
ProfileId.BackgroundTransparency = 1.000
ProfileId.Position = UDim2.new(0, 0, 0.5, 0)
ProfileId.Size = UDim2.new(1, 0, 0, 20)
ProfileId.Font = Enum.Font.SourceSansSemibold
ProfileId.Text = "User ID: " .. tostring(PlayerId)
ProfileId.TextColor3 = Color3.fromRGB(200, 200, 200)
ProfileId.TextSize = 14.000

local ProfileClose = Instance.new("TextButton")
ProfileClose.Name = "ProfileClose"
ProfileClose.Parent = ProfileFrame
ProfileClose.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
ProfileClose.Position = UDim2.new(0.1, 0, 0.75, 0)
ProfileClose.Size = UDim2.new(0.8, 0, 0, 25)
ProfileClose.Font = Enum.Font.GothamSemibold
ProfileClose.Text = "Close"
ProfileClose.TextColor3 = Color3.fromRGB(255, 255, 255)
ProfileClose.TextSize = 14.000
Instance.new("UICorner", ProfileClose).CornerRadius = UDim.new(0, 6)

-- LOGIC

ProfileToggleButton.MouseButton1Click:Connect(function()
    UserProfileGUI.Enabled = not UserProfileGUI.Enabled
end)

ProfileClose.MouseButton1Click:Connect(function()
    UserProfileGUI.Enabled = false
end)

_G.farm2 = false 
local groundDistance = 8

local function getNearest()
    local nearest, dist = nil, 99999
    
    for _, v in pairs(Workspace.BossFolder:GetChildren()) do
        if v:FindFirstChild("Head") then
            local m = (Player.Character.Head.Position - v.Head.Position).magnitude
            if m < dist then
                dist = m
                nearest = v
            end
        end
    end
    
    for _, v in pairs(Workspace.enemies:GetChildren()) do
        if v:FindFirstChild("Head") then
            local m = (Player.Character.Head.Position - v.Head.Position).magnitude
            if m < dist then
                dist = m
                nearest = v
            end
        end
    end
    
    return nearest
end

_G.globalTarget = nil

RunService.RenderStepped:Connect(function()
    if _G.farm2 and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local target = getNearest()
        if target ~= nil and target:FindFirstChild("Head") and target:FindFirstChild("HumanoidRootPart") then
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.p, target.Head.Position)
            Player.Character.HumanoidRootPart.CFrame = (target.HumanoidRootPart.CFrame * CFrame.new(0, groundDistance, 9))
            _G.globalTarget = target
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if _G.farm2 and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            if Player.Character:FindFirstChild("Torso") then
                Player.Character.Torso.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if _G.farm2 and _G.globalTarget ~= nil and _G.globalTarget:FindFirstChild("Head") and Player.Character then
            local tool = Player.Character:FindFirstChildOfClass("Tool")
            if tool then
                local target = _G.globalTarget
                game.ReplicatedStorage.Gun:FireServer({
                    ["Normal"] = Vector3.new(0, 0, 0),
                    ["Direction"] = target.Head.Position,
                    ["Name"] = tool.Name,
                    ["Hit"] = target.Head,
                    ["Origin"] = target.Head.Position,
                    ["Pos"] = target.Head.Position,
                })
            end
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    _G.farm2 = not _G.farm2 
    
    if _G.farm2 then
        ToggleButton.Text = "Autofarm [ON]"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        ToggleButton:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "Autofarm [OFF]"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ToggleButton:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(60, 60, 60)
    end
end)

local isMinimized = false
local defaultSize = UDim2.new(0, 220, 0, 185) 
local minimizedSize = UDim2.new(0, 220, 0, 35) 

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized

    if isMinimized then
        MainFrame:TweenSize(minimizedSize, "Out", "Quad", 0.2, true)
        ToggleButton.Visible = false
        AfkLoaderButton.Visible = false
        ProfileToggleButton.Visible = false 
        NameLabel.Visible = false
        TitleLabel.Position = UDim2.new(0.02, 0, 0, 0) 
        MinimizeButton.Text = "[]"
    else
        MainFrame:TweenSize(defaultSize, "Out", "Quad", 0.2, true)
        ToggleButton.Visible = true
        AfkLoaderButton.Visible = true
        ProfileToggleButton.Visible = true 
        NameLabel.Visible = true
        TitleLabel.Position = UDim2.new(0.02, 0, 0.05, 0) 
        MinimizeButton.Text = "_"
    end
end)
