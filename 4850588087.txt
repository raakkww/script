game.StarterGui:SetCore("SendNotification", {
    Title = "Did you know?",
    Text = "<- This is the sword you'll need.",
    Icon = "rbxassetid://10464310283", 
    Duration = 4,
    Button1 = "Shut the fuck up",
})
local RunService = game:GetService("RunService") local renderConnection 
local function onRenderStep(deltaTime) game:GetService("Players").LocalPlayer.Character.DragonSlayersSwordShield.PlayEffect:FireServer("RapidSlash")
 end
  renderConnection = RunService.RenderStepped:Connect(onRenderStep)
