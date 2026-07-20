-- ==============================================================================
-- BAGIAN 1: SERVICE IN-GAME, CONFIG, DAN UI LAYOUT DASAR
-- ==============================================================================

-- [1] Hindari _G, gunakan Local Table untuk menyimpan semua state/fungsi global Anda
local App = {
    MenuBtns = {},
    CurrentPage = nil,
    CurrentL1 = "Main",
    MainContentClip = nil
}

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
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    UI_Settings = {
        TweenTime = 0.45,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out,
        BaseWidth = 1920, 
        BaseHeight = 1080
    }
}

-- [2] Load Services secara normal (Tidak butuh pcall karena dijamin ada)
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= SUB PART: KEY2API & GUI PROTECTION =================
local AxomuscUI = Instance.new("ScreenGui")
AxomuscUI.Name = "Axomusc_Premium_UI"
AxomuscUI.ResetOnSpawn = false
AxomuscUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AxomuscUI.IgnoreGuiInset = true

-- pcall hanya digunakan di sini karena eksekutor berbeda-beda
local function ProtectGUI()
    local s, e = pcall(function()
        if gethui then
            AxomuscUI.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(AxomuscUI)
            AxomuscUI.Parent = CoreGui
        else
            AxomuscUI.Parent = CoreGui
        end
    end)
    if not s then AxomuscUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end
ProtectGUI()

-- ================= SUB PART: SMART NOTIFY SYSTEM =================
function App.Notify(Title, Text, Duration)
    local notifyDuration = Duration or 3.5
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "SmartNotifyBox"
    NotifFrame.Size = UDim2.new(0, 300, 0, 75)
    NotifFrame.Position = UDim2.new(1, 50, 1, -100)
    NotifFrame.BackgroundColor3 = Config.Colors.DarkBlue
    NotifFrame.BackgroundTransparency = 0.05
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ZIndex = 100
    NotifFrame.Parent = AxomuscUI
    
    local NotifCorner = Instance.new("UICorner", NotifFrame)
    NotifCorner.CornerRadius = UDim.new(0, 10)

    local NotifStroke = Instance.new("UIStroke", NotifFrame)
    NotifStroke.Color = Config.Colors.IceBlue
    NotifStroke.Thickness = 1.2
    NotifStroke.Transparency = 0.2
    
    local NotifShadow = Instance.new("ImageLabel", NotifFrame)
    NotifShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    NotifShadow.BackgroundTransparency = 1
    NotifShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    NotifShadow.Size = UDim2.new(1, 15, 1, 15)
    NotifShadow.Image = "rbxassetid://13169336625"
    NotifShadow.ImageColor3 = Config.Colors.Shadow
    NotifShadow.ImageTransparency = 0.6
    NotifShadow.ZIndex = 99

    local TitleLbl = Instance.new("TextLabel", NotifFrame)
    TitleLbl.Size = UDim2.new(1, -30, 0, 25)
    TitleLbl.Position = UDim2.new(0, 15, 0, 8)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = Title
    TitleLbl.TextColor3 = Config.Colors.IceBlue
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 15
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 101
    
    local TextLbl = Instance.new("TextLabel", NotifFrame)
    TextLbl.Size = UDim2.new(1, -30, 0, 35)
    TextLbl.Position = UDim2.new(0, 15, 0, 32)
    TextLbl.BackgroundTransparency = 1
    TextLbl.Text = Text
    TextLbl.TextColor3 = Config.Colors.White
    TextLbl.Font = Enum.Font.Gotham
    TextLbl.TextSize = 13
    TextLbl.TextTransparency = 0.1
    TextLbl.TextXAlignment = Enum.TextXAlignment.Left
    TextLbl.TextYAlignment = Enum.TextYAlignment.Top
    TextLbl.TextWrapped = true
    TextLbl.ZIndex = 101

    local TweenIn = TweenService:Create(NotifFrame, TweenInfo.new(Config.UI_Settings.TweenTime, Config.UI_Settings.EasingStyle, Config.UI_Settings.EasingDirection), {Position = UDim2.new(1, -320, 1, -100)})
    TweenIn:Play()
    
    task.delay(notifyDuration, function()
        local TweenOut = TweenService:Create(NotifFrame, TweenInfo.new(Config.UI_Settings.TweenTime, Config.UI_Settings.EasingStyle, Config.UI_Settings.EasingDirection), {Position = UDim2.new(1, 50, 1, -100), BackgroundTransparency = 1})
        TweenService:Create(NotifStroke, TweenInfo.new(Config.UI_Settings.TweenTime), {Transparency = 1}):Play()
        TweenService:Create(TitleLbl, TweenInfo.new(Config.UI_Settings.TweenTime), {TextTransparency = 1}):Play()
        TweenService:Create(TextLbl, TweenInfo.new(Config.UI_Settings.TweenTime), {TextTransparency = 1}):Play()
        TweenService:Create(NotifShadow, TweenInfo.new(Config.UI_Settings.TweenTime), {ImageTransparency = 1}):Play()
        
        TweenOut:Play()
        TweenOut.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

-- ================= SUB PART: MAIN CANVAS & DYNAMIC AUTO-SCALE =================
local MainFrame = Instance.new("Frame", AxomuscUI)
MainFrame.Name = "MainCanvas_Workspace"
MainFrame.Size = UDim2.new(0, 680, 0, 460)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Menempatkan titik tengah frame ke tengah layar
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Mengatur titik poros ke tengah frame
MainFrame.BackgroundColor3 = Config.Colors.Black
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = AxomuscUI

local UIScale = Instance.new("UIScale", MainFrame)

local function UpdateScale()
    local Viewport = Camera.ViewportSize
    local ScaleWidth = Viewport.X / Config.UI_Settings.BaseWidth
    local ScaleHeight = Viewport.Y / Config.UI_Settings.BaseHeight
    local ExactScale = math.min(ScaleWidth, ScaleHeight)
    UIScale.Scale = math.clamp(ExactScale * 1.5, 0.45, 1.25)
end

UpdateScale() 
local CameraScaleConn = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale) 

local MainShadow = Instance.new("ImageLabel", MainFrame)
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.BackgroundTransparency = 1
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 10)
MainShadow.Size = UDim2.new(1, 40, 1, 40)
MainShadow.Image = "rbxassetid://13169336625"
MainShadow.ImageColor3 = Config.Colors.Shadow
MainShadow.ImageTransparency = 0.4
MainShadow.ZIndex = 0

local ContentClip = Instance.new("Frame", MainFrame)
ContentClip.Name = "ContentClip"
ContentClip.Size = UDim2.new(1, 0, 1, 0)
ContentClip.BackgroundTransparency = 1
ContentClip.ClipsDescendants = true
ContentClip.ZIndex = 1
App.MainContentClip = ContentClip

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UICorner", ContentClip).CornerRadius = UDim.new(0, 14)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2.5
UIStroke.Color = Color3.new(1, 1, 1)

local UIGradient = Instance.new("UIGradient", UIStroke)
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(0.5, Config.Colors.White),
    ColorSequenceKeypoint.new(1, Config.Colors.IceBlue)
}

-- [3] Fix Memory Leak: Loop akan berhenti otomatis jika UI dihancurkan
local RenderGradientConn
RenderGradientConn = RunService.RenderStepped:Connect(function()
    if not UIGradient.Parent then 
        RenderGradientConn:Disconnect() 
        return 
    end
    UIGradient.Rotation = (UIGradient.Rotation + 1.2) % 360 
end)

-- ================= SUB PART: DRAGGABLE FEATURE (ULTRA SMOOTH) =================
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(MainFrame, TweenInfo.new(0.15, Config.UI_Settings.EasingStyle, Config.UI_Settings.EasingDirection), {Position = targetPos}):Play()
    end
end)

-- ================= SUB PART: RESIZE FEATURE =================
local ResizeBtn = Instance.new("TextButton", MainFrame)
ResizeBtn.Name = "ResizeButton"
ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text = "◢" -- Simbol visual untuk resize
ResizeBtn.TextColor3 = Config.Colors.White
ResizeBtn.TextSize = 15
ResizeBtn.ZIndex = 10

local resizing = false
local resizeStartSize
local resizeStartMousePos

ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStartSize = MainFrame.Size
        resizeStartMousePos = input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - resizeStartMousePos
            
            -- Hitung ukuran baru (minimal 300x200 agar tidak hilang)
            local newX = math.max(300, resizeStartSize.X.Offset + delta.X)
            local newY = math.max(200, resizeStartSize.Y.Offset + delta.Y)
            
            MainFrame.Size = UDim2.new(0, newX, 0, newY)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

-- ================= SUB PART: HEADER (LUXURY CENTERED) =================
local Header = Instance.new("Frame", ContentClip)
Header.Name = "Header_Section"
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = Config.Colors.DarkBlue
Header.BorderSizePixel = 0
Header.ZIndex = 2

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local HeaderBlocker = Instance.new("Frame", Header)
HeaderBlocker.Size = UDim2.new(1, 0, 0, 14)
HeaderBlocker.Position = UDim2.new(0, 0, 1, -14)
HeaderBlocker.BackgroundColor3 = Config.Colors.DarkBlue
HeaderBlocker.BorderSizePixel = 0
HeaderBlocker.ZIndex = 2

local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.new(1, 0, 0, 30)
HeaderTitle.Position = UDim2.new(0, 0, 0, 8)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "Axomusc"
HeaderTitle.TextColor3 = Config.Colors.IceBlue
HeaderTitle.TextSize = 26
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Center
HeaderTitle.ZIndex = 3

local HeaderSub = Instance.new("TextLabel", Header)
HeaderSub.Size = UDim2.new(1, 0, 0, 15)
HeaderSub.Position = UDim2.new(0, 0, 0, 38)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Text = "By. " .. Config.Brand
HeaderSub.TextColor3 = Config.Colors.White
HeaderSub.TextSize = 12
HeaderSub.Font = Enum.Font.GothamSemibold
HeaderSub.TextXAlignment = Enum.TextXAlignment.Center
HeaderSub.TextTransparency = 0.3
HeaderSub.ZIndex = 3

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 50, 0, 50)
CloseBtn.Position = UDim2.new(1, -50, 0, 7)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "-"
CloseBtn.TextColor3 = Config.Colors.White
CloseBtn.TextSize = 35
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 3

CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Config.Colors.White}):Play() end)

CloseBtn.MouseButton1Click:Connect(function() 
    App.Notify("Axomusc System", "Menutup UI Premium...", 2)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    TweenService:Create(UIStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
    
    -- Pembersihan koneksi
    CameraScaleConn:Disconnect()
    
    task.wait(0.45)
    AxomuscUI:Destroy() 
end)

local PremiumLine = Instance.new("Frame", Header)
PremiumLine.Size = UDim2.new(1, 0, 0, 2)
PremiumLine.Position = UDim2.new(0, 0, 1, -2)
PremiumLine.BackgroundColor3 = Color3.new(1, 1, 1)
PremiumLine.BorderSizePixel = 0
PremiumLine.ZIndex = 4

local LineGradient = Instance.new("UIGradient", PremiumLine)
LineGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Colors.Black),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.Black)
}

-- ==============================================================================
-- BAGIAN 2: UI 3 LAYAR PREMIUM
-- ==============================================================================

local L1_Width = 60
local L2_Width = 140

local Layar3_Content = Instance.new("Frame", ContentClip)
Layar3_Content.Size = UDim2.new(1, -(L1_Width + L2_Width), 1, -65)
Layar3_Content.Position = UDim2.new(0, L1_Width + L2_Width, 0, 65)
Layar3_Content.BackgroundColor3 = Config.Colors.Black
Layar3_Content.BackgroundTransparency = 1
Layar3_Content.BorderSizePixel = 0
Layar3_Content.ZIndex = 2

local PageFolder = Instance.new("Folder", Layar3_Content)
PageFolder.Name = "All_Pages"

local Layar2_Sidebar = Instance.new("Frame", ContentClip)
Layar2_Sidebar.Size = UDim2.new(0, L2_Width, 1, -65)
Layar2_Sidebar.Position = UDim2.new(0, L1_Width, 0, 65)
Layar2_Sidebar.BackgroundColor3 = Config.Colors.DarkBlue
Layar2_Sidebar.BackgroundTransparency = 0.4
Layar2_Sidebar.BorderSizePixel = 0
Layar2_Sidebar.ClipsDescendants = true
Layar2_Sidebar.ZIndex = 3

local RGB_Separator = Instance.new("Frame", Layar2_Sidebar)
RGB_Separator.Size = UDim2.new(0, 2, 1, 0)
RGB_Separator.Position = UDim2.new(1, -2, 0, 0)
RGB_Separator.BackgroundColor3 = Color3.new(1, 1, 1)
RGB_Separator.BorderSizePixel = 0
RGB_Separator.ZIndex = 4

local SeparatorGradient = Instance.new("UIGradient", RGB_Separator)
SeparatorGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Colors.ToscaGreen),
    ColorSequenceKeypoint.new(0.5, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(1, Config.Colors.ToscaGreen)
}
SeparatorGradient.Rotation = 90

-- Putaran gradient sidebar, mati otomatis jika UI hancur
local RenderSepConn
RenderSepConn = RunService.RenderStepped:Connect(function()
    if not SeparatorGradient.Parent then
        RenderSepConn:Disconnect()
        return
    end
    SeparatorGradient.Rotation = (SeparatorGradient.Rotation + 1) % 360
end)

local MenuScroll = Instance.new("ScrollingFrame", Layar2_Sidebar)
MenuScroll.Size = UDim2.new(1, -2, 1, -10)
MenuScroll.Position = UDim2.new(0, 0, 0, 5)
MenuScroll.BackgroundTransparency = 1
MenuScroll.BorderSizePixel = 0
MenuScroll.ScrollBarThickness = 0
MenuScroll.ZIndex = 4

local MenuListLayout = Instance.new("UIListLayout", MenuScroll)
MenuListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MenuListLayout.Padding = UDim.new(0, 8)
MenuListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local MenuPadding = Instance.new("UIPadding", MenuScroll)
MenuPadding.PaddingTop = UDim.new(0, 10)

MenuListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MenuScroll.CanvasSize = UDim2.new(0, 0, 0, MenuListLayout.AbsoluteContentSize.Y + 20)
end)

-- ================= SUB PART: TAB SYSTEM LOGIC =================
local function HideAllPages()
    for _, btnData in pairs(App.MenuBtns) do
        TweenService:Create(btnData.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(btnData.Text, TweenInfo.new(0.3), {TextColor3 = Config.Colors.White, TextTransparency = 0.4}):Play()
        TweenService:Create(btnData.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 3, 0, 0)}):Play()
        if btnData.Page.Visible then
            btnData.Page.Visible = false
            btnData.Page.Position = UDim2.new(0, 30, 0, 0)
        end
    end
end

function App.CreateMenuButton(MenuName, Category)
    local BtnData = {}
    
    local MenuBtn = Instance.new("TextButton")
    MenuBtn.Size = UDim2.new(0.85, 0, 0, 32)
    MenuBtn.BackgroundColor3 = Config.Colors.Black
    MenuBtn.BackgroundTransparency = 1
    MenuBtn.Text = ""
    MenuBtn.AutoButtonColor = false
    MenuBtn.ZIndex = 5
    
    local CatValue = Instance.new("StringValue", MenuBtn)
    CatValue.Name = "Category"
    CatValue.Value = Category

    Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 6)

    local BtnText = Instance.new("TextLabel", MenuBtn)
    BtnText.Size = UDim2.new(1, -15, 1, 0)
    BtnText.Position = UDim2.new(0, 15, 0, 0)
    BtnText.BackgroundTransparency = 1
    BtnText.Text = MenuName
    BtnText.TextColor3 = Config.Colors.White
    BtnText.TextTransparency = 0.4
    BtnText.Font = Enum.Font.GothamSemibold
    BtnText.TextSize = 13
    BtnText.TextXAlignment = Enum.TextXAlignment.Left
    BtnText.ZIndex = 6

    local Indicator = Instance.new("Frame", MenuBtn)
    Indicator.Size = UDim2.new(0, 3, 0, 0)
    Indicator.Position = UDim2.new(0, 0, 0.5, 0)
    Indicator.AnchorPoint = Vector2.new(0, 0.5)
    Indicator.BackgroundColor3 = Config.Colors.ToscaGreen
    Indicator.BorderSizePixel = 0
    Indicator.ZIndex = 6

    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local Page = Instance.new("ScrollingFrame", PageFolder)
    Page.Name = MenuName .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 30, 0, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Config.Colors.IceBlue
    Page.Visible = false
    Page.ZIndex = 2

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 10)

    local PagePad = Instance.new("UIPadding", Page)
    PagePad.PaddingTop = UDim.new(0, 15)
    PagePad.PaddingBottom = UDim.new(0, 15)
    PagePad.PaddingLeft = UDim.new(0, 15)
    PagePad.PaddingRight = UDim.new(0, 15)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
    end)

    MenuBtn.MouseButton1Click:Connect(function()
        HideAllPages()
        App.CurrentPage = MenuName
        
        TweenService:Create(MenuBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
        TweenService:Create(BtnText, TweenInfo.new(0.3), {TextColor3 = Config.Colors.ToscaGreen, TextTransparency = 0}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 18)}):Play()
        
        Page.Visible = true
        TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)
    
    MenuBtn.Parent = MenuScroll
    table.insert(App.MenuBtns, { Btn = MenuBtn, Text = BtnText, Indicator = Indicator, Page = Page, Category = Category })
    
    BtnData.Page = Page
    return BtnData
end

-- Simpan ke local variabel jika ingin memanggil page dari tempat lain, hindari _G
local Page_Music = App.CreateMenuButton("Music Panel", "Main")
local Page_Playlist = App.CreateMenuButton("Playlist", "Main")
local Page_Folder = App.CreateMenuButton("Folder", "Main")

local Page_Profile = App.CreateMenuButton("Profile", "Special")
local Page_About = App.CreateMenuButton("About", "Special")
local Page_UpInfo = App.CreateMenuButton("Up Info", "Special")

local function SwitchMenuCategory(TargetCategory)
    local FirstBtnFound = nil
    for _, btnData in pairs(App.MenuBtns) do
        if btnData.Category == TargetCategory then
            btnData.Btn.Visible = true
            if not FirstBtnFound then FirstBtnFound = btnData.Btn end
        else
            btnData.Btn.Visible = false
        end
    end
    -- Trigger tombol pertama dari kategori baru
    if FirstBtnFound then
        for _, connection in pairs(getconnections(FirstBtnFound.MouseButton1Click)) do
            connection.Function()
        end
    end
end

-- ================= SUB PART: LAYAR 1 (GUI/ICON DENGAN ANIMASI) =================
local Layar1_Icons = Instance.new("Frame", ContentClip)
Layar1_Icons.Size = UDim2.new(0, L1_Width, 1, -65)
Layar1_Icons.Position = UDim2.new(0, 0, 0, 65)
Layar1_Icons.BackgroundColor3 = Config.Colors.Black
Layar1_Icons.BorderSizePixel = 0
Layar1_Icons.ZIndex = 5

local L1_Separator = Instance.new("Frame", Layar1_Icons)
L1_Separator.Size = UDim2.new(0, 1, 1, 0)
L1_Separator.Position = UDim2.new(1, -1, 0, 0)
L1_Separator.BackgroundColor3 = Config.Colors.IceBlue
L1_Separator.BackgroundTransparency = 0.7
L1_Separator.BorderSizePixel = 0

local L1_ActiveLine = Instance.new("Frame", Layar1_Icons)
L1_ActiveLine.Size = UDim2.new(0, 3, 0, 24)
L1_ActiveLine.Position = UDim2.new(0, 0, 0, 35)
L1_ActiveLine.AnchorPoint = Vector2.new(0, 0.5)
L1_ActiveLine.BackgroundColor3 = Config.Colors.ToscaGreen
L1_ActiveLine.BorderSizePixel = 0
L1_ActiveLine.ZIndex = 6

Instance.new("UICorner", L1_ActiveLine).CornerRadius = UDim.new(1, 0)

-- 1. Tombol Garis 3 (Hamburger Menu)
local MainMenu_Btn = Instance.new("TextButton", Layar1_Icons)
MainMenu_Btn.Size = UDim2.new(0, 36, 0, 36)
MainMenu_Btn.Position = UDim2.new(0.5, 0, 0, 35)
MainMenu_Btn.AnchorPoint = Vector2.new(0.5, 0.5)
MainMenu_Btn.BackgroundTransparency = 1
MainMenu_Btn.Text = ""
MainMenu_Btn.AutoButtonColor = false
MainMenu_Btn.ZIndex = 6

local H_Line1 = Instance.new("Frame", MainMenu_Btn)
H_Line1.Size = UDim2.new(0, 20, 0, 2)
H_Line1.Position = UDim2.new(0.5, -10, 0.5, -7)
H_Line1.BackgroundColor3 = Config.Colors.White
H_Line1.BorderSizePixel = 0

local H_Line2 = Instance.new("Frame", MainMenu_Btn)
H_Line2.Size = UDim2.new(0, 20, 0, 2)
H_Line2.Position = UDim2.new(0.5, -10, 0.5, -1)
H_Line2.BackgroundColor3 = Config.Colors.White
H_Line2.BorderSizePixel = 0

local H_Line3 = Instance.new("Frame", MainMenu_Btn)
H_Line3.Size = UDim2.new(0, 20, 0, 2)
H_Line3.Position = UDim2.new(0.5, -10, 0.5, 5)
H_Line3.BackgroundColor3 = Config.Colors.White
H_Line3.BorderSizePixel = 0

-- 2. Tombol Logo Axolion
local SpecialMenu_Btn = Instance.new("ImageButton", Layar1_Icons)
SpecialMenu_Btn.Size = UDim2.new(0, 34, 0, 34)
SpecialMenu_Btn.Position = UDim2.new(0.5, 0, 0, 85)
SpecialMenu_Btn.AnchorPoint = Vector2.new(0.5, 0.5)
SpecialMenu_Btn.BackgroundTransparency = 1
SpecialMenu_Btn.Image = Config.SubLogo
SpecialMenu_Btn.ImageColor3 = Config.Colors.White
SpecialMenu_Btn.ImageTransparency = 0.4
SpecialMenu_Btn.AutoButtonColor = false
SpecialMenu_Btn.ZIndex = 6
    
local SidebarOpen = true
local function ToggleSidebar(Category)
    if Category then SwitchMenuCategory(Category) end
    
    if not SidebarOpen then
        SidebarOpen = true
        TweenService:Create(Layar2_Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, L2_Width, 1, -65)}):Play()
        TweenService:Create(Layar3_Content, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -(L1_Width + L2_Width), 1, -65), Position = UDim2.new(0, L1_Width + L2_Width, 0, 65)}):Play()
    end
end

MainMenu_Btn.MouseEnter:Connect(function() TweenService:Create(MainMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 40, 0, 40)}):Play() end)
MainMenu_Btn.MouseLeave:Connect(function() TweenService:Create(MainMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 36, 0, 36)}):Play() end)

SpecialMenu_Btn.MouseEnter:Connect(function() TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 38, 0, 38), ImageTransparency = 0}):Play() end)
SpecialMenu_Btn.MouseLeave:Connect(function() 
    local targetTrans = (App.CurrentL1 == "Special") and 0 or 0.4
    TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 34, 0, 34), ImageTransparency = targetTrans}):Play() 
end)

MainMenu_Btn.MouseButton1Click:Connect(function()
    App.CurrentL1 = "Main"
    TweenService:Create(H_Line1, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.ToscaGreen}):Play()
    TweenService:Create(H_Line2, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.ToscaGreen}):Play()
    TweenService:Create(H_Line3, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.ToscaGreen}):Play()
    TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.3), {ImageColor3 = Config.Colors.White, ImageTransparency = 0.4}):Play()
    TweenService:Create(L1_ActiveLine, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 35)}):Play()
    ToggleSidebar("Main")
end)

SpecialMenu_Btn.MouseButton1Click:Connect(function()
    App.CurrentL1 = "Special"
    TweenService:Create(H_Line1, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.White}):Play()
    TweenService:Create(H_Line2, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.White}):Play()
    TweenService:Create(H_Line3, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.White}):Play()
    TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.3), {ImageColor3 = Config.Colors.ToscaGreen, ImageTransparency = 0}):Play()
    TweenService:Create(L1_ActiveLine, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 85)}):Play()
    ToggleSidebar("Special")
end)

-- Set Default View Awal
App.CurrentL1 = "Main"
SwitchMenuCategory("Main")
H_Line1.BackgroundColor3 = Config.Colors.ToscaGreen
H_Line2.BackgroundColor3 = Config.Colors.ToscaGreen
H_Line3.BackgroundColor3 = Config.Colors.ToscaGreen

-- ==============================================================================
-- [ MODUL BAGIAN 3: MUSIC PLAYER ENGINE (INTEGRATED) ]
-- Gunakan ini untuk mengisi halaman Music Panel yang sudah dibuat di Bagian 2
-- ==============================================================================

local function InitMusicPlayer()
    local TargetPage = Page_Music.Page -- Mengakses halaman dari variabel yang sudah ada
    
    -- Kita buat container tunggal agar UIListLayout milik Page tidak merusak konten kita
    local PlayerContainer = Instance.new("Frame", TargetPage)
    PlayerContainer.Name = "PlayerContainer"
    PlayerContainer.Size = UDim2.new(1, 0, 1, 0) -- Mengisi penuh page
    PlayerContainer.BackgroundTransparency = 1
    PlayerContainer.LayoutOrder = 1 -- Agar berada di urutan atas
    
    -- Define Colors lokal untuk modul ini
    local Colors = Config.Colors
    
    -- 1. PREMIUM BADGE & TITLE
    local PremiumBadge = Instance.new("Frame", PlayerContainer)
    PremiumBadge.Size = UDim2.new(0, 80, 0, 25)
    PremiumBadge.Position = UDim2.new(0, 10, 0, 10)
    PremiumBadge.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    PremiumBadge.BackgroundTransparency = 0.8
    Instance.new("UICorner", PremiumBadge).CornerRadius = UDim.new(0, 6)
    
    local PText = Instance.new("TextLabel", PremiumBadge)
    PText.Size = UDim2.new(1, 0, 1, 0)
    PText.Text = "👑 PREMIUM"
    PText.TextColor3 = Color3.fromRGB(255, 215, 0)
    PText.Font = Enum.Font.GothamBold
    PText.TextSize = 10
    PText.BackgroundTransparency = 1

    -- 2. VINYL VISUALIZER (Center)
    local AlbumWrapper = Instance.new("Frame", PlayerContainer)
    AlbumWrapper.Name = "CD_Wrapper"
    AlbumWrapper.Size = UDim2.new(0, 150, 0, 150)
    AlbumWrapper.Position = UDim2.new(0.5, 0, 0, 100)
    AlbumWrapper.AnchorPoint = Vector2.new(0.5, 0.5)
    AlbumWrapper.BackgroundTransparency = 1
    
    local AlbumCD = Instance.new("ImageLabel", AlbumWrapper)
    AlbumCD.Size = UDim2.new(1, 0, 1, 0)
    AlbumCD.Image = Config.Thumbnail
    AlbumCD.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", AlbumCD).CornerRadius = UDim.new(1, 0)
    
    -- 3. PROGRESS BAR & INFO
    local SongTitle = Instance.new("TextLabel", PlayerContainer)
    SongTitle.Size = UDim2.new(0.9, 0, 0, 30)
    SongTitle.Position = UDim2.new(0.5, 0, 0, 200)
    SongTitle.AnchorPoint = Vector2.new(0.5, 0)
    SongTitle.Text = "Axolion Theme"
    SongTitle.TextColor3 = Colors.White
    SongTitle.Font = Enum.Font.GothamBold
    SongTitle.TextSize = 16
    SongTitle.BackgroundTransparency = 1
    
    -- 4. CONTROL PANEL (Horisontal)
    local ControlPanel = Instance.new("Frame", PlayerContainer)
    ControlPanel.Size = UDim2.new(0.9, 0, 0, 60)
    ControlPanel.Position = UDim2.new(0.5, 0, 1, -80)
    ControlPanel.AnchorPoint = Vector2.new(0.5, 0)
    ControlPanel.BackgroundColor3 = Colors.DarkBlue
    ControlPanel.BackgroundTransparency = 0.5
    Instance.new("UICorner", ControlPanel).CornerRadius = UDim.new(0, 15)
    
    local ControlLayout = Instance.new("UIListLayout", ControlPanel)
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.Padding = UDim.new(0, 20)

    -- Fungsi tombol helper
    local function CreateBtn(text, size)
        local b = Instance.new("TextButton", ControlPanel)
        b.Size = UDim2.new(0, size, 0, size)
        b.BackgroundTransparency = 1
        b.Text = text
        b.TextColor3 = Colors.White
        b.TextSize = size * 0.6
        return b
    end

    CreateBtn("⏮", 35)
    local PlayBtn = CreateBtn("▶", 45)
    CreateBtn("⏭", 35)
    CreateBtn("🔊", 35)
    
    -- Feedback Visual Tombol Play
    PlayBtn.MouseButton1Click:Connect(function()
        PlayBtn.Text = (PlayBtn.Text == "▶") and "⏸" or "▶"
    end)
end

-- Eksekusi Modul
InitMusicPlayer()

-- ==============================================================================
-- KOREKSI & FIX TOTAL: BAGIAN 3 TAHAP 2 (PREMIUM PLAYLIST ENGINE)
-- ==============================================================================

local PlaylistPage = Page_Playlist.Page
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- [FIX UTAMA] Hancurkan layout bawaan agar tidak merusak posisi absolute antar halaman menu
local oldLayout = PlaylistPage:FindFirstChildOfClass("UIListLayout")
if oldLayout then oldLayout:Destroy() end
local oldPadding = PlaylistPage:FindFirstChildOfClass("UIPadding")
if oldPadding then oldPadding:Destroy() end

-- Konfigurasi Properti Canvas Playlist Page
PlaylistPage.ScrollBarThickness = 3
PlaylistPage.ScrollBarImageColor3 = Config.Colors.ToscaGreen
PlaylistPage.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Global State Initialization (Mendukung Sinkronisasi Antar Menu)
App.Playlists = App.Playlists or {
    ["Default"] = {
        {ID = 1837874717, Title = "Axolion Cyber Horizon", Artist = "Community Beats"},
        {ID = 1843405728, Title = "Neon Tokyo Midnight", Artist = "Synthwave Lab"}
    },
    ["Favorites"] = {}
}
App.CurrentPlaylist = App.CurrentPlaylist or "Default"
App.MusicQueue = App.MusicQueue or {}
App.CurrentTrackIndex = App.CurrentTrackIndex or 1

-- Global Sound Engine Setup
if not App.GlobalAudioSource then
    App.GlobalAudioSource = Instance.new("Sound", game:GetService("SoundService"))
    App.GlobalAudioSource.Name = "Axolion_AudioEngine"
    App.GlobalAudioSource.Volume = 0.6
end

-- ================= SYSTEM FUNCTION: SINKRONISASI KE MUSIC PANEL =================
local function SyncToMusicPanel(track, shouldPlay)
    if not track then return end
    
    -- 1. Jalankan/Hentikan Audio Engine
    App.GlobalAudioSource.SoundId = "rbxassetid://" .. tostring(track.ID)
    if shouldPlay then
        App.GlobalAudioSource:Play()
    else
        App.GlobalAudioSource:Stop()
    end
    
    -- 2. Cari & Update Elemen Visual di Halaman Music Panel secara Realtime
    local MusicPageRef = Page_Music and Page_Music.Page
    if MusicPageRef then
        local Container = MusicPageRef:FindFirstChild("PlayerContainer")
        if Container then
            -- Update Judul Lagu
            local TitleLabel = Container:FindFirstChild("SongTitle")
            if TitleLabel then
                TitleLabel.Text = track.Title .. " - " .. track.Artist
            end
            
            -- Update Gambar Vinyl/CD Thumb jika ada
            local CDWrapper = Container:FindFirstChild("CD_Wrapper")
            if CDWrapper then
                local CDAudio = CDWrapper:FindFirstChildOfClass("ImageLabel")
                if CDAudio then
                    CDAudio.Image = Config.Thumbnail
                end
            end
            
            -- Sinkronisasi Indikator Tombol Play/Pause Utama
            local ControlPanel = Container:FindFirstChild("ControlPanel") or Container
            for _, child in ipairs(ControlPanel:GetChildren()) do
                if child:IsA("TextButton") and (child.Text == "▶" or child.Text == "⏸") then
                    child.Text = shouldPlay and "⏸" or "▶"
                end
            end
        end
    end
end

-- Inject sinkronisasi interaktif langsung ke tombol play bawaan di Music Panel (Jika ditekan manual)
task.spawn(function()
    local MusicPageRef = Page_Music and Page_Music.Page
    if MusicPageRef then
        local Container = MusicPageRef:WaitForChild("PlayerContainer", 5)
        if Container then
            for _, child in ipairs(Container:GetChildren()) do
                if child:IsA("TextButton") and (child.Text == "▶" or child.Text == "⏸") then
                    child.MouseButton1Click:Connect(function()
                        if App.GlobalAudioSource.IsPlaying then
                            App.GlobalAudioSource:Pause()
                            child.Text = "▶"
                        else
                            if App.GlobalAudioSource.SoundId ~= "" then
                                App.GlobalAudioSource:Play()
                                child.Text = "⏸"
                            end
                        end
                    end)
                end
            end
        end
    end
end)

-- ================= HELPER: ANIMASI HOVER PREMIUM =================
local function ApplyPremiumFeedback(instance, hoverBg, hoverText)
    local defBg = instance.BackgroundColor3
    local defText = instance.TextColor3
    
    instance.MouseEnter:Connect(function()
        TweenService:Create(instance, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = hoverBg,
            TextColor3 = hoverText
        }):Play()
    end)
    
    instance.MouseLeave:Connect(function()
        TweenService:Create(instance, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = defBg,
            TextColor3 = defText
        }):Play()
    end)
end

-- ================= SUB PART: CONTAINER UTAMA (GLASSMORPHISM) =================
local PlaylistWrapper = Instance.new("Frame", PlaylistPage)
PlaylistWrapper.Name = "PlaylistWrapper"
PlaylistWrapper.Size = UDim2.new(1, 0, 1, 0)
PlaylistWrapper.BackgroundTransparency = 1

-- Search Bar Container
local SearchBar = Instance.new("Frame", PlaylistWrapper)
SearchBar.Size = UDim2.new(1, -24, 0, 42)
SearchBar.Position = UDim2.new(0, 12, 0, 10)
SearchBar.BackgroundColor3 = Color3.fromRGB(8, 14, 26)
SearchBar.BackgroundTransparency = 0.3
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 8)
local SStroke = Instance.new("UIStroke", SearchBar)
SStroke.Color = Config.Colors.ToscaGreen
SStroke.Transparency = 0.6

local SearchInput = Instance.new("TextBox", SearchBar)
SearchInput.Size = UDim2.new(1, -55, 1, 0)
SearchInput.Position = UDim2.new(0, 14, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.PlaceholderText = "Masukkan ID Audio Musik Roblox..."
SearchInput.Text = ""
SearchInput.TextColor3 = Config.Colors.White
SearchInput.PlaceholderColor3 = Color3.fromRGB(110, 125, 145)
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.TextSize = 13
SearchInput.TextXAlignment = Enum.TextXAlignment.Left

local SearchBtn = Instance.new("TextButton", SearchBar)
SearchBtn.Size = UDim2.new(0, 32, 0, 32)
SearchBtn.Position = UDim2.new(1, -38, 0.5, -16)
SearchBtn.BackgroundColor3 = Color3.fromRGB(14, 22, 38)
SearchBtn.Text = "🔍"
SearchBtn.TextColor3 = Config.Colors.ToscaGreen
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 13
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 6)
ApplyPremiumFeedback(SearchBtn, Config.Colors.ToscaGreen, Config.Colors.Black)

-- Panel Hasil Pencarian (Muncul jika ID Valid)
local ResultPane = Instance.new("Frame", PlaylistWrapper)
ResultPane.Size = UDim2.new(1, -24, 0, 54)
ResultPane.Position = UDim2.new(0, 12, 0, 60)
ResultPane.BackgroundColor3 = Color3.fromRGB(12, 22, 40)
ResultPane.Visible = false
Instance.new("UICorner", ResultPane).CornerRadius = UDim.new(0, 8)
local RStroke = Instance.new("UIStroke", ResultPane)
RStroke.Color = Config.Colors.IceBlue
RStroke.Transparency = 0.5

local RTitle = Instance.new("TextLabel", ResultPane)
RTitle.Size = UDim2.new(1, -65, 0, 22)
RTitle.Position = UDim2.new(0, 14, 0, 6)
RTitle.BackgroundTransparency = 1
RTitle.TextColor3 = Config.Colors.White
RTitle.Font = Enum.Font.GothamBold
RTitle.TextSize = 12
RTitle.TextXAlignment = Enum.TextXAlignment.Left
RTitle.TextTruncate = Enum.TextTruncate.AtEnd

local RArtist = Instance.new("TextLabel", ResultPane)
RArtist.Size = UDim2.new(1, -65, 0, 18)
RArtist.Position = UDim2.new(0, 14, 0, 26)
RArtist.BackgroundTransparency = 1
RArtist.TextColor3 = Color3.fromRGB(140, 160, 180)
RArtist.Font = Enum.Font.Gotham
RArtist.TextSize = 11
RArtist.TextXAlignment = Enum.TextXAlignment.Left

local SaveBtn = Instance.new("TextButton", ResultPane)
SaveBtn.Size = UDim2.new(0, 32, 0, 32)
SaveBtn.Position = UDim2.new(1, -42, 0.5, -16)
SaveBtn.BackgroundColor3 = Color3.fromRGB(18, 30, 50)
SaveBtn.Text = "💾"
SaveBtn.TextColor3 = Config.Colors.White
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 13
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)
ApplyPremiumFeedback(SaveBtn, Config.Colors.ToscaGreen, Config.Colors.Black)

-- Selector Playlist Terbuka
local PlaylistSelector = Instance.new("TextButton", PlaylistWrapper)
PlaylistSelector.Size = UDim2.new(1, -24, 0, 36)
PlaylistSelector.Position = UDim2.new(0, 12, 0, 122)
PlaylistSelector.BackgroundColor3 = Color3.fromRGB(10, 18, 32)
PlaylistSelector.Text = "🎵 Ruang Musik: " .. App.CurrentPlaylist .. "  ▼"
PlaylistSelector.TextColor3 = Config.Colors.White
PlaylistSelector.Font = Enum.Font.GothamBold
PlaylistSelector.TextSize = 12
Instance.new("UICorner", PlaylistSelector).CornerRadius = UDim.new(0, 8)
local SelectStroke = Instance.new("UIStroke", PlaylistSelector)
SelectStroke.Color = Config.Colors.ToscaGreen
SelectStroke.Transparency = 0.5

-- Area Scroll Utama Daftar Musik (Murni Hanya Menampilkan List Music)
local MusicTrackScroll = Instance.new("ScrollingFrame", PlaylistWrapper)
MusicTrackScroll.Size = UDim2.new(1, -24, 1, -175)
MusicTrackScroll.Position = UDim2.new(0, 12, 0, 165)
MusicTrackScroll.BackgroundTransparency = 1
MusicTrackScroll.ScrollBarThickness = 2
MusicTrackScroll.ScrollBarImageColor3 = Config.Colors.ToscaGreen

local MainListLayout = Instance.new("UIListLayout", MusicTrackScroll)
MainListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainListLayout.Padding = UDim.new(0, 6)

-- ================= SUB PART: CONTEXT MENU SYSTEM (MODAL TITIK 3) =================
local ContextOverlay = Instance.new("TextButton", PlaylistWrapper)
ContextOverlay.Size = UDim2.new(1, 0, 1, 0)
ContextOverlay.BackgroundTransparency = 1
ContextOverlay.Text = ""
ContextOverlay.Visible = false
ContextOverlay.ZIndex = 50

local ContextFrame = Instance.new("Frame", ContextOverlay)
ContextFrame.Size = UDim2.new(0, 175, 0, 150)
ContextFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 22)
ContextFrame.ZIndex = 51
Instance.new("UICorner", ContextFrame).CornerRadius = UDim.new(0, 8)
local ContextStroke = Instance.new("UIStroke", ContextFrame)
ContextStroke.Color = Config.Colors.ToscaGreen
ContextStroke.Thickness = 1.2

local function AddMenuOption(text, yPos, isDanger)
    local option = Instance.new("TextButton", ContextFrame)
    option.Size = UDim2.new(1, -14, 0, 28)
    option.Position = UDim2.new(0, 7, 0, yPos)
    option.BackgroundColor3 = Color3.fromRGB(14, 20, 34)
    option.Text = text
    option.TextColor3 = isDanger and Color3.fromRGB(255, 90, 90) or Config.Colors.White
    option.Font = Enum.Font.GothamMedium
    option.TextSize = 11
    option.ZIndex = 52
    Instance.new("UICorner", option).CornerRadius = UDim.new(0, 5)
    
    if isDanger then
        ApplyPremiumFeedback(option, Color3.fromRGB(200, 45, 45), Config.Colors.White)
    else
        ApplyPremiumFeedback(option, Config.Colors.ToscaGreen, Config.Colors.Black)
    end
    return option
end

local ActionPlay = AddMenuOption("▶  Putar Sekarang", 8)
local ActionNext = AddMenuOption("⏭  Putar Selanjutnya", 42)
local ActionFolder = AddMenuOption("📁  Kirim ke Tahap 3", 76)
local ActionDelete = AddMenuOption("🗑  Hapus dari List", 110, true)

local TargetTrackData = nil
local TargetTrackIdx = nil

local function HideContextMenu()
    ContextOverlay.Visible = false
end
ContextOverlay.MouseButton1Click:Connect(HideContextMenu)

-- ================= SUB PART: LOGIC ENGINE & CORE REFRESH =================
local CurrentSearchedData = nil

SearchBtn.MouseButton1Click:Connect(function()
    local val = SearchInput.Text
    if val == "" then return App.Notify("Peringatan", "Isi ID Audio musik!", 2.5) end
    local cleanID = tonumber(val)
    
    if cleanID then
        SearchBtn.Text = "..."
        local success, res = pcall(function()
            return MarketplaceService:GetProductInfo(cleanID, Enum.InfoType.Asset)
        end)
        SearchBtn.Text = "🔍"
        
        if success and res and res.AssetTypeId == 3 then
            CurrentSearchedData = {ID = cleanID, Title = res.Name, Artist = res.Creator.Name or "Axolion Producer"}
            RTitle.Text = CurrentSearchedData.Title
            RArtist.Text = "Pembuat: " .. CurrentSearchedData.Artist
            ResultPane.Visible = true
        else
            App.Notify("Gagal", "ID Audio salah atau tidak terdaftar.", 3)
        end
    else
        App.Notify("Error", "Gunakan format angka ID Audio.", 3)
    end
end)

SaveBtn.MouseButton1Click:Connect(function()
    if CurrentSearchedData then
        table.insert(App.Playlists[App.CurrentPlaylist], CurrentSearchedData)
        ResultPane.Visible = false
        SearchInput.Text = ""
        App.BuildPlaylistView()
        App.Notify("Sukses", "Musik tersimpan ke " .. App.CurrentPlaylist, 2)
        CurrentSearchedData = nil
    end
end)

function App.BuildPlaylistView()
    for _, child in ipairs(MusicTrackScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local list = App.Playlists[App.CurrentPlaylist] or {}
    
    for idx, track in ipairs(list) do
        local trackRow = Instance.new("Frame", MusicTrackScroll)
        trackRow.Size = UDim2.new(1, 0, 0, 48)
        trackRow.BackgroundColor3 = Color3.fromRGB(11, 16, 28)
        trackRow.BorderSizePixel = 0
        Instance.new("UICorner", trackRow).CornerRadius = UDim.new(0, 6)
        
        local grad = Instance.new("UIGradient", trackRow)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 10, 18))
        })
        
        local sideBar = Instance.new("Frame", trackRow)
        sideBar.Size = UDim2.new(0, 3, 1, 0)
        sideBar.BackgroundColor3 = Config.Colors.ToscaGreen
        sideBar.BorderSizePixel = 0
        
        local tName = Instance.new("TextLabel", trackRow)
        tName.Size = UDim2.new(1, -60, 0, 22)
        tName.Position = UDim2.new(0, 14, 0, 5)
        tName.BackgroundTransparency = 1
        tName.Text = track.Title
        tName.TextColor3 = Config.Colors.White
        tName.Font = Enum.Font.GothamSemibold
        tName.TextSize = 12
        tName.TextXAlignment = Enum.TextXAlignment.Left
        tName.TextTruncate = Enum.TextTruncate.AtEnd
        
        local tSub = Instance.new("TextLabel", trackRow)
        tSub.Size = UDim2.new(1, -60, 0, 16)
        tSub.Position = UDim2.new(0, 14, 0, 25)
        tSub.BackgroundTransparency = 1
        tSub.Text = track.Artist .. "  •  ID: " .. tostring(track.ID)
        tSub.TextColor3 = Color3.fromRGB(120, 135, 155)
        tSub.Font = Enum.Font.Gotham
        tSub.TextSize = 10
        tSub.TextXAlignment = Enum.TextXAlignment.Left
        
        local dots = Instance.new("TextButton", trackRow)
        dots.Size = UDim2.new(0, 30, 0, 30)
        dots.Position = UDim2.new(1, -36, 0.5, -15)
        dots.BackgroundTransparency = 1
        dots.Text = "⋮"
        dots.TextColor3 = Color3.fromRGB(160, 175, 195)
        dots.Font = Enum.Font.GothamBold
        dots.TextSize = 16
        
        dots.MouseEnter:Connect(function() dots.TextColor3 = Config.Colors.ToscaGreen end)
        dots.MouseLeave:Connect(function() dots.TextColor3 = Color3.fromRGB(160, 175, 195) end)
        
        dots.MouseButton1Click:Connect(function()
            TargetTrackData = track
            TargetTrackIdx = idx
            
            local mouseLoc = UserInputService:GetMouseLocation()
            local screenPos = PlaylistPage.AbsolutePosition
            local finalX = math.clamp(mouseLoc.X - screenPos.X - 180, 10, PlaylistPage.AbsoluteSize.X - 185)
            local finalY = math.clamp(mouseLoc.Y - screenPos.Y - 30, 10, PlaylistPage.AbsoluteSize.Y - 160)
            
            ContextFrame.Position = UDim2.new(0, finalX, 0, finalY)
            ContextOverlay.Visible = true
        end)
    end
    
    MusicTrackScroll.CanvasSize = UDim2.new(0, 0, 0, MainListLayout.AbsoluteContentSize.Y + 15)
end

-- ================= EXECUTION CONTEXT OPERATIONS =================
ActionPlay.MouseButton1Click:Connect(function()
    if TargetTrackData then
        SyncToMusicPanel(TargetTrackData, true)
        App.Notify("Playing", "Memutar: " .. TargetTrackData.Title, 2)
        HideContextMenu()
    end
end)

ActionNext.MouseButton1Click:Connect(function()
    if TargetTrackData then
        table.insert(App.MusicQueue, TargetTrackData)
        App.Notify("Queue", "Ditambahkan ke antrean selanjutnya", 2)
        HideContextMenu()
    end
end)

ActionFolder.MouseButton1Click:Connect(function()
    if TargetTrackData then
        App.PendingFolderTrack = TargetTrackData
        App.Notify("Folder Terkunci", "Musik siap! Silahkan ke Tahap 3 untuk memasukkan ke folder.", 3.5)
        HideContextMenu()
    end
end)

ActionDelete.MouseButton1Click:Connect(function()
    if TargetTrackIdx and App.Playlists[App.CurrentPlaylist] then
        table.remove(App.Playlists[App.CurrentPlaylist], TargetTrackIdx)
        App.BuildPlaylistView()
        App.Notify("Hapus", "Musik dikeluarkan dari list", 2)
        HideContextMenu()
    end
end)

PlaylistSelector.MouseButton1Click:Connect(function()
    App.CurrentPlaylist = (App.CurrentPlaylist == "Default") and "Favorites" or "Default"
    PlaylistSelector.Text = "🎵 Ruang Musik: " .. App.CurrentPlaylist .. "  ▼"
    App.BuildPlaylistView()
end)

-- Render Tampilan Awal Secara Otomatis
App.BuildPlaylistView()