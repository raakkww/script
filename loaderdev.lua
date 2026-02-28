task.spawn(function()
    local ok, err = pcall(function()
        -- PAKAI GAMEID (Universe ID), BUKAN PLACEID
        local id = tostring(game.GameId)
        local url = "https://raw.githubusercontent.com/raakkww/script/RoHub/" .. id
        
        local src = game:HttpGet(url, true)
        assert(src and #src > 10 and not src:find("<!DOCTYPE"), "Not found")
        
        loadstring(src)()
        print("Loaded: " .. id)
    end)
    
    if not ok then 
        warn("Error: " .. tostring(err))
        
        local universeId = tostring(game.GameId)
        warn("Buat file:" .. universeId)
        
        -- AUTO COPY KE CLIPBOARD
        pcall(function()
            setclipboard(universeId)
            print("✅ Universe ID copied: " .. universeId)
        end)
        
        -- Notifikasi UI
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
