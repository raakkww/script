--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- MAX CASH, GEMS, SPINS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AddValueEvent = Remotes:WaitForChild("AddValueEvent")
local AddRewardEvent = Remotes:WaitForChild("AddRewardEvent")

for i = 1, 10 do
    pcall(function()
        -- Cash
        AddValueEvent:FireServer("Cash", math.huge)
        -- Gems
        AddRewardEvent:FireServer("Gems", math.huge)
        -- Spins
        AddValueEvent:FireServer("Spins", math.huge)
    end)
end
