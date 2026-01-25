local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Theme Data
local themes = {
    BloodTheme = Color3.fromRGB(227, 27, 27),
    BlueTheme = Color3.fromRGB(0, 120, 255),
    DarkTheme = Color3.fromRGB(64, 64, 64),
    Midnight = Color3.fromRGB(15, 15, 15),
    GrapeSoda = Color3.fromRGB(132, 71, 255),
    Ocean = Color3.fromRGB(0, 255, 255),
    GreenTheme = Color3.fromRGB(0, 255, 128)
}

local Window = Library.CreateLib("", "BloodTheme")

local lp = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local npcNames = {"Boy", "Girl", "Girlbig", "Boybig"}
local hillCoords = Vector3.new(-319, 39, -201)
local hillSafeRadius = 110

-- --- SPEED LOOP ---
_G.WalkSpeedValue = 16
task.spawn(function()
    while task.wait(0.1) do
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            if lp.Character.Humanoid.WalkSpeed ~= _G.WalkSpeedValue then
                lp.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
            end
        end
    end
end)

-- --- TABS ---
local Main = Window:NewTab("Automation")
local Section = Main:NewSection("Main")
local Safety = Window:NewTab("Safety")
local S_Section = Safety:NewSection("Physics & AFK")
local Utility = Window:NewTab("Utility")
local U_Section = Utility:NewSection("Performance")
local Settings = Window:NewTab("Settings")
local ThemeSection = Settings:NewSection("Menu Config")

-- --- AUTOMATION ---
Section:NewButton("Start Auto Eat", "Automatic movement to targets", function()
    _G.StopNPCTour = false
    task.spawn(function()
        while not _G.StopNPCTour do
            local char = lp.Character or lp.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")

            local possibleFolders = {
                workspace:FindFirstChild("_Client") and workspace._Client:FindFirstChild("human"),
                workspace:FindFirstChild("NPCs"),
                workspace:FindFirstChild("Humans")
            }

            for _, folder in pairs(possibleFolders) do
                if folder then
                    for _, npc in pairs(folder:GetChildren()) do
                        local isTarget = false
                        for _, name in pairs(npcNames) do
                            if npc.Name == name then isTarget = true break end
                        end

                        if isTarget then
                            local targetPart = npc:FindFirstChild("Head") or npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart")
                            if targetPart then
                                local distFromHill = (targetPart.Position - hillCoords).Magnitude
                                local heightDiff = math.abs(targetPart.Position.Y - hrp.Position.Y)

                                if distFromHill > hillSafeRadius and heightDiff < 100 then
                                    hum:MoveTo(targetPart.Position)

                                    local timer = 0
                                    repeat
                                        task.wait(0.2)
                                        timer = timer + 0.2
                                        local distance = (hrp.Position - targetPart.Position).Magnitude
                                    until distance < 7 or timer > 7 or _G.StopNPCTour

                                    if not _G.StopNPCTour then
                                        task.wait(1) 
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

Section:NewButton("Stop Auto Eat", "Stops movement and Resets Character", function()
    _G.StopNPCTour = true
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.Health = 0 -- Resets the player
    end
end)

-- --- PHYSICS & AFK ---
S_Section:NewToggle("Noclip", "Walk through walls and objects", function(state)
    _G.Noclip = state
    task.spawn(function()
        while _G.Noclip do
            if lp.Character then
                for _, v in pairs(lp.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
            RunService.Stepped:Wait()
        end
        if lp.Character then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end)
end)

S_Section:NewToggle("No Climb / No Step", "Stay on flat ground", function(state)
    _G.NoClimb = state
    task.spawn(function()
        while _G.NoClimb do
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.MaxSlopeAngle = 0
                lp.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            end
            task.wait(1)
        end
        if not state and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.MaxSlopeAngle = 89
            lp.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        end
    end)
end)

S_Section:NewButton("Enable Anti-AFK", "Stop idle kicks", function()
    local vu = game:GetService("VirtualUser")
    lp.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

S_Section:NewSlider("Speed", "WalkSpeed (Looped)", 100, 16, function(s)
    _G.WalkSpeedValue = s
end)

-- --- ANTI-LAG ---
U_Section:NewButton("Enable Anti-Lag", "Boost FPS & Reduce Heat", function()
    local t = settings().Rendering
    t.QualityLevel = Enum.QualityLevel.Level01
    settings().Network.IncomingReplicationLag = -1
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("Lighting") then
             v.GlobalShadows = false
        end
    end
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 0
    game:GetService("Lighting").FogEnd = 9e9
end)

-- --- THEME & UI ---
ThemeSection:NewDropdown("Change Theme", "Select a style", {"BloodTheme", "BlueTheme", "DarkTheme", "Midnight", "GrapeSoda", "Ocean", "GreenTheme"}, function(themeName)
    local selectedColor = themes[themeName]
    if selectedColor then
        Library:ChangeColor("SchemeColor", selectedColor)
    end
end)

ThemeSection:NewKeybind("Toggle Menu", "Key to hide/show hub", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)
