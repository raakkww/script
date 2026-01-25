--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local folderName = "Grass" 

local folder = workspace:FindFirstChild(folderName)
if folder and folder:IsA("Folder") then
	folder:Destroy()
	print("Deleted folder:", folderName)
else
	warn("folder:", folderName)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local TARGET_PART_NAME = "Part"
local TOP_HEIGHT = 0.5
local TAG_NAME = "TopBrickApplied"
local CREATED_BRICK_TAG = "GeneratedTopBrick"

local ESP_ENABLED = false
local currentTransparency = 0.1
local highlights = {}

local gui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,220,0,190)
main.Position = UDim2.new(0.5,-110,0.5,-95)
main.BackgroundColor3 = Color3.fromRGB(25,25,28)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundTransparency = 1
title.Text = "system control + ESP"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13

local toggleBtn = Instance.new("TextButton", main)
toggleBtn.Size = UDim2.new(0.9,0,0,40)
toggleBtn.Position = UDim2.new(0.05,0,0.25,0)
toggleBtn.Text = "ESP: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", toggleBtn)

local opacityBtn = Instance.new("TextButton", main)
opacityBtn.Size = UDim2.new(0.9,0,0,35)
opacityBtn.Position = UDim2.new(0.05,0,0.55,0)
opacityBtn.Text = "BRICK OPACITY: 0.1"
opacityBtn.BackgroundColor3 = Color3.fromRGB(45,45,50)
opacityBtn.TextColor3 = Color3.new(1,1,1)
opacityBtn.Font = Enum.Font.Gotham
Instance.new("UICorner", opacityBtn)

local function spawnTopBrick(part)
	if CollectionService:HasTag(part, TAG_NAME) then return end
	local top = Instance.new("Part")
	top.Size = Vector3.new(part.Size.X, TOP_HEIGHT, part.Size.Z)
	top.Anchored = true
	top.CanCollide = false
	top.Material = Enum.Material.Glass
	top.Transparency = currentTransparency
	top.CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 + TOP_HEIGHT/2, 0)
	top.Parent = workspace
	CollectionService:AddTag(part, TAG_NAME)
	CollectionService:AddTag(top, CREATED_BRICK_TAG)
end

local function enableMap()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart")
		and obj.Name == TARGET_PART_NAME
		and not obj:IsDescendantOf(Players) then
			spawnTopBrick(obj)
		end
	end
end

local function disableMap()
	for _, v in ipairs(CollectionService:GetTagged(CREATED_BRICK_TAG)) do
		v:Destroy()
	end
	for _, v in ipairs(CollectionService:GetTagged(TAG_NAME)) do
		CollectionService:RemoveTag(v, TAG_NAME)
	end
end

local function forceVisible(plr)
	if plr == LocalPlayer or not plr.Character then return end

	for _, obj in ipairs(plr.Character:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("MeshPart") then
			obj.Transparency = 0
			obj.LocalTransparencyModifier = 0
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = 0
		end
	end
end

local function removeESP(plr)
	if highlights[plr] then
		highlights[plr]:Destroy()
		highlights[plr] = nil
	end
end

local function waitForCharacter(plr)
	local char = plr.Character or plr.CharacterAdded:Wait()
	char:WaitForChild("Humanoid")
	char:WaitForChild("HumanoidRootPart")
	return char
end

local function createESP(plr)
	if plr == LocalPlayer or not ESP_ENABLED then return end
	removeESP(plr)

	local char = waitForCharacter(plr)
	if not ESP_ENABLED then return end

	local hl = Instance.new("Highlight")
	hl.Adornee = char
	hl.FillTransparency = 1
	hl.OutlineTransparency = 0
	hl.OutlineColor = Color3.fromRGB(255,0,0)
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = workspace

	highlights[plr] = hl

	char.Humanoid.Died:Connect(function()
		removeESP(plr)
	end)
end

toggleBtn.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED

	toggleBtn.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
	TweenService:Create(toggleBtn, TweenInfo.new(0.25), {
		BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(50,180,100)
			or Color3.fromRGB(180,50,50)
	}):Play()

	if ESP_ENABLED then
		enableMap()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				task.spawn(createESP, plr)
			end
		end
	else
		disableMap()
		for plr in pairs(highlights) do
			removeESP(plr)
		end
	end
end)

opacityBtn.MouseButton1Click:Connect(function()
	currentTransparency += 0.1
	if currentTransparency > 1 then currentTransparency = 0 end
	opacityBtn.Text = "BRICK OPACITY: " .. string.format("%.1f", currentTransparency)

	for _, brick in ipairs(CollectionService:GetTagged(CREATED_BRICK_TAG)) do
		brick.Transparency = currentTransparency
	end
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		if ESP_ENABLED then
			task.wait(0.4)
			createESP(plr)
		end
	end)
end)

RunService.Heartbeat:Connect(function()
	if not ESP_ENABLED then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			forceVisible(plr)

			if not highlights[plr] or not highlights[plr].Adornee then
				task.spawn(createESP, plr)
			end
		end
	end
end)
