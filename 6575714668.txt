-- ⚡ Made By Old Scripts⚡

local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attack")

-- GUI SETUP
local gui = Instance.new("ScreenGui")
gui.Name = "FinalController"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 240) -- Aumentado para caber o novo botão
frame.Position = UDim2.new(0.4, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "⚡ Speedster Roleplay"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.Parent = frame

-- SPEED TEXTBOX (Limit 9999)
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.8, 0, 0, 35)
speedBox.Position = UDim2.new(0.1, 0, 0.15, 0)
speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
speedBox.PlaceholderText = "Velocidade (Máx 9999)..."
speedBox.Text = "9999"
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.Parent = frame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

-- SPEED BUTTON
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.8, 0, 0, 35)
speedBtn.Position = UDim2.new(0.1, 0, 0.34, 0)
speedBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
speedBtn.Text = "🚀 Apply Speed"
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 14
speedBtn.TextColor3 = Color3.new(1, 1, 1)
speedBtn.Parent = frame
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 10)

-- TELEPORT BUTTON
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.8, 0, 0, 35)
tpBtn.Position = UDim2.new(0.1, 0, 0.50, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
tpBtn.Text = "🌀 Teleport to Thug"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 14
tpBtn.TextColor3 = Color3.new(1, 1, 1)
tpBtn.Parent = frame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 10)

-- AUTO ATTACK BUTTON
local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(0.8, 0, 0, 40)
attackBtn.Position = UDim2.new(0.1, 0, 0.66, 0)
attackBtn.BackgroundColor3 = Color3.fromRGB(60, 170, 60) -- Verde (OFF)
attackBtn.Text = "⚔️ Auto Attack: OFF"
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 14
attackBtn.TextColor3 = Color3.new(1, 1, 1)
attackBtn.Parent = frame
Instance.new("UICorner", attackBtn).CornerRadius = UDim.new(0, 10)

-- STATUS
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0.85, 0)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Parent = frame

-----------------------------------------------------------
-- LOGIC
-----------------------------------------------------------

-- Function: Apply Speed with 9999 Limit
speedBtn.MouseButton1Click:Connect(function()
    local value = tonumber(speedBox.Text)
    
    if value then
        -- Trava de segurança: se for maior que 9999, volta para 9999
        if value > 9999 then
            value = 9999
            speedBox.Text = "9999"
        end
        
        local char = player.Character
        local speedScript = char and char:FindFirstChild("SuperSpeed", true)
        if speedScript then
            speedScript:SetAttribute("MAXIMUM_SPEED", value)
            status.Text = "✅ Speed set: "..value
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            status.Text = "❌ SuperSpeed não encontrado"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    else
        status.Text = "⚠️ Número inválido"
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

-- Function: Teleport NPC
tpBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local npcsFolder = workspace:FindFirstChild("NPCs")
    
    if hrp and npcsFolder then
        local nearestNPC = nil
        local shortestDist = math.huge
        
        for _, v in ipairs(npcsFolder:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                local npcRoot = v.HumanoidRootPart
                local npcHum = v:FindFirstChildOfClass("Humanoid")
                if npcHum and npcHum.Health > 0 then
                    local dist = (npcRoot.Position - hrp.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearestNPC = v
                    end
                end
            end
        end

        if nearestNPC then
            status.Text = "✅ Teleporting to: " .. nearestNPC.Name
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            local targetPos = nearestNPC.HumanoidRootPart.Position
            local dir = (targetPos - hrp.Position).Unit
            hrp.CFrame = CFrame.new(targetPos - dir * 5)
        else
            status.Text = "❌ Nenhum Thug encontrado"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    else
        status.Text = "❌ Erro: Personagem/Pasta NPCs"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Function: Auto Attack (Toggle)
local attackEnabled = false
attackBtn.MouseButton1Click:Connect(function()
    attackEnabled = not attackEnabled
    
    if attackEnabled then
        attackBtn.Text = "⚔️ Auto Attack: ON"
        attackBtn.BackgroundColor3 = Color3.fromRGB(170, 60, 60) -- Vermelho (ON)
        status.Text = "✅ Auto Attack Ligado"
        status.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        task.spawn(function()
            while attackEnabled do
                pcall(function()
                    AttackRemote:FireServer("M1")
                end)
                task.wait(0.2)
            end
        end)
    else
        attackBtn.Text = "⚔️ Auto Attack: OFF"
        attackBtn.BackgroundColor3 = Color3.fromRGB(60, 170, 60) -- Verde (OFF)
        status.Text = "❌ Auto Attack Desligado"
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- NOTIFICAÇÃO
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Made by Old Scripts";
    Text = "Script loaded";
    Icon = "rbxassetid://15794846967"; -- icone de virus so pra dar um pouco de susto kkkk
    Duration = 6;
    Button1 = "OK";
    Callback = callback;
})

-- Somzinho de carregado
task.spawn(function()
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://3023237993"
    s.Volume = 0.4
    s.Parent = game:GetService("SoundService")
    s:Play()
    task.delay(3, function() s:Destroy() end)
end)

print("[loaded]")
