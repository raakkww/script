local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- // GLOBAL STATES // --
local State = {
    Active = false,
    WasActiveBeforeDeath = false,
    Thread = nil
}

local LocalPlayer = Players.LocalPlayer

-- // CORE LOGIC // --

local function farmLoop()
    while State.Active do
        pcall(function()
            -- Spams the bomb remote from original script
            ReplicatedStorage:WaitForChild("PlantBomb"):FireServer()
        end)
        RunService.Heartbeat:Wait()
    end
end

local function startFarm()
    State.Active = true
    State.WasActiveBeforeDeath = true
    State.Thread = task.spawn(farmLoop)
end

local function stopFarm()
    State.Active = false
    State.WasActiveBeforeDeath = false
    if State.Thread then
        task.cancel(State.Thread)
        State.Thread = nil
    end
end

-- // WINDOW SETUP // --
local Window = WindUI:CreateWindow({
    Title = "Auto Farm", -- Bersih tanpa nama
    Icon = "solar:bolt-bold",
    Folder = "AutoFarm_Config",
})

-- // TABS // --
local MainTab = Window:Tab({ Title = "Main", Icon = "solar:home-bold" })

-- // MAIN TAB // --
MainTab:Section({ Title = "Automated Farming" })

local FarmToggle = MainTab:Toggle({
    Title = "Auto Farm",
    Desc = "Spams plant bomb remote",
    Value = false,
    Callback = function(v)
        if v then
            startFarm()
        else
            stopFarm()
        end
    end
})

MainTab:Section({ Title = "Settings" })

MainTab:Button({
    Title = "Close Script",
    Desc = "Stops farm and removes UI",
    Callback = function()
        stopFarm()
        Window:Close()
    end
})

-- // EVENT HANDLING // --

-- Death Detection logic from original script
local function setupDetection(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.Died:Connect(function()
            -- Temporarily pause
            local wasRunning = State.Active
            State.Active = false
            if State.Thread then task.cancel(State.Thread) end
            
            -- Wait for respawn
            LocalPlayer.CharacterAdded:Wait()
            task.wait(0.5)
            
            -- Resume if it was active
            if State.WasActiveBeforeDeath then
                State.Active = true
                State.Thread = task.spawn(farmLoop)
            end
        end)
    end
end

-- Initial Setup
if LocalPlayer.Character then setupDetection(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupDetection)

-- ESC to close logic
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Escape then
        stopFarm()
        Window:Close()
    end
end)

-- Notification
WindUI:Notify({
    Title = "Ready",
    Content = "Auto Farm script loaded.",
    Duration = 3
})
