local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    if getnamecallmethod() == "FireServer" and tostring(self) == "RequestSprintAction" then
        local args = {...}
        if args[1] == "SpeedTarget" then
            args[2] = 0
            return old(self, unpack(args))
        end
    end
    return old(self, ...)
end)
