--// ========================================================================
--// AXOMUSC PREMIUM UI
--// AXOLION COMMUNITY (BETA)
--// SINGLE SCRIPT / SELF CONTAINED / EXECUTOR COMPATIBILITY BUILD
--// ========================================================================
--// Rebuilt from zero:
--// - Tidak bergantung pada _G dari script lain
--// - Tidak bergantung pada App / Config / MainClip dari script lain
--// - Aman jika dieksekusi ulang
--// - gethui / syn.protect_gui compatibility
--// - Mobile + PC
--// - Drag
--// - Sidebar 3-layer
--// - Music player
--// - Queue
--// - Playlist
--// - Folder
--// - Profile
--// - About
--// - Up Info
--// - Notification
--// - Search
--// - Progress seek
--// - Tempo
--// - Repeat / Shuffle
--// - Executor compatibility helpers
--// ========================================================================

repeat task.wait() until game:IsLoaded()

--// ========================================================================
--// SERVICES
--// ========================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    return
end

--// ========================================================================
--// EXECUTOR COMPATIBILITY
--// ========================================================================

local Executor = {
    Name = "Roblox",
    HasGetHui = false,
    HasProtectGui = false,
    HasGetConnections = false,
    HasRequest = false
}

pcall(function()
    if type(identifyexecutor) == "function" then
        Executor.Name = tostring(identifyexecutor())
    elseif type(getexecutorname) == "function" then
        Executor.Name = tostring(getexecutorname())
    end
end)

pcall(function()
    Executor.HasGetHui = type(gethui) == "function"
end)

pcall(function()
    Executor.HasProtectGui = syn and type(syn.protect_gui) == "function"
end)

pcall(function()
    Executor.HasGetConnections = type(getconnections) == "function"
end)

pcall(function()
    Executor.HasRequest =
        type(request) == "function"
        or type(http_request) == "function"
        or (syn and type(syn.request) == "function")
end)

local function SafeGetHui()
    local gui

    pcall(function()
        if type(gethui) == "function" then
            gui = gethui()
        end
    end)

    return gui
end

local function ProtectGui(gui)
    local success = false

    pcall(function()
        local hui = SafeGetHui()

        if hui then
            gui.Parent = hui
            success = true
            return
        end
    end)

    if not success then
        pcall(function()
            if syn and type(syn.protect_gui) == "function" then
                syn.protect_gui(gui)
            end
        end)

        pcall(function()
            gui.Parent = CoreGui
            success = true
        end)
    end

    if not success then
        pcall(function()
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
            success = true
        end)
    end

    return success
end

--// ========================================================================
--// CONFIG
--// ========================================================================

local Config = {
    Brand = "Axolion Community (Beta)",
    Title = "Axomusc",

    MainLogo = "rbxassetid://85647271976925",
    Thumbnail = "rbxassetid://84404991858137",
    SubLogo = "rbxassetid://100003155958609",

    Discord = "https://discord.gg/dkuXRcS2hY",
    RobloxGroup = "https://www.roblox.com/share/g/245953568",

    Colors = {
        DarkBlue = Color3.fromRGB(5, 10, 30),
        DarkBlue2 = Color3.fromRGB(9, 16, 40),
        ToscaGreen = Color3.fromRGB(64, 224, 208),
        IceBlue = Color3.fromRGB(175, 238, 238),
        Black = Color3.fromRGB(12, 12, 16),
        Black2 = Color3.fromRGB(18, 18, 24),
        White = Color3.fromRGB(245, 245, 250),
        Gray = Color3.fromRGB(155, 165, 180),
        Red = Color3.fromRGB(255, 75, 90),
        Shadow = Color3.fromRGB(0, 0, 0)
    },

    Tween = {
        Fast = 0.18,
        Normal = 0.30,
        Slow = 0.45
    }
}

local C = Config.Colors

--// ========================================================================
--// SAFE HELPERS
--// ========================================================================

local function SafeDestroy(obj)
    pcall(function()
        if obj then
            obj:Destroy()
        end
    end)
end

local function New(className, parent)
    local obj = Instance.new(className)

    if parent then
        obj.Parent = parent
    end

    return obj
end

local function Corner(parent, radius)
    local c = New("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function Stroke(parent, color, thickness, transparency)
    local s = New("UIStroke", parent)
    s.Color = color or C.White
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    return s
end

local function Gradient(parent, colors, rotation)
    local g = New("UIGradient", parent)

    g.Color = ColorSequence.new(colors)
    g.Rotation = rotation or 0

    return g
end

local function Tween(obj, duration, properties, style, direction)
    if not obj then
        return nil
    end

    local tween

    pcall(function()
        tween = TweenService:Create(
            obj,
            TweenInfo.new(
                duration or Config.Tween.Normal,
                style or Enum.EasingStyle.Quart,
                direction or Enum.EasingDirection.Out
            ),
            properties
        )

        tween:Play()
    end)

    return tween
end

local function FormatTime(seconds)
    seconds = tonumber(seconds) or 0

    if seconds ~= seconds or seconds < 0 then
        seconds = 0
    end

    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)

    return string.format("%d:%02d", minutes, secs)
end

local function ClampNumber(value, minValue, maxValue)
    return math.clamp(tonumber(value) or minValue, minValue, maxValue)
end

local function GetAssetId(id)
    id = tostring(id or "")

    if id == "" then
        return ""
    end

    if string.find(id, "rbxassetid://", 1, true) then
        return id
    end

    local number = string.match(id, "%d+")

    if number then
        return "rbxassetid://" .. number
    end

    return ""
end

--// ========================================================================
--// REMOVE OLD VERSION
--// ========================================================================

pcall(function()
    local oldNames = {
        "Axomusc_Premium_UI",
        "AxomuscUI",
        "Axomusc_UI"
    }

    for _, name in ipairs(oldNames) do
        local old = CoreGui:FindFirstChild(name)
        if old then
            old:Destroy()
        end

        local hui = SafeGetHui()

        if hui then
            local oldHui = hui:FindFirstChild(name)
            if oldHui then
                oldHui:Destroy()
            end
        end

        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

        if playerGui then
            local oldPlayer = playerGui:FindFirstChild(name)
            if oldPlayer then
                oldPlayer:Destroy()
            end
        end
    end
end)

--// ========================================================================
--// MAIN GUI
--// ========================================================================

local Gui = New("ScreenGui")
Gui.Name = "Axomusc_Premium_UI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999999

ProtectGui(Gui)

--// ========================================================================
--// MAIN WINDOW
--// ========================================================================

local Main = New("Frame", Gui)
Main.Name = "Axomusc_Main"
Main.Size = UDim2.new(0, 760, 0, 500)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = C.Black
Main.BorderSizePixel = 0
Main.Active = true
Main.ZIndex = 10

Corner(Main, 16)

local MainStroke = Stroke(Main, C.IceBlue, 2, 0.35)

local MainGradient = Gradient(
    MainStroke,
    {
        ColorSequenceKeypoint.new(0, C.ToscaGreen),
        ColorSequenceKeypoint.new(0.5, C.IceBlue),
        ColorSequenceKeypoint.new(1, C.ToscaGreen)
    },
    0
)

local Shadow = New("ImageLabel", Main)
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
Shadow.Size = UDim2.new(1, 45, 1, 45)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://13169336625"
Shadow.ImageColor3 = C.Shadow
Shadow.ImageTransparency = 0.35
Shadow.ZIndex = 1

local Clip = New("Frame", Main)
Clip.Name = "MainClip"
Clip.Size = UDim2.new(1, 0, 1, 0)
Clip.BackgroundTransparency = 1
Clip.BorderSizePixel = 0
Clip.ClipsDescendants = true
Clip.ZIndex = 11

Corner(Clip, 16)

--// ========================================================================
--// RESPONSIVE SCALE
--// ========================================================================

local UIScale = New("UIScale", Main)

local function UpdateScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local sx = viewport.X / 900
    local sy = viewport.Y / 600

    local scale = math.min(sx, sy)

    if viewport.X <= 700 then
        scale = math.min(scale, 0.88)
    end

    UIScale.Scale = math.clamp(scale, 0.48, 1)
end

pcall(UpdateScale)

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
end

--// ========================================================================
--// STATE
--// ========================================================================

local State = {
    CurrentLayer = "Main",
    CurrentPage = "Music Panel",

    SidebarWidth = 155,
    IconWidth = 62,

    SidebarOpen = true,

    IsQueueOpen = false,
    TempoOpen = false,

    IsPlaying = false,
    CurrentTrackIndex = 1,
    PlayMode = 1,
    PlaybackSpeed = 1,

    Destroyed = false
}

local Pages = {}
local MenuButtons = {}

--// ========================================================================
--// NOTIFICATION SYSTEM
--// ========================================================================

local NotificationHolder = New("Frame", Gui)
NotificationHolder.Name = "Notifications"
NotificationHolder.Size = UDim2.new(0, 320, 1, -20)
NotificationHolder.Position = UDim2.new(1, -330, 0, 10)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.ZIndex = 1000

local NotificationLayout = New("UIListLayout", NotificationHolder)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationLayout.Padding = UDim.new(0, 8)

local function Notify(title, text, duration)
    if State.Destroyed then
        return
    end

    duration = tonumber(duration) or 3

    local Box = New("Frame", NotificationHolder)
    Box.Name = "Notification"
    Box.Size = UDim2.new(0, 300, 0, 70)
    Box.BackgroundColor3 = C.DarkBlue2
    Box.BackgroundTransparency = 0.04
    Box.BorderSizePixel = 0
    Box.ZIndex = 1001

    Corner(Box, 10)
    Stroke(Box, C.ToscaGreen, 1.2, 0.25)

    local Accent = New("Frame", Box)
    Accent.Size = UDim2.new(0, 3, 1, -20)
    Accent.Position = UDim2.new(0, 8, 0, 10)
    Accent.BackgroundColor3 = C.ToscaGreen
    Accent.BorderSizePixel = 0
    Accent.ZIndex = 1002

    Corner(Accent, 4)

    local Title = New("TextLabel", Box)
    Title.Size = UDim2.new(1, -35, 0, 23)
    Title.Position = UDim2.new(0, 20, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = tostring(title or "Axomusc")
    Title.TextColor3 = C.IceBlue
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 1002

    local Body = New("TextLabel", Box)
    Body.Size = UDim2.new(1, -35, 0, 30)
    Body.Position = UDim2.new(0, 20, 0, 32)
    Body.BackgroundTransparency = 1
    Body.Text = tostring(text or "")
    Body.TextColor3 = C.White
    Body.TextTransparency = 0.1
    Body.Font = Enum.Font.Gotham
    Body.TextSize = 12
    Body.TextWrapped = true
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.ZIndex = 1002

    Box.Position = UDim2.new(1, 30, 0, 0)

    Tween(Box, 0.35, {
        Position = UDim2.new(0, 0, 0, 0)
    })

    task.delay(duration, function()
        if not Box or not Box.Parent then
            return
        end

        local out = Tween(
            Box,
            0.3,
            {
                Position = UDim2.new(1, 30, 0, 0),
                BackgroundTransparency = 1
            }
        )

        Tween(Title, 0.25, {
            TextTransparency = 1
        })

        Tween(Body, 0.25, {
            TextTransparency = 1
        })

        task.delay(0.35, function()
            SafeDestroy(Box)
        end)
    end)
end

--// ========================================================================
--// HEADER
--// ========================================================================

local Header = New("Frame", Clip)
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 70)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = C.DarkBlue
Header.BorderSizePixel = 0
Header.ZIndex = 20

local HeaderCorner = Corner(Header, 16)

local HeaderBlock = New("Frame", Header)
HeaderBlock.Size = UDim2.new(1, 0, 0, 16)
HeaderBlock.Position = UDim2.new(0, 0, 1, -16)
HeaderBlock.BackgroundColor3 = C.DarkBlue
HeaderBlock.BorderSizePixel = 0
HeaderBlock.ZIndex = 20

local HeaderLogo = New("ImageLabel", Header)
HeaderLogo.Name = "Logo"
HeaderLogo.Size = UDim2.new(0, 40, 0, 40)
HeaderLogo.Position = UDim2.new(0, 17, 0.5, 0)
HeaderLogo.AnchorPoint = Vector2.new(0, 0.5)
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.Image = Config.SubLogo
HeaderLogo.ImageColor3 = C.White
HeaderLogo.ZIndex = 22

Corner(HeaderLogo, 10)

local HeaderTitle = New("TextLabel", Header)
HeaderTitle.Size = UDim2.new(0, 300, 0, 27)
HeaderTitle.Position = UDim2.new(0, 70, 0, 10)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = Config.Title
HeaderTitle.TextColor3 = C.IceBlue
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 24
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 22

local HeaderSub = New("TextLabel", Header)
HeaderSub.Size = UDim2.new(0, 350, 0, 17)
HeaderSub.Position = UDim2.new(0, 72, 0, 39)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Text = "By. " .. Config.Brand
HeaderSub.TextColor3 = C.White
HeaderSub.TextTransparency = 0.3
HeaderSub.Font = Enum.Font.GothamSemibold
HeaderSub.TextSize = 11
HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
HeaderSub.ZIndex = 22

local CloseButton = New("TextButton", Header)
CloseButton.Name = "Close"
CloseButton.Size = UDim2.new(0, 42, 0, 42)
CloseButton.Position = UDim2.new(1, -53, 0.5, 0)
CloseButton.AnchorPoint = Vector2.new(0, 0.5)
CloseButton.BackgroundColor3 = C.Black2
CloseButton.BackgroundTransparency = 0.25
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = C.White
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 27
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 23

Corner(CloseButton, 10)

CloseButton.MouseEnter:Connect(function()
    Tween(CloseButton, 0.18, {
        BackgroundColor3 = C.Red,
        TextColor3 = C.White
    })
end)

CloseButton.MouseLeave:Connect(function()
    Tween(CloseButton, 0.18, {
        BackgroundColor3 = C.Black2,
        TextColor3 = C.White
    })
end)

--// ========================================================================
--// LAYER 1 - ICON BAR
--// ========================================================================

local IconBar = New("Frame", Clip)
IconBar.Name = "Layer1_IconBar"
IconBar.Size = UDim2.new(0, State.IconWidth, 1, -70)
IconBar.Position = UDim2.new(0, 0, 0, 70)
IconBar.BackgroundColor3 = C.Black
IconBar.BorderSizePixel = 0
IconBar.ZIndex = 30

local IconSeparator = New("Frame", IconBar)
IconSeparator.Size = UDim2.new(0, 1, 1, 0)
IconSeparator.Position = UDim2.new(1, -1, 0, 0)
IconSeparator.BackgroundColor3 = C.IceBlue
IconSeparator.BackgroundTransparency = 0.65
IconSeparator.BorderSizePixel = 0
IconSeparator.ZIndex = 31

local ActiveIconLine = New("Frame", IconBar)
ActiveIconLine.Size = UDim2.new(0, 3, 0, 38)
ActiveIconLine.Position = UDim2.new(0, 0, 0, 35)
ActiveIconLine.AnchorPoint = Vector2.new(0, 0.5)
ActiveIconLine.BackgroundColor3 = C.ToscaGreen
ActiveIconLine.BorderSizePixel = 0
ActiveIconLine.ZIndex = 35

Corner(ActiveIconLine, 4)

--// Hamburger
local Hamburger = New("TextButton", IconBar)
Hamburger.Name = "MainMenu"
Hamburger.Size = UDim2.new(0, 42, 0, 42)
Hamburger.Position = UDim2.new(0.5, 0, 0, 35)
Hamburger.AnchorPoint = Vector2.new(0.5, 0.5)
Hamburger.BackgroundTransparency = 1
Hamburger.Text = ""
Hamburger.AutoButtonColor = false
Hamburger.ZIndex = 35

local H1 = New("Frame", Hamburger)
H1.Size = UDim2.new(0, 23, 0, 2)
H1.Position = UDim2.new(0.5, -11, 0.5, -7)
H1.BackgroundColor3 = C.ToscaGreen
H1.BorderSizePixel = 0
H1.ZIndex = 36

local H2 = New("Frame", Hamburger)
H2.Size = UDim2.new(0, 23, 0, 2)
H2.Position = UDim2.new(0.5, -11, 0.5, 0)
H2.BackgroundColor3 = C.ToscaGreen
H2.BorderSizePixel = 0
H2.ZIndex = 36

local H3 = New("Frame", Hamburger)
H3.Size = UDim2.new(0, 23, 0, 2)
H3.Position = UDim2.new(0.5, -11, 0.5, 7)
H3.BackgroundColor3 = C.ToscaGreen
H3.BorderSizePixel = 0
H3.ZIndex = 36

--// Axolion Logo
local SpecialButton = New("ImageButton", IconBar)
SpecialButton.Name = "SpecialMenu"
SpecialButton.Size = UDim2.new(0, 36, 0, 36)
SpecialButton.Position = UDim2.new(0.5, 0, 0, 88)
SpecialButton.AnchorPoint = Vector2.new(0.5, 0.5)
SpecialButton.BackgroundTransparency = 1
SpecialButton.Image = Config.SubLogo
SpecialButton.ImageColor3 = C.White
SpecialButton.ImageTransparency = 0.45
SpecialButton.AutoButtonColor = false
SpecialButton.ZIndex = 35

--// ========================================================================
--// LAYER 2 - SIDEBAR
--// ========================================================================

local Sidebar = New("Frame", Clip)
Sidebar.Name = "Layer2_Sidebar"
Sidebar.Size = UDim2.new(0, State.SidebarWidth, 1, -70)
Sidebar.Position = UDim2.new(0, State.IconWidth, 0, 70)
Sidebar.BackgroundColor3 = C.DarkBlue
Sidebar.BackgroundTransparency = 0.12
Sidebar.BorderSizePixel = 0
Sidebar.ClipsDescendants = true
Sidebar.ZIndex = 40

local SidebarLine = New("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 2, 1, 0)
SidebarLine.Position = UDim2.new(1, -2, 0, 0)
SidebarLine.BackgroundColor3 = C.ToscaGreen
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 45

local SidebarGradient = Gradient(
    SidebarLine,
    {
        ColorSequenceKeypoint.new(0, C.ToscaGreen),
        ColorSequenceKeypoint.new(0.5, C.IceBlue),
        ColorSequenceKeypoint.new(1, C.ToscaGreen)
    },
    90
)

local MenuScroll = New("ScrollingFrame", Sidebar)
MenuScroll.Name = "MenuScroll"
MenuScroll.Size = UDim2.new(1, -8, 1, -10)
MenuScroll.Position = UDim2.new(0, 4, 0, 5)
MenuScroll.BackgroundTransparency = 1
MenuScroll.BorderSizePixel = 0
MenuScroll.ScrollBarThickness = 0
MenuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MenuScroll.ZIndex = 41

local MenuLayout = New("UIListLayout", MenuScroll)
MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
MenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MenuLayout.Padding = UDim.new(0, 7)

local MenuPadding = New("UIPadding", MenuScroll)
MenuPadding.PaddingTop = UDim.new(0, 10)
MenuPadding.PaddingBottom = UDim.new(0, 10)

MenuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MenuScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        MenuLayout.AbsoluteContentSize.Y + 30
    )
end)

--// ========================================================================
--// LAYER 3 - CONTENT
--// ========================================================================

local Content = New("Frame", Clip)
Content.Name = "Layer3_Content"
Content.Size = UDim2.new(
    1,
    -(State.IconWidth + State.SidebarWidth),
    1,
    -70
)
Content.Position = UDim2.new(
    0,
    State.IconWidth + State.SidebarWidth,
    0,
    70
)
Content.BackgroundColor3 = C.Black
Content.BackgroundTransparency = 0
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.ZIndex = 12

local ContentGradient = Gradient(
    Content,
    {
        ColorSequenceKeypoint.new(0, C.Black),
        ColorSequenceKeypoint.new(0.5, C.Black2),
        ColorSequenceKeypoint.new(1, C.Black)
    },
    90
)

local PageContainer = New("Frame", Content)
PageContainer.Name = "Pages"
PageContainer.Size = UDim2.new(1, 0, 1, 0)
PageContainer.BackgroundTransparency = 1
PageContainer.BorderSizePixel = 0
PageContainer.ClipsDescendants = true
PageContainer.ZIndex = 13

--// ========================================================================
--// PAGE CREATOR
--// ========================================================================

local function CreatePage(name)
    local page = New("ScrollingFrame", PageContainer)

    page.Name = name:gsub("%s+", "_") .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.ToscaGreen
    page.ScrollBarImageTransparency = 0.15
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 14

    local padding = New("UIPadding", page)
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 20)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)

    Pages[name] = page

    return page
end

local MusicPage = CreatePage("Music Panel")
local PlaylistPage = CreatePage("Playlist")
local FolderPage = CreatePage("Folder")
local ProfilePage = CreatePage("Profile")
local AboutPage = CreatePage("About")
local UpInfoPage = CreatePage("Up Info")

--// ========================================================================
--// PAGE TITLE HELPER
--// ========================================================================

local function CreatePageHeader(parent, title, subtitle)
    local holder = New("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 55)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 15

    local titleLabel = New("TextLabel", holder)
    titleLabel.Size = UDim2.new(1, 0, 0, 27)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = C.White
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 21
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 16

    local subLabel = New("TextLabel", holder)
    subLabel.Size = UDim2.new(1, 0, 0, 20)
    subLabel.Position = UDim2.new(0, 0, 0, 28)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = subtitle or ""
    subLabel.TextColor3 = C.Gray
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 11
    subLabel.TextXAlignment = Enum.TextXAlignment.Left
    subLabel.ZIndex = 16

    return holder
end

--// ========================================================================
--// MENU BUTTON CREATOR
--// ========================================================================

local function SetPageVisible(targetName)
    for name, page in pairs(Pages) do
        if name == targetName then
            page.Visible = true
            page.Position = UDim2.new(0, 25, 0, 0)

            Tween(page, 0.3, {
                Position = UDim2.new(0, 0, 0, 0)
            })
        else
            page.Visible = false
        end
    end

    for name, data in pairs(MenuButtons) do
        local active = name == targetName

        Tween(data.Button, 0.2, {
            BackgroundTransparency = active and 0.45 or 1
        })

        Tween(data.Label, 0.2, {
            TextColor3 = active and C.ToscaGreen or C.White,
            TextTransparency = active and 0 or 0.35
        })

        Tween(data.Indicator, 0.25, {
            Size = active
                and UDim2.new(0, 3, 0, 18)
                or UDim2.new(0, 3, 0, 0)
        })
    end

    State.CurrentPage = targetName
end

local function CreateMenuButton(name, category, order)
    local button = New("TextButton", MenuScroll)
    button.Name = "Menu_" .. name:gsub("%s+", "_")
    button.Size = UDim2.new(0.88, 0, 0, 36)
    button.LayoutOrder = order or 1
    button.BackgroundColor3 = C.Black
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 43

    Corner(button, 8)

    local indicator = New("Frame", button)
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 3, 0, 0)
    indicator.Position = UDim2.new(0, 0, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = C.ToscaGreen
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 46

    Corner(indicator, 5)

    local label = New("TextLabel", button)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.White
    label.TextTransparency = 0.35
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 45

    local categoryValue = New("StringValue", button)
    categoryValue.Name = "Category"
    categoryValue.Value = category

    MenuButtons[name] = {
        Button = button,
        Label = label,
        Indicator = indicator,
        Category = category
    }

    button.MouseEnter:Connect(function()
        if State.CurrentPage ~= name then
            Tween(button, 0.15, {
                BackgroundTransparency = 0.75
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if State.CurrentPage ~= name then
            Tween(button, 0.15, {
                BackgroundTransparency = 1
            })
        end
    end)

    button.MouseButton1Click:Connect(function()
        SetPageVisible(name)
    end)

    return button
end

CreateMenuButton("Music Panel", "Main", 1)
CreateMenuButton("Playlist", "Main", 2)
CreateMenuButton("Folder", "Main", 3)

CreateMenuButton("Profile", "Special", 4)
CreateMenuButton("About", "Special", 5)
CreateMenuButton("Up Info", "Special", 6)

--// ========================================================================
--// LAYER SWITCHING
--// ========================================================================

local function ShowCategory(category)
    for name, data in pairs(MenuButtons) do
        data.Button.Visible = data.Category == category
    end

    local first

    for name, data in pairs(MenuButtons) do
        if data.Category == category and not first then
            first = name
        end
    end

    if first then
        SetPageVisible(first)
    end
end

local function SetLayer(layer)
    State.CurrentLayer = layer

    if layer == "Main" then
        Tween(H1, 0.2, {BackgroundColor3 = C.ToscaGreen})
        Tween(H2, 0.2, {BackgroundColor3 = C.ToscaGreen})
        Tween(H3, 0.2, {BackgroundColor3 = C.ToscaGreen})

        Tween(SpecialButton, 0.2, {
            ImageColor3 = C.White,
            ImageTransparency = 0.45
        })

        Tween(ActiveIconLine, 0.3, {
            Position = UDim2.new(0, 0, 0, 35)
        })

        ShowCategory("Main")
    else
        Tween(H1, 0.2, {BackgroundColor3 = C.White})
        Tween(H2, 0.2, {BackgroundColor3 = C.White})
        Tween(H3, 0.2, {BackgroundColor3 = C.White})

        Tween(SpecialButton, 0.2, {
            ImageColor3 = C.ToscaGreen,
            ImageTransparency = 0
        })

        Tween(ActiveIconLine, 0.3, {
            Position = UDim2.new(0, 0, 0, 88)
        })

        ShowCategory("Special")
    end
end

Hamburger.MouseEnter:Connect(function()
    Tween(Hamburger, 0.15, {
        Size = UDim2.new(0, 46, 0, 46)
    })
end)

Hamburger.MouseLeave:Connect(function()
    Tween(Hamburger, 0.15, {
        Size = UDim2.new(0, 42, 0, 42)
    })
end)

SpecialButton.MouseEnter:Connect(function()
    Tween(SpecialButton, 0.15, {
        Size = UDim2.new(0, 40, 0, 40),
        ImageTransparency = 0
    })
end)

SpecialButton.MouseLeave:Connect(function()
    Tween(SpecialButton, 0.15, {
        Size = UDim2.new(0, 36, 0, 36),
        ImageTransparency = State.CurrentLayer == "Special" and 0 or 0.45
    })
end)

Hamburger.MouseButton1Click:Connect(function()
    SetLayer("Main")
end)

SpecialButton.MouseButton1Click:Connect(function()
    SetLayer("Special")
end)

--// ========================================================================
--// MUSIC DATA
--// ========================================================================

local MusicQueue = {
    {
        ID = "9112892993",
        Title = "Axomusc Theme",
        Artist = "Axolion Community"
    }
}

local Audio = New("Sound")
Audio.Name = "Axomusc_AudioEngine"
Audio.SoundId = ""
Audio.Volume = 0.75
Audio.PlaybackSpeed = 1
Audio.Looped = false

pcall(function()
    Audio.Parent = SoundService
end)

if not Audio.Parent then
    pcall(function()
        Audio.Parent = Gui
    end)
end

--// ========================================================================
--// MUSIC PAGE
--// ========================================================================

CreatePageHeader(
    MusicPage,
    "Music Panel",
    "Premium music control system • Axolion Community"
)

local NowPlaying = New("Frame", MusicPage)
NowPlaying.Name = "NowPlaying"
NowPlaying.Size = UDim2.new(1, 0, 0, 155)
NowPlaying.BackgroundColor3 = C.DarkBlue2
NowPlaying.BackgroundTransparency = 0.08
NowPlaying.BorderSizePixel = 0
NowPlaying.ZIndex = 16

Corner(NowPlaying, 14)
Stroke(NowPlaying, C.ToscaGreen, 1.4, 0.45)

--// Album
local Album = New("Frame", NowPlaying)
Album.Size = UDim2.new(0, 112, 0, 112)
Album.Position = UDim2.new(0, 18, 0.5, 0)
Album.AnchorPoint = Vector2.new(0, 0.5)
Album.BackgroundColor3 = C.Black
Album.BorderSizePixel = 0
Album.ZIndex = 18

Corner(Album, 56)
Stroke(Album, C.IceBlue, 1.3, 0.3)

local AlbumImage = New("ImageLabel", Album)
AlbumImage.Size = UDim2.new(1, -6, 1, -6)
AlbumImage.Position = UDim2.new(0.5, 0, 0.5, 0)
AlbumImage.AnchorPoint = Vector2.new(0.5, 0.5)
AlbumImage.BackgroundTransparency = 1
AlbumImage.Image = Config.Thumbnail
AlbumImage.ZIndex = 19

Corner(AlbumImage, 55)

local AlbumHole = New("Frame", AlbumImage)
AlbumHole.Size = UDim2.new(0, 18, 0, 18)
AlbumHole.Position = UDim2.new(0.5, 0, 0.5, 0)
AlbumHole.AnchorPoint = Vector2.new(0.5, 0.5)
AlbumHole.BackgroundColor3 = C.DarkBlue
AlbumHole.BorderSizePixel = 0
AlbumHole.ZIndex = 20

Corner(AlbumHole, 20)

local BassRing = New("Frame", NowPlaying)
BassRing.Size = UDim2.new(0, 124, 0, 124)
BassRing.Position = UDim2.new(0, 74, 0.5, 0)
BassRing.AnchorPoint = Vector2.new(0.5, 0.5)
BassRing.BackgroundTransparency = 1
BassRing.BorderSizePixel = 0
BassRing.ZIndex = 17

Corner(BassRing, 70)

local BassStroke = Stroke(BassRing, C.ToscaGreen, 2.5, 0.1)

local BassGradient = Gradient(
    BassStroke,
    {
        ColorSequenceKeypoint.new(0, C.ToscaGreen),
        ColorSequenceKeypoint.new(0.5, C.IceBlue),
        ColorSequenceKeypoint.new(1, C.Black)
    },
    0
)

--// Song info
local SongTitle = New("TextLabel", NowPlaying)
SongTitle.Size = UDim2.new(1, -235, 0, 30)
SongTitle.Position = UDim2.new(0, 150, 0, 22)
SongTitle.BackgroundTransparency = 1
SongTitle.Text = "No Track Selected"
SongTitle.TextColor3 = C.White
SongTitle.Font = Enum.Font.GothamBold
SongTitle.TextSize = 19
SongTitle.TextXAlignment = Enum.TextXAlignment.Left
SongTitle.TextTruncate = Enum.TextTruncate.AtEnd
SongTitle.ZIndex = 18

local SongArtist = New("TextLabel", NowPlaying)
SongArtist.Size = UDim2.new(1, -235, 0, 20)
SongArtist.Position = UDim2.new(0, 150, 0, 51)
SongArtist.BackgroundTransparency = 1
SongArtist.Text = "Axolion Community"
SongArtist.TextColor3 = C.ToscaGreen
SongArtist.Font = Enum.Font.GothamSemibold
SongArtist.TextSize = 11
SongArtist.TextXAlignment = Enum.TextXAlignment.Left
SongArtist.ZIndex = 18

local StatusLabel = New("TextLabel", NowPlaying)
StatusLabel.Size = UDim2.new(1, -235, 0, 18)
StatusLabel.Position = UDim2.new(0, 150, 0, 71)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "READY"
StatusLabel.TextColor3 = C.Gray
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.ZIndex = 18

--// Queue button
local QueueButton = New("TextButton", NowPlaying)
QueueButton.Size = UDim2.new(0, 38, 0, 38)
QueueButton.Position = UDim2.new(1, -52, 0, 15)
QueueButton.BackgroundColor3 = C.Black
QueueButton.BackgroundTransparency = 0.25
QueueButton.BorderSizePixel = 0
QueueButton.Text = "≡"
QueueButton.TextColor3 = C.White
QueueButton.Font = Enum.Font.GothamBold
QueueButton.TextSize = 21
QueueButton.AutoButtonColor = false
QueueButton.ZIndex = 20

Corner(QueueButton, 9)
Stroke(QueueButton, C.ToscaGreen, 1, 0.4)

--// ========================================================================
--// PROGRESS BAR
--// ========================================================================

local ProgressHolder = New("Frame", NowPlaying)
ProgressHolder.Size = UDim2.new(1, -170, 0, 38)
ProgressHolder.Position = UDim2.new(0, 150, 1, -52)
ProgressHolder.BackgroundTransparency = 1
ProgressHolder.ZIndex = 18

local ProgressButton = New("TextButton", ProgressHolder)
ProgressButton.Size = UDim2.new(1, 0, 0, 5)
ProgressButton.Position = UDim2.new(0, 0, 0, 6)
ProgressButton.BackgroundColor3 = C.Black
ProgressButton.BorderSizePixel = 0
ProgressButton.Text = ""
ProgressButton.AutoButtonColor = false
ProgressButton.ZIndex = 19

Corner(ProgressButton, 5)

local ProgressFill = New("Frame", ProgressButton)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = C.ToscaGreen
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 20

Corner(ProgressFill, 5)

local ProgressKnob = New("Frame", ProgressFill)
ProgressKnob.Size = UDim2.new(0, 11, 0, 11)
ProgressKnob.Position = UDim2.new(1, 0, 0.5, 0)
ProgressKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressKnob.BackgroundColor3 = C.White
ProgressKnob.BorderSizePixel = 0
ProgressKnob.ZIndex = 21

Corner(ProgressKnob, 10)

local CurrentTime = New("TextLabel", ProgressHolder)
CurrentTime.Size = UDim2.new(0, 55, 0, 15)
CurrentTime.Position = UDim2.new(0, 0, 0, 15)
CurrentTime.BackgroundTransparency = 1
CurrentTime.Text = "0:00"
CurrentTime.TextColor3 = C.Gray
CurrentTime.Font = Enum.Font.Gotham
CurrentTime.TextSize = 9
CurrentTime.TextXAlignment = Enum.TextXAlignment.Left
CurrentTime.ZIndex = 20

local TotalTime = New("TextLabel", ProgressHolder)
TotalTime.Size = UDim2.new(0, 55, 0, 15)
TotalTime.Position = UDim2.new(1, -55, 0, 15)
TotalTime.BackgroundTransparency = 1
TotalTime.Text = "0:00"
TotalTime.TextColor3 = C.Gray
TotalTime.Font = Enum.Font.Gotham
TotalTime.TextSize = 9
TotalTime.TextXAlignment = Enum.TextXAlignment.Right
TotalTime.ZIndex = 20

--// ========================================================================
--// CONTROLS
--// ========================================================================

local ControlPanel = New("Frame", MusicPage)
ControlPanel.Name = "ControlPanel"
ControlPanel.Size = UDim2.new(1, 0, 0, 82)
ControlPanel.BackgroundColor3 = C.Black2
ControlPanel.BackgroundTransparency = 0.15
ControlPanel.BorderSizePixel = 0
ControlPanel.ZIndex = 16

Corner(ControlPanel, 13)
local ControlStroke = Stroke(ControlPanel, C.ToscaGreen, 1, 0.65)

local ControlLayout = New("UIListLayout", ControlPanel)
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlLayout.Padding = UDim.new(0, 12)

local function CreateControlButton(name, text, size, order, main)
    local button = New("TextButton", ControlPanel)

    button.Name = name
    button.Size = UDim2.new(0, size, 0, size)
    button.LayoutOrder = order
    button.BackgroundColor3 = main and C.ToscaGreen or C.DarkBlue
    button.BackgroundTransparency = main and 0 or 0.12
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = main and C.Black or C.White
    button.Font = Enum.Font.GothamBold
    button.TextSize = main and 25 or 17
    button.AutoButtonColor = false
    button.ZIndex = 18

    Corner(button, size)

    if not main then
        Stroke(button, C.IceBlue, 1, 0.6)
    end

    button.MouseEnter:Connect(function()
        Tween(button, 0.15, {
            Size = UDim2.new(0, size + 5, 0, size + 5)
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, 0.15, {
            Size = UDim2.new(0, size, 0, size)
        })
    end)

    return button
end

local TempoButton = CreateControlButton("Tempo", "⏱", 43, 1, false)
local PreviousButton = CreateControlButton("Previous", "◀◀", 48, 2, false)
local PlayButton = CreateControlButton("Play", "▶", 62, 3, true)
local NextButton = CreateControlButton("Next", "▶▶", 48, 4, false)
local ModeButton = CreateControlButton("Mode", "↻", 43, 5, false)

--// ========================================================================
--// TEMPO PANEL
--// ========================================================================

local TempoPanel = New("Frame", MusicPage)
TempoPanel.Name = "TempoPanel"
TempoPanel.Size = UDim2.new(0, 220, 0, 0)
TempoPanel.Position = UDim2.new(0.5, -110, 0, 248)
TempoPanel.BackgroundColor3 = C.DarkBlue2
TempoPanel.BackgroundTransparency = 0.03
TempoPanel.BorderSizePixel = 0
TempoPanel.ClipsDescendants = true
TempoPanel.Visible = false
TempoPanel.ZIndex = 50

Corner(TempoPanel, 10)
Stroke(TempoPanel, C.ToscaGreen, 1.2, 0.25)

local TempoLayout = New("UIListLayout", TempoPanel)
TempoLayout.FillDirection = Enum.FillDirection.Horizontal
TempoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TempoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TempoLayout.Padding = UDim.new(0, 7)

local TempoPadding = New("UIPadding", TempoPanel)
TempoPadding.PaddingLeft = UDim.new(0, 8)
TempoPadding.PaddingRight = UDim.new(0, 8)

local TempoButtons = {}

for _, speed in ipairs({0.5, 0.75, 1, 1.25, 1.5}) do
    local button = New("TextButton", TempoPanel)

    button.Size = UDim2.new(0, 36, 0, 30)
    button.BackgroundColor3 = speed == 1 and C.ToscaGreen or C.Black
    button.BorderSizePixel = 0
    button.Text = tostring(speed) .. "x"
    button.TextColor3 = speed == 1 and C.Black or C.White
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.AutoButtonColor = false
    button.ZIndex = 52

    Corner(button, 6)

    table.insert(TempoButtons, {
        Button = button,
        Speed = speed
    })

    button.MouseButton1Click:Connect(function()
        State.PlaybackSpeed = speed
        Audio.PlaybackSpeed = speed

        for _, data in ipairs(TempoButtons) do
            data.Button.BackgroundColor3 =
                data.Speed == speed and C.ToscaGreen or C.Black

            data.Button.TextColor3 =
                data.Speed == speed and C.Black or C.White
        end

        Notify(
            "Tempo",
            "Playback speed: " .. tostring(speed) .. "x",
            2
        )

        State.TempoOpen = false

        local tw = Tween(
            TempoPanel,
            0.25,
            {
                Size = UDim2.new(0, 220, 0, 0)
            }
        )

        task.delay(0.27, function()
            TempoPanel.Visible = false
        end)
    end)
end

TempoButton.MouseButton1Click:Connect(function()
    State.TempoOpen = not State.TempoOpen

    if State.TempoOpen then
        TempoPanel.Visible = true
        TempoPanel.Size = UDim2.new(0, 220, 0, 0)

        Tween(
            TempoPanel,
            0.3,
            {
                Size = UDim2.new(0, 220, 0, 48)
            }
        )
    else
        Tween(
            TempoPanel,
            0.25,
            {
                Size = UDim2.new(0, 220, 0, 0)
            }
        )

        task.delay(0.27, function()
            TempoPanel.Visible = false
        end)
    end
end)

--// ========================================================================
--// QUEUE
--// ========================================================================

local QueuePanel = New("Frame", MusicPage)
QueuePanel.Name = "QueuePanel"
QueuePanel.Size = UDim2.new(1, 0, 0, 0)
QueuePanel.BackgroundColor3 = C.DarkBlue2
QueuePanel.BackgroundTransparency = 0.08
QueuePanel.BorderSizePixel = 0
QueuePanel.ClipsDescendants = true
QueuePanel.ZIndex = 45

Corner(QueuePanel, 12)
local QueueStroke = Stroke(QueuePanel, C.ToscaGreen, 1.2, 1)

local QueueScroll = New("ScrollingFrame", QueuePanel)
QueueScroll.Size = UDim2.new(1, -12, 1, -12)
QueueScroll.Position = UDim2.new(0, 6, 0, 6)
QueueScroll.BackgroundTransparency = 1
QueueScroll.BorderSizePixel = 0
QueueScroll.ScrollBarThickness = 3
QueueScroll.ScrollBarImageColor3 = C.ToscaGreen
QueueScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
QueueScroll.ZIndex = 46

local QueueLayout = New("UIListLayout", QueueScroll)
QueueLayout.SortOrder = Enum.SortOrder.LayoutOrder
QueueLayout.Padding = UDim.new(0, 6)

local QueuePadding = New("UIPadding", QueueScroll)
QueuePadding.PaddingTop = UDim.new(0, 4)
QueuePadding.PaddingBottom = UDim.new(0, 8)

--// ========================================================================
--// MUSIC FUNCTIONS
--// ========================================================================

local function UpdateQueueUI()
    for _, child in ipairs(QueueScroll:GetChildren()) do
        if child:IsA("Frame") then
            SafeDestroy(child)
        end
    end

    for index, track in ipairs(MusicQueue) do
        local item = New("Frame", QueueScroll)

        item.Name = "Track_" .. index
        item.Size = UDim2.new(1, -5, 0, 43)
        item.BackgroundColor3 =
            index == State.CurrentTrackIndex
            and C.DarkBlue
            or C.Black
        item.BackgroundTransparency = 0.15
        item.BorderSizePixel = 0
        item.LayoutOrder = index
        item.ZIndex = 47

        Corner(item, 8)

        if index == State.CurrentTrackIndex then
            Stroke(item, C.ToscaGreen, 1, 0.35)
        end

        local number = New("TextLabel", item)
        number.Size = UDim2.new(0, 30, 1, 0)
        number.Position = UDim2.new(0, 8, 0, 0)
        number.BackgroundTransparency = 1
        number.Text = tostring(index)
        number.TextColor3 =
            index == State.CurrentTrackIndex
            and C.ToscaGreen
            or C.Gray
        number.Font = Enum.Font.GothamBold
        number.TextSize = 11
        number.ZIndex = 49

        local title = New("TextLabel", item)
        title.Size = UDim2.new(1, -95, 1, 0)
        title.Position = UDim2.new(0, 40, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = tostring(track.Title or "Unknown Track")
        title.TextColor3 = C.White
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.ZIndex = 49

        local play = New("TextButton", item)
        play.Size = UDim2.new(0, 28, 0, 28)
        play.Position = UDim2.new(1, -37, 0.5, 0)
        play.AnchorPoint = Vector2.new(0, 0.5)
        play.BackgroundColor3 = C.DarkBlue
        play.BorderSizePixel = 0
        play.Text = "▶"
        play.TextColor3 = C.White
        play.Font = Enum.Font.GothamBold
        play.TextSize = 10
        play.AutoButtonColor = false
        play.ZIndex = 50

        Corner(play, 20)

        play.MouseButton1Click:Connect(function()
            local id = GetAssetId(track.ID)

            if id == "" then
                Notify("Audio Error", "Sound ID tidak valid.", 3)
                return
            end

            State.CurrentTrackIndex = index

            Audio:Stop()
            Audio.SoundId = id
            Audio.PlaybackSpeed = State.PlaybackSpeed

            local ok = pcall(function()
                Audio:Play()
            end)

            if not ok then
                Notify(
                    "Audio Error",
                    "Executor/Roblox menolak audio tersebut.",
                    3
                )
                return
            end

            State.IsPlaying = true

            PlayButton.Text = "Ⅱ"
            StatusLabel.Text = "PLAYING"
            StatusLabel.TextColor3 = C.ToscaGreen

            SongTitle.Text = track.Title or "Unknown Track"
            SongArtist.Text = track.Artist or "Unknown Artist"

            Tween(
                PlayButton,
                0.2,
                {
                    BackgroundColor3 = C.ToscaGreen,
                    TextColor3 = C.Black
                }
            )

            UpdateQueueUI()
        end)
    end

    QueueScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        (#MusicQueue * 49) + 15
    )
end

local function PlayTrack(index)
    if #MusicQueue <= 0 then
        Notify(
            "Playlist Kosong",
            "Tambahkan audio terlebih dahulu.",
            3
        )
        return
    end

    index = tonumber(index) or 1

    if index < 1 then
        index = #MusicQueue
    elseif index > #MusicQueue then
        index = 1
    end

    local track = MusicQueue[index]

    if not track then
        return
    end

    local soundId = GetAssetId(track.ID)

    if soundId == "" then
        Notify(
            "Audio Error",
            "ID audio tidak valid.",
            3
        )
        return
    end

    State.CurrentTrackIndex = index

    SongTitle.Text = tostring(track.Title or "Unknown Track")
    SongArtist.Text = tostring(track.Artist or "Unknown Artist")

    Audio:Stop()
    Audio.SoundId = soundId
    Audio.PlaybackSpeed = State.PlaybackSpeed
    Audio.TimePosition = 0

    local success = pcall(function()
        Audio:Play()
    end)

    if not success then
        State.IsPlaying = false
        PlayButton.Text = "▶"
        StatusLabel.Text = "AUDIO ERROR"
        StatusLabel.TextColor3 = C.Red

        Notify(
            "Audio Error",
            "Audio tidak dapat diputar.",
            3
        )

        return
    end

    State.IsPlaying = true

    PlayButton.Text = "Ⅱ"
    StatusLabel.Text = "PLAYING"
    StatusLabel.TextColor3 = C.ToscaGreen

    Tween(
        PlayButton,
        0.2,
        {
            BackgroundColor3 = C.ToscaGreen,
            TextColor3 = C.Black
        }
    )

    UpdateQueueUI()

    Notify(
        "Now Playing",
        tostring(track.Title or "Unknown Track"),
        2.5
    )
end

local function PauseTrack()
    pcall(function()
        Audio:Pause()
    end)

    State.IsPlaying = false
    PlayButton.Text = "▶"
    StatusLabel.Text = "PAUSED"
    StatusLabel.TextColor3 = C.Gray

    Tween(
        PlayButton,
        0.2,
        {
            BackgroundColor3 = C.ToscaGreen,
            TextColor3 = C.Black
        }
    )
end

local function ResumeTrack()
    if Audio.SoundId == "" then
        PlayTrack(State.CurrentTrackIndex)
        return
    end

    pcall(function()
        Audio:Resume()
    end)

    State.IsPlaying = true
    PlayButton.Text = "Ⅱ"
    StatusLabel.Text = "PLAYING"
    StatusLabel.TextColor3 = C.ToscaGreen
end

--// ========================================================================
--// MUSIC BUTTON EVENTS
--// ========================================================================

PlayButton.MouseButton1Click:Connect(function()
    if #MusicQueue == 0 then
        Notify(
            "Playlist Kosong",
            "Tidak ada lagu di queue.",
            3
        )
        return
    end

    if State.IsPlaying then
        PauseTrack()
    else
        ResumeTrack()
    end
end)

NextButton.MouseButton1Click:Connect(function()
    if #MusicQueue == 0 then
        return
    end

    if State.PlayMode == 3 then
        PlayTrack(math.random(1, #MusicQueue))
    else
        PlayTrack(State.CurrentTrackIndex + 1)
    end
end)

PreviousButton.MouseButton1Click:Connect(function()
    if #MusicQueue == 0 then
        return
    end

    PlayTrack(State.CurrentTrackIndex - 1)
end)

ModeButton.MouseButton1Click:Connect(function()
    State.PlayMode = State.PlayMode + 1

    if State.PlayMode > 3 then
        State.PlayMode = 1
    end

    if State.PlayMode == 1 then
        ModeButton.Text = "↻"
        ModeButton.TextColor3 = C.White

        Notify(
            "Play Mode",
            "Auto Next",
            2
        )

    elseif State.PlayMode == 2 then
        ModeButton.Text = "↻1"
        ModeButton.TextColor3 = C.ToscaGreen

        Notify(
            "Play Mode",
            "Repeat One",
            2
        )

    else
        ModeButton.Text = "🔀"
        ModeButton.TextColor3 = C.ToscaGreen

        Notify(
            "Play Mode",
            "Shuffle",
            2
        )
    end
end)

--// ========================================================================
--// QUEUE TOGGLE
--// ========================================================================

QueueButton.MouseButton1Click:Connect(function()
    State.IsQueueOpen = not State.IsQueueOpen

    if State.IsQueueOpen then
        QueueButton.BackgroundColor3 = C.ToscaGreen
        QueueButton.TextColor3 = C.Black

        QueueStroke.Transparency = 0.2

        Tween(
            ControlPanel,
            0.35,
            {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            }
        )

        Tween(
            QueuePanel,
            0.4,
            {
                Size = UDim2.new(1, 0, 0, 230)
            }
        )

    else
        QueueButton.BackgroundColor3 = C.Black
        QueueButton.TextColor3 = C.White

        QueueStroke.Transparency = 1

        Tween(
            QueuePanel,
            0.35,
            {
                Size = UDim2.new(1, 0, 0, 0)
            }
        )

        Tween(
            ControlPanel,
            0.4,
            {
                Size = UDim2.new(1, 0, 0, 82),
                BackgroundTransparency = 0.15
            }
        )
    end
end)

--// ========================================================================
--// PROGRESS SEEK
--// ========================================================================

local ProgressDragging = false

local function SeekFromInput(input)
    if not Audio or not Audio.Parent then
        return
    end

    if Audio.TimeLength <= 0 then
        return
    end

    local width = ProgressButton.AbsoluteSize.X

    if width <= 0 then
        return
    end

    local x = input.Position.X - ProgressButton.AbsolutePosition.X

    local percentage = math.clamp(
        x / width,
        0,
        1
    )

    local target = percentage * Audio.TimeLength

    pcall(function()
        Audio.TimePosition = target
    end)

    ProgressFill.Size = UDim2.new(
        percentage,
        0,
        1,
        0
    )
end

ProgressButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        ProgressDragging = true
        SeekFromInput(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not ProgressDragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        SeekFromInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        ProgressDragging = false
    end
end)

--// ========================================================================
--// AUDIO ENDED
--// ========================================================================

Audio.Ended:Connect(function()
    if State.Destroyed then
        return
    end

    State.IsPlaying = false

    if #MusicQueue == 0 then
        return
    end

    if State.PlayMode == 2 then
        PlayTrack(State.CurrentTrackIndex)

    elseif State.PlayMode == 3 then
        PlayTrack(math.random(1, #MusicQueue))

    else
        PlayTrack(State.CurrentTrackIndex + 1)
    end
end)

--// ========================================================================
--// MUSIC RENDER LOOP
--// ========================================================================

local MusicConnection

MusicConnection = RunService.RenderStepped:Connect(function()
    if State.Destroyed then
        return
    end

    if not Audio or not Audio.Parent then
        return
    end

    if State.IsPlaying then
        pcall(function()
            AlbumImage.Rotation =
                (AlbumImage.Rotation + 0.45) % 360

            BassGradient.Rotation =
                (BassGradient.Rotation + 1.5) % 360

            local loudness =
                math.clamp(
                    Audio.PlaybackLoudness / 1000,
                    0,
                    1
                )

            local pulse =
                1 + (loudness * 0.08)

            BassRing.Size =
                BassRing.Size:Lerp(
                    UDim2.new(
                        0,
                        124 * pulse,
                        0,
                        124 * pulse
                    ),
                    0.15
                )

            if Audio.TimeLength > 0 then
                local ratio =
                    math.clamp(
                        Audio.TimePosition / Audio.TimeLength,
                        0,
                        1
                    )

                if not ProgressDragging then
                    ProgressFill.Size =
                        UDim2.new(
                            ratio,
                            0,
                            1,
                            0
                        )
                end

                CurrentTime.Text =
                    FormatTime(Audio.TimePosition)

                TotalTime.Text =
                    FormatTime(Audio.TimeLength)
            end
        end)
    else
        pcall(function()
            BassRing.Size =
                BassRing.Size:Lerp(
                    UDim2.new(0, 124, 0, 124),
                    0.1
                )
        end)
    end
end)

--// ========================================================================
--// PLAYLIST PAGE
--// ========================================================================

CreatePageHeader(
    PlaylistPage,
    "Playlist",
    "Manage music queue and custom tracks"
)

local PlaylistCard = New("Frame", PlaylistPage)
PlaylistCard.Size = UDim2.new(1, 0, 0, 300)
PlaylistCard.BackgroundColor3 = C.DarkBlue2
PlaylistCard.BackgroundTransparency = 0.08
PlaylistCard.BorderSizePixel = 0
PlaylistCard.ZIndex = 16

Corner(PlaylistCard, 13)
Stroke(PlaylistCard, C.IceBlue, 1, 0.6)

local PlaylistTitle = New("TextLabel", PlaylistCard)
PlaylistTitle.Size = UDim2.new(1, -30, 0, 25)
PlaylistTitle.Position = UDim2.new(0, 15, 0, 14)
PlaylistTitle.BackgroundTransparency = 1
PlaylistTitle.Text = "Current Playlist"
PlaylistTitle.TextColor3 = C.White
PlaylistTitle.Font = Enum.Font.GothamBold
PlaylistTitle.TextSize = 16
PlaylistTitle.TextXAlignment = Enum.TextXAlignment.Left
PlaylistTitle.ZIndex = 17

local PlaylistInfo = New("TextLabel", PlaylistCard)
PlaylistInfo.Size = UDim2.new(1, -30, 0, 35)
PlaylistInfo.Position = UDim2.new(0, 15, 0, 43)
PlaylistInfo.BackgroundTransparency = 1
PlaylistInfo.Text = "Tracks currently loaded into Axomusc."
PlaylistInfo.TextColor3 = C.Gray
PlaylistInfo.Font = Enum.Font.Gotham
PlaylistInfo.TextSize = 11
PlaylistInfo.TextXAlignment = Enum.TextXAlignment.Left
PlaylistInfo.ZIndex = 17

local PlaylistScroll = New("ScrollingFrame", PlaylistCard)
PlaylistScroll.Size = UDim2.new(1, -30, 1, -95)
PlaylistScroll.Position = UDim2.new(0, 15, 0, 85)
PlaylistScroll.BackgroundTransparency = 1
PlaylistScroll.BorderSizePixel = 0
PlaylistScroll.ScrollBarThickness = 3
PlaylistScroll.ScrollBarImageColor3 = C.ToscaGreen
PlaylistScroll.ZIndex = 17

local PlaylistLayout = New("UIListLayout", PlaylistScroll)
PlaylistLayout.Padding = UDim.new(0, 7)

local function RefreshPlaylistPage()
    for _, child in ipairs(PlaylistScroll:GetChildren()) do
        if child:IsA("Frame") then
            SafeDestroy(child)
        end
    end

    for i, track in ipairs(MusicQueue) do
        local item = New("Frame", PlaylistScroll)

        item.Size = UDim2.new(1, -5, 0, 45)
        item.BackgroundColor3 = C.Black
        item.BackgroundTransparency = 0.2
        item.BorderSizePixel = 0
        item.LayoutOrder = i
        item.ZIndex = 18

        Corner(item, 8)

        local title = New("TextLabel", item)
        title.Size = UDim2.new(1, -55, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = tostring(track.Title or "Unknown")
        title.TextColor3 = C.White
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.ZIndex = 19

        local play = New("TextButton", item)
        play.Size = UDim2.new(0, 28, 0, 28)
        play.Position = UDim2.new(1, -38, 0.5, 0)
        play.AnchorPoint = Vector2.new(0, 0.5)
        play.BackgroundColor3 = C.DarkBlue
        play.BorderSizePixel = 0
        play.Text = "▶"
        play.TextColor3 = C.White
        play.Font = Enum.Font.GothamBold
        play.TextSize = 10
        play.ZIndex = 20

        Corner(play, 20)

        play.MouseButton1Click:Connect(function()
            PlayTrack(i)
        end)
    end

    PlaylistScroll.CanvasSize =
        UDim2.new(0, 0, 0, (#MusicQueue * 52) + 15)
end

RefreshPlaylistPage()

--// ========================================================================
--// FOLDER PAGE
--// ========================================================================

CreatePageHeader(
    FolderPage,
    "Folder",
    "Audio library and quick access"
)

local FolderCard = New("Frame", FolderPage)
FolderCard.Size = UDim2.new(1, 0, 0, 220)
FolderCard.BackgroundColor3 = C.DarkBlue2
FolderCard.BackgroundTransparency = 0.08
FolderCard.BorderSizePixel = 0
FolderCard.ZIndex = 16

Corner(FolderCard, 13)
Stroke(FolderCard, C.ToscaGreen, 1, 0.5)

local FolderIcon = New("TextLabel", FolderCard)
FolderIcon.Size = UDim2.new(0, 60, 0, 60)
FolderIcon.Position = UDim2.new(0, 20, 0, 25)
FolderIcon.BackgroundColor3 = C.Black
FolderIcon.BorderSizePixel = 0
FolderIcon.Text = "♫"
FolderIcon.TextColor3 = C.ToscaGreen
FolderIcon.Font = Enum.Font.GothamBold
FolderIcon.TextSize = 28
FolderIcon.ZIndex = 17

Corner(FolderIcon, 14)

local FolderTitle = New("TextLabel", FolderCard)
FolderTitle.Size = UDim2.new(1, -105, 0, 25)
FolderTitle.Position = UDim2.new(0, 95, 0, 25)
FolderTitle.BackgroundTransparency = 1
FolderTitle.Text = "Audio Library"
FolderTitle.TextColor3 = C.White
FolderTitle.Font = Enum.Font.GothamBold
FolderTitle.TextSize = 16
FolderTitle.TextXAlignment = Enum.TextXAlignment.Left
FolderTitle.ZIndex = 17

local FolderDesc = New("TextLabel", FolderCard)
FolderDesc.Size = UDim2.new(1, -105, 0, 45)
FolderDesc.Position = UDim2.new(0, 95, 0, 52)
FolderDesc.BackgroundTransparency = 1
FolderDesc.Text =
    "Tracks loaded into the current Axomusc session."
FolderDesc.TextColor3 = C.Gray
FolderDesc.Font = Enum.Font.Gotham
FolderDesc.TextSize = 11
FolderDesc.TextWrapped = true
FolderDesc.TextXAlignment = Enum.TextXAlignment.Left
FolderDesc.TextYAlignment = Enum.TextYAlignment.Top
FolderDesc.ZIndex = 17

local FolderCount = New("TextLabel", FolderCard)
FolderCount.Size = UDim2.new(1, -40, 0, 25)
FolderCount.Position = UDim2.new(0, 20, 1, -48)
FolderCount.BackgroundTransparency = 1
FolderCount.Text = tostring(#MusicQueue) .. " track(s) loaded"
FolderCount.TextColor3 = C.ToscaGreen
FolderCount.Font = Enum.Font.GothamSemibold
FolderCount.TextSize = 11
FolderCount.TextXAlignment = Enum.TextXAlignment.Left
FolderCount.ZIndex = 17

--// ========================================================================
--// PROFILE PAGE
--// ========================================================================

CreatePageHeader(
    ProfilePage,
    "Profile",
    "Player identity and Axolion session"
)

local ProfileCard = New("Frame", ProfilePage)
ProfileCard.Size = UDim2.new(1, 0, 0, 220)
ProfileCard.BackgroundColor3 = C.DarkBlue2
ProfileCard.BackgroundTransparency = 0.08
ProfileCard.BorderSizePixel = 0
ProfileCard.ZIndex = 16

Corner(ProfileCard, 13)
Stroke(ProfileCard, C.IceBlue, 1, 0.55)

local Avatar = New("ImageLabel", ProfileCard)
Avatar.Size = UDim2.new(0, 90, 0, 90)
Avatar.Position = UDim2.new(0, 20, 0, 20)
Avatar.BackgroundColor3 = C.Black
Avatar.BorderSizePixel = 0
Avatar.Image = Config.SubLogo
Avatar.ZIndex = 18

Corner(Avatar, 45)
Stroke(Avatar, C.ToscaGreen, 2, 0.2)

pcall(function()
    local thumb =
        Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )

    if thumb and thumb ~= "" then
        Avatar.Image = thumb
    end
end)

local ProfileName = New("TextLabel", ProfileCard)
ProfileName.Size = UDim2.new(1, -135, 0, 28)
ProfileName.Position = UDim2.new(0, 125, 0, 25)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = LocalPlayer.DisplayName
ProfileName.TextColor3 = C.White
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextSize = 18
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.ZIndex = 18

local ProfileUsername = New("TextLabel", ProfileCard)
ProfileUsername.Size = UDim2.new(1, -135, 0, 20)
ProfileUsername.Position = UDim2.new(0, 125, 0, 53)
ProfileUsername.BackgroundTransparency = 1
ProfileUsername.Text = "@" .. LocalPlayer.Name
ProfileUsername.TextColor3 = C.ToscaGreen
ProfileUsername.Font = Enum.Font.GothamSemibold
ProfileUsername.TextSize = 11
ProfileUsername.TextXAlignment = Enum.TextXAlignment.Left
ProfileUsername.ZIndex = 18

local ProfileExecutor = New("TextLabel", ProfileCard)
ProfileExecutor.Size = UDim2.new(1, -40, 0, 20)
ProfileExecutor.Position = UDim2.new(0, 20, 1, -55)
ProfileExecutor.BackgroundTransparency = 1
ProfileExecutor.Text = "Executor: " .. Executor.Name
ProfileExecutor.TextColor3 = C.Gray
ProfileExecutor.Font = Enum.Font.Gotham
ProfileExecutor.TextSize = 10
ProfileExecutor.TextXAlignment = Enum.TextXAlignment.Left
ProfileExecutor.ZIndex = 18

local ProfileStatus = New("TextLabel", ProfileCard)
ProfileStatus.Size = UDim2.new(1, -40, 0, 20)
ProfileStatus.Position = UDim2.new(0, 20, 1, -32)
ProfileStatus.BackgroundTransparency = 1
ProfileStatus.Text = "Axomusc session active"
ProfileStatus.TextColor3 = C.ToscaGreen
ProfileStatus.Font = Enum.Font.GothamSemibold
ProfileStatus.TextSize = 10
ProfileStatus.TextXAlignment = Enum.TextXAlignment.Left
ProfileStatus.ZIndex = 18

--// ========================================================================
--// ABOUT PAGE
--// ========================================================================

CreatePageHeader(
    AboutPage,
    "About",
    "Axolion Community ecosystem"
)

local AboutCard = New("Frame", AboutPage)
AboutCard.Size = UDim2.new(1, 0, 0, 260)
AboutCard.BackgroundColor3 = C.DarkBlue2
AboutCard.BackgroundTransparency = 0.08
AboutCard.BorderSizePixel = 0
AboutCard.ZIndex = 16

Corner(AboutCard, 13)
Stroke(AboutCard, C.ToscaGreen, 1.2, 0.4)

local AboutLogo = New("ImageLabel", AboutCard)
AboutLogo.Size = UDim2.new(0, 90, 0, 90)
AboutLogo.Position = UDim2.new(0.5, -45, 0, 20)
AboutLogo.BackgroundTransparency = 1
AboutLogo.Image = Config.MainLogo
AboutLogo.ZIndex = 18

local AboutTitle = New("TextLabel", AboutCard)
AboutTitle.Size = UDim2.new(1, -30, 0, 28)
AboutTitle.Position = UDim2.new(0, 15, 0, 115)
AboutTitle.BackgroundTransparency = 1
AboutTitle.Text = Config.Brand
AboutTitle.TextColor3 = C.IceBlue
AboutTitle.Font = Enum.Font.GothamBold
AboutTitle.TextSize = 17
AboutTitle.TextXAlignment = Enum.TextXAlignment.Center
AboutTitle.ZIndex = 18

local AboutText = New("TextLabel", AboutCard)
AboutText.Size = UDim2.new(1, -45, 0, 55)
AboutText.Position = UDim2.new(0, 22, 0, 150)
AboutText.BackgroundTransparency = 1
AboutText.Text =
    "Axomusc adalah music interface premium dengan tema Dark Blue, Tosca Green, Ice Blue, Black dan White."
AboutText.TextColor3 = C.Gray
AboutText.Font = Enum.Font.Gotham
AboutText.TextSize = 11
AboutText.TextWrapped = true
AboutText.TextXAlignment = Enum.TextXAlignment.Center
AboutText.TextYAlignment = Enum.TextYAlignment.Center
AboutText.ZIndex = 18

local AboutVersion = New("TextLabel", AboutCard)
AboutVersion.Size = UDim2.new(1, -30, 0, 20)
AboutVersion.Position = UDim2.new(0, 15, 1, -30)
AboutVersion.BackgroundTransparency = 1
AboutVersion.Text = "AXOMUSC • PREMIUM CORE"
AboutVersion.TextColor3 = C.ToscaGreen
AboutVersion.Font = Enum.Font.GothamBold
AboutVersion.TextSize = 10
AboutVersion.TextXAlignment = Enum.TextXAlignment.Center
AboutVersion.ZIndex = 18

--// ========================================================================
--// UP INFO PAGE
--// ========================================================================

CreatePageHeader(
    UpInfoPage,
    "Up Info",
    "System information and compatibility"
)

local InfoCard = New("Frame", UpInfoPage)
InfoCard.Size = UDim2.new(1, 0, 0, 280)
InfoCard.BackgroundColor3 = C.DarkBlue2
InfoCard.BackgroundTransparency = 0.08
InfoCard.BorderSizePixel = 0
InfoCard.ZIndex = 16

Corner(InfoCard, 13)
Stroke(InfoCard, C.IceBlue, 1, 0.5)

local InfoTitle = New("TextLabel", InfoCard)
InfoTitle.Size = UDim2.new(1, -30, 0, 25)
InfoTitle.Position = UDim2.new(0, 15, 0, 15)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "System Status"
InfoTitle.TextColor3 = C.White
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextSize = 16
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.ZIndex = 18

local InfoText = New("TextLabel", InfoCard)
InfoText.Size = UDim2.new(1, -30, 0, 200)
InfoText.Position = UDim2.new(0, 15, 0, 50)
InfoText.BackgroundTransparency = 1
InfoText.Text =
    "AXOMUSC STATUS\n\n" ..
    "UI Core       : ONLINE\n" ..
    "Music Engine  : ONLINE\n" ..
    "Queue Engine  : ONLINE\n" ..
    "Tween Engine  : ONLINE\n" ..
    "Touch Input   : ENABLED\n" ..
    "PC Input      : ENABLED\n" ..
    "Executor      : " .. Executor.Name .. "\n\n" ..
    "Compatibility helpers are enabled automatically."
InfoText.TextColor3 = C.Gray
InfoText.Font = Enum.Font.Gotham
InfoText.TextSize = 11
InfoText.TextWrapped = true
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.ZIndex = 18

--// ========================================================================
--// PAGE CANVAS AUTO SIZE
--// ========================================================================

local function UpdatePageCanvas(page)
    if not page then
        return
    end

    local maximum = 0

    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("GuiObject") then
            local bottom =
                child.Position.Y.Offset +
                child.Size.Y.Offset

            if bottom > maximum then
                maximum = bottom
            end
        end
    end

    page.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            maximum + 40
        )
end

for _, page in pairs(Pages) do
    page.ChildAdded:Connect(function()
        task.defer(function()
            UpdatePageCanvas(page)
        end)
    end)

    page.ChildRemoved:Connect(function()
        task.defer(function()
            UpdatePageCanvas(page)
        end)
    end)

    task.defer(function()
        UpdatePageCanvas(page)
    end)
end

--// ========================================================================
--// DRAG SYSTEM
--// ========================================================================

local Dragging = false
local DragStart
local StartPosition
local DragInput

local function UpdateDrag(input)
    if not Dragging then
        return
    end

    if not DragStart or not StartPosition then
        return
    end

    local delta = input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + delta.Y
    )
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
        DragInput = input

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
                DragInput = nil
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input == DragInput then
        UpdateDrag(input)
    end
end)

--// ========================================================================
--// CLOSE
--// ========================================================================

local function CloseUI()
    if State.Destroyed then
        return
    end

    State.Destroyed = true

    Notify(
        "Axomusc",
        "Closing interface...",
        1
    )

    pcall(function()
        Audio:Stop()
    end)

    if MusicConnection then
        pcall(function()
            MusicConnection:Disconnect()
        end)
    end

    Tween(
        Main,
        0.35,
        {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        },
        Enum.EasingStyle.Back,
        Enum.EasingDirection.In
    )

    Tween(
        MainStroke,
        0.25,
        {
            Transparency = 1
        }
    )

    task.delay(0.4, function()
        SafeDestroy(Audio)
        SafeDestroy(Gui)
    end)
end

CloseButton.MouseButton1Click:Connect(CloseUI)

--// ========================================================================
--// INITIAL STATE
--// ========================================================================

SetLayer("Main")
SetPageVisible("Music Panel")

UpdateQueueUI()

--// ========================================================================
--// STARTUP ANIMATION
--// ========================================================================

local OriginalSize = Main.Size

Main.Size = UDim2.new(0, 0, 0, 0)

Tween(
    Main,
    0.5,
    {
        Size = OriginalSize
    },
    Enum.EasingStyle.Back,
    Enum.EasingDirection.Out
)

task.delay(0.55, function()
    if State.Destroyed then
        return
    end

    Notify(
        "Axomusc",
        "Premium UI berhasil dimuat.",
        3
    )
end)

--// ========================================================================
--// GLOBAL COMPATIBILITY OBJECT
--// ========================================================================
--// Sengaja dibuat di akhir agar tidak ada dependency nil seperti versi lama.

_G.Axomusc_Config = Config
_G.Axomusc_UI = Gui
_G.Axomusc_Main = Main
_G.Axomusc_Audio = Audio

_G.Axomusc_Notify = Notify

_G.Axomusc_PlayTrack = PlayTrack
_G.Axomusc_Pause = PauseTrack
_G.Axomusc_Resume = ResumeTrack

_G.Axomusc_MusicQueue = MusicQueue

_G.Axomusc_State = State

--// ========================================================================
--// FINAL SAFE NOTICE
--// ========================================================================

pcall(function()
    if #MusicQueue > 0 then
        local first = MusicQueue[1]

        if first and first.ID then
            StatusLabel.Text = "READY • " .. tostring(#MusicQueue) .. " TRACK"
        end
    end
end)