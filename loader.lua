task.spawn(function()
    local function loadScript(id)
        local url = "https://raw.githubusercontent.com/raakkww/script/refs/heads/hoho/" .. id .. ".txt"
        local source = game:HttpGet(url)

        if not source or #source <= 5 then
            return false, "Empty or too short"
        end

        if source:find("<!DOCTYPE") then
            return false, "Invalid HTML response"
        end

        loadstring(source)()
        return true
    end

    local success, err = pcall(function()
        local placeId = tostring(game.PlaceId)
        local universeId = tostring(game.GameId)

        -- 🔹 Coba Place ID dulu
        local ok, reason = loadScript(placeId)

        if not ok then
            warn("[LOADER] PlaceId failed, trying UniverseId... (" .. tostring(reason) .. ")")

            -- 🔹 Fallback ke Universe ID
            local ok2, reason2 = loadScript(universeId)

            if not ok2 then
                error("Both PlaceId & UniverseId failed: " .. tostring(reason2))
            end
        end
    end)

    if not success then
        warn("[LOADER ERROR]: " .. tostring(err))
    end
end)
