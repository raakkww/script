task.spawn(function()
    local ok, err = pcall(function()
        local placeId = tostring(game.PlaceId)
        local url = "https://pastefy.app/3PAJv2mD/raw?part=" .. placeId .. ".txt"

        local source = game:HttpGet(url)
        assert(source and #source > 5, "Game script not found")

        loadstring(source)()
    end)

    if not ok then
        warn("[LOADER ERROR]:", err)
    end
end)
