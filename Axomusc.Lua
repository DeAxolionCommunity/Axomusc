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
-- BAGIAN 3: KONTEN MENU EKSKLUSIF (TAHAP 1 - MUSIC PANEL PREMIUM)
-- ==============================================================================

local MusicPage = Page_Music.Page

-- ================= SUB PART: AUDIO ENGINE & QUEUE SYSTEM =================
App.MusicQueue = {}
App.CurrentTrackIndex = 0
App.IsPlaying = false
App.IsShuffle = false
App.IsRepeat = false
App.CrossfadeEnabled = false
App.CrossfadeTime = 2 

local AudioCore = Instance.new("Sound")
AudioCore.Name = "Axomusc_AudioEngine_Main"
AudioCore.Parent = CoreGui
AudioCore.Volume = 1
AudioCore.Looped = false

local AudioCore2 = Instance.new("Sound") 
AudioCore2.Name = "Axomusc_AudioEngine_Crossfade"
AudioCore2.Parent = CoreGui
AudioCore2.Volume = 0
AudioCore2.Looped = false

local EQ = Instance.new("EqualizerSoundEffect")
EQ.Name = "Axomusc_EQ"
EQ.Parent = AudioCore
EQ.LowGain = 0
EQ.MidGain = 0
EQ.HighGain = 0

local EQ2 = Instance.new("EqualizerSoundEffect")
EQ2.Name = "Axomusc_EQ2"
EQ2.Parent = AudioCore2
EQ2.LowGain = 0
EQ2.MidGain = 0
EQ2.HighGain = 0

-- ================= SUB PART: NOW PLAYING & VISUALIZER =================
local NowPlayingCard = Instance.new("Frame", MusicPage)
NowPlayingCard.Name = "NowPlaying_Card"
NowPlayingCard.Size = UDim2.new(1, 0, 0, 160)
NowPlayingCard.BackgroundColor3 = Config.Colors.DarkBlue
NowPlayingCard.BackgroundTransparency = 0.2
NowPlayingCard.BorderSizePixel = 0
Instance.new("UICorner", NowPlayingCard).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", NowPlayingCard).Color = Config.Colors.IceBlue
Instance.new("UIStroke", NowPlayingCard).Transparency = 0.5

local AlbumCD_Bg = Instance.new("Frame", NowPlayingCard)
AlbumCD_Bg.Size = UDim2.new(0, 120, 0, 120)
AlbumCD_Bg.Position = UDim2.new(0, 20, 0.5, 0)
AlbumCD_Bg.AnchorPoint = Vector2.new(0, 0.5)
AlbumCD_Bg.BackgroundColor3 = Config.Colors.Black
Instance.new("UICorner", AlbumCD_Bg).CornerRadius = UDim.new(1, 0)
local CDStroke = Instance.new("UIStroke", AlbumCD_Bg)
CDStroke.Color = Config.Colors.White
CDStroke.Thickness = 2

local AlbumCD = Instance.new("ImageLabel", AlbumCD_Bg)
AlbumCD.Size = UDim2.new(1, -4, 1, -4)
AlbumCD.Position = UDim2.new(0.5, 0, 0.5, 0)
AlbumCD.AnchorPoint = Vector2.new(0.5, 0.5)
AlbumCD.BackgroundTransparency = 1
AlbumCD.Image = Config.Thumbnail
Instance.new("UICorner", AlbumCD).CornerRadius = UDim.new(1, 0)

local CD_Hole = Instance.new("Frame", AlbumCD)
CD_Hole.Size = UDim2.new(0, 25, 0, 25)
CD_Hole.Position = UDim2.new(0.5, 0, 0.5, 0)
CD_Hole.AnchorPoint = Vector2.new(0.5, 0.5)
CD_Hole.BackgroundColor3 = Config.Colors.DarkBlue
Instance.new("UICorner", CD_Hole).CornerRadius = UDim.new(1, 0)

local BassRing = Instance.new("Frame", AlbumCD_Bg)
BassRing.Size = UDim2.new(1, 10, 1, 10)
BassRing.Position = UDim2.new(0.5, 0, 0.5, 0)
BassRing.AnchorPoint = Vector2.new(0.5, 0.5)
BassRing.BackgroundTransparency = 1
BassRing.ZIndex = 0
Instance.new("UICorner", BassRing).CornerRadius = UDim.new(1, 0)
local BassStroke = Instance.new("UIStroke", BassRing)
BassStroke.Thickness = 4
local BassGradient = Instance.new("UIGradient", BassStroke)
BassGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Colors.IceBlue),
    ColorSequenceKeypoint.new(0.5, Config.Colors.Black),
    ColorSequenceKeypoint.new(1, Config.Colors.White)
}

local SongTitle = Instance.new("TextLabel", NowPlayingCard)
SongTitle.Size = UDim2.new(1, -170, 0, 35)
SongTitle.Position = UDim2.new(0, 160, 0, 25)
SongTitle.BackgroundTransparency = 1
SongTitle.Text = "No Audio Playing"
SongTitle.TextColor3 = Config.Colors.White
SongTitle.Font = Enum.Font.GothamBold
SongTitle.TextSize = 22
SongTitle.TextXAlignment = Enum.TextXAlignment.Left
SongTitle.TextTruncate = Enum.TextTruncate.AtEnd

local SongArtist = Instance.new("TextLabel", NowPlayingCard)
SongArtist.Size = UDim2.new(1, -170, 0, 20)
SongArtist.Position = UDim2.new(0, 160, 0, 60)
SongArtist.BackgroundTransparency = 1
SongArtist.Text = "Select track from Playlist/Folder"
SongArtist.TextColor3 = Config.Colors.IceBlue
SongArtist.Font = Enum.Font.GothamSemibold
SongArtist.TextSize = 13
SongArtist.TextXAlignment = Enum.TextXAlignment.Left

-- Premium Interactive Progress Bar
local ProgressContainer = Instance.new("Frame", NowPlayingCard)
ProgressContainer.Size = UDim2.new(1, -170, 0, 20)
ProgressContainer.Position = UDim2.new(0, 160, 0, 110)
ProgressContainer.BackgroundTransparency = 1

local ProgressBg = Instance.new("TextButton", ProgressContainer)
ProgressBg.Size = UDim2.new(1, 0, 0, 6)
ProgressBg.Position = UDim2.new(0, 0, 0.5, 0)
ProgressBg.AnchorPoint = Vector2.new(0, 0.5)
ProgressBg.BackgroundColor3 = Config.Colors.Black
ProgressBg.Text = ""
ProgressBg.AutoButtonColor = false
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

local ProgressFill = Instance.new("Frame", ProgressBg)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Config.Colors.ToscaGreen
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

local ProgressKnob = Instance.new("Frame", ProgressFill)
ProgressKnob.Size = UDim2.new(0, 12, 0, 12)
ProgressKnob.Position = UDim2.new(1, -6, 0.5, 0)
ProgressKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressKnob.BackgroundColor3 = Config.Colors.White
Instance.new("UICorner", ProgressKnob).CornerRadius = UDim.new(1, 0)

local TimeCurrent = Instance.new("TextLabel", ProgressContainer)
TimeCurrent.Size = UDim2.new(0, 50, 0, 15)
TimeCurrent.Position = UDim2.new(0, 0, 1, 2)
TimeCurrent.BackgroundTransparency = 1
TimeCurrent.Text = "0:00"
TimeCurrent.TextColor3 = Config.Colors.White
TimeCurrent.Font = Enum.Font.Gotham
TimeCurrent.TextSize = 11
TimeCurrent.TextXAlignment = Enum.TextXAlignment.Left

local TimeTotal = Instance.new("TextLabel", ProgressContainer)
TimeTotal.Size = UDim2.new(0, 50, 0, 15)
TimeTotal.Position = UDim2.new(1, -50, 1, 2)
TimeTotal.BackgroundTransparency = 1
TimeTotal.Text = "0:00"
TimeTotal.TextColor3 = Config.Colors.White
TimeTotal.Font = Enum.Font.Gotham
TimeTotal.TextSize = 11
TimeTotal.TextXAlignment = Enum.TextXAlignment.Right

local isDraggingProg = false
ProgressBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingProg = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDraggingProg = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if isDraggingProg and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pct = math.clamp((input.Position.X - ProgressBg.AbsolutePosition.X) / ProgressBg.AbsoluteSize.X, 0, 1)
        ProgressFill.Size = UDim2.new(pct, 0, 1, 0)
        if AudioCore.TimeLength > 0 then AudioCore.TimePosition = pct * AudioCore.TimeLength end
    end
end)

-- ================= SUB PART: MAIN CONTROL PANEL =================
local ControlPanel = Instance.new("Frame", MusicPage)
ControlPanel.Size = UDim2.new(1, 0, 0, 70)
ControlPanel.BackgroundColor3 = Config.Colors.Black
ControlPanel.BackgroundTransparency = 0.5
Instance.new("UICorner", ControlPanel).CornerRadius = UDim.new(0, 10)

local CtrlLayout = Instance.new("UIListLayout", ControlPanel)
CtrlLayout.FillDirection = Enum.FillDirection.Horizontal
CtrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CtrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CtrlLayout.Padding = UDim.new(0, 20)
CtrlLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateCtrlBtn(name, text, size, txtSize, order, isMain)
    local btn = Instance.new("TextButton", ControlPanel)
    btn.Name = name
    btn.Size = UDim2.new(0, size, 0, size)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = isMain and Config.Colors.White or Config.Colors.DarkBlue
    btn.Text = text
    btn.TextColor3 = isMain and Config.Colors.Black or Config.Colors.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = txtSize
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    if not isMain then Instance.new("UIStroke", btn).Color = Config.Colors.IceBlue end
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, size+4, 0, size+4)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, size, 0, size)}):Play() end)
    return btn
end

local BtnShuffle = CreateCtrlBtn("BtnShuffle", "🔀", 35, 14, 1, false)
local BtnPrev    = CreateCtrlBtn("BtnPrev", "⏮", 40, 16, 2, false)
local BtnPlay    = CreateCtrlBtn("BtnPlay", "▶", 55, 24, 3, true)
local BtnNext    = CreateCtrlBtn("BtnNext", "⏭", 40, 16, 4, false)
local BtnRepeat  = CreateCtrlBtn("BtnRepeat", "🔁", 35, 14, 5, false)

-- ================= SUB PART: FEATURE TOOLBAR & DYNAMIC PANELS =================
local Toolbar = Instance.new("Frame", MusicPage)
Toolbar.Size = UDim2.new(1, 0, 0, 45)
Toolbar.BackgroundTransparency = 1

local ToolLayout = Instance.new("UIListLayout", Toolbar)
ToolLayout.FillDirection = Enum.FillDirection.Horizontal
ToolLayout.HorizontalAlignment = Enum.HorizontalAlignment.SpaceBetween
ToolLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ActivePanel = nil
local DynamicPanelContainer = Instance.new("Frame", MusicPage)
DynamicPanelContainer.Size = UDim2.new(1, 0, 0, 0) -- Expandable
DynamicPanelContainer.BackgroundColor3 = Config.Colors.DarkBlue
DynamicPanelContainer.BackgroundTransparency = 0.3
DynamicPanelContainer.ClipsDescendants = true
Instance.new("UICorner", DynamicPanelContainer).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", DynamicPanelContainer).Color = Config.Colors.IceBlue

local function CreateToolBtn(text, icon, order)
    local btn = Instance.new("TextButton", Toolbar)
    btn.Size = UDim2.new(0.23, 0, 1, 0)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = Config.Colors.Black
    btn.BackgroundTransparency = 0.2
    btn.Text = icon .. " " .. text
    btn.TextColor3 = Config.Colors.White
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Config.Colors.ToscaGreen
    stroke.Transparency = 1
    return btn, stroke
end

local BtnVol, StrVol = CreateToolBtn("Volume", "🔊", 1)
local BtnTmp, StrTmp = CreateToolBtn("Tempo", "⏱", 2)
local BtnEQ, StrEQ   = CreateToolBtn("Equalizer", "🎛", 3)
local BtnFX, StrFX   = CreateToolBtn("FX", "✨", 4)

-- Sub-Panels (Hidden by default)
local PnlVol = Instance.new("Frame", DynamicPanelContainer)
PnlVol.Size = UDim2.new(1, 0, 1, 0)
PnlVol.BackgroundTransparency = 1
PnlVol.Visible = false

local PnlTmp = Instance.new("Frame", DynamicPanelContainer)
PnlTmp.Size = UDim2.new(1, 0, 1, 0)
PnlTmp.BackgroundTransparency = 1
PnlTmp.Visible = false

local PnlEQ = Instance.new("Frame", DynamicPanelContainer)
PnlEQ.Size = UDim2.new(1, 0, 1, 0)
PnlEQ.BackgroundTransparency = 1
PnlEQ.Visible = false

local PnlFX = Instance.new("Frame", DynamicPanelContainer)
PnlFX.Size = UDim2.new(1, 0, 1, 0)
PnlFX.BackgroundTransparency = 1
PnlFX.Visible = false

local function SwitchDynamicPanel(targetBtn, targetStroke, targetPanel)
    for _, str in ipairs({StrVol, StrTmp, StrEQ, StrFX}) do
        TweenService:Create(str, TweenInfo.new(0.2), {Transparency = 1}):Play()
    end
    for _, p in ipairs({PnlVol, PnlTmp, PnlEQ, PnlFX}) do p.Visible = false end

    if ActivePanel == targetPanel then
        TweenService:Create(DynamicPanelContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        ActivePanel = nil
    else
        TweenService:Create(targetStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
        targetPanel.Visible = true
        TweenService:Create(DynamicPanelContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 70)}):Play()
        ActivePanel = targetPanel
    end
end

BtnVol.MouseButton1Click:Connect(function() SwitchDynamicPanel(BtnVol, StrVol, PnlVol) end)
BtnTmp.MouseButton1Click:Connect(function() SwitchDynamicPanel(BtnTmp, StrTmp, PnlTmp) end)
BtnEQ.MouseButton1Click:Connect(function() SwitchDynamicPanel(BtnEQ, StrEQ, PnlEQ) end)
BtnFX.MouseButton1Click:Connect(function() SwitchDynamicPanel(BtnFX, StrFX, PnlFX) end)

-- [Isi Panel Volume 0-100%]
local VolTitle = Instance.new("TextLabel", PnlVol)
VolTitle.Size = UDim2.new(0, 100, 0, 20)
VolTitle.Position = UDim2.new(0, 15, 0, 10)
VolTitle.BackgroundTransparency = 1
VolTitle.Text = "Master Volume"
VolTitle.TextColor3 = Config.Colors.IceBlue
VolTitle.Font = Enum.Font.GothamBold
VolTitle.TextSize = 12
VolTitle.TextXAlignment = Enum.TextXAlignment.Left

local VolPct = Instance.new("TextLabel", PnlVol)
VolPct.Size = UDim2.new(0, 50, 0, 20)
VolPct.Position = UDim2.new(1, -65, 0, 10)
VolPct.BackgroundTransparency = 1
VolPct.Text = "50%"
VolPct.TextColor3 = Config.Colors.ToscaGreen
VolPct.Font = Enum.Font.GothamBold
VolPct.TextSize = 14
VolPct.TextXAlignment = Enum.TextXAlignment.Right

local VolBg = Instance.new("TextButton", PnlVol)
VolBg.Size = UDim2.new(1, -30, 0, 8)
VolBg.Position = UDim2.new(0, 15, 0, 45)
VolBg.BackgroundColor3 = Config.Colors.Black
VolBg.Text = ""
Instance.new("UICorner", VolBg).CornerRadius = UDim.new(1, 0)
local VolFill = Instance.new("Frame", VolBg)
VolFill.Size = UDim2.new(0.5, 0, 1, 0)
VolFill.BackgroundColor3 = Config.Colors.White
Instance.new("UICorner", VolFill).CornerRadius = UDim.new(1, 0)
local VolKnob = Instance.new("Frame", VolFill)
VolKnob.Size = UDim2.new(0, 16, 0, 16)
VolKnob.Position = UDim2.new(1, -8, 0.5, 0)
VolKnob.AnchorPoint = Vector2.new(0.5, 0.5)
VolKnob.BackgroundColor3 = Config.Colors.ToscaGreen
Instance.new("UICorner", VolKnob).CornerRadius = UDim.new(1, 0)

local draggingVol = false
VolBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingVol = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingVol = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingVol and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local pct = math.clamp((input.Position.X - VolBg.AbsolutePosition.X) / VolBg.AbsoluteSize.X, 0, 1)
        VolFill.Size = UDim2.new(pct, 0, 1, 0)
        VolPct.Text = math.floor(pct * 100) .. "%"
        AudioCore.Volume = pct * 2 
        AudioCore2.Volume = pct * 2
    end
end)

-- [Isi Panel Tempo 0.5 - 2.0]
local TmpLayout = Instance.new("UIListLayout", PnlTmp)
TmpLayout.FillDirection = Enum.FillDirection.Horizontal
TmpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TmpLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TmpLayout.Padding = UDim.new(0, 15)

local TmpBtns = {}
for _, spd in ipairs({0.5, 1.0, 1.5, 2.0}) do
    local tb = Instance.new("TextButton", PnlTmp)
    tb.Size = UDim2.new(0, 60, 0, 30)
    tb.BackgroundColor3 = (spd == 1.0) and Config.Colors.IceBlue or Config.Colors.Black
    tb.Text = spd .. "x"
    tb.TextColor3 = (spd == 1.0) and Config.Colors.Black or Config.Colors.White
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 12
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    table.insert(TmpBtns, tb)
    
    tb.MouseButton1Click:Connect(function()
        AudioCore.PlaybackSpeed = spd
        AudioCore2.PlaybackSpeed = spd
        for _, btn in pairs(TmpBtns) do
            btn.BackgroundColor3 = Config.Colors.Black
            btn.TextColor3 = Config.Colors.White
        end
        tb.BackgroundColor3 = Config.Colors.IceBlue
        tb.TextColor3 = Config.Colors.Black
    end)
end

-- [Isi Panel EQ]
local EQGrid = Instance.new("UIListLayout", PnlEQ)
EQGrid.FillDirection = Enum.FillDirection.Horizontal
EQGrid.HorizontalAlignment = Enum.HorizontalAlignment.SpaceEvenly
EQGrid.VerticalAlignment = Enum.VerticalAlignment.Center

local function CreateEQSlider(name, prop)
    local col = Instance.new("Frame", PnlEQ)
    col.Size = UDim2.new(0.3, 0, 1, 0)
    col.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", col)
    lbl.Size = UDim2.new(1, 0, 0, 15)
    lbl.Position = UDim2.new(0, 0, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Config.Colors.White
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    
    local bg = Instance.new("TextButton", col)
    bg.Size = UDim2.new(0.8, 0, 0, 6)
    bg.Position = UDim2.new(0.1, 0, 0, 40)
    bg.BackgroundColor3 = Config.Colors.Black
    bg.Text = ""
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Config.Colors.ToscaGreen
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame", fill)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(1, -6, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = Config.Colors.White
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragEQ = false
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragEQ = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragEQ = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragEQ and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local val = (pct * 20) - 10
            EQ[prop] = val
            EQ2[prop] = val
        end
    end)
end
CreateEQSlider("BASS", "LowGain")
CreateEQSlider("MID", "MidGain")
CreateEQSlider("TREBLE", "HighGain")

-- [Isi Panel FX (Crossfade)]
local FXLbl = Instance.new("TextLabel", PnlFX)
FXLbl.Size = UDim2.new(0, 150, 0, 20)
FXLbl.Position = UDim2.new(0, 20, 0.5, -10)
FXLbl.BackgroundTransparency = 1
FXLbl.Text = "Smooth Crossfade"
FXLbl.TextColor3 = Config.Colors.IceBlue
FXLbl.Font = Enum.Font.GothamBold
FXLbl.TextSize = 13
FXLbl.TextXAlignment = Enum.TextXAlignment.Left

local CFBtn = Instance.new("TextButton", PnlFX)
CFBtn.Size = UDim2.new(0, 60, 0, 26)
CFBtn.Position = UDim2.new(1, -80, 0.5, -13)
CFBtn.BackgroundColor3 = Config.Colors.Black
CFBtn.Text = "OFF"
CFBtn.TextColor3 = Config.Colors.White
CFBtn.Font = Enum.Font.GothamBold
CFBtn.TextSize = 12
Instance.new("UICorner", CFBtn).CornerRadius = UDim.new(0, 6)

CFBtn.MouseButton1Click:Connect(function()
    App.CrossfadeEnabled = not App.CrossfadeEnabled
    if App.CrossfadeEnabled then
        TweenService:Create(CFBtn, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.ToscaGreen, TextColor3 = Config.Colors.Black}):Play()
        CFBtn.Text = "ON"
    else
        TweenService:Create(CFBtn, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.Black, TextColor3 = Config.Colors.White}):Play()
        CFBtn.Text = "OFF"
    end
end)

-- ================= SUB PART: SYSTEM LOGIC & CONNECTIONS =================
function App.PlayTrack(index)
    if #App.MusicQueue == 0 then return end
    if index < 1 then index = #App.MusicQueue end
    if index > #App.MusicQueue then index = 1 end
    
    App.CurrentTrackIndex = index
    local track = App.MusicQueue[index]
    
    SongTitle.Text = track.Title
    SongArtist.Text = track.Artist
    
    if App.CrossfadeEnabled and AudioCore.IsPlaying then
        AudioCore2.SoundId = "rbxassetid://" .. track.ID
        AudioCore2:Play()
        local currentVol = VolFill.Size.X.Scale * 2
        
        TweenService:Create(AudioCore, TweenInfo.new(App.CrossfadeTime), {Volume = 0}):Play()
        TweenService:Create(AudioCore2, TweenInfo.new(App.CrossfadeTime), {Volume = currentVol}):Play()
        
        task.delay(App.CrossfadeTime, function()
            AudioCore:Stop()
            local temp = AudioCore
            AudioCore = AudioCore2
            AudioCore2 = temp
            
            local tempEQ = EQ
            EQ = EQ2
            EQ2 = tempEQ
        end)
    else
        AudioCore:Stop()
        AudioCore.SoundId = "rbxassetid://" .. track.ID
        AudioCore:Play()
    end
    
    App.IsPlaying = true
    BtnPlay.Text = "⏸"
    TweenService:Create(BtnPlay, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.ToscaGreen}):Play()
end

BtnPlay.MouseButton1Click:Connect(function()
    if #App.MusicQueue == 0 then return App.Notify("Empty Queue", "Tambahkan lagu dari Playlist atau Folder!", 3) end
    if App.IsPlaying then
        AudioCore:Pause()
        App.IsPlaying = false
        BtnPlay.Text = "▶"
        TweenService:Create(BtnPlay, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.White}):Play()
    else
        if AudioCore.SoundId == "" then App.PlayTrack(App.CurrentTrackIndex == 0 and 1 or App.CurrentTrackIndex) else AudioCore:Resume() end
        App.IsPlaying = true
        BtnPlay.Text = "⏸"
        TweenService:Create(BtnPlay, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.ToscaGreen}):Play()
    end
end)

BtnNext.MouseButton1Click:Connect(function()
    if App.IsShuffle then App.PlayTrack(math.random(1, #App.MusicQueue)) else App.PlayTrack(App.CurrentTrackIndex + 1) end
end)

BtnPrev.MouseButton1Click:Connect(function() App.PlayTrack(App.CurrentTrackIndex - 1) end)

BtnShuffle.MouseButton1Click:Connect(function()
    App.IsShuffle = not App.IsShuffle
    BtnShuffle.TextColor3 = App.IsShuffle and Config.Colors.ToscaGreen or Config.Colors.White
end)

BtnRepeat.MouseButton1Click:Connect(function()
    App.IsRepeat = not App.IsRepeat
    BtnRepeat.TextColor3 = App.IsRepeat and Config.Colors.ToscaGreen or Config.Colors.White
end)

AudioCore.Ended:Connect(function()
    if App.IsRepeat then App.PlayTrack(App.CurrentTrackIndex) else BtnNext.MouseButton1Click:Fire() end
end)
AudioCore2.Ended:Connect(function()
    if App.IsRepeat then App.PlayTrack(App.CurrentTrackIndex) else BtnNext.MouseButton1Click:Fire() end
end)

local function formatTime(s)
    local min = math.floor(s / 60)
    local sec = math.floor(s % 60)
    return string.format("%d:%02d", min, sec)
end

RunService.RenderStepped:Connect(function()
    if App.IsPlaying and AudioCore.TimeLength > 0 then
        AlbumCD.Rotation = (AlbumCD.Rotation + 0.8) % 360
        BassGradient.Rotation = (BassGradient.Rotation + 2) % 360
        
        local loud = (AudioCore.PlaybackLoudness / 1000)
        local pulse = 1 + math.clamp(loud * 0.15, 0, 0.2)
        BassRing.Size = BassRing.Size:Lerp(UDim2.new(pulse, 10, pulse, 10), 0.2)
        
        local current = AudioCore.TimePosition
        local total = AudioCore.TimeLength
        if not isDraggingProg then
            ProgressFill.Size = UDim2.new(current / total, 0, 1, 0)
            TimeCurrent.Text = formatTime(current)
        end
        TimeTotal.Text = formatTime(total)
    else
        BassRing.Size = BassRing.Size:Lerp(UDim2.new(1, 10, 1, 10), 0.1)
    end
end)