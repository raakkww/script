task.spawn(function()
    local ok, err = pcall(function()
        local placeId = tostring(game.PlaceId)
        local url = "https://raw.githubusercontent.com/raakkww/asdwasdwasdwasdwa/aaaaaaaaaaaaaaaaaaaaa/" .. placeId .. ".lua"

        local source = game:HttpGet(url)
        assert(source and #source > 5, "Game script not found")

        loadstring(source)()
    end)

    if not ok then
        warn("[LOADER ERROR]:", err)
    end
end)
