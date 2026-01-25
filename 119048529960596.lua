local start_tick = tick();

local replicated_storage = game:GetService("ReplicatedStorage");
local virtual_user = game:GetService("VirtualUser");
local run_service = game:GetService("RunService");
local workspace = game:GetService("Workspace");
local players = game:GetService("Players");

local local_player = players.LocalPlayer;

local player_tycoon = local_player:WaitForChild("Tycoon").Value

if (not player_tycoon) then
    return local_player:Kick("Load in fully with your tycoon to run this script");
end

local player_scripts = local_player:WaitForChild("PlayerScripts");
local events = replicated_storage:WaitForChild("Events");
local drop_folder = workspace:WaitForChild("DropFolder");
local temp = workspace:FindFirstChild("Temp");

local replicated_source = replicated_storage:WaitForChild("Source");
local restaurant_events = events:WaitForChild("Restaurant");
local player_source = player_scripts:WaitForChild("Source");
local farming_events = events:WaitForChild("Farming");
local dialog_events = events:WaitForChild("Dialog");

local task_completed = restaurant_events:WaitForChild("TaskCompleted");
local replicated_utility = replicated_source:WaitForChild("Utility");
local customer_events = restaurant_events:WaitForChild("Customers");
local replicated_data = replicated_source:WaitForChild("Data");
local systems_source = player_source:WaitForChild("Systems");
local tycoon_object = player_tycoon:WaitForChild("Objects");
local tycoon_items = player_tycoon:WaitForChild("Items");

local get_rude_customer_dialog = customer_events:WaitForChild("GetRudeCustomerDialog");
local furniture_modules = replicated_utility:WaitForChild("Furniture");
local tycoon_furniture = tycoon_items:WaitForChild("Furniture");
local farming_data = replicated_data:WaitForChild("Farming");
local restaurant = systems_source:WaitForChild("Restaurant");
local tycoon_surface = tycoon_items:WaitForChild("Surface");
local currency = systems_source:WaitForChild("Currency");
local tycoon_food = tycoon_object:WaitForChild("Food");

local table_connection_utility = require(furniture_modules:WaitForChild("TableConnectionUtility"));
local furniture_utility = require(replicated_utility:WaitForChild("FurnitureUtility"));
local scavanger_hunt = require(systems_source:WaitForChild("ScavengerHunt"));
local daily_rewards = require(systems_source:WaitForChild("DailyRewards"));
local waypoints = require(systems_source:WaitForChild("Waypoints"));
local upgrades = require(systems_source:WaitForChild("Upgrades"));
local teleport = require(systems_source:WaitForChild("Teleport"));
local crop_data = require(farming_data:WaitForChild("CropData"));
local drive_thru = require(restaurant:WaitForChild("DriveThru"));
local customers = require(restaurant:WaitForChild("Customers"));
local farming = require(systems_source:WaitForChild("Farming"));
local grab_food = require(restaurant:WaitForChild("GrabFood"));
local cook = require(systems_source:WaitForChild("Cook"));

local crop_names = {};

local delays = {
    auto_calm_angry_customer = { last_ran = 0, delay = 1 };
    auto_collect_dish = { last_ran = 0, delay = .25 };
    auto_collect_bill = { last_ran = 0, delay = .25 };
    auto_collect_drops = { last_ran = 0, delay = 1 };
    auto_group_order = { last_ran = 0, delay = .5 };
    auto_grab_food = { last_ran = 0, delay = 0 };
    auto_give_food = { last_ran = 0, delay = 0 };
    auto_grab_oder = { last_ran = 0, delay = 0 };
    auto_harvest = { last_ran = 0, delay = 1 };
    auto_seat = { last_ran = 0, delay = .25 };
    auto_daily = { last_ran = 0, delay = 1 };
    auto_tips = { last_ran = 0, delay = 1 };
    auto_crop = { last_ran = 0, delay = 1 };
    auto_cook = { last_ran = 0, delay = 0 }
}

local gui_config = {
	Color = Color3.fromRGB(128, 128, 128);
	Keybind = Enum.KeyCode.End
}

for crop in (crop_data) do
    table.insert(crop_names, crop);
end

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nfpw/XXSCRIPT/main/Library/Module.lua"))();
local window = library:CreateWindow(gui_config, gethui());
library:SetWindowName(""..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name);

local game_utility = {}; do
    function game_utility:get_objects(object_type: string)
        local objects = {};

        for _, object in furniture_utility:FindWhere(player_tycoon, tycoon_surface, function(furniture)
            if (object_type == "Table") then
                return (furniture_utility:IsTable(furniture));
            else
                return (furniture_utility:Is(furniture, object_type));
            end
        end) do
            table.insert(objects, object);
        end

        return (objects);
    end

    function game_utility:get_group_type(group_type: string)
        local groups = {};

        if (group_type == "Customers") then
            for group_id, group_data in (customers:GetStorage(player_tycoon).Groups) do
                local group_info = { id = group_id, data = group_data, customers = {} }
                table.insert(groups, group_info);

                for customer_id, customer_data in (group_data.Customers) do
                    table.insert(group_info.customers, { id = customer_id, data = customer_data });
                end
            end
        elseif (group_type == "Cars") then
            for car_id, car_data in (drive_thru:GetStorage(player_tycoon).Cars) do
                local car_info = { id = car_id, data = car_data };
                table.insert(groups, car_info);
            end
        end

        return (groups);
    end
    
    function game_utility:get_table_for_group(group_size: number)
        for _, table in (game_utility:get_objects("Table")) do
            if (table:GetAttribute("InUse")) then
                continue;
            end
            if (#table_connection_utility:FindChairs(player_tycoon, table) < group_size) then
                continue;
            end
            return (table);
        end
    end

    function game_utility:get_table_item(item: string)
        local items = {};
        for _, table_model in (game_utility:get_objects("Table")) do
            if (item == "Bill") then
                local bill = table_model:FindFirstChild("Bill");
                if (bill) and (not bill:GetAttribute("Taken")) then
                    table.insert(items, table_model);
                end
            elseif (item == "Trash") then
                local trash = table_model:FindFirstChild("Trash");
                if (trash) and (trash:GetAttribute("Collectable")) then
                    table.insert(items, table_model);
                end
            end
        end
        return (items);
    end
end

local utility_handler = {}; do
    function utility_handler:harvest_crops()
        if (#game_utility:get_objects("Fridge") == 0) then
            return;
        end
        for tile in (farming.TrackedTiles) do
            local state = farming:GetState(tile);
            if (state == "Completed") then
                farming_events.RequestHarvest:InvokeServer(tile.Name);
            end
        end
    end
    
    function utility_handler:crop_crops()
        for tile in (farming.TrackedTiles) do
            local state = farming:GetState(tile);
            if (state == "Empty") then
                farming_events.RequestCropPlant:InvokeServer(library.flags.selected_crop[math.random(1, #library.flags.selected_crop)], tile.Name);
            end
        end
    end

    function utility_handler:claim_daily()
        if (not daily_rewards.CanClaim) then
            return;
        end
        daily_rewards:StartOpeningAnimation(daily_rewards.Chest);
    end

    function utility_handler:collect_tip()
        local tip;

        for _, object in (furniture_utility:FindWhere(player_tycoon, tycoon_furniture, function(furniture)
            return (furniture_utility:Is(furniture, "TipJar"))
        end)) do
            tip = object;
            break;
        end
        if (not tip) then
            return;
        end
        local value = tip:GetAttribute("Value");
        if (not value) or (value == 0) then
            return;
        end
        restaurant_events.TipsCollected:FireServer(player_tycoon);
    end

    function utility_handler:seat_groups()
        local groups = game_utility:get_group_type("Customers");
        if (#groups == 0) then
            return;
        end
        for _, group in (groups) do
            if (group.data.State == "Entered") then
                local data = {
                    ["Name"] = "SendToTable";
                    ["GroupId"] = group.id;
                    ["Tycoon"] = player_tycoon;
                    ["FurnitureModel"] = game_utility:get_table_for_group(group.data.NumCustomers)
                }
                task_completed:FireServer(data);
            end
        end
    end

    function utility_handler:take_group_orders()
        local groups = game_utility:get_group_type("Customers");
        if (#groups > 0) then
            for _, group in (groups) do
                for _, customer in (group.customers) do
                    if (customer.data.State == "Ordering") then
                        local data = {
                            ["Name"] = "TakeOrder";
                            ["GroupId"] = group.id;
                            ["CustomerId"] = customer.id;
                            ["Tycoon"] = player_tycoon
                        }
                        task_completed:FireServer(data);
                    end
                end
            end
        end
    
        local cars = game_utility:get_group_type("Cars");
        if (#cars > 0) then
            for _, car in (cars) do
                local car_id = car.id;
                if (drive_thru:GetCarState(player_tycoon, car_id) == "Ordering") then
                    local data = {
                        ["Name"] = "TakeDriveThruOrder";
                        ["CarId"] = car_id;
                        ["Tycoon"] = player_tycoon
                    }
                    task_completed:FireServer(data);
                end
            end
        end
    end

    function utility_handler:grab_orders()
        local orders = temp:GetChildren();
        if (#orders == 0) then
            return;
        end
        for _, order in (orders) do
            local prompt = order:FindFirstChildWhichIsA("ProximityPrompt");
            if (not prompt) then
                continue;
            end
            fireproximityprompt(prompt);
        end
    end    

    function utility_handler:collect_dishes()
        local trashes = game_utility:get_table_item("Trash");
        if (#trashes == 0) then
            return;
        end
        for _, trash in (trashes) do
            local data = {
                ["Name"] = "CollectDishes";
                ["FurnitureModel"] = trash;
                ["Tycoon"] = player_tycoon
            }
            task_completed:FireServer(data);
        end
    end

    function utility_handler:collect_bills()
        local bills = game_utility:get_table_item("Bill");
        if (#bills > 0) then
            for _, bill in (bills) do
                local data = {
                    ["Name"] = "CollectBill";
                    ["FurnitureModel"] = bill;
                    ["Tycoon"] = player_tycoon
                }
                task_completed:FireServer(data);
            end
        end

        local cars = game_utility:get_group_type("Cars");
        if (#cars > 0) then
            for _, car in (cars) do
                local car_id = car.id;
                if (drive_thru:GetCarState(player_tycoon, car_id) == "Paying") then
                    local data = {
                        ["Name"] = "CollectDriveThruBill";
                        ["CarId"] = car_id;
                        ["Tycoon"] = player_tycoon
                    }
                    task_completed:FireServer(data);
                end
            end
        end
    end

    function utility_handler:attempt_cook()
        waypoints:DestroyAll();
        events.Cook.CookInputRequested:FireServer("CompleteTask", player_tycoon, "Oven", true);
    end

    function utility_handler:collect_drops()
        local active_drops = drop_folder:GetChildren();
        if (#active_drops == 0) then
            return;
        end
        for _, drop in (active_drops) do
            local touchinterest = drop:FindFirstChild("TouchInterest");
            if (not touchinterest) then
                continue;
            end
            firetouchinterest(local_player.Character.HumanoidRootPart, drop, 0);
            firetouchinterest(local_player.Character.HumanoidRootPart, drop, 1);
        end
    end

    function utility_handler:grab_food()
        local food_children = tycoon_food:GetChildren();
        if (food_children == 0) then
            return;
        end
        for _, food in (food_children) do
            grab_food.AttemptGrab(grab_food, player_tycoon, food);
        end
    end

    function utility_handler:calm_angry_customers()
        local groups = game_utility:get_group_type("Customers");
        if (#groups == 0) then
            return;
        end
        for _, group in (groups) do
            for _, customer in (group.customers) do
                if (customer.data.State == "CustomerAngry") then
                    get_rude_customer_dialog:InvokeServer(player_tycoon, group.id, customer.id);
                    get_rude_customer_dialog:InvokeServer(player_tycoon, group.id, customer.id, "We\226\128\153re sorry you\226\128\153ve had this experience today.");
                    dialog_events.DialogCompleted:FireServer();
                end
            end
        end
    end

    function utility_handler:give_food()
        local food_storage = grab_food.Storage
        if #food_storage == 0 then
            return
        end
        local groups = game_utility:get_group_type("Customers")
        if (#groups > 0) then
            for _, group in (groups) do
                for _, customer in (group.customers) do
                    if (customer.data.State == "WaitingForDish") then
                        local held_food = grab_food:IsHoldingFoodForNPC(customer.data.Order)
                        if (not held_food) then
                            continue
                        end
                        local data = {
                            ["Name"] = "Serve";
                            ["GroupId"] = group.id;
                            ["CustomerId"] = customer.id;
                            ["FoodModel"] = held_food.Model;
                            ["Tycoon"] = player_tycoon
                        };
                        task_completed:FireServer(data);
                    end
                end
            end
        end
        local cars = game_utility:get_group_type("Cars")
        if (#cars > 0) then
            for _, car in (cars) do
                local car_id = car.id;
                local car_orders = drive_thru:GetCarData(player_tycoon, car_id).Orders;
                if (not car_orders) then
                    continue;
                end
                local searched_food = nil;
                for _, order in car_orders do
                    local holding = grab_food:IsHoldingFoodForCar(order);
                    if (holding) then
                        searched_food = holding;
                        break;
                    end
                end
                if (not searched_food) then
                    continue;
                end
                local data = {
                    ["Name"] = "Serve";
                    ["CarId"] = car_id;
                    ["FoodModel"] = searched_food.Model;
                    ["Tycoon"] = player_tycoon;
                };
                task_completed:FireServer(data);
            end
        end
    end
end

table.insert(
    library.Connections,
    run_service.RenderStepped:Connect(function()
        local now = tick();

        if (library.flags.auto_harvest) and (now - delays.auto_harvest.last_ran > delays.auto_harvest.delay) then
            delays.auto_harvest.last_ran = now;
            utility_handler:harvest_crops();
        end

        if (library.flags.auto_crop) and (now - delays.auto_crop.last_ran > delays.auto_crop.delay) and (library.flags.selected_crop) and (#library.flags.selected_crop > 0) then
            delays.auto_crop.last_ran = now;
            utility_handler:crop_crops();
        end

        if (library.flags.auto_daily) and (now - delays.auto_daily.last_ran > delays.auto_daily.delay) then
            delays.auto_daily.last_ran = now;
            utility_handler:claim_daily();
        end

        if (library.flags.auto_tips) and (now - delays.auto_tips.last_ran > delays.auto_tips.delay) then
            delays.auto_tips.last_ran = now;
            utility_handler:collect_tip();
        end

        if (library.flags.auto_collect_dish) and (now - delays.auto_collect_dish.last_ran > delays.auto_collect_dish.delay) then
            delays.auto_collect_dish.last_ran = now;
            utility_handler:collect_dishes();
        end

        if (library.flags.auto_collect_bill) and (now - delays.auto_collect_bill.last_ran > delays.auto_collect_bill.delay) then
            delays.auto_collect_bill.last_ran = now;
            utility_handler:collect_bills();
        end

        if (library.flags.auto_group_order) and (now - delays.auto_group_order.last_ran > delays.auto_group_order.delay) then
            delays.auto_group_order.last_ran = now;
            utility_handler:take_group_orders();
        end

        if (library.flags.auto_grab_oder) and (now - delays.auto_grab_oder.last_ran > delays.auto_grab_oder.delay) then
            delays.auto_grab_oder.last_ran = now;
            utility_handler:grab_orders();
        end

        if (library.flags.auto_grab_food) and (now - delays.auto_grab_food.last_ran > delays.auto_grab_food.delay) then
            delays.auto_grab_food.last_ran = now;
            utility_handler:grab_food();
        end

        if (library.flags.auto_give_food) and (now - delays.auto_give_food.last_ran > delays.auto_give_food.delay) then
            delays.auto_give_food.last_ran = now;
            utility_handler:give_food();
        end

        if (library.flags.auto_cook) and (now - delays.auto_cook.last_ran > delays.auto_cook.delay) then
            delays.auto_cook.last_ran = now;
            utility_handler:attempt_cook();
        end

        if (library.flags.auto_seat) and (now - delays.auto_seat.last_ran > delays.auto_seat.delay) then
            delays.auto_seat.last_ran = now;
            utility_handler:seat_groups();
        end

        if (library.flags.auto_calm_angry_customer) and (now - delays.auto_calm_angry_customer.last_ran > delays.auto_calm_angry_customer.delay) then
            delays.auto_calm_angry_customer.last_ran = now;
            utility_handler:calm_angry_customers();
        end

        if (library.flags.auto_collect_drops) and (now - delays.auto_collect_drops.last_ran > delays.auto_collect_drops.delay) then
            delays.auto_collect_drops.last_ran = now;
            utility_handler:collect_drops();
        end
    end)
)

local tabs = {
    main = window:CreateTab("Main");
    settings = window:CreateTab("Settings")
}

local sections = {
    restaurant_section = tabs.main:CreateSection("Restaurant", "left");
    reward_section = tabs.main:CreateSection("Rewards", "right");
    farm_section = tabs.main:CreateSection("Farm", "right");
    gui_section = tabs.settings:CreateSection("Gui", "right")
}

sections.restaurant_section:CreateToggle("Auto Calm Angry Customers", false, function(value)
    library.flags.auto_calm_angry_customer = value;
end)

sections.restaurant_section:CreateToggle("Auto Collect Dishes", false, function(value)
    library.flags.auto_collect_dish = value;
end)

sections.restaurant_section:CreateToggle("Auto Collect Drops", false, function(value)
    library.flags.auto_collect_drops = value;
end)

sections.restaurant_section:CreateToggle("Auto Collect Bills", false, function(value)
    library.flags.auto_collect_bill = value;
end)

sections.restaurant_section:CreateToggle("Auto Take Orders", false, function(value)
    library.flags.auto_group_order = value;
end)

sections.restaurant_section:CreateToggle("Auto Grab Orders", false, function(value)
    library.flags.auto_grab_oder = value;
end)

sections.restaurant_section:CreateToggle("Auto Grab Food", false, function(value)
    library.flags.auto_grab_food = value;
end)

sections.restaurant_section:CreateToggle("Auto Give Food", false, function(value)
    library.flags.auto_give_food = value;
end)

sections.restaurant_section:CreateToggle("Auto Cook", false, function(value)
    library.flags.auto_cook = value;
end)

sections.restaurant_section:CreateToggle("Auto Seat", false, function(value)
    library.flags.auto_seat = value;
end)

sections.farm_section:CreateDropdown("Select Crops To Place:", crop_names, function(value)
    library.flags.selected_crop = value;
end, {}, true);

sections.farm_section:CreateToggle("Auto Place Crops", false, function(value)
    library.flags.auto_crop = value;
end)

sections.farm_section:CreateToggle("Auto Harvest", false, function(value)
    library.flags.auto_harvest = value;
end)

sections.farm_section:CreateDivider();

sections.farm_section:CreateButton("Destory All Crops", function()
    local deleted_amount, time_took = 0, tick();
    for tile in (farming_module.TrackedTiles) do
        local state = farming_module:GetState(tile);
        if (state == "Completed") or (state == "Growing") then
            farming_events.CropRemoved:FireServer(tile.Name);
            deleted_amount = deleted_amount + 1;
        end
    end
    window:Notify("", "Deleted "..deleted_amount.." crops in "..string.format("%.2f", tick() - time_took).." seconds", 5);
end)

sections.reward_section:CreateToggle("Auto Claim Daily", false, function(value)
    library.flags.auto_daily = value;
end)

sections.reward_section:CreateToggle("Auto Claim Tips", false, function(value)
    library.flags.auto_tips = value;
end)

sections.gui_section:CreateButton("Unload UI", function()
	library:Destroy();
end)

sections.gui_section:CreateToggle("Enable Particles", false, function(value)
	window:CreateParticles(value);
end)

local config_manager = loadstring(game:HttpGet("https://raw.githubusercontent.com/nfpw/XXSCRIPT/refs/heads/main/Library/ConfigManager.lua"))();
config_manager:SetLibrary(library);
config_manager:SetWindow(window);
config_manager:SetFolder("");
config_manager:BuildConfigSection(tabs.settings);
config_manager:LoadAutoloadConfig();
window:Notify("", "Loaded script in "..string.format("%.2f", tick() - start_tick).." seconds", 5);
