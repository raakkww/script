local gethui = gethui or function() return game:GetService("CoreGui") end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local guiName = "MEGGD-FreeSansMorph2"
local targetGui = gethui()

if targetGui:FindFirstChild(guiName) then
    targetGui[guiName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AUTO-FARM"
TitleLabel.Font = Enum.Font.Arcade
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 25
TitleLabel.Parent = MainFrame

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 2)
Line.Position = UDim2.new(0, 10, 0, 35)
Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

local CharLabel = Instance.new("TextLabel")
CharLabel.Size = UDim2.new(1, -20, 0, 20)
CharLabel.Position = UDim2.new(0, 10, 0, 45)
CharLabel.BackgroundTransparency = 1
CharLabel.Text = "CHARACTER NAME"
CharLabel.Font = Enum.Font.Arcade
CharLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
CharLabel.TextSize = 20
CharLabel.TextXAlignment = Enum.TextXAlignment.Left
CharLabel.Parent = MainFrame

local CharInput = Instance.new("TextBox")
CharInput.Size = UDim2.new(1, -20, 0, 30)
CharInput.Position = UDim2.new(0, 10, 0, 65)
CharInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CharInput.BorderColor3 = Color3.fromRGB(255, 255, 255)
CharInput.BorderSizePixel = 2
CharInput.Text = ""
CharInput.Font = Enum.Font.Arcade
CharInput.TextColor3 = Color3.fromRGB(255, 255, 0)
CharInput.TextSize = 20
CharInput.ClearTextOnFocus = false
CharInput.Parent = MainFrame

local AmountLabel = Instance.new("TextLabel")
AmountLabel.Size = UDim2.new(1, -20, 0, 20)
AmountLabel.Position = UDim2.new(0, 10, 0, 105)
AmountLabel.BackgroundTransparency = 1
AmountLabel.Text = "RESETS"
AmountLabel.Font = Enum.Font.Arcade
AmountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountLabel.TextSize = 20
AmountLabel.TextXAlignment = Enum.TextXAlignment.Left
AmountLabel.Parent = MainFrame

local AmountInput = Instance.new("TextBox")
AmountInput.Size = UDim2.new(1, -20, 0, 30)
AmountInput.Position = UDim2.new(0, 10, 0, 125)
AmountInput.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AmountInput.BorderColor3 = Color3.fromRGB(255, 255, 255)
AmountInput.BorderSizePixel = 2
AmountInput.Text = ""
AmountInput.Font = Enum.Font.Arcade
AmountInput.TextColor3 = Color3.fromRGB(255, 255, 0)
AmountInput.TextSize = 20
AmountInput.ClearTextOnFocus = false
AmountInput.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 165)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "IDLE"
StatusLabel.Font = Enum.Font.Arcade
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 18
StatusLabel.Parent = MainFrame

local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(1, -20, 0, 40)
StartButton.Position = UDim2.new(0, 10, 0, 195)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StartButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
StartButton.BorderSizePixel = 2
StartButton.Text = "START FARM"
StartButton.Font = Enum.Font.Arcade
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 25
StartButton.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CloseButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BorderSizePixel = 1
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.Arcade
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 15
CloseButton.Parent = MainFrame

local isFarming = false

CloseButton.MouseButton1Click:Connect(function()
    isFarming = false
    ScreenGui:Destroy()
end)

StartButton.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    
    if isFarming then
        StartButton.Text = "STOP FARM"
        StartButton.TextColor3 = Color3.fromRGB(255, 0, 0)
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        local charName = CharInput.Text
        local targetAmount = tonumber(AmountInput.Text)
        
        if not targetAmount then
            StatusLabel.Text = "ERROR: INVALID NUMBER"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            isFarming = false
            StartButton.Text = "START FARM"
            StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            return
        end
        
        task.spawn(function()
            local currentResets = 0
            
            while isFarming and currentResets < targetAmount do
                StatusLabel.Text = string.format("FARMING... [%d/%d]", currentResets, targetAmount)
                StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                
                pcall(function()
                    local remote = LocalPlayer.PlayerGui:WaitForChild("SelectCharacterGui", 5):WaitForChild("Frame", 5):WaitForChild("RemoteEvent", 5)
                    
                    if remote then
                        remote:FireServer(charName, false)
                        task.wait(0.2)
                        remote:FireServer("character")
                    end
                end)

                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid", 10)
                
                if humanoid then
                    task.wait(0.2)
                    
                    if isFarming and humanoid.Parent and humanoid.Health > 0 then
                        humanoid.Health = 0
                        
                        while humanoid.Health > 0 and humanoid.Parent do
                            task.wait(0.1)
                        end
                        
                        if isFarming then
                            while LocalPlayer.Character == character and isFarming do
                                task.wait(0.1)
                            end
                            
                            if isFarming then
                                currentResets = currentResets + 1
                            end
                        end
                    end
                end
            end
            
            isFarming = false
            StartButton.Text = "START FARM"
            StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            if currentResets >= targetAmount then
                StatusLabel.Text = "FINISHED!"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                StatusLabel.Text = "STOPPED"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
    else
        StartButton.Text = "START FARM"
        StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = "STOPPED"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
