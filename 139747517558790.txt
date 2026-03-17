---rescripted of weapon tower farm

local pads = workspace.Functions.CashGivers
local coins = workspace.Coins
local plr = game.Players.LocalPlayer

local active = false
local db = false

local function touchthem()
    for i, pad in pads:GetChildren() do
        if not active then return end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then task.wait(.05) touchthem() return end
        pad.CanCollide = false
        task.spawn(function()
            for i, coin in coins:GetChildren() do
                firetouchinterest(coin, root)
            end
        end)
        firetouchinterest(pads.Parent.WinPart, root)
        firetouchinterest(pad, root)
        task.wait()
        touchthem()
    end
end

local ui = Instance.new("ScreenGui")
ui.Parent = game:GetService("CoreGui")
local label = Instance.new("TextLabel")
label.Parent = ui
label.Size = UDim2.fromOffset(100, 50)
label.Position = UDim2.fromScale(0.14560705423355103, 0.882087254524231)
label.RichText = true
label.TextScaled = true

local button = Instance.new("TextButton")
button.Parent = ui
button.Text = "Activate Farm"
button.Size = UDim2.fromOffset(100,50)
button.Position = UDim2.fromScale(0.14560705423355103, 0.823866779344279)

button.Activated:Connect(function()
    if db then return end
    db = true
    if active then
        active = false
        button.Text = "Activate Farm"
        plr.Character:WaitForChild("HumanoidRootPart", 3).Parent = nil
        task.wait(1)
        plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        print"destroyed humanoidrootpart"
    else
        active = true
        print"activating"
        button.Text = "Deactivate Farm"
        task.spawn(touchthem)
    end
    print"debounce"
    task.wait(3)
    print("db off")
    db = false
end)

local cash = plr:WaitForChild("leaderstats"):WaitForChild("Money")
local lastCash = cash.Value
local earnings = {}

cash.Changed:Connect(function(newValue)
	local diff = newValue - lastCash
	lastCash = newValue
	
	if diff > 0 then
		table.insert(earnings, {time = os.time(), amount = diff})
	end
end)

local function formatNumber(num)
	return tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

while true do
	local now = os.time()
	local total = 0
	
	for i = #earnings, 1, -1 do
		local data = earnings[i]
		
		if now - data.time > 60 then
			table.remove(earnings, i)
		else
			total += data.amount
		end
	end
	
	label.Text = "💰 $"..formatNumber(total).." / min"
	
	task.wait(1)
end
