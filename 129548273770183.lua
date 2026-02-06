-- Waste-Time Auto Redeem Codes (No Access Check)
-- Clean version with mobile-friendly GUI
-- Credits: NoHub - Noctyra

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Flags
local ScriptEnabled = true
local Settings = {
    AutoRedeemCodes = false
}

-- Active codes database (Updated: February 2026)
local ActiveCodes = {
    "gullible",
    "sorryforbrokenclans",
    "10millionvisitswow",
    "sorryforP2W",
    "20kccu",
    "freererollsfr",
    "freelocksfr",
    "holymoly",
    "superduperhidden",
    "yetanothercompensation",
    "imsosorry",
    "freeclicks",
    "moreclicksfr",
    "wehavecodesnow"
}

local RedeemedCodes = {}

-- ═══════════════════════════════════════════════════════════
-- MAIN GUI CREATION
-- ═══════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local TitleCorner = Instance.new("UICorner")
local AutoRedeemButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local CodesLabel = Instance.new("TextLabel")
local CreditsLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")

ScreenGui.Name = "WasteTimeCodesGUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main frame (mobile-optimized size)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -160)
MainFrame.Size = UDim2.new(0, 400, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Title bar
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Font = Enum.Font.GothamBold
Title.Text = "🎁 Waste-Time Auto Codes"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 15, 0, 10)

TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Credits label (required)
CreditsLabel.Name = "CreditsLabel"
CreditsLabel.Parent = MainFrame
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Position = UDim2.new(1, -15, 0, 12)
CreditsLabel.Size = UDim2.new(0, 150, 0, 20)
CreditsLabel.Font = Enum.Font.Gotham
CreditsLabel.Text = "NoHub - Noctyra"
CreditsLabel.TextColor3 = Color3.fromRGB(120, 120, 255)
CreditsLabel.TextSize = 13
CreditsLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Auto Redeem button (touch-optimized size)
AutoRedeemButton.Name = "AutoRedeemButton"
AutoRedeemButton.Parent = MainFrame
AutoRedeemButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
AutoRedeemButton.BorderSizePixel = 0
AutoRedeemButton.Position = UDim2.new(0, 20, 0, 70)
AutoRedeemButton.Size = UDim2.new(0, 360, 0, 60) -- Larger for touch
AutoRedeemButton.Font = Enum.Font.GothamSemibold
AutoRedeemButton.Text = "🎁 Auto Redeem Codes: OFF"
AutoRedeemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoRedeemButton.TextSize = 16
AutoRedeemButton.AutoButtonColor = false

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = AutoRedeemButton

-- Codes statistics
CodesLabel.Name = "CodesLabel"
CodesLabel.Parent = MainFrame
CodesLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
CodesLabel.BorderSizePixel = 0
CodesLabel.Position = UDim2.new(0, 20, 0, 145)
CodesLabel.Size = UDim2.new(0, 360, 0, 70)
CodesLabel.Font = Enum.Font.Gotham
CodesLabel.Text = "🎁 Codes Redeemed: 0/" .. #ActiveCodes .. "\n📋 Total Codes: " .. #ActiveCodes
CodesLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
CodesLabel.TextSize = 14
CodesLabel.TextWrapped = true
CodesLabel.TextXAlignment = Enum.TextXAlignment.Left

local codesCorner = Instance.new("UICorner")
codesCorner.CornerRadius = UDim.new(0, 10)
codesCorner.Parent = CodesLabel

-- Status label
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 20, 0, 230)
StatusLabel.Size = UDim2.new(0, 360, 0, 30)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.Text = "✅ Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.TextSize = 14

-- Close button (mobile-friendly size)
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(1, -42, 0, 10)
CloseButton.Size = UDim2.new(0, 35, 0, 35) -- Larger tap target
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.AutoButtonColor = false

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseButton

-- ═══════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════
local function UpdateStatus(text, color)
    if not ScriptEnabled then return end
    StatusLabel.Text = "✅ Status: " .. text
    StatusLabel.TextColor3 = color or Color3.fromRGB(100, 255, 100)
end

local function UpdateCodesStats()
    if not ScriptEnabled then return end
    CodesLabel.Text = string.format("🎁 Codes Redeemed: %d/%d\n📋 Total Codes: %d", #RedeemedCodes, #ActiveCodes, #ActiveCodes)
end

local function StopAllScripts()
    ScriptEnabled = false
    Settings.AutoRedeemCodes = false
    
    UpdateStatus("Disabled", Color3.fromRGB(255, 100, 100))
    wait(0.3)
    
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
    
    print("Waste-Time Auto Codes disabled and removed!")
end

-- Code redemption function
local function RedeemCode(code)
    if not ScriptEnabled then return false end
    if table.find(RedeemedCodes, code) then return false end
    
    local success = false
    
    pcall(function()
        -- Method 1: RemoteEvents/RemoteFunctions in ReplicatedStorage
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local nameLower = v.Name:lower()
                if nameLower:find("code") or nameLower:find("redeem") or nameLower:find("promo") then
                    if v:IsA("RemoteEvent") then
                        v:FireServer(code)
                        v:FireServer("Redeem", code)
                        v:FireServer({Code = code})
                    else
                        v:InvokeServer(code)
                    end
                    success = true
                end
            end
        end
        
        -- Method 2: TextBox + Button interaction
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, gui in pairs(playerGui:GetDescendants()) do
                if gui:IsA("TextBox") then
                    local guiName = gui.Name:lower()
                    if guiName:find("code") or guiName:find("input") then
                        gui.Text = code
                        
                        local parent = gui.Parent
                        if parent then
                            for _, btn in pairs(parent:GetDescendants()) do
                                if btn:IsA("TextButton") then
                                    local btnName = btn.Name:lower()
                                    if btnName:find("redeem") or btnName:find("submit") then
                                        if getconnections then
                                            for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                                conn:Fire()
                                            end
                                        end
                                        success = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if success then
            table.insert(RedeemedCodes, code)
            UpdateStatus("✅ Redeemed: " .. code, Color3.fromRGB(100, 255, 100))
            UpdateCodesStats()
        else
            table.insert(RedeemedCodes, code)
            UpdateCodesStats()
        end
    end)
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- AUTO REDEEM LOOP
-- ═══════════════════════════════════════════════════════════
spawn(function()
    wait(2) -- Initial delay for game to load
    
    while wait(2.5) do
        if not ScriptEnabled then break end
        if Settings.AutoRedeemCodes then
            local allRedeemed = true
            
            for _, code in ipairs(ActiveCodes) do
                if not ScriptEnabled or not Settings.AutoRedeemCodes then break end
                
                if not table.find(RedeemedCodes, code) then
                    allRedeemed = false
                    UpdateStatus("🎁 Redeeming: " .. code, Color3.fromRGB(255, 200, 100))
                    
                    local success = RedeemCode(code)
                    if success then
                        pcall(function()
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "✅ Code Redeemed!";
                                Text = code;
                                Duration = 2;
                            })
                        end)
                    end
                    
                    wait(2.5)
                end
            end
            
            if allRedeemed and #RedeemedCodes > 0 then
                UpdateStatus("🎉 All codes redeemed!", Color3.fromRGB(100, 255, 100))
                Settings.AutoRedeemCodes = false
                AutoRedeemButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
                AutoRedeemButton.Text = "🎁 Auto Redeem Codes: OFF"
                
                pcall(function()
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "🎉 Complete!";
                        Text = "All " .. #RedeemedCodes .. " codes redeemed!",
                        Duration = 4;
                    })
                end)
            end
            
            UpdateCodesStats()
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- GUI INTERACTIONS (Touch-Optimized)
-- ═══════════════════════════════════════════════════════════
AutoRedeemButton.MouseButton1Click:Connect(function()
    if not ScriptEnabled then return end
    
    Settings.AutoRedeemCodes = not Settings.AutoRedeemCodes
    
    if Settings.AutoRedeemCodes then
        AutoRedeemButton.BackgroundColor3 = Color3.fromRGB(75, 255, 75)
        AutoRedeemButton.Text = "🎁 Auto Redeem Codes: ON"
        
        TweenService:Create(AutoRedeemButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 240, 60)}):Play()
        wait(0.1)
        TweenService:Create(AutoRedeemButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(75, 255, 75)}):Play()
        
        pcall(function()
            game.StarterGui:SetCore("SendNotification", {
                Title = "🎁 Auto Redeem Active";
                Text = "Redeeming " .. #ActiveCodes .. " codes...";
                Duration = 3;
            })
        end)
    else
        AutoRedeemButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        AutoRedeemButton.Text = "🎁 Auto Redeem Codes: OFF"
        
        TweenService:Create(AutoRedeemButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(240, 60, 60)}):Play()
        wait(0.1)
        TweenService:Create(AutoRedeemButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 75, 75)}):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    -- Smooth fade-out animation
    TweenService:Create(MainFrame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TweenService:Create(MainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    
    wait(0.25)
    StopAllScripts()
end)

-- Hover/touch effects
AutoRedeemButton.MouseEnter:Connect(function()
    if ScriptEnabled then
        TweenService:Create(AutoRedeemButton, TweenInfo.new(0.15), {Size = UDim2.new(0, 368, 0, 64)}):Play()
    end
end)

AutoRedeemButton.MouseLeave:Connect(function()
    if ScriptEnabled then
        TweenService:Create(AutoRedeemButton, TweenInfo.new(0.15), {Size = UDim2.new(0, 360, 0, 60)}):Play()
    end
end)

CloseButton.MouseEnter:Connect(function()
    if ScriptEnabled then
        TweenService:Create(CloseButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end
end)

CloseButton.MouseLeave:Connect(function()
    if ScriptEnabled then
        TweenService:Create(CloseButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- FINAL INITIALIZATION
-- ═══════════════════════════════════════════════════════════
-- Fade-in animation
MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 400, 0, 320)}):Play()

wait(0.5)
UpdateStatus("Ready", Color3.fromRGB(100, 255, 100))
UpdateCodesStats()

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "🎁 Waste-Time Codes Loaded";
        Text = "NoHub - Noctyra | " .. #ActiveCodes .. " codes available";
        Duration = 4;
    })
end)

print("═══════════════════════════════════════")
print("✅ Waste-Time Auto Codes Loaded")
print("✨ Credits: NoHub - Noctyra")
print("📱 Mobile & PC Optimized")
print("═══════════════════════════════════════")
