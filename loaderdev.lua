task.spawn(function()
    local function tryLoad(id)
        local url = "https://raw.githubusercontent.com/raakkww/script/RoHub/" .. tostring(id)
        local src = game:HttpGet(url, true)
        assert(src and #src > 10 and not src:find("<!DOCTYPE"), "Not found")
        loadstring(src)()
        return true
    end

    local ok, err = pcall(tryLoad, game.GameId)

    if not ok then
        -- fallback ke PlaceId
        ok, err = pcall(tryLoad, game.PlaceId)
    end

    if not ok then
        warn("Error: " .. tostring(err))

        local universeId = tostring(game.GameId)
        warn("Buat file: " .. universeId)

        pcall(function()
            setclipboard(universeId)
            print("✅ Universe ID copied: " .. universeId)
        end)

        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Script Not Found",
                Text = "Universe ID copied to clipboard!\n" .. universeId,
                Duration = 10,
                Button1 = "OK"
            })
        end)
    end
end)
