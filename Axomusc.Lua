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
-- BAGIAN 3: KONTEN MENU EKSKLUSIF (TAHAP 2 - FIX TOTAL PREMIUM PLAYLIST)
-- ==============================================================================

local PlaylistPage = Page_Playlist.Page
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

App.SavedSongs = {}
App.Playlists = {
    ["Default"] = {},
    ["Favorites"] = {}
}
App.CurrentPlaylist = "Default"
App.PendingFolderTrack = nil

-- ================= HELPER: PREMIUM EFFECT & ANIMATION =================
local function ApplyPremiumHover(btn, hoverBg, hoverText)
    local originalBg = btn.BackgroundColor3
    local originalText = btn.TextColor3
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverBg,
            TextColor3 = hoverText
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = originalBg,
            TextColor3 = originalText
        }):Play()
    end)
end

-- ================= SUB PART: SEARCH BAR (GLASSMORPHISM) =================
local SearchContainer = Instance.new("Frame", PlaylistPage)
SearchContainer.Size = UDim2.new(1, -20, 0, 42)
SearchContainer.Position = UDim2.new(0, 10, 0, 12)
SearchContainer.BackgroundColor3 = Color3.fromRGB(10, 16, 26)
SearchContainer.BackgroundTransparency = 0.4
Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 8)

local SearchStroke = Instance.new("UIStroke", SearchContainer)
SearchStroke.Color = Config.Colors.ToscaGreen
SearchStroke.Transparency = 0.6
SearchStroke.Thickness = 1

local SearchInput = Instance.new("TextBox", SearchContainer)
SearchInput.Size = UDim2.new(1, -50, 1, 0)
SearchInput.Position = UDim2.new(0, 12, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.PlaceholderText = "Cari ID Audio Musik..."
SearchInput.Text = ""
SearchInput.TextColor3 = Config.Colors.White
SearchInput.PlaceholderColor3 = Color3.fromRGB(100, 115, 130)
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.TextSize = 13
SearchInput.TextXAlignment = Enum.TextXAlignment.Left

local SearchBtn = Instance.new("TextButton", SearchContainer)
SearchBtn.Size = UDim2.new(0, 32, 0, 32)
SearchBtn.Position = UDim2.new(1, -37, 0.5, -16)
SearchBtn.BackgroundColor3 = Color3.fromRGB(16, 24, 38)
SearchBtn.Text = "🔍"
SearchBtn.TextColor3 = Config.Colors.ToscaGreen
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.TextSize = 14
Instance.new("UICorner", SearchBtn).CornerRadius = UDim.new(0, 6)
ApplyPremiumHover(SearchBtn, Config.Colors.ToscaGreen, Config.Colors.Black)

-- ================= SUB PART: PANE HASIL PENCARIAN =================
local ResultContainer = Instance.new("Frame", PlaylistPage)
ResultContainer.Size = UDim2.new(1, -20, 0, 56)
ResultContainer.Position = UDim2.new(0, 10, 0, 62)
ResultContainer.BackgroundColor3 = Color3.fromRGB(12, 20, 32)
ResultContainer.BackgroundTransparency = 0.2
ResultContainer.Visible = false
Instance.new("UICorner", ResultContainer).CornerRadius = UDim.new(0, 8)

local ResStroke = Instance.new("UIStroke", ResultContainer)
ResStroke.Color = Config.Colors.ToscaGreen
ResStroke.Transparency = 0.7

local ResTitle = Instance.new("TextLabel", ResultContainer)
ResTitle.Size = UDim2.new(1, -65, 0, 22)
ResTitle.Position = UDim2.new(0, 14, 0, 7)
ResTitle.BackgroundTransparency = 1
ResTitle.TextColor3 = Config.Colors.White
ResTitle.Font = Enum.Font.GothamBold
ResTitle.TextSize = 13
ResTitle.TextXAlignment = Enum.TextXAlignment.Left
ResTitle.TextTruncate = Enum.TextTruncate.AtEnd

local ResArtist = Instance.new("TextLabel", ResultContainer)
ResArtist.Size = UDim2.new(1, -65, 0, 18)
ResArtist.Position = UDim2.new(0, 14, 0, 27)
ResArtist.BackgroundTransparency = 1
ResArtist.TextColor3 = Color3.fromRGB(150, 165, 180)
ResArtist.Font = Enum.Font.Gotham
ResArtist.TextSize = 11
ResArtist.TextXAlignment = Enum.TextXAlignment.Left

local BtnSaveSearch = Instance.new("TextButton", ResultContainer)
BtnSaveSearch.Size = UDim2.new(0, 32, 0, 32)
BtnSaveSearch.Position = UDim2.new(1, -42, 0.5, -16)
BtnSaveSearch.BackgroundColor3 = Color3.fromRGB(16, 26, 42)
BtnSaveSearch.Text = "💾"
BtnSaveSearch.TextColor3 = Config.Colors.White
BtnSaveSearch.Font = Enum.Font.GothamBold
BtnSaveSearch.TextSize = 14
Instance.new("UICorner", BtnSaveSearch).CornerRadius = UDim.new(0, 6)
ApplyPremiumHover(BtnSaveSearch, Config.Colors.ToscaGreen, Config.Colors.Black)

-- ================= SUB PART: CONTEXT MENU MODAL (3-DOTS) =================
local ContextOverlay = Instance.new("TextButton", PlaylistPage)
ContextOverlay.Size = UDim2.new(1, 0, 1, 0)
ContextOverlay.BackgroundColor3 = Config.Colors.Black
ContextOverlay.BackgroundTransparency = 1
ContextOverlay.Text = ""
ContextOverlay.Visible = false
ContextOverlay.ZIndex = 20

local ContextMenu = Instance.new("Frame", ContextOverlay)
ContextMenu.Size = UDim2.new(0, 180, 0, 160)
ContextMenu.BackgroundColor3 = Color3.fromRGB(10, 16, 26)
ContextMenu.ZIndex = 21
Instance.new("UICorner", ContextMenu).CornerRadius = UDim.new(0, 10)
local MenuStroke = Instance.new("UIStroke", ContextMenu)
MenuStroke.Color = Config.Colors.ToscaGreen
MenuStroke.Transparency = 0.4

local function CreateMenuOption(text, yPos, isDelete)
    local btn = Instance.new("TextButton", ContextMenu)
    btn.Size = UDim2.new(1, -16, 0, 30)
    btn.Position = UDim2.new(0, 8, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(16, 24, 38)
    btn.Text = text
    btn.TextColor3 = isDelete and Color3.fromRGB(240, 80, 80) or Config.Colors.White
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.ZIndex = 22
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    if isDelete then
        ApplyPremiumHover(btn, Color3.fromRGB(200, 50, 50), Config.Colors.White)
    else
        ApplyPremiumHover(btn, Config.Colors.ToscaGreen, Config.Colors.Black)
    end
    return btn
end

local OptPlay = CreateMenuOption("▶  Putar Sekarang", 10)
local OptPlayNext = CreateMenuOption("⏭  Putar Selanjutnya", 45)
local OptFolder = CreateMenuOption("📁  Tambah ke Folder", 80)
local OptDelete = CreateMenuOption("🗑  Hapus Musik", 115, true)

local ActiveTrackData = nil
local ActiveTrackIndex = nil

local function CloseContextMenu()
    TweenService:Create(ContextOverlay, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    local close = TweenService:Create(ContextMenu, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 180, 0, 0)})
    close:Play()
    close.Completed:Connect(function()
        if not ActiveTrackData then ContextOverlay.Visible = false end
    end)
    ActiveTrackData = nil
end

ContextOverlay.MouseButton1Click:Connect(CloseContextMenu)

-- ================= SUB PART: PLAYLIST SELECTOR & CONTAINER =================
local PlaylistSelector = Instance.new("TextButton", PlaylistPage)
PlaylistSelector.Size = UDim2.new(1, -20, 0, 36)
PlaylistSelector.Position = UDim2.new(0, 10, 0, 126)
PlaylistSelector.BackgroundColor3 = Color3.fromRGB(14, 22, 36)
PlaylistSelector.Text = "🎵 Daftar Putar: Default  ▼"
PlaylistSelector.TextColor3 = Config.Colors.White
PlaylistSelector.Font = Enum.Font.GothamBold
PlaylistSelector.TextSize = 12
Instance.new("UICorner", PlaylistSelector).CornerRadius = UDim.new(0, 8)
local SelectStroke = Instance.new("UIStroke", PlaylistSelector)
SelectStroke.Color = Config.Colors.ToscaGreen
SelectStroke.Transparency = 0.6

local MusicScroll = Instance.new("ScrollingFrame", PlaylistPage)
MusicScroll.Size = UDim2.new(1, -20, 1, -180)
MusicScroll.Position = UDim2.new(0, 10, 0, 170)
MusicScroll.BackgroundTransparency = 1
MusicScroll.ScrollBarThickness = 2
MusicScroll.ScrollBarImageColor3 = Config.Colors.ToscaGreen
local ListLayout = Instance.new("UIListLayout", MusicScroll)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 6)

-- ================= SUB PART: CORE LOGIC & REFRESH UI =================
SearchBtn.MouseButton1Click:Connect(function()
    local query = SearchInput.Text
    if query == "" then return App.Notify("Sistem", "Masukkan ID musik terlebih dahulu!", 3) end
    local id = tonumber(query)
    if id then
        SearchBtn.Text = "..."
        local success, info = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset) end)
        SearchBtn.Text = "🔍"
        
        if success and info and info.AssetTypeId == 3 then
            CurrentSearchedTrack = {ID = id, Title = info.Name, Artist = info.Creator.Name or "Axolion Artist"}
            ResTitle.Text = CurrentSearchedTrack.Title
            ResArtist.Text = "Oleh: " .. CurrentSearchedTrack.Artist
            ResultContainer.Visible = true
        else
            App.Notify("Gagal", "ID Musik tidak valid/tidak ditemukan.", 3)
        end
    else
        App.Notify("Info", "Gunakan pencarian berbasis ID Audio.", 3)
    end
end)

BtnSaveSearch.MouseButton1Click:Connect(function()
    if CurrentSearchedTrack then
        table.insert(App.Playlists[App.CurrentPlaylist], CurrentSearchedTrack)
        ResultContainer.Visible = false
        SearchInput.Text = ""
        App.RefreshPlaylistUI()
        App.Notify("Sukses", "Musik disimpan ke playlist " .. App.CurrentPlaylist, 2)
    end
end)

function App.RefreshPlaylistUI()
    for _, child in ipairs(MusicScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local tracks = App.Playlists[App.CurrentPlaylist] or {}
    for index, track in ipairs(tracks) do
        local card = Instance.new("Frame", MusicScroll)
        card.Size = UDim2.new(1, 0, 0, 46)
        card.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
        card.BackgroundTransparency = 0.1
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        
        local grad = Instance.new("UIGradient", card)
        grad.Rotation = 45
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 26, 42)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 14, 24))
        })
        
        local accent = Instance.new("Frame", card)
        accent.Size = UDim2.new(0, 3, 1, 0)
        accent.BackgroundColor3 = Config.Colors.ToscaGreen
        accent.BorderSizePixel = 0
        
        local titleLbl = Instance.new("TextLabel", card)
        titleLbl.Size = UDim2.new(1, -55, 0, 20)
        titleLbl.Position = UDim2.new(0, 14, 0, 5)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = track.Title
        titleLbl.TextColor3 = Config.Colors.White
        titleLbl.Font = Enum.Font.GothamSemibold
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        
        local artistLbl = Instance.new("TextLabel", card)
        artistLbl.Size = UDim2.new(1, -55, 0, 16)
        artistLbl.Position = UDim2.new(0, 14, 0, 23)
        artistLbl.BackgroundTransparency = 1
        artistLbl.Text = track.Artist
        artistLbl.TextColor3 = Color3.fromRGB(130, 145, 160)
        artistLbl.Font = Enum.Font.Gotham
        artistLbl.TextSize = 10
        artistLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local dotsBtn = Instance.new("TextButton", card)
        dotsBtn.Size = UDim2.new(0, 28, 0, 28)
        dotsBtn.Position = UDim2.new(1, -34, 0.5, -14)
        dotsBtn.BackgroundTransparency = 1
        dotsBtn.Text = "⋮"
        dotsBtn.TextColor3 = Color3.fromRGB(180, 195, 210)
        dotsBtn.Font = Enum.Font.GothamBold
        dotsBtn.TextSize = 16
        
        dotsBtn.MouseEnter:Connect(function() dotsBtn.TextColor3 = Config.Colors.ToscaGreen end)
        dotsBtn.MouseLeave:Connect(function() dotsBtn.TextColor3 = Color3.fromRGB(180, 195, 210) end)
        
        dotsBtn.MouseButton1Click:Connect(function()
            ActiveTrackData = track
            ActiveTrackIndex = index
            
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local framePos = PlaylistPage.AbsolutePosition
            local posX = math.clamp(mousePos.X - framePos.X - 190, 10, PlaylistPage.AbsoluteSize.X - 190)
            local posY = math.clamp(mousePos.Y - framePos.Y - 30, 10, PlaylistPage.AbsoluteSize.Y - 170)
            
            ContextMenu.Position = UDim2.new(0, posX, 0, posY)
            ContextMenu.Size = UDim2.new(0, 180, 0, 0)
            ContextOverlay.Visible = true
            
            TweenService:Create(ContextOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
            TweenService:Create(ContextMenu, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 180, 0, 155)}):Play()
        end)
    end
    MusicScroll.CanvasSize = UDim2.new(0, 0, 0, #tracks * 52)
end

-- ================= CONTEXT MENU EXECUTION =================
OptPlay.MouseButton1Click:Connect(function()
    if ActiveTrackData then
        App.MusicQueue = {ActiveTrackData}
        if App.UpdateQueueUI then App.UpdateQueueUI() end
        if App.PlayTrack then App.PlayTrack(1) end
        CloseContextMenu()
    end
end)

OptPlayNext.MouseButton1Click:Connect(function()
    if ActiveTrackData then
        table.insert(App.MusicQueue, math.min(2, #App.MusicQueue + 1), ActiveTrackData)
        if App.UpdateQueueUI then App.UpdateQueueUI() end
        App.Notify("Queue", "Musik akan diputar selanjutnya", 2)
        CloseContextMenu()
    end
end)

OptFolder.MouseButton1Click:Connect(function()
    if ActiveTrackData then
        App.PendingFolderTrack = ActiveTrackData
        App.Notify("Folder", "Musik dialihkan! Buka Tab Folder (Tahap 3) untuk menaruh.", 3)
        CloseContextMenu()
    end
end)

OptDelete.MouseButton1Click:Connect(function()
    if ActiveTrackIndex then
        table.remove(App.Playlists[App.CurrentPlaylist], ActiveTrackIndex)
        App.RefreshPlaylistUI()
        App.Notify("Sistem", "Musik berhasil dihapus", 2)
        CloseContextMenu()
    end
end)

PlaylistSelector.MouseButton1Click:Connect(function()
    App.CurrentPlaylist = (App.CurrentPlaylist == "Default") and "Favorites" or "Default"
    PlaylistSelector.Text = "🎵 Daftar Putar: " .. App.CurrentPlaylist .. "  ▼"
    App.RefreshPlaylistUI()
end)

App.RefreshPlaylistUI()