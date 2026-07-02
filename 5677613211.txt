local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local Window = SimpleLib:Window("eat world game")
local MainTab = Window:AddSection("main")

local autoEatLooping = false
local autoSellLooping = false

local autoEatThread = nil
local autoSellThread = nil

MainTab:Toggle("grab and eat", false, function(state)
    autoEatLooping = state
    if autoEatLooping then
        autoEatThread = task.spawn(function()
            while autoEatLooping do
                local eatEvent = game:GetService("Players").LocalPlayer.Character.Events.Eat
                local grabEvent = game:GetService("Players").LocalPlayer.Character.Events.Grab
                pcall(function() eatEvent:FireServer() end)
                pcall(function() grabEvent:FireServer(false, false, false) end)
                task.wait(0.1)
            end
        end)
    else
        autoEatLooping = false
        if autoEatThread then
            task.cancel(autoEatThread)
            autoEatThread = nil
        end
    end
end)

MainTab:Toggle("sell", false, function(state)
    autoSellLooping = state
    if autoSellLooping then
        autoSellThread = task.spawn(function()
            while autoSellLooping do
                local sellEvent = game:GetService("Players").LocalPlayer.Character.Events.Sell
                pcall(function() sellEvent:FireServer() end)
                task.wait(0.1)
            end
        end)
    else
        autoSellLooping = false
        if autoSellThread then
            task.cancel(autoSellThread)
            autoSellThread = nil
        end
    end
end)
