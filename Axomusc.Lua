-- ==============================================================================
-- BAGIAN 1: SERVICE IN-GAME, KEY2API, DAN UI LAYOUT DASAR (PREMIUM CORE + FIX AUTOSCALE + CENTERED TITLE)
-- ==============================================================================

local success_config, error_config = pcall(function()
    _G.Axomusc_Config = {
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
end)

if not success_config then warn("[Axomusc] Gagal memuat Config: " .. tostring(error_config)) end

local CoreGui, TweenService, RunService, Players, MarketplaceService, SoundService, HttpService, UserInputService

local success_services, error_services = pcall(function()
    _G.GetService = function(serviceName) return game:GetService(serviceName) end
    
    CoreGui = _G.GetService("CoreGui")
    TweenService = _G.GetService("TweenService")
    RunService = _G.GetService("RunService")
    Players = _G.GetService("Players")
    MarketplaceService = _G.GetService("MarketplaceService")
    SoundService = _G.GetService("SoundService")
    HttpService = _G.GetService("HttpService")
    UserInputService = _G.GetService("UserInputService")
end)

if not success_services then warn("[Axomusc] Gagal memuat Service: " .. tostring(error_services)) end

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= SUB PART: KEY2API & GUI PROTECTION =================
local AxomuscUI = nil
local success_gui, error_gui = pcall(function()
    AxomuscUI = Instance.new("ScreenGui")
    AxomuscUI.Name = "Axomusc_Premium_UI"
    AxomuscUI.ResetOnSpawn = false
    AxomuscUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AxomuscUI.IgnoreGuiInset = true

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
end)

if not success_gui then warn("[Axomusc] Gagal membuat GUI Base: " .. tostring(error_gui)) end

-- ================= SUB PART: SMART NOTIFY SYSTEM (ELEGANT) =================
_G.Axomusc_Notify = function(Title, Text, Duration)
    pcall(function()
        local notifyDuration = Duration or 3.5
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "SmartNotifyBox"
        NotifFrame.Size = UDim2.new(0, 300, 0, 75)
        NotifFrame.Position = UDim2.new(1, 50, 1, -100)
        NotifFrame.BackgroundColor3 = _G.Axomusc_Config.Colors.DarkBlue
        NotifFrame.BackgroundTransparency = 0.05
        NotifFrame.BorderSizePixel = 0
        NotifFrame.ZIndex = 100
        NotifFrame.Parent = AxomuscUI
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 10)
        NotifCorner.Parent = NotifFrame

        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = _G.Axomusc_Config.Colors.IceBlue
        NotifStroke.Thickness = 1.2
        NotifStroke.Transparency = 0.2
        NotifStroke.Parent = NotifFrame
        
        local NotifShadow = Instance.new("ImageLabel")
        NotifShadow.Name = "Shadow"
        NotifShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        NotifShadow.BackgroundTransparency = 1
        NotifShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
        NotifShadow.Size = UDim2.new(1, 15, 1, 15)
        NotifShadow.Image = "rbxassetid://13169336625"
        NotifShadow.ImageColor3 = _G.Axomusc_Config.Colors.Shadow
        NotifShadow.ImageTransparency = 0.6
        NotifShadow.ZIndex = 99
        NotifShadow.Parent = NotifFrame

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -30, 0, 25)
        TitleLbl.Position = UDim2.new(0, 15, 0, 8)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = Title
        TitleLbl.TextColor3 = _G.Axomusc_Config.Colors.IceBlue
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextSize = 15
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.ZIndex = 101
        TitleLbl.Parent = NotifFrame
        
        local TextLbl = Instance.new("TextLabel")
        TextLbl.Size = UDim2.new(1, -30, 0, 35)
        TextLbl.Position = UDim2.new(0, 15, 0, 32)
        TextLbl.BackgroundTransparency = 1
        TextLbl.Text = Text
        TextLbl.TextColor3 = _G.Axomusc_Config.Colors.White
        TextLbl.Font = Enum.Font.Gotham
        TextLbl.TextSize = 13
        TextLbl.TextTransparency = 0.1
        TextLbl.TextXAlignment = Enum.TextXAlignment.Left
        TextLbl.TextYAlignment = Enum.TextYAlignment.Top
        TextLbl.TextWrapped = true
        TextLbl.ZIndex = 101
        TextLbl.Parent = NotifFrame

        local TweenIn = TweenService:Create(NotifFrame, TweenInfo.new(_G.Axomusc_Config.UI_Settings.TweenTime, _G.Axomusc_Config.UI_Settings.EasingStyle, _G.Axomusc_Config.UI_Settings.EasingDirection), {Position = UDim2.new(1, -320, 1, -100)})
        TweenIn:Play()
        
        task.delay(notifyDuration, function()
            local s, e = pcall(function()
                local TweenOut = TweenService:Create(NotifFrame, TweenInfo.new(_G.Axomusc_Config.UI_Settings.TweenTime, _G.Axomusc_Config.UI_Settings.EasingStyle, _G.Axomusc_Config.UI_Settings.EasingDirection), {Position = UDim2.new(1, 50, 1, -100), BackgroundTransparency = 1})
                TweenService:Create(NotifStroke, TweenInfo.new(_G.Axomusc_Config.UI_Settings.TweenTime), {Transparency = 1}):Play()
                TweenService:Create(TitleLbl, TweenInfo.new(_G.Axomusc_Config.UI_Settings.TweenTime), {TextTransparency = 1}):Play()
                TweenService:Create(TextLbl, TweenInfo.new(_G.Axomusc_Config.UI_Settings.TweenTime), {TextTransparency = 1}):Play()
                TweenService:Create(NotifShadow, TweenInfo.new(_G.Axomusc_Config.UI_Settings.TweenTime), {ImageTransparency = 1}):Play()
                
                TweenOut:Play()
                TweenOut.Completed:Connect(function() NotifFrame:Destroy() end)
            end)
        end)
    end)
end

-- ================= SUB PART: MAIN CANVAS & DYNAMIC AUTO-SCALE =================
local MainFrame = Instance.new("Frame")
local success_main, error_main = pcall(function()
    MainFrame.Name = "MainCanvas_Workspace"
    MainFrame.Size = UDim2.new(0, 680, 0, 460)
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -230)
    MainFrame.BackgroundColor3 = _G.Axomusc_Config.Colors.Black
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false 
    MainFrame.Active = true
    MainFrame.Parent = AxomuscUI

    -- 1. TRUE DYNAMIC AUTO-SCALE RESOLUTION FIX
    local UIScale = Instance.new("UIScale")
    UIScale.Parent = MainFrame

    local function UpdateScale()
        local Viewport = Camera.ViewportSize
        local ScaleWidth = Viewport.X / _G.Axomusc_Config.UI_Settings.BaseWidth
        local ScaleHeight = Viewport.Y / _G.Axomusc_Config.UI_Settings.BaseHeight
        
        local ExactScale = math.min(ScaleWidth, ScaleHeight)
        
        UIScale.Scale = math.clamp(ExactScale * 1.5, 0.45, 1.25)
    end
    
    UpdateScale() 
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale) 

    -- Drop Shadow Mewah untuk UI Utama
    local MainShadow = Instance.new("ImageLabel")
    MainShadow.Name = "DropShadow"
    MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainShadow.BackgroundTransparency = 1
    MainShadow.Position = UDim2.new(0.5, 0, 0.5, 10)
    MainShadow.Size = UDim2.new(1, 40, 1, 40)
    MainShadow.Image = "rbxassetid://13169336625"
    MainShadow.ImageColor3 = _G.Axomusc_Config.Colors.Shadow
    MainShadow.ImageTransparency = 0.4
    MainShadow.ZIndex = 0
    MainShadow.Parent = MainFrame

    -- Container agar isi tidak melebihi frame utama
    local ContentClip = Instance.new("Frame")
    ContentClip.Name = "ContentClip"
    ContentClip.Size = UDim2.new(1, 0, 1, 0)
    ContentClip.BackgroundTransparency = 1
    ContentClip.ClipsDescendants = true
    ContentClip.ZIndex = 1
    ContentClip.Parent = MainFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 14)
    UICorner.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 14)
    ContentCorner.Parent = ContentClip

    -- RGB UI Corners (Biru Es dan Putih) Premium Smooth
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2.5
    UIStroke.Color = Color3.new(1, 1, 1)
    UIStroke.Parent = MainFrame
    
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, _G.Axomusc_Config.Colors.IceBlue),
        ColorSequenceKeypoint.new(0.5, _G.Axomusc_Config.Colors.White),
        ColorSequenceKeypoint.new(1, _G.Axomusc_Config.Colors.IceBlue)
    }
    UIGradient.Parent = UIStroke

    RunService.RenderStepped:Connect(function()
        pcall(function() 
            UIGradient.Rotation = (UIGradient.Rotation + 1.2) % 360 
        end)
    end)
    
    _G.MainContentClip = ContentClip
end)

if not success_main then warn("[Axomusc] Error Frame Utama: " .. tostring(error_main)) end

-- ================= SUB PART: DRAGGABLE FEATURE (ULTRA SMOOTH) =================
local success_drag, error_drag = pcall(function()
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(MainFrame, TweenInfo.new(0.15, _G.Axomusc_Config.UI_Settings.EasingStyle, _G.Axomusc_Config.UI_Settings.EasingDirection), {Position = targetPos}):Play()
    end
    
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
        if input == dragInput and dragging then update(input) end
    end)
end)

if not success_drag then warn("[Axomusc] Error Draggable: " .. tostring(error_drag)) end

-- ================= SUB PART: HEADER (LUXURY CENTERED) =================
local Header = Instance.new("Frame")
local success_header, error_header = pcall(function()
    Header.Name = "Header_Section"
    Header.Size = UDim2.new(1, 0, 0, 65) -- Diperbesar sedikit agar text tidak bertumpuk
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = _G.Axomusc_Config.Colors.DarkBlue
    Header.BorderSizePixel = 0
    Header.ZIndex = 2
    Header.Parent = _G.MainContentClip

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 14)
    HeaderCorner.Parent = Header
    
    -- Fix corner bleed at the bottom of header (Membuat bagian bawah rata)
    local HeaderBlocker = Instance.new("Frame")
    HeaderBlocker.Size = UDim2.new(1, 0, 0, 14)
    HeaderBlocker.Position = UDim2.new(0, 0, 1, -14)
    HeaderBlocker.BackgroundColor3 = _G.Axomusc_Config.Colors.DarkBlue
    HeaderBlocker.BorderSizePixel = 0
    HeaderBlocker.ZIndex = 2
    HeaderBlocker.Parent = Header

    -- Judul Utama (Di Tengah)
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Name = "Judul_Utama"
    HeaderTitle.Size = UDim2.new(1, 0, 0, 30)
    HeaderTitle.Position = UDim2.new(0, 0, 0, 8)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "Axomusc"
    HeaderTitle.TextColor3 = _G.Axomusc_Config.Colors.IceBlue -- Warna Ice Blue Mewah
    HeaderTitle.TextSize = 26
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Center
    HeaderTitle.ZIndex = 3
    HeaderTitle.Parent = Header

    -- Sub Judul (Di Bawah Judul)
    local HeaderSub = Instance.new("TextLabel")
    HeaderSub.Name = "Sub_Judul"
    HeaderSub.Size = UDim2.new(1, 0, 0, 15)
    HeaderSub.Position = UDim2.new(0, 0, 0, 38)
    HeaderSub.BackgroundTransparency = 1
    HeaderSub.Text = "By. " .. _G.Axomusc_Config.Brand
    HeaderSub.TextColor3 = _G.Axomusc_Config.Colors.White
    HeaderSub.TextSize = 12
    HeaderSub.Font = Enum.Font.GothamSemibold
    HeaderSub.TextXAlignment = Enum.TextXAlignment.Center
    HeaderSub.TextTransparency = 0.3
    HeaderSub.ZIndex = 3
    HeaderSub.Parent = Header

    -- Tombol Close (Kanan)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close_Button"
    CloseBtn.Size = UDim2.new(0, 50, 0, 50)
    CloseBtn.Position = UDim2.new(1, -50, 0, 7) -- Disesuaikan dengan tinggi header 65
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "-"
    CloseBtn.TextColor3 = _G.Axomusc_Config.Colors.White
    CloseBtn.TextSize = 35
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.ZIndex = 3
    CloseBtn.Parent = Header
    
    -- Hover Animasi Close Button Mewah
    CloseBtn.MouseEnter:Connect(function()
        pcall(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 75, 75)}):Play() end)
    end)
    CloseBtn.MouseLeave:Connect(function()
        pcall(function() TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = _G.Axomusc_Config.Colors.White}):Play() end)
    end)

    CloseBtn.MouseButton1Click:Connect(function() 
        pcall(function() 
            _G.Axomusc_Notify("Axomusc System", "Menutup UI Premium...", 2)
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
            TweenService:Create(UIStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            task.wait(0.45)
            AxomuscUI:Destroy() 
        end)
    end)

    -- Garis Pembatas Premium Glowing (Ice Blue & Putih Gradient)
    local PremiumLine = Instance.new("Frame")
    PremiumLine.Name = "Premium_Separator"
    PremiumLine.Size = UDim2.new(1, 0, 0, 2)
    PremiumLine.Position = UDim2.new(0, 0, 1, -2)
    PremiumLine.BackgroundColor3 = Color3.new(1, 1, 1)
    PremiumLine.BorderSizePixel = 0
    PremiumLine.ZIndex = 4
    PremiumLine.Parent = Header
    
    local LineGradient = Instance.new("UIGradient")
    LineGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, _G.Axomusc_Config.Colors.Black),
        ColorSequenceKeypoint.new(0.5, _G.Axomusc_Config.Colors.IceBlue),
        ColorSequenceKeypoint.new(1, _G.Axomusc_Config.Colors.Black)
    }
    LineGradient.Parent = PremiumLine
end)

if not success_header then warn("[Axomusc] Error Header: " .. tostring(error_header)) end

-- ==============================================================================
-- BAGIAN 2: UI 3 LAYAR PREMIUM (PERBAIKAN LAYAR 1: ICON MENU, LAYAR 2 & 3)
-- ==============================================================================

local success_b2, error_b2 = pcall(function()
    local MainClip = _G.MainContentClip
    local TweenService = _G.GetService("TweenService")
    local Colors = _G.Axomusc_Config.Colors
    local UI_Settings = _G.Axomusc_Config.UI_Settings
    
    -- Konfigurasi Ukuran Layar
    local L1_Width = 60 -- Sedikit dilebarkan agar icon lebih lega
    local L2_Width = 140
    
    -- ================= SUB PART: LAYAR 3 (KONTEN UTAMA / WORKSPACE) =================
    local Layar3_Content = Instance.new("Frame")
    Layar3_Content.Name = "Layar3_Workspace"
    Layar3_Content.Size = UDim2.new(1, -(L1_Width + L2_Width), 1, -65)
    Layar3_Content.Position = UDim2.new(0, L1_Width + L2_Width, 0, 65)
    Layar3_Content.BackgroundColor3 = Colors.Black
    Layar3_Content.BackgroundTransparency = 1
    Layar3_Content.BorderSizePixel = 0
    Layar3_Content.ZIndex = 2
    Layar3_Content.Parent = MainClip
    
    _G.Layar3_Container = Layar3_Content

    local PageFolder = Instance.new("Folder")
    PageFolder.Name = "All_Pages"
    PageFolder.Parent = Layar3_Content

    -- ================= SUB PART: LAYAR 2 (MENU SIDEBAR DINAMIS) =================
    local Layar2_Sidebar = Instance.new("Frame")
    Layar2_Sidebar.Name = "Layar2_SidebarMenu"
    Layar2_Sidebar.Size = UDim2.new(0, L2_Width, 1, -65)
    Layar2_Sidebar.Position = UDim2.new(0, L1_Width, 0, 65)
    Layar2_Sidebar.BackgroundColor3 = Colors.DarkBlue
    Layar2_Sidebar.BackgroundTransparency = 0.4
    Layar2_Sidebar.BorderSizePixel = 0
    Layar2_Sidebar.ClipsDescendants = true
    Layar2_Sidebar.ZIndex = 3
    Layar2_Sidebar.Parent = MainClip

    -- Garis Pembatas RGB (Biru Es dan Hijau Toska)
    local RGB_Separator = Instance.new("Frame")
    RGB_Separator.Name = "RGB_Line"
    RGB_Separator.Size = UDim2.new(0, 2, 1, 0)
    RGB_Separator.Position = UDim2.new(1, -2, 0, 0)
    RGB_Separator.BackgroundColor3 = Color3.new(1, 1, 1)
    RGB_Separator.BorderSizePixel = 0
    RGB_Separator.ZIndex = 4
    RGB_Separator.Parent = Layar2_Sidebar

    local SeparatorGradient = Instance.new("UIGradient")
    SeparatorGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.ToscaGreen),
        ColorSequenceKeypoint.new(0.5, Colors.IceBlue),
        ColorSequenceKeypoint.new(1, Colors.ToscaGreen)
    }
    SeparatorGradient.Rotation = 90
    SeparatorGradient.Parent = RGB_Separator

    _G.GetService("RunService").RenderStepped:Connect(function()
        pcall(function() SeparatorGradient.Rotation = (SeparatorGradient.Rotation + 1) % 360 end)
    end)

    local MenuScroll = Instance.new("ScrollingFrame")
    MenuScroll.Name = "Menu_ScrollList"
    MenuScroll.Size = UDim2.new(1, -2, 1, -10)
    MenuScroll.Position = UDim2.new(0, 0, 0, 5)
    MenuScroll.BackgroundTransparency = 1
    MenuScroll.BorderSizePixel = 0
    MenuScroll.ScrollBarThickness = 0
    MenuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    MenuScroll.ZIndex = 4
    MenuScroll.Parent = Layar2_Sidebar

    local MenuListLayout = Instance.new("UIListLayout")
    MenuListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    MenuListLayout.Padding = UDim.new(0, 8)
    MenuListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    MenuListLayout.Parent = MenuScroll
    
    local MenuPadding = Instance.new("UIPadding")
    MenuPadding.PaddingTop = UDim.new(0, 10)
    MenuPadding.Parent = MenuScroll

    MenuListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MenuScroll.CanvasSize = UDim2.new(0, 0, 0, MenuListLayout.AbsoluteContentSize.Y + 20)
    end)

    -- ================= SUB PART: TAB SYSTEM LOGIC =================
    _G.Axomusc_MenuBtns = {}
    _G.CurrentPage = nil

    local function HideAllPages()
        for _, btnData in pairs(_G.Axomusc_MenuBtns) do
            TweenService:Create(btnData.Btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(btnData.Text, TweenInfo.new(0.3), {TextColor3 = Colors.White, TextTransparency = 0.4}):Play()
            TweenService:Create(btnData.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            if btnData.Page.Visible then
                btnData.Page.Visible = false
                btnData.Page.Position = UDim2.new(0, 30, 0, 0)
            end
        end
    end

    _G.CreateMenuButton = function(MenuName, Category)
        local BtnData = {}
        
        local MenuBtn = Instance.new("TextButton")
        MenuBtn.Size = UDim2.new(0.85, 0, 0, 32)
        MenuBtn.BackgroundColor3 = Colors.Black
        MenuBtn.BackgroundTransparency = 1
        MenuBtn.Text = ""
        MenuBtn.AutoButtonColor = false
        MenuBtn.ZIndex = 5
        
        local CatValue = Instance.new("StringValue")
        CatValue.Name = "Category"
        CatValue.Value = Category
        CatValue.Parent = MenuBtn

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = MenuBtn

        local BtnText = Instance.new("TextLabel")
        BtnText.Size = UDim2.new(1, -15, 1, 0)
        BtnText.Position = UDim2.new(0, 15, 0, 0)
        BtnText.BackgroundTransparency = 1
        BtnText.Text = MenuName
        BtnText.TextColor3 = Colors.White
        BtnText.TextTransparency = 0.4
        BtnText.Font = Enum.Font.GothamSemibold
        BtnText.TextSize = 13
        BtnText.TextXAlignment = Enum.TextXAlignment.Left
        BtnText.ZIndex = 6
        BtnText.Parent = MenuBtn

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 0)
        Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.BackgroundColor3 = Colors.ToscaGreen
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 6
        Indicator.Parent = MenuBtn

        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(1, 0)
        IndCorner.Parent = Indicator
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = MenuName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Position = UDim2.new(0, 30, 0, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Colors.IceBlue
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.ZIndex = 2
        Page.Parent = PageFolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 15)
        PagePad.PaddingBottom = UDim.new(0, 15)
        PagePad.PaddingLeft = UDim.new(0, 15)
        PagePad.PaddingRight = UDim.new(0, 15)
        PagePad.Parent = Page

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 30)
        end)

        MenuBtn.MouseButton1Click:Connect(function()
            HideAllPages()
            _G.CurrentPage = MenuName
            
            TweenService:Create(MenuBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()
            TweenService:Create(BtnText, TweenInfo.new(0.3), {TextColor3 = Colors.ToscaGreen, TextTransparency = 0}):Play()
            TweenService:Create(Indicator, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3, 0, 18)}):Play()
            
            Page.Visible = true
            TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        end)
        
        MenuBtn.Parent = MenuScroll

        table.insert(_G.Axomusc_MenuBtns, { Btn = MenuBtn, Text = BtnText, Indicator = Indicator, Page = Page, Category = Category })
        BtnData.Page = Page
        return BtnData
    end

    _G.Page_Music = _G.CreateMenuButton("Music Panel", "Main")
    _G.Page_Playlist = _G.CreateMenuButton("Playlist", "Main")
    _G.Page_Folder = _G.CreateMenuButton("Folder", "Main")
    
    _G.Page_Profile = _G.CreateMenuButton("Profile", "Special")
    _G.Page_About = _G.CreateMenuButton("About", "Special")
    _G.Page_UpInfo = _G.CreateMenuButton("Up Info", "Special")

    local function SwitchMenuCategory(TargetCategory)
        local FirstBtnFound = nil
        for _, btnData in pairs(_G.Axomusc_MenuBtns) do
            if btnData.Category == TargetCategory then
                btnData.Btn.Visible = true
                if not FirstBtnFound then FirstBtnFound = btnData.Btn end
            else
                btnData.Btn.Visible = false
            end
        end
        if FirstBtnFound then
            pcall(function()
                for _, connection in pairs(getconnections(FirstBtnFound.MouseButton1Click)) do
                    connection.Function()
                end
            end)
        end
    end

    -- ================= SUB PART: LAYAR 1 (GUI/ICON DENGAN ANIMASI & POSISI PREMIUM) =================
    local Layar1_Icons = Instance.new("Frame")
    Layar1_Icons.Name = "Layar1_IconBar"
    Layar1_Icons.Size = UDim2.new(0, L1_Width, 1, -65)
    Layar1_Icons.Position = UDim2.new(0, 0, 0, 65)
    Layar1_Icons.BackgroundColor3 = Colors.Black
    Layar1_Icons.BorderSizePixel = 0
    Layar1_Icons.ZIndex = 5
    Layar1_Icons.Parent = MainClip
    
    local L1_Separator = Instance.new("Frame")
    L1_Separator.Size = UDim2.new(0, 1, 1, 0)
    L1_Separator.Position = UDim2.new(1, -1, 0, 0)
    L1_Separator.BackgroundColor3 = Colors.IceBlue
    L1_Separator.BackgroundTransparency = 0.7
    L1_Separator.BorderSizePixel = 0
    L1_Separator.Parent = Layar1_Icons

    -- Active Indicator untuk Layar 1
    local L1_ActiveLine = Instance.new("Frame")
    L1_ActiveLine.Size = UDim2.new(0, 3, 0, 24)
    L1_ActiveLine.Position = UDim2.new(0, 0, 0, 35) -- Posisi default awal
    L1_ActiveLine.AnchorPoint = Vector2.new(0, 0.5)
    L1_ActiveLine.BackgroundColor3 = Colors.ToscaGreen
    L1_ActiveLine.BorderSizePixel = 0
    L1_ActiveLine.ZIndex = 6
    L1_ActiveLine.Parent = Layar1_Icons
    
    local L1_LineCorner = Instance.new("UICorner")
    L1_LineCorner.CornerRadius = UDim.new(1, 0)
    L1_LineCorner.Parent = L1_ActiveLine

    -- 1. Tombol Garis 3 (Hamburger Menu - Dibuat Manual Agar Tidak Ada Error ID)
    local MainMenu_Btn = Instance.new("TextButton")
    MainMenu_Btn.Name = "Btn_Hamburger"
    MainMenu_Btn.Size = UDim2.new(0, 36, 0, 36)
    MainMenu_Btn.Position = UDim2.new(0.5, 0, 0, 35) -- Y=35
    MainMenu_Btn.AnchorPoint = Vector2.new(0.5, 0.5)
    MainMenu_Btn.BackgroundTransparency = 1
    MainMenu_Btn.Text = ""
    MainMenu_Btn.AutoButtonColor = false
    MainMenu_Btn.ZIndex = 6
    MainMenu_Btn.Parent = Layar1_Icons

    local H_Line1 = Instance.new("Frame", MainMenu_Btn)
    H_Line1.Size = UDim2.new(0, 20, 0, 2)
    H_Line1.Position = UDim2.new(0.5, -10, 0.5, -7)
    H_Line1.BackgroundColor3 = Colors.White
    H_Line1.BorderSizePixel = 0

    local H_Line2 = Instance.new("Frame", MainMenu_Btn)
    H_Line2.Size = UDim2.new(0, 20, 0, 2)
    H_Line2.Position = UDim2.new(0.5, -10, 0.5, -1)
    H_Line2.BackgroundColor3 = Colors.White
    H_Line2.BorderSizePixel = 0

    local H_Line3 = Instance.new("Frame", MainMenu_Btn)
    H_Line3.Size = UDim2.new(0, 20, 0, 2)
    H_Line3.Position = UDim2.new(0.5, -10, 0.5, 5)
    H_Line3.BackgroundColor3 = Colors.White
    H_Line3.BorderSizePixel = 0

    -- 2. Tombol Logo Axolion (Special Menu - Tepat Di Bawah Hamburger)
    local SpecialMenu_Btn = Instance.new("ImageButton")
    SpecialMenu_Btn.Name = "Btn_AxolionLogo"
    SpecialMenu_Btn.Size = UDim2.new(0, 34, 0, 34)
    SpecialMenu_Btn.Position = UDim2.new(0.5, 0, 0, 85) -- Y=85 (50 pixel di bawahnya)
    SpecialMenu_Btn.AnchorPoint = Vector2.new(0.5, 0.5)
    SpecialMenu_Btn.BackgroundTransparency = 1
    SpecialMenu_Btn.Image = _G.Axomusc_Config.SubLogo
    SpecialMenu_Btn.ImageColor3 = Colors.White
    SpecialMenu_Btn.ImageTransparency = 0.4
    SpecialMenu_Btn.AutoButtonColor = false
    SpecialMenu_Btn.ZIndex = 6
    SpecialMenu_Btn.Parent = Layar1_Icons
    
    -- Logic Animasi & Transisi Layar 1 ke Layar 2
    local SidebarOpen = true

    local function ToggleSidebar(Category)
        if Category then SwitchMenuCategory(Category) end
        
        if not SidebarOpen then
            SidebarOpen = true
            TweenService:Create(Layar2_Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, L2_Width, 1, -65)}):Play()
            TweenService:Create(Layar3_Content, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -(L1_Width + L2_Width), 1, -65), Position = UDim2.new(0, L1_Width + L2_Width, 0, 65)}):Play()
        end
    end

    -- Hover Animations
    MainMenu_Btn.MouseEnter:Connect(function() TweenService:Create(MainMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 40, 0, 40)}):Play() end)
    MainMenu_Btn.MouseLeave:Connect(function() TweenService:Create(MainMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 36, 0, 36)}):Play() end)
    
    SpecialMenu_Btn.MouseEnter:Connect(function() TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 38, 0, 38), ImageTransparency = 0}):Play() end)
    SpecialMenu_Btn.MouseLeave:Connect(function() 
        local targetTrans = (_G.CurrentL1 == "Special") and 0 or 0.4
        TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.2), {Size = UDim2.new(0, 34, 0, 34), ImageTransparency = targetTrans}):Play() 
    end)

    -- Click Logic
    MainMenu_Btn.MouseButton1Click:Connect(function()
        pcall(function()
            _G.CurrentL1 = "Main"
            -- Warna icon aktif
            TweenService:Create(H_Line1, TweenInfo.new(0.3), {BackgroundColor3 = Colors.ToscaGreen}):Play()
            TweenService:Create(H_Line2, TweenInfo.new(0.3), {BackgroundColor3 = Colors.ToscaGreen}):Play()
            TweenService:Create(H_Line3, TweenInfo.new(0.3), {BackgroundColor3 = Colors.ToscaGreen}):Play()
            TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.3), {ImageColor3 = Colors.White, ImageTransparency = 0.4}):Play()
            -- Pindah indikator
            TweenService:Create(L1_ActiveLine, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 35)}):Play()
            ToggleSidebar("Main")
        end)
    end)

    SpecialMenu_Btn.MouseButton1Click:Connect(function()
        pcall(function()
            _G.CurrentL1 = "Special"
            -- Warna icon aktif
            TweenService:Create(H_Line1, TweenInfo.new(0.3), {BackgroundColor3 = Colors.White}):Play()
            TweenService:Create(H_Line2, TweenInfo.new(0.3), {BackgroundColor3 = Colors.White}):Play()
            TweenService:Create(H_Line3, TweenInfo.new(0.3), {BackgroundColor3 = Colors.White}):Play()
            TweenService:Create(SpecialMenu_Btn, TweenInfo.new(0.3), {ImageColor3 = Colors.ToscaGreen, ImageTransparency = 0}):Play()
            -- Pindah indikator
            TweenService:Create(L1_ActiveLine, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 85)}):Play()
            ToggleSidebar("Special")
        end)
    end)
    
    -- Set Default View Awal
    _G.CurrentL1 = "Main"
    SwitchMenuCategory("Main")
    H_Line1.BackgroundColor3 = Colors.ToscaGreen
    H_Line2.BackgroundColor3 = Colors.ToscaGreen
    H_Line3.BackgroundColor3 = Colors.ToscaGreen
end)

if not success_b2 then warn("[Axomusc] Error Bagian 2 (3-Layar System): " .. tostring(error_b2)) end
