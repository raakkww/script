local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FelixsFood = ReplicatedStorage.PlaceFoodOrder

local Foodies: table = {} 
for i = 1, 7999 do
    table.insert(Foodies, "Fried Chicken") -- This is basically create a new entry into the array with the value "Fried Chicken"
end
while task.wait(.2) do
    FelixsFood:FireServer( -- Game sends a table to the server with the items you want, and so we can call the table we created
        Foodies
    )
end
