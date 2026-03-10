local toggle = false
local uis = game:GetService("UserInputService")

uis.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        toggle = true
    end
end)

uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        toggle = false
    end
end)

task.spawn(function()
    while task.wait() do
        if toggle == true then
            local mouse = uis:GetMouseLocation()
            local target = workspace.Targets:FindFirstChild("Target")
            if target then
                local v = workspace.CurrentCamera:WorldToViewportPoint(target.Position)
                mousemoverel(v.X - mouse.X, v.Y - mouse.Y)
            end
            local part = workspace.Targets:FindFirstChild("Part")
            if part then
                local v = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                mousemoverel(v.X - mouse.X, v.Y - mouse.Y)
            end
        end
    end
end)
