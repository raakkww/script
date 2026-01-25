--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
a = game:GetService("ReplicatedStorage")
b = a.GameRemotes.BuyEvent
c = a.GameItems

player = game.Players.LocalPlayer

gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ItemGiverGui"

toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(0, 10, 0.5, -20)
toggle.Text = "≡"

main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(0.5, -160, 0.5, -210)
main.Visible = false
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "item giver"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)

search = Instance.new("TextBox", main)
search.Size = UDim2.new(1, -20, 0, 35)
search.Position = UDim2.new(0, 10, 0, 50)
search.PlaceholderText = "search item"
search.Text = ""

list = Instance.new("ScrollingFrame", main)
list.Size = UDim2.new(1, -20, 1, -100)
list.Position = UDim2.new(0, 10, 0, 90)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.ScrollBarImageTransparency = 0.3

layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 6)

function refresh(filter)
	for _, v in pairs(list:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _, item in ipairs(c:GetChildren()) do
		if not filter or string.find(string.lower(item.Name), string.lower(filter)) then
			btn = Instance.new("TextButton", list)
			btn.Size = UDim2.new(1, 0, 0, 36)
			btn.Text = item.Name
			btn.TextScaled = true

			btn.MouseButton1Click:Connect(function()
				b:FireServer(item.Name)
			end)
		end
	end

	wait()
	list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

refresh()

search:GetPropertyChangedSignal("Text"):Connect(function()
	refresh(search.Text)
end)

toggle.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)
