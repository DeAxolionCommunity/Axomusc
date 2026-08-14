Memproses selama 11s

--// ================================================================
--// AXOMUSC BETA
--// AXOLION COMMUNITY
--// PREMIUM MUSIC ENGINE
--// EXECUTOR-SAFE / DELTA COMPATIBILITY BUILD
--// ================================================================
--// COMPLETE SINGLE SCRIPT
--// - gethui() protected
--// - Executor API detection
--// - Responsive UIScale
--// - Premium Acrylic / Glass UI
--// - Sidebar Navigation
--// - Music Engine
--// - Roblox Music ID Search
--// - Audio Library
--// - Playlist System
--// - Persistent Favorites
--// - Persistent Saved Tracks
--// - Volume 1-100
--// - Playback Speed
--// - Equalizer
--// - Shuffle
--// - Repeat
--// - Previous / Play / Next
--// - Search
--// - Folder Browser
--// - Community Panel
--// - Clipboard
--// - Toast System
--// - Ripple
--// - Dragging
--// - Minimize Bubble
--// - Keybind
--// - Executor Detection
--// - Cleanup / Re-execution Protection
--// ================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

--// ================================================================
--// EXECUTOR ENVIRONMENT
--// ================================================================

local GEN = nil
pcall(function()
    GEN = getgenv and getgenv()
end)

if not GEN then
    GEN = {}
end

--// Stop previous Axomusc instance safely
pcall(function()
    if GEN.__AXOMUSC_DESTROY then
        GEN.__AXOMUSC_DESTROY()
    end
end)

--// Protected executor UI host
local UIParent

pcall(function()
    if typeof(gethui) == "function" then
        UIParent = gethui()
    end
end)

if not UIParent then
    pcall(function()
        UIParent = game:GetService("CoreGui")
    end)
end

if not UIParent then
    UIParent = LocalPlayer:WaitForChild("PlayerGui")
end

--// Executor API detection
local Executor = {
    Name = "Roblox",
    Clipboard = false,
    FileSystem = false,
    Folder = false,
    Read = false,
    Write = false,
    IsFile = false,
    MakeFolder = false,
}

pcall(function()
    if typeof(identifyexecutor) == "function" then
        local a,b = identifyexecutor()
        Executor.Name = tostring(a or b or "Executor")
    end
end)

pcall(function()
    if typeof(setclipboard) == "function" then
        Executor.Clipboard = true
    end
end)

pcall(function()
    if typeof(readfile) == "function" then
        Executor.Read = true
    end
end)

pcall(function()
    if typeof(writefile) == "function" then
        Executor.Write = true
    end
end)

pcall(function()
    if typeof(isfile) == "function" then
        Executor.IsFile = true
    end
end)

pcall(function()
    if typeof(makefolder) == "function" then
        Executor.MakeFolder = true
    end
end)

Executor.FileSystem = Executor.Read and Executor.Write
Executor.Folder = Executor.MakeFolder

--// ================================================================
--// CONFIGURATION
--// ================================================================

local CONFIG = {
    Name = "Axomusc",
    Version = "Beta",
    Community = "Axolion Community",

    Logo = "rbxassetid://85647271976925",
    Thumbnail = "rbxassetid://84404991858137",
    SubLogo = "rbxassetid://100003155958609",

    Discord = "https://discord.gg/dkuXRcS2hY",
    CommunityLink = "https://www.roblox.com/share/g/245953568",

    Accent = Color3.fromRGB(38, 224, 202),
    AccentDark = Color3.fromRGB(16, 150, 138),
    IceBlue = Color3.fromRGB(106, 211, 255),

    Background = Color3.fromRGB(5, 10, 23),
    Background2 = Color3.fromRGB(7, 14, 31),
    Panel = Color3.fromRGB(8, 13, 28),
    Panel2 = Color3.fromRGB(11, 18, 38),
    Black = Color3.fromRGB(2, 4, 9),

    White = Color3.fromRGB(240, 248, 255),
    Muted = Color3.fromRGB(143, 158, 180),
    Dim = Color3.fromRGB(80, 94, 115),

    Corner = 16,
    SaveFile = "Axomusc_Beta_Data.json",
    SaveFolder = "Axolion",

    DefaultVolume = 80,
    DefaultSpeed = 1,
    DefaultKey = Enum.KeyCode.RightControl,
}

--// ================================================================
--// SAFE HELPERS
--// ================================================================

local function safeCall(fn,...)
    local ok,result = pcall(fn,...)
    if ok then
        return result
    end
    return nil
end

local function safeDestroy(obj)
    if obj then
        pcall(function()
            obj:Destroy()
        end)
    end
end

local function safeDisconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function clampNumber(v,a,b)
    return math.clamp(tonumber(v) or a,a,b)
end

local function create(class,parent,props)
    local obj = Instance.new(class)
    if parent then
        obj.Parent = parent
    end

    if props then
        for k,v in pairs(props) do
            pcall(function()
                obj[k] = v
            end)
        end
    end

    return obj
end

local function tween(obj,duration,properties,easing)
    if not obj then
        return nil
    end

    local style = easing or Enum.EasingStyle.Quad

    local info = TweenInfo.new(
        duration or 0.25,
        style,
        Enum.EasingDirection.Out
    )

    local t
    pcall(function()
        t = TweenService:Create(obj,info,properties)
        t:Play()
    end)

    return t
end

local function corner(parent,radius)
    return create("UICorner",parent,{
        CornerRadius = UDim.new(0,radius or CONFIG.Corner)
    })
end

local function stroke(parent,color,thickness,transparency)
    return create("UIStroke",parent,{
        Color = color or CONFIG.Accent,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function padding(parent,l,r,t,b)
    return create("UIPadding",parent,{
        PaddingLeft = UDim.new(0,l or 0),
        PaddingRight = UDim.new(0,r or 0),
        PaddingTop = UDim.new(0,t or 0),
        PaddingBottom = UDim.new(0,b or 0),
    })
end

local function list(parent,direction,gap)
    return create("UIListLayout",parent,{
        FillDirection = direction or Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,gap or 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })
end

local function gradient(parent,c1,c2,rotation)
    return create("UIGradient",parent,{
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,c1),
            ColorSequenceKeypoint.new(1,c2)
        }),
        Rotation = rotation or 0,
    })
end

--// ================================================================
--// FILE STORAGE
--// ================================================================

local saveFolder = CONFIG.SaveFolder
local savePath = saveFolder .. "/" .. CONFIG.SaveFile

local function ensureFolder()
    if not Executor.MakeFolder then
        return
    end

    pcall(function()
        if not isfolder or not isfolder(saveFolder) then
            makefolder(saveFolder)
        end
    end)
end

ensureFolder()

local function encode(data)
    local HttpService = game:GetService("HttpService")
    return safeCall(function()
        return HttpService:JSONEncode(data)
    end)
end

local function decode(data)
    local HttpService = game:GetService("HttpService")
    return safeCall(function()
        return HttpService:JSONDecode(data)
    end)
end

local function saveData(data)
    if not Executor.FileSystem then
        return false
    end

    local raw = encode(data)
    if not raw then
        return false
    end

    local ok = pcall(function()
        writefile(savePath,raw)
    end)

    return ok
end

local function loadData()
    if not Executor.FileSystem then
        return nil
    end

    local exists = false

    pcall(function()
        exists = isfile(savePath)
    end)

    if not exists then
        return nil
    end

    local raw

    pcall(function()
        raw = readfile(savePath)
    end)

    if not raw then
        return nil
    end

    return decode(raw)
end

--// ================================================================
--// DATA
--// ================================================================

local Saved = loadData()

if type(Saved) ~= "table" then
    Saved = {}
end

Saved.Tracks = type(Saved.Tracks) == "table" and Saved.Tracks or {}
Saved.Favorites = type(Saved.Favorites) == "table" and Saved.Favorites or {}
Saved.Playlists = type(Saved.Playlists) == "table" and Saved.Playlists or {}
Saved.Settings = type(Saved.Settings) == "table" and Saved.Settings or {}

Saved.Settings.Volume = clampNumber(
    Saved.Settings.Volume or CONFIG.DefaultVolume,
    1,
    100
)

Saved.Settings.Speed = tonumber(Saved.Settings.Speed) or CONFIG.DefaultSpeed
Saved.Settings.Key = Saved.Settings.Key or "RightControl"

local function persist()
    saveData(Saved)
end

--// ================================================================
--// GUI ROOT
--// ================================================================

local Existing = safeCall(function()
    return UIParent:FindFirstChild("Axomusc_Beta")
end)

if Existing then
    safeDestroy(Existing)
end

local ScreenGui = create("ScreenGui",UIParent,{
    Name = "Axomusc_Beta",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999999,
})

GEN.__AXOMUSC_GUI = ScreenGui

--// ================================================================
--// SCALE SYSTEM
--// ================================================================

local ScaleHolder = create("Frame",ScreenGui,{
    Name = "ScaleHolder",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1,1),
})

local UIScale = create("UIScale",ScaleHolder,{
    Scale = 1,
})

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local width = viewport.X
    local height = viewport.Y

    local baseWidth = 1120
    local baseHeight = 690

    local scaleX = width / baseWidth
    local scaleY = height / baseHeight

    local target = math.min(scaleX,scaleY)

    if width < 600 then
        target = math.min(target,0.78)
    elseif width < 850 then
        target = math.min(target,0.88)
    else
        target = math.min(target,1)
    end

    target = math.clamp(target,0.62,1)

    tween(UIScale,0.25,{
        Scale = target
    })
end

updateScale()

local cameraConnection
cameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(updateScale)
end)

local viewportConnection
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.5)
        updateScale()
    end
end)

--// ================================================================
--// MAIN WINDOW
--// ================================================================

local Main = create("Frame",ScaleHolder,{
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.52),
    Size = UDim2.fromOffset(1080,650),
    BackgroundColor3 = CONFIG.Background,
    BackgroundTransparency = 0.035,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

corner(Main,22)
stroke(Main,CONFIG.Accent,1.5,0.08)

local MainGradient = gradient(
    Main,
    Color3.fromRGB(6,12,29),
    Color3.fromRGB(2,7,17),
    125
)

--// subtle glass overlay
local Glass = create("Frame",Main,{
    Name = "GlassOverlay",
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromRGB(20,40,60),
    BackgroundTransparency = 0.93,
    BorderSizePixel = 0,
    Active = false,
})

corner(Glass,22)

--// ================================================================
--// TOP BAR
--// ================================================================

local TopBar = create("Frame",Main,{
    Name = "TopBar",
    Size = UDim2.new(1,0,0,78),
    BackgroundColor3 = CONFIG.Background,
    BackgroundTransparency = 0.03,
    BorderSizePixel = 0,
    ZIndex = 20,
})

local TopLine = create("Frame",TopBar,{
    Position = UDim2.new(0,0,1,-1),
    Size = UDim2.new(1,0,0,1),
    BackgroundColor3 = CONFIG.Accent,
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
    ZIndex = 21,
})

local Logo = create("ImageLabel",TopBar,{
    Position = UDim2.fromOffset(18,15),
    Size = UDim2.fromOffset(48,48),
    BackgroundColor3 = CONFIG.Black,
    BackgroundTransparency = 0.1,
    Image = CONFIG.Logo,
    ScaleType = Enum.ScaleType.Crop,
    BorderSizePixel = 0,
})

corner(Logo,14)
stroke(Logo,CONFIG.Accent,1,0.3)

local Title = create("TextLabel",TopBar,{
    Position = UDim2.fromOffset(78,14),
    Size = UDim2.fromOffset(260,30),
    BackgroundTransparency = 1,
    Text = "Axomusc",
    TextColor3 = CONFIG.White,
    TextSize = 23,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local BetaBox = create("TextLabel",TopBar,{
    Position = UDim2.fromOffset(174,17),
    Size = UDim2.fromOffset(52,21),
    BackgroundColor3 = CONFIG.Accent,
    BackgroundTransparency = 0.83,
    Text = "BETA",
    TextColor3 = CONFIG.Accent,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
})

corner(BetaBox,7)
stroke(BetaBox,CONFIG.Accent,1,0.35)

local Subtitle = create("TextLabel",TopBar,{
    Position = UDim2.fromOffset(79,43),
    Size = UDim2.fromOffset(350,22),
    BackgroundTransparency = 1,
    Text = "By. Axolion Community (Beta)",
    TextColor3 = CONFIG.Muted,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local ExecutorLabel = create("TextLabel",TopBar,{
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-72,0,27),
    Size = UDim2.fromOffset(180,24),
    BackgroundTransparency = 1,
    Text = "SESSION • " .. Executor.Name,
    TextColor3 = CONFIG.Accent,
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Right,
})

--// close
local Close = create("TextButton",TopBar,{
    AnchorPoint = Vector2.new(1,0.5),
    Position = UDim2.new(1,-16,0.5,0),
    Size = UDim2.fromOffset(42,42),
    BackgroundColor3 = CONFIG.Panel2,
    BackgroundTransparency = 0.15,
    Text = "×",
    TextColor3 = CONFIG.White,
    TextSize = 25,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
})

corner(Close,12)
stroke(Close,CONFIG.Accent,1,0.78)

--// ================================================================
--// CONTENT ROOT
--// ================================================================

local Content = create("Frame",Main,{
    Position = UDim2.new(0,0,0,78),
    Size = UDim2.new(1,0,1,-78),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})

--// ================================================================
--// SIDEBAR
--// ================================================================

local Sidebar = create("Frame",Content,{
    Name = "Sidebar",
    Size = UDim2.fromOffset(220,572),
    BackgroundColor3 = CONFIG.Black,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

local SideStroke = stroke(Sidebar,CONFIG.Accent,1,0.75)

local SideHeader = create("TextLabel",Sidebar,{
    Position = UDim2.fromOffset(22,22),
    Size = UDim2.new(1,-44,0,22),
    BackgroundTransparency = 1,
    Text = "WORKSPACE",
    TextColor3 = CONFIG.Dim,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local SideLine = create("Frame",Sidebar,{
    Position = UDim2.fromOffset(22,50),
    Size = UDim2.new(1,-44,0,1),
    BackgroundColor3 = CONFIG.Accent,
    BackgroundTransparency = 0.75,
    BorderSizePixel = 0,
})

local NavContainer = create("Frame",Sidebar,{
    Position = UDim2.fromOffset(12,68),
    Size = UDim2.new(1,-24,0,205),
    BackgroundTransparency = 1,
})

list(NavContainer,Enum.FillDirection.Vertical,7)

local function navButton(text,icon)
    local b = create("TextButton",NavContainer,{
        Size = UDim2.new(1,0,0,52),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    })

    corner(b,12)

    local indicator = create("Frame",b,{
        Position = UDim2.new(0,0,0.5,-11),
        Size = UDim2.fromOffset(3,22),
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    corner(indicator,3)

    local ico = create("TextLabel",b,{
        Position = UDim2.fromOffset(15,0),
        Size = UDim2.fromOffset(27,52),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = CONFIG.Muted,
        TextSize = 18,
        Font = Enum.Font.GothamMedium,
    })

    local txt = create("TextLabel",b,{
        Position = UDim2.fromOffset(52,0),
        Size = UDim2.new(1,-60,1,0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CONFIG.Muted,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    return b,indicator,ico,txt
end

local MusicNav,MusicIndicator,MusicIcon,MusicText =
    navButton("Music Engine","♫")

local CommunityNav,CommunityIndicator,CommunityIcon,CommunityText =
    navButton("Axolion Community","◆")

local ExecutorCard = create("Frame",Sidebar,{
    AnchorPoint = Vector2.new(0,1),
    Position = UDim2.new(0,14,1,-14),
    Size = UDim2.new(1,-28,0,100),
    BackgroundColor3 = CONFIG.Panel2,
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
})

corner(ExecutorCard,14)
stroke(ExecutorCard,CONFIG.Accent,1,0.84)

local StatusDot = create("Frame",ExecutorCard,{
    Position = UDim2.fromOffset(15,18),
    Size = UDim2.fromOffset(9,9),
    BackgroundColor3 = CONFIG.Accent,
    BorderSizePixel = 0,
})

corner(StatusDot,9)

local SessionTitle = create("TextLabel",ExecutorCard,{
    Position = UDim2.fromOffset(32,11),
    Size = UDim2.new(1,-44,0,22),
    BackgroundTransparency = 1,
    Text = "Axomusc Session",
    TextColor3 = CONFIG.White,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local SessionText = create("TextLabel",ExecutorCard,{
    Position = UDim2.fromOffset(15,38),
    Size = UDim2.new(1,-30,0,40),
    BackgroundTransparency = 1,
    Text = Executor.Name .. "\nPersistent data: " ..
        (Executor.FileSystem and "ON" or "OFF"),
    TextColor3 = CONFIG.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
})

--// ================================================================
--// WORKSPACE
--// ================================================================

local Workspace = create("Frame",Content,{
    Position = UDim2.fromOffset(220,0),
    Size = UDim2.new(1,-220,1,0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})

--// ================================================================
--// TOAST SYSTEM
--// ================================================================

local ToastHolder = create("Frame",ScreenGui,{
    Name = "ToastHolder",
    AnchorPoint = Vector2.new(1,1),
    Position = UDim2.new(1,-22,1,-22),
    Size = UDim2.fromOffset(340,300),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 500,
})

list(ToastHolder,Enum.FillDirection.Vertical,8)

local function toast(title,text,icon)
    local item = create("Frame",ToastHolder,{
        Size = UDim2.fromOffset(340,65),
        BackgroundColor3 = CONFIG.Panel,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    corner(item,13)
    stroke(item,CONFIG.Accent,1,0.65)

    local bar = create("Frame",item,{
        Position = UDim2.fromOffset(0,0),
        Size = UDim2.fromOffset(3,65),
        BackgroundColor3 = CONFIG.Accent,
        BorderSizePixel = 0,
    })

    local iconLabel = create("TextLabel",item,{
        Position = UDim2.fromOffset(15,10),
        Size = UDim2.fromOffset(32,32),
        BackgroundTransparency = 1,
        Text = icon or "•",
        TextColor3 = CONFIG.Accent,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
    })

    local titleLabel = create("TextLabel",item,{
        Position = UDim2.fromOffset(53,8),
        Size = UDim2.new(1,-65,0,21),
        BackgroundTransparency = 1,
        Text = title or "Axomusc",
        TextColor3 = CONFIG.White,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local bodyLabel = create("TextLabel",item,{
        Position = UDim2.fromOffset(53,30),
        Size = UDim2.new(1,-65,0,25),
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = CONFIG.Muted,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })

    item.Position = UDim2.new(1,30,0,0)
    tween(item,0.35,{
        Position = UDim2.new(0,0,0,0)
    })

    task.delay(2.7,function()
        if item and item.Parent then
            tween(item,0.3,{
                BackgroundTransparency = 1,
                Position = UDim2.new(1,30,0,0)
            })
            task.wait(0.35)
            safeDestroy(item)
        end
    end)
end

--// ================================================================
--// RIPPLE
--// ================================================================

local function ripple(button)
    if not button or not button:IsA("GuiButton") then
        return
    end

    local mouse = UserInputService:GetMouseLocation()
    local absolute = button.AbsolutePosition
    local x = mouse.X - absolute.X
    local y = mouse.Y - absolute.Y

    local r = create("Frame",button,{
        Position = UDim2.fromOffset(x,y),
        AnchorPoint = Vector2.new(0.5,0.5),
        Size = UDim2.fromOffset(0,0),
        BackgroundColor3 = CONFIG.Accent,
        BackgroundTransparency = 0.68,
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 5,
    })

    corner(r,999)

    tween(r,0.45,{
        Size = UDim2.fromOffset(180,180),
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(x,y),
    })

    task.delay(0.5,function()
        safeDestroy(r)
    end)
end

--// ================================================================
--// BUTTON EFFECT
--// ================================================================

local function buttonFX(button,normal,hover)
    button.MouseEnter:Connect(function()
        tween(button,0.18,{
            BackgroundColor3 = hover or CONFIG.Panel2
        })
    end)

    button.MouseLeave:Connect(function()
        tween(button,0.18,{
            BackgroundColor3 = normal or CONFIG.Panel
        })
    end)

    button.MouseButton1Click:Connect(function()
        ripple(button)
    end)
end

buttonFX(Close,CONFIG.Panel2,Color3.fromRGB(24,35,54))

--// ================================================================
--// MUSIC ENGINE ROOT
--// ================================================================

local MusicPage = create("Frame",Workspace,{
    Name = "MusicEnginePage",
    Size = UDim2.fromScale(1,1),
    BackgroundTransparency = 1,
})

local CommunityPage = create("Frame",Workspace,{
    Name = "CommunityPage",
    Size = UDim2.fromScale(1,1),
    BackgroundTransparency = 1,
    Visible = false,
})

--// ================================================================
--// MUSIC HEADER
--// ================================================================

local MusicHeader = create("Frame",MusicPage,{
    Position = UDim2.fromOffset(20,16),
    Size = UDim2.new(1,-40,0,60),
    BackgroundTransparency = 1,
})

local MusicHeaderTitle = create("TextLabel",MusicHeader,{
    Position = UDim2.fromOffset(0,0),
    Size = UDim2.new(0.5,0,0,28),
    BackgroundTransparency = 1,
    Text = "Music Engine",
    TextColor3 = CONFIG.White,
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local MusicHeaderSub = create("TextLabel",MusicHeader,{
    Position = UDim2.fromOffset(0,30),
    Size = UDim2.new(0.6,0,0,20),
    BackgroundTransparency = 1,
    Text = "Professional audio workspace",
    TextColor3 = CONFIG.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

--// Search ID
local SearchBox = create("TextBox",MusicHeader,{
    AnchorPoint = Vector2.new(1,0.5),
    Position = UDim2.new(1,-5,0.5,0),
    Size = UDim2.fromOffset(270,38),
    BackgroundColor3 = CONFIG.Panel2,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    PlaceholderText = "Search Roblox Music ID...",
    PlaceholderColor3 = CONFIG.Dim,
    Text = "",
    TextColor3 = CONFIG.White,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    ClearTextOnFocus = false,
})

corner(SearchBox,11)
stroke(SearchBox,CONFIG.Accent,1,0.65)
padding(SearchBox,14,12,0,0)

--// ================================================================
--// MUSIC BODY
--// ================================================================

local MusicBody = create("Frame",MusicPage,{
    Position = UDim2.fromOffset(20,88),
    Size = UDim2.new(1,-40,1,-105),
    BackgroundTransparency = 1,
})

--// ================================================================
--// LEFT AUDIO LIBRARY
--// ================================================================

local LibraryPanel = create("Frame",MusicBody,{
    Position = UDim2.fromOffset(0,0),
    Size = UDim2.fromOffset(205,460),
    BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})

corner(LibraryPanel,16)
stroke(LibraryPanel,CONFIG.Accent,1,0.77)

local LibraryTitle = create("TextLabel",LibraryPanel,{
    Position = UDim2.fromOffset(17,14),
    Size = UDim2.new(1,-34,0,22),
    BackgroundTransparency = 1,
    Text = "AUDIO LIBRARY",
    TextColor3 = CONFIG.White,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local LibrarySub = create("TextLabel",LibraryPanel,{
    Position = UDim2.fromOffset(17,36),
    Size = UDim2.new(1,-34,0,20),
    BackgroundTransparency = 1,
    Text = "Folders & saved audio",
    TextColor3 = CONFIG.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local LibrarySearch = create("TextBox",LibraryPanel,{
    Position = UDim2.fromOffset(12,65),
    Size = UDim2.new(1,-24,0,35),
    BackgroundColor3 = CONFIG.Black,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    PlaceholderText = "Search library...",
    PlaceholderColor3 = CONFIG.Dim,
    Text = "",
    TextColor3 = CONFIG.White,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
})

corner(LibrarySearch,10)
stroke(LibrarySearch,CONFIG.Accent,1,0.85)
padding(LibrarySearch,11,10,0,0)

local FolderContainer = create("ScrollingFrame",LibraryPanel,{
    Position = UDim2.fromOffset(10,110),
    Size = UDim2.new(1,-20,1,-120),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = CONFIG.Accent,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
})

list(FolderContainer,Enum.FillDirection.Vertical,6)

local function folderButton(name,icon)
    local b = create("TextButton",FolderContainer,{
        Size = UDim2.new(1,0,0,43),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.45,
        Text = "",
        AutoButtonColor = false,
    })

    corner(b,10)

    local ico = create("TextLabel",b,{
        Position = UDim2.fromOffset(12,0),
        Size = UDim2.fromOffset(25,43),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = CONFIG.Accent,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
    })

    local label = create("TextLabel",b,{
        Position = UDim2.fromOffset(44,0),
        Size = UDim2.new(1,-52,1,0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = CONFIG.Muted,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    buttonFX(b,CONFIG.Panel2,Color3.fromRGB(17,31,46))

    return b,label
end

local AllFolder = folderButton("All Audio","♫")
local FavoritesFolder = folderButton("Favorites","★")
local SavedFolder = folderButton("Saved Tracks","▣")
local SystemFolder = folderButton("System Audio","◆")

--// ================================================================
--// CENTER PLAYER
--// ================================================================

local PlayerPanel = create("Frame",MusicBody,{
    Position = UDim2.fromOffset(215,0),
    Size = UDim2.new(1,-430,1,0),
    BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = 0.045,
    BorderSizePixel = 0,
})

corner(PlayerPanel,18)
stroke(PlayerPanel,CONFIG.Accent,1,0.72)

local PlayerTop = create("TextLabel",PlayerPanel,{
    Position = UDim2.fromOffset(18,15),
    Size = UDim2.new(1,-36,0,20),
    BackgroundTransparency = 1,
    Text = "NOW PLAYING",
    TextColor3 = CONFIG.Accent,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local AlbumHolder = create("Frame",PlayerPanel,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,45),
    Size = UDim2.fromOffset(230,230),
    BackgroundColor3 = CONFIG.Black,
    BorderSizePixel = 0,
})

corner(AlbumHolder,24)
stroke(AlbumHolder,CONFIG.Accent,1.5,0.42)

local AlbumGlow = create("Frame",AlbumHolder,{
    Position = UDim2.fromOffset(7,7),
    Size = UDim2.new(1,-14,1,-14),
    BackgroundColor3 = CONFIG.Accent,
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
})

corner(AlbumGlow,20)

local AlbumArt = create("ImageLabel",AlbumHolder,{
    Position = UDim2.fromOffset(12,12),
    Size = UDim2.new(1,-24,1,-24),
    BackgroundColor3 = CONFIG.Black,
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Image = CONFIG.Thumbnail,
    ScaleType = Enum.ScaleType.Crop,
})

corner(AlbumArt,18)

local AlbumGradient = gradient(
    AlbumArt,
    Color3.fromRGB(10,30,48),
    Color3.fromRGB(2,8,19),
    135
)

local TrackTitle = create("TextLabel",PlayerPanel,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,287),
    Size = UDim2.new(1,-50,0,30),
    BackgroundTransparency = 1,
    Text = "Axomusc Theme",
    TextColor3 = CONFIG.White,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextTruncate = Enum.TextTruncate.AtEnd,
})

local TrackID = create("TextLabel",PlayerPanel,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,316),
    Size = UDim2.new(1,-50,0,20),
    BackgroundTransparency = 1,
    Text = "No Roblox audio loaded",
    TextColor3 = CONFIG.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Center,
})

local ProgressBack = create("Frame",PlayerPanel,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,347),
    Size = UDim2.new(1,-70,0,5),
    BackgroundColor3 = CONFIG.Black,
    BorderSizePixel = 0,
})

corner(ProgressBack,5)

local ProgressFill = create("Frame",ProgressBack,{
    Size = UDim2.new(0,0,1,0),
    BackgroundColor3 = CONFIG.Accent,
    BorderSizePixel = 0,
})

corner(ProgressFill,5)

local TimeLabel = create("TextLabel",PlayerPanel,{
    Position = UDim2.fromOffset(30,358),
    Size = UDim2.fromOffset(55,18),
    BackgroundTransparency = 1,
    Text = "0:00",
    TextColor3 = CONFIG.Dim,
    TextSize = 8,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local DurationLabel = create("TextLabel",PlayerPanel,{
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-30,0,358),
    Size = UDim2.fromOffset(55,18),
    BackgroundTransparency = 1,
    Text = "0:00",
    TextColor3 = CONFIG.Dim,
    TextSize = 8,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Right,
})

--// controls
local Controls = create("Frame",PlayerPanel,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,380),
    Size = UDim2.fromOffset(300,48),
    BackgroundTransparency = 1,
})

local function controlButton(parent,text,size)
    local b = create("TextButton",parent,{
        Size = UDim2.fromOffset(size or 42,42),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = CONFIG.White,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    })

    corner(b,13)
    stroke(b,CONFIG.Accent,1,0.8)
    buttonFX(b,CONFIG.Panel2,Color3.fromRGB(20,40,52))

    return b
end

local RepeatButton = controlButton(Controls,"↻",42)
local PreviousButton = controlButton(Controls,"‹",42)

local PlayButton = controlButton(Controls,"▶",54)
PlayButton.BackgroundColor3 = CONFIG.Accent
PlayButton.TextColor3 = CONFIG.Black
stroke(PlayButton,CONFIG.Accent,1,0.15)

local NextButton = controlButton(Controls,"›",42)
local ShuffleButton = controlButton(Controls,"⌘",42)

local ControlLayout = list(Controls,Enum.FillDirection.Horizontal,10)
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local RepeatActive = false
local ShuffleActive = false

--// volume
local VolumeLabel = create("TextLabel",PlayerPanel,{
    Position = UDim2.fromOffset(25,442),
    Size = UDim2.fromOffset(70,18),
    BackgroundTransparency = 1,
    Text = "VOLUME",
    TextColor3 = CONFIG.Muted,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
})

local VolumeValue = create("TextLabel",PlayerPanel,{
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-25,0,442),
    Size = UDim2.fromOffset(55,18),
    BackgroundTransparency = 1,
    Text = tostring(Saved.Settings.Volume) .. "%",
    TextColor3 = CONFIG.Accent,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
})

local VolumeBack = create("TextButton",PlayerPanel,{
    Position = UDim2.fromOffset(25,465),
    Size = UDim2.new(1,-50,0,7),
    BackgroundColor3 = CONFIG.Black,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
})

corner(VolumeBack,7)

local VolumeFill = create("Frame",VolumeBack,{
    Size = UDim2.new(Saved.Settings.Volume/100,0,1,0),
    BackgroundColor3 = CONFIG.Accent,
    BorderSizePixel = 0,
})

corner(VolumeFill,7)

--// ================================================================
--// RIGHT PLAYLIST
--// ================================================================

local PlaylistPanel = create("Frame",MusicBody,{
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,0,0,0),
    Size = UDim2.fromOffset(205,460),
    BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
})

corner(PlaylistPanel,16)
stroke(PlaylistPanel,CONFIG.Accent,1,0.77)

local PlaylistTitle = create("TextLabel",PlaylistPanel,{
    Position = UDim2.fromOffset(17,14),
    Size = UDim2.new(1,-34,0,22),
    BackgroundTransparency = 1,
    Text = "PLAYLIST",
    TextColor3 = CONFIG.White,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local PlaylistSub = create("TextLabel",PlaylistPanel,{
    Position = UDim2.fromOffset(17,36),
    Size = UDim2.new(1,-34,0,20),
    BackgroundTransparency = 1,
    Text = "Current queue",
    TextColor3 = CONFIG.Muted,
    TextSize = 9,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local PlaylistList = create("ScrollingFrame",PlaylistPanel,{
    Position = UDim2.fromOffset(10,68),
    Size = UDim2.new(1,-20,1,-78),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = CONFIG.Accent,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
})

list(PlaylistList,Enum.FillDirection.Vertical,6)

--// ================================================================
--// MUSIC DATA
--// ================================================================

local Tracks = {}

local function normalizeTrack(track)
    if type(track) ~= "table" then
        return nil
    end

    local id = tostring(track.Id or "")
    id = id:gsub("%D","")

    if id == "" then
        return nil
    end

    return {
        Id = id,
        Name = tostring(track.Name or ("Roblox Audio " .. id)),
        Creator = tostring(track.Creator or "Unknown"),
        Favorite = track.Favorite == true,
    }
end

for _,track in ipairs(Saved.Tracks) do
    local t = normalizeTrack(track)
    if t then
        Tracks[#Tracks+1] = t
    end
end

local function isFavorite(id)
    id = tostring(id)

    for _,v in ipairs(Saved.Favorites) do
        if tostring(v) == id then
            return true
        end
    end

    return false
end

local function setFavorite(id,value)
    id = tostring(id)

    local found = nil

    for i,v in ipairs(Saved.Favorites) do
        if tostring(v) == id then
            found = i
            break
        end
    end

    if value and not found then
        table.insert(Saved.Favorites,id)
    elseif not value and found then
        table.remove(Saved.Favorites,found)
    end

    for _,track in ipairs(Tracks) do
        if track.Id == id then
            track.Favorite = value
        end
    end

    persist()
end

local function addTrack(track)
    track = normalizeTrack(track)
    if not track then
        return false
    end

    for _,v in ipairs(Tracks) do
        if v.Id == track.Id then
            return false
        end
    end

    track.Favorite = isFavorite(track.Id)

    table.insert(Tracks,track)

    Saved.Tracks = Tracks

    persist()

    return true
end

local function removeTrack(id)
    id = tostring(id)

    for i = #Tracks,1,-1 do
        if Tracks[i].Id == id then
            table.remove(Tracks,i)
        end
    end

    Saved.Tracks = Tracks
    persist()
end

--// ================================================================
--// SOUND ENGINE
--// ================================================================

local CurrentIndex = 0
local CurrentTrack = nil
local CurrentSound = nil

local Equalizer

pcall(function()
    Equalizer = SoundService:FindFirstChild("AxomuscEqualizer")
end)

if not Equalizer then
    Equalizer = create("EqualizerSoundEffect",SoundService,{
        Name = "AxomuscEqualizer",
        HighGain = 0,
        MidGain = 0,
        LowGain = 0,
    })
end

local function destroySound()
    if CurrentSound then
        safeDestroy(CurrentSound)
        CurrentSound = nil
    end
end

local function formatTime(sec)
    sec = math.max(0,math.floor(tonumber(sec) or 0))
    local minutes = math.floor(sec/60)
    local seconds = sec%60
    return string.format("%d:%02d",minutes,seconds)
end

local function updateProgress()
    if not CurrentSound or not CurrentSound.Parent then
        return
    end

    local length = CurrentSound.TimeLength
    local position = CurrentSound.TimePosition

    if length and length > 0 then
        ProgressFill.Size = UDim2.new(
            math.clamp(position/length,0,1),
            0,
            1,
            0
        )

        TimeLabel.Text = formatTime(position)
        DurationLabel.Text = formatTime(length)
    else
        ProgressFill.Size = UDim2.new(0,0,1,0)
        TimeLabel.Text = "0:00"
        DurationLabel.Text = "0:00"
    end
end

local function updatePlayerLabels()
    if CurrentTrack then
        TrackTitle.Text = CurrentTrack.Name
        TrackID.Text = "Roblox Audio ID • " .. tostring(CurrentTrack.Id)
    else
        TrackTitle.Text = "Axomusc Theme"
        TrackID.Text = "No Roblox audio loaded"
    end
end

local function setVolume(value)
    value = clampNumber(value,1,100)

    Saved.Settings.Volume = value
    VolumeFill.Size = UDim2.new(value/100,0,1,0)
    VolumeValue.Text = tostring(math.floor(value)) .. "%"

    if CurrentSound then
        CurrentSound.Volume = value/100
    end

    persist()
end

local function setSpeed(value)
    value = tonumber(value) or 1

    if CurrentSound then
        CurrentSound.PlaybackSpeed = value
    end

    Saved.Settings.Speed = value
    persist()
end

local function createPlaylistItem(track,index)
    local item = create("Frame",PlaylistList,{
        Size = UDim2.new(1,0,0,54),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
    })

    corner(item,11)

    local number = create("TextLabel",item,{
        Position = UDim2.fromOffset(10,0),
        Size = UDim2.fromOffset(20,54),
        BackgroundTransparency = 1,
        Text = tostring(index),
        TextColor3 = CONFIG.Accent,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
    })

    local name = create("TextLabel",item,{
        Position = UDim2.fromOffset(35,8),
        Size = UDim2.new(1,-72,0,20),
        BackgroundTransparency = 1,
        Text = track.Name,
        TextColor3 = CONFIG.White,
        TextSize = 9,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local id = create("TextLabel",item,{
        Position = UDim2.fromOffset(35,29),
        Size = UDim2.new(1,-72,0,16),
        BackgroundTransparency = 1,
        Text = track.Id,
        TextColor3 = CONFIG.Dim,
        TextSize = 7,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local play = create("TextButton",item,{
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-9,0.5,0),
        Size = UDim2.fromOffset(30,30),
        BackgroundColor3 = CONFIG.Black,
        BackgroundTransparency = 0.2,
        Text = "▶",
        TextColor3 = CONFIG.Accent,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    })

    corner(play,9)
    buttonFX(play,CONFIG.Black,Color3.fromRGB(17,35,43))

    play.MouseButton1Click:Connect(function()
        ripple(play)
        CurrentIndex = index
        CurrentTrack = track

        toast(
            "Track Selected",
            track.Name,
            "♫"
        )

        -- play function defined later
    end)

    item.MouseEnter:Connect(function()
        tween(item,0.15,{
            BackgroundTransparency = 0.08
        })
    end)

    item.MouseLeave:Connect(function()
        tween(item,0.15,{
            BackgroundTransparency = 0.3
        })
    end)

    return item
end

local function rebuildPlaylist()
    for _,v in ipairs(PlaylistList:GetChildren()) do
        if v:IsA("Frame") then
            safeDestroy(v)
        end
    end

    for i,track in ipairs(Tracks) do
        createPlaylistItem(track,i)
    end
end

--// ================================================================
--// SEARCH RESULT PANEL
--// ================================================================

local SearchResults = create("Frame",MusicPage,{
    Position = UDim2.fromOffset(590,78),
    Size = UDim2.fromOffset(270,0),
    BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 100,
})

corner(SearchResults,13)
stroke(SearchResults,CONFIG.Accent,1,0.45)

local SearchResultTitle = create("TextLabel",SearchResults,{
    Position = UDim2.fromOffset(13,10),
    Size = UDim2.new(1,-26,0,20),
    BackgroundTransparency = 1,
    Text = "ROBLOX AUDIO",
    TextColor3 = CONFIG.Accent,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local SearchResultName = create("TextLabel",SearchResults,{
    Position = UDim2.fromOffset(13,35),
    Size = UDim2.new(1,-26,0,40),
    BackgroundTransparency = 1,
    Text = "Enter an audio ID",
    TextColor3 = CONFIG.White,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextWrapped = true,
})

local SearchResultCreator = create("TextLabel",SearchResults,{
    Position = UDim2.fromOffset(13,77),
    Size = UDim2.new(1,-26,0,20),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = CONFIG.Muted,
    TextSize = 8,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local SearchAdd = create("TextButton",SearchResults,{
    Position = UDim2.fromOffset(13,106),
    Size = UDim2.new(1,-26,0,35),
    BackgroundColor3 = CONFIG.Accent,
    Text = "ADD TO LIBRARY",
    TextColor3 = CONFIG.Black,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
})

corner(SearchAdd,9)

local SearchPlay = create("TextButton",SearchResults,{
    Position = UDim2.fromOffset(13,148),
    Size = UDim2.new(1,-26,0,35),
    BackgroundColor3 = CONFIG.Panel2,
    Text = "PLAY NOW",
    TextColor3 = CONFIG.White,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
})

corner(SearchPlay,9)
stroke(SearchPlay,CONFIG.Accent,1,0.65)

buttonFX(SearchAdd,CONFIG.Accent,Color3.fromRGB(68,239,218))
buttonFX(SearchPlay,CONFIG.Panel2,Color3.fromRGB(21,38,53))

local SearchTrack = nil

local function showSearchPanel(show)
    SearchResults.Visible = show

    if show then
        SearchResults.Size = UDim2.fromOffset(270,0)

        tween(SearchResults,0.25,{
            Size = UDim2.fromOffset(270,195)
        })
    else
        tween(SearchResults,0.2,{
            Size = UDim2.fromOffset(270,0)
        })

        task.delay(0.22,function()
            if SearchResults.Size.Y.Offset <= 1 then
                SearchResults.Visible = false
            end
        end)
    end
end

local function searchMusicId()
    local raw = tostring(SearchBox.Text or "")
    local id = raw:match("%d+")

    if not id then
        SearchResultName.Text = "Invalid Roblox Audio ID"
        SearchResultCreator.Text = "Use numeric asset ID"
        SearchTrack = nil
        showSearchPanel(true)

        toast(
            "Search Failed",
            "Masukkan Roblox Music ID yang valid.",
            "!"
        )

        return
    end

    SearchResultName.Text = "Loading..."
    SearchResultCreator.Text = "Checking Roblox asset..."
    SearchTrack = nil
    showSearchPanel(true)

    task.spawn(function()
        local info

        pcall(function()
            info = MarketplaceService:GetProductInfo(
                tonumber(id),
                Enum.InfoType.Asset
            )
        end)

        if info then
            local assetType = tostring(info.AssetTypeId or "")

            local name = tostring(info.Name or ("Roblox Audio " .. id))
            local creator = "Unknown"

            if type(info.Creator) == "table" then
                creator = tostring(info.Creator.Name or "Unknown")
            end

            SearchResultName.Text = name
            SearchResultCreator.Text =
                "ID " .. id .. " • " .. creator

            SearchTrack = {
                Id = id,
                Name = name,
                Creator = creator,
            }

            toast(
                "Search Complete",
                name,
                "⌕"
            )
        else
            SearchResultName.Text = "Audio information unavailable"
            SearchResultCreator.Text =
                "Asset may be private, deleted, or unavailable."

            SearchTrack = {
                Id = id,
                Name = "Roblox Audio " .. id,
                Creator = "Unknown",
            }

            toast(
                "ID Found",
                "Metadata tidak tersedia, tetapi ID dapat dicoba diputar.",
                "♫"
            )
        end
    end)
end

SearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        searchMusicId()
    end
end)

--// ================================================================
--// PLAY FUNCTION
--// ================================================================

local function playTrack(track)
    track = normalizeTrack(track)

    if not track then
        toast(
            "Playback Error",
            "Track tidak valid.",
            "!"
        )
        return
    end

    destroySound()

    CurrentTrack = track

    for i,v in ipairs(Tracks) do
        if v.Id == track.Id then
            CurrentIndex = i
            break
        end
    end

    local sound = create("Sound",SoundService,{
        Name = "Axomusc_CurrentTrack",
        SoundId = "rbxassetid://" .. track.Id,
        Volume = Saved.Settings.Volume / 100,
        PlaybackSpeed = Saved.Settings.Speed,
        Looped = false,
        RollOffMaxDistance = 10000,
    })

    CurrentSound = sound

    pcall(function()
        Equalizer.Parent = sound
    end)

    updatePlayerLabels()

    PlayButton.Text = "Ⅱ"

    local loadedConnection

    loadedConnection = sound.Loaded:Connect(function()
        safeDisconnect(loadedConnection)

        pcall(function()
            sound:Play()
        end)

        toast(
            "Now Playing",
            track.Name,
            "♫"
        )
    end)

    sound.Ended:Connect(function()
        if RepeatActive then
            playTrack(track)
            return
        end

        if ShuffleActive and #Tracks > 1 then
            local nextIndex = math.random(1,#Tracks)

            if nextIndex == CurrentIndex then
                nextIndex = (nextIndex % #Tracks) + 1
            end

            CurrentIndex = nextIndex
        else
            CurrentIndex = CurrentIndex + 1

            if CurrentIndex > #Tracks then
                CurrentIndex = 1
            end
        end

        local nextTrack = Tracks[CurrentIndex]

        if nextTrack then
            playTrack(nextTrack)
        else
            PlayButton.Text = "▶"
        end
    end)

    task.spawn(function()
        task.wait(1.5)

        if CurrentSound == sound then
            pcall(function()
                sound:Play()
            end)

            toast(
                "Playing",
                track.Name,
                "▶"
            )
        end
    end)
end

local function togglePlay()
    if not CurrentSound then
        if #Tracks > 0 then
            if CurrentIndex <= 0 then
                CurrentIndex = 1
            end

            playTrack(Tracks[CurrentIndex])
        else
            toast(
                "Library Empty",
                "Search Music ID terlebih dahulu.",
                "♫"
            )
        end

        return
    end

    if CurrentSound.IsPlaying then
        CurrentSound:Pause()
        PlayButton.Text = "▶"

        toast(
            "Paused",
            CurrentTrack and CurrentTrack.Name or "Current track",
            "Ⅱ"
        )
    else
        CurrentSound:Resume()
        PlayButton.Text = "Ⅱ"

        toast(
            "Playing",
            CurrentTrack and CurrentTrack.Name or "Current track",
            "▶"
        )
    end
end

local function nextTrack()
    if #Tracks == 0 then
        toast("Playlist Empty","Tambahkan audio terlebih dahulu.","♫")
        return
    end

    if ShuffleActive then
        CurrentIndex = math.random(1,#Tracks)
    else
        CurrentIndex += 1
        if CurrentIndex > #Tracks then
            CurrentIndex = 1
        end
    end

    playTrack(Tracks[CurrentIndex])
end

local function previousTrack()
    if #Tracks == 0 then
        toast("Playlist Empty","Tidak ada track.","♫")
        return
    end

    if CurrentSound and CurrentSound.TimePosition > 4 then
        CurrentSound.TimePosition = 0
        return
    end

    CurrentIndex -= 1

    if CurrentIndex < 1 then
        CurrentIndex = #Tracks
    end

    playTrack(Tracks[CurrentIndex])
end

PlayButton.MouseButton1Click:Connect(function()
    ripple(PlayButton)
    togglePlay()
end)

NextButton.MouseButton1Click:Connect(function()
    ripple(NextButton)
    nextTrack()
end)

PreviousButton.MouseButton1Click:Connect(function()
    ripple(PreviousButton)
    previousTrack()
end)

RepeatButton.MouseButton1Click:Connect(function()
    ripple(RepeatButton)

    RepeatActive = not RepeatActive

    tween(RepeatButton,0.18,{
        BackgroundColor3 = RepeatActive
            and CONFIG.Accent
            or CONFIG.Panel2
    })

    RepeatButton.TextColor3 =
        RepeatActive and CONFIG.Black or CONFIG.White

    toast(
        "Repeat",
        RepeatActive and "Repeat aktif." or "Repeat dimatikan.",
        "↻"
    )
end)

ShuffleButton.MouseButton1Click:Connect(function()
    ripple(ShuffleButton)

    ShuffleActive = not ShuffleActive

    tween(ShuffleButton,0.18,{
        BackgroundColor3 = ShuffleActive
            and CONFIG.Accent
            or CONFIG.Panel2
    })

    ShuffleButton.TextColor3 =
        ShuffleActive and CONFIG.Black or CONFIG.White

    toast(
        "Shuffle",
        ShuffleActive and "Shuffle aktif." or "Shuffle dimatikan.",
        "⌘"
    )
end)

--// ================================================================
--// VOLUME SLIDER
--// ================================================================

local draggingVolume = false

local function updateVolumeFromX(x)
    local left = VolumeBack.AbsolutePosition.X
    local width = VolumeBack.AbsoluteSize.X

    local amount = math.clamp(
        (x-left)/math.max(width,1),
        0,
        1
    )

    setVolume(math.floor(amount*100))
end

VolumeBack.MouseButton1Down:Connect(function(x)
    draggingVolume = true
    updateVolumeFromX(x)
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingVolume and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateVolumeFromX(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingVolume = false
    end
end)

--// ================================================================
--// PLAYLIST ADD
--// ================================================================

SearchAdd.MouseButton1Click:Connect(function()
    ripple(SearchAdd)

    if not SearchTrack then
        toast(
            "No Result",
            "Cari Music ID terlebih dahulu.",
            "!"
        )
        return
    end

    if addTrack(SearchTrack) then
        rebuildPlaylist()

        toast(
            "Saved",
            SearchTrack.Name .. " masuk ke Audio Library.",
            "✓"
        )
    else
        toast(
            "Already Saved",
            "Track tersebut sudah ada.",
            "!"
        )
    end
end)

SearchPlay.MouseButton1Click:Connect(function()
    ripple(SearchPlay)

    if SearchTrack then
        playTrack(SearchTrack)
        showSearchPanel(false)
    else
        toast(
            "No Track",
            "Belum ada audio yang ditemukan.",
            "!"
        )
    end
end)

--// ================================================================
--// SEARCH LIBRARY FILTER
--// ================================================================

local function refreshFolder(folderType)
    for _,v in ipairs(PlaylistList:GetChildren()) do
        if v:IsA("Frame") then
            safeDestroy(v)
        end
    end

    local source = {}

    if folderType == "favorites" then
        for _,track in ipairs(Tracks) do
            if isFavorite(track.Id) then
                source[#source+1] = track
            end
        end
    elseif folderType == "saved" then
        source = Tracks
    elseif folderType == "system" then
        source = {}
    else
        source = Tracks
    end

    for i,track in ipairs(source) do
        createPlaylistItem(track,i)
    end
end

AllFolder.MouseButton1Click:Connect(function()
    ripple(AllFolder)
    refreshFolder("all")
    toast("Audio Library","Menampilkan semua track.","♫")
end)

FavoritesFolder.MouseButton1Click:Connect(function()
    ripple(FavoritesFolder)
    refreshFolder("favorites")
    toast("Favorites","Menampilkan track favorit.","★")
end)

SavedFolder.MouseButton1Click:Connect(function()
    ripple(SavedFolder)
    refreshFolder("saved")
    toast("Saved Tracks","Menampilkan track tersimpan.","▣")
end)

SystemFolder.MouseButton1Click:Connect(function()
    ripple(SystemFolder)
    refreshFolder("system")
    toast("System Audio","Folder system siap digunakan.","◆")
end)

LibrarySearch:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(LibrarySearch.Text or "")

    for _,v in ipairs(PlaylistList:GetChildren()) do
        if v:IsA("Frame") then
            safeDestroy(v)
        end
    end

    for i,track in ipairs(Tracks) do
        if query == ""
        or string.find(string.lower(track.Name),query,1,true)
        or string.find(string.lower(track.Id),query,1,true)
        then
            createPlaylistItem(track,i)
        end
    end
end)

--// ================================================================
--// COMMUNITY PAGE
--// ================================================================

local CommunityHeader = create("Frame",CommunityPage,{
    Position = UDim2.fromOffset(20,16),
    Size = UDim2.new(1,-40,0,65),
    BackgroundTransparency = 1,
})

local CommunityTitle = create("TextLabel",CommunityHeader,{
    Position = UDim2.fromOffset(0,0),
    Size = UDim2.new(1,0,0,28),
    BackgroundTransparency = 1,
    Text = "Axolion Community",
    TextColor3 = CONFIG.White,
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local CommunitySubtitle = create("TextLabel",CommunityHeader,{
    Position = UDim2.fromOffset(0,31),
    Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1,
    Text = "Community information & official links",
    TextColor3 = CONFIG.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local CommunityCard = create("Frame",CommunityPage,{
    Position = UDim2.fromOffset(20,95),
    Size = UDim2.new(1,-40,0,400),
    BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = 0.035,
    BorderSizePixel = 0,
})

corner(CommunityCard,20)
stroke(CommunityCard,CONFIG.Accent,1.2,0.52)

local CommunityLogo = create("ImageLabel",CommunityCard,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,28),
    Size = UDim2.fromOffset(112,112),
    BackgroundColor3 = CONFIG.Black,
    BorderSizePixel = 0,
    Image = CONFIG.SubLogo,
    ScaleType = Enum.ScaleType.Crop,
})

corner(CommunityLogo,22)
stroke(CommunityLogo,CONFIG.Accent,1.5,0.35)

local CommunityName = create("TextLabel",CommunityCard,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,153),
    Size = UDim2.new(1,-40,0,30),
    BackgroundTransparency = 1,
    Text = "Axolion Community (Beta)",
    TextColor3 = CONFIG.White,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center,
})

local CommunityInfo = create("TextLabel",CommunityCard,{
    AnchorPoint = Vector2.new(0.5,0),
    Position = UDim2.new(0.5,0,0,190),
    Size = UDim2.new(1,-100,0,60),
    BackgroundTransparency = 1,
    Text = "Axomusc adalah music interface premium dengan tema Dark Blue, Tosca Green, Ice Blue, Black dan White.",
    TextColor3 = CONFIG.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Center,
})

local DiscordButton = create("TextButton",CommunityCard,{
    Position = UDim2.fromOffset(70,275),
    Size = UDim2.new(0.5,-85,0,48),
    BackgroundColor3 = CONFIG.Panel2,
    BorderSizePixel = 0,
    Text = "COPY DISCORD",
    TextColor3 = CONFIG.White,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
})

corner(DiscordButton,12)
stroke(DiscordButton,CONFIG.Accent,1,0.55)
buttonFX(DiscordButton,CONFIG.Panel2,Color3.fromRGB(18,39,48))

local CommunityButton = create("TextButton",CommunityCard,{
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-70,0,275),
    Size = UDim2.new(0.5,-85,0,48),
    BackgroundColor3 = CONFIG.Accent,
    BorderSizePixel = 0,
    Text = "COPY COMMUNITY",
    TextColor3 = CONFIG.Black,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
})

corner(CommunityButton,12)
buttonFX(CommunityButton,CONFIG.Accent,Color3.fromRGB(72,239,218))

local CommunityFooter = create("TextLabel",CommunityCard,{
    AnchorPoint = Vector2.new(0.5,1),
    Position = UDim2.new(0.5,0,1,-22),
    Size = UDim2.new(1,-40,0,22),
    BackgroundTransparency = 1,
    Text = "AXOMUSC • PREMIUM CORE",
    TextColor3 = CONFIG.Accent,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center,
})

--// ================================================================
--// CLIPBOARD
--// ================================================================

local function copyText(value,name)
    local success = false

    if Executor.Clipboard then
        success = pcall(function()
            setclipboard(value)
        end)
    end

    if success then
        toast(
            "Link Copied",
            name .. " berhasil disalin.",
            "✓"
        )
    else
        toast(
            "Clipboard Unavailable",
            name .. " tidak dapat disalin pada executor ini.",
            "!"
        )
    end
end

DiscordButton.MouseButton1Click:Connect(function()
    ripple(DiscordButton)
    copyText(CONFIG.Discord,"Discord Link")
end)

CommunityButton.MouseButton1Click:Connect(function()
    ripple(CommunityButton)
    copyText(CONFIG.CommunityLink,"Community Link")
end)

--// ================================================================
--// NAVIGATION
--// ================================================================

local currentPage = "music"

local function activateNav(
    active,
    activeIndicator,
    activeIcon,
    activeText,
    otherIndicator,
    otherIcon,
    otherText
)
    tween(active,0.2,{
        BackgroundTransparency = 0.05
    })

    tween(activeIndicator,0.2,{
        BackgroundTransparency = 0
    })

    tween(activeIcon,0.2,{
        TextColor3 = CONFIG.Accent
    })

    tween(activeText,0.2,{
        TextColor3 = CONFIG.White
    })

    tween(otherIndicator,0.2,{
        BackgroundTransparency = 1
    })

    tween(otherIcon,0.2,{
        TextColor3 = CONFIG.Muted
    })

    tween(otherText,0.2,{
        TextColor3 = CONFIG.Muted
    })
end

activateNav(
    MusicNav,
    MusicIndicator,
    MusicIcon,
    MusicText,
    CommunityIndicator,
    CommunityIcon,
    CommunityText
)

MusicNav.MouseButton1Click:Connect(function()
    ripple(MusicNav)

    if currentPage == "music" then
        toast(
            "Music Engine",
            "Music workspace sudah aktif.",
            "♫"
        )
        return
    end

    currentPage = "music"

    CommunityPage.Visible = false
    MusicPage.Visible = true

    activateNav(
        MusicNav,
        MusicIndicator,
        MusicIcon,
        MusicText,
        CommunityIndicator,
        CommunityIcon,
        CommunityText
    )

    toast(
        "Music Engine",
        "Music workspace dibuka.",
        "♫"
    )
end)

CommunityNav.MouseButton1Click:Connect(function()
    ripple(CommunityNav)

    if currentPage == "community" then
        toast(
            "Axolion Community",
            "Community workspace sudah aktif.",
            "◆"
        )
        return
    end

    currentPage = "community"

    MusicPage.Visible = false
    CommunityPage.Visible = true

    activateNav(
        CommunityNav,
        CommunityIndicator,
        CommunityIcon,
        CommunityText,
        MusicIndicator,
        MusicIcon,
        MusicText
    )

    toast(
        "Axolion Community",
        "Community workspace dibuka.",
        "◆"
    )
end)

--// ================================================================
--// DRAG SYSTEM
--// ================================================================

local dragging = false
local dragStart
local startPosition
local dragInput

local function updateDrag(input)
    if not dragging then
        return
    end

    local delta = input.Position - dragStart

    local newPosition = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

    local viewport = workspace.CurrentCamera
        and workspace.CurrentCamera.ViewportSize
        or Vector2.new(1920,1080)

    local absolute = Main.AbsoluteSize

    local x = math.clamp(
        newPosition.X.Offset,
        -(viewport.X/2) + 60,
        (viewport.X/2) - 60
    )

    local y = math.clamp(
        newPosition.Y.Offset,
        -(viewport.Y/2) + 70,
        (viewport.Y/2) - 70
    )

    tween(Main,0.08,{
        Position = UDim2.new(
            0.5,
            x,
            0.5,
            y
        )
    })
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
        dragInput = input

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch
    then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateDrag(input)
    elseif dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

--// ================================================================
--// MINIMIZE BUBBLE
--// ================================================================

local Bubble = create("TextButton",ScreenGui,{
    Name = "AxomuscBubble",
    AnchorPoint = Vector2.new(1,1),
    Position = UDim2.new(1,-24,1,-90),
    Size = UDim2.fromOffset(58,58),
    BackgroundColor3 = CONFIG.Black,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Text = "",
    Visible = false,
    AutoButtonColor = false,
    ZIndex = 300,
})

corner(Bubble,18)
stroke(Bubble,CONFIG.Accent,1.5,0.2)

local BubbleLogo = create("ImageLabel",Bubble,{
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.5),
    Size = UDim2.fromOffset(38,38),
    BackgroundTransparency = 1,
    Image = CONFIG.Logo,
    ScaleType = Enum.ScaleType.Crop,
})

corner(BubbleLogo,12)

buttonFX(Bubble,CONFIG.Black,Color3.fromRGB(10,29,40))

local function showBubble()
    Bubble.Visible = true
    Bubble.Size = UDim2.fromOffset(0,0)

    tween(Bubble,0.35,{
        Size = UDim2.fromOffset(58,58)
    })
end

local function hideBubble()
    tween(Bubble,0.25,{
        Size = UDim2.fromOffset(0,0)
    })

    task.delay(0.28,function()
        Bubble.Visible = false
    end)
end

Bubble.MouseButton1Click:Connect(function()
    ripple(Bubble)

    Main.Visible = true
    hideBubble()

    toast(
        "Axomusc",
        "Music interface restored.",
        "◆"
    )
end)

Close.MouseButton1Click:Connect(function()
    ripple(Close)

    Main.Visible = false
    showBubble()

    toast(
        "Axomusc Minimized",
        "Tap the Axomusc bubble untuk membuka kembali.",
        "−"
    )
end)

--// ================================================================
--// KEYBIND
--// ================================================================

local toggleKey = Enum.KeyCode.RightControl

pcall(function()
    local value = Saved.Settings.Key
    if type(value) == "string" and Enum.KeyCode[value] then
        toggleKey = Enum.KeyCode[value]
    end
end)

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then
        return
    end

    if input.KeyCode == toggleKey then
        if Main.Visible then
            Main.Visible = false
            showBubble()

            toast(
                "Axomusc Hidden",
                "Tekan " .. toggleKey.Name .. " untuk membuka.",
                "−"
            )
        else
            Main.Visible = true
            hideBubble()

            toast(
                "Axomusc Visible",
                "Music interface restored.",
                "◆"
            )
        end
    end
end)

--// ================================================================
--// EQUALIZER PANEL
--// ================================================================

local EQPanel = create("Frame",PlayerPanel,{
    Position = UDim2.fromOffset(25,495),
    Size = UDim2.new(1,-50,0,80),
    BackgroundColor3 = CONFIG.Black,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
})

corner(EQPanel,12)
stroke(EQPanel,CONFIG.Accent,1,0.83)

local EQTitle = create("TextLabel",EQPanel,{
    Position = UDim2.fromOffset(12,8),
    Size = UDim2.fromOffset(100,18),
    BackgroundTransparency = 1,
    Text = "EQUALIZER",
    TextColor3 = CONFIG.Muted,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local EQPresets = {
    {"Flat",0,0,0},
    {"Bass",6,2,-2},
    {"Vocal",-2,5,4},
    {"Energy",5,4,5},
}

local EQButtons = create("Frame",EQPanel,{
    Position = UDim2.fromOffset(10,30),
    Size = UDim2.new(1,-20,0,35),
    BackgroundTransparency = 1,
})

local eql = list(EQButtons,Enum.FillDirection.Horizontal,5)
eql.VerticalAlignment = Enum.VerticalAlignment.Center

for _,preset in ipairs(EQPresets) do
    local b = create("TextButton",EQButtons,{
        Size = UDim2.new(0.25,-4,1,0),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.1,
        Text = preset[1],
        TextColor3 = CONFIG.White,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    })

    corner(b,8)
    buttonFX(b,CONFIG.Panel2,Color3.fromRGB(17,38,46))

    b.MouseButton1Click:Connect(function()
        ripple(b)

        pcall(function()
            Equalizer.LowGain = preset[2]
            Equalizer.MidGain = preset[3]
            Equalizer.HighGain = preset[4]
        end)

        toast(
            "Equalizer",
            preset[1] .. " preset aktif.",
            "≋"
        )
    end)
end

--// ================================================================
--// SPEED PANEL
--// ================================================================

local SpeedPanel = create("Frame",PlayerPanel,{
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-25,0,495),
    Size = UDim2.fromOffset(150,80),
    BackgroundColor3 = CONFIG.Black,
    BackgroundTransparency = 0.25,
    BorderSizePixel = 0,
})

corner(SpeedPanel,12)
stroke(SpeedPanel,CONFIG.Accent,1,0.83)

local SpeedTitle = create("TextLabel",SpeedPanel,{
    Position = UDim2.fromOffset(12,8),
    Size = UDim2.new(1,-24,0,18),
    BackgroundTransparency = 1,
    Text = "PLAYBACK SPEED",
    TextColor3 = CONFIG.Muted,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local SpeedButtons = create("Frame",SpeedPanel,{
    Position = UDim2.fromOffset(10,30),
    Size = UDim2.new(1,-20,0,35),
    BackgroundTransparency = 1,
})

local sl = list(SpeedButtons,Enum.FillDirection.Horizontal,4)
sl.VerticalAlignment = Enum.VerticalAlignment.Center

for _,speed in ipairs({0.5,1,1.5,2}) do
    local b = create("TextButton",SpeedButtons,{
        Size = UDim2.new(0.25,-3,1,0),
        BackgroundColor3 = CONFIG.Panel2,
        BackgroundTransparency = 0.1,
        Text = tostring(speed) .. "x",
        TextColor3 = CONFIG.White,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    })

    corner(b,8)
    buttonFX(b,CONFIG.Panel2,Color3.fromRGB(17,38,46))

    b.MouseButton1Click:Connect(function()
        ripple(b)
        setSpeed(speed)

        toast(
            "Playback Speed",
            tostring(speed) .. "x",
            "◈"
        )
    end)
end

--// ================================================================
--// FAVORITE QUICK ACTION
--// ================================================================

local FavoriteButton = create("TextButton",PlayerPanel,{
    AnchorPoint = Vector2.new(1,0),
    Position = UDim2.new(1,-25,0,16),
    Size = UDim2.fromOffset(35,30),
    BackgroundColor3 = CONFIG.Panel2,
    BackgroundTransparency = 0.15,
    Text = "☆",
    TextColor3 = CONFIG.White,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
})

corner(FavoriteButton,9)
buttonFX(FavoriteButton,CONFIG.Panel2,Color3.fromRGB(18,39,48))

FavoriteButton.MouseButton1Click:Connect(function()
    ripple(FavoriteButton)

    if not CurrentTrack then
        toast(
            "Favorite",
            "Belum ada track yang sedang diputar.",
            "☆"
        )
        return
    end

    local value = not isFavorite(CurrentTrack.Id)

    setFavorite(CurrentTrack.Id,value)

    FavoriteButton.Text = value and "★" or "☆"
    FavoriteButton.TextColor3 = value and CONFIG.Accent or CONFIG.White

    toast(
        value and "Favorite Added" or "Favorite Removed",
        CurrentTrack.Name,
        value and "★" or "☆"
    )
end)

--// ================================================================
--// INITIAL STATE
--// ================================================================

setVolume(Saved.Settings.Volume)
setSpeed(Saved.Settings.Speed)
rebuildPlaylist()
refreshFolder("all")

--// ================================================================
--// SEARCH UI ANIMATION
--// ================================================================

SearchBox.Focused:Connect(function()
    tween(SearchBox,0.2,{
        BackgroundColor3 = Color3.fromRGB(11,25,39)
    })

    toast(
        "Music Search",
        "Masukkan Roblox Music ID lalu tekan Enter.",
        "⌕"
    )
end)

SearchBox.FocusLost:Connect(function()
    tween(SearchBox,0.2,{
        BackgroundColor3 = CONFIG.Panel2
    })
end)

--// ================================================================
--// PROGRESS LOOP
--// ================================================================

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.08)

        if CurrentSound and CurrentSound.Parent then
            updateProgress()

            if CurrentSound.IsPlaying then
                local angle = os.clock()*0.7

                tween(AlbumGlow,0.18,{
                    BackgroundTransparency =
                        0.88 + math.sin(angle)*0.025
                })
            end
        end
    end
end)

--// ================================================================
--// ALBUM ART ANIMATION
--// ================================================================

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.03)

        if CurrentSound and CurrentSound.IsPlaying then
            local rotation = (os.clock()*3)%360

            AlbumGlow.Rotation = rotation

            local pulse =
                1 + math.sin(os.clock()*3)*0.012

            AlbumHolder.Size =
                UDim2.fromOffset(
                    230*pulse,
                    230*pulse
                )
        else
            AlbumHolder.Size =
                UDim2.fromOffset(230,230)
        end
    end
end)

--// ================================================================
--// SEARCH RESULT POSITION RESPONSIVE
--// ================================================================

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.2)

        if SearchResults.Visible then
            SearchResults.Position =
                UDim2.fromOffset(
                    math.max(320,MusicHeader.AbsolutePosition.X
                        + MusicHeader.AbsoluteSize.X - 270),
                    78
                )
        end
    end
end)

--// ================================================================
--// MOBILE TOUCH SUPPORT
--// ================================================================

local touchDragging = false
local touchStart
local touchMainStart

TopBar.TouchLongPress:Connect(function(_,state)
    if state == Enum.UserInputState.Begin then
        touchDragging = true
        touchStart = UserInputService:GetMouseLocation()
        touchMainStart = Main.Position
    elseif state == Enum.UserInputState.End then
        touchDragging = false
    end
end)

--// ================================================================
--// CLEANUP
--// ================================================================

local destroyed = false

local function destroyAxomusc()
    if destroyed then
        return
    end

    destroyed = true

    pcall(function()
        persist()
    end)

    pcall(function()
        if CurrentSound then
            CurrentSound:Stop()
        end
    end)

    safeDisconnect(cameraConnection)
    safeDisconnect(viewportConnection)

    pcall(function()
        ScreenGui:Destroy()
    end)

    GEN.__AXOMUSC_GUI = nil
    GEN.__AXOMUSC_DESTROY = nil
end

GEN.__AXOMUSC_DESTROY = destroyAxomusc

--// ================================================================
--// CLOSE / RE-EXECUTION SAFETY
--// ================================================================

ScreenGui.Destroying:Connect(function()
    if not destroyed then
        destroyed = true

        pcall(function()
            persist()
        end)

        GEN.__AXOMUSC_GUI = nil
        GEN.__AXOMUSC_DESTROY = nil
    end
end)

--// ================================================================
--// INITIAL OPEN ANIMATION
--// ================================================================

Main.Size = UDim2.fromOffset(1040,610)
Main.BackgroundTransparency = 1

tween(Main,0.45,{
    Size = UDim2.fromOffset(1080,650),
    BackgroundTransparency = 0.035
})

task.delay(0.25,function()
    toast(
        "Axomusc Beta",
        "Premium Music Engine berhasil dimuat.",
        "◆"
    )
end)

task.delay(0.55,function()
    toast(
        "Executor",
        Executor.Name .. " compatibility layer aktif.",
        "✓"
    )
end)

--// ================================================================
--// OPTIONAL DEFAULT TRACK
--// ================================================================

if #Tracks == 0 then
    local defaultTrack = {
        Id = "9112892993",
        Name = "Axomusc Theme",
        Creator = "Axolion Community",
    }

    addTrack(defaultTrack)
    rebuildPlaylist()
end

--// ================================================================
--// FINAL UI POLISH
--// ================================================================

local function polishFrame(frame)
    if not frame then
        return
    end

    frame.ClipsDescendants = true
end

polishFrame(Main)
polishFrame(Sidebar)
polishFrame(PlayerPanel)
polishFrame(LibraryPanel)
polishFrame(PlaylistPanel)
polishFrame(CommunityCard)

--// ================================================================
--// FINAL STATUS
--// ================================================================

task.delay(1,function()
    if ScreenGui and ScreenGui.Parent then
        toast(
            "Ready",
            "Search ID Roblox, simpan playlist, lalu putar musik.",
            "♫"
        )
    end
end)

--// ================================================================
--// END
--// ================================================================