local Players = game:GetService("Players")
local player = Players.LocalPlayer


local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true


local close = Instance.new("TextButton", frame)
close.Text = "X"
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -25, 0, 0)
close.MouseButton1Click:Connect(function() gui:Destroy() end)


local status = Instance.new("TextLabel", frame)
status.Text = "STOPPED"
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0, 30)
status.TextColor3 = Color3.new(1, 0, 0)


local startBtn = Instance.new("TextButton", frame)
startBtn.Text = "START"
startBtn.Size = UDim2.new(0, 100, 0, 40)
startBtn.Position = UDim2.new(0, 20, 0, 70)
startBtn.BackgroundColor3 = Color3.new(0, 0.5, 0)

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Text = "STOP"
stopBtn.Size = UDim2.new(0, 100, 0, 40)
stopBtn.Position = UDim2.new(1, -120, 0, 70)
stopBtn.BackgroundColor3 = Color3.new(0.5, 0, 0)


local running = false
local connection

local function teleport()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local candy = workspace:FindFirstChild("CandyCurrencies")
        if candy and candy:FindFirstChild("Candy") then
            char:MoveTo(candy.Candy.Position)
        end
    end
end

startBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    status.Text = "RUNNING"
    status.TextColor3 = Color3.new(0, 1, 0)
    
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        teleport()
        wait(0.2)
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
    status.Text = "STOPPED"
    status.TextColor3 = Color3.new(1, 0, 0)
    if connection then
        connection:Disconnect()
    end
end)
