if not game:IsLoaded() then
    game.Loaded:Wait()
end

local env = type(getgenv) == "function" and getgenv() or _G
local clonerefFn = type(cloneref) == "function" and cloneref or function(value)
    return value
end

local function GetService(name)
    return clonerefFn(game:GetService(name))
end

local CoreGui = GetService("CoreGui")
local TweenService = GetService("TweenService")
local HttpService = GetService("HttpService")
local Players = GetService("Players")
local UserInputService = GetService("UserInputService")
local Lighting = GetService("Lighting")
local Workspace = GetService("Workspace")
local RbxAnalyticsService = GetService("RbxAnalyticsService")
local LocalPlayer = Players.LocalPlayer

local Colors = {
    MainBG = Color3.fromRGB(24, 16, 25),
    SecondaryBG = Color3.fromRGB(34, 22, 36),
    TertiaryBG = Color3.fromRGB(45, 29, 47),
    ElevatedBG = Color3.fromRGB(56, 35, 58),
    Accent = Color3.fromRGB(244, 114, 182),
    AccentGlow = Color3.fromRGB(255, 155, 207),
    AccentSoft = Color3.fromRGB(105, 48, 79),
    TextPrimary = Color3.fromRGB(255, 247, 252),
    TextSecondary = Color3.fromRGB(222, 190, 209),
    TextMuted = Color3.fromRGB(164, 130, 151),
    Stroke = Color3.fromRGB(82, 53, 74),
    StrokeBright = Color3.fromRGB(124, 75, 105),
    Success = Color3.fromRGB(92, 224, 172),
    Warn = Color3.fromRGB(255, 190, 111),
    Error = Color3.fromRGB(255, 96, 137)
}

local Config = {
    HeaderTitle = "VYX",
    Subtitle = "ScriptHub Authentication",
    LinkvertiseLink = "https://ads.luarmor.net/get_key?for=VYXLinkvertise-YysLqXvzHcdm",
    ShrtflyLink = "https://ads.luarmor.net/get_key?for=VYXShrtFly-soPiLyyqONUM",
    DiscordLink = "https://discord.gg/dgN5u5da6q",
    FileName = "VYXKey_Save.txt",
    AssetFolder = "VYXAssets",
    DiscordInvite = "dgN5u5da6q"
}

local gameIdToURL = {
    ["6409513651"] = "28569f801443762c458f0c690c398dcb",
}

local FallbackIcons = {
    vyx = "rbxassetid://0",
    key = "rbxassetid://96510194465420",
    ["book-lock"] = "rbxassetid://114355063515473",
    ["gamepad-2"] = "rbxassetid://101192191207677",
    ["loader-2"] = "rbxassetid://116535712789945",
    check = "rbxassetid://76078495178149",
    ["wifi-off"] = "rbxassetid://140438367956051",
    ["alert-circle"] = "rbxassetid://140438367956051",
    x = "rbxassetid://6022668916",
    ["book-key"] = "rbxassetid://10871266112",
    ["external-link"] = "rbxassetid://10709790644",
    shield = "rbxassetid://89965059528921",
    user = "rbxassetid://77400125196692",
    copy = "rbxassetid://125851897718493",
    clock = "rbxassetid://87505349362628"
}

local AssetsToLoad = {
    {Name = "vyx", Type = "discord"},
    {Name = "key", Type = "icon"},
    {Name = "book-lock", Type = "icon"},
    {Name = "gamepad-2", Type = "icon"},
    {Name = "loader-2", Type = "icon"},
    {Name = "check", Type = "icon"},
    {Name = "wifi-off", Type = "icon"},
    {Name = "alert-circle", Type = "icon"},
    {Name = "x", Type = "icon"},
    {Name = "book-key", Type = "icon"},
    {Name = "external-link", Type = "icon"},
    {Name = "shield", Type = "icon"},
    {Name = "user", Type = "icon"},
    {Name = "copy", Type = "icon"},
    {Name = "clock", Type = "icon"}
}

local function New(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            object[property] = value
        end
    end
    if properties and properties.Parent then
        object.Parent = properties.Parent
    end
    return object
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
        Parent = parent
    })
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Colors.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
end

local function PlayTween(object, duration, properties, style, direction)
    if not object or not object.Parent then
        return nil
    end
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.25,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

local function SafeJSONDecode(value)
    local success, result = pcall(function()
        return HttpService:JSONDecode(value)
    end)
    if success then
        return result
    end
    return nil
end

local function HasFileSystem()
    return type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
        and type(makefolder) == "function"
        and type(isfolder) == "function"
end

local FileSystemAvailable = HasFileSystem()
local CustomAssetAvailable = type(getcustomasset) == "function"

local function EnsureAssetFolder()
    if not FileSystemAvailable then
        return
    end
    pcall(function()
        if not isfolder(Config.AssetFolder) then
            makefolder(Config.AssetFolder)
        end
    end)
end

local function GetAssetPath(name, assetType)
    local extension = assetType == "discord" and ".jpg" or ".png"
    return Config.AssetFolder .. "/" .. name .. extension
end

local function DownloadAsset(asset)
    if not FileSystemAvailable then
        return
    end
    local path = GetAssetPath(asset.Name, asset.Type)
    local exists = false
    pcall(function()
        exists = isfile(path)
    end)
    if exists then
        return
    end
    local url = nil
    if asset.Type == "icon" then
        url = "https://raw.githubusercontent.com/latte-soft/lucide-roblox/master/icons/compiled/256px/" .. asset.Name .. ".png"
    else
        local inviteSuccess, inviteResponse = pcall(function()
            return game:HttpGet("https://discord.com/api/v10/invites/" .. Config.DiscordInvite .. "?with_counts=false&with_expiration=false")
        end)
        if inviteSuccess and type(inviteResponse) == "string" then
            local decoded = SafeJSONDecode(inviteResponse)
            if decoded and decoded.guild and decoded.guild.id and decoded.guild.icon then
                url = "https://cdn.discordapp.com/icons/" .. decoded.guild.id .. "/" .. decoded.guild.icon .. ".png?size=256"
            end
        end
    end
    if not url then
        return
    end
    local downloadSuccess, data = pcall(function()
        return game:HttpGet(url)
    end)
    if downloadSuccess and type(data) == "string" and #data > 100 then
        pcall(function()
            writefile(path, data)
        end)
    end
end

EnsureAssetFolder()
local pendingAssets = 0
for _, asset in ipairs(AssetsToLoad) do
    pendingAssets = pendingAssets + 1
    task.spawn(function()
        DownloadAsset(asset)
        pendingAssets = pendingAssets - 1
    end)
end
local assetDeadline = os.clock() + 4
while pendingAssets > 0 and os.clock() < assetDeadline do
    task.wait()
end

local function GetAsset(name)
    local assetType = name == "vyx" and "discord" or "icon"
    if FileSystemAvailable and CustomAssetAvailable then
        local path = GetAssetPath(name, assetType)
        local exists = false
        pcall(function()
            exists = isfile(path)
        end)
        if exists then
            local success, result = pcall(function()
                return getcustomasset(path)
            end)
            if success and result then
                return result
            end
        end
    end
    return FallbackIcons[name] or "rbxassetid://0"
end

local function SafeClipboard(value)
    if type(setclipboard) ~= "function" then
        return false
    end
    return pcall(function()
        setclipboard(value)
    end)
end

local function SaveKey(value)
    if not FileSystemAvailable then
        return false
    end
    return pcall(function()
        writefile(Config.FileName, value)
    end)
end

local function LoadSavedKey()
    if not FileSystemAvailable then
        return nil
    end
    local success, result = pcall(function()
        if not isfile(Config.FileName) then
            return nil
        end
        return readfile(Config.FileName)
    end)
    if success and type(result) == "string" and result ~= "" then
        return result
    end
    return nil
end

local function ClearSavedKey()
    if not FileSystemAvailable or type(delfile) ~= "function" then
        return
    end
    pcall(function()
        if isfile(Config.FileName) then
            delfile(Config.FileName)
        end
    end)
end

local function GetExecutor()
    if type(identifyexecutor) == "function" then
        local success, name = pcall(identifyexecutor)
        if success and name then
            return tostring(name)
        end
    end
    return "Unknown"
end

local function GetDevice()
    local touch = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local gamepad = UserInputService.GamepadEnabled
    if gamepad and not keyboard and not touch then
        return "Console"
    end
    if touch and not keyboard then
        return "Mobile"
    end
    if touch and keyboard then
        return "PC & Touch"
    end
    if keyboard then
        return "PC"
    end
    return "Unknown"
end

local function GetHWID()
    if type(gethwid) == "function" then
        local success, value = pcall(gethwid)
        if success and value and tostring(value) ~= "" then
            return tostring(value)
        end
    end
    local success, value = pcall(function()
        return RbxAnalyticsService:GetClientId()
    end)
    if success and value then
        return tostring(value)
    end
    return "Unavailable"
end

local function FormatDuration(seconds)
    if type(seconds) ~= "number" or seconds <= 0 then
        return "Lifetime"
    end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then
        return tostring(days) .. "d " .. tostring(hours) .. "h"
    end
    if hours > 0 then
        return tostring(hours) .. "h " .. tostring(minutes) .. "m"
    end
    return tostring(math.max(minutes, 1)) .. "m"
end

local function FormatExpiry(timestamp)
    if type(timestamp) ~= "number" or timestamp <= 0 then
        return "Lifetime"
    end
    local success, value = pcall(function()
        return os.date("%b %d, %Y %I:%M %p", timestamp)
    end)
    if success then
        return value
    end
    return "Unknown"
end

local function SanitizeKey(rawValue)
    if type(rawValue) ~= "string" then
        return ""
    end
    local quoted = rawValue:match("script_key%s*=%s*[%\"']([^%\"']+)[%\"']")
    local value = quoted or rawValue
    value = value:gsub("[%c%s]", "")
    value = value:gsub("[;]+$", "")
    return value
end

pcall(function()
    if env.VYXKey_System then
        env.VYXKey_System:Destroy()
    end
end)

pcall(function()
    local oldBlur = Lighting:FindFirstChild("VYXBlur")
    if oldBlur then
        oldBlur:Destroy()
    end
end)

local ScreenGui = New("ScreenGui", {
    Name = "VYXKeySystem",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

env.VYXKey_System = ScreenGui

local guiParent = nil
if type(gethui) == "function" then
    pcall(function()
        guiParent = gethui()
    end)
end
if not guiParent then
    guiParent = CoreGui
end
local parented = pcall(function()
    ScreenGui.Parent = guiParent
end)
if not parented then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local VYXBlur = New("BlurEffect", {
    Name = "VYXBlur",
    Size = 0,
    Parent = Lighting
})
PlayTween(VYXBlur, 0.5, {Size = 12}, Enum.EasingStyle.Quint)

local connections = {}
local function Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local closing = false
local isAuthenticating = false
local isUserPanelOpen = false
local buttonLocks = {}
local spinTween = nil

local function UseCooldown(name, duration)
    if buttonLocks[name] then
        return false
    end
    buttonLocks[name] = true
    task.delay(duration or 0.65, function()
        buttonLocks[name] = nil
    end)
    return true
end

local NotificationContainer = New("Frame", {
    Size = UDim2.new(0, 310, 1, -30),
    Position = UDim2.new(1, -20, 1, -20),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 100,
    Parent = ScreenGui
})

local ActiveNotifications = {}

local function RestackNotifications()
    local accumulated = 0
    for _, notification in ipairs(ActiveNotifications) do
        if notification.Frame and notification.Frame.Parent then
            PlayTween(
                notification.Frame,
                0.35,
                {Position = UDim2.new(0, 0, 1, -accumulated)},
                Enum.EasingStyle.Quint
            )
            accumulated = accumulated + notification.Height + 10
        end
    end
end

local function Notify(title, message, notificationType, duration)
    if closing then
        return
    end
    duration = duration or 3.5
    local accent = Colors.Success
    local iconName = "check"
    if notificationType == "Warn" then
        accent = Colors.Warn
        iconName = "alert-circle"
    elseif notificationType == "Error" then
        accent = Colors.Error
        iconName = "x"
    elseif notificationType == "Info" then
        accent = Colors.Accent
        iconName = "shield"
    end

    local toast = New("Frame", {
        Size = UDim2.new(1, 0, 0, 66),
        Position = UDim2.new(1, 340, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Colors.SecondaryBG,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = NotificationContainer
    })
    Corner(toast, 9)
    Stroke(toast, Colors.StrokeBright, 1, 0.2)

    local leftBar = New("Frame", {
        Size = UDim2.new(0, 4, 1, -16),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = toast
    })
    Corner(leftBar, 4)

    New("ImageLabel", {
        Size = UDim2.new(0, 19, 0, 19),
        Position = UDim2.new(0, 21, 0, 15),
        BackgroundTransparency = 1,
        Image = GetAsset(iconName),
        ImageColor3 = accent,
        ZIndex = 102,
        Parent = toast
    })

    New("TextLabel", {
        Size = UDim2.new(1, -58, 0, 18),
        Position = UDim2.new(0, 49, 0, 10),
        BackgroundTransparency = 1,
        Text = tostring(title),
        TextColor3 = Colors.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = toast
    })

    New("TextLabel", {
        Size = UDim2.new(1, -58, 0, 28),
        Position = UDim2.new(0, 49, 0, 29),
        BackgroundTransparency = 1,
        Text = tostring(message),
        TextColor3 = Colors.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 102,
        Parent = toast
    })

    local progress = New("Frame", {
        Size = UDim2.new(1, -18, 0, 2),
        Position = UDim2.new(0, 9, 1, -5),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex = 102,
        Parent = toast
    })
    Corner(progress, 2)

    local data = {
        Frame = toast,
        Height = 66,
        Closed = false
    }
    table.insert(ActiveNotifications, 1, data)

    while #ActiveNotifications > 4 do
        local oldest = table.remove(ActiveNotifications, #ActiveNotifications)
        if oldest and oldest.Frame then
            oldest.Closed = true
            PlayTween(oldest.Frame, 0.25, {Position = UDim2.new(1, 340, 1, oldest.Frame.Position.Y.Offset)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.delay(0.26, function()
                if oldest.Frame then
                    oldest.Frame:Destroy()
                end
            end)
        end
    end

    RestackNotifications()
    PlayTween(toast, 0.45, {Position = UDim2.new(0, 0, 1, toast.Position.Y.Offset)}, Enum.EasingStyle.Back)
    PlayTween(progress, duration, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)

    local function dismiss()
        if data.Closed then
            return
        end
        data.Closed = true
        for index, notification in ipairs(ActiveNotifications) do
            if notification == data then
                table.remove(ActiveNotifications, index)
                break
            end
        end
        PlayTween(toast, 0.3, {Position = UDim2.new(1, 340, 1, toast.Position.Y.Offset)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.31, function()
            if toast and toast.Parent then
                toast:Destroy()
            end
        end)
        RestackNotifications()
    end

    local dismissButton = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 103,
        Parent = toast
    })
    Connect(dismissButton.MouseButton1Click, dismiss)
    task.delay(duration, dismiss)
end

local RootContainer = New("Frame", {
    Size = UDim2.new(0, 360, 0, 380),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Visible = false,
    Parent = ScreenGui
})

local InterfaceScale = New("UIScale", {
    Scale = 0.84,
    Parent = RootContainer
})

local MainCard = New("Frame", {
    Size = UDim2.new(0, 360, 0, 380),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Colors.MainBG,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = RootContainer
})
Corner(MainCard, 12)
local CardStroke = Stroke(MainCard, Colors.StrokeBright, 1, 0.1)

local TopBar = New("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = Colors.Accent,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 5,
    Parent = MainCard
})
local TopGradient = New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Accent),
        ColorSequenceKeypoint.new(0.5, Colors.AccentGlow),
        ColorSequenceKeypoint.new(1, Colors.Accent)
    }),
    Offset = Vector2.new(-1, 0),
    Parent = TopBar
})

task.spawn(function()
    while ScreenGui.Parent and not closing do
        TopGradient.Offset = Vector2.new(-1, 0)
        local tween = PlayTween(TopGradient, 2.4, {Offset = Vector2.new(1, 0)}, Enum.EasingStyle.Linear)
        if tween then
            tween.Completed:Wait()
        else
            break
        end
    end
end)

local UserPanel = New("Frame", {
    Size = UDim2.new(0, 0, 0, 380),
    Position = UDim2.new(0, 370, 0, 0),
    BackgroundColor3 = Colors.MainBG,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 20,
    Parent = RootContainer
})
Corner(UserPanel, 12)
local UserPanelStroke = Stroke(UserPanel, Colors.StrokeBright, 1, 1)

local PanelContent = New("Frame", {
    Size = UDim2.new(0, 200, 1, 0),
    BackgroundTransparency = 1,
    ZIndex = 21,
    Parent = UserPanel
})

local PanelTitle = New("TextLabel", {
    Size = UDim2.new(1, -50, 0, 24),
    Position = UDim2.new(0, 16, 0, 14),
    BackgroundTransparency = 1,
    Text = "User information",
    TextColor3 = Colors.TextPrimary,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 22,
    Parent = PanelContent
})

local PanelClose = New("TextButton", {
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -14, 0, 12),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundColor3 = Colors.SecondaryBG,
    Text = "×",
    TextColor3 = Colors.TextSecondary,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    AutoButtonColor = false,
    ZIndex = 22,
    Parent = PanelContent
})
Corner(PanelClose, 6)
Stroke(PanelClose, Colors.Stroke, 1, 0)

local Avatar = New("ImageLabel", {
    Size = UDim2.new(0, 58, 0, 58),
    Position = UDim2.new(0.5, 0, 0, 54),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = Colors.TertiaryBG,
    BorderSizePixel = 0,
    Image = "",
    ZIndex = 22,
    Parent = PanelContent
})
Corner(Avatar, 9)
Stroke(Avatar, Colors.Accent, 2, 0.1)

task.spawn(function()
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if success and Avatar.Parent then
        Avatar.Image = image
    end
end)

New("TextLabel", {
    Size = UDim2.new(1, -24, 0, 22),
    Position = UDim2.new(0, 12, 0, 119),
    BackgroundTransparency = 1,
    Text = LocalPlayer.DisplayName,
    TextColor3 = Colors.TextPrimary,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 22,
    Parent = PanelContent
})

local function CreateInfoRow(labelText, valueText, y)
    New("TextLabel", {
        Size = UDim2.new(1, -28, 0, 14),
        Position = UDim2.new(0, 14, 0, y),
        BackgroundTransparency = 1,
        Text = labelText,
        TextColor3 = Colors.TextMuted,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 22,
        Parent = PanelContent
    })
    return New("TextLabel", {
        Size = UDim2.new(1, -28, 0, 18),
        Position = UDim2.new(0, 14, 0, y + 14),
        BackgroundTransparency = 1,
        Text = valueText,
        TextColor3 = Colors.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 22,
        Parent = PanelContent
    })
end

New("Frame", {
    Size = UDim2.new(1, -28, 0, 1),
    Position = UDim2.new(0, 14, 0, 151),
    BackgroundColor3 = Colors.Stroke,
    BorderSizePixel = 0,
    ZIndex = 22,
    Parent = PanelContent
})

CreateInfoRow("EXECUTOR", GetExecutor(), 164)
CreateInfoRow("DEVICE", GetDevice(), 205)
local FullHWID = GetHWID()
local HwidValue = CreateInfoRow("HWID", string.rep("•", 18), 246)
HwidValue.Size = UDim2.new(1, -52, 0, 18)

local CopyHWIDButton = New("ImageButton", {
    Size = UDim2.new(0, 19, 0, 19),
    Position = UDim2.new(1, -15, 0, 260),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Image = GetAsset("copy"),
    ImageColor3 = Colors.TextSecondary,
    AutoButtonColor = false,
    ZIndex = 23,
    Parent = PanelContent
})

New("Frame", {
    Size = UDim2.new(1, -28, 0, 1),
    Position = UDim2.new(0, 14, 0, 292),
    BackgroundColor3 = Colors.Stroke,
    BorderSizePixel = 0,
    ZIndex = 22,
    Parent = PanelContent
})

local ClockIcon = New("ImageLabel", {
    Size = UDim2.new(0, 17, 0, 17),
    Position = UDim2.new(0.5, -57, 0, 311),
    BackgroundTransparency = 1,
    Image = GetAsset("clock"),
    ImageColor3 = Colors.Accent,
    ZIndex = 22,
    Parent = PanelContent
})

local ClockTime = New("TextLabel", {
    Size = UDim2.new(0, 100, 0, 19),
    Position = UDim2.new(0.5, -34, 0, 309),
    BackgroundTransparency = 1,
    Text = "00:00:00 AM",
    TextColor3 = Colors.TextPrimary,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 22,
    Parent = PanelContent
})

local ClockDate = New("TextLabel", {
    Size = UDim2.new(1, -28, 0, 16),
    Position = UDim2.new(0, 14, 0, 335),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Colors.TextSecondary,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    ZIndex = 22,
    Parent = PanelContent
})

local clockRunning = true
task.spawn(function()
    while clockRunning and ScreenGui.Parent do
        local data = os.date("*t")
        local hour = data.hour % 12
        if hour == 0 then
            hour = 12
        end
        local period = data.hour >= 12 and "PM" or "AM"
        ClockTime.Text = string.format("%d:%02d:%02d %s", hour, data.min, data.sec, period)
        ClockDate.Text = os.date("%b %d, %Y")
        task.wait(1)
    end
end)

local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundTransparency = 1,
    Active = true,
    Parent = MainCard
})

local ServerIcon = New("ImageLabel", {
    Size = UDim2.new(0, 42, 0, 42),
    Position = UDim2.new(0, 20, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Colors.SecondaryBG,
    BorderSizePixel = 0,
    Image = GetAsset("vyx"),
    Parent = Header
})
Corner(ServerIcon, 10)
Stroke(ServerIcon, Colors.AccentSoft, 1, 0.25)

local LogoScale = New("UIScale", {
    Scale = 1,
    Parent = ServerIcon
})

task.spawn(function()
    while ScreenGui.Parent and not closing do
        PlayTween(LogoScale, 1.4, {Scale = 1.05}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.4)
        PlayTween(LogoScale, 1.4, {Scale = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.4)
    end
end)

New("TextLabel", {
    Size = UDim2.new(0, 200, 0, 22),
    Position = UDim2.new(0, 75, 0, 23),
    BackgroundTransparency = 1,
    Text = Config.HeaderTitle,
    TextColor3 = Colors.TextPrimary,
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

New("TextLabel", {
    Size = UDim2.new(0, 220, 0, 17),
    Position = UDim2.new(0, 75, 0, 45),
    BackgroundTransparency = 1,
    Text = Config.Subtitle,
    TextColor3 = Colors.TextSecondary,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

local CloseButton = New("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -20, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = Colors.SecondaryBG,
    Text = "",
    AutoButtonColor = false,
    Parent = Header
})
Corner(CloseButton, 7)
local CloseStroke = Stroke(CloseButton, Colors.Stroke, 1, 0)
local CloseIcon = New("ImageLabel", {
    Size = UDim2.new(0, 14, 0, 14),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Image = GetAsset("x"),
    ImageColor3 = Colors.TextSecondary,
    Parent = CloseButton
})

local BodyFrame = New("Frame", {
    Size = UDim2.new(1, -40, 1, -80),
    Position = UDim2.new(0, 20, 0, 80),
    BackgroundTransparency = 1,
    Parent = MainCard
})

local StatusFrame = New("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Colors.SecondaryBG,
    BorderSizePixel = 0,
    Parent = BodyFrame
})
Corner(StatusFrame, 8)
local StatusStroke = Stroke(StatusFrame, Colors.Stroke, 1, 0)
local StatusIcon = New("ImageLabel", {
    Size = UDim2.new(0, 17, 0, 17),
    Position = UDim2.new(0, 12, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Image = GetAsset("shield"),
    ImageColor3 = Colors.Warn,
    Parent = StatusFrame
})
local StatusText = New("TextLabel", {
    Size = UDim2.new(1, -44, 1, 0),
    Position = UDim2.new(0, 37, 0, 0),
    BackgroundTransparency = 1,
    Text = "Ready for authorization...",
    TextColor3 = Colors.TextSecondary,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = StatusFrame
})

New("TextLabel", {
    Size = UDim2.new(1, 0, 0, 19),
    Position = UDim2.new(0, 2, 0, 52),
    BackgroundTransparency = 1,
    Text = "LICENSE KEY",
    TextColor3 = Colors.TextSecondary,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = BodyFrame
})

local InputFrame = New("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    Position = UDim2.new(0, 0, 0, 72),
    BackgroundColor3 = Colors.TertiaryBG,
    BorderSizePixel = 0,
    Parent = BodyFrame
})
Corner(InputFrame, 8)
local InputStroke = Stroke(InputFrame, Colors.Stroke, 1, 0)
local KeyIcon = New("ImageLabel", {
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(0, 12, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundTransparency = 1,
    Image = GetAsset("key"),
    ImageColor3 = Colors.TextSecondary,
    Parent = InputFrame
})
local KeyInput = New("TextBox", {
    Size = UDim2.new(1, -49, 1, 0),
    Position = UDim2.new(0, 40, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Paste your 32-character key...",
    PlaceholderColor3 = Colors.TextMuted,
    TextColor3 = Colors.TextPrimary,
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Parent = InputFrame
})

local function CreateMainButton(y, text, iconName, primary, xScale, xOffset, widthScale, widthOffset)
    local button = New("TextButton", {
        Size = UDim2.new(widthScale or 1, widthOffset or 0, 0, 42),
        Position = UDim2.new(xScale or 0, xOffset or 0, 0, y),
        BackgroundColor3 = primary and Colors.Accent or Colors.SecondaryBG,
        Text = "",
        AutoButtonColor = false,
        Parent = BodyFrame
    })
    Corner(button, 8)
    local buttonStroke = Stroke(button, primary and Colors.Accent or Colors.Stroke, 1, primary and 0.2 or 0)
    local scale = New("UIScale", {
        Scale = 1,
        Parent = button
    })
    local content = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = button
    })
    local layout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        Parent = content
    })
    local icon = New("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = 1,
        Image = GetAsset(iconName),
        ImageColor3 = Colors.TextPrimary,
        LayoutOrder = 1,
        Parent = content
    })
    local label = New("TextLabel", {
        Size = UDim2.new(0, 0, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        LayoutOrder = 2,
        Parent = content
    })

    Connect(button.MouseEnter, function()
        PlayTween(button, 0.18, {BackgroundColor3 = primary and Colors.AccentGlow or Colors.ElevatedBG})
        PlayTween(buttonStroke, 0.18, {Color = primary and Colors.AccentGlow or Colors.StrokeBright})
        PlayTween(scale, 0.18, {Scale = 1.015})
    end)
    Connect(button.MouseLeave, function()
        PlayTween(button, 0.18, {BackgroundColor3 = primary and Colors.Accent or Colors.SecondaryBG})
        PlayTween(buttonStroke, 0.18, {Color = primary and Colors.Accent or Colors.Stroke})
        PlayTween(scale, 0.18, {Scale = 1})
    end)
    Connect(button.MouseButton1Down, function()
        PlayTween(scale, 0.08, {Scale = 0.97}, Enum.EasingStyle.Quad)
    end)
    Connect(button.MouseButton1Up, function()
        PlayTween(scale, 0.15, {Scale = 1.015}, Enum.EasingStyle.Back)
    end)

    return button, label, icon, buttonStroke, scale
end

local LinkvertiseButton, LinkvertiseText = CreateMainButton(132, "Linkvertise", "external-link", false, 0, 0, 0.5, -5)
local ShrtflyButton, ShrtflyText = CreateMainButton(132, "Shrtfly", "external-link", false, 0.5, 5, 0.5, -5)
local RedeemButton, RedeemText = CreateMainButton(182, "Verify Key", "book-key", true)

New("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -46),
    BackgroundColor3 = Colors.Stroke,
    BorderSizePixel = 0,
    Parent = BodyFrame
})

local LinksContainer = New("Frame", {
    Size = UDim2.new(1, 0, 0, 31),
    Position = UDim2.new(0, 0, 1, -36),
    BackgroundTransparency = 1,
    Parent = BodyFrame
})
New("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 7),
    Parent = LinksContainer
})

local function CreateLinkButton(text, iconName)
    local button = New("TextButton", {
        Size = UDim2.new(0, 70, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = LinksContainer
    })
    local scale = New("UIScale", {
        Scale = 1,
        Parent = button
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        Parent = button
    })
    local icon = New("ImageLabel", {
        Size = UDim2.new(0, 13, 0, 13),
        BackgroundTransparency = 1,
        Image = GetAsset(iconName),
        ImageColor3 = Colors.TextSecondary,
        Parent = button
    })
    local label = New("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Colors.TextSecondary,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        Parent = button
    })
    Connect(button.MouseEnter, function()
        PlayTween(icon, 0.16, {ImageColor3 = Colors.TextPrimary})
        PlayTween(label, 0.16, {TextColor3 = Colors.TextPrimary})
        PlayTween(scale, 0.16, {Scale = 1.04})
    end)
    Connect(button.MouseLeave, function()
        PlayTween(icon, 0.16, {ImageColor3 = Colors.TextSecondary})
        PlayTween(label, 0.16, {TextColor3 = Colors.TextSecondary})
        PlayTween(scale, 0.16, {Scale = 1})
    end)
    Connect(button.MouseButton1Down, function()
        PlayTween(scale, 0.08, {Scale = 0.94}, Enum.EasingStyle.Quad)
    end)
    Connect(button.MouseButton1Up, function()
        PlayTween(scale, 0.14, {Scale = 1.04}, Enum.EasingStyle.Back)
    end)
    return button
end

local ResetHWIDButton = CreateLinkButton("Reset HWID", "book-lock")
local DiscordButton = CreateLinkButton("Discord", "gamepad-2")
local UserInfoButton = CreateLinkButton("User Info", "user")

local SuccessFrame = New("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Colors.MainBG,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 50,
    Parent = MainCard
})
Corner(SuccessFrame, 12)

local SuccessTopBar = New("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = Colors.Success,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = SuccessFrame
})

local SuccessGlow = New("Frame", {
    Size = UDim2.new(0, 62, 0, 62),
    Position = UDim2.new(0.5, 0, 0, 30),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundColor3 = Colors.Success,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = SuccessFrame
})
Corner(SuccessGlow, 31)

local SuccessIcon = New("ImageLabel", {
    Size = UDim2.new(0, 34, 0, 34),
    Position = UDim2.new(0.5, 0, 0, 44),
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
    Image = GetAsset("check"),
    ImageColor3 = Colors.Success,
    ImageTransparency = 1,
    ZIndex = 52,
    Parent = SuccessFrame
})

local SuccessTitle = New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 24),
    Position = UDim2.new(0, 15, 0, 91),
    BackgroundTransparency = 1,
    Text = "Key information",
    TextColor3 = Colors.TextPrimary,
    TextTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    ZIndex = 52,
    Parent = SuccessFrame
})

local SuccessSubtitle = New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 18),
    Position = UDim2.new(0, 15, 0, 116),
    BackgroundTransparency = 1,
    Text = "Your VYX license was verified.",
    TextColor3 = Colors.TextSecondary,
    TextTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    ZIndex = 52,
    Parent = SuccessFrame
})

local SuccessCard = New("Frame", {
    Size = UDim2.new(1, -34, 0, 142),
    Position = UDim2.new(0, 17, 0, 148),
    BackgroundColor3 = Colors.SecondaryBG,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 51,
    Parent = SuccessFrame
})
Corner(SuccessCard, 9)
local SuccessCardScale = New("UIScale", {
    Scale = 1,
    Parent = SuccessCard
})
local SuccessStroke = Stroke(SuccessCard, Colors.Success, 1, 1)

local SuccessLabels = {}
local SuccessSeparators = {}

local function CreateSuccessRow(name, y, addSeparator)
    local label = New("TextLabel", {
        Size = UDim2.new(0, 92, 0, 24),
        Position = UDim2.new(0, 13, 0, y),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Colors.TextSecondary,
        TextTransparency = 1,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 53,
        Parent = SuccessCard
    })
    local value = New("TextLabel", {
        Size = UDim2.new(1, -116, 0, 24),
        Position = UDim2.new(0, 103, 0, y),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Colors.TextPrimary,
        TextTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 53,
        Parent = SuccessCard
    })
    table.insert(SuccessLabels, label)
    table.insert(SuccessLabels, value)
    if addSeparator then
        local separator = New("Frame", {
            Size = UDim2.new(1, -26, 0, 1),
            Position = UDim2.new(0, 13, 0, y + 25),
            BackgroundColor3 = Colors.Stroke,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 52,
            Parent = SuccessCard
        })
        table.insert(SuccessSeparators, separator)
    end
    return value
end

local LicenseValue = CreateSuccessRow("License", 7, true)
local ExpiryValue = CreateSuccessRow("Expires", 34, true)
local RemainingValue = CreateSuccessRow("Remaining", 61, true)
local ExecutionsValue = CreateSuccessRow("Executions", 88, true)
local NoteValue = CreateSuccessRow("Note", 115, false)

local SuccessLoading = New("TextLabel", {
    Size = UDim2.new(1, -34, 0, 18),
    Position = UDim2.new(0, 17, 0, 308),
    BackgroundTransparency = 1,
    Text = "Loading VYX...",
    TextColor3 = Colors.TextSecondary,
    TextTransparency = 1,
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 52,
    Parent = SuccessFrame
})

local SuccessCountdown = New("TextLabel", {
    Size = UDim2.new(0, 30, 0, 18),
    Position = UDim2.new(1, -47, 0, 308),
    BackgroundTransparency = 1,
    Text = "3s",
    TextColor3 = Colors.Success,
    TextTransparency = 1,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 52,
    Parent = SuccessFrame
})

local SuccessProgressBG = New("Frame", {
    Size = UDim2.new(1, -34, 0, 4),
    Position = UDim2.new(0, 17, 0, 336),
    BackgroundColor3 = Colors.TertiaryBG,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 52,
    Parent = SuccessFrame
})
Corner(SuccessProgressBG, 4)

local SuccessProgress = New("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Colors.Success,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 53,
    Parent = SuccessProgressBG
})
Corner(SuccessProgress, 4)

local function UpdateScale()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    local viewport = camera.ViewportSize
    local targetWidth = isUserPanelOpen and 610 or 400
    local scale = math.min(viewport.X / targetWidth, viewport.Y / 430)
    InterfaceScale.Scale = math.clamp(scale, 0.62, 1)
end

local function ToggleUserPanel(forceState)
    if closing or isAuthenticating then
        return
    end
    if type(forceState) == "boolean" then
        isUserPanelOpen = forceState
    else
        isUserPanelOpen = not isUserPanelOpen
    end
    if isUserPanelOpen then
        PlayTween(RootContainer, 0.42, {Size = UDim2.new(0, 570, 0, 380)}, Enum.EasingStyle.Quint)
        PlayTween(UserPanel, 0.42, {Size = UDim2.new(0, 200, 0, 380)}, Enum.EasingStyle.Quint)
        PlayTween(UserPanelStroke, 0.3, {Transparency = 0})
    else
        PlayTween(UserPanel, 0.32, {Size = UDim2.new(0, 0, 0, 380)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        PlayTween(UserPanelStroke, 0.2, {Transparency = 1})
        PlayTween(RootContainer, 0.35, {Size = UDim2.new(0, 360, 0, 380)}, Enum.EasingStyle.Quint)
    end
    task.delay(0.43, UpdateScale)
end

local function SetStatus(mode, text)
    if spinTween then
        spinTween:Cancel()
        spinTween = nil
    end
    StatusIcon.Rotation = 0
    if mode == "loading" then
        StatusText.Text = text or "Authenticating with server..."
        StatusText.TextColor3 = Colors.TextPrimary
        StatusIcon.Image = GetAsset("loader-2")
        StatusIcon.ImageColor3 = Colors.Accent
        PlayTween(StatusStroke, 0.25, {Color = Colors.Accent})
        spinTween = TweenService:Create(StatusIcon, TweenInfo.new(0.85, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
        spinTween:Play()
    elseif mode == "success" then
        StatusText.Text = text or "Key verified."
        StatusText.TextColor3 = Colors.Success
        StatusIcon.Image = GetAsset("check")
        StatusIcon.ImageColor3 = Colors.Success
        PlayTween(StatusStroke, 0.25, {Color = Colors.Success})
    elseif mode == "error" then
        StatusText.Text = text or "Authentication failed."
        StatusText.TextColor3 = Colors.Error
        StatusIcon.Image = GetAsset("alert-circle")
        StatusIcon.ImageColor3 = Colors.Error
        PlayTween(StatusStroke, 0.25, {Color = Colors.Error})
    elseif mode == "warn" then
        StatusText.Text = text or "Waiting..."
        StatusText.TextColor3 = Colors.Warn
        StatusIcon.Image = GetAsset("alert-circle")
        StatusIcon.ImageColor3 = Colors.Warn
        PlayTween(StatusStroke, 0.25, {Color = Colors.Warn})
    else
        StatusText.Text = text or "Ready for authorization..."
        StatusText.TextColor3 = Colors.TextSecondary
        StatusIcon.Image = GetAsset("shield")
        StatusIcon.ImageColor3 = Colors.Warn
        PlayTween(StatusStroke, 0.25, {Color = Colors.Stroke})
    end
end

local shaking = false
local function ShakeInput()
    if shaking then
        return
    end
    shaking = true
    local base = UDim2.new(0, 0, 0, 72)
    task.spawn(function()
        local offsets = {7, -7, 5, -5, 3, -3, 0}
        for _, offset in ipairs(offsets) do
            PlayTween(InputFrame, 0.045, {Position = UDim2.new(0, offset, 0, 72)}, Enum.EasingStyle.Linear)
            task.wait(0.05)
        end
        InputFrame.Position = base
        shaking = false
    end)
end

local function CleanupImmediate()
    clockRunning = false
    if spinTween then
        spinTween:Cancel()
        spinTween = nil
    end
    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    connections = {}
    if VYXBlur and VYXBlur.Parent then
        VYXBlur:Destroy()
    end
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
    if env.VYXKey_System == ScreenGui then
        env.VYXKey_System = nil
    end
end

local function OffsetPosition(position, xOffset, yOffset)
    return UDim2.new(
        position.X.Scale,
        position.X.Offset + (xOffset or 0),
        position.Y.Scale,
        position.Y.Offset + (yOffset or 0)
    )
end

local function AnimateInterfaceOut(callback)
    if closing then
        return
    end
    closing = true
    isAuthenticating = true
    if isUserPanelOpen then
        isUserPanelOpen = false
        PlayTween(UserPanel, 0.22, {Size = UDim2.new(0, 0, 0, 380)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        PlayTween(UserPanelStroke, 0.18, {Transparency = 1})
        PlayTween(RootContainer, 0.22, {Size = UDim2.new(0, 360, 0, 380)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    end
    local startScale = InterfaceScale.Scale
    local targetScale = math.max(startScale * 0.9, 0.5)
    PlayTween(RootContainer, 0.36, {Position = OffsetPosition(RootContainer.Position, 0, 22)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    PlayTween(InterfaceScale, 0.36, {Scale = targetScale}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    PlayTween(VYXBlur, 0.36, {Size = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.38, function()
        CleanupImmediate()
        if callback then
            callback()
        end
    end)
end

local function CloseInterface()
    AnimateInterfaceOut()
end

local dragging = false
local dragStart = nil
local startPosition = nil
local dragInput = nil

Connect(Header.InputBegan, function(input)
    if closing then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = RootContainer.Position
        dragInput = input
    end
end)

Connect(UserInputService.InputChanged, function(input)
    if not dragging or not dragStart or not startPosition then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input == dragInput then
        local delta = input.Position - dragStart
        RootContainer.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

Connect(UserInputService.InputEnded, function(input)
    if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        dragInput = nil
    end
end)

local cameraConnection = nil
if Workspace.CurrentCamera then
    cameraConnection = Connect(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), UpdateScale)
end

Connect(KeyInput:GetPropertyChangedSignal("Text"), function()
    if #KeyInput.Text > 180 then
        KeyInput.Text = KeyInput.Text:sub(1, 180)
    end
end)

Connect(KeyInput.Focused, function()
    PlayTween(InputStroke, 0.22, {Color = Colors.Accent})
    PlayTween(KeyIcon, 0.22, {ImageColor3 = Colors.Accent})
    PlayTween(InputFrame, 0.22, {BackgroundColor3 = Colors.ElevatedBG})
end)

Connect(KeyInput.FocusLost, function(enterPressed)
    PlayTween(InputStroke, 0.22, {Color = Colors.Stroke})
    PlayTween(KeyIcon, 0.22, {ImageColor3 = Colors.TextSecondary})
    PlayTween(InputFrame, 0.22, {BackgroundColor3 = Colors.TertiaryBG})
    if enterPressed and not isAuthenticating then
        task.spawn(function()
            local value = SanitizeKey(KeyInput.Text)
            if value ~= "" then
                KeyInput.Text = value
            end
        end)
    end
end)

Connect(CloseButton.MouseEnter, function()
    PlayTween(CloseButton, 0.16, {BackgroundColor3 = Colors.Error})
    PlayTween(CloseIcon, 0.16, {ImageColor3 = Colors.TextPrimary})
    PlayTween(CloseStroke, 0.16, {Transparency = 1})
end)

Connect(CloseButton.MouseLeave, function()
    PlayTween(CloseButton, 0.16, {BackgroundColor3 = Colors.SecondaryBG})
    PlayTween(CloseIcon, 0.16, {ImageColor3 = Colors.TextSecondary})
    PlayTween(CloseStroke, 0.16, {Transparency = 0})
end)

Connect(CloseButton.MouseButton1Click, function()
    if UseCooldown("close", 1) then
        CloseInterface()
    end
end)

Connect(PanelClose.MouseButton1Click, function()
    if UseCooldown("panelclose", 0.45) then
        ToggleUserPanel(false)
    end
end)

Connect(CopyHWIDButton.MouseEnter, function()
    PlayTween(CopyHWIDButton, 0.16, {ImageColor3 = Colors.Accent})
end)

Connect(CopyHWIDButton.MouseLeave, function()
    PlayTween(CopyHWIDButton, 0.16, {ImageColor3 = Colors.TextSecondary})
end)

Connect(CopyHWIDButton.MouseButton1Click, function()
    if not UseCooldown("copyhwid", 0.8) then
        return
    end
    if SafeClipboard(FullHWID) then
        PlayTween(CopyHWIDButton, 0.15, {ImageColor3 = Colors.Success})
        Notify("Copied", "HWID copied to your clipboard.", "Info", 2.5)
        task.delay(0.45, function()
            if CopyHWIDButton.Parent then
                PlayTween(CopyHWIDButton, 0.15, {ImageColor3 = Colors.TextSecondary})
            end
        end)
    else
        Notify("Unavailable", "Clipboard is not supported by this executor.", "Error", 3)
    end
end)

local currentScriptId = gameIdToURL[tostring(game.GameId)]
local api = nil
local sdkError = nil
local sdkSuccess, sdkResult = pcall(function()
    local source = game:HttpGet("https://sdkapi-public.luarmor.net/library.lua")
    local loader = loadstring(source)
    if type(loader) ~= "function" then
        error("SDK loader is unavailable")
    end
    return loader()
end)

if sdkSuccess and type(sdkResult) == "table" then
    api = sdkResult
else
    sdkError = tostring(sdkResult)
end

local isSupported = api ~= nil and type(currentScriptId) == "string" and currentScriptId ~= ""
if isSupported then
    api.script_id = currentScriptId
elseif not currentScriptId then
    SetStatus("error", "This game is not configured.")
else
    SetStatus("error", "Authentication service unavailable.")
end

local function FillKeyInformation(status)
    local data = type(status.data) == "table" and status.data or {}
    local expiry = tonumber(data.auth_expire) or 0
    local lifetime = expiry <= 0
    LicenseValue.Text = lifetime and "Lifetime" or "Timed"
    ExpiryValue.Text = FormatExpiry(expiry)
    RemainingValue.Text = lifetime and "Lifetime" or FormatDuration(math.max(expiry - os.time(), 0))
    ExecutionsValue.Text = tostring(tonumber(data.total_executions) or 0)
    local note = tostring(data.note or "Not specified")
    if note == "" then
        note = "Not specified"
    end
    NoteValue.Text = note
end

local function LoadProtectedScript(userKey)
    env.script_key = userKey
    _G.script_key = userKey
    script_key = userKey
    task.spawn(function()
        local success = pcall(function()
            api.load_script()
        end)
        if not success and type(api.purge_cache) == "function" then
            pcall(function()
                api.purge_cache()
            end)
            pcall(function()
                api.load_script()
            end)
        end
    end)
end

local function ShowKeyInformation(status, userKey)
    if isUserPanelOpen then
        isUserPanelOpen = false
        PlayTween(UserPanel, 0.24, {Size = UDim2.new(0, 0, 0, 380)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        PlayTween(UserPanelStroke, 0.18, {Transparency = 1})
        PlayTween(RootContainer, 0.26, {Size = UDim2.new(0, 360, 0, 380)}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.27)
        UpdateScale()
    end

    FillKeyInformation(status)
    SuccessFrame.Visible = true
    SuccessCardScale.Scale = 0.96
    SuccessGlow.BackgroundTransparency = 1
    SuccessIcon.ImageTransparency = 1
    SuccessIcon.Position = UDim2.new(0.5, 0, 0, 52)
    SuccessTitle.TextTransparency = 1
    SuccessTitle.Position = UDim2.new(0, 15, 0, 99)
    SuccessSubtitle.TextTransparency = 1
    SuccessSubtitle.Position = UDim2.new(0, 15, 0, 124)
    SuccessCard.BackgroundTransparency = 1
    SuccessCard.Position = UDim2.new(0, 17, 0, 158)
    SuccessStroke.Transparency = 1
    SuccessLoading.TextTransparency = 1
    SuccessCountdown.TextTransparency = 1
    SuccessProgressBG.BackgroundTransparency = 1
    SuccessProgress.BackgroundTransparency = 1
    SuccessProgress.Size = UDim2.new(1, 0, 1, 0)
    SuccessCountdown.Text = "3s"

    for _, label in ipairs(SuccessLabels) do
        label.TextTransparency = 1
    end
    for _, separator in ipairs(SuccessSeparators) do
        separator.BackgroundTransparency = 1
    end

    PlayTween(TopBar, 0.3, {BackgroundColor3 = Colors.Success})
    PlayTween(SuccessCardScale, 0.42, {Scale = 1}, Enum.EasingStyle.Back)
    PlayTween(SuccessGlow, 0.34, {BackgroundTransparency = 0.84}, Enum.EasingStyle.Quint)
    PlayTween(SuccessIcon, 0.42, {
        ImageTransparency = 0,
        Position = UDim2.new(0.5, 0, 0, 44)
    }, Enum.EasingStyle.Back)
    PlayTween(SuccessTitle, 0.34, {
        TextTransparency = 0,
        Position = UDim2.new(0, 15, 0, 91)
    }, Enum.EasingStyle.Quint)
    PlayTween(SuccessSubtitle, 0.36, {
        TextTransparency = 0,
        Position = UDim2.new(0, 15, 0, 116)
    }, Enum.EasingStyle.Quint)
    PlayTween(SuccessCard, 0.4, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 17, 0, 148)
    }, Enum.EasingStyle.Quint)
    PlayTween(SuccessStroke, 0.4, {Transparency = 0.08}, Enum.EasingStyle.Quint)
    PlayTween(SuccessLoading, 0.36, {TextTransparency = 0})
    PlayTween(SuccessCountdown, 0.36, {TextTransparency = 0})
    PlayTween(SuccessProgressBG, 0.36, {BackgroundTransparency = 0})
    PlayTween(SuccessProgress, 0.36, {BackgroundTransparency = 0})

    for index, label in ipairs(SuccessLabels) do
        task.delay(0.08 + index * 0.025, function()
            if label.Parent then
                PlayTween(label, 0.24, {TextTransparency = 0}, Enum.EasingStyle.Quint)
            end
        end)
    end
    for index, separator in ipairs(SuccessSeparators) do
        task.delay(0.16 + index * 0.035, function()
            if separator.Parent then
                PlayTween(separator, 0.24, {BackgroundTransparency = 0.35}, Enum.EasingStyle.Quint)
            end
        end)
    end

    PlayTween(SuccessProgress, 3, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

    task.spawn(function()
        for remaining = 3, 1, -1 do
            if closing or not SuccessCountdown.Parent then
                return
            end
            SuccessCountdown.Text = tostring(remaining) .. "s"
            task.wait(1)
        end
    end)

    task.wait(3)
    AnimateInterfaceOut(function()
        LoadProtectedScript(userKey)
    end)
end

local ErrorMessages = {
    KEY_EXPIRED = "Your key has expired.",
    KEY_HWID_LOCKED = "Key is linked to another HWID.",
    KEY_INCORRECT = "The key is incorrect or no longer exists.",
    KEY_BANNED = "This key has been blacklisted.",
    KEY_INVALID = "The key format is invalid.",
    SCRIPT_ID_INCORRECT = "The configured script ID does not exist.",
    SCRIPT_ID_INVALID = "The configured script ID is invalid.",
    INVALID_EXECUTOR = "This executor is not supported by Luarmor.",
    SECURITY_ERROR = "The authentication request failed security validation.",
    TIME_ERROR = "Your client time is invalid or the request timed out.",
    UNKNOWN_ERROR = "Luarmor is temporarily unavailable. Try again shortly."
}

local function ValidateKey(rawKey)
    if closing or isAuthenticating then
        return
    end
    isAuthenticating = true

    if not currentScriptId then
        SetStatus("error", "This game is not configured.")
        Notify("Unsupported", "No Luarmor script ID is configured for this game.", "Error", 4)
        isAuthenticating = false
        return
    end

    if not api or type(api.check_key) ~= "function" then
        SetStatus("error", "Authentication service unavailable.")
        Notify("SDK Error", sdkError or "Luarmor SDK could not be loaded.", "Error", 4)
        isAuthenticating = false
        return
    end

    local userKey = SanitizeKey(rawKey)
    KeyInput.Text = userKey
    if userKey == "" or #userKey < 16 or #userKey > 128 then
        SetStatus("error", "Please enter a valid key.")
        Notify("Invalid Input", "Paste the key generated for your VYX license.", "Error", 3.5)
        PlayTween(InputStroke, 0.2, {Color = Colors.Error})
        ShakeInput()
        task.delay(1.2, function()
            if InputStroke.Parent and not KeyInput:IsFocused() then
                PlayTween(InputStroke, 0.2, {Color = Colors.Stroke})
            end
        end)
        isAuthenticating = false
        return
    end

    RedeemText.Text = "Verifying..."
    RedeemButton.Active = false
    LinkvertiseButton.Active = false
    ShrtflyButton.Active = false
    SetStatus("loading", "Authenticating with Luarmor...")

    local success, status = pcall(function()
        return api.check_key(userKey)
    end)

    if not success or type(status) ~= "table" or type(status.code) ~= "string" then
        SetStatus("error", "Connection to Luarmor failed.")
        Notify("Connection Error", "The authentication server did not return a valid response.", "Error", 4)
        RedeemText.Text = "Verify Key"
        RedeemButton.Active = true
        LinkvertiseButton.Active = true
        ShrtflyButton.Active = true
        ShakeInput()
        isAuthenticating = false
        return
    end

    if status.code == "KEY_VALID" then
        SaveKey(userKey)
        env.script_key = userKey
        _G.script_key = userKey
        script_key = userKey
        SetStatus("success", "Key verified successfully.")
        RedeemText.Text = "Verified"
        PlayTween(TopBar, 0.3, {BackgroundColor3 = Colors.Success})
        PlayTween(RedeemButton, 0.3, {BackgroundColor3 = Colors.Success})
        Notify("Access Granted", "Your license was verified successfully.", "Info", 2.5)
        task.wait(0.45)
        ShowKeyInformation(status, userKey)
        return
    end

    local errorText = ErrorMessages[status.code] or status.message or "Authentication failed."
    if status.code == "KEY_INCORRECT" or status.code == "KEY_INVALID" or status.code == "KEY_BANNED" then
        ClearSavedKey()
    end
    SetStatus("error", errorText)
    Notify("Authentication Failed", errorText, "Error", 4.5)
    RedeemText.Text = "Verify Key"
    RedeemButton.Active = true
    LinkvertiseButton.Active = true
    ShrtflyButton.Active = true
    PlayTween(InputStroke, 0.2, {Color = Colors.Error})
    ShakeInput()
    task.delay(1.3, function()
        if InputStroke.Parent and not KeyInput:IsFocused() then
            PlayTween(InputStroke, 0.2, {Color = Colors.Stroke})
        end
    end)
    task.delay(3, function()
        if not closing and not isAuthenticating then
            SetStatus("idle", "Ready for authorization...")
        end
    end)
    isAuthenticating = false
end

local function CopyProviderLink(cooldownName, providerName, link, label)
    if not UseCooldown(cooldownName, 0.9) or isAuthenticating then
        return
    end
    if type(link) ~= "string" or link == "" then
        Notify("Not Configured", providerName .. " link has not been added yet.", "Warn", 3)
        return
    end
    if SafeClipboard(link) then
        Notify("Link Copied", providerName .. " key link copied to your clipboard.", "Info", 3)
        local oldText = label.Text
        label.Text = "Copied!"
        task.delay(0.8, function()
            if label.Parent then
                label.Text = oldText
            end
        end)
    else
        Notify("Unavailable", "Clipboard is not supported by this executor.", "Error", 3)
    end
end

Connect(LinkvertiseButton.MouseButton1Click, function()
    CopyProviderLink("linkvertise", "Linkvertise", Config.LinkvertiseLink, LinkvertiseText)
end)

Connect(ShrtflyButton.MouseButton1Click, function()
    CopyProviderLink("shrtfly", "Shrtfly", Config.ShrtflyLink, ShrtflyText)
end)

Connect(ResetHWIDButton.MouseButton1Click, function()
    if not UseCooldown("resethwid", 0.9) or isAuthenticating then
        return
    end
    if SafeClipboard(Config.DiscordLink) then
        Notify("Discord Copied", "Open the VYX Discord and use the Luarmor bot to reset your HWID.", "Warn", 4)
    else
        Notify("Unavailable", "Clipboard is not supported by this executor.", "Error", 3)
    end
end)

Connect(DiscordButton.MouseButton1Click, function()
    if not UseCooldown("discord", 0.9) or isAuthenticating then
        return
    end
    if SafeClipboard(Config.DiscordLink) then
        Notify("Discord Copied", "VYX Discord invite copied.", "Info", 3)
    else
        Notify("Unavailable", "Clipboard is not supported by this executor.", "Error", 3)
    end
end)

Connect(UserInfoButton.MouseButton1Click, function()
    if not UseCooldown("userinfo", 0.45) or isAuthenticating then
        return
    end
    ToggleUserPanel()
end)

Connect(RedeemButton.MouseButton1Click, function()
    if not UseCooldown("redeem", 0.65) then
        return
    end
    task.spawn(ValidateKey, KeyInput.Text)
end)

Connect(KeyInput.FocusLost, function(enterPressed)
    if enterPressed and UseCooldown("enterredeem", 0.65) then
        task.spawn(ValidateKey, KeyInput.Text)
    end
end)

UpdateScale()
local initialScale = InterfaceScale.Scale
local restingPosition = RootContainer.Position
RootContainer.Position = OffsetPosition(restingPosition, 0, 22)
InterfaceScale.Scale = math.max(initialScale * 0.92, 0.52)
RootContainer.Visible = true
PlayTween(RootContainer, 0.48, {Position = restingPosition}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
PlayTween(InterfaceScale, 0.52, {Scale = initialScale}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)


if not getgenv().Premium and script_key then
    local function safeRequestInvite()
        local success, err = pcall(function()
            local http = request or http_request or (syn and syn.request)
            if not http then
                warn("There No Access !")
                return
            end

            local body = game:GetService("HttpService"):JSONEncode({
                cmd = "INVITE_BROWSER",
                args = {code = "7TE3HPrGbB"}, 
                nonce = game:GetService("HttpService"):GenerateGUID(false)
            })

            http({
                Url = "http://127.0.0.1:6463/rpc?v=1",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Origin"] = "https://discord.com"
                },
                Body = body
            })

            warn("[✅] Already Send Discord Invitation")
        end)

        if not success then
            warn("[❌] Join Discord Faile : ", err)
        end
    end

    local filename = "TimeChecking_VYX.txt"
    local currentTick = tick()

    if not isfile(filename) then
        safeRequestInvite()
        writefile(filename, tostring(currentTick))
    else
        local lastTick = tonumber(readfile(filename))
        if (currentTick - lastTick) >= 10 then
            safeRequestInvite()
            writefile(filename, tostring(currentTick))
        end
    end
end


local savedKey = nil
if type(env.script_key) == "string" and env.script_key ~= "" then
    savedKey = env.script_key
elseif type(_G.script_key) == "string" and _G.script_key ~= "" then
    savedKey = _G.script_key
else
    savedKey = LoadSavedKey()
end

if savedKey then
    savedKey = SanitizeKey(savedKey)
    if savedKey ~= "" then
        KeyInput.Text = savedKey
        task.delay(0.75, function()
            if ScreenGui.Parent and not closing and not isAuthenticating then
                Notify("Auto Login", "Saved key found. Validating...", "Warn", 2.5)
                ValidateKey(savedKey)
            end
        end)
    end
end
