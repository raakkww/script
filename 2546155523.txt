local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("PrivateServerGUI")
if oldGui then oldGui:Destroy() end

local function showMessage(text, duration)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PrivateServerGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 400, 0, 100)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Parent = frame
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 4
	stroke.Transparency = 0.4

	local label = Instance.new("TextLabel")
	label.Parent = frame
	label.Size = UDim2.new(1, -20, 1, -20)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center

	task.wait(duration or 2)

	if screenGui and screenGui.Parent then
		screenGui:Destroy()
	end
end

showMessage("Private Server Recommended", 2)


--// SERVICES
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

--// STATE
local AutoFarm = false
local MenuOpen = true

--// AUTO FARM FUNCTION
local function AutoFarmLoop()
	task.spawn(function()
		while AutoFarm do
			pcall(function()
				-- GET COMPASS
				RS.ActionEvents["Get compass"]:FireServer(
					workspace.Environment.JobModels.Excavation.GetCompass
				)

				task.wait(0.5)

				-- DIG AREA
				hrp.CFrame = workspace.Environment.JobModels.Excavation.DigArea.DigArea.Part.CFrame + Vector3.new(0,5,0)
				task.wait(1)

				VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
				task.wait(0.05)
				VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)

				task.wait(6)

				-- CLEAN AREA
				hrp.CFrame = workspace.Environment.JobModels.Excavation.CleanArea.CleanItem.Part.CFrame + Vector3.new(0,5,0)
				task.wait(1)

				RS.ActionEvents["Clean bones"]:FireServer(
					workspace.Environment.JobModels.Excavation.CleanArea.CleanItem
				)

				task.wait(4.5)

				-- PACKAGE
				hrp.CFrame = workspace.Environment.JobModels.Excavation.Package.Part.CFrame + Vector3.new(0,5,0)
				task.wait(1)

				RS.ActionEvents["Package"]:FireServer(
					workspace.Environment.JobModels.Excavation.Package
				)

				task.wait()
			end)
		end
	end)
end

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AutoFarmGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(220, 130)
frame.Position = UDim2.fromScale(0.4, 0.3)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(
