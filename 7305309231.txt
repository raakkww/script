local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Load Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- // GLOBAL STATES // --
local State = {
    Candy = false,
    PartCollector = false,
    AutoMoney = false,
    AutoOffice = false,
    AutoTrophies = false,
    AutoMedals = false,
    DonutGod = false
}

-- // UTILITY FUNCTIONS // --
local function findCar()
    for _, v in pairs(Workspace.Vehicles:GetChildren()) do
        if v:GetAttribute("owner") == Players.LocalPlayer.UserId then return v end
    end
    return nil
end

local function teleportTo(location)
    pcall(function()
        local chr = Players.LocalPlayer.Character
        local hum = chr.Humanoid
        local target = ReplicatedStorage.Places:FindFirstChild(location)
        if not target then return end
        
        if hum.SeatPart == nil then
            chr:PivotTo(CFrame.new(target.Position) + Vector3.new(0, 30, 0))
        else
            hum.SeatPart.Parent.Parent:PivotTo(target.CFrame + Vector3.new(0, 40, 0))
        end
    end)
end

-- // BACKGROUND SYSTEMS // --

-- Anti-AFK
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- Anti-Staff Logic
task.spawn(function()
    while task.wait(5) do
        for _, v in pairs(Players:GetPlayers()) do
            if v:GetRankInGroup(11987919) > 149 then
                Players.LocalPlayer:Kick("Staff member detected in server.")
            end
        end
    end
end)

-- // WINDOW SETUP // --
local Window = WindUI:CreateWindow({
    Title = "Taxi Boss", -- Nama GUI bersih
    Icon = "solar:car-bold",
    Folder = "TaxiBoss_Settings", -- Nama folder config generic
})

-- // TABS // --
local Tabs = {
    Farm = Window:Tab({ Title = "Farm", Icon = "solar:leaf-bold" }),
    Money = Window:Tab({ Title = "Money", Icon = "solar:dollar-minimalistic-bold" }),
    Race = Window:Tab({ Title = "Race", Icon = "solar:flag-bold" }),
    Teleports = Window:Tab({ Title = "Teleports", Icon = "solar:map-point-bold" }),
    Misc = Window:Tab({ Title = "Misc", Icon = "solar:settings-bold" })
}

-- // FARM TAB // --
Tabs.Farm:Section({ Title = "Farming" })

Tabs.Farm:Toggle({
    Title = "Auto Destroy Pumpkins",
    Desc = "Collect candy automatically",
    Callback = function(v)
        State.Candy = v
        while State.Candy do
            task.wait()
            local car = findCar()
            if car then
                for _, p in pairs(Workspace.Pumpkins:GetDescendants()) do
                    if p.Name == "TouchInterest" then
                        firetouchinterest(car.PrimaryPart, p.Parent, 0)
                        firetouchinterest(car.PrimaryPart, p.Parent, 1)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
})

Tabs.Farm:Toggle({
    Title = "Auto Collect Parts",
    Desc = "Collect vehicle parts across map",
    Callback = function(v)
        State.PartCollector = v
        while State.PartCollector do
            task.wait()
            for _, spawn in pairs(Workspace.ItemSpawnLocations:GetChildren()) do
                if not State.PartCollector then break end
                local timer = tick()
                repeat
                    task.wait()
                    Players.LocalPlayer.Character:PivotTo(spawn.CFrame + Vector3.new(0, 251, 0))
                until tick() - timer >= 2
                
                for _, part in pairs(Workspace.ItemSpawnLocations:GetDescendants()) do
                    if part.Name == "TouchInterest" then
                        firetouchinterest(Players.LocalPlayer.Character.HumanoidRootPart, part.Parent, 0)
                        firetouchinterest(Players.LocalPlayer.Character.HumanoidRootPart, part.Parent, 1)
                    end
                end
            end
        end
    end
})

-- // MONEY TAB // --
Tabs.Money:Section({ Title = "Auto Income" })

Tabs.Money:Toggle({
    Title = "Auto Money",
    Desc = "Material contracts loop",
    Callback = function(v)
        State.AutoMoney = v
        pcall(function()
            ReplicatedStorage.Quests.Contracts.CancelContract:InvokeServer(Players.LocalPlayer.ActiveQuests:FindFirstChildOfClass("StringValue").Name)
        end)
        while State.AutoMoney do
            task.wait()
            if not Players.LocalPlayer.ActiveQuests:FindFirstChild("contractBuildMaterial") then
                ReplicatedStorage.Quests.Contracts.StartContract:InvokeServer("contractBuildMaterial")
                repeat task.wait() until Players.LocalPlayer.ActiveQuests:FindFirstChild("contractBuildMaterial")
            end
            repeat
                task.wait()
                task.spawn(function()
                    ReplicatedStorage.Quests.DeliveryComplete:InvokeServer("contractMaterial")
                end)
            until Players.LocalPlayer.ActiveQuests.contractBuildMaterial.Value == "!pw5pi3ps2"
            task.wait()
            ReplicatedStorage.Quests.Contracts.CompleteContract:InvokeServer()
        end
    end
})

Tabs.Money:Toggle({
    Title = "Auto Upgrade Office",
    Desc = "Reach office level 16",
    Callback = function(v)
        State.AutoOffice = v
        while State.AutoOffice do
            task.wait()
            if not Players.LocalPlayer:FindFirstChild("Office") then
                ReplicatedStorage.Company.StartOffice:InvokeServer()
                task.wait(0.2)
            end
            if Players.LocalPlayer.Office:GetAttribute("level") < 16 then
                ReplicatedStorage.Company.SkipOfficeQuest:InvokeServer()
                ReplicatedStorage.Company.UpgradeOffice:InvokeServer()
            end
        end
    end
})

-- // RACE TAB // --
Tabs.Race:Section({ Title = "Racing" })

Tabs.Race:Toggle({
    Title = "Auto Trophies",
    Callback = function(v)
        State.AutoTrophies = v
        ReplicatedStorage.Race.LeaveRace:InvokeServer()
        while State.AutoTrophies do
            task.wait()
            pcall(function()
                if Players.LocalPlayer.Character.Humanoid.Sit then
                    if Players.LocalPlayer.variables.race.Value == "none" then
                        ReplicatedStorage.Race.TimeTrial:InvokeServer("circuit", 5)
                    else
                        for _, carObj in pairs(Workspace.Vehicles:GetDescendants()) do
                            if carObj.Name == "Player" and carObj.Value == Players.LocalPlayer then
                                for _, det in pairs(Workspace.Races["circuit"].detects:GetChildren()) do
                                    if det.ClassName == "Part" and det:FindFirstChild("TouchInterest") then
                                        det.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                        firetouchinterest(carObj.Parent.Parent.PrimaryPart, det, 0)
                                        firetouchinterest(carObj.Parent.Parent.PrimaryPart, det, 1)
                                    end
                                end
                                local finish = Workspace.Races["circuit"].timeTrial:FindFirstChildOfClass("IntValue").finish
                                finish.CFrame = Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                                firetouchinterest(carObj.Parent.Parent.PrimaryPart, finish, 0)
                                firetouchinterest(carObj.Parent.Parent.PrimaryPart, finish, 1)
                            end
                        end
                    end
                else
                    ReplicatedStorage.Vehicles.GetNearestSpot:InvokeServer(Players.LocalPlayer.variables.carId.Value)
                    task.wait(0.5)
                    ReplicatedStorage.Vehicles.EnterVehicleEvent:InvokeServer()
                end
            end)
        end
    end
})

-- // TELEPORTS TAB // --
Tabs.Teleports:Section({ Title = "Locations" })

local locs = {
    "Beechwood", "Beechwood Beach", "Boss Airport", "Bridgeview",
    "Cedar Side", "Central Bank", "Central City", "City Park",
    "Coconut Park", "Country Club", "Da Hills", "Doge Harbor",
    "Ocean Viewpoint", "Oil Refinery", "Old Town", "Popular Street",
    "Small Town", "St. Noll Viewpoint", "Sunny Elementary", "Sunset Grove",
    "Taxi Central", "high school", "mall", "the beach", "🏆 Race Club"
}

Tabs.Teleports:Dropdown({
    Title = "Teleport To",
    Values = locs,
    Callback = function(v) teleportTo(v) end
})

-- // MISC TAB // --
Tabs.Misc:Section({ Title = "Tools" })

Tabs.Misc:Input({
    Title = "Purchase Car",
    Placeholder = "Car Name...",
    Callback = function(v)
        for _, car in pairs(require(ReplicatedStorage.ModuleLists.CarList)) do
            if string.find(string.lower(car.name), string.lower(v)) then
                ReplicatedStorage.DataStore.PurchaseVehicle:InvokeServer(car.id)
                break
            end
        end
    end
})

Tabs.Misc:Button({
    Title = "Unlock Taxi Radar",
    Callback = function() Players.LocalPlayer.variables.vip.Value = true end
})

Tabs.Misc:Button({
    Title = "Remove Traffic & Barriers",
    Callback = function()
        if Workspace:FindFirstChild("Tracks") then Workspace.Tracks:Destroy() end
        if Workspace:FindFirstChild("AreaLocked") then Workspace.AreaLocked:Destroy() end
    end
})

Tabs.Misc:Toggle({
    Title = "Donut God",
    Callback = function(v)
        State.DonutGod = v
        while State.DonutGod do
            task.wait()
            pcall(function()
                local seat = Players.LocalPlayer.Character.Humanoid.SeatPart
                seat.RotVelocity = Vector3.new(0, seat.RotVelocity.Y + 10, 0)
            end)
        end
    end
})

-- Final Notification
WindUI:Notify({
    Title = "Loaded",
    Content = "Script is ready.",
    Duration = 3
})
