local ui = Instance.new("ScreenGui")
ui.Parent = game.Players.LocalPlayer.PlayerGui

ui.ResetOnSpawn = false

local background = Instance.new("Frame")
local backgroundStroke = Instance.new("UIStroke")
local drag = Instance.new("UIDragDetector")

local minimizeButton = Instance.new("TextButton")
local minimizeStroke = Instance.new("UIStroke")

local closebutton = Instance.new("TextButton")
local closeStroke = Instance.new("UIStroke")

local openbutton = Instance.new("TextButton")
local openStroke = Instance.new("UIStroke")

openbutton.Parent = ui
openbutton.Size = UDim2.new(0.05, 0, 0.05, 0)
openbutton.Position = UDim2.new(0.95, 0, 0.95, 0)
openbutton.Text = "Self"
openbutton.TextColor3 = Color3.new(1, 1, 1)
openbutton.BackgroundColor3 = Color3.new(0.156863, 0.0784314, 0.0941176)
openbutton.TextScaled = true
openbutton.Font = Enum.Font.GothamBold
openbutton.Visible = false
openbutton.ZIndex = 1

closebutton.Parent = background
closebutton.Size = UDim2.new(0.1, 0, 0.08, 0)
closebutton.Position = UDim2.new(0.9, 0, 0, 0)
closebutton.Text = "X"
closebutton.TextColor3 = Color3.new(1, 1, 1)
closebutton.BackgroundColor3 = Color3.new(0.156863, 0.0784314, 0.0941176)
closebutton.TextScaled = true
closebutton.Font = Enum.Font.GothamBold

closeStroke.Parent = closebutton
closeStroke.Thickness = 2
closeStroke.Color = Color3.new(0, 0, 0)
closeStroke.Transparency = 0
closebutton.ZIndex = 2
closeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

minimizeButton.Parent = background
minimizeButton.Size = UDim2.new(0.1, 0, 0.08, 0)
minimizeButton.Position = UDim2.new(0.8, 0, 0, 0)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.BackgroundColor3 = Color3.new(0.117647, 0.192157, 0.258824)
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.GothamBold

minimizeStroke.Parent =	minimizeButton
minimizeStroke.Thickness = 2
minimizeStroke.Color = Color3.new(0, 0, 0)
minimizeStroke.Transparency = 0
minimizeButton.ZIndex = 2
minimizeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

drag.Parent = background

backgroundStroke.Parent = background
backgroundStroke.Thickness = 10
backgroundStroke.Color = Color3.new(0.317647, 0.227451, 0.423529)
backgroundStroke.Transparency = 0.3
background.Parent = ui

background.ZIndex = 1

background.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
background.BackgroundTransparency = 0
background.Size = UDim2.new(0.5, 0, 0.5, 0)
background.Position = UDim2.new(0.3, 0, 0.15, 0)
background.Parent = ui


local EspButton = Instance.new("TextButton")
local EspStroke = Instance.new("UIStroke")

EspButton.Parent = background
EspButton.Size = UDim2.new(0.3, 0, 0.08, 0)
EspButton.Position = UDim2.new(0.05, 0, 0.1, 0)
EspButton.Text = "ESP"
EspButton.TextColor3 = Color3.new(1, 1, 1)
EspButton.BackgroundColor3 = Color3.new(0.156863, 0.0784314, 0.0941176)
EspButton.TextScaled = true
EspButton.Font = Enum.Font.GothamBold
EspButton.ZIndex = 2

EspStroke.Parent = EspButton
EspStroke.Thickness = 2
EspStroke.Color = Color3.new(0, 0, 0)
EspStroke.Transparency = 0
EspButton.ZIndex = 2
EspStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local fillselector = Instance.new("TextBox")
local fillstroke = Instance.new("UIStroke")

fillstroke.Parent = fillselector
fillstroke.Thickness = 2
fillstroke.Color = Color3.new(0, 0, 0)
fillstroke.Transparency = 0
fillselector.ZIndex = 2
fillstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

fillselector.Parent = background
fillselector.Size = UDim2.new(0.3, 0, 0.08, 0)
fillselector.Position = UDim2.new(0.05, 0, 0.18, 0)
fillselector.Text = "Fill Color"
fillselector.TextColor3 = Color3.new(1, 1, 1)
fillselector.BackgroundColor3 = Color3.fromHex("#d4d4d4")
fillselector.TextStrokeTransparency = 0

local outlineselec = Instance.new("TextBox")
local outlineStroke = Instance.new("UIStroke")

outlineStroke.Parent = outlineselec
outlineStroke.Thickness = 2
outlineStroke.Color = Color3.new(0, 0, 0)
outlineStroke.Transparency = 0
outlineselec.ZIndex = 2
outlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

outlineselec.Parent = background
outlineselec.Size = UDim2.new(0.3, 0, 0.08, 0)
outlineselec.Position = UDim2.new(0.05, 0, 0.25, 0)
outlineselec.Text = "Outline Color"
outlineselec.TextColor3 = Color3.new(1, 1, 1)
outlineselec.BackgroundColor3 = Color3.fromHex("#6b34eb")
outlineselec.TextStrokeTransparency = 0

local filltransselector = Instance.new("TextBox")
local filltransstroke = Instance.new("UIStroke")

filltransstroke.Parent = filltransselector
filltransstroke.Thickness = 2
filltransstroke.Color = Color3.new(0, 0, 0)
filltransstroke.Transparency = 0
filltransselector.ZIndex = 2
filltransstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

filltransselector.Parent = background
filltransselector.Size = UDim2.new(0.3, 0, 0.08, 0)
filltransselector.Position = UDim2.new(0.05, 0, 0.32, 0)
filltransselector.Text = "Fill Transparency"
filltransselector.TextColor3 = Color3.new(1, 1, 1)
filltransselector.BackgroundColor3 = Color3.new(0.780392, 0.780392, 1)
filltransselector.TextStrokeTransparency = 0

local outlinetransselector = Instance.new("TextBox")
local outlineTransStroke = Instance.new("UIStroke")

outlineTransStroke.Parent = outlinetransselector
outlineTransStroke.Thickness = 2
outlineTransStroke.Color = Color3.new(0, 0, 0)	
outlineTransStroke.Transparency = 0
outlinetransselector.ZIndex = 2
outlineTransStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

outlinetransselector.Parent = background
outlinetransselector.Size = UDim2.new(0.3, 0, 0.08, 0)
outlinetransselector.Position = UDim2.new(0.05, 0, 0.39, 0)
outlinetransselector.Text = "Outline Transparency"
outlinetransselector.TextColor3 = Color3.new(1, 1, 1)
outlinetransselector.BackgroundColor3 = Color3.new(0.780392, 0.780392, 1)
outlinetransselector.TextStrokeTransparency = 0

local ScrollShopButton = Instance.new("TextButton")
local ScrollShopStroke = Instance.new("UIStroke")

ScrollShopStroke.Parent = ScrollShopButton
ScrollShopStroke.Thickness = 2
ScrollShopStroke.Color = Color3.new(0, 0, 0)
ScrollShopStroke.Transparency = 0
ScrollShopStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

ScrollShopButton.Parent = background
ScrollShopButton.Size = UDim2.new(0.3, 0, 0.08, 0)
ScrollShopButton.Position = UDim2.new(0.4, 0, 0.1, 0)
ScrollShopButton.Text = "Travelling Merchant"
ScrollShopButton.TextColor3 = Color3.new(1, 1, 1)
ScrollShopButton.BackgroundColor3 = Color3.new(0.211765, 0.690196, 0.745098)
ScrollShopButton.TextScaled = true
ScrollShopButton.Font = Enum.Font.GothamBold
ScrollShopButton.ZIndex = 2
ScrollShopButton.TextStrokeTransparency = 0

local QuestsText = Instance.new("TextLabel")
local QuestsStroke = Instance.new("UIStroke")

QuestsStroke.Parent = QuestsText
QuestsStroke.Thickness = 2
QuestsStroke.Color = Color3.new(0, 0, 0)
QuestsStroke.Transparency = 0
QuestsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

QuestsText.Parent = background
QuestsText.Size = UDim2.new(0.3, 0, 0.08, 0)
QuestsText.Position = UDim2.new(0.7, 0, 0.1, 0)
QuestsText.Text = "World Events"
QuestsText.TextColor3 = Color3.new(1, 1, 1)
QuestsText.BackgroundColor3 = Color3.new(0.984314, 1, 0.168627)
QuestsText.TextStrokeTransparency = 0
QuestsText.TextScaled = true
QuestsText.Font = Enum.Font.GothamBold

local RollBackButton = Instance.new("TextButton")
local RollBackStroke = Instance.new("UIStroke")

RollBackStroke.Parent = RollBackButton
RollBackStroke.Thickness = 2
RollBackStroke.Color = Color3.new(0, 0, 0)
RollBackStroke.Transparency = 0
RollBackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

RollBackButton.Parent = background
RollBackButton.Size = UDim2.new(0.3, 0, 0.08, 0)
RollBackButton.Position = UDim2.new(0.4, 0, 0.3, 0)
RollBackButton.Text = "Roll Back"
RollBackButton.TextColor3 = Color3.new(1, 1, 1)
RollBackButton.BackgroundColor3 = Color3.new(1, 0.517647, 0.0980392)
RollBackButton.TextScaled = true
RollBackButton.Font = Enum.Font.GothamBold
RollBackButton.ZIndex = 2
RollBackButton.TextStrokeTransparency = 0

-- functions
local FILL_COLOR = Color3.fromHex("#d4d4d4")
local OUTLINE_COLOR = Color3.fromHex("#6b34eb")

local FILL_TRANSPARENCY = 0.91
local OUTLINE_TRANSPARENCY = 0.15

local buttonCounts = 0

local function EventButton(name , position)
	buttonCounts += 1

	local button = Instance.new("TextButton")
	local stroke = Instance.new("UIStroke")
	stroke.Parent = button
	stroke.Thickness = 2
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Transparency = 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	button.Parent = background
	button.Size = UDim2.new(0.3, 0, 0.08, 0)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.BackgroundColor3 = Color3.new(0.258824, 0, 0.558824)

	button.Position = UDim2.new(0.7, 0, 0.1 + (buttonCounts * 0.1), 0)

	button.Text = name

	button.MouseButton1Click:Connect(function()
		local plr = game.Players.LocalPlayer
		local char = plr.Character or plr.CharacterAdded:Wait()
		local hrt = char:WaitForChild("HumanoidRootPart")

		hrt.CFrame = position + Vector3.new(0, 3, 0)
	end)

	return button
end

RollBackButton.MouseButton1Up:Connect(function()
	local plr = game.Players.LocalPlayer
	local teleport = game:GetService("TeleportService")

	local GameId = 16997056665

	teleport:Teleport(GameId, plr)
end)

local Normal = workspace.WorldEvents.Normal
local activeButtons = {} -- [event] = button

local function ensureButton(event)
	if activeButtons[event] then return end
	activeButtons[event] = EventButton(event.Name, event.CFrame)
end

local function removeButton(event)
	local btn = activeButtons[event]
	if btn then
		btn:Destroy()
		activeButtons[event] = nil
		buttonCounts -= 1
	end
end

local function hookEvent(event)
	if event:FindFirstChild("DamageFolder") then
		ensureButton(event)
	end

	event.ChildAdded:Connect(function(child)
		if child.Name == "DamageFolder" then
			ensureButton(event)
		end
	end)

	event.ChildRemoved:Connect(function(child)
		if child.Name == "DamageFolder" then
			removeButton(event)
		end
	end)

	event.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			removeButton(event)
		end
	end)
end

for _, event in ipairs(Normal:GetChildren()) do
	hookEvent(event)
end

Normal.ChildAdded:Connect(function(event)
	hookEvent(event)
end)

local function getColor(text)
	text = text:gsub("%s+", "")

	local hex = text:gsub("#", "")
	if hex:match("^[0-9A-Fa-f]{6}$") then
		return Color3.fromHex(hex)
	end

	local r,g,b = text:match("^(%d+),(%d+),(%d+)$")
	if r and g and b then
		return Color3.fromRGB(
			math.clamp(tonumber(r),0,255),
			math.clamp(tonumber(g),0,255),
			math.clamp(tonumber(b),0,255)
		)
	end

	return nil
end

local merchantPos = {
	"-5197.20068, 3.29959178, -322.690369, 0.223629937, -3.3609131e-09, -0.974674106, 1.86051813e-10, 1, -3.40555495e-09, 0.974674106, 5.80244186e-10, 0.223629937",
	"-3373.52954, 3.69471788, 2275.90137, -0.35339275, -1.87011331e-08, 0.935475051, 5.04991782e-08, 1, 3.90680377e-08, -0.935475051, 6.10470821e-08, -0.35339275",
	"-1131.19946, 15.580554, 816.494446, 0.520269573, 5.25635147e-10, 0.854002118, -9.1515e-09, 1, 4.95972063e-09, -0.854002118, -1.03957918e-08, 0.520269573",
	"316.74292, -33.4303207, -1237.45264, -0.789251804, -7.61275132e-08, -0.614069641, -2.01999359e-08, 1, -9.80095294e-08, 0.614069641, -6.49500365e-08, -0.789251804",
}

local function StringToCFrame(str)
	local numbers = {}
	for num in string.gmatch(str, "[^,]+") do
		table.insert(numbers, tonumber(num))
	end
	return CFrame.new(unpack(numbers))
end

ScrollShopButton.MouseButton1Click:Connect(function()
	local plr = game.Players.LocalPlayer
	local hrt = plr.Character:WaitForChild("HumanoidRootPart")

	background.Visible = false
	openbutton.Visible = true

	local origin = hrt.CFrame

	for _,pos in ipairs(merchantPos) do
		hrt.CFrame = StringToCFrame(pos)
		wait(3) 

		if game.Workspace.QuestNPCs:FindFirstChild("???") then
			return
		end
	end

	hrt.CFrame = origin
end)

local function open()
	background.Visible = true
	openbutton.Visible = false
end

fillselector.FocusLost:Connect(function(enter)
	if not enter then return end

	local color = getColor(fillselector.Text)
	if color then
		FILL_COLOR = color
		fillselector.BackgroundColor3 = color
	else
		fillselector.Text = "Invalid Color"
	end

	wait(1)
	fillselector.Text = "Fill Color"
end)

outlineselec.FocusLost:Connect(function(enter)
	if not enter then return end

	local color = getColor(outlineselec.Text)
	if color then
		OUTLINE_COLOR = color
		outlineselec.BackgroundColor3 = color
	else
		outlineselec.Text = "Invalid Color"
	end

	wait(1)
	outlineselec.Text = "Outline Color"
end)

filltransselector.FocusLost:Connect(function(enter)
	if not enter then return end
	local transparency = tonumber(filltransselector.Text)
	if transparency and transparency >= 0 and transparency <= 1 then
		FILL_TRANSPARENCY = transparency
	else
		filltransselector.Text = "Invalid Transparency"
		filltransselector.BackgroundColor3 = Color3.new(1, 0, 0)
	end

	wait(1)
	filltransselector.Text = "Fill Transparency"
	filltransselector.BackgroundColor3 = Color3.new(0.780392, 0.780392, 1)
end)

outlinetransselector.FocusLost:Connect(function(enter)
	if not enter then return end
	local transparency = tonumber(outlinetransselector.Text)
	if transparency and transparency >= 0 and transparency <= 1 then
		OUTLINE_TRANSPARENCY = transparency
	else
		outlinetransselector.Text = "Invalid Transparency"
		outlinetransselector.BackgroundColor3 = Color3.new(1, 0, 0)
	end

	wait(1)
	outlinetransselector.Text = "Outline Transparency"
	outlinetransselector.BackgroundColor3 = Color3.new(0.780392, 0.780392, 1)
end)

openbutton.MouseButton1Click:Connect(open)

minimizeButton.MouseButton1Up:Connect(function()
	background.Visible = false
	openbutton.Visible = true
end)

closebutton.MouseButton1Up:Connect(function()
	ui:Destroy()
	script:Destroy()
end)

local espopen = false

local instances = {}

local function ToggleESP(toggle)
	local Players = game:GetService("Players")

	if not toggle then
		for _, gui in pairs(instances) do
			if gui then gui:Destroy() end
		end
		return
	end

	local function addHighlight(character)
		if not character:IsA("Model") then return end
		if not character:FindFirstChildOfClass("Humanoid") then return end
		if character:FindFirstChildOfClass("Highlight") then return end
		if character == Players.LocalPlayer.Character then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = "ESP"
		highlight.Adornee = character
		highlight.Parent = character

		highlight.FillColor = FILL_COLOR
		highlight.OutlineColor = OUTLINE_COLOR
		highlight.FillTransparency = FILL_TRANSPARENCY
		highlight.OutlineTransparency = OUTLINE_TRANSPARENCY

		table.insert(instances,highlight)
	end


	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") then
			addHighlight(obj)
		end
	end

	workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("Model") then
			addHighlight(obj)
		end
	end)
end

EspButton.MouseButton1Click:Connect(function()
	espopen = not espopen
	ToggleESP(espopen)
end)
