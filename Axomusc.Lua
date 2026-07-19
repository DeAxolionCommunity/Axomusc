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

-- ==============================================================================
-- [ AXOLION COMMUNITY (BETA) - UI SCRIPT ]
-- REVISI TOTAL: BAGIAN 3 - TAHAP 1 (ULTRA-PREMIUM EDITION)
-- ==============================================================================
-- MENUNGGU PERINTAH "LANJUT" UNTUK TAHAP 2 (PLAYLIST & FOLDER)
-- ==============================================================================

local Tahap1_Success, Tahap1_Error = pcall(function()
    
    -- ==============================================================================
    -- [1] SERVICES INITIALIZATION
    -- ==============================================================================
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local SoundService = game:GetService("SoundService")
    local ContentProvider = game:GetService("ContentProvider")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")

    -- ==============================================================================
    -- [2] GLOBAL CONFIGURATION & THEME SYSTEM
    -- ==============================================================================
    _G.Axomusc_Config = _G.Axomusc_Config or {}
    
    -- Strict Premium Color Palette Definition
    _G.Axomusc_Config.Colors = _G.Axomusc_Config.Colors or {
        DarkBlue = Color3.fromRGB(15, 25, 45),
        ToscaGreen = Color3.fromRGB(0, 200, 150),
        Black = Color3.fromRGB(10, 10, 15),
        White = Color3.fromRGB(245, 245, 245),
        IceBlue = Color3.fromRGB(100, 200, 255),
        Gray = Color3.fromRGB(60, 60, 70),
        DarkGray = Color3.fromRGB(30, 30, 40),
        Transparent = Color3.fromRGB(255, 255, 255) -- Used with Transparency 1
    }
    
    local Colors = _G.Axomusc_Config.Colors
    
    -- Asset IDs
    _G.Axomusc_Config.MainLogo = "rbxassetid://85647271976925"
    _G.Axomusc_Config.Thumbnail = "rbxassetid://84404991858137"
    _G.Axomusc_Config.SubLogo = "rbxassetid://100003155958609"
    _G.Axomusc_Config.GlowAsset = "rbxassetid://5028857084"

    -- Ensure Base Page Exists
    _G.Page_Music = _G.Page_Music or { Page = Instance.new("Frame") }
    local PageMusic = _G.Page_Music.Page

    -- ==============================================================================
    -- [3] ADVANCED MATH & UTILITY FUNCTIONS
    -- ==============================================================================
    local MathUtils = {}
    
    function MathUtils.Lerp(a, b, t)
        return a + (b - a) * t
    end

    function MathUtils.Clamp(val, min, max)
        if val < min then return min end
        if val > max then return max end
        return val
    end

    function MathUtils.FormatTime(seconds)
        if not seconds or seconds ~= seconds or seconds < 0 or seconds == math.huge then 
            return "00:00" 
        end
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", mins, secs)
    end

    local function CreateTween(object, time, style, direction, properties)
        local success, tween = pcall(function()
            local tweenInfo = TweenInfo.new(time, style, direction)
            local t = TweenService:Create(object, tweenInfo, properties)
            t:Play()
            return t
        end)
        if success then return tween else return nil end
    end

    -- ==============================================================================
    -- [4] UI FACTORY GENERATORS (FOR MODULARITY & LENGTH)
    -- ==============================================================================
    local UI = {}

    function UI.CreateFrame(name, parent, size, pos, anchor, bgColor, transparency, zIndex)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = size
        frame.Position = pos
        frame.AnchorPoint = anchor or Vector2.new(0, 0)
        frame.BackgroundColor3 = bgColor or Colors.Black
        frame.BackgroundTransparency = transparency or 0
        frame.BorderSizePixel = 0
        frame.ZIndex = zIndex or 1
        frame.Parent = parent
        return frame
    end

    function UI.CreateCorner(parent, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(radius.Scale, radius.Offset)
        corner.Parent = parent
        return corner
    end

    function UI.CreateStroke(parent, color, thickness, transparency)
        local stroke = Instance.new("UIStroke")
        stroke.Color = color or Colors.White
        stroke.Thickness = thickness or 1
        stroke.Transparency = transparency or 0
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = parent
        return stroke
    end

    function UI.CreateTextLabel(name, parent, size, pos, anchor, text, font, textSize, textColor, alignX, zIndex)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = size
        label.Position = pos
        label.AnchorPoint = anchor or Vector2.new(0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.Font = font or Enum.Font.GothamMedium
        label.TextSize = textSize or 14
        label.TextColor3 = textColor or Colors.White
        label.TextXAlignment = alignX or Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.ZIndex = zIndex or 1
        label.Parent = parent
        return label
    end

    function UI.CreateImage(name, parent, size, pos, anchor, imageId, scaleType, zIndex)
        local img = Instance.new("ImageLabel")
        img.Name = name
        img.Size = size
        img.Position = pos
        img.AnchorPoint = anchor or Vector2.new(0, 0)
        img.BackgroundTransparency = 1
        img.Image = imageId
        img.ScaleType = scaleType or Enum.ScaleType.Stretch
        img.ZIndex = zIndex or 1
        img.Parent = parent
        return img
    end

    -- ==============================================================================
    -- [5] CORE AUDIO ENGINE RE-INITIALIZATION
    -- ==============================================================================
    pcall(function()
        if _G.Axomusc_Engine then
            _G.Axomusc_Engine:Stop()
            _G.Axomusc_Engine:Destroy()
        end
    end)
    
    local AudioEngine = Instance.new("Sound")
    AudioEngine.Name = "Axolion_Audio_Engine_V2"
    AudioEngine.Parent = CoreGui
    AudioEngine.Volume = 0.5
    AudioEngine.PlaybackSpeed = 1
    AudioEngine.Looped = false
    AudioEngine.SoundGroup = nil
    AudioEngine.PlayOnRemove = false
    _G.Axomusc_Engine = AudioEngine

    -- State Variables
    _G.Axomusc_State = {
        IsPlaying = false,
        CurrentID = "",
        CurrentTitle = "",
        CurrentArtist = "",
        Duration = 0,
        Position = 0,
        Volume = 0.5,
        Speed = 1.0,
        IsDraggingProgress = false,
        IsDraggingVolume = false,
        BassPulseTarget = 1,
        BassPulseCurrent = 1,
        VinylRotation = 0
    }

    -- ==============================================================================
    -- [6] MASTER CONTAINER SETUP
    -- ==============================================================================
    local MusicContainer = UI.CreateFrame(
        "Music_Master_Container", 
        PageMusic, 
        UDim2.new(1, 0, 1, 0), 
        UDim2.new(0, 0, 0, 0), 
        Vector2.new(0, 0), 
        Colors.Black, 
        1, 
        1
    )

    -- ==============================================================================
    -- [7] EXTREME DETAIL VINYL & CD VISUALIZER
    -- ==============================================================================
    local VisualizerWrapper = UI.CreateFrame(
        "Visualizer_Wrapper",
        MusicContainer,
        UDim2.new(0.5, 0, 0.5, 0),
        UDim2.new(0.5, 0, 0.05, 0),
        Vector2.new(0.5, 0),
        Colors.Black,
        1,
        2
    )

    local AspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
    AspectRatioConstraint.AspectRatio = 1
    AspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
    AspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
    AspectRatioConstraint.Parent = VisualizerWrapper

    -- [7.1] Responsive RGB Bass Glow
    local BassGlow = UI.CreateFrame(
        "Bass_RGB_Glow",
        VisualizerWrapper,
        UDim2.new(1, 40, 1, 40),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        Color3.new(1, 1, 1),
        0,
        1
    )
    UI.CreateCorner(BassGlow, UDim.new(1, 0))

    local BassGradient = Instance.new("UIGradient")
    BassGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Colors.ToscaGreen),
        ColorSequenceKeypoint.new(0.20, Colors.IceBlue),
        ColorSequenceKeypoint.new(0.40, Colors.DarkBlue),
        ColorSequenceKeypoint.new(0.60, Colors.ToscaGreen),
        ColorSequenceKeypoint.new(0.80, Colors.IceBlue),
        ColorSequenceKeypoint.new(1.00, Colors.ToscaGreen)
    })
    BassGradient.Rotation = 0
    BassGradient.Parent = BassGlow

    -- [7.2] Main Vinyl Record
    local VinylRecord = UI.CreateImage(
        "Vinyl_Record_Main",
        VisualizerWrapper,
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        _G.Axomusc_Config.Thumbnail,
        Enum.ScaleType.Crop,
        3
    )
    VinylRecord.BackgroundTransparency = 0
    VinylRecord.BackgroundColor3 = Colors.Black
    UI.CreateCorner(VinylRecord, UDim.new(1, 0))
    UI.CreateStroke(VinylRecord, Colors.DarkBlue, 4, 0)

    -- [7.3] Vinyl Texture Overlays (Rings & Light Reflection)
    for i = 1, 6 do
        local ringSize = 1 - (i * 0.12)
        local Ring = UI.CreateFrame(
            "Vinyl_Ring_" .. i,
            VinylRecord,
            UDim2.new(ringSize, 0, ringSize, 0),
            UDim2.new(0.5, 0, 0.5, 0),
            Vector2.new(0.5, 0.5),
            Colors.Black,
            1,
            4
        )
        UI.CreateCorner(Ring, UDim.new(1, 0))
        UI.CreateStroke(Ring, Colors.White, 1, 0.85 + (i * 0.02))
    end

    local ReflectionGradient = UI.CreateFrame(
        "Vinyl_Reflection",
        VinylRecord,
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        Color3.new(1, 1, 1),
        0,
        5
    )
    UI.CreateCorner(ReflectionGradient, UDim.new(1, 0))
    local RefGradient = Instance.new("UIGradient")
    RefGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
    })
    RefGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.4, 1),
        NumberSequenceKeypoint.new(0.6, 1),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    RefGradient.Rotation = -45
    RefGradient.Parent = ReflectionGradient

    -- [7.4] Center Hole & Spindle
    local CenterLabel = UI.CreateFrame(
        "Center_Label",
        VinylRecord,
        UDim2.new(0.3, 0, 0.3, 0),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        Colors.DarkBlue,
        0,
        6
    )
    UI.CreateCorner(CenterLabel, UDim.new(1, 0))
    UI.CreateStroke(CenterLabel, Colors.ToscaGreen, 2, 0)

    local SpindleHole = UI.CreateFrame(
        "Spindle_Hole",
        CenterLabel,
        UDim2.new(0.15, 0, 0.15, 0),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        Colors.Black,
        0,
        7
    )
    UI.CreateCorner(SpindleHole, UDim.new(1, 0))
    UI.CreateStroke(SpindleHole, Colors.IceBlue, 1, 0.5)
    
    _G.Axomusc_AlbumArt = VinylRecord

    -- ==============================================================================
    -- [8] SONG METADATA PANEL
    -- ==============================================================================
    local MetaDataPanel = UI.CreateFrame(
        "MetaData_Panel",
        MusicContainer,
        UDim2.new(1, -40, 0, 60),
        UDim2.new(0.5, 0, 0.58, 0),
        Vector2.new(0.5, 0),
        Colors.Black,
        1,
        2
    )

    local TitleLabel = UI.CreateTextLabel(
        "Title_Label",
        MetaDataPanel,
        UDim2.new(1, 0, 0, 30),
        UDim2.new(0.5, 0, 0, 0),
        Vector2.new(0.5, 0),
        "Axolion Theme (Beta)",
        Enum.Font.GothamBold,
        22,
        Colors.White,
        Enum.TextXAlignment.Center,
        2
    )
    TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    _G.Axomusc_TitleLabel = TitleLabel

    local ArtistLabel = UI.CreateTextLabel(
        "Artist_Label",
        MetaDataPanel,
        UDim2.new(1, 0, 0, 20),
        UDim2.new(0.5, 0, 0, 30),
        Vector2.new(0.5, 0),
        "Axolion Community",
        Enum.Font.GothamSemibold,
        14,
        Colors.IceBlue,
        Enum.TextXAlignment.Center,
        2
    )
    _G.Axomusc_ArtistLabel = ArtistLabel

    -- ==============================================================================
    -- [9] ADVANCED PROGRESS BAR SYSTEM
    -- ==============================================================================
    local ProgressContainer = UI.CreateFrame(
        "Progress_Container",
        MusicContainer,
        UDim2.new(1, -60, 0, 30),
        UDim2.new(0.5, 0, 0.72, 0),
        Vector2.new(0.5, 0),
        Colors.Black,
        1,
        2
    )

    local TimeCurrentLabel = UI.CreateTextLabel(
        "Time_Current",
        ProgressContainer,
        UDim2.new(0, 45, 1, 0),
        UDim2.new(0, -50, 0, 0),
        Vector2.new(0, 0),
        "00:00",
        Enum.Font.GothamMedium,
        12,
        Colors.White,
        Enum.TextXAlignment.Right,
        2
    )

    local TimeTotalLabel = UI.CreateTextLabel(
        "Time_Total",
        ProgressContainer,
        UDim2.new(0, 45, 1, 0),
        UDim2.new(1, 5, 0, 0),
        Vector2.new(0, 0),
        "00:00",
        Enum.Font.GothamMedium,
        12,
        Colors.White,
        Enum.TextXAlignment.Left,
        2
    )

    local ProgressHitbox = Instance.new("TextButton")
    ProgressHitbox.Name = "Progress_Hitbox"
    ProgressHitbox.Size = UDim2.new(1, 0, 1, 0)
    ProgressHitbox.Position = UDim2.new(0, 0, 0, 0)
    ProgressHitbox.BackgroundTransparency = 1
    ProgressHitbox.Text = ""
    ProgressHitbox.ZIndex = 5
    ProgressHitbox.Parent = ProgressContainer

    local ProgressTrack = UI.CreateFrame(
        "Progress_Track",
        ProgressContainer,
        UDim2.new(1, 0, 0, 6),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        Colors.DarkGray,
        0,
        2
    )
    UI.CreateCorner(ProgressTrack, UDim.new(1, 0))
    UI.CreateStroke(ProgressTrack, Colors.Black, 1, 0)

    local ProgressFill = UI.CreateFrame(
        "Progress_Fill",
        ProgressTrack,
        UDim2.new(0, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        Vector2.new(0, 0),
        Colors.ToscaGreen,
        0,
        3
    )
    UI.CreateCorner(ProgressFill, UDim.new(1, 0))

    local ProgressThumb = UI.CreateFrame(
        "Progress_Thumb",
        ProgressFill,
        UDim2.new(0, 14, 0, 14),
        UDim2.new(1, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        Colors.White,
        0,
        4
    )
    UI.CreateCorner(ProgressThumb, UDim.new(1, 0))
    UI.CreateStroke(ProgressThumb, Colors.IceBlue, 2, 0.2)

    local ProgressThumbGlow = UI.CreateImage(
        "Progress_Thumb_Glow",
        ProgressThumb,
        UDim2.new(0, 36, 0, 36),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        _G.Axomusc_Config.GlowAsset,
        Enum.ScaleType.Stretch,
        3
    )
    ProgressThumbGlow.ImageColor3 = Colors.ToscaGreen
    ProgressThumbGlow.ImageTransparency = 0.6

    -- ==============================================================================
    -- [10] GLASSMORPHISM MAIN CONTROL PANEL
    -- ==============================================================================
    local ControlPanel = UI.CreateFrame(
        "Control_Panel",
        MusicContainer,
        UDim2.new(1, -40, 0, 75),
        UDim2.new(0.5, 0, 1, -20),
        Vector2.new(0.5, 1),
        Colors.Black,
        0.25,
        2
    )
    UI.CreateCorner(ControlPanel, UDim.new(0, 20))
    UI.CreateStroke(ControlPanel, Colors.DarkBlue, 2, 0.3)

    local ControlGradient = Instance.new("UIGradient")
    ControlGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.DarkBlue),
        ColorSequenceKeypoint.new(0.5, Colors.Black),
        ColorSequenceKeypoint.new(1, Colors.DarkBlue)
    })
    ControlGradient.Rotation = 35
    ControlGradient.Parent = ControlPanel

    -- Control Panel Layout Settings
    local ControlLayout = Instance.new("UIListLayout")
    ControlLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlLayout.Padding = UDim.new(0, 15)
    ControlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlLayout.Parent = ControlPanel

    local function CreateControlButton(name, text, layoutOrder, defaultSize, hoverSize, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0, 50, 0, 50)
        btn.BackgroundTransparency = 1
        btn.Text = text
        btn.TextColor3 = color or Colors.White
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = defaultSize
        btn.LayoutOrder = layoutOrder
        btn.AutoButtonColor = false
        btn.ZIndex = 5
        btn.Parent = ControlPanel
        
        btn.MouseEnter:Connect(function() 
            pcall(function() CreateTween(btn, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, {TextSize = hoverSize, TextColor3 = Colors.IceBlue}) end)
        end)
        btn.MouseLeave:Connect(function() 
            pcall(function() CreateTween(btn, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, {TextSize = defaultSize, TextColor3 = color or Colors.White}) end)
        end)
        
        return btn
    end

    local BtnSpeed = CreateControlButton("Btn_Speed", "1.0x", 1, 14, 18, Colors.White)
    local BtnPrev  = CreateControlButton("Btn_Prev", "⏮", 2, 24, 28, Colors.White)
    local BtnPlay  = CreateControlButton("Btn_Play", "▶", 3, 45, 50, Colors.ToscaGreen)
    local BtnNext  = CreateControlButton("Btn_Next", "⏭", 4, 24, 28, Colors.White)
    local BtnVol   = CreateControlButton("Btn_Vol", "🔊", 5, 24, 28, Colors.White)

    -- Play Button Special Glow & Override
    local PlayBtnGlow = UI.CreateImage(
        "Play_Glow",
        BtnPlay,
        UDim2.new(0, 80, 0, 80),
        UDim2.new(0.5, 0, 0.5, 0),
        Vector2.new(0.5, 0.5),
        _G.Axomusc_Config.GlowAsset,
        Enum.ScaleType.Stretch,
        4
    )
    PlayBtnGlow.ImageColor3 = Colors.ToscaGreen
    PlayBtnGlow.ImageTransparency = 1

    BtnPlay.MouseLeave:Connect(function()
        pcall(function()
            local targetColor = AudioEngine.IsPlaying and Colors.ToscaGreen or Colors.White
            CreateTween(BtnPlay, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, {TextSize = 45, TextColor3 = targetColor})
        end)
    end)

    -- ==============================================================================
    -- [11] INTERACTIVE POPUP MENUS (SPEED & VOLUME)
    -- ==============================================================================
    local PopupContainer = UI.CreateFrame("Popup_Container", MusicContainer, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Vector2.new(0,0), Colors.Black, 1, 10)
    PopupContainer.Visible = false

    local ClosePopupOverlay = Instance.new("TextButton")
    ClosePopupOverlay.Size = UDim2.new(1,0,1,0)
    ClosePopupOverlay.BackgroundTransparency = 1
    ClosePopupOverlay.Text = ""
    ClosePopupOverlay.Parent = PopupContainer

    -- [11.1] Speed Menu
    local SpeedMenu = UI.CreateFrame("Speed_Menu", PopupContainer, UDim2.new(0, 80, 0, 160), UDim2.new(0.15, 0, 0.85, 0), Vector2.new(0.5, 1), Colors.Black, 0.1, 11)
    UI.CreateCorner(SpeedMenu, UDim.new(0, 12))
    UI.CreateStroke(SpeedMenu, Colors.IceBlue, 1, 0)
    SpeedMenu.Visible = false

    local SpeedList = Instance.new("UIListLayout")
    SpeedList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SpeedList.SortOrder = Enum.SortOrder.LayoutOrder
    SpeedList.Parent = SpeedMenu

    local SpeedOptions = {2.0, 1.5, 1.25, 1.0, 0.75, 0.5}
    for idx, spd in ipairs(SpeedOptions) do
        local spdBtn = Instance.new("TextButton")
        spdBtn.Size = UDim2.new(1, 0, 0, 26)
        spdBtn.BackgroundTransparency = 1
        spdBtn.Text = string.format("%.2fx", spd)
        spdBtn.TextColor3 = Colors.White
        spdBtn.Font = Enum.Font.GothamMedium
        spdBtn.TextSize = 13
        spdBtn.LayoutOrder = idx
        spdBtn.Parent = SpeedMenu

        spdBtn.MouseEnter:Connect(function() pcall(function() CreateTween(spdBtn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundColor3 = Colors.DarkBlue, BackgroundTransparency = 0.3, TextColor3 = Colors.ToscaGreen}) end) end)
        spdBtn.MouseLeave:Connect(function() pcall(function() CreateTween(spdBtn, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {BackgroundTransparency = 1, TextColor3 = Colors.White}) end) end)
        
        spdBtn.MouseButton1Click:Connect(function()
            pcall(function()
                AudioEngine.PlaybackSpeed = spd
                _G.Axomusc_State.Speed = spd
                BtnSpeed.Text = (spd == 1.0) and "1.0x" or string.format("%.1fx", spd)
                SpeedMenu.Visible = false
                PopupContainer.Visible = false
            end)
        end)
    end

    -- [11.2] Volume Menu
    local VolumeMenu = UI.CreateFrame("Volume_Menu", PopupContainer, UDim2.new(0, 180, 0, 50), UDim2.new(0.85, 0, 0.85, 0), Vector2.new(0.5, 1), Colors.Black, 0.1, 11)
    UI.CreateCorner(VolumeMenu, UDim.new(0, 12))
    UI.CreateStroke(VolumeMenu, Colors.ToscaGreen, 1, 0)
    VolumeMenu.Visible = false

    local VolTextVal = UI.CreateTextLabel("Vol_Val", VolumeMenu, UDim2.new(0, 30, 1, 0), UDim2.new(1, -35, 0, 0), Vector2.new(0,0), "50%", Enum.Font.GothamBold, 12, Colors.White, Enum.TextXAlignment.Right, 12)
    
    local VolHitbox = Instance.new("TextButton")
    VolHitbox.Size = UDim2.new(0, 120, 1, 0)
    VolHitbox.Position = UDim2.new(0, 15, 0, 0)
    VolHitbox.BackgroundTransparency = 1
    VolHitbox.Text = ""
    VolHitbox.ZIndex = 15
    VolHitbox.Parent = VolumeMenu

    local VolTrack = UI.CreateFrame("Vol_Track", VolHitbox, UDim2.new(1, 0, 0, 6), UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5), Colors.DarkGray, 0, 12)
    UI.CreateCorner(VolTrack, UDim.new(1, 0))
    
    local VolFill = UI.CreateFrame("Vol_Fill", VolTrack, UDim2.new(0.5, 0, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0,0), Colors.IceBlue, 0, 13)
    UI.CreateCorner(VolFill, UDim.new(1, 0))

    local VolThumb = UI.CreateFrame("Vol_Thumb", VolFill, UDim2.new(0, 14, 0, 14), UDim2.new(1, 0, 0.5, 0), Vector2.new(0.5, 0.5), Colors.White, 0, 14)
    UI.CreateCorner(VolThumb, UDim.new(1, 0))

    -- Popup Toggles
    BtnSpeed.MouseButton1Click:Connect(function()
        pcall(function()
            PopupContainer.Visible = true
            SpeedMenu.Visible = true
            VolumeMenu.Visible = false
        end)
    end)

    BtnVol.MouseButton1Click:Connect(function()
        pcall(function()
            PopupContainer.Visible = true
            VolumeMenu.Visible = true
            SpeedMenu.Visible = false
        end)
    end)

    ClosePopupOverlay.MouseButton1Click:Connect(function()
        pcall(function()
            PopupContainer.Visible = false
            SpeedMenu.Visible = false
            VolumeMenu.Visible = false
        end)
    end)

    -- ==============================================================================
    -- [12] COMPLEX INPUT SYSTEM & LOGIC
    -- ==============================================================================
    local function UpdateVolumeVisual(input)
        pcall(function()
            local bounds = VolHitbox.AbsoluteSize.X
            local minX = VolHitbox.AbsolutePosition.X
            local mouseX = input.Position.X
            local percentage = MathUtils.Clamp((mouseX - minX) / bounds, 0, 1)
            
            VolFill.Size = UDim2.new(percentage, 0, 1, 0)
            local volInt = math.floor(percentage * 100)
            VolTextVal.Text = tostring(volInt) .. "%"
            
            AudioEngine.Volume = percentage
            _G.Axomusc_State.Volume = percentage

            if volInt == 0 then BtnVol.Text = "🔇"
            elseif volInt < 40 then BtnVol.Text = "🔉"
            else BtnVol.Text = "🔊" end
        end)
    end

    local function UpdateProgressVisual(input)
        pcall(function()
            local bounds = ProgressHitbox.AbsoluteSize.X
            local minX = ProgressHitbox.AbsolutePosition.X
            local mouseX = input.Position.X
            local percentage = MathUtils.Clamp((mouseX - minX) / bounds, 0, 1)
            
            ProgressFill.Size = UDim2.new(percentage, 0, 1, 0)
            
            local duration = AudioEngine.TimeLength
            if duration and duration == duration and duration > 0 and duration ~= math.huge then
                local targetTime = duration * percentage
                TimeCurrentLabel.Text = MathUtils.FormatTime(targetTime)
            end
        end)
    end

    VolHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _G.Axomusc_State.IsDraggingVolume = true
            UpdateVolumeVisual(input)
        end
    end)

    ProgressHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _G.Axomusc_State.IsDraggingProgress = true
            UpdateProgressVisual(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if _G.Axomusc_State.IsDraggingVolume then UpdateVolumeVisual(input) end
            if _G.Axomusc_State.IsDraggingProgress then UpdateProgressVisual(input) end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if _G.Axomusc_State.IsDraggingVolume then
                _G.Axomusc_State.IsDraggingVolume = false
            end
            if _G.Axomusc_State.IsDraggingProgress then
                _G.Axomusc_State.IsDraggingProgress = false
                pcall(function()
                    local duration = AudioEngine.TimeLength
                    if duration and duration == duration and duration > 0 and duration ~= math.huge then
                        local finalPercent = ProgressFill.Size.X.Scale
                        AudioEngine.TimePosition = duration * finalPercent
                    end
                end)
            end
        end
    end)

    -- ==============================================================================
    -- [13] GLOBAL PLAYBACK API (SECURE ACCESS POINT)
    -- ==============================================================================
    _G.Axomusc_PlaySong = function(MusicID, MusicName, MusicArtist)
        pcall(function()
            local CleanID = tostring(MusicID):gsub("%D", "")
            if CleanID == "" then return end
            
            AudioEngine:Stop()
            AudioEngine.SoundId = "rbxassetid://" .. CleanID
            AudioEngine.TimePosition = 0
            
            _G.Axomusc_State.CurrentID = CleanID
            _G.Axomusc_State.CurrentTitle = tostring(MusicName or "Unknown Title")
            _G.Axomusc_State.CurrentArtist = tostring(MusicArtist or "Axolion Community")
            
            TitleLabel.Text = _G.Axomusc_State.CurrentTitle
            ArtistLabel.Text = _G.Axomusc_State.CurrentArtist
            TimeCurrentLabel.Text = "00:00"
            TimeTotalLabel.Text = "Loading..."
            ProgressFill.Size = UDim2.new(0, 0, 1, 0)
            
            AudioEngine:Play()
            
            BtnPlay.Text = "⏸"
            PlayBtnGlow.ImageTransparency = 0.3
            CreateTween(BtnPlay, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, {TextColor3 = Colors.ToscaGreen})
        end)
    end

    _G.Axomusc_TogglePlayback = function()
        pcall(function()
            if AudioEngine.SoundId == "" then return end
            
            if AudioEngine.IsPlaying then
                AudioEngine:Pause()
                BtnPlay.Text = "▶"
                PlayBtnGlow.ImageTransparency = 1
                CreateTween(BtnPlay, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, {TextColor3 = Colors.White})
            else
                AudioEngine:Play()
                BtnPlay.Text = "⏸"
                PlayBtnGlow.ImageTransparency = 0.3
                CreateTween(BtnPlay, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, {TextColor3 = Colors.ToscaGreen})
            end
        end)
    end

    BtnPlay.MouseButton1Click:Connect(_G.Axomusc_TogglePlayback)

    -- ==============================================================================
    -- [14] RENDER STEPPED (ENGINE TICK, ANIMATIONS, ANTI-FREEZE SYSTEM)
    -- ==============================================================================
    RunService.RenderStepped:Connect(function(deltaTime)
        pcall(function()
            -- 1. Rotate Bass Gradient Always
            BassGradient.Rotation = (BassGradient.Rotation + (100 * deltaTime)) % 360
            
            -- 2. State & Safety Check Validation
            local isPlaying = AudioEngine.IsPlaying
            local cTime = AudioEngine.TimePosition
            local tTime = AudioEngine.TimeLength
            
            -- NaN Protection Logic
            local validTime = (tTime and tTime == tTime and tTime > 0 and tTime ~= math.huge)

            if isPlaying then
                -- A. Audio Reactive Visuals
                local loudness = AudioEngine.PlaybackLoudness or 0
                local targetScale = 1.0 + MathUtils.Clamp(loudness / 1000, 0.0, 0.35)
                
                _G.Axomusc_State.BassPulseCurrent = MathUtils.Lerp(_G.Axomusc_State.BassPulseCurrent, targetScale, deltaTime * 12)
                BassGlow.Size = UDim2.new(_G.Axomusc_State.BassPulseCurrent, 40, _G.Axomusc_State.BassPulseCurrent, 40)
                
                -- B. Vinyl Rotation Math
                local rotationSpeed = 40 * AudioEngine.PlaybackSpeed
                _G.Axomusc_State.VinylRotation = (_G.Axomusc_State.VinylRotation + (rotationSpeed * deltaTime)) % 360
                VinylRecord.Rotation = _G.Axomusc_State.VinylRotation
                
                -- C. Dynamic Progress Update
                if validTime then
                    TimeTotalLabel.Text = MathUtils.FormatTime(tTime)
                    if not _G.Axomusc_State.IsDraggingProgress then
                        local progressRatio = MathUtils.Clamp(cTime / tTime, 0, 1)
                        TimeCurrentLabel.Text = MathUtils.FormatTime(cTime)
                        
                        -- Smooth Lerp for Progress Bar
                        local currentScale = ProgressFill.Size.X.Scale
                        local nextScale = MathUtils.Lerp(currentScale, progressRatio, deltaTime * 15)
                        ProgressFill.Size = UDim2.new(nextScale, 0, 1, 0)
                    end
                else
                    TimeTotalLabel.Text = "Loading..."
                end
                
                -- D. Auto-Next Logic (If song finished naturally)
                if validTime and cTime >= (tTime - 0.2) and not _G.Axomusc_State.IsDraggingProgress then
                    if _G.Axomusc_PlayNextFromPlaylist then
                        _G.Axomusc_PlayNextFromPlaylist() -- To be defined in Tahap 2
                    else
                        AudioEngine:Stop()
                        BtnPlay.Text = "▶"
                        PlayBtnGlow.ImageTransparency = 1
                        BtnPlay.TextColor3 = Colors.White
                        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
                        TimeCurrentLabel.Text = "00:00"
                    end
                end
            else
                -- Graceful Fallback Animations when paused/stopped
                _G.Axomusc_State.BassPulseCurrent = MathUtils.Lerp(_G.Axomusc_State.BassPulseCurrent, 1.0, deltaTime * 8)
                BassGlow.Size = UDim2.new(_G.Axomusc_State.BassPulseCurrent, 40, _G.Axomusc_State.BassPulseCurrent, 40)
            end
        end)
    end)

end)

if not Tahap1_Success then 
    warn("[Axolion Premium] Tahap 1 Critical System Recovery: " .. tostring(Tahap1_Error)) 
end

-- ==============================================================================
-- END OF TAHAP 1 REVISION. MENUNGGU PERINTAH LANJUT.
-- ==============================================================================
