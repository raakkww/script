local Remote = game:GetService("ReplicatedStorage").Remotes.GuiRemote.BuyButton

local sequence = {
    {role = "Survivor", name = "MrRobot"},
    {role = "Survivor", name = "Calindra"},
    {role = "Survivor", name = "Bloxxer"},
    {role = "Killer",   name = "ClawsGuy"},
    {role = "Killer",   name = "Frapers"},
    {role = "Killer",   name = "Stalker"},
    {role = "Killer",   name = "Vencer"},
    {role = "Killer",   name = "KillerKyle"},
}

for _, data in ipairs(sequence) do
    local args = {
        [1] = true,
        [2] = data.role,
        [3] = data.name,
        [4] = 0,
        [5] = data.name
    }

    Remote:FireServer(unpack(args))
    task.wait(0.2)
end
