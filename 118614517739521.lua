local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

--[[====================================================================================
    WindUI Loader (Robust - Works in Studio & Live Game)
    Credits: NoHub - Noctyra
====================================================================================]]

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local WindUI
do
    local ok, result = pcall(function()
        return require(ReplicatedStorage:FindFirstChild("WindUI") and ReplicatedStorage.WindUI.Init or nil)
    end)
    
    if ok then
        WindUI = result
    else
        if RunService:IsStudio() then
            WindUI = require(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init"))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
        end
    end
end

--[[====================================================================================
    Hydra Blind Shot - Core Logic (UNCHANGED from original)
    Credits: NoHub - Noctyra
====================================================================================]]

-- Settings (identical to original)
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

-- ESP Storage (identical to original)
local espObjects = {}
local highlightObjects = {}

-- Services (identical to original)
local Net = RS:WaitForChild("NetRayRemotes")

-- Helper functions (IDENTICAL logic - zero changes)
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

-- ESP Functions (IDENTICAL logic - zero changes)
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

-- Aim Detection System (IDENTICAL logic - zero changes)
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
								WindUI:Notify({
									Title = "⚠️ WARNING",
									Content = player.Name .. " is aiming at you!",
									Duration = 3,
								})
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

--[[====================================================================================
    NoHub Main Window - Mobile-Optimized & Draggable
    Credits: NoHub - Noctyra
====================================================================================]]

local Window = WindUI:CreateWindow({
    Title = "NoHub By Noctyra",
    Folder = "HydraBlindShot",
    Icon = "solar:target-bold",
    Draggable = true, -- Essential for mobile drag support
    
    OpenButton = {
        Title = "Open NoHub",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true, -- Mobile-friendly drag handle
        OnlyMobile = false,
        Scale = 0.65, -- Optimized size for mobile touch
        
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#ECA201")
        )
    },
    
    Topbar = {
        Height = 48, -- Minimum 44px for touch targets
        ButtonsType = "Mac",
    },
    
    -- Mobile-first sizing defaults
    Size = UDim2.new(0, 420, 0, 580),
    Position = UDim2.new(0.5, 0, 0.5, 0),
})

-- Branding tag (required per your specifications)
Window:Tag({
    Title = "NoHub By Noctyra",
    Icon = "shield-check",
    Color = Color3.fromHex("#1c1c1c"),
    Border = true,
})

-- Add unload handler (IDENTICAL cleanup logic)
Window:OnClose(function()
	print("Hydra Hub unloaded!")
	-- Clean up ESP
	for _, obj in pairs(espObjects) do
		if obj then obj:Destroy() end
	end
	for _, obj in pairs(highlightObjects) do
		if obj then obj:Destroy() end
	end
end)

--[[====================================================================================
    Features Section (Main + Visuals Tabs)
====================================================================================]]

local FeaturesSection = Window:Section({
    Title = "Features",
})

-- Main Tab (Auto Features + Settings)
local MainTab = FeaturesSection:Tab({
    Title = "Main",
    Icon = "solar:target-bold",
    IconColor = Color3.fromHex("#EF4F1D"),
    IconShape = "Square",
    Border = true,
})

-- Auto Features Group (Left column equivalent)
local AutoFeaturesGroup = MainTab:Group({})

AutoFeaturesGroup:Toggle({
    Title = "Auto Skip Spins",
    Desc = "Automatically claims cached rewards",
    Icon = "rotate-ccw",
    -- IDENTICAL callback logic
    Callback = function(Value)
        settings.AutoSkipSpins = Value
        print("Auto Skip Spins:", Value)
    end
})

AutoFeaturesGroup:Space({ Columns = 1 })

AutoFeaturesGroup:Toggle({
    Title = "Auto Buy Spin",
    Desc = "Automatically purchases spins",
    Icon = "shopping-cart",
    -- IDENTICAL callback logic
    Callback = function(Value)
        settings.AutoBuySpin = Value
        print("Auto Buy Spin:", Value)
    end
})

AutoFeaturesGroup:Space({ Columns = 1 })

AutoFeaturesGroup:Toggle({
    Title = "Unfreeze character (IN SHOOTING STAGE)",
    Desc = "xeno was here i think",
    Icon = "unlock",
    -- IDENTICAL callback logic
    Callback = function(Value)
        settings.UnanchorHRP = Value
        print("Unanchor HRP:", Value)
    end
})

MainTab:Space({ Columns = 2 })

-- Settings Group (Right column equivalent)
local SettingsGroup = MainTab:Group({})

SettingsGroup:Slider({
    Title = "Skip Delay (s)",
    Desc = "Delay between auto skip attempts",
    IsTooltip = true,
    Step = 0.1,
    Width = 200,
    Value = {
        Min = 0.1,
        Max = 5,
        Default = 0.5,
    },
    -- IDENTICAL callback logic
    Callback = function(Value)
        settings.SkipDelay = Value
    end
})

SettingsGroup:Space({ Columns = 1 })

SettingsGroup:Slider({
    Title = "Buy Delay (s)",
    Desc = "Delay between auto buy attempts",
    IsTooltip = true,
    Step = 0.1,
    Width = 200,
    Value = {
        Min = 0.1,
        Max = 10,
        Default = 1.0,
    },
    -- IDENTICAL callback logic
    Callback = function(Value)
        settings.BuyDelay = Value
    end
})

-- Visuals Tab (ESP & Detection)
local VisualsTab = FeaturesSection:Tab({
    Title = "Visuals",
    Icon = "solar:eye-bold",
    IconColor = Color3.fromHex("#305DFF"),
    IconShape = "Square",
    Border = true,
})

-- ESP & Visuals Group
local ESPGroup = VisualsTab:Group({})

ESPGroup:Toggle({
    Title = "Player ESP",
    Desc = "Shows player names and distance through walls",
    Icon = "user",
    -- IDENTICAL callback logic (including cleanup)
    Callback = function(Value)
        settings.PlayerESP = Value
        if not Value then
            -- Clear ESP (IDENTICAL to original)
            for _, obj in pairs(espObjects) do
                if obj then obj:Destroy() end
            end
            espObjects = {}
        end
    end
})

ESPGroup:Space({ Columns = 1 })

ESPGroup:Toggle({
    Title = "Highlight Players",
    Desc = "Adds highlight effect to all players",
    Icon = "square-dot",
    -- IDENTICAL callback logic (including cleanup)
    Callback = function(Value)
        settings.HighlightPlayers = Value
        if not Value then
            -- Clear highlights (IDENTICAL to original)
            for _, obj in pairs(highlightObjects) do
                if obj then obj:Destroy() end
            end
            highlightObjects = {}
        end
    end
})

ESPGroup:Space({ Columns = 1 })

ESPGroup:Toggle({
    Title = "Reveal Hidden Players",
    Desc = "Finds and reveals players hidden",
    Icon = "eye-off",
    -- IDENTICAL callback logic
    Callback = function(Value)
        settings.RevealPlayers = Value
        print("Reveal Players:", Value)
    end
})

VisualsTab:Space({ Columns = 2 })

-- Detection Group
local DetectionGroup = VisualsTab:Group({})

DetectionGroup:Toggle({
    Title = "Aim Warning",
    Desc = "Notifies when someone is aiming at you",
    Icon = "alert-triangle",
    -- IDENTICAL callback logic
    Callback = function(Value)
        settings.AimDetection = Value
        print("Aim Detection:", Value)
    end
})

--[[====================================================================================
    Configuration Section (UI Settings + Config Management)
====================================================================================]]

local ConfigSection = Window:Section({
    Title = "Configuration",
})

local ConfigTab = ConfigSection:Tab({
    Title = "UI Settings",
    Icon = "solar:settings-bold",
    IconColor = Color3.fromHex("#7775F2"),
    Border = true,
})

-- UI Settings Group
local UISettingsGroup = ConfigTab:Group({})

UISettingsGroup:Toggle({
    Title = "Keybind Frame",
    Flag = "KeybindFrameShow",
    Value = false,
    -- WindUI doesn't have native keybind frame - disable functionality but keep toggle
    Callback = function(Value)
        -- Original Obsidian functionality not available in WindUI
        -- Keeping toggle for UI consistency only
        print("Keybind Frame toggle:", Value)
    end
})

UISettingsGroup:Space({ Columns = 1 })

UISettingsGroup:Toggle({
    Title = "Watermark",
    Flag = "WatermarkFrameShow",
    Value = true,
    -- WindUI doesn't have native watermark - disable functionality but keep toggle
    Callback = function(Value)
        print("Watermark toggle:", Value)
    end
})

UISettingsGroup:Space({ Columns = 1 })

UISettingsGroup:Button({
    Title = "Unload UI",
    Icon = "log-out",
    Justify = "Center",
    Color = Color3.fromHex("#FF4830"),
    -- IDENTICAL unload behavior (calls Window:Destroy)
    Callback = function()
        Window:Destroy()
    end
})

ConfigTab:Space({ Columns = 2 })

-- Menu Keybind (WindUI equivalent of KeyPicker)
local MenuKeybind = ConfigTab:Keybind({
    Title = "Menu Keybind",
    Desc = "Toggle UI visibility",
    Flag = "MenuKeybind",
    Value = "RightShift",
    -- IDENTICAL functionality (sets toggle key)
    Callback = function(keyName)
        if keyName then
            local keyCode = Enum.KeyCode[keyName]
            if keyCode then
                Window:SetToggleKey(keyCode)
            end
        end
    end
})

-- Set default toggle key (RightShift as in original)
Window:SetToggleKey(Enum.KeyCode.RightShift)

ConfigTab:Space({ Columns = 2 })

-- Config Management (WindUI native ConfigManager - replaces SaveManager)
ConfigTab:Section({
    Title = "Configuration Management",
    TextSize = 18,
    FontWeight = Enum.FontWeight.SemiBold,
})

local ConfigName = "default"
local ConfigNameInput = ConfigTab:Input({
    Title = "Config Name",
    Desc = "Name for your configuration",
    Flag = "ConfigName",
    Value = ConfigName,
    Placeholder = "default",
    Icon = "file-cog",
    Callback = function(value)
        ConfigName = value
    end
})

ConfigTab:Space({ Columns = 1 })

ConfigTab:Button({
    Title = "Save Config",
    Icon = "save",
    Justify = "Center",
    Color = Color3.fromHex("#30FF6A"),
    Callback = function()
        local CurrentConfig = Window.ConfigManager:Config(ConfigName)
        if CurrentConfig:Save() then
            WindUI:Notify({
                Title = "Config Saved",
                Content = "Configuration '" .. ConfigName .. "' saved successfully!",
                Icon = "check",
                Duration = 3,
            })
        end
    end
})

ConfigTab:Space({ Columns = 1 })

ConfigTab:Button({
    Title = "Load Config",
    Icon = "upload",
    Justify = "Center",
    Color = Color3.fromHex("#257AF7"),
    Callback = function()
        local CurrentConfig = Window.ConfigManager:CreateConfig(ConfigName)
        if CurrentConfig:Load() then
            WindUI:Notify({
                Title = "Config Loaded",
                Content = "Configuration '" .. ConfigName .. "' loaded successfully!",
                Icon = "refresh-cw",
                Duration = 3,
            })
        end
    end
})

-- Auto-load default config on startup (mimics SaveManager:LoadAutoloadConfig)
task.spawn(function()
    task.wait(0.5) -- Allow UI to fully initialize
    local CurrentConfig = Window.ConfigManager:CreateConfig("default")
    CurrentConfig:Load()
end)

--[[====================================================================================
    Main Execution Loops (IDENTICAL to original - zero changes)
====================================================================================]]

-- Auto Skip Loop (IDENTICAL logic)
task.spawn(function()
	while true do
		if settings.AutoSkipSpins then
			claimCachedRewards()
		end
		task.wait(settings.SkipDelay)
	end
end)

-- Auto Buy Loop (IDENTICAL logic)
task.spawn(function()
	while true do
		if settings.AutoBuySpin then
			buySpin()
		end
		task.wait(settings.BuyDelay)
	end
end)

-- ESP/Highlight/Unanchor/Aim Detection Loop (IDENTICAL logic)
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

-- Reveal Players Loop (IDENTICAL logic)
task.spawn(function()
	while true do
		if settings.RevealPlayers then
			revealPlayers()
		end
		task.wait(1) -- Check every second
	end
end)

-- Handle player character changes (IDENTICAL logic)
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

-- Setup for existing players (IDENTICAL logic)
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

--[[====================================================================================
    Public API (IDENTICAL to original - zero changes)
====================================================================================]]

local Main = {}

function Main.SetAutoSkip(value)
	settings.AutoSkipSpins = not not value
	-- Note: WindUI doesn't expose direct toggle control like Obsidian
	-- Settings are preserved via ConfigManager flags
end

function Main.SetAutoBuy(value)
	settings.AutoBuySpin = not not value
	-- Note: WindUI doesn't expose direct toggle control like Obsidian
	-- Settings are preserved via ConfigManager flags
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

print("Hydra Blind Shot loaded! | Credits: NoHub - Noctyra")
