--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Made by Snickers (sinfulf3dd on discord)

local _C = game:GetService("CoreGui")
local _P = game:GetService("Players")
local _T = game:GetService("TweenService")

if _C:FindFirstChild("ToraScript") then
    _C.ToraScript:Destroy()
end

local _L = loadstring(game:HttpGet("https://raw.githubusercontent.com/liebertsx/Tora-Library/main/src/librarynew", true))()
local _W = _L:CreateWindow("Last Run - Gun Mod")

local _p = _P.LocalPlayer
local _b = {}

local function _antiSit()
    local char = _p.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.Sit then
            hum.Jump = true
        end
    end
end

local function _s(t, e)
    if not t:IsA("Tool") then return end

    if e then
        if not _b[t] then
            _b[t] = {
                a = t:GetAttribute("ammo"),
                d = t:GetAttribute("damage"),
                f = t:GetAttribute("fireMode"),
                rx = t:GetAttribute("recoilMax"),
                rn = t:GetAttribute("recoilMin"),
                ro = t:GetAttribute("rateOfFire"),
            }
        end
        
        t:SetAttribute("ammo", math.huge)
        t:SetAttribute("damage", math.huge)
        t:SetAttribute("fireMode", "Auto")
        t:SetAttribute("recoilMax", Vector2.new(0, 0))
        t:SetAttribute("recoilMin", Vector2.new(0, 0))
        t:SetAttribute("rateOfFire", 0)
    else
        local o = _b[t]
        if o then
            t:SetAttribute("ammo", o.a)
            t:SetAttribute("damage", o.d)
            t:SetAttribute("fireMode", o.f)
            t:SetAttribute("recoilMax", o.rx)
            t:SetAttribute("recoilMin", o.rn)
            t:SetAttribute("rateOfFire", o.ro)
        end
    end
end

local function _a(e)
    local bp = _p:WaitForChild("Backpack")
    local ch = _p.Character or _p.CharacterAdded:Wait()

    for _, t in ipairs(bp:GetChildren()) do _s(t, e) end
    for _, t in ipairs(ch:GetChildren()) do _s(t, e) end
end

_p.Backpack.ChildAdded:Connect(function(t)
    if _G.GM then
        task.wait(0.2)
        _s(t, true)
    end
end)

_p.CharacterAdded:Connect(function(c)
    c.ChildAdded:Connect(function(t)
        if _G.GM then
            task.wait(0.2)
            _s(t, true)
        end
    end)
end)

task.spawn(function()
    while task.wait(0.5) do
        if not _G.GM then continue end
        
        _antiSit()

        local function check(con)
            if not con then return end
            for _, t in ipairs(con:GetChildren()) do
                if t:IsA("Tool") then
                    if t:GetAttribute("ammo") ~= math.huge then t:SetAttribute("ammo", math.huge) end
                    if t:GetAttribute("fireMode") ~= "Auto" then t:SetAttribute("fireMode", "Auto") end
                end
            end
        end

        check(_p.Character)
        check(_p:FindFirstChild("Backpack"))
    end
end)

_W:AddToggle({
    text = "OP GUN MODE",
    state = false,
    callback = function(s)
        _G.GM = s
        _a(s)
    end
})

_W:AddButton({
    text = "Force Anti-Sit",
    callback = function()
        _antiSit()
    end
})

_W:AddLabel("Made by Snickers")
_W:AddLabel("Discord: sinfulf3dd")

_L:Init()
