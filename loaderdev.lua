task.spawn(function()
    local ok, err = pcall(function()
        -- PAKAI GAMEID (Universe ID), BUKAN PLACEID
        local id = tostring(game.GameId)
        local url = "https://raw.githubusercontent.com/raakkww/script/RoHub/universe_" .. id
        
        local src = game:HttpGet(url, true)
        assert(src and #src > 10 and not src:find("<!DOCTYPE"), "Not found")
        
        loadstring(src)()
        print("Loaded: universe_" .. id)
    end)
    
    if not ok then 
        warn("Error: " .. tostring(err))
        warn("Buat file: universe_" .. tostring(game.GameId))
    end
end)
