local syde = loadstring(game:HttpGet("https://raw.githubusercontent.com/essencejs/syde/refs/heads/main/source", true))()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Hapus underwater detection
local folder = workspace:FindFirstChild(player.Name)
if folder then
    local uw = folder:FindFirstChild("UnderwaterDetection")
    if uw then uw:Destroy() end
end

-- Setup lingkungan
local ocean = workspace:FindFirstChild("OceanTile1")
local wavemath = require(game.ReplicatedStorage.WaveMath)
local floatForce
local buoyancyEnabled = false
local cashEnabled = false
local creaturesEnabled = false
local cashConnection
local creatureConnection

-- Inisialisasi GUI Syde
syde:Load({
	Logo = '7488932274',
	Name = 'NoHub - Noctyra',
	Status = 'Stable',
	Accent = Color3.fromRGB(251, 144, 255),
	HitBox = Color3.fromRGB(251, 144, 255),
	AutoLoad = false,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = 'NoHub',
		FileName = "config"
	}
})

local Window = syde:Init({
	Title = 'NoHub Complete',
	SubText = 'All Library Features'
})

-- ✅ PERBAIKAN #1: Tambahkan '=' yang hilang
local MainTab = Window:InitTab('Main')

-- Toggle: No Underwater
MainTab:Toggle({
	Title = 'No Underwater',
	Value = false,
	CallBack = function(value)
		-- ✅ PERBAIKAN #2: Langsung assign value (bukan not value)
		buoyancyEnabled = value
		
		if not buoyancyEnabled and floatForce then
			floatForce:Destroy()
			floatForce = nil
		end
		
		syde:Notify({
			Title = 'No Underwater',
			Content = 'Toggle is now ' .. (value and 'ON' or 'OFF'),
			Duration = 1
		})
	end,
})

-- Toggle: Inf Money
MainTab:Toggle({
	Title = 'Inf Money',
	Value = false,
	CallBack = function(value)
		-- ✅ PERBAIKAN #2: Langsung assign value
		cashEnabled = value
		
		if cashConnection then
			cashConnection:Disconnect()
			cashConnection = nil
		end

		if cashEnabled then
			local lastGrant = tick()
			cashConnection = game:GetService("RunService").Heartbeat:Connect(function()
				if not cashEnabled then return end
				local now = tick()
				-- ✅ PERBAIKAN #3: Ganti wait() dengan time-check aman
				if now - lastGrant >= 1.2 then
					lastGrant = now
					local args = {
						{
							type = "Money",
							rarity = "Uncommon",
							value = 1000,
							color = Color3.new(0.3921568691730499, 0.7843137383460999, 0.3921568691730499),
							icon = "\240\159\146\181",
							displayName = "1,000 Cash"
						}
					}
					pcall(function()
						game:GetService("ReplicatedStorage"):WaitForChild("GrantReward"):InvokeServer(unpack(args))
					end)
				end
			end)
		end
		
		syde:Notify({
			Title = 'Inf Money',
			Content = 'Toggle is now ' .. (value and 'ON' or 'OFF'),
			Duration = 1
		})
	end,
})

-- ✅ PERBAIKAN #4: Definisikan grantReward sekali di awal
local grantReward = game:GetService("ReplicatedStorage"):WaitForChild("GrantReward")

-- Toggle: Get Creatures
MainTab:Toggle({
	Title = 'Get Creatures',
	Value = false,
	CallBack = function(value)
		-- ✅ PERBAIKAN #2: Langsung assign value
		creaturesEnabled = value
		
		if creatureConnection then
			creatureConnection:Disconnect()
			creatureConnection = nil
		end

		if creaturesEnabled then
			local creaturesList = {
				{rarity = "Common", name = "Archelon"},
				{rarity = "Rare", name = "Metriorhynchus"},
				{rarity = "Legendary", name = "Mosasaurus"}
			}
			local lastCycle = tick()
			creatureConnection = game:GetService("RunService").Heartbeat:Connect(function()
				if not creaturesEnabled then return end
				local now = tick()
				-- ✅ PERBAIKAN #3: Rate-limit dengan aman
				if now - lastCycle >= 2.5 then
					lastCycle = now
					for _, info in ipairs(creaturesList) do
						pcall(function()
							grantReward:InvokeServer({
								type = "SeaCreature",
								rarity = info.rarity,
								creatureId = 1,
								value = 1,
								color = Color3.new(0.8313725590705872, 0.8313725590705872, 0.8313725590705872),
								icon = "\240\159\144\162",
								displayName = info.name
							})
						end)
						-- Delay kecil antar creature (aman karena di luar Heartbeat loop utama)
						wait(0.3)
					end
				end
			end)
		end
		
		-- ✅ PERBAIKAN #5: Perbaiki title notifikasi
		syde:Notify({
			Title = 'Get Creatures',
			Content = 'Toggle is now ' .. (value and 'ON' or 'OFF'),
			Duration = 1
		})
	end,
})

-- Sistem buoyancy
local function keepAboveWater()
	if not buoyancyEnabled or not character or not rootPart or not humanoid then return end
	if not ocean or not wavemath then return end
	
	local pos = rootPart.Position
	-- ✅ PERBAIKAN #6: Wave calculation yang lebih akurat
	local waveHeight = wavemath.GetPosition(pos.X, pos.Z, workspace:GetServerTimeNow()).Y
	local waveY = ocean.Position.Y + math.abs(waveHeight)
	
	if pos.Y < waveY then
		if not floatForce then
			floatForce = Instance.new("VectorForce")
			floatForce.Name = "floatForce"
			floatForce.Attachment0 = rootPart:FindFirstChild("RootAttachment") or Instance.new("Attachment")
			if not rootPart:FindFirstChild("RootAttachment") then 
				floatForce.Attachment0.Name = "RootAttachment"
				floatForce.Attachment0.Parent = rootPart 
			end
			floatForce.RelativeTo = Enum.ActuatorRelativeTo.World
			floatForce.Force = Vector3.new(0, 0, 0)
			floatForce.Parent = rootPart
		end
		local mass = rootPart.AssemblyMass
		floatForce.Force = Vector3.new(0, math.clamp(mass * 150 * (waveY - pos.Y), 0, mass * 2000), 0)
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	elseif floatForce then
		floatForce:Destroy()
		floatForce = nil
	end
end

game:GetService("RunService").Heartbeat:Connect(keepAboveWater)

-- Anti-ragdoll underwater
if character:FindFirstChild("IsRagdoll") then
	character.IsRagdoll.Changed:Connect(function()
		if buoyancyEnabled and humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end)
end

-- Auto-reconnect character
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	rootPart = newChar:WaitForChild("HumanoidRootPart")
	humanoid = newChar:WaitForChild("Humanoid")
	wait(1)
	
	if character:FindFirstChild("IsRagdoll") then
		character.IsRagdoll.Changed:Connect(function()
			if buoyancyEnabled and humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
end)

syde:Notify({
	Title = 'NoHub Complete',
	Content = 'All features loaded successfully!',
	Duration = 5
})
