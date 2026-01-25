    repeat task.wait() until game:IsLoaded()

getgenv().Core = {}

local Core = getgenv().Core

Core.Version = "1.0.0"
Core.Loaded = true

Core.Services = {}
Core.Features = {}
Core.Connections = {}
Core.Keybinds = {}
Core.Hooks = {}

local Services = Core.Services

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.UserInputService = game:GetService("UserInputService")
Services.TeleportService = game:GetService("TeleportService")

local LocalPlayer = Services.Players.LocalPlayer

local Camera = workspace.CurrentCamera

local PlayerESPLib = loadstring(game:HttpGet("https://pastefy.app/ik8BXXQX/raw"))()
local MacLib = loadstring(game:HttpGet("https://pastefy.app/tNO41lcM/raw"))()

--[[ FEATURE SETUP ]]--

Core.Features.AutoQuest = {
	Enabled = false
}

Core.Features.AutoStealItems = {
	Enabled = false
}

Core.Features.AutoStealGems = {
	Enabled = false
}

Core.Features.NoSlow = {
	Enabled = false
}

Core.Features.AutoBreakGlass = {
	Enabled = false
}

Core.Features.Flight = {
	Enabled = false,
	VerticalSpeed = 50,
	HorizontalSpeed = 50
}

Core.Features.Walkspeed = {
	Enabled = false,
	Speed = 50
}

Core.Features.FOV = {
	Enabled = false,
	Value = 70
}

Core.Features.Gravity = {
	Enabled = false,
	Value = 196.2
}

Core.Features.JumpPower = {
	Enabled = false,
	Power = 50
}

Core.Features.Phase = {
	Enabled = false,
	OriginalCollision = {}
}

Core.Features.LongJump = {
	Enabled = false,
	Height = 50,
	Boost = 50
}

Core.Features.WallClimb = {
	Enabled = false,
	Speed = 50
}

Core.Features.SpinBot = {
	Enabled = false,
	Speed = 50
}

Core.Features.BunnyHop = {
	Enabled = false,
	Speed = 50
}

Core.Features.PlayerESP = {
	Enabled = false,
	Box = false,
	Chams = false,
	ChamsFill = false,
	Tracer = false,
	Skeleton = false,
	Arrow = false,
	Name = false,
	Rainbow = false,
	DefaultColor = Color3.fromRGB(255, 255, 255),
	ChamsColor = Color3.fromRGB(255, 255, 255),
	ChamsOutline = Color3.fromRGB(255, 255, 255),
	MaxDistance = 1000
}

Core.Config = {
	Selected = nil,
	NameInput = ""
}

--[[ UTILITIES ]]--

function Core:GetCharacter(player)
	player = player or LocalPlayer

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not root or not humanoid then return end

	return character, humanoid, root
end

function Core:GetParts(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
	if not humanoid_root_part then return end

	return character, humanoid, humanoid_root_part
end

function Core:RefreshConfigs(dropdown)
	dropdown:ClearOptions()
	dropdown:InsertOptions(MacLib:RefreshConfigList() or {})
end

--[[ FEATURES ]]--

local folder_name = "Testing"

local window = MacLib:Window({
	Title = "",
	Subtitle = "" .. Core.Version,
	Size = Services.UserInputService.TouchEnabled and UDim2.fromOffset(600, 400) or UDim2.fromOffset(800, 600),
	DragStyle = 1,
	ShowUserInfo = true,
	Keybind = Enum.KeyCode.RightAlt,
	AcrylicBlur = true,
})

MacLib:SetFolder(folder_name)

local main_group = window:TabGroup()

local tabs = {
	Main = main_group:Tab({Name = "Combat", Image = "rbxassetid://4034483344"}),
	Mobility = main_group:Tab({Name = "Mobility", Image = "rbxassetid://7992557358"}),
	Render = main_group:Tab({Name = "Render", Image = "rbxassetid://6523858394"}),
	Settings = main_group:Tab({Name = "Settings", Image = "rbxassetid://132848201849699"}),
}

local sections = {
	main_left = tabs.Main:Section({ Side = "Left" }),
	main_left_bottom = tabs.Main:Section({ Side = "Left" }),
	main_right = tabs.Main:Section({ Side = "Right" }),
	main_right_bottom = tabs.Main:Section({ Side = "Right" }),
	main_right_bottom2 = tabs.Main:Section({ Side = "Right" }),
	mobility_left = tabs.Mobility:Section({ Side = "Left" }),
	mobility_right = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right2 = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right3 = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right4 = tabs.Mobility:Section({ Side = "Right" }),
	mobility_right5 = tabs.Mobility:Section({ Side = "Right" }),
	render_left = tabs.Render:Section({ Side = "Left" }),
	settings_left = tabs.Settings:Section({ Side = "Left" })
}

tabs.Main:Select()

--[[ MAIN ]]--

sections.main_left:Button({
	Name = "Delete Guards",
	Callback = function()
		local map = workspace:FindFirstChild("Map")
		if not map then return end
		
		local npc_folder = map:FindFirstChild("NPCS")
		if not npc_folder then return end
		
		pcall(function()
			Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(npc_folder)
		end)
	end
})

sections.main_left:Button({
	Name = "Delete Doors",
	Callback = function()
		local map = workspace:FindFirstChild("Map")
		if not map then return end

		local doors_folder = map:FindFirstChild("Doors")
		if not doors_folder then return end

		pcall(function()
			Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(doors_folder)
		end)
	end
})

sections.main_left:Button({
	Name = "Delete Glass",
	Callback = function()
		local map = workspace:FindFirstChild("Map")
		if not map then return end

		local breakable_glass_folder = map:FindFirstChild("BreakableGlass")
		if not breakable_glass_folder then return end

		pcall(function()
			Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(breakable_glass_folder)
		end)
	end
})

sections.main_left:Button({
	Name = "Delete Cameras",
	Callback = function()
		local map = workspace:FindFirstChild("Map")
		if not map then return end

		local cameras_folder = map:FindFirstChild("Cameras")
		if not cameras_folder then return end

		pcall(function()
			Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(cameras_folder)
		end)
	end
})

AutoStealItems = sections.main_left_bottom:Toggle({
	Name = "Auto Steal Items",
	Default = Core.Features.AutoStealItems.Enabled,
	Callback = function(state)
		Core.Features.AutoStealItems.Enabled = state

		if state then
			Core.Connections.AutoStealItems = Services.RunService.PreRender:Connect(function(delta)
				local map = workspace:FindFirstChild("Map")
				if not map then return end

				local stealable_items = map:FindFirstChild("StealableItems")
				if not stealable_items then return end

				local natural = stealable_items:FindFirstChild("Natural")
				if not natural then return end
				
				for _, item in natural:GetChildren() do
					pcall(function()
						Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(item)
					end)
				end
			end)
		else
			if Core.Connections.AutoStealItems then
				Core.Connections.AutoStealItems:Disconnect()
				Core.Connections.AutoStealItems = nil
			end
		end
	end,
}, "AutoStealItems")

Core.Keybinds.AutoStealItemsKeybind = sections.main_left_bottom:Keybind({
	Name = "Auto Steal Items Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.AutoStealItems.Enabled = not Core.Features.AutoStealItems.Enabled
			AutoStealItems:UpdateState(Core.Features.AutoStealItems.Enabled)
		end
	end,
}, "AutoStealItemsKeybind")

AutoStealGems = sections.main_left_bottom:Toggle({
	Name = "Auto Steal Gems",
	Default = Core.Features.AutoStealGems.Enabled,
	Callback = function(state)
		Core.Features.AutoStealGems.Enabled = state

		if state then
			Core.Connections.AutoStealGems = Services.RunService.PreRender:Connect(function(delta)
				local map = workspace:FindFirstChild("Map")
				if not map then return end

				local stealable_items = map:FindFirstChild("StealableItems")
				if not stealable_items then return end

				for _, item in stealable_items:GetChildren() do
					if item.Name ~= "Gem" then continue end
					
					pcall(function()
						Services.ReplicatedStorage.Remotes.AutoGrabItems:FireServer(item)
					end)
				end
			end)
		else
			if Core.Connections.AutoStealGems then
				Core.Connections.AutoStealGems:Disconnect()
				Core.Connections.AutoStealGems = nil
			end
		end
	end,
}, "AutoStealGems")

Core.Keybinds.AutoStealGemsKeybind = sections.main_left_bottom:Keybind({
	Name = "Auto Steal Gems Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.AutoStealGems.Enabled = not Core.Features.AutoStealGems.Enabled
			AutoStealGems:UpdateState(Core.Features.AutoStealGems.Enabled)
		end
	end,
}, "AutoStealGemsKeybind")

AutoQuest = sections.main_right:Toggle({
	Name = "Auto Quest",
	Default = Core.Features.AutoQuest.Enabled,
	Callback = function(state)
		Core.Features.AutoQuest.Enabled = state

		if state then
			Core.Connections.AutoQuest = Services.RunService.PreRender:Connect(function(delta)
				local quest_folder = LocalPlayer:FindFirstChild("QuestFolder")
				if not quest_folder then return end
				
				local player_gui = LocalPlayer.PlayerGui
				if not player_gui then return end
				
				local main_ui = player_gui:FindFirstChild("MainUI")
				if not main_ui then return end
				
				local free_gift = main_ui:FindFirstChild("FreeGift")
				if not free_gift then return end
				
				if free_gift.Enabled then
					free_gift.Enabled = false
				end
				
				for _, quest in next, quest_folder:GetChildren() do
					local args = {
						quest.Name
					}
					pcall(function()
						Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClaimQuestReward"):FireServer(unpack(args))
					end)
				end
			end)
		else
			if Core.Connections.AutoQuest then
				Core.Connections.AutoQuest:Disconnect()
				Core.Connections.AutoQuest = nil
			end
		end
	end,
}, "AutoQuest")

Core.Keybinds.AutoQuestKeybind = sections.main_right:Keybind({
	Name = "Auto Quest Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.AutoQuest.Enabled = not Core.Features.AutoQuest.Enabled
			AutoQuest:UpdateState(Core.Features.AutoQuest.Enabled)
		end
	end,
}, "AutoQuestKeybind")

NoSlow = sections.main_right_bottom:Toggle({
	Name = "No Slow",
	Default = Core.Features.NoSlow.Enabled,
	Callback = function(state)
		Core.Features.NoSlow.Enabled = state

		if state then
			Core.Connections.NoSlow = Services.RunService.PreRender:Connect(function(delta)
				if LocalPlayer:GetAttribute("BagScale") then
					LocalPlayer:SetAttribute("BagScale", 0) 
				end
			end)
		else
			if Core.Connections.NoSlow then
				Core.Connections.NoSlow:Disconnect()
				Core.Connections.NoSlow = nil
			end
		end
	end,
}, "NoSlow")

Core.Keybinds.NoSlowKeybind = sections.main_right_bottom:Keybind({
	Name = "No Slow Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.NoSlow.Enabled = not Core.Features.NoSlow.Enabled
			NoSlow:UpdateState(Core.Features.NoSlow.Enabled)
		end
	end,
}, "NoSlowKeybind")

AutoBreakGlass = sections.main_right_bottom2:Toggle({
	Name = "Auto Break Glass",
	Default = Core.Features.AutoBreakGlass.Enabled,
	Callback = function(state)
		Core.Features.AutoBreakGlass.Enabled = state

		if state then
			Core.Connections.AutoBreakGlass = Services.RunService.PreRender:Connect(function(delta)
				local map = workspace:FindFirstChild("Map")
				if not map then return end

				local breakable_glass = map:FindFirstChild("BreakableGlass")
				if not breakable_glass then return end
				
				for _, glass in next, breakable_glass:GetChildren() do
					pcall(function()
						Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Utilities"):WaitForChild("BreakWindow"):FireServer(glass)
					end)
				end
			end)
		else
			if Core.Connections.AutoBreakGlass then
				Core.Connections.AutoBreakGlass:Disconnect()
				Core.Connections.AutoBreakGlass = nil
			end
		end
	end,
}, "AutoBreakGlass")

Core.Keybinds.AutoBreakGlassKeybind = sections.main_right_bottom2:Keybind({
	Name = "Auto Break Glass Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.AutoBreakGlass.Enabled = not Core.Features.AutoBreakGlass.Enabled
			AutoBreakGlass:UpdateState(Core.Features.AutoBreakGlass.Enabled)
		end
	end,
}, "AutoBreakGlassKeybind")

--[[ MOBILITY ]]--

Flight = sections.mobility_left:Toggle({
	Name = "Flight",
	Default = Core.Features.Flight.Enabled,
	Callback = function(state)
		Core.Features.Flight.Enabled = state

		if state then
			Core.Connections.Flight = Services.RunService.PreRender:Connect(function(delta)
				local character, humanoid, humanoid_root_part = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not humanoid_root_part then return end

				local move_direction = Vector3.zero

				if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(0, 0, 1)
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(0, 0, -1)
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(-1, 0, 0)
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) and not Services.UserInputService:GetFocusedTextBox() then
					move_direction += Vector3.new(1, 0, 0)
				end

				local vertical = 0
				if (Services.UserInputService:IsKeyDown(Enum.KeyCode.E) or Services.UserInputService:IsKeyDown(Enum.KeyCode.Space))
					and not Services.UserInputService:GetFocusedTextBox() then
					vertical = Core.Features.Flight.VerticalSpeed
				end
				if Services.UserInputService:IsKeyDown(Enum.KeyCode.Q) and not Services.UserInputService:GetFocusedTextBox() then
					vertical = -Core.Features.Flight.VerticalSpeed
				end

				if move_direction.Magnitude > 0 then
					move_direction = move_direction.Unit * Core.Features.Flight.HorizontalSpeed
				end

				local forward = Camera.CFrame.LookVector
				local right = Camera.CFrame.RightVector

				local final_move = (forward * move_direction.Z) + (right * move_direction.X) + (Vector3.yAxis * vertical)

				humanoid_root_part.CFrame += final_move * delta

				local velocity = humanoid_root_part.Velocity
				humanoid_root_part.Velocity = Vector3.new(velocity.X, 0.5, velocity.Z)
			end)
		else
			if Core.Connections.Flight then
				Core.Connections.Flight:Disconnect()
				Core.Connections.Flight = nil
			end
		end
	end,
}, "Flight")

sections.mobility_left:Slider({
	Name = "Horizontal Speed",
	Default = Core.Features.Flight.HorizontalSpeed,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v) Core.Features.Flight.HorizontalSpeed = v end,
}, "FlightHorizontalSpeed")

sections.mobility_left:Slider({
	Name = "Vertical Speed",
	Default = Core.Features.Flight.VerticalSpeed,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v) Core.Features.Flight.VerticalSpeed = v end,
}, "FlightVerticalSpeed")

Core.Keybinds.Flight = sections.mobility_left:Keybind({
	Name = "Flight Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Flight.Enabled = not Core.Features.Flight.Enabled
			Flight:UpdateState(Core.Features.Flight.Enabled)
		end
	end,
}, "FlightKeybind")

Walkspeed = sections.mobility_left:Toggle({
	Name = "Walkspeed",
	Default = Core.Features.Walkspeed.Enabled,
	Callback = function(enabled)
		Core.Features.Walkspeed.Enabled = enabled

		if enabled then
			Core.Connections.Walkspeed = Services.RunService.PreRender:Connect(function()
				local character, humanoid, humanoid_root_part = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not humanoid_root_part then return end

				humanoid.WalkSpeed = Core.Features.Walkspeed.Speed
			end)
		else
			if Core.Connections.Walkspeed then
				Core.Connections.Walkspeed:Disconnect()
				Core.Connections.Walkspeed = nil
			end

			local character, humanoid, humanoid_root_part = Core:GetParts(LocalPlayer)
			if not character or not humanoid or not humanoid_root_part then return end

			humanoid.WalkSpeed = 16
		end
	end,
}, "Walkspeed")

sections.mobility_left:Slider({
	Name = "Speed",
	Default = Core.Features.Walkspeed.Speed,
	Minimum = 0,
	Maximum = 250,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.Walkspeed.Speed = value
	end,
}, "WalkspeedSlider")

Core.Keybinds.Walkspeed = sections.mobility_left:Keybind({
	Name = "Walkspeed Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Walkspeed.Enabled = not Core.Features.Walkspeed.Enabled
			Walkspeed:UpdateState(Core.Features.Walkspeed.Enabled)
		end
	end,
}, "WalkspeedKeybind")

JumpPower = sections.mobility_left:Toggle({
	Name = "Jump Power",
	Default = Core.Features.JumpPower.Enabled,
	Callback = function(enabled)
		Core.Features.JumpPower.Enabled = enabled

		if enabled then
			Core.Connections.JumpPower = Services.RunService.PreRender:Connect(function()
				local character, humanoid = Core:GetParts(LocalPlayer)
				if not humanoid then return end

				if humanoid.UseJumpPower then
					humanoid.JumpPower = Core.Features.JumpPower.Power
				else
					humanoid.JumpHeight = Core.Features.JumpPower.Power
				end
			end)
		else
			if Core.Connections.JumpPower then
				Core.Connections.JumpPower:Disconnect()
				Core.Connections.JumpPower = nil
			end

			local character, humanoid = Core:GetParts(LocalPlayer)
			if not humanoid then return end
			
			if humanoid.UseJumpPower then
				humanoid.JumpPower = 50
			else
				humanoid.JumpHeight = 7.2
			end
		end
	end,
}, "JumpPower")

sections.mobility_left:Slider({
	Name = "Power",
	Default = Core.Features.JumpPower.Power,
	Minimum = 0,
	Maximum = 300,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.JumpPower.Power = value
	end,
}, "JumpPowerSlider")

Core.Keybinds.JumpPower = sections.mobility_left:Keybind({
	Name = "Jump Power Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.JumpPower.Enabled = not Core.Features.JumpPower.Enabled
			JumpPower:UpdateState(Core.Features.JumpPower.Enabled)
		end
	end,
}, "JumpPowerKeybind")

FOV = sections.mobility_left:Toggle({
	Name = "Field of View",
	Default = Core.Features.FOV.Enabled,
	Callback = function(enabled)
		Core.Features.FOV.Enabled = enabled

		if enabled then
			Core.Connections.FOV = Services.RunService.PreRender:Connect(function()
				Camera.FieldOfView = Core.Features.FOV.Value
			end)
		else
			if Core.Connections.FOV then
				Core.Connections.FOV:Disconnect()
				Core.Connections.FOV = nil
			end

			Camera.FieldOfView = 70
		end
	end,
}, "FOV")

sections.mobility_left:Slider({
	Name = "FOV",
	Default = Core.Features.FOV.Value,
	Minimum = 0,
	Maximum = 120,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.FOV.Value = value
	end,
}, "FOVSlider")

Core.Keybinds.FOV = sections.mobility_left:Keybind({
	Name = "FOV Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.FOV.Enabled = not Core.Features.FOV.Enabled
			FOV:UpdateState(Core.Features.FOV.Enabled)
		end
	end,
}, "FOVKeybind")

Gravity = sections.mobility_left:Toggle({
	Name = "Gravity",
	Default = Core.Features.Gravity.Enabled,
	Callback = function(enabled)
		Core.Features.Gravity.Enabled = enabled

		if enabled then
			Core.Connections.Gravity = Services.RunService.PreRender:Connect(function()
				workspace.Gravity = Core.Features.Gravity.Value
			end)
		else
			if Core.Connections.Gravity then
				Core.Connections.Gravity:Disconnect()
				Core.Connections.Gravity = nil
			end

			workspace.Gravity = 196.2
		end
	end,
}, "Gravity")

sections.mobility_left:Slider({
	Name = "Gravity",
	Default = Core.Features.Gravity.Value,
	Minimum = 0,
	Maximum = 300,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v)
		Core.Features.Gravity.Value = v
	end,
}, "GravitySlider")

Core.Keybinds.Gravity = sections.mobility_left:Keybind({
	Name = "Gravity Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Gravity.Enabled = not Core.Features.Gravity.Enabled
			Gravity:UpdateState(Core.Features.Gravity.Enabled)
		end
	end,
}, "GravityKeybind")

Phase = sections.mobility_right:Toggle({
	Name = "Phase",
	Default = Core.Features.Phase.Enabled,
	Callback = function(enabled)
		Core.Features.Phase.Enabled = enabled

		if enabled then
			Core.Features.Phase.OriginalCollision = {}

			Core.Connections.Phase = Services.RunService.PreRender:Connect(function()
				local character = LocalPlayer.Character
				if not character then return end
				
				for _, part in next, character:GetDescendants() do
					if part:IsA("BasePart") and Core.Features.Phase.OriginalCollision[part] == nil then
						Core.Features.Phase.OriginalCollision[part] = part.CanCollide
					end
				end

				for part in next, Core.Features.Phase.OriginalCollision do
					if part and part.Parent then
						part.CanCollide = false
					end
				end
			end)
		else
			for part, canCollide in next, Core.Features.Phase.OriginalCollision do
				if part and part.Parent then
					part.CanCollide = canCollide
				end
			end

			Core.Features.Phase.OriginalCollision = {}

			if Core.Connections.Phase then
				Core.Connections.Phase:Disconnect()
				Core.Connections.Phase = nil
			end
		end
	end,
}, "Phase")

Core.Keybinds.Phase = sections.mobility_right:Keybind({
	Name = "Phase Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.Phase.Enabled = not Core.Features.Phase.Enabled
			Phase:UpdateState(Core.Features.Phase.Enabled)
		end
	end,
}, "PhaseKeybind")

LongJump = sections.mobility_right2:Toggle({
	Name = "Long Jump",
	Default = Core.Features.LongJump.Enabled,
	Callback = function(enabled)
		Core.Features.LongJump.Enabled = enabled

		if enabled then
			local can_boost = true

			Core.Connections.LongJump = Services.RunService.PreRender:Connect(function()
				local character, humanoid, root = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not root then return end

				if humanoid:GetState() == Enum.HumanoidStateType.Jumping and can_boost then
					local direction = root.CFrame.LookVector * Core.Features.LongJump.Boost
					root.Velocity += Vector3.new(direction.X, Core.Features.LongJump.Height, direction.Z)
					can_boost = false
				elseif humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
					can_boost = true
				end
			end)
		else
			if Core.Connections.LongJump then
				Core.Connections.LongJump:Disconnect()
				Core.Connections.LongJump = nil
			end
		end
	end,
}, "LongJump")

sections.mobility_right2:Slider({
	Name = "Height",
	Default = Core.Features.LongJump.Height,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.LongJump.Height = value
	end,
}, "LongJumpHeight")

sections.mobility_right2:Slider({
	Name = "Boost",
	Default = Core.Features.LongJump.Boost,
	Minimum = 0,
	Maximum = 500,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.LongJump.Boost = value
	end,
}, "LongJumpBoost")

Core.Keybinds.LongJump = sections.mobility_right2:Keybind({
	Name = "Long Jump Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.LongJump.Enabled = not Core.Features.LongJump.Enabled
			LongJump:UpdateState(Core.Features.LongJump.Enabled)
		end
	end,
}, "LongJumpKeybind")

WallClimb = sections.mobility_right3:Toggle({
	Name = "Wall Climb",
	Default = Core.Features.WallClimb.Enabled,
	Callback = function(enabled)
		Core.Features.WallClimb.Enabled = enabled

		if enabled then
			Core.Connections.WallClimb = Services.RunService.PreRender:Connect(function()
				local character, humanoid, root = Core:GetParts(LocalPlayer)
				if not character or not root then return end

				local ray_origin = root.Position
				local ray_direction = root.CFrame.LookVector * 2

				local params = RaycastParams.new()
				params.FilterDescendantsInstances = { character }
				params.FilterType = Enum.RaycastFilterType.Exclude

				local hit = workspace:Raycast(ray_origin, ray_direction, params)
				if not hit then return end

				local upperOrigin = ray_origin + Vector3.new(0, 2.5, 0)
				local upperHit = workspace:Raycast(upperOrigin, ray_direction, params)

				if upperHit then
					root.Velocity = Vector3.new(
						root.Velocity.X,
						Core.Features.WallClimb.Speed,
						root.Velocity.Z
					)
				else
					root.CFrame += root.CFrame.LookVector * 1.2
					root.Velocity = Vector3.zero
				end
			end)
		else
			if Core.Connections.WallClimb then
				Core.Connections.WallClimb:Disconnect()
				Core.Connections.WallClimb = nil
			end
		end
	end,
}, "WallClimb")

sections.mobility_right3:Slider({
	Name = "Speed",
	Default = Core.Features.WallClimb.Speed,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(value)
		Core.Features.WallClimb.Speed = value
	end,
}, "WallClimbSpeed")

Core.Keybinds.WallClimb = sections.mobility_right3:Keybind({
	Name = "Wall Climb Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.WallClimb.Enabled = not Core.Features.WallClimb.Enabled
			WallClimb:UpdateState(Core.Features.WallClimb.Enabled)
		end
	end,
}, "WallClimbKeybind")

SpinBot = sections.mobility_right4:Toggle({
	Name = "Spin Bot",
	Default = Core.Features.SpinBot.Enabled,
	Callback = function(enabled)
		Core.Features.SpinBot.Enabled = enabled

		if enabled then
			Core.Connections.SpinBot = Services.RunService.PreRender:Connect(function(delta)
				local character, humanoid, root = Core:GetParts(LocalPlayer)
				if not character or not humanoid or not root then return end

				humanoid.AutoRotate = false

				local rotation = math.rad(Core.Features.SpinBot.Speed) * delta * 60
				root.CFrame *= CFrame.Angles(0, rotation, 0)
			end)
		else
			if Core.Connections.SpinBot then
				Core.Connections.SpinBot:Disconnect()
				Core.Connections.SpinBot = nil
			end

			local character, humanoid = Core:GetParts(LocalPlayer)
			if humanoid then
				humanoid.AutoRotate = true
			end
		end
	end,
}, "SpinBot")

sections.mobility_right4:Slider({
	Name = "Speed",
	Default = Core.Features.SpinBot.Speed,
	Minimum = 0,
	Maximum = 100,
	DisplayMethod = "Value",
	Precision = 1,
	Callback = function(v)
		Core.Features.SpinBot.Speed = v
	end,
}, "SpinBotSpeed")

Core.Keybinds.SpinBot = sections.mobility_right4:Keybind({
	Name = "Spin Bot Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.SpinBot.Enabled = not Core.Features.SpinBot.Enabled
			SpinBot:UpdateState(Core.Features.SpinBot.Enabled)
		end
	end,
}, "SpinBotKeybind")

BunnyHop = sections.mobility_right5:Toggle({
	Name = "Bunny Hop",
	Default = Core.Features.BunnyHop.Enabled,
	Callback = function(enabled)
		Core.Features.BunnyHop.Enabled = enabled

		if enabled then
			Core.Connections.BunnyHop = Services.RunService.PreRender:Connect(function(delta)
				local character = LocalPlayer.Character
				if not character then return end

				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid then return end

				if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		else
			if Core.Connections.BunnyHop then
				Core.Connections.BunnyHop:Disconnect()
				Core.Connections.BunnyHop = nil
			end
		end
	end,
}, "BunnyHop")

Core.Keybinds.BunnyHop = sections.mobility_right5:Keybind({
	Name = "Bunny Hop Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.BunnyHop.Enabled = not Core.Features.BunnyHop.Enabled
			BunnyHop:UpdateState(Core.Features.BunnyHop.Enabled)
		end
	end,
}, "BunnyHopKeybind")

--[[ RENDER ]]--

local EspInstance = nil
PlayerESP = sections.render_left:Toggle({
	Name = "Player ESP",
	Default = false,
	Callback = function(enabled)
		Core.Features.PlayerESP.Enabled = enabled

		if enabled then
			EspInstance = PlayerESPLib.new({
				Box = Core.Features.PlayerESP.Box,
				Chams = Core.Features.PlayerESP.Chams,
				ChamsFill = Core.Features.PlayerESP.ChamsFill,
				Tracer = Core.Features.PlayerESP.Tracer,
				Arrows = Core.Features.PlayerESP.Arrows,
				Skeleton = Core.Features.PlayerESP.Skeleton,
				Name = Core.Features.PlayerESP.Name,
				Rainbow = Core.Features.PlayerESP.Rainbow,
				DefaultColor = Core.Features.PlayerESP.DefaultColor,
				ChamsColor = Core.Features.PlayerESP.ChamsColor,
				ChamsOutline = Core.Features.PlayerESP.ChamsOutline,
				MaxDistance = Core.Features.PlayerESP.MaxDistance
			})
			
			EspInstance:Enable()
		else
			if EspInstance then
				EspInstance:Disable()
				EspInstance = nil
			end
		end
	end,
}, "PlayerESP")

sections.render_left:Toggle({
	Name = "Box",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Box = state
		
		if EspInstance then
			EspInstance.Box = state
		end
	end,
}, "PlayerESPBox")

sections.render_left:Toggle({
	Name = "Chams",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Chams = state

		if EspInstance then
			EspInstance.Chams = state
		end
	end,
}, "PlayerESPChams")

sections.render_left:Toggle({
	Name = "Chams Fill",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.ChamsFill = state

		if EspInstance then
			EspInstance.ChamsFill = state
		end
	end,
}, "PlayerESPChamsFill")

sections.render_left:Toggle({
	Name = "Tracer",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Tracer = state
		
		if EspInstance then
			EspInstance.Tracer = state
		end
	end,
}, "PlayerESPTracer")

sections.render_left:Toggle({
	Name = "Skeleton",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Skeleton = state
		
		if EspInstance then
			EspInstance.Skeleton = state
		end
	end,
}, "PlayerESPSkeleton")

sections.render_left:Toggle({
	Name = "Arrows",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Arrows = state
		
		if EspInstance then
			EspInstance.Arrows = state
		end
	end,
}, "PlayerESPArrows")

sections.render_left:Toggle({
	Name = "Name",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Name = state
		
		if EspInstance then
			EspInstance.Name = state
		end
	end,
}, "PlayerESPName")

sections.render_left:Toggle({
	Name = "Rainbow",
	Default = false,
	Callback = function(state)
		Core.Features.PlayerESP.Rainbow = state
		
		if EspInstance then
			EspInstance.Rainbow = state
		end
	end,
}, "PlayerESPRainbow")

sections.render_left:Colorpicker({
	Name = "Player ESP Color",
	Default = Core.Features.PlayerESP.DefaultColor,
	Callback = function(color)
		Core.Features.PlayerESP.DefaultColor = color

		if EspInstance then
			EspInstance.DefaultColor = color

			for _, target_player in next, Services.Players:GetPlayers() do
				if target_player ~= LocalPlayer then
					EspInstance:SetColor(target_player, color)
				end
			end
		end
	end,
}, "PlayerESPColor")

sections.render_left:Colorpicker({
	Name = "Chams Color",
	Default = Core.Features.PlayerESP.ChamsColor,
	Callback = function(color)
		Core.Features.PlayerESP.ChamsColor = color

		if EspInstance then
			EspInstance.ChamsColor = color
		end
	end,
}, "ChamsColorColor")

sections.render_left:Colorpicker({
	Name = "Chams Outline Color",
	Default = Core.Features.PlayerESP.ChamsOutline,
	Callback = function(color)
		Core.Features.PlayerESP.ChamsOutline = color

		if EspInstance then
			EspInstance.ChamsOutline = color
		end
	end,
}, "ChamsOutlineColor")

Core.Keybinds.PlayerESP = sections.render_left:Keybind({
	Name = "Player ESP Keybind",
	Blacklist = false,
	onBindHeld = function(held)
		if held then
			Core.Features.PlayerESP.Enabled = not Core.Features.PlayerESP.Enabled
			PlayerESP:UpdateState(Core.Features.PlayerESP.Enabled)
		end
	end,
}, "PlayerESPKeybind")

--[[ CONFIG ]]--

ConfigDropdown = sections.settings_left:Dropdown({
	Name = "Configs",
	Callback = function(selected)
		Core.Config.Selected = selected
	end,
}, "ConfigDropdown")

Core:RefreshConfigs(ConfigDropdown)

sections.settings_left:Input({
	Name = "Config Name",
	Placeholder = "Enter name",
	Callback = function(text)
		Core.Config.NameInput = text
	end,
}, "ConfigNameInput")

sections.settings_left:Button({
	Name = "Save Config",
	Callback = function()
		if Core.Config.NameInput == "" then
			window:Notify({
				Title = "Config",
				Description = "Config name cannot be empty",
				Lifetime = 3
			})
			return
		end

		MacLib:SaveConfig(Core.Config.NameInput)
		Core:RefreshConfigs(ConfigDropdown)

		window:Notify({
			Title = "Config",
			Description = "Saved config: " .. Core.Config.NameInput,
			Lifetime = 3
		})
	end
})

sections.settings_left:Button({
	Name = "Load Config",
	Callback = function()
		if not Core.Config.Selected then return end

		MacLib:LoadConfig(Core.Config.Selected)
		Core:RefreshConfigs(ConfigDropdown)

		window:Notify({
			Title = "Config",
			Description = "Loaded config: " .. Core.Config.Selected,
			Lifetime = 3
		})
	end
})

sections.settings_left:Button({
	Name = "Delete Config",
	Callback = function()
		if not Core.Config.Selected then return end

		local path = folder_name .. "/settings/" .. Core.Config.Selected .. ".json"
		if isfile(path) then
			delfile(path)
		end

		Core.Config.Selected = nil
		Core:RefreshConfigs(ConfigDropdown)

		window:Notify({
			Title = "Config",
			Description = "Config deleted",
			Lifetime = 3
		})
	end
})


window.onUnloaded(function()
	if EspInstance then
		EspInstance:Disable()
		EspInstance = nil
	end
	
	for _, keybind in next, Core.Keybinds do
		if keybind and keybind.Unbind then
			keybind:Unbind()
		end
	end

	Core.Keybinds = {}

	for _, connection in next, Core.Connections do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end
	end
	
	Core.Connections = {}
end)
