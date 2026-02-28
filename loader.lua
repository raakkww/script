task.spawn(function()
    local ok, err = pcall(function()
        local placeId = tostring(game.PlaceId)
        local url = "https://raw.githubusercontent.com/raakkww/script/refs/heads/RoHub/" .. placeId ..

        local source = game:HttpGet(url)
        assert(source and #source > 5, "Game script not found")
        assert(not source:find("<!DOCTYPE"), "Invalid response")

        loadstring(source)()
    end)

    if not ok then
        warn("[LOADER ERROR]: " .. tostring(err))
    end
end)
