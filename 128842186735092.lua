--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- make sure to hold tool for it to work
local replicated_storage = game:GetService("ReplicatedStorage");
local run_service = game:GetService("RunService");
local players = game:GetService("Players");

local local_player = players.LocalPlayer;

local gun_fire = replicated_storage.GunFire;

local player_variables = require(local_player.PlayerScripts.PlayerVariables);

local npcs;
if (player_variables.Tycoon) then
	npcs = player_variables.Tycoon.NpcStuff.ActiveNpcs;
else
	return local_player:Kick("Failed to retrive tycoon make sure you claimed one if it keeps happening report it to @kylosilly on discord");
end

run_service.RenderStepped:Connect(function()
	local tool = local_player.Character:FindFirstChildWhichIsA("Tool");
	if (tool) then
		for _, player in (players:GetPlayers()) do
			if (player == local_player) then
				continue;
			end
			local character = player.Character;
			if (not character) or (character:FindFirstChildWhichIsA("ForceField")) then
				continue;
			end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid");
			local head = character:FindFirstChild("Head");
			if (not head) or (not humanoid) or (humanoid.Health <= 0) then
				continue;
			end
			gun_fire:FireServer(tool.Name, tool, head.Position, head.Position, head);
		end

		for _, npc in (npcs:GetChildren()) do
			local humanoid = npc:FindFirstChildWhichIsA("Humanoid");
			local head = npc:FindFirstChild("Head");
			if (not head) or (not humanoid) or (humanoid.Health <= 0) then
				continue;
			end
			gun_fire:FireServer(tool.Name, tool, head.Position, head.Position, head);
		end
	end
end)
