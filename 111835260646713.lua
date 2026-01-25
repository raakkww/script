while task.wait() do
    local player = game.Players.LocalPlayer
    local weapon = player.Backpack:WaitForChild("Katana")
    local remote = game.ReplicatedStorage.Assets.Remotes.Hit

    for _, target in pairs(game.Players:GetPlayers()) do
        if target ~= player then
            local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
            if humanoid then
                remote:FireServer(weapon, humanoid, 2)
            end
        end
    end
end
