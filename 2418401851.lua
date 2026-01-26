-- Architect's GUI (client-side)
-- MUST be a LocalScript running on the client (StarterPlayerScripts recommended).
-- Features:
--  - Hop Up/Down: teleports you to the closest platform ABOVE/BELOW your closest platform (same X/Z)
--  - Teleport to Pellet / MirrorPellet (Workspace/ServerOrb)
--  - Teleport to bottom floor (BigWindow anywhere in Workspace descendants)
--  - Closest platform list for all players (click a name to TP to their closest platform)
--  - X button deletes GUI, P toggles show/hide

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	warn("GUI must run as a LocalScript on the client.")
	return
end

local player = Players.LocalPlayer

-- ✅ Admin whitelist
local ADMINS = {
	[UserID Here] = true,
}

if not ADMINS[player.UserId] then
	warn("GUI: not an admin. GUI will not load.")
	return
end

local playerGui = player:WaitForChild("PlayerGui")

local GUI_NAME = "ArchitectsGui"
local gui = playerGui:FindFirstChild(GUI_NAME)

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local function getHRP(plr: Player)
	local char = plr.Character or plr.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart", 5)
end

-- ===== Finders =====
local function findOrb(which)
	local folder = workspace:FindFirstChild("ServerOrb")
	if not folder then return nil end
	return folder:FindFirstChild(which)
end

local function norm(s)
	return (tostring(s):gsub("%s+", ""))
end

local function findBigWindow()
	local direct = workspace:FindFirstChild("BigWindow")
	if direct then return direct end

	local deep = workspace:FindFirstChild("BigWindow", true)
	if deep then return deep end

	for _, d in ipairs(workspace:GetDescendants()) do
		if norm(d.Name) == "BigWindow" then
			return d
		end
	end
	return nil
end

-- ===== Platform cache / helpers =====
local function getPosForPlatform(inst: Instance): Vector3?
	-- Platforms are Models like L0X0Z0. Prefer Base part.
	if inst:IsA("Model") then
		local base = inst:FindFirstChild("Base", true)
		if base and base:IsA("BasePart") then
			return base.Position
		end
		local anyPart = inst:FindFirstChildWhichIsA("BasePart", true)
		if anyPart then
			return anyPart.Position
		end
		return inst:GetPivot().Position
	elseif inst:IsA("BasePart") then
		return inst.Position
	end
	return nil
end

local function getTeleportCFrame(inst: Instance): CFrame?
	if inst:IsA("BasePart") then
		return inst.CFrame
	end
	if inst:IsA("Model") then
		local base = inst:FindFirstChild("Base", true)
		if base and base:IsA("BasePart") then
			return base.CFrame
		end
		local anyPart = inst:FindFirstChildWhichIsA("BasePart", true)
		if anyPart then
			return anyPart.CFrame
		end
		return inst:GetPivot()
	end
	local anyPart = inst:FindFirstChildWhichIsA("BasePart", true)
	if anyPart then
		return anyPart.CFrame
	end
	return nil
end

local function tpTo(inst: Instance)
	if not inst then
		return false, "Target not found"
	end

	local hrp = getHRP(player)
	if not hrp then
		return false, "No HumanoidRootPart"
	end

	local cf = getTeleportCFrame(inst)
	if not cf then
		return false, "No teleport point"
	end

	hrp.CFrame = cf + Vector3.new(0, 4, 0)
	return true, "Teleported"
end

-- Parse names like: L0X0Z0 (supports negatives)
local function parsePlatformName(name: string)
	local lStr, xStr, zStr = string.match(name, "^L(-?%d+)X(-?%d+)Z(-?%d+)$")
	if not lStr then return nil end
	return tonumber(lStr), tonumber(xStr), tonumber(zStr)
end

local platformCache = {} -- array {inst, name, pos, L, X, Z}
local cacheDirty = true

local function rebuildPlatformCache()
	platformCache = {}
	local folder = workspace:FindFirstChild("Platforms")
	if not folder then
		cacheDirty = false
		return
	end

	for _, inst in ipairs(folder:GetChildren()) do
		local L, X, Z = parsePlatformName(inst.Name)
		local pos = getPosForPlatform(inst)
		if L and X and Z and pos then
			table.insert(platformCache, {
				inst = inst,
				name = inst.Name,
				pos = pos,
				L = L, X = X, Z = Z,
			})
		end
	end

	cacheDirty = false
end

local function ensureCache()
	if cacheDirty then rebuildPlatformCache() end
end

do
	local folder = workspace:FindFirstChild("Platforms")
	if folder then
		folder.ChildAdded:Connect(function() cacheDirty = true end)
		folder.ChildRemoved:Connect(function() cacheDirty = true end)
	end
end

local function nearestPlatformForPos(fromPos: Vector3)
	ensureCache()
	local best, bestDist = nil, math.huge
	for _, p in ipairs(platformCache) do
		local d = (fromPos - p.pos).Magnitude
		if d < bestDist then
			bestDist = d
			best = p
		end
	end
	return best, bestDist
end

local function hopRelative(direction: number)
	-- direction: +1 up, -1 down
	local hrp = getHRP(player)
	if not hrp then return false, "No character" end

	local current, dist = nearestPlatformForPos(hrp.Position)
	if not current then return false, "No platforms found" end

	-- find the nearest platform with same X/Z but L greater/less
	local bestCandidate, bestLDelta = nil, math.huge
	for _, p in ipairs(platformCache) do
		if p.X == current.X and p.Z == current.Z then
			local deltaL = p.L - current.L
			if direction > 0 and deltaL > 0 and deltaL < bestLDelta then
				bestLDelta = deltaL
				bestCandidate = p
			elseif direction < 0 and deltaL < 0 and math.abs(deltaL) < bestLDelta then
				bestLDelta = math.abs(deltaL)
				bestCandidate = p
			end
		end
	end

	if not bestCandidate then
		return false, (direction > 0 and "No higher platform found for this X/Z" or "No lower platform found for this X/Z")
	end

	local ok, msg = tpTo(bestCandidate.inst)
	if ok then
		return true, ("Hopped -> %s (from %s, %.1f studs away)"):format(bestCandidate.name, current.name, dist or 0)
	end
	return false, msg
end

-- ===== Build / rebuild GUI =====
if not gui then
	gui = mk("ScreenGui", { Name = GUI_NAME, ResetOnSpawn = false }, playerGui)
else
	local oldPanel = gui:FindFirstChild("Panel")
	if oldPanel then oldPanel:Destroy() end
end

local panel = mk("Frame", {
	Name = "Panel",
	Size = UDim2.new(0, 340, 0, 540),
	Position = UDim2.new(0, 20, 0.5, -270),
	BackgroundTransparency = 0.1,
	Active = true,
	Draggable = true,
}, gui)
mk("UICorner", { CornerRadius = UDim.new(0, 12) }, panel)

mk("TextLabel", {
	Size = UDim2.new(1, -60, 0, 28),
	Position = UDim2.new(0, 10, 0, 10),
	BackgroundTransparency = 1,
	Text = "GUI",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local closeBtn = mk("TextButton", {
	Size = UDim2.new(0, 30, 0, 24),
	Position = UDim2.new(1, -40, 0, 12),
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextSize = 14,
}, panel)
mk("UICorner", { CornerRadius = UDim.new(0, 8) }, closeBtn)

closeBtn.MouseButton1Click:Connect(function()
	if gui then gui:Destroy() end
end)

local function button(y, text)
	local b = mk("TextButton", {
		Size = UDim2.new(1, -20, 0, 36),
		Position = UDim2.new(0, 10, 0, y),
		Text = text,
		Font = Enum.Font.Gotham,
		TextSize = 14,
	}, panel)
	mk("UICorner", { CornerRadius = UDim.new(0, 10) }, b)
	return b
end

-- Floor hop buttons (no coordinate input)
local hopUp = mk("TextButton", {
	Size = UDim2.new(0.5, -15, 0, 36),
	Position = UDim2.new(0, 10, 0, 50),
	Text = "Hop Up (closest)",
	Font = Enum.Font.Gotham,
	TextSize = 14,
}, panel)
mk("UICorner", { CornerRadius = UDim.new(0, 10) }, hopUp)

local hopDown = mk("TextButton", {
	Size = UDim2.new(0.5, -15, 0, 36),
	Position = UDim2.new(0.5, 5, 0, 50),
	Text = "Hop Down (closest)",
	Font = Enum.Font.Gotham,
	TextSize = 14,
}, panel)
mk("UICorner", { CornerRadius = UDim.new(0, 10) }, hopDown)

local btnPellet = button(95, "Teleport to Pellet")
local btnMirror = button(137, "Teleport to MirrorPellet")
local btnBottom = button(179, "Teleport to bottom floor")

local status = mk("TextLabel", {
	Size = UDim2.new(1, -20, 0, 24),
	Position = UDim2.new(0, 10, 0, 225),
	BackgroundTransparency = 1,
	Text = "Ready. Press P to show/hide.",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTransparency = 0.2,
}, panel)

local function setStatus(msg)
	if status and status.Parent then status.Text = msg end
end

hopUp.MouseButton1Click:Connect(function()
	local ok, msg = hopRelative(1)
	setStatus(ok and msg or ("Hop Up failed: " .. msg))
end)

hopDown.MouseButton1Click:Connect(function()
	local ok, msg = hopRelative(-1)
	setStatus(ok and msg or ("Hop Down failed: " .. msg))
end)

btnPellet.MouseButton1Click:Connect(function()
	local inst = findOrb("Pellet")
	local ok, msg = tpTo(inst)
	setStatus(ok and "OK: Pellet" or ("Fail: " .. msg))
end)

btnMirror.MouseButton1Click:Connect(function()
	local inst = findOrb("MirrorPellet")
	local ok, msg = tpTo(inst)
	setStatus(ok and "OK: MirrorPellet" or ("Fail: " .. msg))
end)

btnBottom.MouseButton1Click:Connect(function()
	local inst = findBigWindow()
	if not inst then
		setStatus("Fail: BigWindow not found (Workspace scan)")
		return
	end
	local ok, msg = tpTo(inst)
	setStatus(ok and "OK: bottom floor" or ("Fail: " .. msg))
end)

-- ===== Closest platform to players UI =====
mk("TextLabel", {
	Size = UDim2.new(1, -20, 0, 18),
	Position = UDim2.new(0, 10, 0, 260),
	BackgroundTransparency = 1,
	Text = "Closest Platform to Players (click a name to TP)",
	Font = Enum.Font.GothamSemibold,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
}, panel)

local scroll = mk("ScrollingFrame", {
	Size = UDim2.new(1, -20, 0, 250),
	Position = UDim2.new(0, 10, 0, 280),
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 6,
}, panel)
mk("UICorner", { CornerRadius = UDim.new(0, 10) }, scroll)

mk("UIListLayout", {
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, scroll)

local rowPool = {}  -- [Player] = TextButton
local rowConns = {} -- [Player] = connection

local function getHRPFor(plr: Player)
	local char = plr.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function ensureRow(plr: Player)
	if rowPool[plr] then return rowPool[plr] end

	local btn = mk("TextButton", {
		Size = UDim2.new(1, -10, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = plr.Name .. " -> ...",
	}, scroll)

	rowPool[plr] = btn

	rowConns[plr] = btn.MouseButton1Click:Connect(function()
		local hrp = getHRPFor(plr)
		if not hrp then
			setStatus(("Can't TP: %s has no character"):format(plr.Name))
			return
		end

		local closest = nearestPlatformForPos(hrp.Position)
		if not closest then
			setStatus("Can't TP: no platforms found.")
			return
		end

		local ok, msg = tpTo(closest.inst)
		setStatus(ok and ("TP -> " .. plr.Name .. " closest: " .. closest.name) or ("TP failed: " .. msg))
	end)

	return btn
end

local function cleanupRows()
	for plr, btn in pairs(rowPool) do
		if not plr.Parent then
			if rowConns[plr] then rowConns[plr]:Disconnect() end
			rowConns[plr] = nil
			btn:Destroy()
			rowPool[plr] = nil
		end
	end
end

task.spawn(function()
	while gui and gui.Parent do
		cleanupRows()
		ensureCache()

		for _, plr in ipairs(Players:GetPlayers()) do
			local row = ensureRow(plr)
			local hrp = getHRPFor(plr)

			if not hrp then
				row.Text = ("%s -> (no character)"):format(plr.Name)
			else
				local closest, dist = nearestPlatformForPos(hrp.Position)
				if closest then
					row.Text = ("%s -> %s (%.1f studs)"):format(plr.Name, closest.name, dist or 0)
				else
					row.Text = ("%s -> (no platforms found)"):format(plr.Name)
				end
			end
		end

		task.wait(0.5)
	end
end)

-- Toggle GUI with P
local shown = true
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.P then
		shown = not shown
		if panel and panel.Parent then
			panel.Visible = shown
		end
	end
end)

print("GUI loaded for", player.Name)
setStatus("Ready. Press P to show/hide.")
