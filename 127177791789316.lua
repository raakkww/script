local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
	Name = "Build a Haven Script",
	LoadingTitle = "Build a Haven",
	LoadingSubtitle = "",
	ConfigurationSaving = {Enabled = false},
	KeySystem = false,
})

local MainTab = Window:CreateTab("Main", nil)
local MainSection = MainTab:CreateSection("Main Menu")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- ================= VARIABLES =================
local noclipOn = false
local autoCoinOn = false
local interactRange = 10
local walkSpeed = 16
local coinList = {}   -- cache coin ProximityPrompt
local lastTick = 0

-- ================= INFINITE JUMP =================
_G.infinjump = false
_G.infinJumpStarted = false

MainTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "infjump",
	Callback = function(val)
		_G.infinjump = val
		if not _G.infinJumpStarted then
			_G.infinJumpStarted = true
			UIS.JumpRequest:Connect(function()
				if _G.infinjump then
					local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
				end
			end)
		end
	end
})

-- ================= WALK SPEED =================
MainTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 80},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = walkSpeed,
	Flag = "ws",
	Callback = function(val)
		walkSpeed = val
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
			plr.Character.Humanoid.WalkSpeed = walkSpeed
		end
	end
})

-- ================= NOCLIP =================
MainTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Flag = "noclip",
	Callback = function(val)
		noclipOn = val
	end
})

-- ================= AUTO COIN =================
MainTab:CreateToggle({
	Name = "Auto Coin/Visitor",
	CurrentValue = false,
	Flag = "autocoin",
	Callback = function(val)
		autoCoinOn = val
	end
})

-- ================= HELPER FUNCTIONS =================
local function getClosestPart(obj)
	if obj:IsA("BasePart") then
		return obj
	elseif obj:IsA("Model") then
		if obj.PrimaryPart then
			return obj.PrimaryPart
		else
			for _,p in pairs(obj:GetChildren()) do
				if p:IsA("BasePart") then
					return p
				end
			end
		end
	end
	return nil
end

local function interactWith(v)
	if v:IsA("ProximityPrompt") then
		pcall(function()
			fireproximityprompt(v, 0, true)
		end)
	end
end

-- ================= CACHE COINS =================
local function updateCoinList()
	coinList = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") and v.Parent then
			table.insert(coinList, v)
		end
	end
end

updateCoinList()

workspace.DescendantAdded:Connect(function(v)
	if v:IsA("ProximityPrompt") and v.Parent then
		table.insert(coinList, v)
	end
end)

workspace.DescendantRemoving:Connect(function(v)
	for i,p in pairs(coinList) do
		if v == p or v == p.Parent then
			table.remove(coinList, i)
		end
	end
end)

-- ================= RUN SERVICE =================
RunService.Heartbeat:Connect(function(dt)
	-- Noclip
	if noclipOn and plr.Character then
		for _,part in pairs(plr.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	-- Auto Coin (low lag)
	lastTick = lastTick + dt
	if lastTick >= 0.2 then
		lastTick = 0
		if autoCoinOn and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart
			for _,v in pairs(coinList) do
				local part = getClosestPart(v.Parent)
				if part and (hrp.Position - part.Position).Magnitude <= interactRange then
					interactWith(v)
				end
			end
		end
	end
end)
