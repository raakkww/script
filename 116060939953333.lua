--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local pGui = LP:WaitForChild("PlayerGui")

-- CONFIGURAÇÕES EXTREMAS
_G.AutoFarm = false
_G.AutoCollect = false
_G.AutoSell = false
_G.HitDelay = 0.01 
_G.PromptDelay = 0

-- WHITELIST DE REBIRTHS
local TreeLevels = {
    ["Carvalho"] = 0, ["Acácia"] = 3, ["Pinheiro"] = 5,
    ["Cogumelo"] = 7, ["Lava"] = 10, ["Lava Tree"] = 12
}

local function getRebirths()
    local stats = LP:FindFirstChild("leaderstats")
    return (stats and stats:FindFirstChild("Rebirths")) and stats.Rebirths.Value or 0
end

-- SISTEMA DE ARRASTAR UNIVERSAL (PC E CELULAR)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- GUI ESTILO V7
local ScreenGui = Instance.new("ScreenGui", pGui)
ScreenGui.Name = "LumberMaster_V11"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 30)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.25
MainFrame.AutomaticSize = Enum.AutomaticSize.Y
MainFrame.Active = true
Instance.new("UICorner", MainFrame)
local MS = Instance.new("UIStroke", MainFrame); MS.Thickness = 2; MS.Color = Color3.new(0,0,0)

local GuiScale = Instance.new("UIScale", MainFrame)

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 30); TitleBar.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, 0, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = ""; Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.FredokaOne; Title.TextSize = 13; Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
local TS = Instance.new("UIStroke", Title); TS.Thickness = 1.5

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 0, 0); Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1; Content.AutomaticSize = Enum.AutomaticSize.Y
local List = Instance.new("UIListLayout", Content); List.Padding = UDim.new(0, 6); List.HorizontalAlignment = 1

-- BOTÕES X / -
local function createTopBtn(txt, pos, col, func)
    local b = Instance.new("TextButton", TitleBar)
    b.Text = txt; b.Size = UDim2.new(0, 20, 0, 20); b.Position = pos
    b.BackgroundColor3 = col; b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
end

createTopBtn("X", UDim2.new(1, -25, 0, 5), Color3.fromRGB(150,0,0), function() ScreenGui:Destroy() end)
createTopBtn("-", UDim2.new(1, -50, 0, 5), Color3.fromRGB(50,50,50), function()
    _G.Min = not _G.Min
    Content.Visible = not _G.Min
    MainFrame.AutomaticSize = _G.Min and "None" or "Y"
    if _G.Min then MainFrame.Size = UDim2.new(0, 220, 0, 30) end
end)

-- TOGGLE
local function CreateToggle(name, sub, callback)
    local F = Instance.new("Frame", Content)
    F.Size = UDim2.new(0.95, 0, 0, 45); F.BackgroundColor3 = Color3.fromRGB(30, 30, 30); F.BackgroundTransparency = 0.5; Instance.new("UICorner", F)
    Instance.new("UIStroke", F).Color = Color3.new(0,0,0)

    local T = Instance.new("TextLabel", F)
    T.Text = name; T.Size = UDim2.new(0.7, 0, 0.5, 0); T.Position = UDim2.new(0, 8, 0, 5)
    T.TextColor3 = Color3.new(1,1,1); T.Font = Enum.Font.FredokaOne; T.TextSize = 11; T.BackgroundTransparency = 1; T.TextXAlignment = 0
    Instance.new("UIStroke", T).Color = Color3.new(0,0,0)

    local ST = Instance.new("TextLabel", F)
    ST.Text = sub; ST.Size = UDim2.new(0.7, 0, 0.4, 0); ST.Position = UDim2.new(0, 8, 0.45, 5)
    ST.TextColor3 = Color3.fromRGB(180,180,180); ST.Font = Enum.Font.SourceSans; ST.TextSize = 9; ST.BackgroundTransparency = 1; ST.TextXAlignment = 0

    local Sw = Instance.new("TextButton", F)
    Sw.Size = UDim2.new(0, 34, 0, 16); Sw.Position = UDim2.new(1, -42, 0.5, -8); Sw.BackgroundColor3 = Color3.fromRGB(50,50,50); Sw.Text = ""
    Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)
    
    local D = Instance.new("Frame", Sw)
    D.Size = UDim2.new(0, 12, 0, 12); D.Position = UDim2.new(0, 2, 0.5, -6); D.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", D)

    local act = false
    Sw.MouseButton1Click:Connect(function()
        act = not act
        TweenService:Create(D, TweenInfo.new(0.2), {Position = act and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
        Sw.BackgroundColor3 = act and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(50, 50, 50)
        callback(act)
    end)
end

-- SELETOR DE TAMANHO
local currentSize = 1
local sizeBtn = Instance.new("TextButton", Content)
sizeBtn.Size = UDim2.new(0.95, 0, 0, 30); sizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sizeBtn.TextColor3 = Color3.new(1, 1, 1); sizeBtn.Font = Enum.Font.FredokaOne; sizeBtn.TextSize = 10
sizeBtn.Text = "SIZE: SMALL"; Instance.new("UICorner", sizeBtn)
Instance.new("UIStroke", sizeBtn).Color = Color3.new(0,0,0)

sizeBtn.MouseButton1Click:Connect(function()
    if currentSize == 1 then
        currentSize = 1.5; GuiScale.Scale = 1.5; sizeBtn.Text = "SIZE: MEDIUM"
    elseif currentSize == 1.5 then
        currentSize = 2; GuiScale.Scale = 2; sizeBtn.Text = "SIZE: LARGE"
    else
        currentSize = 1; GuiScale.Scale = 1; sizeBtn.Text = "SIZE: SMALL"
    end
end)

-- AUTO FARM ROUBADO (0.01s)
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local reb = getRebirths()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Tronco" and obj:IsA("BasePart") and obj.Transparency == 0 then
                    local req = TreeLevels[obj.Parent.Name] or 0
                    if reb >= req then
                        local p = obj:FindFirstChildOfClass("ProximityPrompt") or obj.Parent:FindFirstChildOfClass("ProximityPrompt")
                        if p then
                            while _G.AutoFarm and obj.Transparency == 0 do
                                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                                    LP.Character.HumanoidRootPart.CFrame = obj.CFrame * CFrame.new(0,0,3)
                                    p.HoldDuration = _G.PromptDelay
                                    fireproximityprompt(p)
                                end
                                task.wait(_G.HitDelay)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO COLLECT INSTANTÂNEO (SEM DELAY)
task.spawn(function()
    while RunService.Heartbeat:Wait() do -- Usa Heartbeat para máxima velocidade
        if _G.AutoCollect then
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, d in ipairs(workspace:GetDescendants()) do
                    if d.Name:find("Drop") and d:IsA("BasePart") then
                        local b = d:FindFirstChildOfClass("BillboardGui")
                        local l = b and b:FindFirstChildOfClass("TextLabel")
                        if l and (l.Text:find(LP.Name) or l.Text:find(LP.DisplayName)) then
                            hrp.CFrame = d.CFrame
                            -- Não há task.wait() aqui para ser instantâneo
                        end
                    end
                end
            end
        end
    end
end)

-- AUTO SELL
task.spawn(function()
    while task.wait(1) do
        if _G.AutoSell then
            for _, m in ipairs(workspace:GetDescendants()) do
                if m.Name:find("SellButton") then
                    local p = m:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p and p.Parent:IsA("BasePart") then
                        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local old = hrp.CFrame
                            hrp.CFrame = p.Parent.CFrame
                            task.wait(0.2)
                            fireproximityprompt(p)
                            task.wait(0.1)
                            hrp.CFrame = old
                            break
                        end
                    end
                end
            end
        end
    end
end)

MakeDraggable(MainFrame)
CreateToggle("Auto Farm Logs", "", function(v) _G.AutoFarm = v end)
CreateToggle("Auto Collect Logs", "", function(v) _G.AutoCollect = v end)
CreateToggle("Auto Sell", "", function(v) _G.AutoSell = v end)
