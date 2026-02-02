local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui", 10)

-- Ремоуты
local toyRemote = RS:WaitForChild("Menu"):WaitForChild("SpawnToyRemoteFunction")
local remoteOwner = RS:WaitForChild("GrabEvents"):WaitForChild("SetOwnerNetwork")
local remoteStruggle = RS:WaitForChild("GrabEvents"):WaitForChild("Struggle")
local toyFolder = workspace:WaitForChild("DirizandiSpawnedInToys")

-- Логика
local targetMode = nil
local TargetPlayers = {}
local isSpamming = false
local VortexEnabled = false
local isCleaning = true
local angle = 0
local VortexDistance = 25
local MAX_SPAM_DISTANCE = 35

-- --- ИНТЕРФЕЙС ---
local ScreenGui = Instance.new("ScreenGui", pGui)
ScreenGui.Name = "Tabbed_Hack_RU_Photo"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 480)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Вкладки
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", TabBar)

-- КНОПКА ЗАКРЫТЬ
local CloseBtn = Instance.new("TextButton", TabBar)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.Text = "×"
CloseBtn.TextSize = 30
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local OwnerTabBtn = Instance.new("TextButton", TabBar)
OwnerTabBtn.Size = UDim2.new(0.4, 0, 1, 0)
OwnerTabBtn.Text = "OWNER"
OwnerTabBtn.TextSize = 18
OwnerTabBtn.Font = Enum.Font.SourceSansBold
OwnerTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OwnerTabBtn.TextColor3 = Color3.new(1, 1, 1)

local SpamTabBtn = Instance.new("TextButton", TabBar)
SpamTabBtn.Size = UDim2.new(0.4, 0, 1, 0)
SpamTabBtn.Position = UDim2.new(0.4, 0, 0, 0)
SpamTabBtn.Text = "SPAM"
SpamTabBtn.TextSize = 18
SpamTabBtn.Font = Enum.Font.SourceSansBold
SpamTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpamTabBtn.TextColor3 = Color3.new(0.7, 0.7, 0.7)

-- Заголовок
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0.11, 0)
Title.Text = "TARGET: NOT SELECTED"
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.TextColor3 = Color3.new(1, 1, 0.4)
Title.BackgroundTransparency = 1

-- Список игроков
local PlayerList = Instance.new("ScrollingFrame", MainFrame)
PlayerList.Size = UDim2.new(0.9, 0, 0, 130)
PlayerList.Position = UDim2.new(0.05, 0, 0.18, 0)
PlayerList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
local UIList = Instance.new("UIListLayout", PlayerList)
UIList.Padding = UDim.new(0, 3)

-- Контейнеры
local OwnerContent = Instance.new("Frame", MainFrame)
OwnerContent.Size = UDim2.new(1, 0, 0.5, 0)
OwnerContent.Position = UDim2.new(0, 0, 0.48, 0)
OwnerContent.BackgroundTransparency = 1

local SpamContent = Instance.new("Frame", MainFrame)
SpamContent.Size = UDim2.new(1, 0, 0.5, 0)
SpamContent.Position = UDim2.new(0, 0, 0.48, 0)
SpamContent.BackgroundTransparency = 1
SpamContent.Visible = false

local function style(btn, color, text, parent)
	btn.Size = UDim2.new(0.9, 0, 0, 42)
	btn.Text = text
	btn.TextSize = 20
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.BorderSizePixel = 0
	btn.Parent = parent
	Instance.new("UICorner", btn)
end

local UIListOwner = Instance.new("UIListLayout", OwnerContent)
UIListOwner.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListOwner.Padding = UDim.new(0, 8)

local UIListSpam = Instance.new("UIListLayout", SpamContent)
UIListSpam.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListSpam.Padding = UDim.new(0, 8)

-- Кнопки ВЛАДЕЛЕЦ
local SelectAllBtn = Instance.new("TextButton")
style(SelectAllBtn, Color3.fromRGB(0, 90, 150), "SELECT ALL", OwnerContent)
local TeleportBtn = Instance.new("TextButton")
style(TeleportBtn, Color3.fromRGB(150, 100, 0), "TELEPORT TO ME", OwnerContent)
local StartVortexBtn = Instance.new("TextButton")
style(StartVortexBtn, Color3.fromRGB(0, 120, 0), "TURN ON VORTEX", OwnerContent)
local StopVortexBtn = Instance.new("TextButton")
style(StopVortexBtn, Color3.fromRGB(120, 0, 0), "TURN OFF THE VORTEX," OwnerContent)

-- Кнопки СПАМ
local OptBtn = Instance.new("TextButton")
style(OptBtn, Color3.fromRGB(60, 60, 60), "CLEANING: ON", SpamContent)
local StartSpamBtn = Instance.new("TextButton")
style(StartSpamBtn, Color3.fromRGB(0, 120, 0), "START SPAM", SpamContent)
local StopSpamBtn = Instance.new("TextButton")
style(StopSpamBtn, Color3.fromRGB(120, 0, 0), "STOP SPAM", SpamContent)

-- Вкладки Логика
OwnerTabBtn.MouseButton1Click:Connect(function()
	OwnerContent.Visible = true; SpamContent.Visible = false
	OwnerTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); OwnerTabBtn.TextColor3 = Color3.new(1,1,1)
	SpamTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); SpamTabBtn.TextColor3 = Color3.new(0.7,0.7,0.7)
end)
SpamTabBtn.MouseButton1Click:Connect(function()
	OwnerContent.Visible = false; SpamContent.Visible = true
	SpamTabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); SpamTabBtn.TextColor3 = Color3.new(1,1,1)
	OwnerTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); OwnerTabBtn.TextColor3 = Color3.new(0.7,0.7,0.7)
end)

local function updateList()
	for _, v in pairs(PlayerList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local b = Instance.new("TextButton", PlayerList)
			b.Size = UDim2.new(1, 0, 0, 35)
			b.Text = "      " .. p.DisplayName
			b.BackgroundColor3 = TargetPlayers[p.Name] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(35, 35, 35)
			b.TextColor3 = Color3.new(1, 1, 1)
			b.TextSize = 16
			b.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UICorner", b)
			
			local Photo = Instance.new("ImageLabel", b)
			Photo.Size = UDim2.new(0, 28, 0, 28)
			Photo.Position = UDim2.new(0, 4, 0.5, -14)
			Photo.BackgroundTransparency = 1
			Photo.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			Instance.new("UICorner", Photo).CornerRadius = UDim.new(1, 0)

			b.MouseButton1Click:Connect(function()
				TargetPlayers = {[p.Name] = true}; targetMode = p
				Title.Text = "ЦЕЛЬ: " .. p.Name:upper(); updateList()
			end)
		end
	end
end
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

RunService.Heartbeat:Connect(function()
	pcall(function() remoteStruggle:FireServer() end)
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	for name, _ in pairs(TargetPlayers) do
		local p = Players:FindFirstChild(name)
		local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if tr then
			if (myRoot.Position - tr.Position).Magnitude <= MAX_SPAM_DISTANCE then
				pcall(function() remoteOwner:FireServer(tr, tr.Position) end)
			end
			if VortexEnabled then
				angle = angle + 0.05
				local pos = myRoot.Position + Vector3.new(math.cos(angle)*VortexDistance, 5, math.sin(angle)*VortexDistance)
				pcall(function() remoteOwner:FireServer(tr, pos); tr.CFrame = CFrame.new(pos) end)
			end
		end
	end
end)

StartSpamBtn.MouseButton1Click:Connect(function()
	if not targetMode then return end
	isSpamming = true
	while isSpamming do
		local list = (targetMode == "ALL") and Players:GetPlayers() or {targetMode}
		for _, p in pairs(list) do
			if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local pos = CFrame.new(p.Character.HumanoidRootPart.Position + Vector3.new(0, 4, 0))
				task.spawn(function() toyRemote:InvokeServer("DarkMatter", pos, 0, nil, 10) end)
			end
		end
		task.wait(targetMode == "ALL" and 0.12 or 0.06)
	end
end)

StopSpamBtn.MouseButton1Click:Connect(function() isSpamming = false end)
StartVortexBtn.MouseButton1Click:Connect(function() VortexEnabled = true end)
StopVortexBtn.MouseButton1Click:Connect(function() VortexEnabled = false end)
SelectAllBtn.MouseButton1Click:Connect(function()
TargetPlayers = {}
    for _, p in pairs(Players:GetPlayers()) do if p ~= player then TargetPlayers[p.Name] = true end end
    targetMode = "ALL"; Title.Text = "TARGET: ALL"; updateList()
end)
OptBtn.MouseButton1Click:Connect(function()
	isCleaning = not isCleaning
	OptBtn.Text = isCleaning and "CLEANING: ON" or "CLEANING: OFF"
end)
toyFolder.ChildAdded:Connect(function(toy) if isCleaning then task.wait(0.3) toy:Destroy() end end)
TeleportBtn.MouseButton1Click:Connect(function()
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end
	for name, _ in pairs(TargetPlayers) do
		local p = Players:FindFirstChild(name)
		local tr = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if tr then
			local tPos = (myRoot.CFrame * CFrame.new(0, 0, -7)).Position
			pcall(function() remoteOwner:FireServer(tr, tPos); tr.CFrame = CFrame.new(tPos) end)
		end
	end
end)
