--[[
===============================================================
 AXOMUSC BETA
 AXOLION COMMUNITY
 PREMIUM MUSIC ENGINE
 ---------------------------------------------------------------
 Delta / Executor LocalScript
 UI REBUILD
 ---------------------------------------------------------------
 SAFE EXECUTOR ADAPTERS:
 gethui
 getgenv
 setclipboard
 request / http_request / syn.request
 isfile / readfile / writefile / delfile
 ---------------------------------------------------------------
 FEATURES:
 • Premium Acrylic / Glass UI
 • Responsive UIScale
 • Dragging
 • Minimize Bubble
 • Keybind
 • Toast Notifications
 • Music Search by Roblox Audio ID / Name
 • Direct Roblox SoundId playback
 • Queue
 • Playlist
 • Favorites
 • Saved Library
 • Audio Folder Browser
 • Volume 1-100
 • Playback Speed 0.5 / 1 / 1.5 / 2
 • Shuffle
 • Repeat
 • Previous / Next
 • Equalizer visual UI
 • Community page
 • Copy Discord / Community links
 • Persistent save when executor supports filesystem
 • Executor-safe API detection
 • No dependency on external UI libraries
===============================================================
]]

--// ============================================================
--// SECTION 01 - EXECUTOR SAFE CORE
--// ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    return
end

--// Never directly trust executor functions.
local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end

    return nil
end

--// ============================================================
--// GET HUI
--// ============================================================

local function getExecutorUI()
    local ok, result = pcall(function()
        if type(gethui) == "function" then
            return gethui()
        end
    end)

    if ok and typeof(result) == "Instance" then
        return result
    end

    local ok2, core = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok2 and core then
        return core
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

    if playerGui then
        return playerGui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local UIParent = getExecutorUI()

--// ============================================================
--// GLOBAL ENVIRONMENT
--// ============================================================

local GlobalEnv = {}

pcall(function()
    if type(getgenv) == "function" then
        GlobalEnv = getgenv()
    else
        GlobalEnv = _G
    end
end)

--// ============================================================
--// CLEAN OLD AXOMUSC
--// ============================================================

pcall(function()
    local old = UIParent:FindFirstChild("Axomusc_Beta")
    if old then
        old:Destroy()
    end
end)

--// ============================================================
--// EXECUTOR API DETECTION
--// ============================================================

local Executor = {
    Name = "Unknown",
    HasHTTP = false,
    HasClipboard = false,
    HasFilesystem = false,
    HasGetHUI = false,
}

pcall(function()
    Executor.HasGetHUI = type(gethui) == "function"
end)

pcall(function()
    Executor.HasClipboard = type(setclipboard) == "function"
end)

pcall(function()
    Executor.HasFilesystem =
        type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
end)

local HTTPRequest

pcall(function()
    if type(request) == "function" then
        HTTPRequest = request
    elseif type(http_request) == "function" then
        HTTPRequest = http_request
    elseif type(syn) == "table" and type(syn.request) == "function" then
        HTTPRequest = syn.request
    end
end)

Executor.HasHTTP = type(HTTPRequest) == "function"

pcall(function()
    if type(identifyexecutor) == "function" then
        Executor.Name = identifyexecutor()
    elseif type(getexecutorname) == "function" then
        Executor.Name = getexecutorname()
    end
end)

--// ============================================================
--// CONFIG
--// ============================================================

local CONFIG = {
    Name = "Axomusc_Beta",

    Logo = "rbxassetid://85647271976925",
    Thumbnail = "rbxassetid://84404991858137",
    SubLogo = "rbxassetid://100003155958609",

    Discord = "https://discord.gg/dkuXRcS2hY",
    Community = "https://www.roblox.com/share/g/245953568",

    SaveFile = "Axomusc_Beta_Data.json",

    DefaultVolume = 70,
    DefaultSpeed = 1,

    Accent = Color3.fromRGB(45, 235, 210),
    AccentDark = Color3.fromRGB(15, 135, 125),

    DarkBlue = Color3.fromRGB(5, 10, 28),
    DarkBlue2 = Color3.fromRGB(8, 15, 38),
    Panel = Color3.fromRGB(7, 9, 19),
    Panel2 = Color3.fromRGB(10, 14, 28),

    Black = Color3.fromRGB(2, 3, 8),
    White = Color3.fromRGB(240, 246, 250),
    Muted = Color3.fromRGB(145, 157, 178),
    Dim = Color3.fromRGB(82, 94, 118),

    Border = Color3.fromRGB(34, 190, 178),
}

--// ============================================================
--// STATE
--// ============================================================

local State = {
    Visible = true,
    Minimized = false,

    CurrentPage = "Music",

    CurrentSound = nil,
    CurrentTrack = nil,

    IsPlaying = false,
    IsShuffle = false,
    IsRepeat = false,

    Volume = CONFIG.DefaultVolume,
    Speed = CONFIG.DefaultSpeed,

    SearchText = "",

    Library = {},
    Favorites = {},
    Playlists = {
        ["Favorites"] = {},
        ["Axomusc Theme"] = {},
    },

    Queue = {},

    CurrentPlaylist = "Favorites",

    Keybind = Enum.KeyCode.RightControl,
}

--// ============================================================
--// PERSISTENCE
--// ============================================================

local function loadSavedData()
    if not Executor.HasFilesystem then
        return
    end

    local ok, content = pcall(function()
        if isfile(CONFIG.SaveFile) then
            return readfile(CONFIG.SaveFile)
        end
    end)

    if not ok or type(content) ~= "string" or content == "" then
        return
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)

    if not success or type(data) ~= "table" then
        return
    end

    if type(data.Library) == "table" then
        State.Library = data.Library
    end

    if type(data.Favorites) == "table" then
        State.Favorites = data.Favorites
    end

    if type(data.Playlists) == "table" then
        State.Playlists = data.Playlists
    end

    if type(data.Volume) == "number" then
        State.Volume = math.clamp(data.Volume, 1, 100)
    end

    if type(data.Speed) == "number" then
        State.Speed = data.Speed
    end
end

local function saveData()
    if not Executor.HasFilesystem then
        return
    end

    local data = {
        Library = State.Library,
        Favorites = State.Favorites,
        Playlists = State.Playlists,
        Volume = State.Volume,
        Speed = State.Speed,
    }

    pcall(function()
        writefile(
            CONFIG.SaveFile,
            HttpService:JSONEncode(data)
        )
    end)
end

loadSavedData()

--// ============================================================
--// INSTANCE HELPERS
--// ============================================================

local function New(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    if parent then
        object.Parent = parent
    end

    return object
end

local function Corner(parent, radius)
    return New(
        "UICorner",
        {
            CornerRadius = UDim.new(0, radius or 12)
        },
        parent
    )
end

local function Stroke(parent, color, thickness, transparency)
    return New(
        "UIStroke",
        {
            Color = color or CONFIG.Border,
            Thickness = thickness or 1,
            Transparency = transparency or 0,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        },
        parent
    )
end

local function Padding(parent, l, r, t, b)
    return New(
        "UIPadding",
        {
            PaddingLeft = UDim.new(0, l or 0),
            PaddingRight = UDim.new(0, r or 0),
            PaddingTop = UDim.new(0, t or 0),
            PaddingBottom = UDim.new(0, b or 0),
        },
        parent
    )
end

local function List(parent, direction, padding)
    return New(
        "UIListLayout",
        {
            FillDirection = direction or Enum.FillDirection.Vertical,
            Padding = UDim.new(0, padding or 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        },
        parent
    )
end

local function tween(object, duration, properties, style, direction)
    if not object or not object.Parent then
        return
    end

    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )

    pcall(function()
        TweenService:Create(object, info, properties):Play()
    end)
end

--// ============================================================
--// RIPPLE
--// ============================================================

local function Ripple(button, position)
    if not button or not button:IsA("GuiObject") then
        return
    end

    local ripple = New(
        "Frame",
        {
            Name = "Ripple",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(
                position.X - button.AbsolutePosition.X,
                position.Y - button.AbsolutePosition.Y
            ),
            Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = CONFIG.Accent,
            BackgroundTransparency = 0.65,
            ZIndex = button.ZIndex + 5,
        },
        button
    )

    Corner(ripple, 100)

    local maxSize = math.max(
        button.AbsoluteSize.X,
        button.AbsoluteSize.Y
    ) * 2.2

    tween(
        ripple,
        0.45,
        {
            Size = UDim2.fromOffset(maxSize, maxSize),
            BackgroundTransparency = 1,
        },
        Enum.EasingStyle.Quad
    )

    task.delay(0.5, function()
        if ripple then
            ripple:Destroy()
        end
    end)
end

--// ============================================================
--// GUI ROOT
--// ============================================================

local ScreenGui = New(
    "ScreenGui",
    {
        Name = "Axomusc_Beta",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
    },
    UIParent
)

--// ============================================================
--// RESPONSIVE SCALE
--// ============================================================

local UIScale = New(
    "UIScale",
    {
        Scale = 1,
    },
    ScreenGui
)

local function updateScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local widthScale = viewport.X / 1280
    local heightScale = viewport.Y / 720

    local scale = math.min(widthScale, heightScale)

    if viewport.X < 600 then
        scale = math.min(scale, 0.72)
    elseif viewport.X < 850 then
        scale = math.min(scale, 0.84)
    else
        scale = math.min(scale, 1)
    end

    UIScale.Scale = math.clamp(scale, 0.58, 1.08)
end

updateScale()

pcall(function()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(
        updateScale
    )
end)

--// ============================================================
--// MAIN WINDOW
--// ============================================================

local Main = New(
    "Frame",
    {
        Name = "MainWindow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.52),
        Size = UDim2.fromOffset(1060, 640),

        BackgroundColor3 = CONFIG.DarkBlue,
        BackgroundTransparency = 0.035,

        BorderSizePixel = 0,

        ClipsDescendants = true,

        ZIndex = 10,
    },
    ScreenGui
)

Corner(Main, 20)
Stroke(Main, CONFIG.Border, 1.5, 0.12)

--// acrylic layers
local Acrylic = New(
    "Frame",
    {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(7, 15, 34),
        BackgroundTransparency = 0.24,
        BorderSizePixel = 0,
        ZIndex = 10,
    },
    Main
)

Corner(Acrylic, 20)

local GlowTop = New(
    "Frame",
    {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 50,
    },
    Main
)

--// ============================================================
--// HEADER
--// ============================================================

local Header = New(
    "Frame",
    {
        Name = "Header",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 82),
        BackgroundColor3 = Color3.fromRGB(5, 8, 22),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        ZIndex = 20,
    },
    Main
)

local HeaderDivider = New(
    "Frame",
    {
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = CONFIG.Border,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 30,
    },
    Header
)

local Logo = New(
    "ImageLabel",
    {
        Name = "Logo",
        Position = UDim2.fromOffset(18, 14),
        Size = UDim2.fromOffset(52, 52),
        BackgroundColor3 = CONFIG.Black,
        BackgroundTransparency = 0.2,
        Image = CONFIG.Logo,
        ScaleType = Enum.ScaleType.Fit,
        BorderSizePixel = 0,
        ZIndex = 30,
    },
    Header
)

Corner(Logo, 14)
Stroke(Logo, CONFIG.Border, 1, 0.3)

local Title = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(84, 14),
        Size = UDim2.fromOffset(350, 28),
        BackgroundTransparency = 1,
        Text = "Axomusc",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = CONFIG.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 30,
    },
    Header
)

local BetaBox = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(174, 18),
        Size = UDim2.fromOffset(48, 20),
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 0.12,
        Text = "BETA",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = CONFIG.Black,
        ZIndex = 31,
    },
    Header
)

Corner(BetaBox, 5)

local Subtitle = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(84, 43),
        Size = UDim2.fromOffset(390, 22),
        BackgroundTransparency = 1,
        Text = "By. Axolion Community  •  Premium Music Engine",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = CONFIG.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 30,
    },
    Header
)

--// ============================================================
--// HEADER BUTTONS
--// ============================================================

local function MakeHeaderButton(text, x)
    local b = New(
        "TextButton",
        {
            Position = UDim2.new(1, x, 0, 20),
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.fromOffset(42, 42),
            BackgroundColor3 = CONFIG.Panel2,
            BackgroundTransparency = 0.1,
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = CONFIG.White,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 40,
        },
        Header
    )

    Corner(b, 12)
    Stroke(b, CONFIG.Border, 1, 0.6)

    b.MouseEnter:Connect(function()
        tween(b, 0.18, {
            BackgroundColor3 = CONFIG.AccentDark,
            TextColor3 = CONFIG.White,
        })
    end)

    b.MouseLeave:Connect(function()
        tween(b, 0.18, {
            BackgroundColor3 = CONFIG.Panel2,
            TextColor3 = CONFIG.White,
        })
    end)

    b.MouseButton1Click:Connect(function()
        Ripple(b, UserInputService:GetMouseLocation())
    end)

    return b
end

local CloseButton = MakeHeaderButton("×", -18)
local MinimizeButton = MakeHeaderButton("—", -68)

--// ============================================================
--// BODY
--// ============================================================

local Body = New(
    "Frame",
    {
        Position = UDim2.fromOffset(0, 82),
        Size = UDim2.new(1, 0, 1, -82),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 20,
    },
    Main
)

--// ============================================================
--// SIDEBAR
--// ============================================================

local Sidebar = New(
    "Frame",
    {
        Name = "Sidebar",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(230, 558),
        BackgroundColor3 = Color3.fromRGB(4, 6, 15),
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 25,
    },
    Body
)

local SidebarStroke = Stroke(Sidebar, CONFIG.Border, 1, 0.65)

local SidebarInner = New(
    "Frame",
    {
        Position = UDim2.fromOffset(12, 16),
        Size = UDim2.new(1, -24, 1, -32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 26,
    },
    Sidebar
)

local SidebarHeader = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 0, 22),
        BackgroundTransparency = 1,
        Text = "WORKSPACE",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = CONFIG.Dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 27,
    },
    SidebarInner
)

local SidebarList = New(
    "Frame",
    {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 145),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 27,
    },
    SidebarInner
)

List(SidebarList, Enum.FillDirection.Vertical, 8)

--// ============================================================
--// NAV BUTTON
--// ============================================================

local Navigation = {}

local function NavButton(name, icon, order)
    local Button = New(
        "TextButton",
        {
            Name = name,
            Size = UDim2.new(1, 0, 0, 58),
            BackgroundColor3 = CONFIG.Panel2,
            BackgroundTransparency = 0.55,
            Text = "",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            LayoutOrder = order,
            ZIndex = 28,
        },
        SidebarList
    )

    Corner(Button, 12)

    local Active = New(
        "Frame",
        {
            Position = UDim2.fromOffset(0, 8),
            Size = UDim2.fromOffset(3, 42),
            BackgroundColor3 = CONFIG.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 29,
        },
        Button
    )

    Corner(Active, 4)

    local Icon = New(
        "TextLabel",
        {
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.fromOffset(36, 58),
            BackgroundTransparency = 1,
            Text = icon,
            Font = Enum.Font.GothamBold,
            TextSize = 19,
            TextColor3 = CONFIG.Muted,
            ZIndex = 30,
        },
        Button
    )

    local Text = New(
        "TextLabel",
        {
            Position = UDim2.fromOffset(58, 0),
            Size = UDim2.new(1, -70, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = CONFIG.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 30,
        },
        Button
    )

    Button.MouseEnter:Connect(function()
        if State.CurrentPage ~= name then
            tween(Button, 0.16, {
                BackgroundTransparency = 0.25,
            })

            tween(Icon, 0.16, {
                TextColor3 = CONFIG.White,
            })

            tween(Text, 0.16, {
                TextColor3 = CONFIG.White,
            })
        end
    end)

    Button.MouseLeave:Connect(function()
        if State.CurrentPage ~= name then
            tween(Button, 0.16, {
                BackgroundTransparency = 0.55,
            })

            tween(Icon, 0.16, {
                TextColor3 = CONFIG.Muted,
            })

            tween(Text, 0.16, {
                TextColor3 = CONFIG.Muted,
            })
        end
    end)

    Button.MouseButton1Click:Connect(function()
        Ripple(Button, UserInputService:GetMouseLocation())
        State.CurrentPage = name
    end)

    Navigation[name] = {
        Button = Button,
        Active = Active,
        Icon = Icon,
        Text = Text,
    }

    return Button
end

NavButton("Music Engine", "♫", 1)
NavButton("Axolion Community", "◆", 2)

--// ============================================================
--// SIDEBAR LOWER
--// ============================================================

local SidebarInfo = New(
    "Frame",
    {
        Position = UDim2.new(0, 8, 1, -108),
        Size = UDim2.new(1, -16, 0, 92),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 27,
    },
    SidebarInner
)

Corner(SidebarInfo, 12)
Stroke(SidebarInfo, CONFIG.Border, 1, 0.72)

New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Text = "SESSION",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = CONFIG.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 28,
    },
    SidebarInfo
)

local ExecutorLabel = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(12, 30),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Text = "Executor: " .. tostring(Executor.Name),
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = CONFIG.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 28,
    },
    SidebarInfo
)

local SessionLabel = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(12, 52),
        Size = UDim2.new(1, -24, 0, 18),
        BackgroundTransparency = 1,
        Text = "Axomusc session active",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = CONFIG.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 28,
    },
    SidebarInfo
)

--// ============================================================
--// CONTENT AREA
--// ============================================================

local Workspace = New(
    "Frame",
    {
        Name = "Workspace",
        Position = UDim2.fromOffset(230, 0),
        Size = UDim2.new(1, -230, 1, 0),
        BackgroundColor3 = Color3.fromRGB(5, 8, 20),
        BackgroundTransparency = 0.16,
        BorderSizePixel = 0,
        ZIndex = 22,
        ClipsDescendants = true,
    },
    Body
)

--// ============================================================
--// TOAST SYSTEM
--// ============================================================

local ToastHolder = New(
    "Frame",
    {
        Name = "ToastHolder",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.fromOffset(330, 280),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10000,
    },
    ScreenGui
)

List(ToastHolder, Enum.FillDirection.Vertical, 8)

local function Toast(title, message)
    local toast = New(
        "Frame",
        {
            Size = UDim2.new(1, 0, 0, 68),
            BackgroundColor3 = CONFIG.Panel,
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            ZIndex = 10001,
        },
        ToastHolder
    )

    Corner(toast, 13)
    Stroke(toast, CONFIG.Border, 1, 0.35)

    local AccentBar = New(
        "Frame",
        {
            Position = UDim2.fromOffset(0, 9),
            Size = UDim2.fromOffset(3, 50),
            BackgroundColor3 = CONFIG.Accent,
            BorderSizePixel = 0,
            ZIndex = 10002,
        },
        toast
    )

    Corner(AccentBar, 4)

    New(
        "TextLabel",
        {
            Position = UDim2.fromOffset(16, 9),
            Size = UDim2.new(1, -26, 0, 20),
            BackgroundTransparency = 1,
            Text = tostring(title),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = CONFIG.White,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 10003,
        },
        toast
    )

    New(
        "TextLabel",
        {
            Position = UDim2.fromOffset(16, 31),
            Size = UDim2.new(1, -26, 0, 26),
            BackgroundTransparency = 1,
            Text = tostring(message),
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextColor3 = CONFIG.Muted,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 10003,
        },
        toast
    )

    toast.Size = UDim2.new(1, 0, 0, 0)

    tween(
        toast,
        0.25,
        {
            Size = UDim2.new(1, 0, 0, 68),
        },
        Enum.EasingStyle.Back
    )

    task.delay(3.2, function()
        if toast and toast.Parent then
            tween(
                toast,
                0.25,
                {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                }
            )

            task.delay(0.3, function()
                if toast then
                    toast:Destroy()
                end
            end)
        end
    end)
end

--// ============================================================
--// GENERIC PANEL
--// ============================================================

local function Panel(parent, position, size)
    local p = New(
        "Frame",
        {
            Position = position,
            Size = size,
            BackgroundColor3 = CONFIG.Panel,
            BackgroundTransparency = 0.06,
            BorderSizePixel = 0,
            ZIndex = 30,
        },
        parent
    )

    Corner(p, 16)
    Stroke(p, CONFIG.Border, 1, 0.5)

    return p
end

local function SectionTitle(parent, text, subtitle)
    local title = New(
        "TextLabel",
        {
            Position = UDim2.fromOffset(18, 14),
            Size = UDim2.new(1, -36, 0, 24),
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = CONFIG.White,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 35,
        },
        parent
    )

    if subtitle then
        New(
            "TextLabel",
            {
                Position = UDim2.fromOffset(18, 38),
                Size = UDim2.new(1, -36, 0, 18),
                BackgroundTransparency = 1,
                Text = subtitle,
                Font = Enum.Font.Gotham,
                TextSize = 9,
                TextColor3 = CONFIG.Muted,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 35,
            },
            parent
        )
    end

    return title
end

--// ============================================================
--// MUSIC PAGE
--// ============================================================

local MusicPage = New(
    "Frame",
    {
        Name = "MusicPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 30,
    },
    Workspace
)

--// SEARCH BAR
local SearchBar = New(
    "TextBox",
    {
        Position = UDim2.fromOffset(18, 16),
        Size = UDim2.new(1, -36, 0, 44),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        PlaceholderText = "Search Roblox Music / enter Audio ID...",
        PlaceholderColor3 = CONFIG.Dim,
        Text = "",
        TextColor3 = CONFIG.White,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ClearTextOnFocus = false,
        ZIndex = 40,
    },
    MusicPage
)

Corner(SearchBar, 12)
Stroke(SearchBar, CONFIG.Border, 1, 0.55)
Padding(SearchBar, 42, 15, 0, 0)

local SearchIcon = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.fromOffset(24, 44),
        BackgroundTransparency = 1,
        Text = "⌕",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = CONFIG.Accent,
        ZIndex = 41,
    },
    SearchBar
)

local SearchButton = New(
    "TextButton",
    {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(78, 34),
        BackgroundColor3 = CONFIG.AccentDark,
        Text = "SEARCH",
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = CONFIG.White,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 42,
    },
    SearchBar
)

Corner(SearchButton, 9)

--// ============================================================
--// THREE COLUMN MUSIC LAYOUT
--// ============================================================

local MusicBody = New(
    "Frame",
    {
        Position = UDim2.fromOffset(18, 74),
        Size = UDim2.new(1, -36, 1, -90),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 30,
    },
    MusicPage
)

--// LEFT
local FolderPanel = Panel(
    MusicBody,
    UDim2.fromOffset(0, 0),
    UDim2.new(0, 205, 1, 0)
)

SectionTitle(
    FolderPanel,
    "Audio Library",
    "Browse your saved audio"
)

local FolderSearch = New(
    "TextBox",
    {
        Position = UDim2.fromOffset(12, 68),
        Size = UDim2.new(1, -24, 0, 34),
        BackgroundColor3 = CONFIG.Black,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        PlaceholderText = "Filter library...",
        PlaceholderColor3 = CONFIG.Dim,
        Text = "",
        TextColor3 = CONFIG.White,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        ClearTextOnFocus = false,
        ZIndex = 38,
    },
    FolderPanel
)

Corner(FolderSearch, 9)
Stroke(FolderSearch, CONFIG.Border, 1, 0.75)
Padding(FolderSearch, 10, 10, 0, 0)

local FolderList = New(
    "ScrollingFrame",
    {
        Position = UDim2.fromOffset(12, 112),
        Size = UDim2.new(1, -24, 1, -124),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CONFIG.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 38,
    },
    FolderPanel
)

List(FolderList, Enum.FillDirection.Vertical, 5)

--// CENTER
local PlayerPanel = Panel(
    MusicBody,
    UDim2.fromOffset(215, 0),
    UDim2.new(0.52, -10, 1, 0)
)

SectionTitle(
    PlayerPanel,
    "Now Playing",
    "Premium playback controller"
)

local AlbumFrame = New(
    "Frame",
    {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 70),
        Size = UDim2.fromOffset(220, 220),
        BackgroundColor3 = CONFIG.Black,
        BorderSizePixel = 0,
        ZIndex = 38,
    },
    PlayerPanel
)

Corner(AlbumFrame, 18)
Stroke(AlbumFrame, CONFIG.Border, 1.5, 0.25)

local AlbumArt = New(
    "ImageLabel",
    {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        Image = CONFIG.Thumbnail,
        ScaleType = Enum.ScaleType.Crop,
        BorderSizePixel = 0,
        ZIndex = 39,
    },
    AlbumFrame
)

Corner(AlbumArt, 14)

local Visualizer = New(
    "Frame",
    {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 305),
        Size = UDim2.fromOffset(220, 32),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 40,
    },
    PlayerPanel
)

local Bars = {}

for i = 1, 24 do
    local bar = New(
        "Frame",
        {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new((i - 0.5) / 24, 0, 1, 0),
            Size = UDim2.new(0, 4, 0, math.random(5, 28)),
            BackgroundColor3 = CONFIG.Accent,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            ZIndex = 41,
        },
        Visualizer
    )

    Corner(bar, 3)
    table.insert(Bars, bar)
end

local TrackTitle = New(
    "TextLabel",
    {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 345),
        Size = UDim2.new(1, -40, 0, 26),
        BackgroundTransparency = 1,
        Text = "Nothing Playing",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = CONFIG.White,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 40,
    },
    PlayerPanel
)

local TrackSub = New(
    "TextLabel",
    {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 371),
        Size = UDim2.new(1, -40, 0, 20),
        BackgroundTransparency = 1,
        Text = "Add a Roblox Audio ID to begin",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = CONFIG.Muted,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 40,
    },
    PlayerPanel
)

--// PROGRESS
local ProgressBG = New(
    "Frame",
    {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 404),
        Size = UDim2.new(1, -44, 0, 5),
        BackgroundColor3 = CONFIG.Dim,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 40,
    },
    PlayerPanel
)

Corner(ProgressBG, 5)

local Progress = New(
    "Frame",
    {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CONFIG.Accent,
        BorderSizePixel = 0,
        ZIndex = 41,
    },
    ProgressBG
)

Corner(Progress, 5)

local TimeLabel = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(22, 414),
        Size = UDim2.fromOffset(60, 18),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.Gotham,
        TextSize = 8,
        TextColor3 = CONFIG.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 40,
    },
    PlayerPanel
)

local DurationLabel = New(
    "TextLabel",
    {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -22, 0, 414),
        Size = UDim2.fromOffset(60, 18),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.Gotham,
        TextSize = 8,
        TextColor3 = CONFIG.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 40,
    },
    PlayerPanel
)

--// ============================================================
--// PLAYER CONTROLS
--// ============================================================

local Controls = New(
    "Frame",
    {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 438),
        Size = UDim2.fromOffset(300, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 45,
    },
    PlayerPanel
)

local function ControlButton(text, size)
    local b = New(
        "TextButton",
        {
            Size = UDim2.fromOffset(size or 42, 42),
            BackgroundColor3 = CONFIG.Panel2,
            BackgroundTransparency = 0.15,
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = CONFIG.White,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 46,
        },
        Controls
    )

    Corner(b, 12)
    Stroke(b, CONFIG.Border, 1, 0.65)

    b.MouseEnter:Connect(function()
        tween(b, 0.15, {
            BackgroundColor3 = CONFIG.AccentDark,
        })
    end)

    b.MouseLeave:Connect(function()
        tween(b, 0.15, {
            BackgroundColor3 = CONFIG.Panel2,
        })
    end)

    b.MouseButton1Click:Connect(function()
        Ripple(b, UserInputService:GetMouseLocation())
    end)

    return b
end

local ShuffleButton = ControlButton("⤨")
ShuffleButton.Position = UDim2.fromOffset(0, 0)

local PreviousButton = ControlButton("◀")
PreviousButton.Position = UDim2.fromOffset(48, 0)

local PlayButton = ControlButton("▶", 52)
PlayButton.Position = UDim2.fromOffset(101, -5)
PlayButton.BackgroundColor3 = CONFIG.AccentDark
PlayButton.TextSize = 19

local NextButton = ControlButton("▶")
NextButton.Position = UDim2.fromOffset(161, 0)

local RepeatButton = ControlButton("↻")
RepeatButton.Position = UDim2.fromOffset(209, 0)

--// ============================================================
--// VOLUME + SPEED
--// ============================================================

local VolumeLabel = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(22, 495),
        Size = UDim2.fromOffset(70, 18),
        BackgroundTransparency = 1,
        Text = "VOLUME  " .. State.Volume .. "%",
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = CONFIG.Muted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 45,
    },
    PlayerPanel
)

local VolumeBG = New(
    "Frame",
    {
        Position = UDim2.fromOffset(22, 518),
        Size = UDim2.new(0.5, -32, 0, 6),
        BackgroundColor3 = CONFIG.Dim,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 45,
    },
    PlayerPanel
)

Corner(VolumeBG, 5)

local VolumeFill = New(
    "Frame",
    {
        Size = UDim2.new(State.Volume / 100, 0, 1, 0),
        BackgroundColor3 = CONFIG.Accent,
        BorderSizePixel = 0,
        ZIndex = 46,
    },
    VolumeBG
)

Corner(VolumeFill, 5)

local VolumeHit = New(
    "TextButton",
    {
        Position = UDim2.fromOffset(22, 508),
        Size = UDim2.new(0.5, -32, 0, 25),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 50,
    },
    PlayerPanel
)

local SpeedLabel = New(
    "TextLabel",
    {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -22, 0, 495),
        Size = UDim2.fromOffset(90, 18),
        BackgroundTransparency = 1,
        Text = "SPEED  " .. State.Speed .. "x",
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = CONFIG.Muted,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 45,
    },
    PlayerPanel
)

local SpeedHolder = New(
    "Frame",
    {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -22, 0, 516),
        Size = UDim2.fromOffset(170, 24),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 46,
    },
    PlayerPanel
)

List(SpeedHolder, Enum.FillDirection.Horizontal, 5)

local SpeedButtons = {}

for _, speed in ipairs({0.5, 1, 1.5, 2}) do
    local b = New(
        "TextButton",
        {
            Size = UDim2.fromOffset(38, 22),
            BackgroundColor3 = speed == 1 and CONFIG.AccentDark or CONFIG.Panel2,
            BackgroundTransparency = 0.1,
            Text = tostring(speed) .. "x",
            Font = Enum.Font.GothamBold,
            TextSize = 8,
            TextColor3 = CONFIG.White,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            LayoutOrder = speed * 10,
            ZIndex = 47,
        },
        SpeedHolder
    )

    Corner(b, 7)
    table.insert(SpeedButtons, {Button = b, Speed = speed})
end

--// ============================================================
--// RIGHT PLAYLIST PANEL
--// ============================================================

local PlaylistPanel = Panel(
    MusicBody,
    UDim2.new(0.52, 0, 0, 0),
    UDim2.new(0.48, 0, 1, 0)
)

SectionTitle(
    PlaylistPanel,
    "Playlist",
    "Queue and saved tracks"
)

local AddTrackButton = New(
    "TextButton",
    {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 15),
        Size = UDim2.fromOffset(90, 30),
        BackgroundColor3 = CONFIG.AccentDark,
        Text = "+ ADD ID",
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = CONFIG.White,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 40,
    },
    PlaylistPanel
)

Corner(AddTrackButton, 8)

local PlaylistSearch = New(
    "TextBox",
    {
        Position = UDim2.fromOffset(14, 68),
        Size = UDim2.new(1, -28, 0, 34),
        BackgroundColor3 = CONFIG.Black,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        PlaceholderText = "Search playlist...",
        PlaceholderColor3 = CONFIG.Dim,
        Text = "",
        TextColor3 = CONFIG.White,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        ClearTextOnFocus = false,
        ZIndex = 40,
    },
    PlaylistPanel
)

Corner(PlaylistSearch, 9)
Stroke(PlaylistSearch, CONFIG.Border, 1, 0.75)
Padding(PlaylistSearch, 10, 10, 0, 0)

local PlaylistList = New(
    "ScrollingFrame",
    {
        Position = UDim2.fromOffset(14, 112),
        Size = UDim2.new(1, -28, 1, -126),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CONFIG.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 40,
    },
    PlaylistPanel
)

List(PlaylistList, Enum.FillDirection.Vertical, 6)

--// ============================================================
--// COMMUNITY PAGE
--// ============================================================

local CommunityPage = New(
    "Frame",
    {
        Name = "CommunityPage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        BorderSizePixel = 0,
        ZIndex = 30,
    },
    Workspace
)

local CommunityHeader = Panel(
    CommunityPage,
    UDim2.fromOffset(20, 20),
    UDim2.new(1, -40, 0, 150)
)

local CommunityLogo = New(
    "ImageLabel",
    {
        Position = UDim2.fromOffset(20, 20),
        Size = UDim2.fromOffset(108, 108),
        BackgroundColor3 = CONFIG.Black,
        BackgroundTransparency = 0.1,
        Image = CONFIG.SubLogo,
        ScaleType = Enum.ScaleType.Fit,
        BorderSizePixel = 0,
        ZIndex = 38,
    },
    CommunityHeader
)

Corner(CommunityLogo, 16)
Stroke(CommunityLogo, CONFIG.Border, 1.2, 0.25)

New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(150, 24),
        Size = UDim2.new(1, -170, 0, 30),
        BackgroundTransparency = 1,
        Text = "Axolion Community",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = CONFIG.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 39,
    },
    CommunityHeader
)

New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(150, 57),
        Size = UDim2.new(1, -170, 0, 42),
        BackgroundTransparency = 1,
        Text = "Community hub for Axomusc, projects, updates and future Axolion systems.",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = CONFIG.Muted,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 39,
    },
    CommunityHeader
)

local CommunityStatus = New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(150, 104),
        Size = UDim2.new(1, -170, 0, 20),
        BackgroundTransparency = 1,
        Text = "● AXOLION COMMUNITY  •  ONLINE",
        Font = Enum.Font.GothamBold,
        TextSize = 8,
        TextColor3 = CONFIG.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 39,
    },
    CommunityHeader
)

--// ============================================================
--// COMMUNITY LINKS
--// ============================================================

local LinksPanel = Panel(
    CommunityPage,
    UDim2.fromOffset(20, 186),
    UDim2.new(1, -40, 0, 220)
)

SectionTitle(
    LinksPanel,
    "Community Links",
    "Copy the official Axolion destinations"
)

local function CommunityLinkCard(parent, y, title, url)
    local card = New(
        "Frame",
        {
            Position = UDim2.fromOffset(16, y),
            Size = UDim2.new(1, -32, 0, 62),
            BackgroundColor3 = CONFIG.Panel2,
            BackgroundTransparency = 0.12,
            BorderSizePixel = 0,
            ZIndex = 40,
        },
        parent
    )

    Corner(card, 11)
    Stroke(card, CONFIG.Border, 1, 0.78)

    New(
        "TextLabel",
        {
            Position = UDim2.fromOffset(14, 8),
            Size = UDim2.new(1, -120, 0, 20),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = CONFIG.White,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 41,
        },
        card
    )

    New(
        "TextLabel",
        {
            Position = UDim2.fromOffset(14, 30),
            Size = UDim2.new(1, -120, 0, 18),
            BackgroundTransparency = 1,
            Text = url,
            Font = Enum.Font.Gotham,
            TextSize = 8,
            TextColor3 = CONFIG.Muted,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 41,
        },
        card
    )

    local copy = New(
        "TextButton",
        {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(78, 32),
            BackgroundColor3 = CONFIG.AccentDark,
            Text = "COPY",
            Font = Enum.Font.GothamBold,
            TextSize = 8,
            TextColor3 = CONFIG.White,
            AutoButtonColor = false,
            BorderSizePixel = 0,
            ZIndex = 42,
        },
        card
    )

    Corner(copy, 8)

    copy.MouseButton1Click:Connect(function()
        Ripple(copy, UserInputService:GetMouseLocation())

        if Executor.HasClipboard then
            pcall(function()
                setclipboard(url)
            end)

            Toast("Link Copied", title .. " has been copied.")
        else
            Toast("Clipboard Unavailable", "Your executor does not expose setclipboard.")
        end
    end)
end

CommunityLinkCard(
    LinksPanel,
    70,
    "Discord Community",
    CONFIG.Discord
)

CommunityLinkCard(
    LinksPanel,
    140,
    "Roblox Community",
    CONFIG.Community
)

--// ============================================================
--// COMMUNITY INFO
--// ============================================================

local AboutPanel = Panel(
    CommunityPage,
    UDim2.fromOffset(20, 420),
    UDim2.new(1, -40, 0, 130)
)

SectionTitle(
    AboutPanel,
    "About Axomusc",
    "Axolion Community (Beta)"
)

New(
    "TextLabel",
    {
        Position = UDim2.fromOffset(18, 65),
        Size = UDim2.new(1, -36, 0, 52),
        BackgroundTransparency = 1,
        Text = "Axomusc is a premium Roblox music interface designed around a clean dark-blue, black, white and Tosca Green visual system. The interface is built to remain lightweight while providing library, queue, favorites, playlists and playback controls.",
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextColor3 = CONFIG.Muted,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 39,
    },
    AboutPanel
)

--// ============================================================
--// PLAYLIST DATA HELPERS
--// ============================================================

local function normalizeId(id)
    if id == nil then
        return nil
    end

    id = tostring(id)

    local number = id:match("%d+")

    if number then
        return number
    end

    return nil
end

local function findTrack(id)
    id = normalizeId(id)

    if not id then
        return nil
    end

    for _, track in ipairs(State.Library) do
        if tostring(track.Id) == id then
            return track
        end
    end

    return nil
end

local function addToLibrary(track)
    if not track or not track.Id then
        return false
    end

    if findTrack(track.Id) then
        return false
    end

    table.insert(State.Library, track)
    saveData()

    return true
end

local function isFavorite(id)
    id = normalizeId(id)

    for _, value in ipairs(State.Favorites) do
        if tostring(value) == id then
            return true
        end
    end

    return false
end

local function toggleFavorite(id)
    id = normalizeId(id)

    if not id then
        return
    end

    for index, value in ipairs(State.Favorites) do
        if tostring(value) == id then
            table.remove(State.Favorites, index)
            saveData()
            Toast("Favorite Removed", "Track removed from favorites.")
            return
        end
    end

    table.insert(State.Favorites, id)
    saveData()

    Toast("Favorite Added", "Track pinned to favorites.")
end

--// ============================================================
--// PLAYLIST RENDER
--// ============================================================

local function clearChildren(container)
    for _, child in ipairs(container:GetChildren()) do
        if not child:IsA("UIListLayout")
            and not child:IsA("UIPadding")
            and not child:IsA("UICorner")
            and not child:IsA("UIStroke") then

            child:Destroy()
        end
    end
end

local function PlayTrack(track)
    if not track or not track.Id then
        return
    end

    local id = normalizeId(track.Id)

    if not id then
        Toast("Invalid Audio ID", "The supplied ID is not valid.")
        return
    end

    if State.CurrentSound then
        pcall(function()
            State.CurrentSound:Stop()
            State.CurrentSound:Destroy()
        end)

        State.CurrentSound = nil
    end

    local sound = Instance.new("Sound")

    sound.Name = "AxomuscPlayback"
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = State.Volume / 100
    sound.PlaybackSpeed = State.Speed
    sound.Looped = State.IsRepeat
    sound.Parent = SoundService

    State.CurrentSound = sound
    State.CurrentTrack = track
    State.IsPlaying = false

    TrackTitle.Text = track.Name or ("Roblox Audio " .. id)
    TrackSub.Text = "rbxassetid://" .. id

    Toast(
        "Loading Music",
        "Loading " .. tostring(track.Name or id)
    )

    local loaded = false

    pcall(function()
        ContentProvider:PreloadAsync({sound})
        loaded = true
    end)

    if not sound.Parent then
        return
    end

    pcall(function()
        sound:Play()
    end)

    State.IsPlaying = true
    PlayButton.Text = "Ⅱ"

    if loaded then
        Toast(
            "Now Playing",
            tostring(track.Name or ("Audio " .. id))
        )
    else
        Toast(
            "Playback Started",
            "Roblox is resolving the audio asset."
        )
    end

    sound.Ended:Connect(function()
        if State.CurrentSound ~= sound then
            return
        end

        State.IsPlaying = false
        PlayButton.Text = "▶"

        if State.IsRepeat then
            task.defer(function()
                if State.CurrentSound == sound then
                    pcall(function()
                        sound:Play()
                    end)
                end
            end)
        elseif #State.Queue > 0 then
            local nextTrack = table.remove(State.Queue, 1)

            task.defer(function()
                PlayTrack(nextTrack)
                refreshPlaylist()
            end)
        end
    end)

    sound:GetPropertyChangedSignal("TimePosition"):Connect(function()
        if State.CurrentSound ~= sound then
            return
        end

        local length = sound.TimeLength

        if length > 0 then
            Progress.Size = UDim2.new(
                math.clamp(sound.TimePosition / length, 0, 1),
                0,
                1,
                0
            )

            TimeLabel.Text = string.format(
                "%d:%02d",
                math.floor(sound.TimePosition / 60),
                math.floor(sound.TimePosition % 60)
            )

            DurationLabel.Text = string.format(
                "%d:%02d",
                math.floor(length / 60),
                math.floor(length % 60)
           