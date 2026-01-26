local clickEvent = game:GetService("ReplicatedStorage").RemoteEvents.ClickEvent

while true do
    clickEvent:FireServer(9999)
    task.wait(0.05)
end
