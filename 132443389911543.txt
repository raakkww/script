local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "STARFRUIT LEGACY",
   LoadingTitle = "STARFRUIT LEGACY OP",
   LoadingSubtitle = "By_Kurogane",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "KUROGANEHUB"
   },
   Discord = {
      Enabled = false,
      Invite = "qUM2rAR6wD", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/qUM2rAR6wD would be KUROGANE
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "KUROGANE HUB || KEY SYSTEM",
      Subtitle = "Enter the Key Below",
      Note = "KEYS IN DISCORD SERVER BRO!!!",
      FileName = "KuroganeHubKey1", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"kontolondon"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

Rayfield:Notify({
   Title = "",
   Content = "How OP Isn't It? , Haha",
   Duration = 10,
   Image = 5274126949,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "The Best Script!",
         Callback = function()
         print("The Noob Tapped The Best Script!")
      end
   },
},
})

local MainTab = Window:CreateTab("PLAYERS", 10048874487) -- Title, Image
local Section = MainTab:CreateSection("MISC")
local Button = MainTab:CreateButton({
   Name = "Infinite Jump Toggle",
   Callback = function()
       --Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then
	--Ensures this only runs once to save resources
	_G.infinJumpStarted = true
	
	--Notifies readiness
	game.StarterGui:SetCore("SendNotification", {Title=""; Text="Infinite Jump Activated!"; Duration=5;})

	--The actual infinite jump
	local plr = game:GetService('Players').LocalPlayer
	local m = plr:GetMouse()
	m.KeyDown:connect(function(k)
		if _G.infinjump then
			if k:byte() == 32 then
			humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
			humanoid:ChangeState('Jumping')
			wait()
			humanoid:ChangeState('Seated')
			end
		end
	end)
end
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "WalkSpeed Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderws", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "JumpPower Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderjp", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = (Value)
   end,
})

local Input = MainTab:CreateInput({
   Name = "Walkspeed",
   PlaceholderText = "1-500",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Text)
   end,
})

local QUESTTab = Window:CreateTab("QUEST", 10924684972) -- Title, Image
local Section = QUESTTab:CreateSection("1X CLICK WHEN LOGIN")
local Button0 = QUESTTab:CreateButton({
   Name = "QUEST REPEAT",
   Callback = function()
   while wait do
wait(0.5)
game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("AcceptRepeatQuest"):FireServer()
end
   end,
})

local Section = QUESTTab:CreateSection("TP QUEST U WANT")
local Button1 = QUESTTab:CreateButton({
   Name = "Level 1-250",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-2478.50684, 20.4122391, 908.349243, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07)
   end,
})

local Button2 = QUESTTab:CreateButton({
   Name = "Level 250-600",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1333.31433, 17.0452881, 1791.53406, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button3 = QUESTTab:CreateButton({
   Name = "Level 600-1000",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1232.31433, 17.0491047, 1790.43408, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button4 = QUESTTab:CreateButton({
   Name = "Level 1000-1500",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-335.014038, 47.6005859, -870.612061, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button5 = QUESTTab:CreateButton({
   Name = "Level 1500-2000",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-213.093719, 47.8012924, -868.849304, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button6 = QUESTTab:CreateButton({
   Name = "Level 2000-2500",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-2361.54199, 18.6975098, -471.661224, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button7 = QUESTTab:CreateButton({
   Name = "Level 2500-3000",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-2265.11475, 27.6741028, -505.309418, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button8 = QUESTTab:CreateButton({
   Name = "Level 3000-4000",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-3701.15991, 10.978405, 200.290543, -0.984812617, 0, 0.173621148, 0, 1, 0, -0.173621148, 0, -0.984812617)
   end,
})

local Button9 = QUESTTab:CreateButton({
   Name = "Level 4000-5000",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-3660.5127, 11.1770792, 104.546608, -0.965929747, 0, 0.258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
   end,
})

local NPCTab = Window:CreateTab("NPC", 6521913304) -- Title, Image
local Section = NPCTab:CreateSection("MALEE & SWORD")
local Button4 = NPCTab:CreateButton({
   Name = "Katana Seller",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-2418.63037, 14.1626158, 1142.71021, 1, 0, 0, 0, 1, 0, 0, 0, 1)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Hawk Of Death Seller",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-935.773743, 20.9051266, 921.613525, 1, 0, 0, 0, 1, 0, 0, 0, 1)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "King Of Curses Seller",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1595.35999, 23.0465813, 144.665085, 1, 0, 0, 0, 1, 0, 0, 0, 1)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "The Strongest Seller",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1596.87903, 22.9466133, 177.300125, 1, 0, 0, 0, 1, 0, 0, 0, 1)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Dark Sovereign Seller",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1144.12695, 17.8275795, 1932.86206, 0, 0.000488311052, 0.999999821, 2.91038305e-11, 0.999999881, -0.000488311052, -0.99999994, -2.91038305e-11, 0)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Phantom Blade Seller",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1541.55615, 128.382324, -14031.3682, 0.087131381, -0, -0.996196866, 0, 1, -0, 0.996196866, 0, 0.087131381)
   end,
})

local Section = NPCTab:CreateSection("OTHER")
local Button4 = NPCTab:CreateButton({
   Name = "Boss Spawn",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1382.79968, 27.2153206, 389.209473, 1, 0, 0, 0, 1, 0, 0, 0, 1)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Hueco Bos Spawn",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-2031.08899, -131.312744, -13987.3262, 0.087131381, -0, -0.996196866, 0, 1, -0, 0.996196866, 0, 0.087131381)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Techniques Dealer",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-1425.56787, 19.5544434, 1894.42346, -0.749236584, 0, -0.662302613, 0, 1, 0, 0.662302613, 0, -0.749236584)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Fruit Dealer",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-2293.40601, 13.9122314, 866.448608, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Fruit Swapper",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-2317.1062, 13.9123535, 867.349426, -1, 0, 0, 0, 1, 0, 0, 0, -1)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Change Color",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-125.81514, 32.4288368, 1289.6095, -0.866007447, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, -0.866007447)
   end,
})

local Button4 = NPCTab:CreateButton({
   Name = "Color Resetter",
   Callback = function()
   game.Players.LocalPlayer.Character.Humanoid.RootPart.CFrame = CFrame.new(-138.108643, 32.6496162, 1149.8313, 0.819155693, -0, -0.573571265, 0, 1, -0, 0.573571265, 0, 0.819155693)
   end,
})

local ITEMTab = Window:CreateTab("GIVE ITEMS", 16179927980) -- Title, Image
local Section = ITEMTab:CreateSection("DON'T SPAM CLICK , LAGG")
local Section = ITEMTab:CreateSection("THE STRONGEST")
local Button4 = ITEMTab:CreateButton({
   Name = "Honored One's Head",
   Callback = function()
   local args = {
    [1] = "Honored One's Head",
    [2] = "Epics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Amplification Orb",
   Callback = function()
   local args = {
    [1] = "Amplification Orb",
    [2] = "Legendaries"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Reversal Core",
   Callback = function()
   local args = {
    [1] = "Reversal Core",
    [2] = "Legendaries"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Limitless Glasses",
   Callback = function()
   local args = {
    [1] = "Limitless Glasses",
    [2] = "Prismatics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Section = ITEMTab:CreateSection("KING OF CURSES")
local Button4 = ITEMTab:CreateButton({
   Name = "Demon Arm",
   Callback = function()
      local args = {
    [1] = "Demon Arm",
    [2] = "Epics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Curse Head",
   Callback = function()
      local args = {
    [1] = "Curse Head",
    [2] = "Epics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Yuji's Heart",
   Callback = function()
      local args = {
    [1] = "Yuji's Heart",
    [2] = "Prismatics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Sukuna Fingers",
   Callback = function()
      local args = {
    [1] = "Sukuna Finger",
    [2] = "Legendaries"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Section = ITEMTab:CreateSection("HAWK OF DEATH")
local Button4 = ITEMTab:CreateButton({
   Name = "Hawk Hat",
   Callback = function()
      local args = {
    [1] = "Hawk Hat",
    [2] = "Rares"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Yoru",
   Callback = function()
      local args = {
    [1] = "Yoru",
    [2] = "Rares"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})
local Section = ITEMTab:CreateSection("DARK SOVEREIGN")
local Button4 = ITEMTab:CreateButton({
   Name = "Eye Of Terror",
   Callback = function()
   local args = {
    [1] = "Eye of Terror",
    [2] = "Legendaries"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Eminence Blade",
   Callback = function()
   local args = {
    [1] = "Eminence Blade",
    [2] = "Epics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Purple Flame",
   Callback = function()
   local args = {
    [1] = "Purple Flame",
    [2] = "Legendaries"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Sovereign Fragment",
   Callback = function()
   local args = {
    [1] = "Sovereign Fragment",
    [2] = "Prismatics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Section = ITEMTab:CreateSection("PHANTOM BLADE")
local Button4 = ITEMTab:CreateButton({
   Name = "Spiritual Energy",
   Callback = function()
   local args = {
    [1] = "Spiritual Energy",
    [2] = "Legendaries"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Phantom's Hair",
   Callback = function()
   local args = {
    [1] = "Phantom's Hair",
    [2] = "Rares"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Head of Phantom",
   Callback = function()
   local args = {
    [1] = "Head Of Phantom",
    [2] = "Epics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Hado Energy",
   Callback = function()
   local args = {
    [1] = "Hado Energy",
    [2] = "Legendaries"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local Button4 = ITEMTab:CreateButton({
   Name = "Illusionary Blade",
   Callback = function()
   local args = {
    [1] = "Illusionary Blade",
    [2] = "Prismatics"
}

game:GetService("ReplicatedStorage").RemoteEvents.GivePhysicalItem:FireServer(unpack(args))
   end,
})

local COLORTab = Window:CreateTab("Color Change", 12714352648) -- Title, Image
local Section = COLORTab:CreateSection("GIVE RAINBOW COLOR")
local Button4 = COLORTab:CreateButton({
   Name = "Combat",
   Callback = function()
   local args = {
    [1] = "SetColor",
    [2] = {
        ["colorType"] = "rainbow",
        ["abilityName"] = "Combat",
        ["hex1"] = "9400D3",
        ["hex2"] = "4B0082",
        ["hex3"] = "0000FF",
        ["hex4"] = "00FF00",
        ["hex5"] = "FFFF00",
        ["hex6"] = "FF7F00",
        ["hex7"] = "FF0000"
    }
}

game:GetService("ReplicatedStorage").RemoteEvents.PlayerColorEvent:FireServer(unpack(args))
   end,
})

local Button4 = COLORTab:CreateButton({
   Name = "Katana",
   Callback = function()
   local args = {
    [1] = "SetColor",
    [2] = {
        ["colorType"] = "rainbow",
        ["abilityName"] = "Katana",
        ["hex1"] = "9400D3",
        ["hex2"] = "4B0082",
        ["hex3"] = "0000FF",
        ["hex4"] = "00FF00",
        ["hex5"] = "FFFF00",
        ["hex6"] = "FF7F00",
        ["hex7"] = "FF0000"
    }
}

game:GetService("ReplicatedStorage").RemoteEvents.PlayerColorEvent:FireServer(unpack(args))
   end,
})

local Button4 = COLORTab:CreateButton({
   Name = "Hawk Of Death",
   Callback = function()
   local args = {
    [1] = "SetColor",
    [2] = {
        ["colorType"] = "rainbow",
        ["abilityName"] = "Hawk of Death",
        ["hex1"] = "9400D3",
        ["hex2"] = "4B0082",
        ["hex3"] = "0000FF",
        ["hex4"] = "00FF00",
        ["hex5"] = "FFFF00",
        ["hex6"] = "FF7F00",
        ["hex7"] = "FF0000"
    }
}

game:GetService("ReplicatedStorage").RemoteEvents.PlayerColorEvent:FireServer(unpack(args))
   end,
})

local Button4 = COLORTab:CreateButton({
   Name = "King Of Curses",
   Callback = function()
   local args = {
    [1] = "SetColor",
    [2] = {
        ["colorType"] = "rainbow",
        ["abilityName"] = "King of Curses",
        ["hex1"] = "9400D3",
        ["hex2"] = "4B0082",
        ["hex3"] = "0000FF",
        ["hex4"] = "00FF00",
        ["hex5"] = "FFFF00",
        ["hex6"] = "FF7F00",
        ["hex7"] = "FF0000"
    }
}

game:GetService("ReplicatedStorage").RemoteEvents.PlayerColorEvent:FireServer(unpack(args))
   end,
})

local Button4 = COLORTab:CreateButton({
   Name = "The Strongest",
   Callback = function()
   local args = {
    [1] = "SetColor",
    [2] = {
        ["colorType"] = "rainbow",
        ["abilityName"] = "The Strongest",
        ["hex1"] = "9400D3",
        ["hex2"] = "4B0082",
        ["hex3"] = "0000FF",
        ["hex4"] = "00FF00",
        ["hex5"] = "FFFF00",
        ["hex6"] = "FF7F00",
        ["hex7"] = "FF0000"
    }
}

game:GetService("ReplicatedStorage").RemoteEvents.PlayerColorEvent:FireServer(unpack(args))
   end,
})

local Button4 = COLORTab:CreateButton({
   Name = "Dark Sovereign",
   Callback = function()
   local args = {
    [1] = "SetColor",
    [2] = {
        ["colorType"] = "rainbow",
        ["abilityName"] = "Dark Sovereign",
        ["hex1"] = "9400D3",
        ["hex2"] = "4B0082",
        ["hex3"] = "0000FF",
        ["hex4"] = "00FF00",
        ["hex5"] = "FFFF00",
        ["hex6"] = "FF7F00",
        ["hex7"] = "FF0000"
    }
}

game:GetService("ReplicatedStorage").RemoteEvents.PlayerColorEvent:FireServer(unpack(args))
   end,
})

local Button4 = COLORTab:CreateButton({
   Name = "Phantom Blade",
   Callback = function()
   local args = {
    [1] = "SetColor",
    [2] = {
        ["colorType"] = "rainbow",
        ["abilityName"] = "Phantom Blade",
        ["hex1"] = "9400D3",
        ["hex2"] = "4B0082",
        ["hex3"] = "0000FF",
        ["hex4"] = "00FF00",
        ["hex5"] = "FFFF00",
        ["hex6"] = "FF7F00",
        ["hex7"] = "FF0000"
    }
}

game:GetService("ReplicatedStorage").RemoteEvents.PlayerColorEvent:FireServer(unpack(args))
   end,
})
