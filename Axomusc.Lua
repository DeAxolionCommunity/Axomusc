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
-- BAGIAN 3: KONTEN MENU EKSKLUSIF (TAHAP 1 - MUSIC PANEL ELEGANT FIX)
-- ==============================================================================

local MusicPage = Page_Music.Page

-- ================= SUB PART: AUDIO ENGINE & SYSTEM STATE =================
App.MusicQueue = {}
App.CurrentTrackIndex = 0
App.IsPlaying = false
App.PlayMode = 1 -- 1: Auto Next, 2: Repeat One, 3: Shuffle

local AudioCore = Instance.new("Sound")
AudioCore.Name = "Axomusc_AudioEngine"
AudioCore.Parent = CoreGui
AudioCore.Volume = 1
AudioCore.Looped = false

-- ================= SUB PART: NOW PLAYING CARD =================
local NowPlayingCard = Instance.new("Frame", MusicPage)
NowPlayingCard.Name = "NowPlaying_Card"
NowPlayingCard.Size = UDim2.new(1, 0, 0, 150)
NowPlayingCard.BackgroundColor3 = Config.Colors.DarkBlue
NowPlayingCard.BackgroundTransparency = 0.1
NowPlayingCard.BorderSizePixel = 0
NowPlayingCard.ZIndex = 2
Instance.new("UICorner", NowPlayingCard).CornerRadius = UDim.new(0, 15)
local CardStroke = Instance.new("UIStroke", NowPlayingCard)
CardStroke.Color = Config.Colors.ToscaGreen
CardStroke.Transparency = 0.6
CardStroke.Thickness = 1.5

-- Tombol Garis 3 (Daftar Putar) di dalam Container Now Playing
local BtnQueue = Instance.new("TextButton", NowPlayingCard)
BtnQueue.Size = UDim2.new(0, 35, 0, 35)
BtnQueue.Position = UDim2.new(1, -45, 0, 15)
BtnQueue.BackgroundColor3 = Config.Colors.Black
BtnQueue.BackgroundTransparency = 0.3
BtnQueue.Text = "≡"
BtnQueue.TextColor3 = Config.Colors.White
BtnQueue.Font = Enum.Font.GothamBold
BtnQueue.TextSize = 20
BtnQueue.ZIndex = 4
Instance.new("UICorner", BtnQueue).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", BtnQueue).Color = Config.Colors.ToscaGreen

-- Album Art / CD
local AlbumBg = Instance.new("Frame", NowPlayingCard)
AlbumBg.Size = UDim2.new(0, 110, 0, 110)
AlbumBg.Position = UDim2.new(0, 20, 0.5, 0)
AlbumBg.AnchorPoint = Vector2.new(0, 0.5)
AlbumBg.BackgroundColor3 = Config.Colors.Black
AlbumBg.ZIndex = 3
Instance.new("UICorner", AlbumBg).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", AlbumBg).Color = Config.Colors.White

local AlbumCD = Instance.new("ImageLabel", AlbumBg)
AlbumCD.Size = UDim2.new(1, -4, 1, -4)
AlbumCD.Position = UDim2.new(0.5, 0, 0.5, 0)
AlbumCD.AnchorPoint = Vector2.new(0.5, 0.5)
AlbumCD.BackgroundTransparency = 1
AlbumCD.Image = "rbxassetid://84404991858137"
AlbumCD.ZIndex = 3
Instance.new("UICorner", AlbumCD).CornerRadius = UDim.new(1, 0)

local CD_Hole = Instance.new("Frame", AlbumCD)
CD_Hole.Size = UDim2.new(0, 22, 0, 22)
CD_Hole.Position = UDim2.new(0.5, 0, 0.5, 0)
CD_Hole.AnchorPoint = Vector2.new(0.5, 0.5)
CD_Hole.BackgroundColor3 = Config.Colors.DarkBlue
CD_Hole.ZIndex = 4
Instance.new("UICorner", CD_Hole).CornerRadius = UDim.new(1, 0)

-- Bass RGB Visualizer Ring
local BassRing = Instance.new("Frame", AlbumBg)
BassRing.Size = UDim2.new(1, 14, 1, 14)
BassRing.Position = UDim2.new(0.5, 0, 0.5, 0)
BassRing.AnchorPoint = Vector2.new(0.5, 0.5)
BassRing.BackgroundTransparency = 1
BassRing.ZIndex = 2
Instance.new("UICorner", BassRing).CornerRadius = UDim.new(1, 0)
local BassStroke = Instance.new("UIStroke", BassRing)
BassStroke.Thickness = 3
local BassGradient = Instance.new("UIGradient", BassStroke)
BassGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Config.Colors.ToscaGreen),
    ColorSequenceKeypoint.new(0.5, Config.Colors.Black),
    ColorSequenceKeypoint.new(1, Config.Colors.White)
}

-- Text Info
local SongTitle = Instance.new("TextLabel", NowPlayingCard)
SongTitle.Size = UDim2.new(1, -210, 0, 30) -- Disesuaikan agar tidak nabrak tombol garis 3
SongTitle.Position = UDim2.new(0, 150, 0, 25)
SongTitle.BackgroundTransparency = 1
SongTitle.Text = "No Track Selected"
SongTitle.TextColor3 = Config.Colors.White
SongTitle.Font = Enum.Font.GothamBold
SongTitle.TextSize = 20
SongTitle.TextXAlignment = Enum.TextXAlignment.Left
SongTitle.TextTruncate = Enum.TextTruncate.AtEnd
SongTitle.ZIndex = 3

local SongArtist = Instance.new("TextLabel", NowPlayingCard)
SongArtist.Size = UDim2.new(1, -210, 0, 20)
SongArtist.Position = UDim2.new(0, 150, 0, 55)
SongArtist.BackgroundTransparency = 1
SongArtist.Text = "Axolion Community"
SongArtist.TextColor3 = Config.Colors.ToscaGreen
SongArtist.Font = Enum.Font.GothamSemibold
SongArtist.TextSize = 12
SongArtist.TextXAlignment = Enum.TextXAlignment.Left
SongArtist.ZIndex = 3

-- Progress Slider Premium
local ProgressContainer = Instance.new("Frame", NowPlayingCard)
ProgressContainer.Size = UDim2.new(1, -165, 0, 25)
ProgressContainer.Position = UDim2.new(0, 150, 0, 100)
ProgressContainer.BackgroundTransparency = 1
ProgressContainer.ZIndex = 3

local ProgressBg = Instance.new("TextButton", ProgressContainer)
ProgressBg.Size = UDim2.new(1, 0, 0, 4)
ProgressBg.Position = UDim2.new(0, 0, 0.5, 0)
ProgressBg.AnchorPoint = Vector2.new(0, 0.5)
ProgressBg.BackgroundColor3 = Config.Colors.Black
ProgressBg.Text = ""
ProgressBg.AutoButtonColor = false
ProgressBg.ZIndex = 3
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

local ProgressFill = Instance.new("Frame", ProgressBg)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Config.Colors.ToscaGreen
ProgressFill.ZIndex = 3
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

local ProgressKnob = Instance.new("Frame", ProgressFill)
ProgressKnob.Size = UDim2.new(0, 12, 0, 12)
ProgressKnob.Position = UDim2.new(1, -6, 0.5, 0)
ProgressKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ProgressKnob.BackgroundColor3 = Config.Colors.White
ProgressKnob.ZIndex = 4
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
TimeCurrent.ZIndex = 3

local TimeTotal = Instance.new("TextLabel", ProgressContainer)
TimeTotal.Size = UDim2.new(0, 50, 0, 15)
TimeTotal.Position = UDim2.new(1, -50, 1, 2)
TimeTotal.BackgroundTransparency = 1
TimeTotal.Text = "0:00"
TimeTotal.TextColor3 = Config.Colors.White
TimeTotal.Font = Enum.Font.Gotham
TimeTotal.TextSize = 11
TimeTotal.TextXAlignment = Enum.TextXAlignment.Right
TimeTotal.ZIndex = 3

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

-- ================= SUB PART: MAIN CONTROL PANEL (LEBIH BESAR) =================
local ControlPanel = Instance.new("Frame", MusicPage)
ControlPanel.Size = UDim2.new(1, 0, 0, 85) -- Jauh lebih tinggi
ControlPanel.Position = UDim2.new(0, 0, 0, 165)
ControlPanel.BackgroundColor3 = Config.Colors.Black
ControlPanel.BackgroundTransparency = 0.4
ControlPanel.ClipsDescendants = true -- Penting agar isi menghilang saat size Y=0
ControlPanel.ZIndex = 2
Instance.new("UICorner", ControlPanel).CornerRadius = UDim.new(0, 12)
local ControlStroke = Instance.new("UIStroke", ControlPanel)
ControlStroke.Color = Config.Colors.ToscaGreen
ControlStroke.Transparency = 0.7

local CtrlLayout = Instance.new("UIListLayout", ControlPanel)
CtrlLayout.FillDirection = Enum.FillDirection.Horizontal
CtrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 
CtrlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CtrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
CtrlLayout.Padding = UDim.new(0, 18) -- Jarak antar tombol diperlebar

local function CreateCtrlBtn(name, text, size, txtSize, order, isMain)
    local btn = Instance.new("TextButton", ControlPanel)
    btn.Name = name
    btn.Size = UDim2.new(0, size, 0, size)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = isMain and Config.Colors.ToscaGreen or Config.Colors.DarkBlue
    btn.BackgroundTransparency = isMain and 0 or 0.2
    btn.Text = text
    btn.TextColor3 = isMain and Config.Colors.Black or Config.Colors.White
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = txtSize
    btn.AutoButtonColor = false
    btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    if not isMain then
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = Config.Colors.White
        stroke.Transparency = 0.6
        stroke.Thickness = 1.5
    end
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, size+5, 0, size+5)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(0, size, 0, size)}):Play() end)
    return btn
end

-- Urutan dan Ukuran Diperbesar sesuai prompt
local BtnTempo    = CreateCtrlBtn("BtnTempo", "⏱", 45, 18, 1, false)
local BtnPrev     = CreateCtrlBtn("BtnPrev", "⏮", 50, 22, 2, false)
local BtnPlay     = CreateCtrlBtn("BtnPlay", "▶", 65, 28, 3, true)
local BtnNext     = CreateCtrlBtn("BtnNext", "⏭", 50, 22, 4, false)
local BtnPlayMode = CreateCtrlBtn("BtnPlayMode", "🔁", 45, 18, 5, false)

-- ================= SUB PART: FLOATING TEMPO PANEL =================
local TempoContainer = Instance.new("Frame", MusicPage)
TempoContainer.Size = UDim2.new(0, 200, 0, 45)
TempoContainer.Position = UDim2.new(0.5, -100, 0, 110)
TempoContainer.BackgroundColor3 = Config.Colors.DarkBlue
TempoContainer.BackgroundTransparency = 0.1
TempoContainer.ClipsDescendants = true
TempoContainer.Visible = false
TempoContainer.ZIndex = 10
Instance.new("UICorner", TempoContainer).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", TempoContainer).Color = Config.Colors.ToscaGreen

local TmpLayout = Instance.new("UIListLayout", TempoContainer)
TmpLayout.FillDirection = Enum.FillDirection.Horizontal
TmpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TmpLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TmpLayout.Padding = UDim.new(0, 8)

local TmpBtns = {}
for _, spd in ipairs({0.5, 1.0, 1.5, 2.0}) do
    local tb = Instance.new("TextButton", TempoContainer)
    tb.Size = UDim2.new(0, 40, 0, 30)
    tb.BackgroundColor3 = (spd == 1.0) and Config.Colors.ToscaGreen or Config.Colors.Black
    tb.Text = spd .. "x"
    tb.TextColor3 = (spd == 1.0) and Config.Colors.Black or Config.Colors.White
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 12
    tb.ZIndex = 11
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    table.insert(TmpBtns, tb)
    
    tb.MouseButton1Click:Connect(function()
        AudioCore.PlaybackSpeed = spd
        for _, btn in pairs(TmpBtns) do
            btn.BackgroundColor3 = Config.Colors.Black
            btn.TextColor3 = Config.Colors.White
        end
        tb.BackgroundColor3 = Config.Colors.ToscaGreen
        tb.TextColor3 = Config.Colors.Black
        App.Notify("Tempo Berubah", "Kecepatan diatur ke " .. spd .. "x", 2)
        TweenService:Create(TempoContainer, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 0)}):Play()
        task.delay(0.3, function() TempoContainer.Visible = false end)
    end)
end

BtnTempo.MouseButton1Click:Connect(function()
    if TempoContainer.Visible then
        TweenService:Create(TempoContainer, TweenInfo.new(0.3), {Size = UDim2.new(0, 200, 0, 0)}):Play()
        task.delay(0.3, function() TempoContainer.Visible = false end)
    else
        TempoContainer.Visible = true
        TempoContainer.Size = UDim2.new(0, 200, 0, 0)
        TweenService:Create(TempoContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 45)}):Play()
    end
end)

-- ================= SUB PART: QUEUE PLAYLIST CONTAINER =================
local QueueContainer = Instance.new("Frame", MusicPage)
QueueContainer.Size = UDim2.new(1, 0, 0, 0)
QueueContainer.Position = UDim2.new(0, 0, 0, 165) -- Sama posisinya dengan ControlPanel
QueueContainer.BackgroundColor3 = Config.Colors.DarkBlue
QueueContainer.BackgroundTransparency = 0.2
QueueContainer.ClipsDescendants = true
QueueContainer.ZIndex = 1
Instance.new("UICorner", QueueContainer).CornerRadius = UDim.new(0, 10)
local QStroke = Instance.new("UIStroke", QueueContainer)
QStroke.Color = Config.Colors.ToscaGreen
QStroke.Transparency = 1

local QueueScroll = Instance.new("ScrollingFrame", QueueContainer)
QueueScroll.Size = UDim2.new(1, -10, 1, -10)
QueueScroll.Position = UDim2.new(0, 5, 0, 5)
QueueScroll.BackgroundTransparency = 1
QueueScroll.ScrollBarThickness = 3
QueueScroll.ScrollBarImageColor3 = Config.Colors.ToscaGreen
local QLayout = Instance.new("UIListLayout", QueueScroll)
QLayout.SortOrder = Enum.SortOrder.LayoutOrder
QLayout.Padding = UDim.new(0, 6)

-- LOGIKA TOGGLE MENU DAFTAR PUTAR DAN HILANGKAN PANEL KONTROL
local IsQueueOpen = false
BtnQueue.MouseButton1Click:Connect(function()
    IsQueueOpen = not IsQueueOpen
    if IsQueueOpen then
        BtnQueue.BackgroundColor3 = Config.Colors.ToscaGreen
        BtnQueue.TextColor3 = Config.Colors.Black
        QStroke.Transparency = 0
        -- Sembunyikan Control Panel
        TweenService:Create(ControlPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}):Play()
        ControlStroke.Transparency = 1
        -- Munculkan Daftar Putar mengisi penuh bagian bawah
        TweenService:Create(QueueContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, -170)}):Play()
    else
        BtnQueue.BackgroundColor3 = Config.Colors.Black
        BtnQueue.TextColor3 = Config.Colors.White
        QStroke.Transparency = 1
        -- Sembunyikan Daftar Putar
        TweenService:Create(QueueContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        -- Munculkan kembali Control Panel ke ukuran semula
        TweenService:Create(ControlPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 85), BackgroundTransparency = 0.4}):Play()
        ControlStroke.Transparency = 0.7
    end
end)

-- ================= SUB PART: SYSTEM LOGIC & CONNECTIONS =================
function App.UpdateQueueUI()
    for _, child in ipairs(QueueScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for i, track in ipairs(App.MusicQueue) do
        local qItem = Instance.new("Frame", QueueScroll)
        qItem.Size = UDim2.new(1, -5, 0, 40)
        qItem.BackgroundColor3 = Config.Colors.Black
        qItem.BackgroundTransparency = 0.4
        Instance.new("UICorner", qItem).CornerRadius = UDim.new(0, 8)
        
        local qTitle = Instance.new("TextLabel", qItem)
        qTitle.Size = UDim2.new(1, -50, 1, 0)
        qTitle.Position = UDim2.new(0, 15, 0, 0)
        qTitle.BackgroundTransparency = 1
        qTitle.Text = i .. ". " .. track.Title
        qTitle.TextColor3 = Config.Colors.White
        qTitle.Font = Enum.Font.GothamSemibold
        qTitle.TextSize = 13
        qTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local playBtn = Instance.new("TextButton", qItem)
        playBtn.Size = UDim2.new(0, 26, 0, 26)
        playBtn.Position = UDim2.new(1, -36, 0.5, -13)
        playBtn.BackgroundColor3 = Config.Colors.DarkBlue
        playBtn.Text = "▶"
        playBtn.TextColor3 = Config.Colors.White
        playBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", playBtn).CornerRadius = UDim.new(1, 0)
        
        playBtn.MouseButton1Click:Connect(function() App.PlayTrack(i) end)
    end
    QueueScroll.CanvasSize = UDim2.new(0, 0, 0, #App.MusicQueue * 46)
end

function App.PlayTrack(index)
    if #App.MusicQueue == 0 then return end
    if index < 1 then index = #App.MusicQueue end
    if index > #App.MusicQueue then index = 1 end
    
    App.CurrentTrackIndex = index
    local track = App.MusicQueue[index]
    
    SongTitle.Text = track.Title
    SongArtist.Text = track.Artist
    
    AudioCore:Stop()
    AudioCore.SoundId = "rbxassetid://" .. track.ID
    AudioCore:Play()
    
    App.IsPlaying = true
    BtnPlay.Text = "⏸"
    TweenService:Create(BtnPlay, TweenInfo.new(0.3), {BackgroundColor3 = Config.Colors.ToscaGreen}):Play()
    
    -- Highlight Active Queue
    for i, child in ipairs(QueueScroll:GetChildren()) do
        if child:IsA("Frame") then
            if i == index + 1 then
                child.BackgroundColor3 = Config.Colors.DarkBlue
                child:FindFirstChildOfClass("TextLabel").TextColor3 = Config.Colors.ToscaGreen
                Instance.new("UIStroke", child).Color = Config.Colors.ToscaGreen
            else
                child.BackgroundColor3 = Config.Colors.Black
                child:FindFirstChildOfClass("TextLabel").TextColor3 = Config.Colors.White
                local s = child:FindFirstChildOfClass("UIStroke")
                if s then s:Destroy() end
            end
        end
    end
    App.Notify("Now Playing", track.Title, 3)
end

BtnPlay.MouseButton1Click:Connect(function()
    if #App.MusicQueue == 0 then return App.Notify("Daftar Kosong", "Tambahkan lagu ke playlist!", 3) end
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
    if App.PlayMode == 3 then App.PlayTrack(math.random(1, #App.MusicQueue)) else App.PlayTrack(App.CurrentTrackIndex + 1) end
end)

BtnPrev.MouseButton1Click:Connect(function() App.PlayTrack(App.CurrentTrackIndex - 1) end)

-- LOGIKA MODE PUTAR BERGANTI
BtnPlayMode.MouseButton1Click:Connect(function()
    App.PlayMode = App.PlayMode + 1
    if App.PlayMode > 3 then App.PlayMode = 1 end
    
    if App.PlayMode == 1 then
        BtnPlayMode.Text = "🔁" -- Auto Next (Putar Otomatis Biasa)
        BtnPlayMode.TextColor3 = Config.Colors.White
        App.Notify("Mode Putar", "Putar Otomatis", 2)
    elseif App.PlayMode == 2 then
        BtnPlayMode.Text = "🔂" -- Repeat One (Ulangi Sekali)
        BtnPlayMode.TextColor3 = Config.Colors.ToscaGreen
        App.Notify("Mode Putar", "Ulangi Lagu Ini", 2)
    elseif App.PlayMode == 3 then
        BtnPlayMode.Text = "🔀" -- Shuffle (Putar Acak)
        BtnPlayMode.TextColor3 = Config.Colors.ToscaGreen
        App.Notify("Mode Putar", "Putar Acak", 2)
    end
end)

AudioCore.Ended:Connect(function()
    if App.PlayMode == 2 then 
        App.PlayTrack(App.CurrentTrackIndex) 
    elseif App.PlayMode == 3 then
        App.PlayTrack(math.random(1, #App.MusicQueue))
    else 
        BtnNext.MouseButton1Click:Fire() 
    end
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
        local pulse = 1 + math.clamp(loud * 0.15, 0, 0.15)
        BassRing.Size = BassRing.Size:Lerp(UDim2.new(pulse, 14, pulse, 14), 0.2)
        
        local current = AudioCore.TimePosition
        local total = AudioCore.TimeLength
        if not isDraggingProg then
            ProgressFill.Size = UDim2.new(current / total, 0, 1, 0)
            TimeCurrent.Text = formatTime(current)
        end
        TimeTotal.Text = formatTime(total)
    else
        BassRing.Size = BassRing.Size:Lerp(UDim2.new(1, 14, 1, 14), 0.1)
    end
end)

-- ==============================================================================
-- BAGIAN 3: KONTEN MENU EKSKLUSIF (TAHAP 2 - PLAYLIST & QUEUE MANAGEMENT)
-- ==============================================================================

local PlaylistPage = Page_Playlist.Page -- Asumsi frame halaman Playlist sudah dideklarasikan di awal
local MarketplaceService = game:GetService("MarketplaceService")

App.SavedSongs = {} -- Tempat menyimpan lagu permanen
App.Playlists = {
    ["Default"] = {},
    ["Favorites"] = {}
}
App.CurrentPlaylist = "Default"

-- ================= SUB PART: SEARCH BAR =================
local SearchContainer = Instance.new("Frame", PlaylistPage)
SearchContainer.Size = UDim2.new(1, -20, 0, 45)
SearchContainer.Position = UDim2.new(0, 10, 0, 10)
SearchContainer.BackgroundColor3 = Config.Colors.DarkBlue
SearchContainer.BackgroundTransparency = 0.2
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", SearchContainer).Color = Config.Colors.ToscaGreen

local SearchInput = Instance.new("TextBox", SearchContainer)
SearchInput.Size = UDim2.new(1, -55, 1, 0)
SearchInput.Position = UDim2.new(0, 10, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.PlaceholderText = "Masukkan ID Audio / Nama Lagu..."
SearchInput.Text = ""
SearchInput.TextColor3 = Config.Colors.White
SearchInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchInput.Font = Enum.Font.Gotham
SearchInput.TextSize = 14
SearchInput.TextXAlignment = Enum.TextXAlignment.Left

local SearchBtn = Instance.new("TextButton", SearchContainer)
SearchBtn.Size = UDim2.new(0, 35, 0, 35)
SearchBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
SearchBtn.BackgroundColor3 = Config.Colors.ToscaGreen
SearchBtn.Text = "🔍"
SearchBtn.TextColor3 = Config.Colors.Black
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 18
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 8)

-- ================= SUB PART: SEARCH RESULT CONTAINER =================
local ResultContainer = Instance.new("Frame", PlaylistPage)
ResultContainer.Size = UDim2.new(1, -20, 0, 60)
ResultContainer.Position = UDim2.new(0, 10, 0, 65)
ResultContainer.BackgroundColor3 = Config.Colors.Black
ResultContainer.BackgroundTransparency = 0.5
ResultContainer.Visible = false
Instance.new("UICorner", ResultContainer).CornerRadius = UDim.new(0, 8)

local ResTitle = Instance.new("TextLabel", ResultContainer)
ResTitle.Size = UDim2.new(1, -120, 0, 25)
ResTitle.Position = UDim2.new(0, 10, 0, 5)
ResTitle.BackgroundTransparency = 1
ResTitle.Text = "Title"
ResTitle.TextColor3 = Config.Colors.White
ResTitle.Font = Enum.Font.GothamBold
ResTitle.TextSize = 14
ResTitle.TextXAlignment = Enum.TextXAlignment.Left
ResTitle.TextTruncate = Enum.TextTruncate.AtEnd

local ResArtist = Instance.new("TextLabel", ResultContainer)
ResArtist.Size = UDim2.new(1, -120, 0, 20)
ResArtist.Position = UDim2.new(0, 10, 0, 30)
ResArtist.BackgroundTransparency = 1
ResArtist.Text = "Artist"
ResArtist.TextColor3 = Config.Colors.ToscaGreen
ResArtist.Font = Enum.Font.Gotham
ResArtist.TextSize = 12
ResArtist.TextXAlignment = Enum.TextXAlignment.Left

local BtnAddQueue = Instance.new("TextButton", ResultContainer)
BtnAddQueue.Size = UDim2.new(0, 30, 0, 30)
BtnAddQueue.Position = UDim2.new(1, -110, 0.5, -15)
BtnAddQueue.BackgroundColor3 = Config.Colors.DarkBlue
BtnAddQueue.Text = "➕"
BtnAddQueue.TextColor3 = Config.Colors.White
Instance.new("UICorner", BtnAddQueue).CornerRadius = UDim.new(0, 6)

local BtnSave = Instance.new("TextButton", ResultContainer)
BtnSave.Size = UDim2.new(0, 30, 0, 30)
BtnSave.Position = UDim2.new(1, -75, 0.5, -15)
BtnSave.BackgroundColor3 = Config.Colors.DarkBlue
BtnSave.Text = "💾"
BtnSave.TextColor3 = Config.Colors.White
Instance.new("UICorner", BtnSave).CornerRadius = UDim.new(0, 6)

local BtnAddFolder = Instance.new("TextButton", ResultContainer)
BtnAddFolder.Size = UDim2.new(0, 30, 0, 30)
BtnAddFolder.Position = UDim2.new(1, -40, 0.5, -15)
BtnAddFolder.BackgroundColor3 = Config.Colors.DarkBlue
BtnAddFolder.Text = "📁"
BtnAddFolder.TextColor3 = Config.Colors.White
Instance.new("UICorner", BtnAddFolder).CornerRadius = UDim.new(0, 6)

-- ================= SUB PART: PLAYLIST SELECTION & QUEUE MANAGEMENT =================
local PlaylistDropdownBtn = Instance.new("TextButton", PlaylistPage)
PlaylistDropdownBtn.Size = UDim2.new(1, -20, 0, 35)
PlaylistDropdownBtn.Position = UDim2.new(0, 10, 0, 135)
PlaylistDropdownBtn.BackgroundColor3 = Config.Colors.DarkBlue
PlaylistDropdownBtn.Text = "📂 Playlist: Default ▼"
PlaylistDropdownBtn.TextColor3 = Config.Colors.White
PlaylistDropdownBtn.Font = Enum.Font.GothamBold
PlaylistDropdownBtn.TextSize = 14
Instance.new("UICorner", PlaylistDropdownBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", PlaylistDropdownBtn).Color = Config.Colors.ToscaGreen

local SavedScroll = Instance.new("ScrollingFrame", PlaylistPage)
SavedScroll.Size = UDim2.new(1, -20, 1, -185)
SavedScroll.Position = UDim2.new(0, 10, 0, 175)
SavedScroll.BackgroundTransparency = 1
SavedScroll.ScrollBarThickness = 4
SavedScroll.ScrollBarImageColor3 = Config.Colors.ToscaGreen
local SavedLayout = Instance.new("UIListLayout", SavedScroll)
SavedLayout.SortOrder = Enum.SortOrder.LayoutOrder
SavedLayout.Padding = UDim.new(0, 8)

-- ================= SUB PART: LOGIC & CONNECTIONS =================
local CurrentSearchedTrack = nil

SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchInput.Text
    if query == "" then return App.Notify("Error", "Masukkan ID Lagu!", 3) end
    
    local id = tonumber(query)
    if id then
        SearchBtn.Text = "..."
        local success, info = pcall(function()
            return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset)
        end)
        SearchBtn.Text = "🔍"
        
        if success and info and info.AssetTypeId == 3 then
            CurrentSearchedTrack = {
                ID = id,
                Title = info.Name,
                Artist = info.Creator.Name or "Unknown"
            }
            ResTitle.Text = CurrentSearchedTrack.Title
            ResArtist.Text = CurrentSearchedTrack.Artist
            ResultContainer.Visible = true
            App.Notify("Ditemukan", "Lagu berhasil ditemukan!", 2)
        else
            App.Notify("Gagal", "ID Audio tidak valid/tidak ditemukan", 3)
        end
    else
        App.Notify("Pencarian Nama", "Fitur cari nama membutuhkan API eksternal. Gunakan ID Audio.", 3)
    end
end)

BtnAddQueue.MouseButton1Click:Connect(function()
    if CurrentSearchedTrack then
        table.insert(App.MusicQueue, CurrentSearchedTrack)
        App.UpdateQueueUI() -- Connect ke Tahap 1
        App.Notify("Queue", CurrentSearchedTrack.Title .. " ditambahkan ke antrean!", 2)
    end
end)

BtnSave.MouseButton1Click:Connect(function()
    if CurrentSearchedTrack then
        table.insert(App.Playlists[App.CurrentPlaylist], CurrentSearchedTrack)
        App.RefreshPlaylistUI()
        App.Notify("Tersimpan", CurrentSearchedTrack.Title .. " disimpan permanen di " .. App.CurrentPlaylist, 2)
    end
end)

BtnAddFolder.MouseButton1Click:Connect(function()
    if CurrentSearchedTrack then
        App.PendingFolderTrack = CurrentSearchedTrack
        App.Notify("Folder", "Buka menu Folder (Tahap 3) untuk menyimpan!", 3)
    end
end)

function App.RefreshPlaylistUI()
    for _, child in ipairs(SavedScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local currentList = App.Playlists[App.CurrentPlaylist] or {}
    for i, track in ipairs(currentList) do
        local item = Instance.new("Frame", SavedScroll)
        item.Size = UDim2.new(1, -10, 0, 45)
        item.BackgroundColor3 = Config.Colors.Black
        item.BackgroundTransparency = 0.3
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
        
        local lblTitle = Instance.new("TextLabel", item)
        lblTitle.Size = UDim2.new(1, -100, 0, 20)
        lblTitle.Position = UDim2.new(0, 10, 0, 5)
        lblTitle.BackgroundTransparency = 1
        lblTitle.Text = track.Title
        lblTitle.TextColor3 = Config.Colors.White
        lblTitle.Font = Enum.Font.GothamSemibold
        lblTitle.TextSize = 13
        lblTitle.TextXAlignment = Enum.TextXAlignment.Left
        lblTitle.TextTruncate = Enum.TextTruncate.AtEnd
        
        local lblArtist = Instance.new("TextLabel", item)
        lblArtist.Size = UDim2.new(1, -100, 0, 15)
        lblArtist.Position = UDim2.new(0, 10, 0, 25)
        lblArtist.BackgroundTransparency = 1
        lblArtist.Text = track.Artist
        lblArtist.TextColor3 = Config.Colors.ToscaGreen
        lblArtist.Font = Enum.Font.Gotham
        lblArtist.TextSize = 11
        lblArtist.TextXAlignment = Enum.TextXAlignment.Left
        
        local btnPlayNow = Instance.new("TextButton", item)
        btnPlayNow.Size = UDim2.new(0, 30, 0, 30)
        btnPlayNow.Position = UDim2.new(1, -80, 0.5, -15)
        btnPlayNow.BackgroundColor3 = Config.Colors.ToscaGreen
        btnPlayNow.Text = "▶"
        btnPlayNow.TextColor3 = Config.Colors.Black
        Instance.new("UICorner", btnPlayNow).CornerRadius = UDim.new(0, 6)
        
        local btnQueueIt = Instance.new("TextButton", item)
        btnQueueIt.Size = UDim2.new(0, 30, 0, 30)
        btnQueueIt.Position = UDim2.new(1, -40, 0.5, -15)
        btnQueueIt.BackgroundColor3 = Config.Colors.DarkBlue
        btnQueueIt.Text = "➕"
        btnQueueIt.TextColor3 = Config.Colors.White
        Instance.new("UICorner", btnQueueIt).CornerRadius = UDim.new(0, 6)
        
        btnPlayNow.MouseButton1Click:Connect(function()
            App.MusicQueue = {track}
            App.UpdateQueueUI()
            App.PlayTrack(1)
        end)
        
        btnQueueIt.MouseButton1Click:Connect(function()
            table.insert(App.MusicQueue, track)
            App.UpdateQueueUI()
            App.Notify("Queue", "Ditambahkan ke antrean", 2)
        end)
    end
    SavedScroll.CanvasSize = UDim2.new(0, 0, 0, #currentList * 55)
end

local dropdownOpen = false
PlaylistDropdownBtn.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        App.CurrentPlaylist = App.CurrentPlaylist == "Default" and "Favorites" or "Default"
        PlaylistDropdownBtn.Text = "📂 Playlist: " .. App.CurrentPlaylist .. " ▼"
        App.RefreshPlaylistUI()
    end
end)

App.RefreshPlaylistUI()
