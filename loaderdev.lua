task.spawn(function()
    local ok, err = pcall(function()
        local id = tostring(game.GameId):gsub("%s+", "")
        local url = "https://raw.githubusercontent.com/raakkww/script/RoHub/" .. id
        local src = game:HttpGet(url, true)
        assert(src and #src > 10 and not src:find("<!DOCTYPE"), "Not found")
        loadstring(src)()
        print("Loaded: " .. id)
    end)

    if not ok then
        warn("Error detail: " .. tostring(err))  -- lihat error aslinya
    end
end)
