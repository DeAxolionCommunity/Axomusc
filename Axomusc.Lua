--// ================================================================
--// AXOMUSC (BETA)
--// AXOLION COMMUNITY
--// PREMIUM MUSIC ENGINE
--// DELTA EXECUTOR / gethui() BUILD
--// ================================================================
--// FULL REBUILD
--// UI LAYOUT
--// CONTENT
--// MUSIC ENGINE
--// ROBLOX AUDIO ID SEARCH
--// PLAYLIST
--// FAVORITES
--// SAVE / LOAD
--// COMMUNITY
--// DRAG
--// MINIMIZE
--// KEYBIND
--// TOAST
--// RIPPLE
--// SPRING ANIMATION
--// RESPONSIVE SCALE
--// ACRYLIC GLASS
--// NO THREE-DOT MUSIC UI
--// ================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ================================================================
-- DELTA / EXECUTOR PROTECTION
-- ================================================================

local function SafeCall(fn, fallback)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return fallback
end

local function GetHUI()
    local hui = SafeCall(function()
        if type(gethui) == "function" then
            return gethui()
        end
        return nil
    end)

    if hui then
        return hui
    end

    return SafeCall(function()
        return CoreGui
    end, game:GetService("CoreGui"))
end

local HUI = GetHUI()

-- ================================================================
-- CLEAN OLD VERSION
-- ================================================================

SafeCall(function()
    local old = HUI:FindFirstChild("Axomusc_Beta")
    if old then
        old:Destroy()
    end
end)

-- ================================================================
-- COLORS
-- ================================================================

local C = {
    DarkBlue = Color3.fromRGB(5, 9, 25),
    DarkBlue2 = Color3.fromRGB(7, 13, 34),
    DarkBlue3 = Color3.fromRGB(10, 17, 42),
    DeepBlue = Color3.fromRGB(3, 6, 17),

    Tosca = Color3.fromRGB(34, 235, 214),
    Tosca2 = Color3.fromRGB(24, 184, 173),
    ToscaDark = Color3.fromRGB(11, 93, 91),

    Ice = Color3.fromRGB(155, 238, 255),

    Black = Color3.fromRGB(1, 2, 6),
    Black2 = Color3.fromRGB(4, 5, 11),

    White = Color3.fromRGB(245, 249, 255),
    White2 = Color3.fromRGB(190, 199, 215),
    Gray = Color3.fromRGB(126, 137, 157),
    Gray2 = Color3.fromRGB(79, 90, 110),

    Green = Color3.fromRGB(65, 255, 160),
    Red = Color3.fromRGB(255, 75, 95),
    Orange = Color3.fromRGB(255, 174, 70),
}

-- ================================================================
-- ASSETS
-- ================================================================

local ASSETS = {
    Logo = "rbxassetid://85647271976925",
    Thumbnail = "rbxassetid://84404991858137",
    SubLogo = "rbxassetid://100003155958609",
}

-- ================================================================
-- CONFIG
-- ================================================================

local CONFIG = {
    BaseWidth = 1080,
    BaseHeight = 650,

    MinWidth = 820,
    MinHeight = 520,

    Keybind = Enum.KeyCode.RightShift,

    DefaultVolume = 70,
    DefaultSpeed = 1,

    SaveFile = "Axomusc_Beta_Data.json",
}

-- ================================================================
-- DATA
-- ================================================================

local Data = {
    Volume = CONFIG.DefaultVolume,
    Speed = CONFIG.DefaultSpeed,

    Keybind = "RightShift",

    Repeat = false,
    Shuffle = false,

    CurrentTrack = nil,
    CurrentIndex = 0,

    Favorites = {},
    Playlist = {},

    SavedPlaylists = {
        ["Axomusc Theme"] = {},
    },

    Recent = {},

    Equalizer = {
        Bass = 50,
        Mid = 50,
        Treble = 50,
    },
}

-- ================================================================
-- EXECUTOR FILE SYSTEM
-- ================================================================

local function CanFile()
    return type(readfile) == "function"
        and type(writefile) == "function"
end

local function SaveData()
    if not CanFile() then
        return false
    end

    return SafeCall(function()
        writefile(
            CONFIG.SaveFile,
            HttpService:JSONEncode(Data)
        )
        return true
    end, false)
end

local function LoadData()
    if not CanFile() then
        return
    end

    SafeCall(function()
        if type(isfile) == "function" and not isfile(CONFIG.SaveFile) then
            return
        end

        local raw = readfile(CONFIG.SaveFile)
        if not raw or raw == "" then
            return
        end

        local decoded = HttpService:JSONDecode(raw)

        if type(decoded) == "table" then
            for k, v in pairs(decoded) do
                Data[k] = v
            end
        end
    end)
end

LoadData()

-- ================================================================
-- CLIPBOARD
-- ================================================================

local function CopyClipboard(text)
    return SafeCall(function()
        if type(setclipboard) == "function" then
            setclipboard(tostring(text))
            return true
        end

        if type(toclipboard) == "function" then
            toclipboard(tostring(text))
            return true
        end

        if type(set_clipboard) == "function" then
            set_clipboard(tostring(text))
            return true
        end

        return false
    end, false)
end

-- ================================================================
-- HTTP REQUEST SUPPORT
-- ================================================================

local function GetRequestFunction()
    if type(request) == "function" then
        return request
    end

    if type(http_request) == "function" then
        return http_request
    end

    if syn and type(syn.request) == "function" then
        return syn.request
    end

    return nil
end

local function HTTPGet(url)
    local req = GetRequestFunction()

    if not req then
        return nil
    end

    return SafeCall(function()
        local response = req({
            Url = url,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Axomusc/1.0",
            },
        })

        if response and response.StatusCode == 200 then
            return response.Body
        end

        if response and response.Body then
            return response.Body
        end

        return nil
    end)
end

-- ================================================================
-- GUI ROOT
-- ================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Axomusc_Beta"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

SafeCall(function()
    ScreenGui.Parent = HUI
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = HUI
end

-- ================================================================
-- HELPERS
-- ================================================================

local function New(className, properties, parent)
    local obj = Instance.new(className)

    for key, value in pairs(properties or {}) do
        SafeCall(function()
            obj[key] = value
        end)
    end

    if parent then
        obj.Parent = parent
    end

    return obj
end

local function Corner(obj, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius),
    }, obj)
end

local function Stroke(obj, color, thickness, transparency)
    return New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function Padding(obj, top, right, bottom, left)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, top),
        PaddingRight = UDim.new(0, right),
        PaddingBottom = UDim.new(0, bottom),
        PaddingLeft = UDim.new(0, left),
    }, obj)
end

local function Tween(obj, info, props)
    local tween = SafeCall(function()
        return TweenService:Create(obj, info, props)
    end)

    if tween then
        tween:Play()
        return tween
    end
end

local Spring = TweenInfo.new(
    0.42,
    Enum.EasingStyle.Spring,
    Enum.EasingDirection.Out,
)

local FastSpring = TweenInfo.new(
    0.26,
    Enum.EasingStyle.Spring,
    Enum.EasingDirection.Out,
)

local Quad = TweenInfo.new(
    0.25,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
)

local SlowQuad = TweenInfo.new(
    0.5,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out,
)

-- ================================================================
-- RIPPLE
-- ================================================================

local function Ripple(button, color)
    if not button then
        return
    end

    local absolute = button.AbsoluteSize

    local ripple = New("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(4, 4),
        BackgroundColor3 = color or C.Tosca,
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 10,
    }, button)

    Corner(ripple, 999)

    local maxSize = math.max(
        absolute.X,
        absolute.Y
    ) * 2.2

    Tween(
        ripple,
        TweenInfo.new(
            0.5,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.fromOffset(maxSize, maxSize),
            BackgroundTransparency = 1,
        }
    )

    task.delay(0.55, function()
        SafeCall(function()
            ripple:Destroy()
        end)
    end)
end

-- ================================================================
-- BUTTON FACTORY
-- ================================================================

local function Button(parent, text, size, position)
    local button = New("TextButton", {
        Name = "Button",
        Size = size,
        Position = position,
        BackgroundColor3 = C.Black2,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text,
        TextColor3 = C.White2,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        ClipsDescendants = true,
        ZIndex = 5,
    }, parent)

    Corner(button, 10)

    local st = Stroke(
        button,
        C.ToscaDark,
        1,
        0.25
    )

    button.MouseEnter:Connect(function()
        Tween(button, FastSpring, {
            BackgroundColor3 = C.DarkBlue3,
        })

        Tween(st, FastSpring, {
            Color = C.Tosca,
            Transparency = 0,
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, FastSpring, {
            BackgroundColor3 = C.Black2,
        })

        Tween(st, FastSpring, {
            Color = C.ToscaDark,
            Transparency = 0.25,
        })
    end)

    button.MouseButton1Click:Connect(function()
        Ripple(button)
    end)

    return button
end

-- ================================================================
-- TOAST SYSTEM
-- ================================================================

local ToastContainer = New("Frame", {
    Name = "ToastContainer",
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -24, 1, -24),
    Size = UDim2.fromOffset(330, 300),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 10000,
}, ScreenGui)

New("UIListLayout", {
    Padding = UDim.new(0, 10),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
}, ToastContainer)

local function Toast(title, message, duration)
    duration = duration or 2.8

    local card = New("Frame", {
        Size = UDim2.fromOffset(310, 72),
        BackgroundColor3 = C.DarkBlue,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ZIndex = 10001,
    }, ToastContainer)

    Corner(card, 14)
    Stroke(card, C.Tosca, 1, 0.18)

    local bar = New("Frame", {
        Size = UDim2.new(0, 3, 1, -20),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = C.Tosca,
        BorderSizePixel = 0,
        ZIndex = 10002,
    }, card)

    Corner(bar, 5)

    New("TextLabel", {
        Size = UDim2.new(1, -45, 0, 24),
        Position = UDim2.fromOffset(27, 9),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.White,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10002,
    }, card)

    New("TextLabel", {
        Size = UDim2.new(1, -45, 0, 32),
        Position = UDim2.fromOffset(27, 32),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = C.Gray,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10002,
    }, card)

    card.Position = UDim2.new(
        1,
        350,
        0,
        0
    )

    Tween(card, Spring, {
        Position = UDim2.new(0, 0, 0, 0),
    })

    task.delay(duration, function()
        Tween(card, Quad, {
            Position = UDim2.new(
                1,
                350,
                0,
                0
            ),
        })

        task.wait(0.3)

        SafeCall(function()
            card:Destroy()
        end)
    end)
end

-- ================================================================
-- GLOBAL SCALE
-- ================================================================

local MainScale = New("UIScale", {
    Scale = 1,
}, ScreenGui)

local function UpdateScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local scaleX = viewport.X / CONFIG.BaseWidth
    local scaleY = viewport.Y / CONFIG.BaseHeight

    local scale = math.min(scaleX, scaleY)

    scale = math.clamp(scale, 0.42, 1.05)

    MainScale.Scale = scale
end

UpdateScale()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.wait(0.1)
    UpdateScale()
end)

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera

    if camera then
        local viewport = camera.ViewportSize
        local scale = math.min(
            viewport.X / CONFIG.BaseWidth,
            viewport.Y / CONFIG.BaseHeight
        )

        MainScale.Scale = math.clamp(scale, 0.42, 1.05)
    end
end)

-- ================================================================
-- MINIMIZE BUBBLE
-- ================================================================

local Bubble = New("TextButton", {
    Name = "AxomuscBubble",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.06, 0.5),
    Size = UDim2.fromOffset(62, 62),
    BackgroundColor3 = C.DarkBlue,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    Visible = false,
    ZIndex = 9000,
}, ScreenGui)

Corner(Bubble, 999)
Stroke(Bubble, C.Tosca, 2, 0.1)

New("ImageLabel", {
    Size = UDim2.fromScale(0.65, 0.65),
    Position = UDim2.fromScale(0.175, 0.175),
    BackgroundTransparency = 1,
    Image = ASSETS.Logo,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 9001,
}, Bubble)

-- ================================================================
-- MAIN WINDOW
-- ================================================================

local Main = New("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(
        CONFIG.BaseWidth,
        CONFIG.BaseHeight
    ),
    BackgroundColor3 = C.DarkBlue,
    BackgroundTransparency = 0.035,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 10,
}, ScreenGui)

Corner(Main, 18)
Stroke(Main, C.Tosca, 1.5, 0.05)

-- ================================================================
-- ACRYLIC BACKGROUND
-- ================================================================

local Acrylic = New("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = C.DarkBlue,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    ZIndex = 10,
}, Main)

Corner(Acrylic, 18)

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.DarkBlue3),
        ColorSequenceKeypoint.new(0.45, C.DarkBlue),
        ColorSequenceKeypoint.new(1, C.DeepBlue),
    }),
    Rotation = 25,
}, Acrylic)

-- ================================================================
-- TOP HEADER
-- ================================================================

local Header = New("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 78),
    BackgroundColor3 = C.Black,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 20,
}, Main)

New("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = C.Tosca,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    ZIndex = 22,
}, Header)

-- Logo

local HeaderLogo = New("ImageLabel", {
    Name = "Logo",
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.fromOffset(18, 15),
    BackgroundColor3 = C.Black2,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    Image = ASSETS.Logo,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 25,
}, Header)

Corner(HeaderLogo, 12)
Stroke(HeaderLogo, C.ToscaDark, 1, 0.15)

New("TextLabel", {
    Size = UDim2.fromOffset(260, 28),
    Position = UDim2.fromOffset(78, 14),
    BackgroundTransparency = 1,
    Text = "Axomusc",
    TextColor3 = C.Ice,
    TextSize = 21,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 25,
}, Header)

local BetaBadge = New("TextLabel", {
    Size = UDim2.fromOffset(46, 20),
    Position = UDim2.fromOffset(168, 18),
    BackgroundColor3 = C.ToscaDark,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Text = "BETA",
    TextColor3 = C.Tosca,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    ZIndex = 26,
}, Header)

Corner(BetaBadge, 6)

New("TextLabel", {
    Size = UDim2.fromOffset(300, 18),
    Position = UDim2.fromOffset(79, 42),
    BackgroundTransparency = 1,
    Text = "By. Axolion Community (Beta)",
    TextColor3 = C.Gray,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 25,
}, Header)

-- Header status

local StatusDot = New("Frame", {
    Size = UDim2.fromOffset(7, 7),
    Position = UDim2.new(1, -180, 0.5, -3),
    BackgroundColor3 = C.Green,
    BorderSizePixel = 0,
    ZIndex = 25,
}, Header)

Corner(StatusDot, 999)

New("TextLabel", {
    Size = UDim2.fromOffset(120, 20),
    Position = UDim2.new(1, -165, 0.5, -10),
    BackgroundTransparency = 1,
    Text = "SESSION ACTIVE",
    TextColor3 = C.Gray,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 25,
}, Header)

local CloseButton = Button(
    Header,
    "×",
    UDim2.fromOffset(46, 46),
    UDim2.new(1, -60, 0.5, -23)
)

CloseButton.TextSize = 25
CloseButton.TextColor3 = C.White

-- ================================================================
-- BODY
-- ================================================================

local Body = New("Frame", {
    Name = "Body",
    Size = UDim2.new(1, 0, 1, -78),
    Position = UDim2.fromOffset(0, 78),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 20,
}, Main)

-- ================================================================
-- SIDEBAR
-- ================================================================

local Sidebar = New("Frame", {
    Name = "Sidebar",
    Size = UDim2.fromOffset(205, 572),
    Position = UDim2.fromOffset(0, 0),
    BackgroundColor3 = C.Black,
    BackgroundTransparency = 0.13,
    BorderSizePixel = 0,
    ZIndex = 30,
}, Body)

New("Frame", {
    Size = UDim2.fromOffset(1, 572),
    Position = UDim2.new(1, -1, 0, 0),
    BackgroundColor3 = C.Tosca,
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
    ZIndex = 35,
}, Sidebar)

local SideTop = New("Frame", {
    Size = UDim2.new(1, 0, 0, 85),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 31,
}, Sidebar)

local SideMenuButton = Button(
    SideTop,
    "☰",
    UDim2.fromOffset(45, 45),
    UDim2.fromOffset(17, 19)
)

SideMenuButton.TextSize = 22

local SideTitle = New("TextLabel", {
    Size = UDim2.fromOffset(125, 24),
    Position = UDim2.fromOffset(74, 20),
    BackgroundTransparency = 1,
    Text = "WORKSPACE",
    TextColor3 = C.White,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
}, SideTop)

New("TextLabel", {
    Size = UDim2.fromOffset(125, 18),
    Position = UDim2.fromOffset(74, 43),
    BackgroundTransparency = 1,
    Text = "Axomusc Engine",
    TextColor3 = C.Gray,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
}, SideTop)

local NavHolder = New("Frame", {
    Size = UDim2.new(1, -20, 0, 250),
    Position = UDim2.fromOffset(10, 90),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 31,
}, Sidebar)

New("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "MAIN",
    TextColor3 = C.Gray2,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
}, NavHolder)

local MusicNav = Button(
    NavHolder,
    "♫    Music Engine",
    UDim2.new(1, 0, 0, 50),
    UDim2.fromOffset(0, 28)
)

MusicNav.TextXAlignment = Enum.TextXAlignment.Left
Padding(MusicNav, 0, 10, 0, 17)

local CommunityNav = Button(
    NavHolder,
    "◆    Axolion Community",
    UDim2.new(1, 0, 0, 50),
    UDim2.fromOffset(0, 86)
)

CommunityNav.TextXAlignment = Enum.TextXAlignment.Left
Padding(CommunityNav, 0, 10, 0, 17)

local NavIndicator = New("Frame", {
    Size = UDim2.fromOffset(3, 36),
    Position = UDim2.fromOffset(2, 35),
    BackgroundColor3 = C.Tosca,
    BorderSizePixel = 0,
    ZIndex = 35,
}, NavHolder)

Corner(NavIndicator, 5)

-- Sidebar bottom

local SideBottom = New("Frame", {
    Size = UDim2.new(1, -24, 0, 130),
    Position = UDim2.new(0, 12, 1, -145),
    BackgroundColor3 = C.DarkBlue2,
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ZIndex = 31,
}, Sidebar)

Corner(SideBottom, 14)
Stroke(SideBottom, C.ToscaDark, 1, 0.35)

New("ImageLabel", {
    Size = UDim2.fromOffset(38, 38),
    Position = UDim2.fromOffset(12, 12),
    BackgroundTransparency = 1,
    Image = ASSETS.SubLogo,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 32,
}, SideBottom)

New("TextLabel", {
    Size = UDim2.new(1, -65, 0, 22),
    Position = UDim2.fromOffset(58, 11),
    BackgroundTransparency = 1,
    Text = "Axolion Community",
    TextColor3 = C.White,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
}, SideBottom)

New("TextLabel", {
    Size = UDim2.new(1, -24, 0, 35),
    Position = UDim2.fromOffset(12, 55),
    BackgroundTransparency = 1,
    Text = "Premium music interface\nfor the Axolion ecosystem.",
    TextColor3 = C.Gray,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
}, SideBottom)

-- ================================================================
-- WORKSPACE
-- ================================================================

local Workspace = New("Frame", {
    Name = "Workspace",
    Size = UDim2.new(1, -205, 1, 0),
    Position = UDim2.fromOffset(205, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 30,
}, Body)

-- ================================================================
-- MUSIC PAGE
-- ================================================================

local MusicPage = New("Frame", {
    Name = "MusicPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 40,
}, Workspace)

-- ================================================================
-- MUSIC PAGE HEADER
-- ================================================================

local MusicPageHeader = New("Frame", {
    Size = UDim2.new(1, -36, 0, 60),
    Position = UDim2.fromOffset(18, 14),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 41,
}, MusicPage)

New("TextLabel", {
    Size = UDim2.fromOffset(250, 28),
    Position = UDim2.fromOffset(0, 3),
    BackgroundTransparency = 1,
    Text = "Music Engine",
    TextColor3 = C.White,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42,
}, MusicPageHeader)

New("TextLabel", {
    Size = UDim2.fromOffset(300, 18),
    Position = UDim2.fromOffset(0, 34),
    BackgroundTransparency = 1,
    Text = "Search, organize and control your Roblox audio.",
    TextColor3 = C.Gray,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42,
}, MusicPageHeader)

-- ================================================================
-- AUDIO SEARCH
-- ================================================================

local SearchBox = New("TextBox", {
    Size = UDim2.fromOffset(245, 38),
    Position = UDim2.new(1, -350, 0, 7),
    BackgroundColor3 = C.Black2,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    PlaceholderText = "Roblox Music ID / keyword",
    PlaceholderColor3 = C.Gray2,
    Text = "",
    TextColor3 = C.White,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    ZIndex = 45,
}, MusicPageHeader)

Corner(SearchBox, 10)
Stroke(SearchBox, C.ToscaDark, 1, 0.15)
Padding(SearchBox, 0, 10, 0, 12)

local SearchButton = Button(
    MusicPageHeader,
    "SEARCH",
    UDim2.fromOffset(85, 38),
    UDim2.new(1, -95, 0, 7)
)

SearchButton.TextSize = 10
SearchButton.TextColor3 = C.Tosca

-- ================================================================
-- THREE COLUMN MUSIC LAYOUT
-- ================================================================

local LibraryPanel = New("Frame", {
    Name = "LibraryPanel",
    Size = UDim2.fromOffset(205, 472),
    Position = UDim2.fromOffset(18, 76),
    BackgroundColor3 = C.Black,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    ZIndex = 42,
}, MusicPage)

Corner(LibraryPanel, 15)
Stroke(LibraryPanel, C.ToscaDark, 1, 0.25)

local CenterPanel = New("Frame", {
    Name = "CenterPanel",
    Size = UDim2.fromOffset(340, 472),
    Position = UDim2.fromOffset(233, 76),
    BackgroundColor3 = C.DarkBlue2,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 42,
}, MusicPage)

Corner(CenterPanel, 15)
Stroke(CenterPanel, C.ToscaDark, 1, 0.25)

local PlaylistPanel = New("Frame", {
    Name = "PlaylistPanel",
    Size = UDim2.fromOffset(250, 472),
    Position = UDim2.new(1, -268, 0, 76),
    BackgroundColor3 = C.Black,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    ZIndex = 42,
}, MusicPage)

Corner(PlaylistPanel, 15)
Stroke(PlaylistPanel, C.ToscaDark, 1, 0.25)

-- ================================================================
-- LIBRARY
-- ================================================================

New("TextLabel", {
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.fromOffset(14, 14),
    BackgroundTransparency = 1,
    Text = "AUDIO LIBRARY",
    TextColor3 = C.White,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 43,
}, LibraryPanel)

New("TextLabel", {
    Size = UDim2.new(1, -28, 0, 18),
    Position = UDim2.fromOffset(14, 37),
    BackgroundTransparency = 1,
    Text = "Folders & collections",
    TextColor3 = C.Gray,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 43,
}, LibraryPanel)

local FolderSearch = New("TextBox", {
    Size = UDim2.new(1, -28, 0, 34),
    Position = UDim2.fromOffset(14, 64),
    BackgroundColor3 = C.DarkBlue2,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    PlaceholderText = "Search folder...",
    PlaceholderColor3 = C.Gray2,
    Text = "",
    TextColor3 = C.White,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    ZIndex = 44,
}, LibraryPanel)

Corner(FolderSearch, 9)
Stroke(FolderSearch, C.ToscaDark, 1, 0.3)
Padding(FolderSearch, 0, 8, 0, 10)

local FolderList = New("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -115),
    Position = UDim2.fromOffset(10, 108),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.Tosca,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 44,
}, LibraryPanel)

New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, FolderList)

Padding(FolderList, 0, 3, 10, 3)

local function FolderButton(name, icon)
    local btn = Button(
        FolderList,
        icon .. "   " .. name,
        UDim2.new(1, -6, 0, 43),
        UDim2.new()
    )

    btn.TextXAlignment = Enum.TextXAlignment.Left
    Padding(btn, 0, 8, 0, 12)

    return btn
end

local FolderButtons = {}

FolderButtons.All = FolderButton(
    "All Audio",
    "♫"
)

FolderButtons.My = FolderButton(
    "My Creations",
    "◆"
)

FolderButtons.System = FolderButton(
    "System Audio",
    "▣"
)

FolderButtons.Favorites = FolderButton(
    "Favorites",
    "★"
)

FolderButtons.Recent = FolderButton(
    "Recently Used",
    "◷"
)

-- ================================================================
-- CENTER PLAYER
-- ================================================================

New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 18),
    Position = UDim2.fromOffset(15, 13),
    BackgroundTransparency = 1,
    Text = "NOW PLAYING",
    TextColor3 = C.Tosca,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 44,
}, CenterPanel)

local Album = New("ImageLabel", {
    Size = UDim2.fromOffset(205, 205),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 38),
    BackgroundColor3 = C.Black,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Image = ASSETS.Thumbnail,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 45,
}, CenterPanel)

Corner(Album, 20)
Stroke(Album, C.Tosca, 1.5, 0.12)

local AlbumGlow = New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 28, 48)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 9, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 53, 52)),
    }),
    Rotation = 45,
}, Album)

-- Visualizer bars

local Visualizer = New("Frame", {
    Size = UDim2.fromOffset(240, 35),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 254),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 46,
}, CenterPanel)

local Bars = {}

for i = 1, 28 do
    local bar = New("Frame", {
        Size = UDim2.fromOffset(5, math.random(5, 22)),
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(
            (i - 1) / 28,
            0,
            1,
            0
        ),
        BackgroundColor3 = C.Tosca,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 47,
    }, Visualizer)

    Corner(bar, 4)

    Bars[i] = bar
end

local CurrentTitle = New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 27),
    Position = UDim2.fromOffset(15, 295),
    BackgroundTransparency = 1,
    Text = "No Audio Loaded",
    TextColor3 = C.White,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 45,
}, CenterPanel)

local CurrentID = New("TextLabel", {
    Size = UDim2.new(1, -30, 0, 18),
    Position = UDim2.fromOffset(15, 321),
    BackgroundTransparency = 1,
    Text = "Enter a Roblox Audio ID to begin",
    TextColor3 = C.Gray,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 45,
}, CenterPanel)

-- ================================================================
-- PROGRESS
-- ================================================================

local ProgressBack = New("Frame", {
    Size = UDim2.new(1, -42, 0, 5),
    Position = UDim2.fromOffset(21, 350),
    BackgroundColor3 = C.Black,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 45,
}, CenterPanel)

Corner(ProgressBack, 10)

local Progress = New("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = C.Tosca,
    BorderSizePixel = 0,
    ZIndex = 46,
}, ProgressBack)

Corner(Progress, 10)

local TimeLabel = New("TextLabel", {
    Size = UDim2.new(1, -42, 0, 17),
    Position = UDim2.fromOffset(21, 358),
    BackgroundTransparency = 1,
    Text = "00:00 / 00:00",
    TextColor3 = C.Gray,
    TextSize = 8,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 45,
}, CenterPanel)

-- ================================================================
-- PLAYER CONTROLS
-- ================================================================

local Controls = New("Frame", {
    Size = UDim2.fromOffset(310, 48),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 383),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 46,
}, CenterPanel)

local RepeatButton = Button(
    Controls,
    "↻",
    UDim2.fromOffset(38, 38),
    UDim2.fromOffset(0, 5)
)

local ShuffleButton = Button(
    Controls,
    "⤨",
    UDim2.fromOffset(38, 38),
    UDim2.fromOffset(43, 5)
)

local BackButton = Button(
    Controls,
    "‹",
    UDim2.fromOffset(40, 40),
    UDim2.fromOffset(88, 4)
)

BackButton.TextSize = 24

local PlayButton = Button(
    Controls,
    "▶",
    UDim2.fromOffset(52, 52),
    UDim2.fromOffset(137, -2)
)

PlayButton.TextSize = 19
PlayButton.BackgroundColor3 = C.ToscaDark
PlayButton.TextColor3 = C.White

local NextButton = Button(
    Controls,
    "›",
    UDim2.fromOffset(40, 40),
    UDim2.fromOffset(195, 4)
)

NextButton.TextSize = 24

local SpeedButton = Button(
    Controls,
    "1.0x",
    UDim2.fromOffset(54, 38),
    UDim2.fromOffset(243, 5)
)

SpeedButton.TextSize = 9

-- ================================================================
-- VOLUME
-- ================================================================

local VolumeLabel = New("TextLabel", {
    Size = UDim2.fromOffset(55, 18),
    Position = UDim2.fromOffset(15, 438),
    BackgroundTransparency = 1,
    Text = "VOLUME",
    TextColor3 = C.Gray,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 45,
}, CenterPanel)

local VolumeValue = New("TextLabel", {
    Size = UDim2.fromOffset(45, 18),
    Position = UDim2.new(1, -60, 0, 438),
    BackgroundTransparency = 1,
    Text = tostring(Data.Volume) .. "%",
    TextColor3 = C.Tosca,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 45,
}, CenterPanel)

local VolumeBack = New("Frame", {
    Size = UDim2.new(1, -30, 0, 6),
    Position = UDim2.fromOffset(15, 460),
    BackgroundColor3 = C.Black,
    BorderSizePixel = 0,
    ZIndex = 45,
}, CenterPanel)

Corner(VolumeBack, 10)

local VolumeFill = New("Frame", {
    Size = UDim2.fromScale(Data.Volume / 100, 1),
    BackgroundColor3 = C.Tosca,
    BorderSizePixel = 0,
    ZIndex = 46,
}, VolumeBack)

Corner(VolumeFill, 10)

local VolumeKnob = New("Frame", {
    Size = UDim2.fromOffset(13, 13),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(Data.Volume / 100, 0.5),
    BackgroundColor3 = C.White,
    BorderSizePixel = 0,
    ZIndex = 47,
}, VolumeBack)

Corner(VolumeKnob, 999)

-- ================================================================
-- PLAYLIST PANEL
-- ================================================================

New("TextLabel", {
    Size = UDim2.new(1, -28, 0, 24),
    Position = UDim2.fromOffset(14, 14),
    BackgroundTransparency = 1,
    Text = "CURRENT PLAYLIST",
    TextColor3 = C.White,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 43,
}, PlaylistPanel)

New("TextLabel", {
    Size = UDim2.new(1, -28, 0, 18),
    Position = UDim2.fromOffset(14, 38),
    BackgroundTransparency = 1,
    Text = "Your selected audio queue",
    TextColor3 = C.Gray,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 43,
}, PlaylistPanel)

local AddPlaylist = Button(
    PlaylistPanel,
    "+  ADD TO PLAYLIST",
    UDim2.new(1, -28, 0, 37),
    UDim2.fromOffset(14, 65)
)

AddPlaylist.TextSize = 9
AddPlaylist.TextColor3 = C.Tosca

local PlaylistList = New("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -120),
    Position = UDim2.fromOffset(10, 112),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.Tosca,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 44,
}, PlaylistPanel)

New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, PlaylistList)

Padding(PlaylistList, 0, 3, 10, 3)

-- ================================================================
-- COMMUNITY PAGE
-- ================================================================

local CommunityPage = New("Frame", {
    Name = "CommunityPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 50,
}, Workspace)

local CommunityHeader = New("Frame", {
    Size = UDim2.new(1, -36, 0, 82),
    Position = UDim2.fromOffset(18, 12),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 51,
}, CommunityPage)

local CommunityLogo = New("ImageLabel", {
    Size = UDim2.fromOffset(65, 65),
    Position = UDim2.fromOffset(0, 5),
    BackgroundColor3 = C.Black,
    BorderSizePixel = 0,
    Image = ASSETS.SubLogo,
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 52,
}, CommunityHeader)

Corner(CommunityLogo, 15)
Stroke(CommunityLogo, C.Tosca, 1.5, 0.2)

New("TextLabel", {
    Size = UDim2.fromOffset(350, 30),
    Position = UDim2.fromOffset(80, 8),
    BackgroundTransparency = 1,
    Text = "Axolion Community",
    TextColor3 = C.Ice,
    TextSize = 21,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 52,
}, CommunityHeader)

New("TextLabel", {
    Size = UDim2.fromOffset(400, 22),
    Position = UDim2.fromOffset(80, 40),
    BackgroundTransparency = 1,
    Text = "Community hub • Axomusc ecosystem",
    TextColor3 = C.Gray,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 52,
}, CommunityHeader)

local CommunityCard = New("Frame", {
    Size = UDim2.new(1, -36, 0, 205),
    Position = UDim2.fromOffset(18, 105),
    BackgroundColor3 = C.Black,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 52,
}, CommunityPage)

Corner(CommunityCard, 18)
Stroke(CommunityCard, C.Tosca, 1.2, 0.15)

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.DarkBlue3),
        ColorSequenceKeypoint.new(1, C.DeepBlue),
    }),
    Rotation = 15,
}, CommunityCard)

New("TextLabel", {
    Size = UDim2.new(1, -40, 0, 30),
    Position = UDim2.fromOffset(20, 18),
    BackgroundTransparency = 1,
    Text = "Welcome to Axolion Community",
    TextColor3 = C.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, CommunityCard)

New("TextLabel", {
    Size = UDim2.new(1, -40, 0, 55),
    Position = UDim2.fromOffset(20, 53),
    BackgroundTransparency = 1,
    Text = "Axomusc is a premium music interface developed under Axolion Community (Beta). Explore the music engine, organize your Roblox audio and connect with the community.",
    TextColor3 = C.Gray,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, CommunityCard)

-- ================================================================
-- DISCORD
-- ================================================================

local DiscordCard = New("Frame", {
    Size = UDim2.new(1, -36, 0, 95),
    Position = UDim2.fromOffset(18, 325),
    BackgroundColor3 = C.DarkBlue2,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 52,
}, CommunityPage)

Corner(DiscordCard, 14)
Stroke(DiscordCard, C.ToscaDark, 1, 0.2)

New("TextLabel", {
    Size = UDim2.fromOffset(110, 20),
    Position = UDim2.fromOffset(16, 12),
    BackgroundTransparency = 1,
    Text = "DISCORD",
    TextColor3 = C.Tosca,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, DiscordCard)

New("TextLabel", {
    Size = UDim2.new(1, -160, 0, 30),
    Position = UDim2.fromOffset(16, 35),
    BackgroundTransparency = 1,
    Text = "https://discord.gg/dkuXRcS2hY",
    TextColor3 = C.White,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, DiscordCard)

local DiscordCopy = Button(
    DiscordCard,
    "COPY LINK",
    UDim2.fromOffset(105, 38),
    UDim2.new(1, -120, 0, 29)
)

DiscordCopy.TextSize = 9

-- ================================================================
-- COMMUNITY LINK
-- ================================================================

local RobloxCard = New("Frame", {
    Size = UDim2.new(1, -36, 0, 95),
    Position = UDim2.fromOffset(18, 430),
    BackgroundColor3 = C.DarkBlue2,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 52,
}, CommunityPage)

Corner(RobloxCard, 14)
Stroke(RobloxCard, C.ToscaDark, 1, 0.2)

New("TextLabel", {
    Size = UDim2.fromOffset(150, 20),
    Position = UDim2.fromOffset(16, 12),
    BackgroundTransparency = 1,
    Text = "ROBLOX COMMUNITY",
    TextColor3 = C.Tosca,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, RobloxCard)

New("TextLabel", {
    Size = UDim2.new(1, -160, 0, 30),
    Position = UDim2.fromOffset(16, 35),
    BackgroundTransparency = 1,
    Text = "roblox.com/share/g/245953568",
    TextColor3 = C.White,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 53,
}, RobloxCard)

local RobloxCopy = Button(
    RobloxCard,
    "COPY LINK",
    UDim2.fromOffset(105, 38),
    UDim2.new(1, -120, 0, 29)
)

RobloxCopy.TextSize = 9

-- ================================================================
-- COMMUNITY BUTTONS
-- ================================================================

DiscordCopy.MouseButton1Click:Connect(function()
    local ok = CopyClipboard(
        "https://discord.gg/dkuXRcS2hY"
    )

    if ok then
        Toast(
            "LINK COPIED",
            "Discord invitation copied to clipboard.",
            2.5
        )
    else
        Toast(
            "CLIPBOARD UNAVAILABLE",
            "Clipboard API is not available in this executor.",
            3
        )
    end
end)

RobloxCopy.MouseButton1Click:Connect(function()
    local ok = CopyClipboard(
        "https://www.roblox.com/share/g/245953568"
    )

    if ok then
        Toast(
            "LINK COPIED",
            "Roblox community link copied.",
            2.5
        )
    else
        Toast(
            "CLIPBOARD UNAVAILABLE",
            "Clipboard API is not available in this executor.",
            3
        )
    end
end)

-- ================================================================
-- AUDIO ENGINE
-- ================================================================

local MusicSound = New("Sound", {
    Name = "AxomuscPlayer",
    Volume = Data.Volume / 100,
    PlaybackSpeed = Data.Speed,
    Looped = false,
    SoundId = "",
}, SoundService)

local CurrentFolder = "All Audio"

local function FormatTime(seconds)
    seconds = tonumber(seconds) or 0

    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)

    return string.format(
        "%02d:%02d",
        minutes,
        secs
    )
end

local function NormalizeID(value)
    value = tostring(value or "")

    local id = value:match(
        "[?&]id=(%d+)"
    )

    if id then
        return id
    end

    id = value:match(
        "rbxassetid://(%d+)"
    )

    if id then
        return id
    end

    id = value:match(
        "/asset/?id=(%d+)"
    )

    if id then
        return id
    end

    id = value:match(
        "(%d+)"
    )

    return id
end

-- ================================================================
-- METADATA
-- ================================================================

local function GetAssetInfo(id)
    id = NormalizeID(id)

    if not id then
        return nil
    end

    return SafeCall(function()
        local info = MarketplaceService:GetProductInfo(
            tonumber(id),
            Enum.InfoType.Asset
        )

        if info then
            return {
                ID = id,
                Name = info.Name or ("Audio " .. id),
                Description = info.Description or "",
                AssetTypeId = info.AssetTypeId,
                Creator = info.Creator and info.Creator.Name or "Unknown",
            }
        end

        return nil
    end)
end

-- ================================================================
-- DATA HELPERS
-- ================================================================

local function TrackExists(list, id)
    for _, track in ipairs(list) do
        if tostring(track.ID) == tostring(id) then
            return true
        end
    end

    return false
end

local function AddFavorite(track)
    if not track then
        return
    end

    if not TrackExists(Data.Favorites, track.ID) then
        table.insert(Data.Favorites, track)
        SaveData()

        Toast(
            "FAVORITE ADDED",
            track.Name,
            2
        )
    else
        for i, item in ipairs(Data.Favorites) do
            if tostring(item.ID) == tostring(track.ID) then
                table.remove(Data.Favorites, i)
                break
            end
        end

        SaveData()

        Toast(
            "FAVORITE REMOVED",
            track.Name,
            2
        )
    end
end

local function AddRecent(track)
    if not track then
        return
    end

    for i = #Data.Recent, 1, -1 do
        if tostring(Data.Recent[i].ID) == tostring(track.ID) then
            table.remove(Data.Recent, i)
        end
    end

    table.insert(Data.Recent, 1, track)

    while #Data.Recent > 20 do
        table.remove(Data.Recent)
    end

    SaveData()
end

local function AddPlaylistTrack(track)
    if not track then
        return
    end

    if TrackExists(Data.Playlist, track.ID) then
        Toast(
            "ALREADY IN PLAYLIST",
            track.Name,
            2
        )
        return
    end

    table.insert(Data.Playlist, track)

    SaveData()

    Toast(
        "PLAYLIST UPDATED",
        track.Name .. " added to queue.",
        2
    )
end

-- ================================================================
-- PLAYLIST UI
-- ================================================================

local function ClearChildren(container)
    for _, child in ipairs(container:GetChildren()) do
        if not child:IsA("UIListLayout")
            and not child:IsA("UIPadding") then

            SafeCall(function()
                child:Destroy()
            end)
        end
    end
end

local PlayTrack
local RefreshPlaylist

local function CreatePlaylistItem(track, index)
    local item = New("Frame", {
        Size = UDim2.new(1, -6, 0, 65),
        BackgroundColor3 = C.DarkBlue2,
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 45,
    }, PlaylistList)

    Corner(item, 10)
    Stroke(item, C.ToscaDark, 1, 0.35)

    New("ImageLabel", {
        Size = UDim2.fromOffset(44, 44),
        Position = UDim2.fromOffset(8, 10),
        BackgroundColor3 = C.Black,
        BorderSizePixel = 0,
        Image = ASSETS.Thumbnail,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 46,
    }, item)

    local art = item:FindFirstChildOfClass("ImageLabel")
    Corner(art, 8)

    New("TextLabel", {
        Size = UDim2.new(1, -90, 0, 19),
        Position = UDim2.fromOffset(61, 8),
        BackgroundTransparency = 1,
        Text = track.Name or "Unknown",
        TextColor3 = C.White,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 47,
    }, item)

    New("TextLabel", {
        Size = UDim2.new(1, -90, 0, 15),
        Position = UDim2.fromOffset(61, 29),
        BackgroundTransparency = 1,
        Text = "ID: " .. tostring(track.ID),
        TextColor3 = C.Gray,
        TextSize = 8,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 47,
    }, item)

    local play = Button(
        item,
        "▶",
        UDim2.fromOffset(28, 28),
        UDim2.new(1, -38, 0, 8)
    )

    play.TextSize = 10

    play.MouseButton1Click:Connect(function()
        PlayTrack(track)
    end)

    return item
end

RefreshPlaylist = function()
    ClearChildren(PlaylistList)

    for i, track in ipairs(Data.Playlist) do
        CreatePlaylistItem(track