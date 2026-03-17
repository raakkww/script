-- Hide & Seek | @FindNulla0.2


if game.CoreGui:FindFirstChild("HideSeekHub") then
    game.CoreGui.HideSeekHub:Destroy()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- GUI PRINCIPAL (GUI PEQUENA E PERFEITA)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "Hide & SeekHub"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 409)            -- GUI PEQUENA E BONITA
Main.Position = UDim2.new(0.5, -130, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", Main)
UIStroke.Color = Color3.fromRGB(0, 255, 120)
UIStroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Hide & Seek"
Title.TextColor3 = Color3.fromRGB(0,255,120)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Main)
UIList.Padding = UDim.new(0, 5)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Top
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- BOTÃO TOGGLE (MENOR E LINDO)
local function createToggle(text, state, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.92, 0, 0, 32)        -- MENOR
    btn.Text = text.." [OFF]"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

    local toggleState = false
    btn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        btn.Text = text.." ["..(toggleState and "ON" or "OFF").."]"
        callback(toggleState)
    end)
end

-- BOTÃO NORMAL (MENOR)
local function createButton(text, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.92, 0, 0, 32)        -- MENOR
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
    btn.MouseButton1Click:Connect(callback)
end

-- TEXT NUMBER (MENOR E DENTRO DA GUI)
local function createNumber(name, default, callback)
    local Frame = Instance.new("Frame", Main)
    Frame.Size = UDim2.new(0.92, 0, 0, 32)      -- MENOR
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Box = Instance.new("TextBox", Frame)
    Box.Size = UDim2.new(1, -10, 1, 0)
    Box.Position = UDim2.new(0, 5, 0, 0)
    Box.PlaceholderText = name.." ("..default..")"
    Box.Text = ""
    Box.TextColor3 = Color3.new(1,1,1)
    Box.Font = Enum.Font.GothamBold
    Box.TextSize = 13
    Box.BackgroundTransparency = 1

    Box.FocusLost:Connect(function()
        local v = tonumber(Box.Text)
        if v and v > 0 then callback(v) end
    end)
end

-- TODAS AS FUNÇÕES 100% ORIGINAIS (NADA MUDOU AQUI)
createToggle("Ragdoll", false, function(state)
	local hum = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
	if state then
		hum:ChangeState(Enum.HumanoidStateType.FallingDown)
		hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	else
		hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

local enabled = false
local function StartAntiFling()
	enabled = true
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Connect(function()
		if not enabled or not hrp then return end
		local vel = hrp.Velocity
		local horiz = vel.X*vel.X + vel.Z*vel.Z
		if horiz > (humanoid.WalkSpeed*1.3)^2 then
			hrp.Velocity = Vector3.new(0, vel.Y, 0)
			hrp.RotVelocity = Vector3.new()
		end
	end)
end
createToggle("Disable Anti Fling System", false, function(v)
	if v then StartAntiFling() else enabled = false end
end)

createButton("Collect All Credits", function()
	for _, obj in workspace.GameObjects:GetDescendants() do
		if obj.Name == "Credit" or obj:FindFirstChild("TouchInterest") then
			local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
			if part then
				firetouchinterest(hrp, part, 0) task.wait()
				firetouchinterest(hrp, part, 1)
			end
		end
	end
end)

-- ESP IT (VERMELHO) - INDEPENDENTE
local ESP_IT_ENABLED = false
local ESP_IT_FOLDER = Instance.new("Folder")
ESP_IT_FOLDER.Name = "ESP_IT"
ESP_IT_FOLDER.Parent = workspace.CurrentCamera

local function createITBox(part)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = part.Size + Vector3.new(0.5, 0.5, 0.5)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.6
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = part
    box.Parent = ESP_IT_FOLDER
end

local function createITTag(head, name)
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 30)
    bill.AlwaysOnTop = true
    bill.Adornee = head
    bill.Parent = ESP_IT_FOLDER

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = name.." [IT]"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = bill
end

local function updateESPIT()
    if not ESP_IT_ENABLED then
        ESP_IT_FOLDER:ClearAllChildren()
        return
    end

    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local isIt = false
            pcall(function() isIt = plr.PlayerData.It.Value end)

            if isIt then
                createITBox(root)
                if head then createITTag(head, plr.DisplayName) end
            end
        end
    end
end

-- Toggle do seu botão
createToggle("ESP IT", false, function(state)
    ESP_IT_ENABLED = state
    updateESPIT()
end)

RunService.RenderStepped:Connect(updateESPIT)

-- ESP SEEK (VERDE) - INDEPENDENTE
local ESP_SEEK_ENABLED = false
local ESP_SEEK_FOLDER = Instance.new("Folder")
ESP_SEEK_FOLDER.Name = "ESP_SEEK"
ESP_SEEK_FOLDER.Parent = workspace.CurrentCamera

local function createSeekBox(part)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = part.Size + Vector3.new(0.5, 0.5, 0.5)
    box.Color3 = Color3.fromRGB(0, 255, 0)
    box.Transparency = 0.6
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = part
    box.Parent = ESP_SEEK_FOLDER
end

local function createSeekTag(head, name)
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 100, 0, 30)
    bill.AlwaysOnTop = true
    bill.Adornee = head
    bill.Parent = ESP_SEEK_FOLDER

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = name.." [SEEK]"
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = bill
end

local function updateESPSeek()
    if not ESP_SEEK_ENABLED then
        ESP_SEEK_FOLDER:ClearAllChildren()
        return
    end

    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local isIt = false
            pcall(function() isIt = plr.PlayerData.It.Value end)

            if not isIt then
                createSeekBox(root)
                if head then createSeekTag(head, plr.DisplayName) end
            end
        end
    end
end

-- Toggle do seu botão
createToggle("ESP SEEK", false, function(state)
    ESP_SEEK_ENABLED = state
    updateESPSeek()
end)

RunService.RenderStepped:Connect(updateESPSeek)

createButton("TeleKill (IT)", function()
	for _, plr in Players:GetPlayers() do
		if plr ~= player and plr.Character and plr.PlayerData.InGame.Value then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if root then
				hrp.CFrame = root.CFrame + Vector3.new(0, 3, 0)
				task.wait(0.1)
			end
		end
	end
end)

local currentSpeed = 100
local currentJump = 150

createToggle("Speed", false, function(state)
    humanoid.WalkSpeed = state and currentSpeed or 16
end)

createToggle("Jump", false, function(state)
    humanoid.JumpPower = state and currentJump or 50
end)

createNumber("Jump", 150, function(v) currentJump = v end)
createNumber("Speed", 100, function(v) currentSpeed = v end)

print("Hide & Seek Premium Hub carregado (GUI pequena e perfeita)!")
