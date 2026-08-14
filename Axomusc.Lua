--[[
====================================================================
                        AXOMUSC BETA
                  AXOLION COMMUNITY (BETA)
====================================================================

    SINGLE-FILE ROBLOX EXECUTOR UI
    DESIGNED FOR DELTA / EXECUTOR ENVIRONMENTS

    FEATURES
    ---------------------------------------------------------------
    • Protected gethui()
    • Protected CoreGui / PlayerGui fallback
    • Protected executor filesystem API
    • Protected clipboard API
    • Protected request API
    • Responsive UIScale
    • Acrylic / Glass UI
    • Dynamic border
    • Premium dark-blue / black / tosca theme
    • Smooth TweenService animations
    • Ripple buttons
    • Dragging
    • Minimize bubble
    • Toggle keybind
    • Toast notifications
    • Music ID search
    • Roblox Marketplace audio lookup
    • Audio playback
    • Play / Pause
    • Previous / Next
    • Repeat
    • Shuffle
    • Volume 1–100
    • Playback speed
    • Equalizer visualizer
    • Folder system
    • Playlist system
    • Favorite tracks
    • Persistent playlist when writefile is available
    • Community panel
    • Discord copy
    • Roblox Community copy
    • Mobile / PC responsive layout
====================================================================
]]

--------------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------
-- SAFE CALL SYSTEM
--------------------------------------------------------------------

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return false, nil
    end

    local args = table.pack(...)

    local ok, result = pcall(function()
        return fn(table.unpack(args, 1, args.n))
    end)

    if ok then
        return true, result
    end

    return false, nil
end

local function SafeMethod(object, methodName, ...)
    if not object then
        return false, nil
    end

    local method = object[methodName]

    if type(method) ~= "function" then
        return false, nil
    end

    return SafeCall(method, object, ...)
end

--------------------------------------------------------------------
-- EXECUTOR API DETECTION
--------------------------------------------------------------------

local Executor = {}

Executor.Name = "Roblox"

do
    local ok, result = pcall(function()
        if type(identifyexecutor) == "function" then
            return identifyexecutor()
        end

        if type(getexecutorname) == "function" then
            return getexecutorname()
        end

        return "Roblox"
    end)

    if ok and result then
        Executor.Name = tostring(result)
    end
end

--------------------------------------------------------------------
-- SAFE gethui
--------------------------------------------------------------------

Executor.GetUI = function()
    local success, ui

    if type(gethui) == "function" then
        success, ui = pcall(gethui)

        if success and ui then
            return ui
        end
    end

    success, ui = pcall(function()
        return CoreGui
    end)

    if success and ui then
        return ui
    end

    if LocalPlayer then
        local pgSuccess, playerGui = pcall(function()
            return LocalPlayer:WaitForChild("PlayerGui", 5)
        end)

        if pgSuccess and playerGui then
            return playerGui
        end
    end

    return nil
end

--------------------------------------------------------------------
-- SAFE CLIPBOARD
--------------------------------------------------------------------

Executor.SetClipboard = function(text)
    text = tostring(text or "")

    local funcs = {
        setclipboard,
        toclipboard,
        set_clipboard,
        writeclipboard
    }

    for _, fn in ipairs(funcs) do
        if type(fn) == "function" then
            local ok = pcall(fn, text)

            if ok then
                return true
            end
        end
    end

    return false
end

--------------------------------------------------------------------
-- SAFE FILESYSTEM
--------------------------------------------------------------------

Executor.File = {}

Executor.File.IsAvailable = function()
    return
        type(isfile) == "function"
        and type(readfile) == "function"
        and type(writefile) == "function"
end

Executor.File.Exists = function(path)
    if type(isfile) ~= "function" then
        return false
    end

    local ok, result = pcall(isfile, path)

    return ok and result == true
end

Executor.File.Read = function(path)
    if type(readfile) ~= "function" then
        return nil
    end

    local ok, result = pcall(readfile, path)

    if ok then
        return result
    end

    return nil
end

Executor.File.Write = function(path, data)
    if type(writefile) ~= "function" then
        return false
    end

    local ok = pcall(writefile, path, data)

    return ok
end

--------------------------------------------------------------------
-- SAFE REQUEST
--------------------------------------------------------------------

Executor.Request = nil

do
    local requestFunctions = {
        request,
        http_request,
        syn and syn.request,
        http and http.request
    }

    for _, fn in ipairs(requestFunctions) do
        if type(fn) == "function" then
            Executor.Request = fn
            break
        end
    end
end

--------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------

local Theme = {
    DarkBlue = Color3.fromRGB(5, 9, 27),
    DarkBlue2 = Color3.fromRGB(7, 13, 37),
    DarkBlue3 = Color3.fromRGB(10, 18, 48),

    Black = Color3.fromRGB(2, 4, 10),
    Black2 = Color3.fromRGB(7, 8, 15),

    Tosca = Color3.fromRGB(30, 235, 210),
    ToscaDark = Color3.fromRGB(18, 150, 139),

    Ice = Color3.fromRGB(170, 245, 255),

    White = Color3.fromRGB(240, 248, 255),
    Grey = Color3.fromRGB(145, 158, 180),
    Grey2 = Color3.fromRGB(95, 108, 130),

    Red = Color3.fromRGB(255, 85, 100),
    Yellow = Color3.fromRGB(255, 208, 92),

    Transparent = Color3.fromRGB(0, 0, 0)
}

--------------------------------------------------------------------
-- CONSTANTS
--------------------------------------------------------------------

local LOGO = "rbxassetid://85647271976925"
local THUMBNAIL = "rbxassetid://84404991858137"
local SUBLOGO = "rbxassetid://100003155958609"

local DISCORD_LINK = "https://discord.gg/dkuXRcS2hY"
local COMMUNITY_LINK = "https://www.roblox.com/share/g/245953568"

local SAVE_FILE = "Axomusc_Beta_Playlists.json"

--------------------------------------------------------------------
-- REMOVE OLD AXOMUSC
--------------------------------------------------------------------

do
    local uiParent = Executor.GetUI()

    if uiParent then
        pcall(function()
            local old = uiParent:FindFirstChild("Axomusc_Beta")
            if old then
                old:Destroy()
            end
        end)
    end
end

--------------------------------------------------------------------
-- GUI ROOT
--------------------------------------------------------------------

local UIParent = Executor.GetUI()

if not UIParent then
    return
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Axomusc_Beta"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

pcall(function()
    ScreenGui.Parent = UIParent
end)

if not ScreenGui.Parent then
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
end

if not ScreenGui.Parent and LocalPlayer then
    pcall(function()
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
end

if not ScreenGui.Parent then
    return
end

--------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------

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
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Theme.Tosca,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, parent)
end

local function Padding(parent, left, right, top, bottom)
    return New("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0)
    }, parent)
end

local function Tween(object, duration, properties, style, direction)
    if not object then
        return nil
    end

    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )

    local ok, tween = pcall(function()
        return TweenService:Create(object, info, properties)
    end)

    if ok and tween then
        pcall(function()
            tween:Play()
        end)

        return tween
    end

    return nil
end

--------------------------------------------------------------------
-- RESPONSIVE SCALE
--------------------------------------------------------------------

local Scale = New("UIScale", {
    Scale = 1
}, ScreenGui)

local function UpdateScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local width = viewport.X
    local height = viewport.Y

    local target

    if width < 600 then
        target = math.clamp(width / 440, 0.72, 0.95)
    elseif width < 1000 then
        target = math.clamp(width / 900, 0.82, 1)
    else
        target = math.clamp(width / 1280, 0.9, 1.08)
    end

    Tween(Scale, 0.3, {
        Scale = target
    })
end

UpdateScale()

pcall(function()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
end)

--------------------------------------------------------------------
-- TOAST SYSTEM
--------------------------------------------------------------------

local ToastHolder = New("Frame", {
    Name = "ToastHolder",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 310, 1, -40),
    Position = UDim2.new(1, -330, 0, 20),
    ZIndex = 900
}, ScreenGui)

New("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
}, ToastHolder)

local function Toast(title, message, duration)
    duration = duration or 2.7

    local holder = New("Frame", {
        BackgroundColor3 = Theme.Black2,
        BackgroundTransparency = 0.06,
        Size = UDim2.new(0, 290, 0, 66),
        ZIndex = 901
    }, ToastHolder)

    Corner(holder, 12)
    Stroke(holder, Theme.Tosca, 1, 0.35)

    New("Frame", {
        BackgroundColor3 = Theme.Tosca,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, -18),
        Position = UDim2.new(0, 8, 0, 9),
        ZIndex = 902
    }, holder)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(title),
        TextColor3 = Theme.White,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -34, 0, 23),
        Position = UDim2.new(0, 22, 0, 8),
        ZIndex = 903
    }, holder)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(message),
        TextColor3 = Theme.Grey,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -34, 0, 27),
        Position = UDim2.new(0, 22, 0, 31),
        ZIndex = 903
    }, holder)

    holder.Position = UDim2.new(0, 320, 0, 0)
    Tween(holder, 0.32, {
        Position = UDim2.new(0, 0, 0, 0)
    })

    task.delay(duration, function()
        if holder and holder.Parent then
            Tween(holder, 0.25, {
                Position = UDim2.new(0, 320, 0, 0),
                BackgroundTransparency = 1
            })

            task.wait(0.28)

            pcall(function()
                holder:Destroy()
            end)
        end
    end)
end

--------------------------------------------------------------------
-- RIPPLE
--------------------------------------------------------------------

local function Ripple(button)
    if not button or not button:IsA("GuiButton") then
        return
    end

    local mouse = UserInputService:GetMouseLocation()

    local absolute = button.AbsolutePosition
    local size = button.AbsoluteSize

    local x = math.clamp(mouse.X - absolute.X, 0, size.X)
    local y = math.clamp(mouse.Y - absolute.Y, 0, size.Y)

    local circle = New("Frame", {
        BackgroundColor3 = Theme.Tosca,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = button.ZIndex + 10
    }, button)

    Corner(circle, 100)

    Tween(circle, 0.45, {
        Size = UDim2.new(0, math.max(size.X, size.Y) * 2.2, 0, math.max(size.X, size.Y) * 2.2),
        Position = UDim2.new(
            0,
            x - math.max(size.X, size.Y) * 1.1,
            0,
            y - math.max(size.X, size.Y) * 1.1
        ),
        BackgroundTransparency = 1
    })

    task.delay(0.48, function()
        pcall(function()
            circle:Destroy()
        end)
    end)
end

local function BindButton(button, callback)
    if not button then
        return
    end

    button.AutoButtonColor = false

    button.MouseButton1Click:Connect(function()
        Ripple(button)

        if callback then
            task.spawn(function()
                pcall(callback)
            end)
        end
    end)
end

--------------------------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------------------------

local Main = New("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.52, 0),
    Size = UDim2.new(0, 1040, 0, 640),
    BackgroundColor3 = Theme.DarkBlue,
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 10
}, ScreenGui)

Corner(Main, 20)
Stroke(Main, Theme.Tosca, 1.5, 0.15)

--------------------------------------------------------------------
-- BACKGROUND GLASS
--------------------------------------------------------------------

local Glow = New("Frame", {
    BackgroundColor3 = Theme.Tosca,
    BackgroundTransparency = 0.96,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 120, 1, 120),
    Position = UDim2.new(0, -60, 0, -60),
    ZIndex = 10
}, Main)

Corner(Glow, 30)

--------------------------------------------------------------------
-- HEADER
--------------------------------------------------------------------

local Header = New("Frame", {
    BackgroundColor3 = Theme.Black,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 82),
    ZIndex = 20
}, Main)

New("ImageLabel", {
    BackgroundTransparency = 1,
    Image = LOGO,
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 18, 0, 16),
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 22
}, Header)

local Title = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Axomusc",
    TextColor3 = Theme.Ice,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0, 250, 0, 28),
    Position = UDim2.new(0, 80, 0, 14),
    ZIndex = 22
}, Header)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "By. Axolion Community (Beta)",
    TextColor3 = Theme.Grey,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0, 260, 0, 20),
    Position = UDim2.new(0, 80, 0, 43),
    ZIndex = 22
}, Header)

local BetaBox = New("TextLabel", {
    BackgroundColor3 = Theme.Tosca,
    BackgroundTransparency = 0.82,
    Text = "BETA",
    TextColor3 = Theme.Tosca,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 46, 0, 22),
    Position = UDim2.new(0, 285, 0, 29),
    ZIndex = 22
}, Header)

Corner(BetaBox, 7)
Stroke(BetaBox, Theme.Tosca, 1, 0.4)

local Close = New("TextButton", {
    BackgroundColor3 = Theme.Black2,
    BackgroundTransparency = 0.1,
    Text = "×",
    TextColor3 = Theme.White,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(1, -58, 0, 19),
    ZIndex = 30
}, Header)

Corner(Close, 13)

--------------------------------------------------------------------
-- SIDEBAR
--------------------------------------------------------------------

local Sidebar = New("Frame", {
    BackgroundColor3 = Theme.Black,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 235, 1, -82),
    Position = UDim2.new(0, 0, 0, 82),
    ZIndex = 20
}, Main)

New("Frame", {
    BackgroundColor3 = Theme.Tosca,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 2, 1, 0),
    Position = UDim2.new(1, -1, 0, 0),
    ZIndex = 25
}, Sidebar)

Padding(Sidebar, 15, 15, 22, 15)

local SideTitle = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "WORKSPACE",
    TextColor3 = Theme.Grey2,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, 0, 0, 24),
    ZIndex = 25
}, Sidebar)

local MusicButton = New("TextButton", {
    BackgroundColor3 = Theme.DarkBlue3,
    BackgroundTransparency = 0,
    Text = "",
    Size = UDim2.new(1, 0, 0, 54),
    Position = UDim2.new(0, 0, 0, 40),
    ZIndex = 25
}, Sidebar)

Corner(MusicButton, 12)
Stroke(MusicButton, Theme.Tosca, 1, 0.25)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "♫",
    TextColor3 = Theme.Tosca,
    TextSize = 23,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 35, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    ZIndex = 26
}, MusicButton)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Music Engine",
    TextColor3 = Theme.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -55, 1, 0),
    Position = UDim2.new(0, 50, 0, 0),
    ZIndex = 26
}, MusicButton)

local CommunityButton = New("TextButton", {
    BackgroundColor3 = Theme.DarkBlue,
    BackgroundTransparency = 1,
    Text = "",
    Size = UDim2.new(1, 0, 0, 54),
    Position = UDim2.new(0, 0, 0, 102),
    ZIndex = 25
}, Sidebar)

Corner(CommunityButton, 12)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "✦",
    TextColor3 = Theme.Ice,
    TextSize = 21,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 35, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    ZIndex = 26
}, CommunityButton)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Axolion Community",
    TextColor3 = Theme.Grey,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -55, 1, 0),
    Position = UDim2.new(0, 50, 0, 0),
    ZIndex = 26
}, CommunityButton)

--------------------------------------------------------------------
-- SIDEBAR STATUS
--------------------------------------------------------------------

local StatusBox = New("Frame", {
    BackgroundColor3 = Theme.DarkBlue2,
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 92),
    Position = UDim2.new(0, 0, 1, -108),
    ZIndex = 25
}, Sidebar)

Corner(StatusBox, 13)
Stroke(StatusBox, Theme.ToscaDark, 1, 0.6)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "AXOMUSC CORE",
    TextColor3 = Theme.Tosca,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -20, 0, 22),
    Position = UDim2.new(0, 10, 0, 10),
    ZIndex = 26
}, StatusBox)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Executor: " .. Executor.Name,
    TextColor3 = Theme.Grey,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 34),
    ZIndex = 26
}, StatusBox)

local SaveStatus = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = Executor.File.IsAvailable() and "Storage: Ready" or "Storage: Session",
    TextColor3 = Theme.Tosca,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 56),
    ZIndex = 26
}, StatusBox)

--------------------------------------------------------------------
-- WORKSPACE
--------------------------------------------------------------------

local Workspace = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -235, 1, -82),
    Position = UDim2.new(0, 235, 0, 82),
    ZIndex = 20
}, Main)

--------------------------------------------------------------------
-- MUSIC PAGE
--------------------------------------------------------------------

local MusicPage = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 21
}, Workspace)

--------------------------------------------------------------------
-- MUSIC TOP BAR
--------------------------------------------------------------------

local SearchFrame = New("Frame", {
    BackgroundColor3 = Theme.Black2,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Size = UDim2.new(1, -36, 0, 52),
    Position = UDim2.new(0, 18, 0, 18),
    ZIndex = 25
}, MusicPage)

Corner(SearchFrame, 14)
Stroke(SearchFrame, Theme.ToscaDark, 1, 0.55)

local SearchBox = New("TextBox", {
    BackgroundTransparency = 1,
    ClearTextOnFocus = false,
    PlaceholderText = "Search Roblox Music ID...",
    PlaceholderColor3 = Theme.Grey2,
    Text = "",
    TextColor3 = Theme.White,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -150, 1, 0),
    Position = UDim2.new(0, 18, 0, 0),
    ZIndex = 26
}, SearchFrame)

local SearchButton = New("TextButton", {
    BackgroundColor3 = Theme.Tosca,
    Text = "SEARCH",
    TextColor3 = Theme.Black,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 92, 0, 34),
    Position = UDim2.new(1, -102, 0, 9),
    ZIndex = 27
}, SearchFrame)

Corner(SearchButton, 10)

--------------------------------------------------------------------
-- SEARCH RESULT
--------------------------------------------------------------------

local SearchResult = New("Frame", {
    BackgroundColor3 = Theme.Black2,
    BackgroundTransparency = 0.04,
    BorderSizePixel = 0,
    Visible = false,
    Size = UDim2.new(1, -36, 0, 90),
    Position = UDim2.new(0, 18, 0, 78),
    ZIndex = 100
}, MusicPage)

Corner(SearchResult, 13)
Stroke(SearchResult, Theme.Tosca, 1, 0.25)

local SearchArt = New("ImageLabel", {
    BackgroundColor3 = Theme.DarkBlue3,
    Image = THUMBNAIL,
    Size = UDim2.new(0, 64, 0, 64),
    Position = UDim2.new(0, 12, 0, 13),
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 101
}, SearchResult)

Corner(SearchArt, 10)

local SearchName = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Unknown Audio",
    TextColor3 = Theme.White,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -220, 0, 24),
    Position = UDim2.new(0, 88, 0, 15),
    ZIndex = 102
}, SearchResult)

local SearchInfo = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Roblox Audio",
    TextColor3 = Theme.Grey,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -220, 0, 22),
    Position = UDim2.new(0, 88, 0, 40),
    ZIndex = 102
}, SearchResult)

local AddSearchButton = New("TextButton", {
    BackgroundColor3 = Theme.Tosca,
    Text = "+ ADD",
    TextColor3 = Theme.Black,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 92, 0, 34),
    Position = UDim2.new(1, -104, 0, 28),
    ZIndex = 102
}, SearchResult)

Corner(AddSearchButton, 10)

--------------------------------------------------------------------
-- THREE COLUMN MUSIC LAYOUT
--------------------------------------------------------------------

local MusicColumns = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -36, 1, -160),
    Position = UDim2.new(0, 18, 0, 148),
    ZIndex = 22
}, MusicPage)

--------------------------------------------------------------------
-- LEFT FOLDER
--------------------------------------------------------------------

local FolderPanel = New("Frame", {
    BackgroundColor3 = Theme.Black,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 190, 1, 0),
    ZIndex = 23
}, MusicColumns)

Corner(FolderPanel, 15)
Stroke(FolderPanel, Theme.ToscaDark, 1, 0.65)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "AUDIO LIBRARY",
    TextColor3 = Theme.White,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(1, -24, 0, 28),
    Position = UDim2.new(0, 12, 0, 10),
    ZIndex = 25
}, FolderPanel)

local FolderSearch = New("TextBox", {
    BackgroundColor3 = Theme.DarkBlue3,
    BackgroundTransparency = 0,
    PlaceholderText = "Filter...",
    PlaceholderColor3 = Theme.Grey2,
    Text = "",
    TextColor3 = Theme.White,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    Size = UDim2.new(1, -24, 0, 34),
    Position = UDim2.new(0, 12, 0, 43),
    ZIndex = 25
}, FolderPanel)

Corner(FolderSearch, 9)

local FolderList = New("ScrollingFrame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Tosca,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Size = UDim2.new(1, -20, 1, -92),
    Position = UDim2.new(0, 10, 0, 88),
    ZIndex = 25
}, FolderPanel)

New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
}, FolderList)

Padding(FolderList, 2, 2, 4, 4)

--------------------------------------------------------------------
-- CENTER PLAYER
--------------------------------------------------------------------

local PlayerPanel = New("Frame", {
    BackgroundColor3 = Theme.DarkBlue2,
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    Size = UDim2.new(0.48, -8, 1, 0),
    Position = UDim2.new(0, 198, 0, 0),
    ZIndex = 23
}, MusicColumns)

Corner(PlayerPanel, 15)
Stroke(PlayerPanel, Theme.ToscaDark, 1, 0.6)

local PlayerTitle = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "NOW PLAYING",
    TextColor3 = Theme.Tosca,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(1, -30, 0, 24),
    Position = UDim2.new(0, 15, 0, 12),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 25
}, PlayerPanel)

local Album = New("ImageLabel", {
    BackgroundColor3 = Theme.Black,
    Image = LOGO,
    Size = UDim2.new(0, 220, 0, 220),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 48),
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 25
}, PlayerPanel)

Corner(Album, 20)
Stroke(Album, Theme.Tosca, 1.5, 0.25)

local AlbumGlow = New("UIStroke", {
    Color = Theme.Ice,
    Thickness = 2,
    Transparency = 0.7
}, Album)

local TrackTitle = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "No Track Selected",
    TextColor3 = Theme.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextTruncate = Enum.TextTruncate.AtEnd,
    Size = UDim2.new(1, -30, 0, 28),
    Position = UDim2.new(0, 15, 0, 278),
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 26
}, PlayerPanel)

local TrackArtist = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "Axomusc Library",
    TextColor3 = Theme.Grey,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    Size = UDim2.new(1, -30, 0, 20),
    Position = UDim2.new(0, 15, 0, 305),
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 26
}, PlayerPanel)

--------------------------------------------------------------------
-- VISUALIZER
--------------------------------------------------------------------

local Visualizer = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -40, 0, 34),
    Position = UDim2.new(0, 20, 0, 332),
    ZIndex = 26
}, PlayerPanel)

local Bars = {}

for i = 1, 24 do
    local bar = New("Frame", {
        BackgroundColor3 = Theme.Tosca,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 1),
        Size = UDim2.new(0, 5, 0, math.random(5, 28)),
        Position = UDim2.new((i - 0.5) / 24, 0, 1, 0),
        ZIndex = 27
    }, Visualizer)

    Corner(bar, 4)

    table.insert(Bars, bar)
end

local VisualizerRunning = false

task.spawn(function()
    while ScreenGui.Parent do
        if VisualizerRunning then
            for _, bar in ipairs(Bars) do
                local targetHeight = math.random(5, 31)

                Tween(bar, 0.13, {
                    Size = UDim2.new(0, 5, 0, targetHeight)
                }, Enum.EasingStyle.Quad)
            end
        else
            for _, bar in ipairs(Bars) do
                Tween(bar, 0.25, {
                    Size = UDim2.new(0, 5, 0, 5)
                })
            end
        end

        task.wait(0.13)
    end
end)

--------------------------------------------------------------------
-- PROGRESS
--------------------------------------------------------------------

local ProgressBack = New("Frame", {
    BackgroundColor3 = Theme.Black,
    BorderSizePixel = 0,
    Size = UDim2.new(1, -40, 0, 5),
    Position = UDim2.new(0, 20, 0, 375),
    ZIndex = 26
}, PlayerPanel)

Corner(ProgressBack, 5)

local Progress = New("Frame", {
    BackgroundColor3 = Theme.Tosca,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 0, 1, 0),
    ZIndex = 27
}, ProgressBack)

Corner(Progress, 5)

--------------------------------------------------------------------
-- PLAYER CONTROLS
--------------------------------------------------------------------

local Controls = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -20, 0, 52),
    Position = UDim2.new(0, 10, 0, 390),
    ZIndex = 27
}, PlayerPanel)

local RepeatButton = New("TextButton", {
    BackgroundTransparency = 1,
    Text = "↻",
    TextColor3 = Theme.Grey,
    TextSize = 21,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 45, 0, 45),
    Position = UDim2.new(0, 10, 0, 0),
    ZIndex = 28
}, Controls)

local PreviousButton = New("TextButton", {
    BackgroundTransparency = 1,
    Text = "◀",
    TextColor3 = Theme.White,
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 45, 0, 45),
    Position = UDim2.new(0, 62, 0, 0),
    ZIndex = 28
}, Controls)

local PlayButton = New("TextButton", {
    BackgroundColor3 = Theme.Tosca,
    Text = "▶",
    TextColor3 = Theme.Black,
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 52, 0, 52),
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, -4),
    ZIndex = 29
}, Controls)

Corner(PlayButton, 26)

local NextButton = New("TextButton", {
    BackgroundTransparency = 1,
    Text = "▶",
    TextColor3 = Theme.White,
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 45, 0, 45),
    Position = UDim2.new(1, -107, 0, 0),
    ZIndex = 28
}, Controls)

local ShuffleButton = New("TextButton", {
    BackgroundTransparency = 1,
    Text = "⤨",
    TextColor3 = Theme.Grey,
    TextSize = 21,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 45, 0, 45),
    Position = UDim2.new(1, -58, 0, 0),
    ZIndex = 28
}, Controls)

--------------------------------------------------------------------
-- VOLUME / SPEED
--------------------------------------------------------------------

local VolumeText = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "VOLUME 100%",
    TextColor3 = Theme.Grey,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0.5, -20, 0, 20),
    Position = UDim2.new(0, 20, 1, -88),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 28
}, PlayerPanel)

local VolumeBack = New("Frame", {
    BackgroundColor3 = Theme.Black,
    BorderSizePixel = 0,
    Size = UDim2.new(0.5, -30, 0, 5),
    Position = UDim2.new(0, 20, 1, -65),
    ZIndex = 28
}, PlayerPanel)

Corner(VolumeBack, 5)

local VolumeFill = New("Frame", {
    BackgroundColor3 = Theme.Tosca,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 29
}, VolumeBack)

Corner(VolumeFill, 5)

local SpeedText = New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "SPEED 1.0x",
    TextColor3 = Theme.Grey,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0.5, -20, 0, 20),
    Position = UDim2.new(0.5, 10, 1, -88),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 28
}, PlayerPanel)

local SpeedFrame = New("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(0.5, -20, 0, 30),
    Position = UDim2.new(0.5, 10, 1, -73),
    ZIndex = 29
}, PlayerPanel)

--------------------------------------------------------------------
-- RIGHT PLAYLIST
--------------------------------------------------------------------

local PlaylistPanel = New("Frame", {
    BackgroundColor3 = Theme.Black,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Size = UDim2.new(0.34, -8, 1, 0),
    Position = UDim2.new(1, -0, 0, 0),
    AnchorPoint = Vector2.new(1, 0),
    ZIndex = 23
}, MusicColumns)

Corner(PlaylistPanel, 15)
Stroke(PlaylistPanel, Theme.ToscaDark, 1, 0.65)

New("TextLabel", {
    BackgroundTransparency = 1,
    Text = "PLAYLIST",
    TextColor3 = Theme.White,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(1, -24, 0, 28),
    Position = UDim2.new(0, 12, 0, 10),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 25
}, PlaylistPanel)

local AddTrackButton = New("TextButton", {
    BackgroundColor3 = Theme.DarkBlue3,
    Text = "+ ADD",
    TextColor3 = Theme.Tosca,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    Size = UDim2.new(0, 62, 0, 30),
    Position = UDim2.new(1, -74, 0, 9),
    ZIndex = 26
}, PlaylistPanel)

Corner(AddTrackButton, 8)
Stroke(AddTrackButton, Theme.Tosca, 1, 0.45)

local PlaylistList = New("ScrollingFrame", {
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Tosca,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Size = UDim2.new(1, -20, 1, -58),
    Position = UDim2.new(0, 10, 0, 50),
    ZIndex = 25
}, PlaylistPanel)

New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
}, PlaylistList)

Padding(PlaylistList, 2, 2, 5, 5)

--------------------------------------------------------------------
-- DATA
--------------------------------------------------------------------

local Tracks = {}
local Favorites = {}
local CurrentIndex = 0

local Settings = {
    Volume = 1,
    Speed = 1,
    Repeat = false,
    Shuffle = false,
    Equalizer = "Balanced"
}

--------------------------------------------------------------------
-- SOUND
--------------------------------------------------------------------

local CurrentSound = New("Sound", {
    Name = "Axomusc_Player",
    Volume = Settings.Volume,
    PlaybackSpeed = Settings.Speed,
    Looped = false,
    SoundId = ""
}, SoundService)

--------------------------------------------------------------------
-- STORAGE
--------------------------------------------------------------------

local function SaveData()
    if not Executor.File.IsAvailable() then
        return
    end

    local data = {
        Tracks = Tracks,
        Favorites = Favorites,
        Settings = Settings
    }

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if ok and encoded then
        Executor.File.Write(SAVE_FILE, encoded)
    end
end

local function LoadData()
    if not Executor.File.IsAvailable() then
        return
    end

    local raw = Executor.File.Read(SAVE_FILE)

    if not raw or raw == "" then
        return
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not ok or type(data) ~= "table" then
        return
    end

    if type(data.Tracks) == "table" then
        Tracks = data.Tracks
    end

    if type(data.Favorites) == "table" then
        Favorites = data.Favorites
    end

    if type(data.Settings) == "table" then
        for key, value in pairs(data.Settings) do
            Settings[key] = value
        end
    end
end

LoadData()

--------------------------------------------------------------------
-- FOLDER BUTTONS
--------------------------------------------------------------------

local function CreateFolder(name, icon, callback)
    local button = New("TextButton", {
        BackgroundColor3 = Theme.DarkBlue2,
        BackgroundTransparency = 0.35,
        Text = "",
        Size = UDim2.new(1, -4, 0, 42),
        ZIndex = 27
    }, FolderList)

    Corner(button, 9)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = Theme.Tosca,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Size = UDim2.new(0, 32, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        ZIndex = 28
    }, button)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Grey,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -45, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        ZIndex = 28
    }, button)

    BindButton(button, callback)

    return button
end

CreateFolder("All Audio", "♫", function()
    Toast("Library", "All audio tracks loaded.")
end)

CreateFolder("Favorites", "★", function()
    Toast("Favorites", tostring(#Favorites) .. " favorite track(s).")
end)

CreateFolder("My Creations", "◆", function()
    Toast("My Creations", "Custom Axomusc tracks.")
end)

CreateFolder("System Audio", "▣", function()
    Toast("System Audio", "System audio library selected.")
end)

CreateFolder("Recent", "◷", function()
    Toast("Recent", "Recently used tracks.")
end)

--------------------------------------------------------------------
-- TRACK UI
--------------------------------------------------------------------

local function IsFavorite(id)
    for _, value in ipairs(Favorites) do
        if tostring(value) == tostring(id) then
            return true
        end
    end

    return false
end

local function ToggleFavorite(id)
    for i, value in ipairs(Favorites) do
        if tostring(value) == tostring(id) then
            table.remove(Favorites, i)
            SaveData()
            return false
        end
    end

    table.insert(Favorites, tostring(id))
    SaveData()

    return true
end

--------------------------------------------------------------------
-- REFRESH PLAYLIST
--------------------------------------------------------------------

local function ClearPlaylistUI()
    for _, child in ipairs(PlaylistList:GetChildren()) do
        if child:IsA("GuiButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function PlayTrack(index)

    if #Tracks == 0 then
        Toast("Playlist Empty", "Tambahkan Roblox Music ID terlebih dahulu.")
        return
    end

    if index < 1 then
        index = #Tracks
    end

    if index > #Tracks then
        index = 1
    end

    CurrentIndex = index

    local track = Tracks[index]

    if not track then
        return
    end

    local id = tostring(track.Id)

    CurrentSound:Stop()
    CurrentSound.SoundId = "rbxassetid://" .. id
    CurrentSound.Volume = Settings.Volume
    CurrentSound.PlaybackSpeed = Settings.Speed

    local ok = pcall(function()
        CurrentSound:Play()
    end)

    TrackTitle.Text = tostring(track.Name or ("Roblox Audio " .. id))
    TrackArtist.Text = "Roblox Audio • ID " .. id
    Album.Image = track.Image or THUMBNAIL

    if ok then
        VisualizerRunning = true
        PlayButton.Text = "Ⅱ"

        Toast(
            "Now Playing",
            tostring(track.Name or "Roblox Audio") .. " • ID " .. id
        )
    else
        VisualizerRunning = false
        Toast("Playback", "Audio tidak dapat diputar oleh Roblox pada sesi ini.")
    end
end

local function AddTrackToData(id, name, image)

    id = tostring(id)

    for _, track in ipairs(Tracks) do
        if tostring(track.Id) == id then
            Toast("Already Added", "Music ID tersebut sudah ada.")
            return false
        end
    end

    table.insert(Tracks, {
        Id = id,
        Name = name or ("Roblox Audio " .. id),
        Image = image or THUMBNAIL
    })

    SaveData()

    return true
end

local function RefreshPlaylist()

    ClearPlaylistUI()

    if #Tracks == 0 then

        New("TextLabel", {
            BackgroundTransparency = 1,
            Text = "Playlist masih kosong.\nTambahkan Music ID melalui Search.",
            TextColor3 = Theme.Grey,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextWrapped = true,
            Size = UDim2.new(1, -20, 0, 70),
            Position = UDim2.new(0, 10, 0, 20),
            ZIndex = 28
        }, PlaylistList)

        return
    end

    for index, track in ipairs(Tracks) do

        local item = New("TextButton", {
            BackgroundColor3 = Theme.DarkBlue2,
            BackgroundTransparency = 0.18,
            Text = "",
            Size = UDim2.new(1, -4, 0, 64),
            ZIndex = 27
        }, PlaylistList)

        Corner(item, 10)

        local art = New("ImageLabel", {
            BackgroundColor3 = Theme.Black,
            Image = track.Image or THUMBNAIL,
            Size = UDim2.new(0, 46, 0, 46),
            Position = UDim2.new(0, 8, 0, 9),
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 28
        }, item)

        Corner(art, 8)

        New("TextLabel", {
            BackgroundTransparency = 1,
            Text = tostring(track.Name or "Unknown"),
            TextColor3 = Theme.White,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -120, 0, 22),
            Position = UDim2.new(0, 62, 0, 9),
            ZIndex = 29
        }, item)

        New("TextLabel", {
            BackgroundTransparency = 1,
            Text = "ID " .. tostring(track.Id),
            TextColor3 = Theme.Grey2,
            TextSize = 8,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -120, 0, 18),
            Position = UDim2.new(0, 62, 0, 31),
            ZIndex = 29
        }, item)

        local favorite = New("TextButton", {
            BackgroundTransparency = 1,
            Text = IsFavorite(track.Id) and "★" or "☆",
            TextColor3 = IsFavorite(track.Id) and Theme.Tosca or Theme.Grey,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -70, 0, 17),
            ZIndex = 31
        }, item)

        local playMini = New("TextButton", {
            BackgroundColor3 = Theme.Tosca,
            Text = "▶",
            TextColor3 = Theme.Black,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(1, -34, 0, 18),
            ZIndex = 31
        }, item)

        Corner(playMini, 14)

        BindButton(favorite, function()
            local state = ToggleFavorite(track.Id)

            favorite.Text = state and "★" or "☆"
            favorite.TextColor3 = state and Theme.Tosca or Theme.Grey

            Toast(
                "Favorite",
                state and "Track disimpan ke Favorite." or "Track dihapus dari Favorite."
            )
        end)

        BindButton(playMini, function()
            PlayTrack(index)
        end)

        BindButton(item, function()
            PlayTrack(index)
        end)
    end
end

--------------------------------------------------------------------
-- ROBLOX MUSIC SEARCH
--------------------------------------------------------------------

local function ResolveAsset(id)

    id = tostring(id or "")
    id = id:gsub("%D", "")

    if id == "" then
        return nil, "Masukkan Music ID Roblox."
   