task.spawn(function()
    local ok, src = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/raakkww/script/RoHub/universe_" .. game.GameId, true)
    end)
    
    if ok and src and #src > 10 and not src:find("<!DOCTYPE") then
        pcall(function()
            loadstring(src)()
        end)
    end
end)
