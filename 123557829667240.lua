local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "",
   LoadingTitle = "",
   LoadingSubtitle = "",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)

-- Services
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace          = game:GetService("Workspace")
local GuiService         = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Remotes     = ReplicatedStorage:WaitForChild("Remotes")

local AxeSwing         = Remotes:WaitForChild("AxeSwing")
local CollectCoin      = Remotes:FindFirstChild("CollectCoin")
local ClickWateringCan = Remotes:FindFirstChild("ClickWateringCan")

-- State
local Enabled = {
   AutoChop     = false,
   AutoCoins    = false,
   AutoUseCans  = false,
   AutoPickup   = false,
}

local Tasks = {}

local function StopTask(name)
   if Tasks[name] then
      task.cancel(Tasks[name])
      Tasks[name] = nil
   end
end

local function GetPlot()
   local plotVal = LocalPlayer:FindFirstChild("Plot")
   if plotVal and plotVal.Value then return plotVal.Value end
   return nil
end

-- Auto Chop (using AxeSwing remote)
local function StartAutoChop()
   StopTask("chop")
   Tasks.chop = task.spawn(function()
      while Enabled.AutoChop do
         pcall(function()
            AxeSwing:FireServer()
         end)
         task.wait(0.008)  -- adjust if needed
      end
   end)
end

-- Auto Collect Coins
local function StartAutoCoins()
   StopTask("coins")
   Tasks.coins = task.spawn(function()
      while Enabled.AutoCoins do
         local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
         if root and CollectCoin then
            local orbs = Workspace:FindFirstChild("Orbs")
            if orbs then
               for _, orb in ipairs(orbs:GetChildren()) do
                  if orb:IsA("BasePart") and orb:GetAttribute("CanCollect") then
                     pcall(function()
                        root.CFrame = orb.CFrame + Vector3.new(0, 2, 0)
                        CollectCoin:FireServer(orb)
                     end)
                     task.wait(0.035)
                  end
               end
            end
         end
         task.wait(0.4)
      end
   end)
end

-- Auto Use Cans
local function GetHighestWaterLevel()
   local data = LocalPlayer:FindFirstChild("Data")
   if not data then return 0 end
   local tapCans = data:FindFirstChild("TapWateringCans")
   if not tapCans then return 0 end

   local highest = 0
   for _, slot in ipairs(tapCans:GetChildren()) do
      local lvl = slot:FindFirstChild("Level")
      if lvl and lvl.Value > highest then highest = lvl.Value end
   end
   return highest
end

local function StartAutoUseCans()
   StopTask("usecans")
   Tasks.usecans = task.spawn(function()
      while Enabled.AutoUseCans do
         if GetHighestWaterLevel() >= 3 then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.07)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)

            local keys = {
               Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five,
               Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine
            }

            for _, key in ipairs(keys) do
               VirtualInputManager:SendKeyEvent(true, key, false, game)
               task.wait(0.13)
               VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
               task.wait(0.18)
               VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
               VirtualInputManager:SendKeyEvent(false, key, false, game)
            end

            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            task.wait(0.07)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
         end
         task.wait(5)
      end
   end)
end

-- Auto Pickup Cans
local function StartAutoPickup()
   StopTask("pickup")
   Tasks.pickup = task.spawn(function()
      while Enabled.AutoPickup do
         local plot = GetPlot()
         if plot and ClickWateringCan then
            for _, desc in ipairs(plot:GetDescendants()) do
               if desc.Name == "WateringCanValue" and desc:IsA("ObjectValue") and desc.Value then
                  pcall(ClickWateringCan.FireServer, ClickWateringCan, desc.Value)
                  task.wait(0.24)
               end
            end

            local contents = plot:FindFirstChild("PlotContents")
            if contents then
               local tree = contents:FindFirstChild("Tree")
               if tree then pcall(ClickWateringCan.FireServer, ClickWateringCan, tree) end
            end
            pcall(ClickWateringCan.FireServer, ClickWateringCan, plot)
         end
         task.wait(6.5)
      end
   end)
end

-- UI Elements
MainTab:CreateToggle({
   Name = "Auto Chop (Equip axe and go near tree)",
   CurrentValue = false,
   Flag = "AutoChop",
   Callback = function(Value)
      Enabled.AutoChop = Value
      if Value then
         StartAutoChop()
         Rayfield:Notify({Title = "Auto Chop", Content = "Enabled – using AxeSwing", Duration = 3})
      else
         StopTask("chop")
         Rayfield:Notify({Title = "Auto Chop", Content = "Disabled", Duration = 2.5})
      end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Collect Coins",
   CurrentValue = false,
   Flag = "AutoCoins",
   Callback = function(Value)
      Enabled.AutoCoins = Value
      if Value then
         StartAutoCoins()
         Rayfield:Notify({Title = "Coins", Content = "Auto collecting orbs", Duration = 3})
      else
         StopTask("coins")
         Rayfield:Notify({Title = "Coins", Content = "Stopped", Duration = 2.5})
      end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Use Watering Cans",
   CurrentValue = false,
   Flag = "AutoUseCans",
   Callback = function(Value)
      Enabled.AutoUseCans = Value
      if Value then
         StartAutoUseCans()
         Rayfield:Notify({Title = "Watering Cans", Content = "Using when level ≥ 3", Duration = 3})
      else
         StopTask("usecans")
         Rayfield:Notify({Title = "Watering Cans", Content = "Stopped", Duration = 2.5})
      end
   end,
})

MainTab:CreateToggle({
   Name = "Auto Pickup Watering Cans",
   CurrentValue = false,
   Flag = "AutoPickup",
   Callback = function(Value)
      Enabled.AutoPickup = Value
      if Value then
         StartAutoPickup()
         Rayfield:Notify({Title = "Pickup", Content = "Auto picking up cans", Duration = 3})
      else
         StopTask("pickup")
         Rayfield:Notify({Title = "Pickup", Content = "Stopped", Duration = 2.5})
      end
   end,
})

print("[Chop Tree Rayfield] Loaded – AxeSwing mode active")
