--// ================================================================
--// AXOMUSC PREMIUM MUSIC UI
--// SINGLE SCRIPT / ERROR-HARDENED BUILD
--// Axolion Community (Beta)
--// ================================================================

--// ================================================================
--// SAFE ENVIRONMENT
--// ================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = workspace.CurrentCamera

if not Camera then
    workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    Camera = workspace.CurrentCamera
end

--// ================================================================
--// CLEAN OLD UI
--// ================================================================

pcall(function()
    local oldNames = {
        "Axomusc_Premium_UI",
        "Axomusc_AudioEngine"
    }

    for _, name in ipairs(oldNames) do
        local a = PlayerGui:FindFirstChild(name)
        if a then
            a:Destroy()
        end

        local b = SoundService:FindFirstChild(name)
        if b then
            b:Destroy()
        end

        local c = game:GetService("CoreGui"):FindFirstChild(name)
        if c then
            c:Destroy()
        end
    end
end)

--// ================================================================
--// CONFIG
--// ================================================================

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
        Shadow = Color3.fromRGB(0, 0, 0),
        Red = Color3.fromRGB(255, 75, 75)
    },

    UI_Settings = {
        TweenTime = 0.45,
        BaseWidth = 1920,
        BaseHeight = 1080
    }
}

_G.Axomusc_Config = Config

--// ================================================================
--// SAFE HELPERS
--// ================================================================

local function safeDestroy(obj)
    pcall(function()
        if obj then
            obj:Destroy()
        end
    end)
end

local function safeTween(obj, info, properties)
    if not obj then
        return nil
    end

    local success, tween = pcall(function()
        return TweenService:Create(obj, info, properties)
    end)

    if success and tween then
        pcall(function()
            tween:Play()
        end)
        return tween
    end

    return nil
end

local function new(className, parent)
    local object = Instance.new(className)

    if parent then
        object.Parent = parent
    end

    return object
end

local function corner(parent, radius)
    local c = new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius)
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = new("UIStroke", parent)
    s.Color = color or Config.Colors.White
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    return s
end

local function formatTime(seconds)
    seconds = tonumber(seconds) or 0

    if seconds < 0 then
        seconds = 0
    end

    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)

    return string.format("%d:%02d", minutes, secs)
end

local function getGuiParent()
    local gui

    pcall(function()
        if type(gethui) == "function" then
            gui = gethui()
        end
    end)

    if gui then
        return gui
    end

    pcall(function()
        if syn and type(syn.protect_gui) == "function" then
            return game:GetService("CoreGui")
        end
    end)

    return PlayerGui
end

--// ================================================================
--// GLOBAL APP STATE
--// ================================================================

local App = {
    MusicQueue = {},
    CurrentTrackIndex = 0,
    IsPlaying = false,
    PlayMode = 1,
    Destroyed = false
}

_G.Axomusc_App = App

--// ================================================================
--// SCREEN GUI
--// ================================================================

local AxomuscUI = new("ScreenGui")
AxomuscUI.Name = "Axomusc_Premium_UI"
AxomuscUI.ResetOnSpawn = false
AxomuscUI.IgnoreGuiInset = true
AxomuscUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AxomuscUI.DisplayOrder = 999999

local guiParent = getGuiParent()

pcall(function()
    if syn and type(syn.protect_gui) == "function" and guiParent == game:GetService("CoreGui") then
        syn.protect_gui(AxomuscUI)
    end
end)

AxomuscUI.Parent = guiParent

--// ================================================================
--// NOTIFICATION
--// ================================================================

local NotificationHolder = new("Frame", AxomuscUI)
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.Size = UDim2.new(0, 340, 1, -20)
NotificationHolder.Position = UDim2.new(1, -350, 0, 10)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.ZIndex = 10000

local NotificationLayout = new("UIListLayout", NotificationHolder)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationLayout.Padding = UDim.new(0, 8)

local function Notify(title, text, duration)
    duration = tonumber(duration) or 3

    pcall(function()
        if App.Destroyed then
            return
        end

        local box = new("Frame", NotificationHolder)
        box.Name = "Notification"
        box.Size = UDim2.new(0, 320, 0, 78)
        box.BackgroundColor3 = Config.Colors.DarkBlue
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.ZIndex = 10001

        corner(box, 12)

        local boxStroke = stroke(
            box,
            Config.Colors.IceBlue,
            1.3,
            1
        )

        local accent = new("Frame", box)
        accent.Size = UDim2.new(0, 3, 1, -20)
        accent.Position = UDim2.new(0, 10, 0, 10)
        accent.BackgroundColor3 = Config.Colors.ToscaGreen
        accent.BorderSizePixel = 0
        accent.ZIndex = 10002

        corner(accent, 2)

        local titleLabel = new("TextLabel", box)
        titleLabel.Size = UDim2.new(1, -40, 0, 24)
        titleLabel.Position = UDim2.new(0, 25, 0, 9)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = tostring(title or "Axomusc")
        titleLabel.TextColor3 = Config.Colors.IceBlue
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 10003

        local textLabel = new("TextLabel", box)
        textLabel.Size = UDim2.new(1, -40, 0, 38)
        textLabel.Position = UDim2.new(0, 25, 0, 32)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = tostring(text or "")
        textLabel.TextColor3 = Config.Colors.White
        textLabel.TextTransparency = 0.1
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextSize = 12
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.ZIndex = 10003

        safeTween(
            box,
            TweenInfo.new(
                0.35,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                BackgroundTransparency = 0.05
            }
        )

        safeTween(
            boxStroke,
            TweenInfo.new(0.35),
            {
                Transparency = 0.15
            }
        )

        task.delay(duration, function()
            if not box or not box.Parent then
                return
            end

            safeTween(
                box,
                TweenInfo.new(
                    0.3,
                    Enum.EasingStyle.Quart,
                    Enum.EasingDirection.In
                ),
                {
                    BackgroundTransparency = 1
                }
            )

            safeTween(
                boxStroke,
                TweenInfo.new(0.3),
                {
                    Transparency = 1
                }
            )

            safeTween(
                titleLabel,
                TweenInfo.new(0.3),
                {
                    TextTransparency = 1
                }
            )

            safeTween(
                textLabel,
                TweenInfo.new(0.3),
                {
                    TextTransparency = 1
                }
            )

            task.delay(0.35, function()
                safeDestroy(box)
            end)
        end)
    end)
end

App.Notify = Notify
_G.Axomusc_Notify = Notify

--// ================================================================
--// MAIN FRAME
--// ================================================================

local MainFrame = new("Frame", AxomuscUI)
MainFrame.Name = "MainCanvas_Workspace"
MainFrame.Size = UDim2.new(0, 680, 0, 460)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Config.Colors.Black
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = false
MainFrame.ZIndex = 1

corner(MainFrame, 14)

local MainStroke = stroke(
    MainFrame,
    Config.Colors.IceBlue,
    2.2,
    0.15
)

--// Gradient HARUS berada pada GuiObject, bukan UIStroke
local MainStrokeGlow = new("Frame", MainFrame)
MainStrokeGlow.Name = "AnimatedBorder"
MainStrokeGlow.Size = UDim2.new(1, 0, 1, 0)
MainStrokeGlow.BackgroundTransparency = 1
MainStrokeGlow.ZIndex = 0
MainStrokeGlow.Parent = MainFrame

corner(MainStrokeGlow, 14)

local BorderGradient = new("UIGradient", MainStrokeGlow)
BorderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.ToscaGreen),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.ToscaGreen)
})

--// ================================================================
--// UISCALE
--// ================================================================

local UIScale = new("UIScale", MainFrame)

local function updateScale()
    pcall(function()
        Camera = workspace.CurrentCamera or Camera

        if not Camera then
            return
        end

        local viewport = Camera.ViewportSize

        if viewport.X <= 0 or viewport.Y <= 0 then
            return
        end

        local scaleX = viewport.X / Config.UI_Settings.BaseWidth
        local scaleY = viewport.Y / Config.UI_Settings.BaseHeight

        local scale = math.min(scaleX, scaleY)

        UIScale.Scale = math.clamp(
            scale * 1.5,
            0.45,
            1.25
        )
    end)
end

updateScale()

pcall(function()
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end)

pcall(function()
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        Camera = workspace.CurrentCamera or Camera
        updateScale()
    end)
end)

--// ================================================================
--// SHADOW
--// ================================================================

local MainShadow = new("ImageLabel", MainFrame)
MainShadow.Name = "DropShadow"
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 8)
MainShadow.Size = UDim2.new(1, 45, 1, 45)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://13169336625"
MainShadow.ImageColor3 = Config.Colors.Shadow
MainShadow.ImageTransparency = 0.45
MainShadow.ZIndex = 0

--// ================================================================
--// CONTENT CLIP
--// ================================================================

local MainClip = new("Frame", MainFrame)
MainClip.Name = "ContentClip"
MainClip.Size = UDim2.new(1, 0, 1, 0)
MainClip.BackgroundTransparency = 1
MainClip.BorderSizePixel = 0
MainClip.ClipsDescendants = true
MainClip.ZIndex = 1

corner(MainClip, 14)

_G.MainContentClip = MainClip

--// ================================================================
--// HEADER
--// ================================================================

local Header = new("Frame", MainClip)
Header.Name = "Header_Section"
Header.Size = UDim2.new(1, 0, 0, 65)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Config.Colors.DarkBlue
Header.BorderSizePixel = 0
Header.ZIndex = 10

corner(Header, 14)

local HeaderBlocker = new("Frame", Header)
HeaderBlocker.Size = UDim2.new(1, 0, 0, 15)
HeaderBlocker.Position = UDim2.new(0, 0, 1, -15)
HeaderBlocker.BackgroundColor3 = Config.Colors.DarkBlue
HeaderBlocker.BorderSizePixel = 0
HeaderBlocker.ZIndex = 10

local HeaderTitle = new("TextLabel", Header)
HeaderTitle.Name = "Judul_Utama"
HeaderTitle.Size = UDim2.new(1, -100, 0, 30)
HeaderTitle.Position = UDim2.new(0, 50, 0, 7)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "Axomusc"
HeaderTitle.TextColor3 = Config.Colors.IceBlue
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 26
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Center
HeaderTitle.ZIndex = 12

local HeaderSub = new("TextLabel", Header)
HeaderSub.Name = "Sub_Judul"
HeaderSub.Size = UDim2.new(1, -100, 0, 16)
HeaderSub.Position = UDim2.new(0, 50, 0, 38)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Text = "By. " .. Config.Brand
HeaderSub.TextColor3 = Config.Colors.White
HeaderSub.TextTransparency = 0.25
HeaderSub.Font = Enum.Font.GothamSemibold
HeaderSub.TextSize = 11
HeaderSub.TextXAlignment = Enum.TextXAlignment.Center
HeaderSub.ZIndex = 12

local CloseBtn = new("TextButton", Header)
CloseBtn.Name = "Close_Button"
CloseBtn.Size = UDim2.new(0, 42, 0, 42)
CloseBtn.Position = UDim2.new(1, -48, 0, 11)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Config.Colors.White
CloseBtn.TextSize = 30
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 15

CloseBtn.MouseEnter:Connect(function()
    safeTween(
        CloseBtn,
        TweenInfo.new(0.2),
        {
            TextColor3 = Config.Colors.Red,
            Rotation = 90
        }
    )
end)

CloseBtn.MouseLeave:Connect(function()
    safeTween(
        CloseBtn,
        TweenInfo.new(0.2),
        {
            TextColor3 = Config.Colors.White,
            Rotation = 0
        }
    )
end)

local PremiumLine = new("Frame", Header)
PremiumLine.Name = "Premium_Separator"
PremiumLine.Size = UDim2.new(1, 0, 0, 2)
PremiumLine.Position = UDim2.new(0, 0, 1, -2)
PremiumLine.BackgroundColor3 = Config.Colors.IceBlue
PremiumLine.BorderSizePixel = 0
PremiumLine.ZIndex = 20

local PremiumGradient = new("UIGradient", PremiumLine)
PremiumGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.Black),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.Black)
})

--// ================================================================
--// 3 LAYOUT SYSTEM
--// ================================================================

local L1_Width = 60
local L2_Width = 140
local HeaderHeight = 65

--// LAYER 3
local Layar3_Content = new("Frame", MainClip)
Layar3_Content.Name = "Layar3_Workspace"
Layar3_Content.Size = UDim2.new(
    1,
    -(L1_Width + L2_Width),
    1,
    -HeaderHeight
)
Layar3_Content.Position = UDim2.new(
    0,
    L1_Width + L2_Width,
    0,
    HeaderHeight
)
Layar3_Content.BackgroundColor3 = Config.Colors.Black
Layar3_Content.BackgroundTransparency = 1
Layar3_Content.BorderSizePixel = 0
Layar3_Content.ZIndex = 2
Layar3_Content.ClipsDescendants = true

_G.Layar3_Container = Layar3_Content

local PageFolder = new("Folder", Layar3_Content)
PageFolder.Name = "All_Pages"

--// LAYER 2
local Layar2_Sidebar = new("Frame", MainClip)
Layar2_Sidebar.Name = "Layar2_SidebarMenu"
Layar2_Sidebar.Size = UDim2.new(
    0,
    L2_Width,
    1,
    -HeaderHeight
)
Layar2_Sidebar.Position = UDim2.new(
    0,
    L1_Width,
    0,
    HeaderHeight
)
Layar2_Sidebar.BackgroundColor3 = Config.Colors.DarkBlue
Layar2_Sidebar.BackgroundTransparency = 0.25
Layar2_Sidebar.BorderSizePixel = 0
Layar2_Sidebar.ClipsDescendants = true
Layar2_Sidebar.ZIndex = 5

local SidebarSeparator = new("Frame", Layar2_Sidebar)
SidebarSeparator.Size = UDim2.new(0, 2, 1, 0)
SidebarSeparator.Position = UDim2.new(1, -2, 0, 0)
SidebarSeparator.BackgroundColor3 = Config.Colors.ToscaGreen
SidebarSeparator.BorderSizePixel = 0
SidebarSeparator.ZIndex = 20

local SidebarGradient = new("UIGradient", SidebarSeparator)
SidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.ToscaGreen),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.ToscaGreen)
})

--// MENU SCROLL
local MenuScroll = new("ScrollingFrame", Layar2_Sidebar)
MenuScroll.Name = "Menu_ScrollList"
MenuScroll.Size = UDim2.new(1, -2, 1, -10)
MenuScroll.Position = UDim2.new(0, 0, 0, 5)
MenuScroll.BackgroundTransparency = 1
MenuScroll.BorderSizePixel = 0
MenuScroll.ScrollBarThickness = 0
MenuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
MenuScroll.ZIndex = 6

local MenuPadding = new("UIPadding", MenuScroll)
MenuPadding.PaddingTop = UDim.new(0, 10)
MenuPadding.PaddingBottom = UDim.new(0, 10)

local MenuListLayout = new("UIListLayout", MenuScroll)
MenuListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MenuListLayout.Padding = UDim.new(0, 8)
MenuListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

MenuListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MenuScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        MenuListLayout.AbsoluteContentSize.Y + 20
    )
end)

--// ================================================================
--// TAB SYSTEM
--// ================================================================

local MenuButtons = {}
local CurrentPage = nil
local CurrentL1 = "Main"

_G.Axomusc_MenuBtns = MenuButtons

local function hideAllPages()
    for _, data in ipairs(MenuButtons) do
        if data and data.Btn and data.Btn.Parent then
            safeTween(
                data.Btn,
                TweenInfo.new(0.25),
                {
                    BackgroundTransparency = 1
                }
            )

            safeTween(
                data.Text,
                TweenInfo.new(0.25),
                {
                    TextColor3 = Config.Colors.White,
                    TextTransparency = 0.4
                }
            )

            safeTween(
                data.Indicator,
                TweenInfo.new(0.25),
                {
                    Size = UDim2.new(0, 3, 0, 0)
                }
            )
        end

        if data and data.Page then
            data.Page.Visible = false
            data.Page.Position = UDim2.new(0, 25, 0, 0)
        end
    end
end

local function activatePage(data)
    if not data then
        return
    end

    hideAllPages()

    CurrentPage = data.Name

    safeTween(
        data.Btn,
        TweenInfo.new(0.25),
        {
            BackgroundTransparency = 0.55
        }
    )

    safeTween(
        data.Text,
        TweenInfo.new(0.25),
        {
            TextColor3 = Config.Colors.ToscaGreen,
            TextTransparency = 0
        }
    )

    safeTween(
        data.Indicator,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.new(0, 3, 0, 18)
        }
    )

    data.Page.Visible = true

    safeTween(
        data.Page,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        {
            Position = UDim2.new(0, 0, 0, 0)
        }
    )
end

local function CreateMenuButton(menuName, category)
    local data = {
        Name = menuName,
        Category = category
    }

    local MenuBtn = new("TextButton", MenuScroll)
    MenuBtn.Name = "Button_" .. menuName
    MenuBtn.Size = UDim2.new(0.85, 0, 0, 32)
    MenuBtn.BackgroundColor3 = Config.Colors.Black
    MenuBtn.BackgroundTransparency = 1
    MenuBtn.Text = ""
    MenuBtn.AutoButtonColor = false
    MenuBtn.ZIndex = 7

    corner(MenuBtn, 7)

    local CategoryValue = new("StringValue", MenuBtn)
    CategoryValue.Name = "Category"
    CategoryValue.Value = category

    local BtnText = new("TextLabel", MenuBtn)
    BtnText.Name = "Text"
    BtnText.Size = UDim2.new(1, -15, 1, 0)
    BtnText.Position = UDim2.new(0, 15, 0, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = menuName
    BtnText.TextColor3 = Config.Colors.White
    BtnText.TextTransparency = 0.4
    BtnText.Font = Enum.Font.GothamSemibold
    BtnText.TextSize = 12
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.ZIndex = 8

    local Indicator = new("Frame", MenuBtn)
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Config.Colors.ToscaGreen
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 8

    corner(Indicator, 2)

    local Page = new("ScrollingFrame", PageFolder)
    Page.Name = menuName .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 25, 0, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Config.Colors.ToscaGreen
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.ZIndex = 3

    local PagePadding = new("UIPadding", Page)
    PagePadding.PaddingTop = UDim.new(0, 15)
    PagePadding.PaddingBottom = UDim.new(0, 15)
    PagePadding.PaddingLeft = UDim.new(0, 15)
    PagePadding.PaddingRight = UDim.new(0, 15)

    local PageLayout = new("UIListLayout", Page)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(
            0,
            0,
            0,
            PageLayout.AbsoluteContentSize.Y + 35
        )
    end)

    data.Btn = MenuBtn
    data.Text = BtnText
    data.Indicator = Indicator
    data.Page = Page

    table.insert(MenuButtons, data)

    MenuBtn.MouseButton1Click:Connect(function()
        activatePage(data)
    end)

    return data
end

local Page_Music = CreateMenuButton("Music Panel", "Main")
local Page_Playlist = CreateMenuButton("Playlist", "Main")
local Page_Folder = CreateMenuButton("Folder", "Main")

local Page_Profile = CreateMenuButton("Profile", "Special")
local Page_About = CreateMenuButton("About", "Special")
local Page_UpInfo = CreateMenuButton("Up Info", "Special")

_G.Page_Music = Page_Music
_G.Page_Playlist = Page_Playlist
_G.Page_Folder = Page_Folder
_G.Page_Profile = Page_Profile
_G.Page_About = Page_About
_G.Page_UpInfo = Page_UpInfo

local function switchCategory(category)
    local first

    for _, data in ipairs(MenuButtons) do
        if data.Category == category then
            data.Btn.Visible = true

            if not first then
                first = data
            end
        else
            data.Btn.Visible = false
        end
    end

    if first then
        activatePage(first)
    end
end

--// ================================================================
--// LAYER 1
--// ================================================================

local Layar1_Icons = new("Frame", MainClip)
Layar1_Icons.Name = "Layar1_IconBar"
Layar1_Icons.Size = UDim2.new(
    0,
    L1_Width,
    1,
    -HeaderHeight
)
Layar1_Icons.Position = UDim2.new(
    0,
    0,
    0,
    HeaderHeight
)
Layar1_Icons.BackgroundColor3 = Config.Colors.Black
Layar1_Icons.BorderSizePixel = 0
Layar1_Icons.ZIndex = 10

local L1Separator = new("Frame", Layar1_Icons)
L1Separator.Size = UDim2.new(0, 1, 1, 0)
L1Separator.Position = UDim2.new(1, -1, 0, 0)
L1Separator.BackgroundColor3 = Config.Colors.IceBlue
L1Separator.BackgroundTransparency = 0.65
L1Separator.BorderSizePixel = 0
L1Separator.ZIndex = 15

local ActiveLine = new("Frame", Layar1_Icons)
ActiveLine.Name = "ActiveIndicator"
ActiveLine.Size = UDim2.new(0, 3, 0, 24)
ActiveLine.Position = UDim2.new(0, 0, 0, 35)
ActiveLine.AnchorPoint = Vector2.new(0, 0.5)
ActiveLine.BackgroundColor3 = Config.Colors.ToscaGreen
ActiveLine.BorderSizePixel = 0
ActiveLine.ZIndex = 20

corner(ActiveLine, 2)

--// HAMBURGER
local MainMenu_Btn = new("TextButton", Layar1_Icons)
MainMenu_Btn.Name = "Btn_Hamburger"
MainMenu_Btn.Size = UDim2.new(0, 36, 0, 36)
MainMenu_Btn.Position = UDim2.new(0.5, 0, 0, 35)
MainMenu_Btn.AnchorPoint = Vector2.new(0.5, 0.5)
MainMenu_Btn.BackgroundTransparency = 1
MainMenu_Btn.Text = ""
MainMenu_Btn.AutoButtonColor = false
MainMenu_Btn.ZIndex = 25

local H1 = new("Frame", MainMenu_Btn)
H1.Size = UDim2.new(0, 20, 0, 2)
H1.Position = UDim2.new(0.5, -10, 0.5, -7)
H1.BackgroundColor3 = Config.Colors.ToscaGreen
H1.BorderSizePixel = 0

local H2 = new("Frame", MainMenu_Btn)
H2.Size = UDim2.new(0, 20, 0, 2)
H2.Position = UDim2.new(0.5, -10, 0.5, -1)
H2.BackgroundColor3 = Config.Colors.ToscaGreen
H2.BorderSizePixel = 0

local H3 = new("Frame", MainMenu_Btn)
H3.Size = UDim2.new(0, 20, 0, 2)
H3.Position = UDim2.new(0.5, -10, 0.5, 5)
H3.BackgroundColor3 = Config.Colors.ToscaGreen
H3.BorderSizePixel = 0

--// LOGO
local SpecialMenu_Btn = new("ImageButton", Layar1_Icons)
SpecialMenu_Btn.Name = "Btn_AxolionLogo"
SpecialMenu_Btn.Size = UDim2.new(0, 34, 0, 34)
SpecialMenu_Btn.Position = UDim2.new(0.5, 0, 0, 85)
SpecialMenu_Btn.AnchorPoint = Vector2.new(0.5, 0.5)
SpecialMenu_Btn.BackgroundTransparency = 1
SpecialMenu_Btn.Image = Config.SubLogo
SpecialMenu_Btn.ImageColor3 = Config.Colors.White
SpecialMenu_Btn.ImageTransparency = 0.4
SpecialMenu_Btn.AutoButtonColor = false
SpecialMenu_Btn.ZIndex = 25

local SidebarOpen = true

local function toggleSidebar(category)
    if category then
        switchCategory(category)
    end

    if not SidebarOpen then
        SidebarOpen = true

        safeTween(
            Layar2_Sidebar,
            TweenInfo.new(
                0.4,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    0,
                    L2_Width,
                    1,
                    -HeaderHeight
                )
            }
        )

        safeTween(
            Layar3_Content,
            TweenInfo.new(
                0.4,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    1,
                    -(L1_Width + L2_Width),
                    1,
                    -HeaderHeight
                ),
                Position = UDim2.new(
                    0,
                    L1_Width + L2_Width,
                    0,
                    HeaderHeight
                )
            }
        )
    end
end

MainMenu_Btn.MouseEnter:Connect(function()
    safeTween(
        MainMenu_Btn,
        TweenInfo.new(0.2),
        {
            Size = UDim2.new(0, 40, 0, 40)
        }
    )
end)

MainMenu_Btn.MouseLeave:Connect(function()
    safeTween(
        MainMenu_Btn,
        TweenInfo.new(0.2),
        {
            Size = UDim2.new(0, 36, 0, 36)
        }
    )
end)

SpecialMenu_Btn.MouseEnter:Connect(function()
    safeTween(
        SpecialMenu_Btn,
        TweenInfo.new(0.2),
        {
            Size = UDim2.new(0, 38, 0, 38),
            ImageTransparency = 0
        }
    )
end)

SpecialMenu_Btn.MouseLeave:Connect(function()
    local transparency = CurrentL1 == "Special" and 0 or 0.4

    safeTween(
        SpecialMenu_Btn,
        TweenInfo.new(0.2),
        {
            Size = UDim2.new(0, 34, 0, 34),
            ImageTransparency = transparency
        }
    )
end)

MainMenu_Btn.MouseButton1Click:Connect(function()
    CurrentL1 = "Main"

    H1.BackgroundColor3 = Config.Colors.ToscaGreen
    H2.BackgroundColor3 = Config.Colors.ToscaGreen
    H3.BackgroundColor3 = Config.Colors.ToscaGreen

    safeTween(
        SpecialMenu_Btn,
        TweenInfo.new(0.25),
        {
            ImageColor3 = Config.Colors.White,
            ImageTransparency = 0.4
        }
    )

    safeTween(
        ActiveLine,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Position = UDim2.new(0, 0, 0, 35)
        }
    )

    toggleSidebar("Main")
end)

SpecialMenu_Btn.MouseButton1Click:Connect(function()
    CurrentL1 = "Special"

    H1.BackgroundColor3 = Config.Colors.White
    H2.BackgroundColor3 = Config.Colors.White
    H3.BackgroundColor3 = Config.Colors.White

    safeTween(
        SpecialMenu_Btn,
        TweenInfo.new(0.25),
        {
            ImageColor3 = Config.Colors.ToscaGreen,
            ImageTransparency = 0
        }
    )

    safeTween(
        ActiveLine,
        TweenInfo.new(
            0.35,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out
        ),
        {
            Position = UDim2.new(0, 0, 0, 85)
        }
    )

    toggleSidebar("Special")
end)

switchCategory("Main")

--// ================================================================
--// DRAG SYSTEM
--// ================================================================

local dragging = false
local dragStart = nil
local startPosition = nil
local dragConnection = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    if not dragStart or not startPosition then
        return
    end

    local delta = input.Position - dragStart

    MainFrame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

--// ================================================================
--// AUDIO ENGINE
--// ================================================================

local AudioCore = new("Sound", SoundService)
AudioCore.Name = "Axomusc_AudioEngine"
AudioCore.Volume = 1
AudioCore.Looped = false
AudioCore.PlaybackSpeed = 1

--// ================================================================
--// MUSIC PAGE
--// ================================================================

local MusicPage = Page_Music.Page

--// NOW PLAYING CARD
local NowPlayingCard = new("Frame", MusicPage)
NowPlayingCard.Name = "NowPlaying_Card"
NowPlayingCard.Size = UDim2.new(1, 0, 0, 150)
NowPlayingCard.BackgroundColor3 = Config.Colors.DarkBlue
NowPlayingCard.BackgroundTransparency = 0.1
NowPlayingCard.BorderSizePixel = 0
NowPlayingCard.ZIndex = 4

corner(NowPlayingCard, 15)
stroke(
    NowPlayingCard,
    Config.Colors.ToscaGreen,
    1.5,
    0.55
)

--// QUEUE BUTTON
local BtnQueue = new("TextButton", NowPlayingCard)
BtnQueue.Name = "BtnQueue"
BtnQueue.Size = UDim2.new(0, 35, 0, 35)
BtnQueue.Position = UDim2.new(1, -45, 0, 15)
BtnQueue.BackgroundColor3 = Config.Colors.Black
BtnQueue.BackgroundTransparency = 0.25
BtnQueue.Text = "≡"
BtnQueue.TextColor3 = Config.Colors.White
BtnQueue.Font = Enum.Font.GothamBold
BtnQueue.TextSize = 20
BtnQueue.AutoButtonColor = false
BtnQueue.ZIndex = 10

corner(BtnQueue, 8)
stroke(BtnQueue, Config.Colors.ToscaGreen, 1, 0.3)

--// ALBUM
local AlbumBg = new("Frame", NowPlayingCard)
AlbumBg.Size = UDim2.new(0, 110, 0, 110)
AlbumBg.Position = UDim2.new(0, 20, 0.5, 0)
AlbumBg.AnchorPoint = Vector2.new(0, 0.5)
AlbumBg.BackgroundColor3 = Config.Colors.Black
AlbumBg.BorderSizePixel = 0
AlbumBg.ZIndex = 5

corner(AlbumBg, 55)
stroke(AlbumBg, Config.Colors.White, 1, 0.25)

local BassRing = new("Frame", AlbumBg)
BassRing.Name = "BassRing"
BassRing.Size = UDim2.new(1, 14, 1, 14)
BassRing.Position = UDim2.new(0.5, 0, 0.5, 0)
BassRing.AnchorPoint = Vector2.new(0.5, 0.5)
BassRing.BackgroundTransparency = 1
BassRing.BorderSizePixel = 0
BassRing.ZIndex = 4

corner(BassRing, 60)

local BassStroke = stroke(
    BassRing,
    Config.Colors.ToscaGreen,
    3,
    0
)

local BassGradient = new("UIGradient", BassRing)
BassGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Colors.ToscaGreen),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.ToscaGreen)
})

local AlbumCD = new("ImageLabel", AlbumBg)
AlbumCD.Name = "AlbumCD"
AlbumCD.Size = UDim2.new(1, -6, 1, -6)
AlbumCD.Position = UDim2.new(0.5, 0, 0.5, 0)
AlbumCD.AnchorPoint = Vector2.new(0.5, 0.5)
AlbumCD.BackgroundTransparency = 1
AlbumCD.Image = Config.Thumbnail
AlbumCD.ZIndex = 6

corner(AlbumCD, 60)

local CD_Hole = new("Frame", AlbumCD)
CD_Hole.Size = UDim2.new(0, 20, 0, 20)
CD_Hole.Position = UDim2.new(0.5, 0, 0.5, 0)
CD_Hole.AnchorPoint = Vector2.new(0.5, 0.5)
CD_Hole.BackgroundColor3 = Config.Colors.DarkBlue
CD_Hole.BorderSizePixel = 0
CD_Hole.ZIndex = 8

corner(CD_Hole, 10)

local SongTitle = new("TextLabel", NowPlayingCard)
SongTitle.Size = UDim2.new(1, -210, 0, 30)
SongTitle.Position = UDim2.new(0, 150, 0, 25)
SongTitle.BackgroundTransparency = 1
SongTitle.Text = "No Track Selected"
SongTitle.TextColor3 = Config.Colors.White
SongTitle.Font = Enum.Font.GothamBold
SongTitle.TextSize = 20
SongTitle.TextXAlignment = Enum.TextXAlignment.Left
SongTitle.TextTruncate = Enum.TextTruncate.AtEnd
SongTitle.ZIndex = 7

local SongArtist = new("TextLabel", NowPlayingCard)
SongArtist.Size = UDim2.new(1, -210, 0, 20)
SongArtist.Position = UDim2.new(0, 150, 0, 55)
SongArtist.BackgroundTransparency = 1
SongArtist.Text = "Axolion Community"
SongArtist.TextColor3 = Config.Colors.ToscaGreen
SongArtist.Font = Enum.Font.GothamSemibold
SongArtist.TextSize = 12
SongArtist.TextXAlignment = Enum.TextXAlignment.Left
SongArtist.ZIndex = 7

--// ================================================================
--// PROGRESS BAR
--// ================================================================

local ProgressContainer = new("Frame", NowPlayingCard)
ProgressContainer.Size = UDim2.new(1, -165, 0, 25)
ProgressContainer.Position = UDim2.new(0, 150, 0, 100)
ProgressContainer.BackgroundTransparency = 1
ProgressContainer.ZIndex = 7

local ProgressBg = new("TextButton", ProgressContainer)
ProgressBg.Size = UDim2.new(1, 0, 0, 4)
ProgressBg.Position = UDim2.new(0, 0, 0.5, 0)
ProgressBg.AnchorPoint = Vector2.new(0, 0.5)
ProgressBg.BackgroundColor3 = Config.Colors.Black
ProgressBg.BorderSizePixel = 0
ProgressBg.Text = ""
ProgressBg.AutoButtonColor = false
ProgressBg.ZIndex = 8

corner(ProgressBg, 3)

local ProgressFill = new("Frame", ProgressBg)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Config.Colors.ToscaGreen
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 9

corner(ProgressFill, 3)

local ProgressKnob = new("Frame", ProgressFill)
ProgressKnob.Size = UDim2.new(0, 12, 0, 12)
ProgressKnob.Position = UDim2.new(1, -6, 0.5, 0)
ProgressKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressKnob.BackgroundColor3 = Config.Colors.White
ProgressKnob.BorderSizePixel = 0
ProgressKnob.ZIndex = 10

corner(ProgressKnob, 10)

local TimeCurrent = new("TextLabel", ProgressContainer)
TimeCurrent.Size = UDim2.new(0, 50, 0, 15)
TimeCurrent.Position = UDim2.new(0, 0, 1, 2)
TimeCurrent.BackgroundTransparency = 1
TimeCurrent.Text = "0:00"
TimeCurrent.TextColor3 = Config.Colors.White
TimeCurrent.Font = Enum.Font.Gotham
TimeCurrent.TextSize = 11
TimeCurrent.TextXAlignment = Enum.TextXAlignment.Left
TimeCurrent.ZIndex = 8

local TimeTotal = new("TextLabel", ProgressContainer)
TimeTotal.Size = UDim2.new(0, 50, 0, 15)
TimeTotal.Position = UDim2.new(1, -50, 1, 2)
TimeTotal.BackgroundTransparency = 1
TimeTotal.Text = "0:00"
TimeTotal.TextColor3 = Config.Colors.White
TimeTotal.Font = Enum.Font.Gotham
TimeTotal.TextSize = 11
TimeTotal.TextXAlignment = Enum.TextXAlignment.Right
TimeTotal.ZIndex = 8

local isDraggingProgress = false

ProgressBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        isDraggingProgress = true

        local pct = math.clamp(
            (input.Position.X - ProgressBg.AbsolutePosition.X)
            / math.max(ProgressBg.AbsoluteSize.X, 1),
            0,
            1
        )

        ProgressFill.Size = UDim2.new(pct, 0, 1, 0)

        if AudioCore.TimeLength > 0 then
            pcall(function()
                AudioCore.TimePosition = pct * AudioCore.TimeLength
            end)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not isDraggingProgress then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local width = math.max(ProgressBg.AbsoluteSize.X, 1)

    local pct = math.clamp(
        (input.Position.X - ProgressBg.AbsolutePosition.X) / width,
        0,
        1
    )

    ProgressFill.Size = UDim2.new(pct, 0, 1, 0)

    if AudioCore.TimeLength > 0 then
        pcall(function()
            AudioCore.TimePosition = pct * AudioCore.TimeLength
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        isDraggingProgress = false
    end
end)

--// ================================================================
--// CONTROL PANEL
--// ================================================================

local ControlPanel = new("Frame", MusicPage)
ControlPanel.Name = "ControlPanel"
ControlPanel.Size = UDim2.new(1, 0, 0, 85)
ControlPanel.Position = UDim2.new(0, 0, 0, 165)
ControlPanel.BackgroundColor3 = Config.Colors.Black
ControlPanel.BackgroundTransparency = 0.35
ControlPanel.BorderSizePixel = 0
ControlPanel.ClipsDescendants = true
ControlPanel.ZIndex = 4

corner(ControlPanel, 12)

local ControlStroke = stroke(
    ControlPanel,
    Config.Colors.ToscaGreen,
    1,
    0.7
)

local CtrlLayout = new("UIListLayout", ControlPanel)
CtrlLayout.FillDirection = Enum.FillDirection.Horizontal
CtrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CtrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CtrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
CtrlLayout.Padding = UDim.new(0, 18)

local function CreateCtrlBtn(name, text, size, textSize, order, main)
    local btn = new("TextButton", ControlPanel)

    btn.Name = name
    btn.Size = UDim2.new(0, size, 0, size)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = main
        and Config.Colors.ToscaGreen
        or Config.Colors.DarkBlue
    btn.BackgroundTransparency = main and 0 or 0.15
    btn.Text = text
    btn.TextColor3 = main
        and Config.Colors.Black
        or Config.Colors.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = textSize
    btn.AutoButtonColor = false
    btn.ZIndex = 10

    corner(btn, 40)

    if not main then
        stroke(
            btn,
            Config.Colors.White,
            1.2,
            0.55
        )
    end

    btn.MouseEnter:Connect(function()
        safeTween(
            btn,
            TweenInfo.new(0.15),
            {
                Size = UDim2.new(
                    0,
                    size + 5,
                    0,
                    size + 5
                )
            }
        )
    end)

    btn.MouseLeave:Connect(function()
        safeTween(
            btn,
            TweenInfo.new(0.15),
            {
                Size = UDim2.new(
                    0,
                    size,
                    0,
                    size
                )
            }
        )
    end)

    return btn
end

local BtnTempo = CreateCtrlBtn(
    "BtnTempo",
    "⏱",
    45,
    18,
    1,
    false
)

local BtnPrev = CreateCtrlBtn(
    "BtnPrev",
    "⏮",
    50,
    22,
    2,
    false
)

local BtnPlay = CreateCtrlBtn(
    "BtnPlay",
    "▶",
    65,
    28,
    3,
    true
)

local BtnNext = CreateCtrlBtn(
    "BtnNext",
    "⏭",
    50,
    22,
    4,
    false
)

local BtnPlayMode = CreateCtrlBtn(
    "BtnPlayMode",
    "🔁",
    45,
    18,
    5,
    false
)

--// ================================================================
--// TEMPO PANEL
--// ================================================================

local TempoContainer = new("Frame", MusicPage)
TempoContainer.Name = "TempoContainer"
TempoContainer.Size = UDim2.new(0, 200, 0, 45)
TempoContainer.Position = UDim2.new(0.5, -100, 0, 110)
TempoContainer.BackgroundColor3 = Config.Colors.DarkBlue
TempoContainer.BackgroundTransparency = 0.05
TempoContainer.BorderSizePixel = 0
TempoContainer.ClipsDescendants = true
TempoContainer.Visible = false
TempoContainer.ZIndex = 50

corner(TempoContainer, 10)
stroke(
    TempoContainer,
    Config.Colors.ToscaGreen,
    1,
    0.25
)

local TempoLayout = new("UIListLayout", TempoContainer)
TempoLayout.FillDirection = Enum.FillDirection.Horizontal
TempoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TempoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TempoLayout.Padding = UDim.new(0, 8)

local TempoButtons = {}

local function setTempo(speed)
    AudioCore.PlaybackSpeed = speed

    for _, button in ipairs(TempoButtons) do
        button.BackgroundColor3 = Config.Colors.Black
        button.TextColor3 = Config.Colors.White
    end
end

for _, speed in ipairs({0.5, 1, 1.5, 2}) do
    local button = new("TextButton", TempoContainer)

    button.Size = UDim2.new(0, 40, 0, 30)
    button.BackgroundColor3 =
        speed == 1
        and Config.Colors.ToscaGreen
        or Config.Colors.Black

    button.Text = tostring(speed) .. "x"

    button.TextColor3 =
        speed == 1
        and Config.Colors.Black
        or Config.Colors.White

    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.AutoButtonColor = false
    button.ZIndex = 55

    corner(button, 6)

    table.insert(TempoButtons, button)

    button.MouseButton1Click:Connect(function()
        setTempo(speed)

        button.BackgroundColor3 = Config.Colors.ToscaGreen
        button.TextColor3 = Config.Colors.Black

        Notify(
            "Tempo Berubah",
            "Kecepatan diatur ke " .. tostring(speed) .. "x",
            2
        )

        safeTween(
            TempoContainer,
            TweenInfo.new(0.25),
            {
                Size = UDim2.new(0, 200, 0, 0)
            }
        )

        task.delay(0.28, function()
            if TempoContainer.Parent then
                TempoContainer.Visible = false
            end
        end)
    end)
end

BtnTempo.MouseButton1Click:Connect(function()
    if TempoContainer.Visible then
        safeTween(
            TempoContainer,
            TweenInfo.new(0.25),
            {
                Size = UDim2.new(0, 200, 0, 0)
            }
        )

        task.delay(0.28, function()
            if TempoContainer.Parent then
                TempoContainer.Visible = false
            end
        end)
    else
        TempoContainer.Visible = true
        TempoContainer.Size = UDim2.new(0, 200, 0, 0)

        safeTween(
            TempoContainer,
            TweenInfo.new(
                0.3,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(0, 200, 0, 45)
            }
        )
    end
end)

--// ================================================================
--// QUEUE
--// ================================================================

local QueueContainer = new("Frame", MusicPage)
QueueContainer.Name = "QueueContainer"
QueueContainer.Size = UDim2.new(1, 0, 0, 0)
QueueContainer.Position = UDim2.new(0, 0, 0, 165)
QueueContainer.BackgroundColor3 = Config.Colors.DarkBlue
QueueContainer.BackgroundTransparency = 0.15
QueueContainer.BorderSizePixel = 0
QueueContainer.ClipsDescendants = true
QueueContainer.ZIndex = 20

corner(QueueContainer, 10)

local QueueStroke = stroke(
    QueueContainer,
    Config.Colors.ToscaGreen,
    1,
    1
)

local QueueScroll = new("ScrollingFrame", QueueContainer)
QueueScroll.Name = "QueueScroll"
QueueScroll.Size = UDim2.new(1, -10, 1, -10)
QueueScroll.Position = UDim2.new(0, 5, 0, 5)
QueueScroll.BackgroundTransparency = 1
QueueScroll.BorderSizePixel = 0
QueueScroll.ScrollBarThickness = 3
QueueScroll.ScrollBarImageColor3 = Config.Colors.ToscaGreen
QueueScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
QueueScroll.ZIndex = 25

local QueueLayout = new("UIListLayout", QueueScroll)
QueueLayout.SortOrder = Enum.SortOrder.LayoutOrder
QueueLayout.Padding = UDim.new(0, 6)

QueueLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    QueueScroll.CanvasSize = UDim2.new(
        0,
        0,
        0,
        QueueLayout.AbsoluteContentSize.Y + 10
    )
end)

local IsQueueOpen = false

local function setQueueOpen(state)
    IsQueueOpen = state

    if IsQueueOpen then
        BtnQueue.BackgroundColor3 = Config.Colors.ToscaGreen
        BtnQueue.TextColor3 = Config.Colors.Black

        QueueStroke.Transparency = 0

        safeTween(
            ControlPanel,
            TweenInfo.new(
                0.35,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            }
        )

        safeTween(
            ControlStroke,
            TweenInfo.new(0.25),
            {
                Transparency = 1
            }
        )

        safeTween(
            QueueContainer,
            TweenInfo.new(
                0.35,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(1, 0, 1, -170)
            }
        )
    else
        BtnQueue.BackgroundColor3 = Config.Colors.Black
        BtnQueue.TextColor3 = Config.Colors.White

        QueueStroke.Transparency = 1

        safeTween(
            QueueContainer,
            TweenInfo.new(
                0.35,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(1, 0, 0, 0)
            }
        )

        safeTween(
            ControlPanel,
            TweenInfo.new(
                0.35,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(1, 0, 0, 85),
                BackgroundTransparency = 0.35
            }
        )

        safeTween(
            ControlStroke,
            TweenInfo.new(0.25),
            {
                Transparency = 0.7
            }
        )
    end
end

BtnQueue.MouseButton1Click:Connect(function()
    setQueueOpen(not IsQueueOpen)
end)

--// ================================================================
--// QUEUE UI
--// ================================================================

local function UpdateQueueUI()
    pcall(function()
        for _, child in ipairs(QueueScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        for index, track in ipairs(App.MusicQueue) do
            local item = new("Frame", QueueScroll)
            item.Name = "QueueItem_" .. index
            item.Size = UDim2.new(1, -5, 0, 40)
            item.BackgroundColor3 = Config.Colors.Black
            item.BackgroundTransparency = 0.35
            item.BorderSizePixel = 0
            item.LayoutOrder = index
            item.ZIndex = 26

            corner(item, 8)

            local title = new("TextLabel", item)
            title.Name = "TrackTitle"
            title.Size = UDim2.new(1, -55, 1, 0)
            title.Position = UDim2.new(0, 15, 0, 0)
            title.BackgroundTransparency = 1
            title.Text = tostring(index) .. ". " .. tostring(track.Title)
            title.TextColor3 = Config.Colors.White
            title.Font = Enum.Font.GothamSemibold
            title.TextSize = 12
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.TextTruncate = Enum.TextTruncate.AtEnd
            title.ZIndex = 27

            local playButton = new("TextButton", item)
            playButton.Name = "Play"
            playButton.Size = UDim2.new(0, 26, 0, 26)
            playButton.Position = UDim2.new(1, -36, 0.5, -13)
            playButton.BackgroundColor3 = Config.Colors.DarkBlue
            playButton.Text = "▶"
            playButton.TextColor3 = Config.Colors.White
            playButton.Font = Enum.Font.GothamBold
            playButton.TextSize = 11
            playButton.AutoButtonColor = false
            playButton.ZIndex = 30

            corner(playButton, 13)

            playButton.MouseButton1Click:Connect(function()
                if App.PlayTrack then
                    App.PlayTrack(index)
                end
            end)
        end

        QueueScroll.CanvasSize = UDim2.new(
            0,
            0,
            0,
            #App.MusicQueue * 46
        )
    end)
end

App.UpdateQueueUI = UpdateQueueUI

--// ================================================================
--// PLAYBACK ENGINE
--// ================================================================

local function HighlightQueue(index)
    for _, child in ipairs(QueueScroll:GetChildren()) do
        if child:IsA("Frame") then
            local number = tonumber(
                string.match(child.Name, "QueueItem_(%d+)")
            )

            local title = child:FindFirstChild("TrackTitle")

            if number == index then
                child.BackgroundColor3 = Config.Colors.DarkBlue

                if title then
                    title.TextColor3 = Config.Colors.ToscaGreen
                end

                if not child:FindFirstChild("ActiveStroke") then
                    local activeStroke = stroke(
                        child,
                        Config.Colors.ToscaGreen,
                        1,
                        0.1
                    )

                    activeStroke.Name = "ActiveStroke"
                end
            else
                child.BackgroundColor3 = Config.Colors.Black

                if title then
                    title.TextColor3 = Config.Colors.White
                end

                local activeStroke = child:FindFirstChild("ActiveStroke")

                if activeStroke then
                    activeStroke:Destroy()
                end
            end
        end
    end
end

local function PlayTrack(index)
    if #App.MusicQueue <= 0 then
        Notify(
            "Daftar Kosong",
            "Tambahkan lagu terlebih dahulu.",
            3
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

    if type(track) ~= "table" then
        return
    end

    local id = tostring(track.ID or "")

    if id == "" then
        Notify(
            "Audio Error",
            "ID audio tidak valid.",
            3
        )
        return
    end

    App.CurrentTrackIndex = index

    SongTitle.Text = tostring(
        track.Title or "Unknown Track"
    )

    SongArtist.Text = tostring(
        track.Artist or "Unknown Artist"
    )

    pcall(function()
        AudioCore:Stop()
        AudioCore.SoundId = "rbxassetid://" .. id
        AudioCore.TimePosition = 0
        AudioCore:Play()
    end)

    App.IsPlaying = true

    BtnPlay.Text = "⏸"

    safeTween(
        BtnPlay,
        TweenInfo.new(0.2),
        {
            BackgroundColor3 = Config.Colors.ToscaGreen,
            TextColor3 = Config.Colors.Black
        }
    )

    HighlightQueue(index)

    Notify(
        "Now Playing",
        tostring(track.Title or "Unknown Track"),
        3
    )
end

App.PlayTrack = PlayTrack

--// ================================================================
--// NEXT / PREVIOUS
--// ================================================================

local function NextTrack()
    if #App.MusicQueue <= 0 then
        return
    end

    if App.PlayMode == 3 then
        local randomIndex

        if #App.MusicQueue == 1 then
            randomIndex = 1
        else
            repeat
                randomIndex = math.random(
                    1,
                    #App.MusicQueue
                )
            until randomIndex ~= App.CurrentTrackIndex
        end

        PlayTrack(randomIndex)
    else
        PlayTrack(App.CurrentTrackIndex + 1)
    end
end

local function PreviousTrack()
    if #App.MusicQueue <= 0 then
        return
    end

    PlayTrack(App.CurrentTrackIndex - 1)
end

--// ================================================================
--// PLAY BUTTON
--// ================================================================

local function TogglePlay()
    if #App.MusicQueue <= 0 then
        Notify(
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

        safeTween(
            BtnPlay,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = Config.Colors.White,
                TextColor3 = Config.Colors.Black
            }
        )
    else
        if AudioCore.SoundId == "" then
            PlayTrack(
                App.CurrentTrackIndex > 0
                and App.CurrentTrackIndex
                or 1
            )
        else
            pcall(function()
                AudioCore:Resume()
            end)

            App.IsPlaying = true
            BtnPlay.Text = "⏸"

            safeTween(
                BtnPlay,
                TweenInfo.new(0.2),
                {
                    BackgroundColor3 = Config.Colors.ToscaGreen,
                    TextColor3 = Config.Colors.Black
                }
            )
        end
    end
end

BtnPlay.MouseButton1Click:Connect(TogglePlay)
BtnNext.MouseButton1Click:Connect(NextTrack)
BtnPrev.MouseButton1Click:Connect(PreviousTrack)

--// ================================================================
--// PLAY MODE
--// ================================================================

BtnPlayMode.MouseButton1Click:Connect(function()
    App.PlayMode = App.PlayMode + 1

    if App.PlayMode > 3 then
        App.PlayMode = 1
    end

    if App.PlayMode == 1 then
        BtnPlayMode.Text = "🔁"
        BtnPlayMode.TextColor3 = Config.Colors.White

        Notify(
            "Mode Putar",
            "Putar otomatis",
            2
        )

    elseif App.PlayMode == 2 then
        BtnPlayMode.Text = "🔂"
        BtnPlayMode.TextColor3 = Config.Colors.ToscaGreen

        Notify(
            "Mode Putar",
            "Ulangi lagu ini",
            2
        )

    elseif App.PlayMode == 3 then
        BtnPlayMode.Text = "🔀"
        BtnPlayMode.TextColor3 = Config.Colors.ToscaGreen

        Notify(
            "Mode Putar",
            "Putar acak",
            2
        )
    end
end)

--// ================================================================
--// AUDIO ENDED
--// ================================================================

AudioCore.Ended:Connect(function()
    if App.Destroyed then
        return
    end

    if #App.MusicQueue <= 0 then
        App.IsPlaying = false
        BtnPlay.Text = "▶"
        return
    end

    if App.PlayMode == 2 then
        PlayTrack(App.CurrentTrackIndex)

    elseif App.PlayMode == 3 then
        if #App.MusicQueue == 1 then
            PlayTrack(1)
        else
            local nextIndex

            repeat
                nextIndex = math.random(
                    1,
                    #App.MusicQueue
                )
            until nextIndex ~= App.CurrentTrackIndex

            PlayTrack(nextIndex)
        end

    else
        NextTrack()
    end
end)

--// ================================================================
--// DEFAULT DEMO