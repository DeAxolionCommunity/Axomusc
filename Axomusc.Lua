--// ================================================================
--// AXOMUSC PREMIUM UI
--// SINGLE SCRIPT / SELF CONTAINED / ERROR HARDENED
--// Axolion Community (Beta)
--// ================================================================

--// ========================= SERVICES ==============================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--// ========================= CLEAN OLD UI ==========================

pcall(function()
    local old = PlayerGui:FindFirstChild("Axomusc_Premium_UI")
    if old then
        old:Destroy()
    end
end)

pcall(function()
    local old = CoreGui:FindFirstChild("Axomusc_Premium_UI")
    if old then
        old:Destroy()
    end
end)

--// ========================= CONFIG ================================

local Config = {
    Brand = "Axolion Community (Beta)",

    MainLogo = "rbxassetid://85647271976925",
    Thumbnail = "rbxassetid://84404991858137",
    SubLogo = "rbxassetid://100003155958609",

    Discord = "https://discord.gg/dkuXRcS2hY",
    RobloxGroup = "https://www.roblox.com/share/g/245953568",

    Colors = {
        DarkBlue = Color3.fromRGB(5, 10, 30),
        ToscaGreen = Color3.fromRGB(64, 224, 208),
        IceBlue = Color3.fromRGB(175, 238, 238),
        Black = Color3.fromRGB(12, 12, 14),
        White = Color3.fromRGB(245, 245, 250),
        Gray = Color3.fromRGB(135, 145, 160),
        Red = Color3.fromRGB(255, 75, 75),
        Shadow = Color3.fromRGB(0, 0, 0)
    },

    UI = {
        Width = 680,
        Height = 460,
        HeaderHeight = 65,
        LeftBarWidth = 60,
        SidebarWidth = 140
    }
}

--// ========================= STATE =================================

local App = {}

App.MusicQueue = {}
App.CurrentTrackIndex = 0
App.IsPlaying = false
App.PlayMode = 1
App.PlaybackSpeed = 1
App.CurrentCategory = "Main"
App.CurrentPage = nil
App.Destroyed = false

--// ========================= GUI ==================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Axomusc_Premium_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local function ProtectGUI(gui)
    local ok = false

    pcall(function()
        if typeof(gethui) == "function" then
            gui.Parent = gethui()
            ok = true
        end
    end)

    if not ok then
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(gui)
                gui.Parent = CoreGui
                ok = true
            end
        end)
    end

    if not ok then
        pcall(function()
            gui.Parent = CoreGui
            ok = true
        end)
    end

    if not ok then
        gui.Parent = PlayerGui
    end
end

ProtectGUI(ScreenGui)

--// ========================= HELPERS ===============================

local function tween(instance, time, properties, style, direction)
    if not instance or not instance.Parent then
        return nil
    end

    local info = TweenInfo.new(
        time or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )

    local ok, result = pcall(function()
        local t = TweenService:Create(instance, info, properties)
        t:Play()
        return t
    end)

    if ok then
        return result
    end

    return nil
end

local function safeDestroy(instance)
    pcall(function()
        if instance then
            instance:Destroy()
        end
    end)
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Config.Colors.White
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function formatTime(value)
    value = tonumber(value) or 0

    local minutes = math.floor(value / 60)
    local seconds = math.floor(value % 60)

    return string.format("%d:%02d", minutes, seconds)
end

--// ========================= NOTIFICATION ===========================

local NotifyHolder = Instance.new("Frame")
NotifyHolder.Name = "NotificationHolder"
NotifyHolder.Size = UDim2.new(0, 330, 1, -20)
NotifyHolder.Position = UDim2.new(1, -340, 0, 10)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.ZIndex = 1000
NotifyHolder.Parent = ScreenGui

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.FillDirection = Enum.FillDirection.Vertical
NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.Padding = UDim.new(0, 8)
NotifyLayout.Parent = NotifyHolder

function App.Notify(title, text, duration)
    duration = duration or 3

    local box = Instance.new("Frame")
    box.Name = "Notification"
    box.Size = UDim2.new(0, 300, 0, 70)
    box.BackgroundColor3 = Config.Colors.DarkBlue
    box.BackgroundTransparency = 0.04
    box.BorderSizePixel = 0
    box.ZIndex = 1001
    box.Parent = NotifyHolder

    corner(box, 10)

    local st = stroke(
        box,
        Config.Colors.ToscaGreen,
        1.2,
        0.25
    )

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -16)
    bar.Position = UDim2.new(0, 7, 0, 8)
    bar.BackgroundColor3 = Config.Colors.ToscaGreen
    bar.BorderSizePixel = 0
    bar.ZIndex = 1002
    bar.Parent = box
    corner(bar, 2)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -35, 0, 22)
    titleLabel.Position = UDim2.new(0, 20, 0, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = tostring(title or "Axomusc")
    titleLabel.TextColor3 = Config.Colors.IceBlue
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 1002
    titleLabel.Parent = box

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -35, 0, 35)
    body.Position = UDim2.new(0, 20, 0, 29)
    body.BackgroundTransparency = 1
    body.Text = tostring(text or "")
    body.TextColor3 = Config.Colors.White
    body.TextTransparency = 0.1
    body.TextSize = 12
    body.Font = Enum.Font.Gotham
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.ZIndex = 1002
    body.Parent = box

    box.Position = UDim2.new(1, 340, 0, 0)

    tween(
        box,
        0.35,
        {Position = UDim2.new(0, 0, 0, 0)},
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    task.delay(duration, function()
        if not box.Parent then
            return
        end

        tween(
            box,
            0.3,
            {
                Position = UDim2.new(1, 340, 0, 0),
                BackgroundTransparency = 1
            },
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.In
        )

        tween(st, 0.3, {Transparency = 1})
        tween(titleLabel, 0.3, {TextTransparency = 1})
        tween(body, 0.3, {TextTransparency = 1})
        tween(bar, 0.3, {BackgroundTransparency = 1})

        task.delay(0.35, function()
            safeDestroy(box)
        end)
    end)
end

--// ========================= MAIN FRAME ============================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainCanvas"
MainFrame.Size = UDim2.new(
    0,
    Config.UI.Width,
    0,
    Config.UI.Height
)
MainFrame.Position = UDim2.new(0.5, -Config.UI.Width / 2, 0.5, -Config.UI.Height / 2)
MainFrame.BackgroundColor3 = Config.Colors.Black
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = false
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui

corner(MainFrame, 14)

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = MainFrame

local MainStroke = stroke(
    MainFrame,
    Config.Colors.IceBlue,
    2,
    0.1
)

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(0.5, Config.Colors.White),
    ColorSequenceKeypoint.new(1, Config.Colors.ToscaGreen)
})
StrokeGradient.Parent = MainStroke

local MainShadow = Instance.new("ImageLabel")
MainShadow.Name = "Shadow"
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 8)
MainShadow.Size = UDim2.new(1, 40, 1, 40)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://13169336625"
MainShadow.ImageColor3 = Config.Colors.Shadow
MainShadow.ImageTransparency = 0.35
MainShadow.ZIndex = 0
MainShadow.Parent = MainFrame

local ContentClip = Instance.new("Frame")
ContentClip.Name = "MainContentClip"
ContentClip.Size = UDim2.new(1, 0, 1, 0)
ContentClip.BackgroundTransparency = 1
ContentClip.BorderSizePixel = 0
ContentClip.ClipsDescendants = true
ContentClip.ZIndex = 1
ContentClip.Parent = MainFrame

corner(ContentClip, 14)

--// ========================= RESPONSIVE SCALE ======================

local function updateScale()
    local viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)

    local sx = viewport.X / 900
    local sy = viewport.Y / 650

    local scale = math.min(sx, sy)

    UIScale.Scale = math.clamp(scale, 0.45, 1)
end

pcall(updateScale)

if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if not App.Destroyed then
            updateScale()
        end
    end)
end

--// ========================= DRAG SYSTEM ============================

do
    local dragging = false
    local dragStart
    local startPosition
    local dragInput

    local function updateDrag(input)
        if not dragging then
            return
        end

        local delta = input.Position - dragStart

        MainFrame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
end

--// ========================= HEADER ================================

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, Config.UI.HeaderHeight)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Config.Colors.DarkBlue
Header.BorderSizePixel = 0
Header.ZIndex = 20
Header.Parent = ContentClip

local HeaderCorner = corner(Header, 14)

local HeaderBottom = Instance.new("Frame")
HeaderBottom.Size = UDim2.new(1, 0, 0, 15)
HeaderBottom.Position = UDim2.new(0, 0, 1, -15)
HeaderBottom.BackgroundColor3 = Config.Colors.DarkBlue
HeaderBottom.BorderSizePixel = 0
HeaderBottom.ZIndex = 20
HeaderBottom.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -100, 0, 30)
HeaderTitle.Position = UDim2.new(0, 50, 0, 7)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "Axomusc"
HeaderTitle.TextColor3 = Config.Colors.IceBlue
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 25
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Center
HeaderTitle.ZIndex = 22
HeaderTitle.Parent = Header

local HeaderSub = Instance.new("TextLabel")
HeaderSub.Size = UDim2.new(1, -100, 0, 16)
HeaderSub.Position = UDim2.new(0, 50, 0, 38)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Text = "By. " .. Config.Brand
HeaderSub.TextColor3 = Config.Colors.White
HeaderSub.TextTransparency = 0.25
HeaderSub.Font = Enum.Font.GothamSemibold
HeaderSub.TextSize = 11
HeaderSub.TextXAlignment = Enum.TextXAlignment.Center
HeaderSub.ZIndex = 22
HeaderSub.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 45, 0, 45)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "×"
CloseButton.TextColor3 = Config.Colors.White
CloseButton.TextSize = 31
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 25
CloseButton.Parent = Header

CloseButton.MouseEnter:Connect(function()
    tween(CloseButton, 0.15, {
        TextColor3 = Config.Colors.Red
    })
end)

CloseButton.MouseLeave:Connect(function()
    tween(CloseButton, 0.15, {
        TextColor3 = Config.Colors.White
    })
end)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 2)
HeaderLine.Position = UDim2.new(0, 0, 1, -2)
HeaderLine.BackgroundColor3 = Config.Colors.IceBlue
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 25
HeaderLine.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.Black),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.ToscaGreen)
})
HeaderGradient.Parent = HeaderLine

--// ========================= BODY ================================

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(
    1,
    0,
    1,
    -Config.UI.HeaderHeight
)
Body.Position = UDim2.new(
    0,
    0,
    0,
    Config.UI.HeaderHeight
)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.ClipsDescendants = true
Body.ZIndex = 2
Body.Parent = ContentClip

--// ========================= LAYER 1 ===============================

local Layer1 = Instance.new("Frame")
Layer1.Name = "Layer1_IconBar"
Layer1.Size = UDim2.new(0, Config.UI.LeftBarWidth, 1, 0)
Layer1.Position = UDim2.new(0, 0, 0, 0)
Layer1.BackgroundColor3 = Config.Colors.Black
Layer1.BorderSizePixel = 0
Layer1.ZIndex = 10
Layer1.Parent = Body

local Layer1Separator = Instance.new("Frame")
Layer1Separator.Size = UDim2.new(0, 1, 1, 0)
Layer1Separator.Position = UDim2.new(1, -1, 0, 0)
Layer1Separator.BackgroundColor3 = Config.Colors.IceBlue
Layer1Separator.BackgroundTransparency = 0.65
Layer1Separator.BorderSizePixel = 0
Layer1Separator.ZIndex = 15
Layer1Separator.Parent = Layer1

--// Active indicator

local ActiveIndicator = Instance.new("Frame")
ActiveIndicator.Size = UDim2.new(0, 3, 0, 25)
ActiveIndicator.Position = UDim2.new(0, 0, 0, 35)
ActiveIndicator.AnchorPoint = Vector2.new(0, 0.5)
ActiveIndicator.BackgroundColor3 = Config.Colors.ToscaGreen
ActiveIndicator.BorderSizePixel = 0
ActiveIndicator.ZIndex = 18
ActiveIndicator.Parent = Layer1

corner(ActiveIndicator, 4)

--// Hamburger

local Hamburger = Instance.new("TextButton")
Hamburger.Name = "Hamburger"
Hamburger.Size = UDim2.new(0, 40, 0, 40)
Hamburger.Position = UDim2.new(0.5, 0, 0, 35)
Hamburger.AnchorPoint = Vector2.new(0.5, 0.5)
Hamburger.BackgroundTransparency = 1
Hamburger.Text = ""
Hamburger.AutoButtonColor = false
Hamburger.ZIndex = 20
Hamburger.Parent = Layer1

local H1 = Instance.new("Frame")
H1.Size = UDim2.new(0, 20, 0, 2)
H1.Position = UDim2.new(0.5, -10, 0.5, -7)
H1.BackgroundColor3 = Config.Colors.ToscaGreen
H1.BorderSizePixel = 0
H1.ZIndex = 21
H1.Parent = Hamburger

local H2 = Instance.new("Frame")
H2.Size = UDim2.new(0, 20, 0, 2)
H2.Position = UDim2.new(0.5, -10, 0.5, -1)
H2.BackgroundColor3 = Config.Colors.ToscaGreen
H2.BorderSizePixel = 0
H2.ZIndex = 21
H2.Parent = Hamburger

local H3 = Instance.new("Frame")
H3.Size = UDim2.new(0, 20, 0, 2)
H3.Position = UDim2.new(0.5, -10, 0.5, 5)
H3.BackgroundColor3 = Config.Colors.ToscaGreen
H3.BorderSizePixel = 0
H3.ZIndex = 21
H3.Parent = Hamburger

--// Axolion icon

local SpecialButton = Instance.new("ImageButton")
SpecialButton.Name = "AxolionButton"
SpecialButton.Size = UDim2.new(0, 34, 0, 34)
SpecialButton.Position = UDim2.new(0.5, 0, 0, 85)
SpecialButton.AnchorPoint = Vector2.new(0.5, 0.5)
SpecialButton.BackgroundTransparency = 1
SpecialButton.Image = Config.SubLogo
SpecialButton.ImageColor3 = Config.Colors.White
SpecialButton.ImageTransparency = 0.4
SpecialButton.AutoButtonColor = false
SpecialButton.ZIndex = 20
SpecialButton.Parent = Layer1

--// ========================= LAYER 2 ===============================

local Layer2 = Instance.new("Frame")
Layer2.Name = "Layer2_Sidebar"
Layer2.Size = UDim2.new(0, Config.UI.SidebarWidth, 1, 0)
Layer2.Position = UDim2.new(0, Config.UI.LeftBarWidth, 0, 0)
Layer2.BackgroundColor3 = Config.Colors.DarkBlue
Layer2.BackgroundTransparency = 0.25
Layer2.BorderSizePixel = 0
Layer2.ClipsDescendants = true
Layer2.ZIndex = 8
Layer2.Parent = Body

local Layer2Line = Instance.new("Frame")
Layer2Line.Size = UDim2.new(0, 2, 1, 0)
Layer2Line.Position = UDim2.new(1, -2, 0, 0)
Layer2Line.BackgroundColor3 = Config.Colors.ToscaGreen
Layer2Line.BorderSizePixel = 0
Layer2Line.ZIndex = 12
Layer2Line.Parent = Layer2

local Layer2Gradient = Instance.new("UIGradient")
Layer2Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.ToscaGreen),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.ToscaGreen)
})
Layer2Gradient.Rotation = 90
Layer2Gradient.Parent = Layer2Line

local MenuScroll = Instance.new("ScrollingFrame")
MenuScroll.Name = "MenuScroll"
MenuScroll.Size = UDim2.new(1, -3, 1, 0)
MenuScroll.Position = UDim2.new(0, 0, 0, 0)
MenuScroll.BackgroundTransparency = 1
MenuScroll.BorderSizePixel = 0
MenuScroll.ScrollBarThickness = 0
MenuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MenuScroll.ZIndex = 10
MenuScroll.Parent = Layer2

local MenuPadding = Instance.new("UIPadding")
MenuPadding.PaddingTop = UDim.new(0, 10)
MenuPadding.PaddingBottom = UDim.new(0, 10)
MenuPadding.Parent = MenuScroll

local MenuLayout = Instance.new("UIListLayout")
MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
MenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MenuLayout.Padding = UDim.new(0, 7)
MenuLayout.Parent = MenuScroll

MenuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MenuScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        MenuLayout.AbsoluteContentSize.Y + 25
    )
end)

--// ========================= LAYER 3 ===============================

local Layer3 = Instance.new("Frame")
Layer3.Name = "Layer3_Workspace"
Layer3.Size = UDim2.new(
    1,
    -(Config.UI.LeftBarWidth + Config.UI.SidebarWidth),
    1,
    0
)
Layer3.Position = UDim2.new(
    0,
    Config.UI.LeftBarWidth + Config.UI.SidebarWidth,
    0,
    0
)
Layer3.BackgroundTransparency = 1
Layer3.BorderSizePixel = 0
Layer3.ClipsDescendants = true
Layer3.ZIndex = 3
Layer3.Parent = Body

local PageFolder = Instance.new("Folder")
PageFolder.Name = "AllPages"
PageFolder.Parent = Layer3

--// ========================= MENU SYSTEM ===========================

local MenuButtons = {}
local CurrentPage = nil

local function HideAllPages()
    for _, data in ipairs(MenuButtons) do
        if data.Button and data.Button.Parent then
            tween(data.Button, 0.2, {
                BackgroundTransparency = 1
            })

            tween(data.Label, 0.2, {
                TextColor3 = Config.Colors.White,
                TextTransparency = 0.35
            })

            tween(data.Indicator, 0.2, {
                Size = UDim2.new(0, 3, 0, 0)
            })
        end

        if data.Page and data.Page.Parent then
            data.Page.Visible = false
            data.Page.Position = UDim2.new(0, 25, 0, 0)
        end
    end
end

local function OpenPage(data)
    if not data then
        return
    end

    HideAllPages()

    CurrentPage = data.Name
    App.CurrentPage = data.Name

    tween(data.Button, 0.25, {
        BackgroundTransparency = 0.55
    })

    tween(data.Label, 0.25, {
        TextColor3 = Config.Colors.ToscaGreen,
        TextTransparency = 0
    })

    tween(
        data.Indicator,
        0.35,
        {
            Size = UDim2.new(0, 3, 0, 18)
        },
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    )

    data.Page.Visible = true

    tween(
        data.Page,
        0.35,
        {
            Position = UDim2.new(0, 0, 0, 0)
        },
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )
end

local function CreateMenuButton(name, category, order)
    local data = {
        Name = name,
        Category = category
    }

    local Button = Instance.new("TextButton")
    Button.Name = "Menu_" .. name
    Button.Size = UDim2.new(0.86, 0, 0, 34)
    Button.BackgroundColor3 = Config.Colors.Black
    Button.BackgroundTransparency = 1
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.LayoutOrder = order or 1
    Button.ZIndex = 12
    Button.Parent = MenuScroll

    corner(Button, 7)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Config.Colors.White
    Label.TextTransparency = 0.35
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 14
    Label.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Config.Colors.ToscaGreen
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 15
    Indicator.Parent = Button

    corner(Indicator, 4)

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 25, 0, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Config.Colors.ToscaGreen
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.ZIndex = 4
    Page.Parent = PageFolder

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 12)
    PagePadding.PaddingBottom = UDim.new(0, 15)
    PagePadding.PaddingLeft = UDim.new(0, 12)
    PagePadding.PaddingRight = UDim.new(0, 12)
    PagePadding.Parent = Page

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(
            0,
            0,
            0,
            PageLayout.AbsoluteContentSize.Y + 30
        )
    end)

    Button.MouseButton1Click:Connect(function()
        OpenPage(data)
    end)

    Button.MouseEnter:Connect(function()
        if CurrentPage ~= name then
            tween(Button, 0.15, {
                BackgroundTransparency = 0.78
            })
        end
    end)

    Button.MouseLeave:Connect(function()
        if CurrentPage ~= name then
            tween(Button, 0.15, {
                BackgroundTransparency = 1
            })
        end
    end)

    data.Button = Button
    data.Label = Label
    data.Indicator = Indicator
    data.Page = Page

    table.insert(MenuButtons, data)

    return data
end

--// ========================= CREATE PAGES ==========================

local PageMusic = CreateMenuButton("Music Panel", "Main", 1)
local PagePlaylist = CreateMenuButton("Playlist", "Main", 2)
local PageFolder = CreateMenuButton("Folder", "Main", 3)

local PageProfile = CreateMenuButton("Profile", "Special", 4)
local PageAbout = CreateMenuButton("About", "Special", 5)
local PageInfo = CreateMenuButton("Up Info", "Special", 6)

--// ========================= CATEGORY SWITCH ========================

local function SwitchCategory(category)
    local first = nil

    for _, data in ipairs(MenuButtons) do
        if data.Category == category then
            data.Button.Visible = true

            if not first then
                first = data
            end
        else
            data.Button.Visible = false
        end
    end

    if first then
        OpenPage(first)
    end
end

--// ========================= LAYER 1 LOGIC ==========================

local CurrentLayer = "Main"

local function SetLayer(category)
    CurrentLayer = category

    if category == "Main" then
        tween(
            ActiveIndicator,
            0.35,
            {Position = UDim2.new(0, 0, 0, 35)},
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        )

        tween(H1, 0.2, {
            BackgroundColor3 = Config.Colors.ToscaGreen
        })

        tween(H2, 0.2, {
            BackgroundColor3 = Config.Colors.ToscaGreen
        })

        tween(H3, 0.2, {
            BackgroundColor3 = Config.Colors.ToscaGreen
        })

        tween(SpecialButton, 0.2, {
            ImageColor3 = Config.Colors.White,
            ImageTransparency = 0.4
        })

    else
        tween(
            ActiveIndicator,
            0.35,
            {Position = UDim2.new(0, 0, 0, 85)},
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        )

        tween(H1, 0.2, {
            BackgroundColor3 = Config.Colors.White
        })

        tween(H2, 0.2, {
            BackgroundColor3 = Config.Colors.White
        })

        tween(H3, 0.2, {
            BackgroundColor3 = Config.Colors.White
        })

        tween(SpecialButton, 0.2, {
            ImageColor3 = Config.Colors.ToscaGreen,
            ImageTransparency = 0
        })
    end

    SwitchCategory(category)
end

Hamburger.MouseEnter:Connect(function()
    tween(H1, 0.15, {Size = UDim2.new(0, 24, 0, 2)})
    tween(H2, 0.15, {Size = UDim2.new(0, 24, 0, 2)})
    tween(H3, 0.15, {Size = UDim2.new(0, 24, 0, 2)})
end)

Hamburger.MouseLeave:Connect(function()
    tween(H1, 0.15, {Size = UDim2.new(0, 20, 0, 2)})
    tween(H2, 0.15, {Size = UDim2.new(0, 20, 0, 2)})
    tween(H3, 0.15, {Size = UDim2.new(0, 20, 0, 2)})
end)

SpecialButton.MouseEnter:Connect(function()
    tween(SpecialButton, 0.15, {
        Size = UDim2.new(0, 38, 0, 38),
        ImageTransparency = 0
    })
end)

SpecialButton.MouseLeave:Connect(function()
    if CurrentLayer ~= "Special" then
        tween(SpecialButton, 0.15, {
            Size = UDim2.new(0, 34, 0, 34),
            ImageTransparency = 0.4
        })
    end
end)

Hamburger.MouseButton1Click:Connect(function()
    SetLayer("Main")
end)

SpecialButton.MouseButton1Click:Connect(function()
    SetLayer("Special")
end)

--// ========================= MUSIC ENGINE ==========================

local AudioCore = Instance.new("Sound")
AudioCore.Name = "Axomusc_AudioEngine"
AudioCore.Volume = 1
AudioCore.Looped = false
AudioCore.PlaybackSpeed = 1
AudioCore.Parent = SoundService

--// ========================= MUSIC PAGE =============================

local MusicPage = PageMusic.Page

--// Now Playing Card

local NowPlayingCard = Instance.new("Frame")
NowPlayingCard.Name = "NowPlayingCard"
NowPlayingCard.Size = UDim2.new(1, 0, 0, 150)
NowPlayingCard.BackgroundColor3 = Config.Colors.DarkBlue
NowPlayingCard.BackgroundTransparency = 0.08
NowPlayingCard.BorderSizePixel = 0
NowPlayingCard.LayoutOrder = 1
NowPlayingCard.ZIndex = 5
NowPlayingCard.Parent = MusicPage

corner(NowPlayingCard, 14)

local CardStroke = stroke(
    NowPlayingCard,
    Config.Colors.ToscaGreen,
    1.4,
    0.5
)

--// Queue button

local BtnQueue = Instance.new("TextButton")
BtnQueue.Name = "QueueButton"
BtnQueue.Size = UDim2.new(0, 35, 0, 35)
BtnQueue.Position = UDim2.new(1, -45, 0, 12)
BtnQueue.BackgroundColor3 = Config.Colors.Black
BtnQueue.BackgroundTransparency = 0.25
BtnQueue.Text = "≡"
BtnQueue.TextColor3 = Config.Colors.White
BtnQueue.Font = Enum.Font.GothamBold
BtnQueue.TextSize = 20
BtnQueue.AutoButtonColor = false
BtnQueue.ZIndex = 15
BtnQueue.Parent = NowPlayingCard

corner(BtnQueue, 8)
stroke(BtnQueue, Config.Colors.ToscaGreen, 1, 0.35)

--// Album

local AlbumBg = Instance.new("Frame")
AlbumBg.Name = "Album"
AlbumBg.Size = UDim2.new(0, 105, 0, 105)
AlbumBg.Position = UDim2.new(0, 20, 0.5, 0)
AlbumBg.AnchorPoint = Vector2.new(0, 0.5)
AlbumBg.BackgroundColor3 = Config.Colors.Black
AlbumBg.BorderSizePixel = 0
AlbumBg.ZIndex = 7
AlbumBg.Parent = NowPlayingCard

corner(AlbumBg, 100)
stroke(AlbumBg, Config.Colors.IceBlue, 1, 0.25)

local AlbumCD = Instance.new("ImageLabel")
AlbumCD.Name = "AlbumImage"
AlbumCD.Size = UDim2.new(1, -4, 1, -4)
AlbumCD.Position = UDim2.new(0.5, 0, 0.5, 0)
AlbumCD.AnchorPoint = Vector2.new(0.5, 0.5)
AlbumCD.BackgroundTransparency = 1
AlbumCD.Image = Config.Thumbnail
AlbumCD.ScaleType = Enum.ScaleType.Crop
AlbumCD.ZIndex = 8
AlbumCD.Parent = AlbumBg

corner(AlbumCD, 100)

local CDHole = Instance.new("Frame")
CDHole.Size = UDim2.new(0, 18, 0, 18)
CDHole.Position = UDim2.new(0.5, 0, 0.5, 0)
CDHole.AnchorPoint = Vector2.new(0.5, 0.5)
CDHole.BackgroundColor3 = Config.Colors.DarkBlue
CDHole.BorderSizePixel = 0
CDHole.ZIndex = 10
CDHole.Parent = AlbumCD

corner(CDHole, 20)

--// Bass ring

local BassRing = Instance.new("Frame")
BassRing.Size = UDim2.new(1, 14, 1, 14)
BassRing.Position = UDim2.new(0.5, 0, 0.5, 0)
BassRing.AnchorPoint = Vector2.new(0.5, 0.5)
BassRing.BackgroundTransparency = 1
BassRing.BorderSizePixel = 0
BassRing.ZIndex = 6
BassRing.Parent = AlbumBg

corner(BassRing, 100)

local BassStroke = stroke(
    BassRing,
    Config.Colors.ToscaGreen,
    2,
    0.1
)

local BassGradient = Instance.new("UIGradient")
BassGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.ToscaGreen),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.White)
})
BassGradient.Parent = BassStroke

--// Song information

local SongTitle = Instance.new("TextLabel")
SongTitle.Size = UDim2.new(1, -205, 0, 30)
SongTitle.Position = UDim2.new(0, 145, 0, 20)
SongTitle.BackgroundTransparency = 1
SongTitle.Text = "No Track Selected"
SongTitle.TextColor3 = Config.Colors.White
SongTitle.Font = Enum.Font.GothamBold
SongTitle.TextSize = 19
SongTitle.TextXAlignment = Enum.TextXAlignment.Left
SongTitle.TextTruncate = Enum.TextTruncate.AtEnd
SongTitle.ZIndex = 10
SongTitle.Parent = NowPlayingCard

local SongArtist = Instance.new("TextLabel")
SongArtist.Size = UDim2.new(1, -205, 0, 20)
SongArtist.Position = UDim2.new(0, 145, 0, 50)
SongArtist.BackgroundTransparency = 1
SongArtist.Text = "Axolion Community"
SongArtist.TextColor3 = Config.Colors.ToscaGreen
SongArtist.Font = Enum.Font.GothamSemibold
SongArtist.TextSize = 12
SongArtist.TextXAlignment = Enum.TextXAlignment.Left
SongArtist.ZIndex = 10
SongArtist.Parent = NowPlayingCard

--// Progress

local ProgressContainer = Instance.new("Frame")
ProgressContainer.Size = UDim2.new(1, -165, 0, 30)
ProgressContainer.Position = UDim2.new(0, 145, 0, 91)
ProgressContainer.BackgroundTransparency = 1
ProgressContainer.ZIndex = 10
ProgressContainer.Parent = NowPlayingCard

local ProgressBackground = Instance.new("TextButton")
ProgressBackground.Size = UDim2.new(1, 0, 0, 5)
ProgressBackground.Position = UDim2.new(0, 0, 0, 5)
ProgressBackground.BackgroundColor3 = Config.Colors.Black
ProgressBackground.BorderSizePixel = 0
ProgressBackground.Text = ""
ProgressBackground.AutoButtonColor = false
ProgressBackground.ZIndex = 11
ProgressBackground.Parent = ProgressContainer

corner(ProgressBackground, 5)

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Config.Colors.ToscaGreen
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 12
ProgressFill.Parent = ProgressBackground

corner(ProgressFill, 5)

local ProgressKnob = Instance.new("Frame")
ProgressKnob.Size = UDim2.new(0, 12, 0, 12)
ProgressKnob.Position = UDim2.new(1, 0, 0.5, 0)
ProgressKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressKnob.BackgroundColor3 = Config.Colors.White
ProgressKnob.BorderSizePixel = 0
ProgressKnob.ZIndex = 13
ProgressKnob.Parent = ProgressFill

corner(ProgressKnob, 20)

local TimeCurrent = Instance.new("TextLabel")
TimeCurrent.Size = UDim2.new(0, 50, 0, 14)
TimeCurrent.Position = UDim2.new(0, 0, 0, 12)
TimeCurrent.BackgroundTransparency = 1
TimeCurrent.Text = "0:00"
TimeCurrent.TextColor3 = Config.Colors.White
TimeCurrent.Font = Enum.Font.Gotham
TimeCurrent.TextSize = 10
TimeCurrent.TextXAlignment = Enum.TextXAlignment.Left
TimeCurrent.ZIndex = 12
TimeCurrent.Parent = ProgressContainer

local TimeTotal = Instance.new("TextLabel")
TimeTotal.Size = UDim2.new(0, 50, 0, 14)
TimeTotal.Position = UDim2.new(1, -50, 0, 12)
TimeTotal.BackgroundTransparency = 1
TimeTotal.Text = "0:00"
TimeTotal.TextColor3 = Config.Colors.White
TimeTotal.Font = Enum.Font.Gotham
TimeTotal.TextSize = 10
TimeTotal.TextXAlignment = Enum.TextXAlignment.Right
TimeTotal.ZIndex = 12
TimeTotal.Parent = ProgressContainer

--// Progress seek

local progressDragging = false

ProgressBackground.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        progressDragging = true

        local pct = math.clamp(
            (input.Position.X - ProgressBackground.AbsolutePosition.X)
            / math.max(ProgressBackground.AbsoluteSize.X, 1),
            0,
            1
        )

        ProgressFill.Size = UDim2.new(pct, 0, 1, 0)

        if AudioCore.TimeLength > 0 then
            AudioCore.TimePosition = pct * AudioCore.TimeLength
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not progressDragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local pct = math.clamp(
            (input.Position.X - ProgressBackground.AbsolutePosition.X)
            / math.max(ProgressBackground.AbsoluteSize.X, 1),
            0,
            1
        )

        ProgressFill.Size = UDim2.new(pct, 0, 1, 0)

        if AudioCore.TimeLength > 0 then
            AudioCore.TimePosition = pct * AudioCore.TimeLength
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        progressDragging = false
    end
end)

--// ========================= CONTROL PANEL =========================

local ControlPanel = Instance.new("Frame")
ControlPanel.Name = "ControlPanel"
ControlPanel.Size = UDim2.new(1, 0, 0, 82)
ControlPanel.BackgroundColor3 = Config.Colors.Black
ControlPanel.BackgroundTransparency = 0.35
ControlPanel.BorderSizePixel = 0
ControlPanel.LayoutOrder = 2
ControlPanel.ClipsDescendants = true
ControlPanel.ZIndex = 5
ControlPanel.Parent = MusicPage

corner(ControlPanel, 12)

local ControlStroke = stroke(
    ControlPanel,
    Config.Colors.ToscaGreen,
    1,
    0.65
)

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlLayout.Padding = UDim.new(0, 12)
ControlLayout.Parent = ControlPanel

local function CreateControlButton(name, text, size, textSize, order, primary)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, size, 0, size)
    button.LayoutOrder = order
    button.BackgroundColor3 = primary
        and Config.Colors.ToscaGreen
        or Config.Colors.DarkBlue
    button.BackgroundTransparency = primary and 0 or 0.15
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = primary
        and Config.Colors.Black
        or Config.Colors.White
    button.Font = Enum.Font.GothamBold
    button.TextSize = textSize
    button.AutoButtonColor = false
    button.ZIndex = 10
    button.Parent = ControlPanel

    corner(button, 100)

    if not primary then
        stroke(button, Config.Colors.White, 1, 0.65)
    end

    button.MouseEnter:Connect(function()
        tween(button, 0.12, {
            Size = UDim2.new(0, size + 4, 0, size + 4)
        })
    end)

    button.MouseLeave:Connect(function()
        tween(button, 0.12, {
            Size = UDim2.new(0, size, 0, size)
        })
    end)

    return button
end

local BtnTempo = CreateControlButton(
    "BtnTempo",
    "⏱",
    43,
    17,
    1,
    false
)

local BtnPrev = CreateControlButton(
    "BtnPrev",
    "◀◀",
    48,
    15,
    2,
    false
)

local BtnPlay = CreateControlButton(
    "BtnPlay",
    "▶",
    62,
    24,
    3,
    true
)

local BtnNext = CreateControlButton(
    "BtnNext",
    "▶▶",
    48,
    15,
    4,
    false
)

local BtnPlayMode = CreateControlButton(
    "BtnPlayMode",
    "↻",
    43,
    20,
    5,
    false
)

--// ========================= TEMPO PANEL ===========================

local TempoContainer = Instance.new("Frame")
TempoContainer.Name = "TempoContainer"
TempoContainer.Size = UDim2.new(0, 200, 0, 45)
TempoContainer.Position = UDim2.new(0.5, -100, 0, 110)
TempoContainer.BackgroundColor3 = Config.Colors.DarkBlue
TempoContainer.BackgroundTransparency = 0.05
TempoContainer.BorderSizePixel = 0
TempoContainer.Visible = false
TempoContainer.ClipsDescendants = true
TempoContainer.ZIndex = 30
TempoContainer.Parent = MusicPage

corner(TempoContainer, 10)
stroke(TempoContainer, Config.Colors.ToscaGreen, 1, 0.3)

local TempoLayout = Instance.new("UIListLayout")
TempoLayout.FillDirection = Enum.FillDirection.Horizontal
TempoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TempoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TempoLayout.Padding = UDim.new(0, 7)
TempoLayout.Parent = TempoContainer

local TempoButtons = {}

for _, speed in ipairs({0.5, 1, 1.5, 2}) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 40, 0, 29)
    b.BackgroundColor3 = speed == 1
        and Config.Colors.ToscaGreen
        or Config.Colors.Black
    b.BorderSizePixel = 0
    b.Text = tostring(speed) .. "x"
    b.TextColor3 = speed == 1
        and Config.Colors.Black
        or Config.Colors.White
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.AutoButtonColor = false
    b.ZIndex = 31
    b.Parent = TempoContainer

    corner(b, 6)

    table.insert(TempoButtons, {
        Button = b,
        Speed = speed
    })

    b.MouseButton1Click:Connect(function()
        AudioCore.PlaybackSpeed = speed
        App.PlaybackSpeed = speed

        for _, item in ipairs(TempoButtons) do
            item.Button.BackgroundColor3 = Config.Colors.Black
            item.Button.TextColor3 = Config.Colors.White
        end

        b.BackgroundColor3 = Config.Colors.ToscaGreen
        b.TextColor3 = Config.Colors.Black

        App.Notify(
            "Tempo",
            "Playback Speed: " .. tostring(speed) .. "x",
            2
        )

        tween(
            TempoContainer,
            0.25,
            {Size = UDim2.new(0, 200, 0, 0)}
        )

        task.delay(0.25, function()
            if TempoContainer.Parent then
                TempoContainer.Visible = false
            end
        end)
    end)
end

BtnTempo.MouseButton1Click:Connect(function()
    if TempoContainer.Visible then
        tween(
            TempoContainer,
            0.25,
            {Size = UDim2.new(0, 200, 0, 0)}
        )

        task.delay(0.25, function()
            if TempoContainer.Parent then
                TempoContainer.Visible = false
            end
        end)
    else
        TempoContainer.Visible = true
        TempoContainer.Size = UDim2.new(0, 200, 0, 0)

        tween(
            TempoContainer,
            0.3,
            {Size = UDim2.new(0, 200, 0, 45)},
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        )
    end
end)

--// ========================= QUEUE ================================

local QueueContainer = Instance.new("Frame")
QueueContainer.Name = "QueueContainer"
QueueContainer.Size = UDim2.new(1, 0, 0, 0)
QueueContainer.Position = UDim2.new(0, 0, 0, 165)
QueueContainer.BackgroundColor3 = Config.Colors.DarkBlue
QueueContainer.BackgroundTransparency = 0.15
QueueContainer.BorderSizePixel = 0
QueueContainer.ClipsDescendants = true
QueueContainer.ZIndex = 20
QueueContainer.Parent = MusicPage

corner(QueueContainer, 11)

local QueueStroke = stroke(
    QueueContainer,
    Config.Colors.ToscaGreen,
    1,
    1
)

local QueueScroll = Instance.new("ScrollingFrame")
QueueScroll.Name = "QueueScroll"
QueueScroll.Size = UDim2.new(1, -10, 1, -10)
QueueScroll.Position = UDim2.new(0, 5, 0, 5)
QueueScroll.BackgroundTransparency = 1
QueueScroll.BorderSizePixel = 0
QueueScroll.ScrollBarThickness = 3
QueueScroll.ScrollBarImageColor3 = Config.Colors.ToscaGreen
QueueScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
QueueScroll.ZIndex = 21
QueueScroll.Parent = QueueContainer

local QueueLayout = Instance.new("UIListLayout")
QueueLayout.SortOrder = Enum.SortOrder.LayoutOrder
QueueLayout.Padding = UDim.new(0, 6)
QueueLayout.Parent = QueueScroll

QueueLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    QueueScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        QueueLayout.AbsoluteContentSize.Y + 10
    )
end)

local QueueOpen = false

local function SetQueueVisible(state)
    QueueOpen = state

    if state then
        BtnQueue.BackgroundColor3 = Config.Colors.ToscaGreen
        BtnQueue.TextColor3 = Config.Colors.Black

        QueueStroke.Transparency = 0.1
        ControlStroke.Transparency = 1

        tween(
            ControlPanel,
            0.35,
            {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            },
            Enum.EasingStyle.Quart
        )

        tween(
            QueueContainer,
            0.4,
            {
                Size = UDim2.new(1, 0, 1, -165)
            },
            Enum.EasingStyle.Quart
        )
    else
        BtnQueue.BackgroundColor3 = Config.Colors.Black
        BtnQueue.TextColor3 = Config.Colors.White

        QueueStroke.Transparency = 1
        ControlStroke.Transparency = 0.65

        tween(
            QueueContainer,
            0.35,
            {
                Size = UDim2.new(1, 0, 0, 0)
            },
            Enum.EasingStyle.Quart
        )

        tween(
            ControlPanel,
            0.35,
            {
                Size = UDim2.new(1, 0, 0, 82),
                BackgroundTransparency = 0.35
            },
            Enum.EasingStyle.Quart
        )
    end
end

BtnQueue.MouseButton1Click:Connect(function()
    SetQueueVisible(not QueueOpen)
end)

--// ========================= QUEUE UI ==============================

function App.UpdateQueueUI()
    for _, child in ipairs(QueueScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    for index, track in ipairs(App.MusicQueue) do
        local item = Instance.new("Frame")
        item.Name = "QueueItem_" .. index
        item.Size = UDim2.new(1, -5, 0, 42)
        item.BackgroundColor3 = Config.Colors.Black
        item.BackgroundTransparency = 0.35
        item.BorderSizePixel = 0
        item.LayoutOrder = index
        item.ZIndex = 23
        item.Parent = QueueScroll

        corner(item, 8)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -55, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = tostring(index) .. ". " .. tostring(track.Title)
        title.TextColor3 = Config.Colors.White
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 12
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.ZIndex = 24
        title.Parent = item

        local play = Instance.new("TextButton")
        play.Size = UDim2.new(0, 28, 0, 28)
        play.Position = UDim2.new(1, -35, 0.5, 0)
        play.AnchorPoint = Vector2.new(0, 0.5)
        play.BackgroundColor3 = Config.Colors.DarkBlue
        play.BorderSizePixel = 0
        play.Text = "▶"
        play.TextColor3 = Config.Colors.White
        play.Font = Enum.Font.GothamBold
        play.TextSize = 11
        play.AutoButtonColor = false
        play.ZIndex = 25
        play.Parent = item

        corner(play, 100)

        play.MouseButton1Click:Connect(function()
            App.PlayTrack(index)
        end)

        item.MouseEnter:Connect(function()
            tween(item, 0.12, {
                BackgroundColor3 = Config.Colors.DarkBlue
            })
        end)

        item.MouseLeave:Connect(function()
            if index ~= App.CurrentTrackIndex then
                tween(item, 0.12, {
                    BackgroundColor3 = Config.Colors.Black
                })
            end
        end)
    end
end

--// ========================= PLAY TRACK ============================

function App.PlayTrack(index)
    if #App.MusicQueue <= 0 then
        App.Notify(
            "Playlist Kosong",
            "Tambahkan lagu terlebih dahulu.",
            2.5
        )
        return
    end

    index = tonumber(index) or 1

    if index < 1 then
        index = #App.MusicQueue
    end

    if index > #App.MusicQueue then
        index = 1
    end

    local track = App.MusicQueue[index]

    if not track then
        return
    end

    App.CurrentTrackIndex = index

    SongTitle.Text = tostring(track.Title or "Unknown Track")
    SongArtist.Text = tostring(track.Artist or "Unknown Artist")

    local id = tostring(track.ID or "")

    if id == "" then
        App.Notify(
            "Audio Error",
            "Sound ID tidak valid.",
            3
        )
        return
    end

    if string.find(id, "rbxassetid://", 1, true) then
        AudioCore.SoundId = id
    else
        AudioCore.SoundId = "rbxassetid://" .. id
    end

    AudioCore.PlaybackSpeed = App.PlaybackSpeed

    pcall(function()
        AudioCore:Stop()
    end)

    pcall(function()
        AudioCore.TimePosition = 0
    end)

    local ok = pcall(function()
        AudioCore:Play()
    end)

    if not ok then
        App.Notify(
            "Audio Error",
            "Roblox gagal memainkan audio ini.",
            3
        )
        return
    end

    App.IsPlaying = true

    BtnPlay.Text = "Ⅱ"

    tween(
        BtnPlay,
        0.2,
        {BackgroundColor3 = Config.Colors.ToscaGreen}
    )

    App.UpdateQueueUI()

    App.Notify(
        "Now Playing",
        tostring(track.Title or "Unknown"),
        2.5
    )
end

--// ========================= PLAY / PAUSE ==========================

BtnPlay.MouseButton1Click:Connect(function()
    if #App.MusicQueue == 0 then
        App.Notify(
            "Daftar Kosong",
            "Tambahkan lagu ke playlist terlebih dahulu.",
            3
        )
        return
    end

    if App.IsPlaying then
        pcall(function()
            AudioCore:Pause()
        end)

        App.IsPlaying = false
        BtnPlay.Text = "▶"

        tween(
            BtnPlay,
            0.2,
            {BackgroundColor3 = Config.Colors.ToscaGreen}
        )
    else
        if AudioCore.SoundId == "" then
            App.PlayTrack(
                App.CurrentTrackIndex > 0
                and App.CurrentTrackIndex
                or 1
            )
        else
            pcall(function()
                AudioCore:Resume()
            end)

            App.IsPlaying = true
            BtnPlay.Text = "Ⅱ"

            tween(
                BtnPlay,
                0.2,
                {BackgroundColor3 = Config.Colors.ToscaGreen}
            )
        end
    end
end)

--// ========================= NEXT ==================================

local function PlayNext()
    if #App.MusicQueue == 0 then
        return
    end

    if App.PlayMode == 3 then
        if #App.MusicQueue == 1 then
            App.PlayTrack(1)
        else
            local nextIndex = App.CurrentTrackIndex

            repeat
                nextIndex = math.random(1, #App.MusicQueue)
            until nextIndex ~= App.CurrentTrackIndex

            App.PlayTrack(nextIndex)
        end
    else
        App.PlayTrack(App.CurrentTrackIndex + 1)
    end
end

local