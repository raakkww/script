--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local args = {
	100000000000000000000
}
game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("WinsGiver"):FireServer(unpack(args))
local args = {
	5000000000
}
game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("PlayTimeRewards"):FireServer(unpack(args))
