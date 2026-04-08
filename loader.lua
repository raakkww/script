task.spawn(function()
    local function loadScript(id)
        local url = "https://raw.githubusercontent.com/raakkww/script/refs/heads/hoho/" .. id .. ".txt"
        
        local ok, source = pcall(function()
            return game:HttpGet(url, true)
        end)

        if not ok then
            return false, "HttpGet failed: " .. tostring(source)
        end

        if not source or #source <= 5 then
            return false, "Empty or too short"
        end

        if source:find("<!DOCTYPE") or source:find("404: Not Found") then
            return false, "404 or invalid response"
        end

        local loadOk, loadErr = pcall(loadstring(source))
        if not loadOk then
            return false, "loadstring error: " .. tostring(loadErr)
        end

        return true
    end

    local placeId = tostring(game.PlaceId)
    local universeId = tostring(game.GameId)

    local ok1, err1 = loadScript(placeId)
    if not ok1 then
        warn("[LOADER] PlaceId failed: " .. err1)

        local ok2, err2 = loadScript(universeId)
        if not ok2 then
            warn("[LOADER] UniverseId failed: " .. err2)
        end
    end
end)
