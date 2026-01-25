local PrestigeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sbertinato7-boop/PrestigeUILib/refs/heads/main/main"))()
local window = PrestigeUI:Create("") -- Renamed here

-- Global variables
getgenv().customerWalkSpeed = 16
getgenv().customerSpeedEnabled = false
getgenv().autoCollectCoins = false
getgenv().autoSell = false
getgenv().autoItemPickup = false
getgenv().autoOpenContainers = false
getgenv().autoBuyOPContainer = false
getgenv().autoUpgrades = false
getgenv().autoBuyContainers = false
getgenv().selectedContainer = "Junk [100]"
getgenv().upgradeSettings = getgenv().upgradeSettings or {
    inventoryItems = false,
    flowers = false,
    customers = false,
    enchantmentSlots = false,
    containers = false,
    plotItems = false
}
getgenv().pickedUpItems = getgenv().pickedUpItems or {}
getgenv().startingMoney = getgenv().startingMoney or 0

-- Helper function to convert money strings to numbers
local function safeToNumber(value)
    if type(value) == "number" then
        return value
    elseif type(value) == "string" then
        local numStr = value:gsub(",", ""):upper()
        local multiplier = 1
        if numStr:find("K") then
            multiplier = 1000
            numStr = numStr:gsub("K", "")
        elseif numStr:find("M") then
            multiplier = 1000000
            numStr = numStr:gsub("M", "")
        elseif numStr:find("B") then
            multiplier = 1000000000
            numStr = numStr:gsub("B", "")
        elseif numStr:find("T") then
            multiplier = 1000000000000
            numStr = numStr:gsub("T", "")
        end
        local number = tonumber(numStr)
        if number then
            return number * multiplier
        end
    end
    return 0
end

spawn(function()
    task.wait(2)
    pcall(function()
        local player = game.Players.LocalPlayer
        if player and player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Money") then
            if getgenv().startingMoney == 0 then
                getgenv().startingMoney = safeToNumber(player.leaderstats.Money.Value)
            end
        end
    end)
end)

local function buyOPContainer()
    if not getgenv().autoBuyOPContainer then return end
    pcall(function()
        local args = {
            buffer.fromstring("*"),
            buffer.fromstring("\254\000\000")
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Warp"):WaitForChild("Index"):WaitForChild("Event"):WaitForChild("Reliable"):FireServer(unpack(args))
    end)
end

local function fireContainer(payload)
    local warpEvent = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
        :WaitForChild("Shared"):WaitForChild("Warp"):WaitForChild("Index")
        :WaitForChild("Event"):WaitForChild("Reliable")
    for _, symbol in ipairs({"4", "6"}) do
        pcall(function()
            local args = {buffer.fromstring(symbol), buffer.fromstring(payload)}
            warpEvent:FireServer(unpack(args))
        end)
    end
end

local function buySelectedContainer()
    if not getgenv().selectedContainer then return end
    local containerName = getgenv().selectedContainer:match("([^%[]+)"):gsub("%s+$", "")
    local containerPayloads = {
        ["Junk"] = "\254\001\000\006\rJunkContainer",
        ["Scratched"] = "\254\001\000\006\018ScratchedContainer",
        ["Sealed"] = "\254\001\000\006\015SealedContainer",
        ["Military"] = "\254\001\000\006\017MilitaryContainer",
        ["Metal"] = "\254\001\000\006\014MetalContainer",
        ["Frozen"] = "\254\001\000\006\015FrozenContainer",
        ["Lava"] = "\254\001\000\006\rLavaContainer",
        ["Corrupted"] = "\254\001\000\006\018CorruptedContainer",
        ["Stormed"] = "\254\001\000\006\016StormedContainer",
        ["Lightning"] = "\254\001\000\006\018LightningContainer",
        ["Infernal"] = "\254\001\000\006\017InfernalContainer",
        ["Mystic"] = "\254\001\000\006\015MysticContainer",
        ["Glitched"] = "\254\001\000\006\017GlitchedContainer",
        ["Astral"] = "\254\001\000\006\015AstralContainer",
        ["Dream"] = "\254\001\000\006\014DreamContainer",
        ["Celestial"] = "\254\001\000\006\018CelestialContainer",
        ["Fire"] = "\254\001\000\006\rFireContainer",
        ["Golden"] = "\254\001\000\006\015GoldenContainer",
        ["Diamond"] = "\254\001\000\006\016DiamondContainer",
        ["Emerald"] = "\254\001\000\006\016EmeraldContainer",
        ["Ruby"] = "\254\001\000\006\rRubyContainer",
        ["Sapphire"] = "\254\001\000\006\017SapphireContainer",
        ["Space"] = "\254\001\000\006\014SpaceContainer",
        ["Deep Space"] = "\254\001\000\006\018DeepSpaceContainer",
        ["Vortex"] = "\254\001\000\006\015VortexContainer",
        ["Black Hole"] = "\254\001\000\006\018BlackHoleContainer",
        ["Camo"] = "\254\001\000\006\rCamoContainer"
    }
    local payload = containerPayloads[getgenv().selectedContainer]
    if payload then
        fireContainer(payload)
    end
end

local function openAllContainers()
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character.HumanoidRootPart then return end
    local playerPos = player.Character.HumanoidRootPart.Position
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("ProximityPrompt") and item.ActionText == "Open Container!" then
            local containerModel = item.Parent
            if containerModel then
                local containerPos = nil
                if containerModel:FindFirstChild("HumanoidRootPart") then
                    containerPos = containerModel.HumanoidRootPart.Position
                elseif containerModel:IsA("BasePart") then
                    containerPos = containerModel.Position
                elseif containerModel:IsA("Model") and containerModel.PrimaryPart then
                    containerPos = containerModel.PrimaryPart.Position
                elseif containerModel:IsA("Model") then
                    containerPos = containerModel:GetPivot().Position
                end
                if containerPos and (containerPos - playerPos).Magnitude <= 180 then
                    if containerModel:FindFirstChild("HumanoidRootPart") then
                        containerModel:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                    elseif containerModel:IsA("BasePart") then
                        containerModel.CFrame = CFrame.new(playerPos + Vector3.new(0, 2, 0))
                    elseif containerModel:IsA("Model") and containerModel.PrimaryPart then
                        containerModel:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                    elseif containerModel:IsA("Model") then
                        containerModel:PivotTo(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                    end
                    task.wait(0.1)
                    pcall(function() fireproximityprompt(item) end)
                end
            end
        end
    end
end

local function autoOpenAllContainers()
    if not getgenv().autoOpenContainers then return end
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character.HumanoidRootPart then return end
    local playerPos = player.Character.HumanoidRootPart.Position
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("ProximityPrompt") and item.ActionText == "Open Container!" then
            local containerModel = item.Parent
            if containerModel then
                local containerPos = nil
                if containerModel:FindFirstChild("HumanoidRootPart") then
                    containerPos = containerModel.HumanoidRootPart.Position
                elseif containerModel:IsA("BasePart") then
                    containerPos = containerModel.Position
                elseif containerModel:IsA("Model") and containerModel.PrimaryPart then
                    containerPos = containerModel.PrimaryPart.Position
                elseif containerModel:IsA("Model") then
                    containerPos = containerModel:GetPivot().Position
                end
                if containerPos and (containerPos - playerPos).Magnitude <= 130 then
                    if containerModel:FindFirstChild("HumanoidRootPart") then
                        containerModel:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                    elseif containerModel:IsA("BasePart") then
                        containerModel.CFrame = CFrame.new(playerPos + Vector3.new(0, 2, 0))
                    elseif containerModel:IsA("Model") and containerModel.PrimaryPart then
                        containerModel:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                    elseif containerModel:IsA("Model") then
                        containerModel:PivotTo(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                    end
                    task.wait(0.1)
                    pcall(function() fireproximityprompt(item) end)
                end
            end
        end
    end
end

local function collectContainerItems()
    if not getgenv().autoItemPickup then return end
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character.HumanoidRootPart then return end
    local playerPos = player.Character.HumanoidRootPart.Position
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("ProximityPrompt") and item.ActionText == "Pick up!" then
            local itemModel = item.Parent
            if itemModel and itemModel.Name:match("^ITEM_") and not getgenv().pickedUpItems[itemModel.Name] then
                local itemPos
                if itemModel:FindFirstChild("HumanoidRootPart") then
                    itemPos = itemModel.HumanoidRootPart.Position
                elseif itemModel:IsA("BasePart") then
                    itemPos = itemModel.Position
                elseif itemModel:IsA("Model") and itemModel.PrimaryPart then
                    itemPos = itemModel.PrimaryPart.Position
                end
                if itemPos and (itemPos - playerPos).Magnitude <= 100 then
                    local inSellZone = false
                    pcall(function()
                        local gameplay = workspace:FindFirstChild("Gameplay")
                        if gameplay then
                            local plots = gameplay:FindFirstChild("Plots")
                            if plots then
                                for _, plot in pairs(plots:GetChildren()) do
                                    local plotLogic = plot:FindFirstChild("PlotLogic")
                                    if plotLogic then
                                        local zones = plotLogic:FindFirstChild("Zones")
                                        if zones then
                                            local sellableZone = zones:FindFirstChild("SellableZone")
                                            if sellableZone and sellableZone:IsA("Part") then
                                                if (itemPos - sellableZone.Position).Magnitude <= 20 then
                                                    inSellZone = true
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    if not inSellZone then
                        if itemModel:FindFirstChild("HumanoidRootPart") then
                            itemModel:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                        elseif itemModel:IsA("BasePart") then
                            itemModel.CFrame = CFrame.new(playerPos + Vector3.new(0, 2, 0))
                        elseif itemModel:IsA("Model") and itemModel.PrimaryPart then
                            itemModel:SetPrimaryPartCFrame(CFrame.new(playerPos + Vector3.new(0, 2, 0)))
                        end
                        task.wait(0.05)
                        pcall(function() fireproximityprompt(item) end)
                        getgenv().pickedUpItems[itemModel.Name] = true
                    end
                end
            end
        end
    end
end

local function collectAllCoins()
    if not getgenv().autoCollectCoins then return end
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character.HumanoidRootPart then return end
    local playerPos = player.Character.HumanoidRootPart.Position
    local coinHolder = workspace:FindFirstChild("Gameplay")
    if coinHolder then
        coinHolder = coinHolder:FindFirstChild("CoinHolder")
        if coinHolder then
            for _, coin in pairs(coinHolder:GetChildren()) do
                if coin.Name:find("MONEY_SPAWN") and coin:IsA("MeshPart") then
                    coin.CFrame = CFrame.new(playerPos + Vector3.new(0, 2, 0))
                    local proximityPrompt = coin:FindFirstChildOfClass("ProximityPrompt")
                    if proximityPrompt then
                        pcall(function() fireproximityprompt(proximityPrompt) end)
                    end
                end
            end
        end
    end
end

local function hasItemsInInventory()
    local player = game.Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    if backpack and #backpack:GetChildren() > 0 then
        return true
    end
    return false
end

local function dropAllItems()
    if not getgenv().autoSell then return end
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not hasItemsInInventory() then return end
    local sellZonePosition = nil
    local playerPos = player.Character.HumanoidRootPart.Position
    local closestDistance = math.huge
    pcall(function()
        local gameplay = workspace:FindFirstChild("Gameplay")
        if gameplay then
            local plots = gameplay:FindFirstChild("Plots")
            if plots then
                for _, plot in pairs(plots:GetChildren()) do
                    local plotLogic = plot:FindFirstChild("PlotLogic")
                    if plotLogic then
                        local zones = plotLogic:FindFirstChild("Zones")
                        if zones then
                            local sellableZone = zones:FindFirstChild("SellableZone")
                            if sellableZone and sellableZone:IsA("Part") then
                                local distance = (sellableZone.Position - playerPos).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    sellZonePosition = sellableZone.Position
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
    if sellZonePosition then
        local currentPosition = player.Character.HumanoidRootPart.CFrame
        spawn(function()
            local targetPosition = Vector3.new(sellZonePosition.X, currentPosition.Position.Y, sellZonePosition.Z)
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            task.wait(0.15)
            -- Call both remotes (\v and \r)
            local warpEvent = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("Warp"):WaitForChild("Index"):WaitForChild("Event"):WaitForChild("Reliable")
            local argsV = {buffer.fromstring("\v"), buffer.fromstring("\254\000\000")}
            local argsR = {buffer.fromstring("\r"), buffer.fromstring("\254\000\000")}
            warpEvent:FireServer(unpack(argsV))
            task.wait(0.05)
            warpEvent:FireServer(unpack(argsR))
            task.wait(0.1)
            player.Character.HumanoidRootPart.CFrame = currentPosition
        end)
    end
end

local function setAllCustomersSpeed(speed)
    local customersFolder = workspace:FindFirstChild("Gameplay")
    if customersFolder then
        customersFolder = customersFolder:FindFirstChild("Customers")
        if customersFolder then
            for _, customer in pairs(customersFolder:GetChildren()) do
                if customer:IsA("Model") then
                    local humanoid = customer:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = speed
                    end
                end
            end
        end
    end
end

spawn(function()
    local customersFolder = workspace:FindFirstChild("Gameplay")
    if customersFolder then
        customersFolder = customersFolder:FindFirstChild("Customers")
        if customersFolder then
            customersFolder.ChildAdded:Connect(function(newCustomer)
                if newCustomer:IsA("Model") and getgenv().customerSpeedEnabled then
                    task.wait(0.5)
                    local humanoid = newCustomer:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = getgenv().customerWalkSpeed
                    end
                end
            end)
        end
    end
end)

local function formatMoney(amount)
    if amount >= 1000000000000 then
        return string.format("%.2fT", amount / 1000000000000)
    elseif amount >= 1000000000 then
        return string.format("%.2fB", amount / 1000000000)
    elseif amount >= 1000000 then
        return string.format("%.2fM", amount / 1000000)
    elseif amount >= 1000 then
        return string.format("%.2fK", amount / 1000)
    else
        return string.format("%.0f", amount)
    end
end

-- Create UI Tabs
local automationTab = window:AddTab("Automation")
local updatesTab = window:AddTab("Updates") -- Only these two tabs now

-- Removed "Customers" and "Statistics" tabs creation and references.

-- Automation tab content
window:AddLabel(automationTab, "Auto Features")
window:AddDivider(automationTab)

local function addHoverAnimation(toggle)
    -- Placeholder for hover animation if your library supports it
end

local autoPickupToggle = window:AddToggle(automationTab, "Auto Item Pickup", function(value)
    getgenv().autoItemPickup = value
    if value then
        spawn(function()
            while getgenv().autoItemPickup do
                collectContainerItems()
                task.wait(0.1)
            end
        end)
    end
end)
-- addHoverAnimation(autoPickupToggle)

local autoSellToggle = window:AddToggle(automationTab, "Auto Sell", function(value)
    getgenv().autoSell = value
    if value then
        spawn(function()
            while getgenv().autoSell do
                dropAllItems()
                task.wait(5)
            end
        end)
    end
end)
-- addHoverAnimation(autoSellToggle)

local autoOpenToggle = window:AddToggle(automationTab, "Auto Open Containers", function(value)
    getgenv().autoOpenContainers = value
    if value then
        spawn(function()
            while getgenv().autoOpenContainers do
                autoOpenAllContainers()
                task.wait(2)
            end
        end)
    end
end)
-- addHoverAnimation(autoOpenToggle)

local autoCollectCoinsToggle = window:AddToggle(automationTab, "Auto Collect Coins", function(value)
    getgenv().autoCollectCoins = value
    if value then
        spawn(function()
            while getgenv().autoCollectCoins do
                collectAllCoins()
                task.wait(0.1)
            end
        end)
    end
end)
-- addHoverAnimation(autoCollectCoinsToggle)

-- 4. Fade-in animation for GUI
local function fadeInGui()
    window.Root.Transparency = 1
    window.Root.Visible = true
    for i=1, 0, -0.1 do
        window.Root.Transparency = i
        task.wait(0.05)
    end
    window.Root.Transparency = 0
end

fadeInGui()

-- 5. Add input area in "Updates" tab for your change logs
window:AddLabel(updatesTab, "Enter your latest updates:")
local updateInput = window:AddTextBox(updatesTab, "Type your updates here", function(text)
   
end)

-- Store the label for displaying saved updates
local updatesDisplay

-- Add a button to save and show the updates
window:AddButton(updatesTab, "Save Updates", function()
    local text = updateInput:GetText()
    if updatesDisplay then 
        updatesDisplay:Destroy() -- Remove previous display
    end
    updatesDisplay = window:AddLabel(updatesTab, "Your last update: " .. text)
end)
