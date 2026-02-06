local replicated_storage = game:GetService("ReplicatedStorage");
local user_input_service = game:GetService("UserInputService");
local run_service = game:GetService("RunService");
local workspace = game:GetService("Workspace");
local players = game:GetService("Players");

local local_player = players.LocalPlayer;
local camera = workspace.CurrentCamera;

local my_camera = require(game:GetService("ReplicatedStorage").Modules.MyCameraModule);
local bullet_constructor = require(replicated_storage.Modules.BulletConstructor);

local map = workspace:WaitForChild("Map");
if (map) then
    map.Parent = workspace.Bulletholes;
end

local silent_fov, current_target = 500, nil;

local silent_aim_fov_outline = Drawing.new("Circle");
local silent_aim_fov = Drawing.new("Circle");
local snapline_outline = Drawing.new("Line");
local snapline = Drawing.new("Line");

do
    silent_aim_fov_outline.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
    silent_aim_fov_outline.Color = Color3.new(0, 0, 0)
    silent_aim_fov_outline.Visible = true;
    silent_aim_fov_outline.Thickness = 3;
    silent_aim_fov_outline.Radius = silent_fov;
end

do
    silent_aim_fov.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
    silent_aim_fov.Color = Color3.new(1, 1, 1)
    silent_aim_fov.Visible = true;
    silent_aim_fov.Thickness = 1;
    silent_aim_fov.Radius = silent_fov;
end

do
    snapline_outline.Color = Color3.new(0, 0, 0);
    snapline_outline.Thickness = 3;
end

do
    snapline.Color = Color3.new(1, 1, 1);
    snapline.Thickness = 1;
end

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    silent_aim_fov_outline.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
    silent_aim_fov.Position = silent_aim_fov_outline.Position;
end)

local function closest(radius: number)
    local closest_head, max_distance = nil, radius;

    local mouse = user_input_service:GetMouseLocation();

    for _, player in (players:GetChildren()) do
        if (player == local_player) then
            continue;
        end
        local character = player.Character;
        if (not character) then
            continue;
        end
        local humanoid = character:FindFirstChildWhichIsA("Humanoid");
        local head = character:FindFirstChild("Head");
        if (not head) or (not humanoid) or (humanoid.Health <= 0) then
            continue;
        end
        local screen_position, visible = camera:WorldToViewportPoint(head.Position);
        if (not visible) then
            continue;
        end
        local distance = (Vector2.new(screen_position.X, screen_position.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude;
        if (distance < max_distance) then
            max_distance = distance;
            closest_head = head;
        end
    end

    return closest_head;
end

run_service.RenderStepped:Connect(function()
    current_target = closest(silent_fov);
    if (current_target) then
        local screen_position = camera:WorldToViewportPoint(current_target.Position);
        snapline_outline.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
        snapline_outline.To = Vector2.new(screen_position.X, screen_position.Y);
        snapline.From = snapline_outline.From;
        snapline.To = snapline_outline.To;
        snapline_outline.Visible = true;
        snapline.Visible = true;
    else
        snapline_outline.Visible = false;
        snapline.Visible = false;
    end
end)

local old; old = hookfunction(bullet_constructor.new, function(self)
    if (current_target) and (self.Player == local_player) then
        self.Direction = (current_target.Position - self.OriginCFrame.Position).Unit;
        self.ProjectileSpeed = 9e9;
    end
    return old(self);
end)

hookfunction(my_camera.Recoil, function()
    return;
end)
