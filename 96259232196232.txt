local Library = loadstring(game:HttpGet("https://pastebin.com/raw/KrSEV1Re"))()
local window = Library.Library:Create("Press Buttons To Grow Numbers", "")

local tab1Holder = window:Tab("Main")
local tab2Holder = window:Tab("Dungeon")

local plr = game:GetService("Players").LocalPlayer


local settig = {
	autorankup = false,
	
	
	-----
	autoMuil = false,
	MuilPick = 1,
	-----
	autoReb = false,
	RebPick = 1,
	-----
	autoUltra = false,
	UltraPick = 1,
	-----
	autoMega = false,
	MegaPick = 1,
	-----
	autoChampion = false,
	ChampionPick = 1,
	-----
	autoSupreme = false,
	SupremePick = 1,
	-----
	autoOverlord = false,
	OverlordPick = 1,
	
	
	
	
	-----
	autoshard = false,
	ShardPick = 1,
	-----
	autoRune = false,
	SelecRunes = "Basic"
	
	
	
}

local dungeonS = {
	Selected = "Slime",
	Enabled = false,
	Pick = 1
	
}


window:Toggle(tab1Holder, "auto Rankup", function(isToggled)
	settig.autorankup = isToggled
	if settig.autorankup then
		while settig.autorankup do
			local args = {
				"Rank"
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RanksEvent"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "in textbox, put the number ontop of the button!")
window:Label(tab1Holder, "Muilt")
window:TextBox(tab1Holder, "Muilt Number", "Default value", function(newValue)
	settig.MuilPick = tonumber(newValue)
end)


window:Toggle(tab1Holder, "auto Muilt", function(isToggled)
	settig.autoMuil = isToggled
	if settig.autoMuil and settig.MuilPick ~= 0 or settig.MuilPick ~= nil then
		while settig.autoMuil do
			local args = {
				{
					"Normal",
					"Multi",
					tostring(settig.MuilPick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "Rebirth")
window:TextBox(tab1Holder, "Rebirth", "Default value", function(newValue)
	settig.RebPick = tonumber(newValue)
end)


window:Toggle(tab1Holder, "auto Rebirth", function(isToggled)
	settig.autoReb = isToggled
	if settig.autoReb and settig.RebPick ~= 0 or settig.RebPick ~= nil then
		while settig.autoReb do
			local args = {
				{
					"Normal",
					"Rebirth",
					tostring(settig.RebPick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "Ultra")
window:TextBox(tab1Holder, "Ultra", "Default value", function(newValue)
	settig.UltraPick = tonumber(newValue)
end)


window:Toggle(tab1Holder, "auto Ultra", function(isToggled)
	settig.autoUltra = isToggled
	if settig.autoUltra and settig.UltraPick ~= 0 or settig.UltraPick ~= nil then
		while settig.autoUltra do
			local args = {
				{
					"Normal",
					"Ultra",
					tostring(settig.UltraPick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "Mega")
window:TextBox(tab1Holder, "Mega", "Default value", function(newValue)
	settig.MegaPick = tonumber(newValue)
end)

window:Toggle(tab1Holder, "auto Mega", function(isToggled)
	settig.autoMega = isToggled
	if settig.autoMega and settig.MegaPick ~= 0 or settig.MegaPick ~= nil then
		while settig.autoMega do
			local args = {
				{
					"Normal",
					"Mega",
					tostring(settig.MegaPick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "Champion")
window:TextBox(tab1Holder, "Champion", "Default value", function(newValue)
	settig.ChampionPick = tonumber(newValue)
end)

window:Toggle(tab1Holder, "auto Champion", function(isToggled)
	settig.autoChampion = isToggled
	if settig.autoChampion and settig.ChampionPick ~= 0 or settig.ChampionPick ~= nil then
		while settig.autoChampion do
			local args = {
				{
					"Normal",
					"Champion",
					tostring(settig.ChampionPick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "Supreme")
window:TextBox(tab1Holder, "Supreme", "Default value", function(newValue)
	settig.SupremePick = tonumber(newValue)
end)

window:Toggle(tab1Holder, "auto Supreme", function(isToggled)
	settig.autoSupreme = isToggled
	if settig.autoSupreme and settig.SupremePick ~= 0 or settig.SupremePick ~= nil then
		while settig.autoSupreme do
			local args = {
				{
					"Normal",
					"Supreme",
					tostring(settig.SupremePick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "Overlord")
window:TextBox(tab1Holder, "Overlord", "Default value", function(newValue)
	settig.OverlordPick = tonumber(newValue)
end)

window:Toggle(tab1Holder, "auto Overlord", function(isToggled)
	settig.autoOverlord = isToggled
	if settig.autoOverlord and settig.OverlordPick ~= 0 or settig.OverlordPick ~= nil then
		while settig.autoOverlord do
			local args = {
				{
					"Normal",
					"Overlord",
					tostring(settig.OverlordPick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)

---------------------------------------------------------------------------------------------------------------------------------------
window:Label(tab1Holder, "Shards")

window:TextBox(tab1Holder, "Shards", "Default value", function(newValue)
	settig.ShardPick = tonumber(newValue)
end)


window:Toggle(tab1Holder, "auto Shards", function(isToggled)
	settig.autoshard = isToggled
	if settig.autoshard and settig.ShardPick ~= 0 or settig.ShardPick ~= nil then
		while settig.autoshard do
			local args = {
				{
					"Normal",
					"Shards",
					tostring(settig.ShardPick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


window:Label(tab1Holder, "Runes")

local Runes = {}
for _, v in pairs(workspace.Buttons.Runes:GetChildren()) do
	if not table.find(Runes, v.Name) then
		table.insert(Runes, v.Name)
	end
end


window:Dropdown(tab1Holder, "Select Rune!", Runes, function(selectedOption)
	settig.SelecRunes = tostring(selectedOption)

end)


window:Toggle(tab1Holder, "auto selected", function(isToggled)
	settig.autoRune = isToggled
	if settig.autoRune and settig.SelecRunes ~= '' or settig.SelecRunes ~= nil then
		while settig.autoRune do
			local args = {
				{
					"Runes",
					"Runes",
					tostring(settig.SelecRunes)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


---------------------------------------------------------------------------------------------------------------------------------------

local DungeonNPCs = {}
--local NPsChild = {}

for _, v in pairs(workspace:GetDescendants()) do
	if v:IsA("TextLabel") and v.Name == "Damage" then
		local folder  = v:FindFirstAncestorWhichIsA("Folder")
		if folder and not table.find(DungeonNPCs, folder.Name) then
			table.insert(DungeonNPCs, folder.Name)
			--	NPsChild[folder.Name] = #folder:GetChildren()
		end
	end
end

window:Label(tab2Holder, "in textbox, put the Npc layout number! Ex: 1 = weakest")

window:Button(tab2Holder, "Go to dungeon", function()
	if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		plr.Character.HumanoidRootPart.CFrame = CFrame.new(1092.06189, 4.31912136, 0.757104814, 0.106499553, 9.15563731e-08, 0.994312763, -2.7525342e-08, 1, -8.91318521e-08, -0.994312763, -1.78762978e-08, 0.106499553)
	end
end)


window:Dropdown(tab2Holder, "NPC Type", DungeonNPCs, function(selectedOption)
	dungeonS.Selected = tostring(selectedOption)
end)


window:TextBox(tab2Holder, "NPC", "Default", function(newValue)
	dungeonS.Pick = tonumber(newValue)
end)


window:Toggle(tab2Holder, "Auto selected", function(isToggled)
	dungeonS.Enabled = isToggled
	if dungeonS.Enabled and dungeonS.Pick ~= 0 or dungeonS.Pick ~= nil then
		while dungeonS.Enabled do
			local args = {
				{
					"Dungeons",
					tostring(dungeonS.Selected),
					tostring(dungeonS.Pick)
				}
			}
			game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ButtonPress"):FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)
