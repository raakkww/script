local unlock = "X08"

--[[
    Possible unlocks:
    X06, X07, X08 - Tank Turrets
    DoubleCash - Double Cash
    Airstrike4 - Plasma Nuke
]]


local Event = game:GetService("ReplicatedStorage").TechTree.Remotes.RequestUnlock
Event:FireServer(
    unlock
)
