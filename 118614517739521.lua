-- Hydra Blind Shot - Main + Settings with UI
-- Adds toggles for auto-skip (claim cached rewards) and auto-buy spin

-- Load UI Library
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- Settings
local settings = {
	AutoSkipSpins = false,
	AutoBuySpin = false,
	SkipDelay = 0.5,
	BuyDelay = 1.0,
	PlayerESP = false,
	HighlightPlayers = false,
	RevealPlayers = false,
	AimDetection = false,
	UnanchorHRP = false,
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP Storage
local espObjects = {}
local highlightObjects = {}

-- Services
local RS = game:GetService("ReplicatedStorage")
local Net = RS:WaitForChild("NetRayRemotes")

-- Helper functions
local function claimCachedRewards()
	local args = {
		buffer.fromstring("@\018ClaimCachedRewards")
	}
	local ok, err = pcall(function()
		Net:WaitForChild("Spinner_RF"):InvokeServer(unpack(args))
	end)
	if not ok then
		warn("claimCachedRewards error:", err)
	end
end

local function buySpin()
	local args = {
		buffer.fromstring("\241C\026\000\000\002\t\a\ashopKey\a\fCashCrate_1x\n"),
		{}
	}
	local ok, err = pcall(function()
		Net:WaitForChild("Shop_Purchase"):FireServer(unpack(args))
	end)
	if not ok then
		warn("buySpin error:", err)
	end
end

-- Create UI Window
local Window = Library:CreateWindow({
	Title = "Hydra Hub",
	Footer = "Blind Shot",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- Add unload handler
Library:OnUnload(function()
	print("Hydra Hub unloaded!")
	-- Clean up ESP
	for _, obj in pairs(espObjects) do
		if obj then obj:Destroy() end
	end
	for _, obj in pairs(highlightObjects) do
		if obj then obj:Destroy() end
	end
end)

-- Create Tabs
local Tabs = {
	Main = Window:AddTab("Main", "target"),
	Visuals = Window:AddTab("Visuals", "eye"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- Main Group
local MainGroup = Tabs.Main:AddLeftGroupbox("Auto Features")

-- Auto Skip Spins Toggle
MainGroup:AddToggle("AutoSkipToggle", {
	Text = "Auto Skip Spins",
	Tooltip = "Automatically claims cached rewards",
	Default = false,
	Callback = function(Value)
		settings.AutoSkipSpins = Value
		print("Auto Skip Spins:", Value)
	end,
})

-- Auto Buy Spin Toggle
MainGroup:AddToggle("AutoBuyToggle", {
	Text = "Auto Buy Spin",
	Tooltip = "Automatically purchases spins",
	Default = false,
	Callback = function(Value)
		settings.AutoBuySpin = Value
		print("Auto Buy Spin:", Value)
	end,
})

-- Unanchor HRP Toggle
MainGroup:AddToggle("UnanchorHRPToggle", {
	Text = "Unfreeze character (IN SHOOTING STAGE)",
	Tooltip = "xeno was here i think",
	Default = false,
	Callback = function(Value)
		settings.UnanchorHRP = Value
		print("Unanchor HRP:", Value)
	end,
})

-- Settings Group
local SettingsGroup = Tabs.Main:AddRightGroupbox("Settings")

-- Skip Delay Slider
SettingsGroup:AddSlider("SkipDelay", {
	Text = "Skip Delay (s)",
	Tooltip = "Delay between auto skip attempts",
	Default = 0.5,
	Min = 0.1,
	Max = 5,
	Rounding = 2,
	Callback = function(Value)
		settings.SkipDelay = Value
	end,
})

-- Buy Delay Slider
SettingsGroup:AddSlider("BuyDelay", {
	Text = "Buy Delay (s)",
	Tooltip = "Delay between auto buy attempts",
	Default = 1.0,
	Min = 0.1,
	Max = 10,
	Rounding = 2,
	Callback = function(Value)
		settings.BuyDelay = Value
	end,
})

-- Visuals Group
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox("ESP & Visuals")

-- Player ESP Toggle
VisualsGroup:AddToggle("PlayerESPToggle", {
	Text = "Player ESP",
	Tooltip = "Shows player names and distance through walls",
	Default = false,
	Callback = function(Value)
		settings.PlayerESP = Value
		if not Value then
			-- Clear ESP
			for _, obj in pairs(espObjects) do
				if obj then obj:Destroy() end
			end
			espObjects = {}
		end
	end,
})

-- Highlight Players Toggle
VisualsGroup:AddToggle("HighlightPlayersToggle", {
	Text = "Highlight Players",
	Tooltip = "Adds highlight effect to all players",
	Default = false,
	Callback = function(Value)
		settings.HighlightPlayers = Value
		if not Value then
			-- Clear highlights
			for _, obj in pairs(highlightObjects) do
				if obj then obj:Destroy() end
			end
			highlightObjects = {}
		end
	end,
})

-- Reveal Players Toggle
VisualsGroup:AddToggle("RevealPlayersToggle", {
	Text = "Reveal Hidden Players",
	Tooltip = "Finds and reveals players hidden",
	Default = false,
	Callback = function(Value)
		settings.RevealPlayers = Value
		print("Reveal Players:", Value)
	end,
})

-- Detection Group
local DetectionGroup = Tabs.Visuals:AddRightGroupbox("Detection")

-- Aim Detection Toggle
DetectionGroup:AddToggle("AimDetectionToggle", {
	Text = "Aim Warning",
	Tooltip = "Notifies when someone is aiming at you",
	Default = false,
	Callback = function(Value)
		settings.AimDetection = Value
		print("Aim Detection:", Value)
	end,
})

-- UI Settings
Library:SetWatermarkVisibility(true)

local FrameworkSettings = Tabs["UI Settings"]:AddLeftGroupbox("UI Settings")
FrameworkSettings:AddToggle("KeybindFrameShow", { Text = "Keybind Frame", Default = false, Callback = function(Value) Library.KeybindFrame.Visible = Value end})
FrameworkSettings:AddToggle("WatermarkFrameShow", {Text = "Watermark Frame", Default = true, Callback = function(Value) Library:SetWatermarkVisibility(Value) end})
FrameworkSettings:AddButton({Text = "Unload UI", Func = function() Library:Unload() end})
FrameworkSettings:AddDivider()
FrameworkSettings:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("HydraBlindShot")
SaveManager:SetFolder("HydraBlindShot/configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

-- ESP Functions
local function createESP(player)
	if not player.Character or espObjects[player] then return end
	
	local char = player.Character
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "ESP_" .. player.Name
	billboardGui.Adornee = hrp
	billboardGui.Size = UDim2.new(0, 100, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = hrp
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextSize = 14
	nameLabel.Parent = billboardGui
	
	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	distanceLabel.TextStrokeTransparency = 0.5
	distanceLabel.Font = Enum.Font.SourceSans
	distanceLabel.TextSize = 12
	distanceLabel.Parent = billboardGui
	
	espObjects[player] = billboardGui
	
	-- Update distance
	task.spawn(function()
		while billboardGui and billboardGui.Parent and settings.PlayerESP do
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and hrp then
				local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
				distanceLabel.Text = string.format("%.1f studs", distance)
			end
			task.wait(0.1)
		end
	end)
end

local function createHighlight(player)
	if not player.Character or highlightObjects[player] then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "PlayerHighlight_" .. player.Name
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Parent = player.Character
	
	highlightObjects[player] = highlight
end

local function revealPlayers()
	-- Move ANY model from ReplicatedStorage to workspace
	for _, obj in pairs(RS:GetChildren()) do
		if obj:IsA("Model") then
			print("Moving model to workspace:", obj.Name)
			obj.Parent = workspace
		end
	end
end

-- Aim Detection System
local lastAimWarning = 0
local function checkAimDetection()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	
	local myPos = LocalPlayer.Character.HumanoidRootPart.Position
	local myHRP = LocalPlayer.Character.HumanoidRootPart
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			-- Look for any Tool in the character
			for _, tool in pairs(player.Character:GetChildren()) do
				if tool:IsA("Tool") then
					-- Search for GunLaser in the tool and its descendants
					local gunLaser = tool:FindFirstChild("GunLaser", true) -- recursive search
					
					if gunLaser and gunLaser:IsA("BasePart") then
						-- Get the laser's position and direction
						local laserPos = gunLaser.Position
						local laserCFrame = gunLaser.CFrame
						local laserForward = laserCFrame.LookVector
						
						-- Vector from laser to player
						local toMe = (myPos - laserPos)
						local distance = toMe.Magnitude
						
						-- Normalize direction to player
						local directionToMe = toMe.Unit
						
						-- Calculate dot product (1 = pointing directly at, -1 = pointing away)
						local dotProduct = laserForward:Dot(directionToMe)
						
						-- Also check if we're in front of the gun (not behind)
						if dotProduct > 0.98 and distance < 500 then -- Very tight angle and reasonable range
							local currentTime = tick()
							if currentTime - lastAimWarning > 3 then -- 3 second cooldown
								Library:Notify("⚠️ WARNING: " .. player.Name .. " is aiming at you!", 3)
								lastAimWarning = currentTime
								
								-- Optional: Print debug info
								print(string.format("[Aim Detection] %s aiming at you! Dot: %.3f, Distance: %.1f", 
									player.Name, dotProduct, distance))
							end
						end
					end
				end
			end
		end
	end
end

-- Main loops
task.spawn(function()
	while true do
		if settings.AutoSkipSpins then
			claimCachedRewards()
		end
		task.wait(settings.SkipDelay)
	end
end)

task.spawn(function()
	while true do
		if settings.AutoBuySpin then
			buySpin()
		end
		task.wait(settings.BuyDelay)
	end
end)

task.spawn(function()
	while true do
		if settings.AutoBuyProduct then
			buyProduct()
		end
		task.wait(settings.ProductDelay)
	end
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
	if settings.PlayerESP then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				if not espObjects[player] or not espObjects[player].Parent then
					createESP(player)
				end
			end
		end
	end
	
	if settings.HighlightPlayers then
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				if not highlightObjects[player] or not highlightObjects[player].Parent then
					createHighlight(player)
				end
			end
		end
	end
	
	if settings.UnanchorHRP then
		if LocalPlayer.Character then
			local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hrp and hrp.Anchored then
				hrp.Anchored = false
			end
			if humanoid then
				humanoid.WalkSpeed = 25
			end
		end
	end
	
	if settings.AimDetection then
		checkAimDetection()
	end
end)

-- Reveal Players Loop
task.spawn(function()
	while true do
		if settings.RevealPlayers then
			revealPlayers()
		end
		task.wait(1) -- Check every second
	end
end)

-- Handle player character changes
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if settings.PlayerESP then
			createESP(player)
		end
		if settings.HighlightPlayers then
			createHighlight(player)
		end
	end)
end)

-- Setup for existing players
for _, player in pairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			if settings.PlayerESP then
				createESP(player)
			end
			if settings.HighlightPlayers then
				createHighlight(player)
			end
		end)
	end
end

-- Expose API
local Main = {}

function Main.SetAutoSkip(value)
	settings.AutoSkipSpins = not not value
	if Toggles.AutoSkipToggle then
		Toggles.AutoSkipToggle:SetValue(value)
	end
end

function Main.SetAutoBuy(value)
	settings.AutoBuySpin = not not value
	if Toggles.AutoBuyToggle then
		Toggles.AutoBuyToggle:SetValue(value)
	end
end

function Main.GetSettings()
	return {
		AutoSkipSpins = settings.AutoSkipSpins,
		AutoBuySpin = settings.AutoBuySpin,
		SkipDelay = settings.SkipDelay,
		BuyDelay = settings.BuyDelay,
	}
end

_G.HydraMain = Main
_G.HydraSettings = settings

print("Hydra Blind Shot loaded! UI is ready.")
