local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

-- // Load WindUI // --
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- // GLOBAL STATES // --
local State = {
    AutoSubmit = false,
    CurrentWord = "No Word Detected :(",
}

-- // WORD CONFIGURATION (1:1 Logic) // --
local WordMap = {
    eletricity = "electricity",
    genuis = "genius",
    ["uncostutional "] = "uncostitutional",
    ["paradigm #219"] = "boat",
    ["notebook v2"] = "notebook",
    ["potted plant"] = "pot",
    hydroeletric = "hydroelectric",
    phiosopher = "philosopher",
    yt = "youtube",
}

local IgnoreSounds = {
    blood_splat = true,
    ["coins-and-gems-treasure-sound-effect"] = true,
}

-- // WINDOW SETUP // --
local Window = WindUI:CreateWindow({
    Title = "Utility", 
    Icon = "solar:keyboard-bold",
    Folder = "Utility_AutoType",
})

-- // TABS // --
local MainTab = Window:Tab({ Title = "Main", Icon = "solar:settings-bold" })

-- // UI ELEMENTS // --
MainTab:Section({ Title = "Detection Status" })

local WordLabel = MainTab:Button({
    Title = "Detected: No Word Detected :(",
    Desc = "Click to manual submit",
    Callback = function()
        if State.CurrentWord ~= "No Word Detected :(" then
            ReplicatedStorage:WaitForChild("Events"):WaitForChild("GameEvent"):FireServer("submitAnswer", State.CurrentWord:lower())
        end
    end
})

MainTab:Section({ Title = "Automation" })

MainTab:Toggle({
    Title = "Auto Submit",
    Desc = "Automatically send the true word",
    Value = false,
    Callback = function(v)
        State.AutoSubmit = v
    end
})

MainTab:Button({
    Title = "Copy Detected Word",
    Callback = function()
        if State.CurrentWord ~= "No Word Detected :(" then
            setclipboard(State.CurrentWord)
            WindUI:Notify({ Title = "Copied", Content = "Word copied to clipboard." })
        end
    end
})

-- // CORE LOGIC (1:1 Ported) // --

local function UpdateWord(soundName)
    State.CurrentWord = WordMap[soundName:lower()] or soundName:lower()
    WordLabel:SetTitle("Detected: " .. State.CurrentWord)
end

-- Sound Detection Logic
game.DescendantAdded:Connect(function(obj)
    if obj:IsA("Sound") then
        local id = string.match(obj.SoundId, "%d+")
        if id then
            local success, info = pcall(function()
                return MarketplaceService:GetProductInfo(id)
            end)
            
            if success and info and info.Name then
                local cleanName = info.Name:gsub("%s?%(%d+%)", "")
                if IgnoreSounds[cleanName:lower()] then return end
                
                -- Original Logic: Destroy sound and process word
                obj.Parent = workspace
                obj.Volume = 0
                obj:Destroy()
                
                UpdateWord(cleanName)
                
                -- Auto Submit Logic (1:1 Loop)
                if State.AutoSubmit then
                    for i = 1, 5 do
                        task.spawn(function()
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("GameEvent"):FireServer("submitAnswer", State.CurrentWord:lower())
                        end)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- Notification
WindUI:Notify({
    Title = "Loaded",
    Content = "Auto Answer system is active.",
    Duration = 3
})
