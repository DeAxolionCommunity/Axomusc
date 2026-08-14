--// ================================================================
--// AXOMUSC (BETA) — AXOLION COMMUNITY
--// PART 4/4 — FITUR AKHIR + PENUTUP + CLEANUP
--// ROBLOX LUA / DELTA EXECUTOR
--// ================================================================

local ok, GUIROOT = pcall(function()
    return gethui()
end)

if not ok or not GUIROOT then
    GUIROOT = game:GetService("CoreGui")
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ================================================================
-- SAFETY
-- ================================================================

local function SafeCall(fn,...)
    local args = {...}
    local success,result = pcall(function()
        return fn(table.unpack(args))
    end)

    if success then
        return result
    end

    return nil
end

local function FindRecursive(parent,name)
    if not parent then
        return nil
    end

    local direct = SafeCall(function()
        return parent:FindFirstChild(name,true)
    end)

    return direct
end

local MainGui =
    FindRecursive(GUIROOT,"Axomusc") or
    FindRecursive(GUIROOT,"AxomuscUI") or
    FindRecursive(GUIROOT,"Axomusc_Beta")

if not MainGui then
    return
end

-- ================================================================
-- THEME
-- ================================================================

local COLORS = {
    DarkBlue = Color3.fromRGB(5,13,29),
    DarkBlue2 = Color3.fromRGB(8,20,42),
    DarkBlue3 = Color3.fromRGB(11,28,53),

    Black = Color3.fromRGB(2,4,8),
    Black2 = Color3.fromRGB(5,7,12),

    Tosca = Color3.fromRGB(42,226,203),
    ToscaDark = Color3.fromRGB(19,148,137),
    ToscaSoft = Color3.fromRGB(83,255,232),

    White = Color3.fromRGB(245,250,255),
    WhiteSoft = Color3.fromRGB(178,193,208),
    Gray = Color3.fromRGB(111,128,146),

    Red = Color3.fromRGB(255,75,92),
    Yellow = Color3.fromRGB(255,204,92)
}

local SPRING = TweenInfo.new(
    0.42,
    Enum.EasingStyle.Spring,
    Enum.EasingDirection.Out
)

local QUAD = TweenInfo.new(
    0.28,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

local FAST = TweenInfo.new(
    0.16,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

-- ================================================================
-- GENERIC UI FINDER
-- ================================================================

local function GetAny(...)
    for _,name in ipairs({...}) do
        local obj = FindRecursive(MainGui,name)
        if obj then
            return obj
        end
    end
end

local MainFrame = GetAny(
    "MainFrame",
    "Main",
    "Window",
    "Container"
)

local Sidebar = GetAny(
    "Sidebar",
    "SideBar",
    "Navigation"
)

local Workspace = GetAny(
    "Workspace",
    "WorkspaceArea",
    "Content"
)

local MusicPage = GetAny(
    "MusicEngine",
    "MusicPanel",
    "MusicPage"
)

local CommunityPage = GetAny(
    "AxolionCommunity",
    "CommunityPanel",
    "CommunityPage"
)

-- ================================================================
-- SAFE VISIBILITY
-- ================================================================

local function SetVisible(obj,value)
    if not obj then
        return
    end

    SafeCall(function()
        if obj:IsA("GuiObject") then
            obj.Visible = value
        end
    end)
end

local function SetTransparency(obj,value)
    if not obj then
        return
    end

    SafeCall(function()
        if obj:IsA("GuiObject") then
            obj.BackgroundTransparency = value
        end
    end)
end

-- ================================================================
-- RIPPLE SYSTEM
-- ================================================================

local function Ripple(button)
    if not button then
        return
    end

    if not button:IsA("GuiButton") then
        return
    end

    local holder = button

    local ripple = Instance.new("Frame")
    ripple.Name = "ClickRipple"
    ripple.AnchorPoint = Vector2.new(0.5,0.5)
    ripple.Position = UDim2.fromScale(0.5,0.5)
    ripple.Size = UDim2.fromOffset(4,4)
    ripple.BackgroundColor3 = COLORS.Tosca
    ripple.BackgroundTransparency = 0.25
    ripple.BorderSizePixel = 0
    ripple.ZIndex = math.max(button.ZIndex + 5,10)
    ripple.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent = ripple

    local maxSize = math.max(
        button.AbsoluteSize.X,
        button.AbsoluteSize.Y
    ) * 2.4

    local tween = TweenService:Create(
        ripple,
        TweenInfo.new(
            0.5,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            Size = UDim2.fromOffset(maxSize,maxSize),
            BackgroundTransparency = 1
        }
    )

    tween:Play()

    tween.Completed:Connect(function()
        SafeCall(function()
            ripple:Destroy()
        end)
    end)
end

local function ConnectRipple(root)
    if not root then
        return
    end

    for _,obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            if not obj:GetAttribute("RippleConnected") then
                obj:SetAttribute("RippleConnected",true)

                obj.Activated:Connect(function()
                    Ripple(obj)
                end)
            end
        end
    end
end

ConnectRipple(MainGui)

-- ================================================================
-- HOVER EFFECT
-- ================================================================

local function AddHover(button)
    if not button then
        return
    end

    if not button:IsA("GuiButton") then
        return
    end

    if button:GetAttribute("HoverConnected") then
        return
    end

    button:SetAttribute("HoverConnected",true)

    local original = button.BackgroundColor3
    local originalTransparency = button.BackgroundTransparency

    button.MouseEnter:Connect(function()
        SafeCall(function()
            TweenService:Create(
                button,
                FAST,
                {
                    BackgroundColor3 = COLORS.DarkBlue3,
                    BackgroundTransparency = math.max(
                        0,
                        originalTransparency - 0.05
                    )
                }
            ):Play()
        end)
    end)

    button.MouseLeave:Connect(function()
        SafeCall(function()
            TweenService:Create(
                button,
                FAST,
                {
                    BackgroundColor3 = original,
                    BackgroundTransparency = originalTransparency
                }
            ):Play()
        end)
    end)
end

for _,obj in ipairs(MainGui:GetDescendants()) do
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        AddHover(obj)
    end
end

-- ================================================================
-- TOAST SYSTEM
-- ================================================================

local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "AxomuscToastContainer"
ToastContainer.AnchorPoint = Vector2.new(1,1)
ToastContainer.Position = UDim2.new(1,-18,1,-18)
ToastContainer.Size = UDim2.fromOffset(300,400)
ToastContainer.BackgroundTransparency = 1
ToastContainer.BorderSizePixel = 0
ToastContainer.ZIndex = 10000
ToastContainer.Parent = MainGui

local ToastLayout = Instance.new("UIListLayout")
ToastLayout.Padding = UDim.new(0,8)
ToastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToastLayout.Parent = ToastContainer

local function Toast(title,message,duration)
    duration = duration or 2.5

    local Card = Instance.new("Frame")
    Card.Name = "Toast"
    Card.Size = UDim2.fromOffset(285,68)
    Card.BackgroundColor3 = COLORS.Black
    Card.BackgroundTransparency = 0.08
    Card.BorderSizePixel = 0
    Card.ZIndex = 10001
    Card.Parent = ToastContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,12)
    Corner.Parent = Card

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = COLORS.Tosca
    Stroke.Thickness = 1
    Stroke.Transparency = 0.25
    Stroke.Parent = Card

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0,3,1,-18)
    Accent.Position = UDim2.new(0,9,0,9)
    Accent.BackgroundColor3 = COLORS.Tosca
    Accent.BorderSizePixel = 0
    Accent.Parent = Card

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(1,0)
    AccentCorner.Parent = Accent

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(24,10)
    Title.Size = UDim2.new(1,-34,0,20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = tostring(title or "Axomusc")
    Title.TextColor3 = COLORS.White
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Message = Instance.new("TextLabel")
    Message.BackgroundTransparency = 1
    Message.Position = UDim2.fromOffset(24,31)
    Message.Size = UDim2.new(1,-34,0,25)
    Message.Font = Enum.Font.Gotham
    Message.Text = tostring(message or "")
    Message.TextColor3 = COLORS.WhiteSoft
    Message.TextSize = 11
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.Parent = Card

    Card.Position = UDim2.new(1,320,0,0)

    TweenService:Create(
        Card,
        SPRING,
        {
            Position = UDim2.fromOffset(0,0)
        }
    ):Play()

    task.delay(duration,function()
        if Card and Card.Parent then
            local closeTween = TweenService:Create(
                Card,
                QUAD,
                {
                    Position = UDim2.new(1,320,0,0),
                    BackgroundTransparency = 1
                }
            )

            closeTween:Play()

            closeTween.Completed:Connect(function()
                SafeCall(function()
                    Card:Destroy()
                end)
            end)
        end
    end)
end

-- ================================================================
-- CLIPBOARD
-- ================================================================

local function CopyText(text,label)
    local copied = false

    if setclipboard then
        copied = pcall(function()
            setclipboard(text)
        end)
    end

    if not copied and toclipboard then
        copied = pcall(function()
            toclipboard(text)
        end)
    end

    if not copied and syn and syn.write_clipboard then
        copied = pcall(function()
            syn.write_clipboard(text)
        end)
    end

    if copied then
        Toast(
            "Axomusc",
            (label or "Teks").." berhasil disalin.",
            2.2
        )
    else
        Toast(
            "Axomusc",
            "Clipboard tidak tersedia.",
            2.2
        )
    end
end

-- ================================================================
-- COMMUNITY COPY BUTTONS
-- ================================================================

local DiscordButton = GetAny(
    "DiscordCopy",
    "CopyDiscord",
    "DiscordButton"
)

local CommunityButton = GetAny(
    "CommunityCopy",
    "CopyCommunity",
    "CommunityButton"
)

if DiscordButton and DiscordButton:IsA("GuiButton") then
    DiscordButton.Activated:Connect(function()
        CopyText(
            "https://discord.gg/dkuXRcS2hY",
            "Discord Link"
        )
    end)
end

if CommunityButton and CommunityButton:IsA("GuiButton") then
    CommunityButton.Activated:Connect(function()
        CopyText(
            "https://www.roblox.com/share/g/245953568",
            "Community Link"
        )
    end)
end

-- ================================================================
-- PERFORMANCE OVERLAY
-- ================================================================

local PerformanceFrame = Instance.new("Frame")
PerformanceFrame.Name = "LivePerformance"
PerformanceFrame.BackgroundTransparency = 1
PerformanceFrame.AnchorPoint = Vector2.new(1,0)
PerformanceFrame.Position = UDim2.new(1,-15,0,8)
PerformanceFrame.Size = UDim2.fromOffset(170,25)
PerformanceFrame.ZIndex = 9000
PerformanceFrame.Parent = MainGui

local PerformanceLabel = Instance.new("TextLabel")
PerformanceLabel.BackgroundTransparency = 1
PerformanceLabel.Size = UDim2.fromScale(1,1)
PerformanceLabel.Font = Enum.Font.GothamMedium
PerformanceLabel.TextSize = 10
PerformanceLabel.TextColor3 = COLORS.WhiteSoft
PerformanceLabel.TextXAlignment = Enum.TextXAlignment.Right
PerformanceLabel.Text = "FPS --  |  PING --"
PerformanceLabel.Parent = PerformanceFrame

local frames = 0
local fps = 60
local lastFPS = os.clock()

RunService.RenderStepped:Connect(function()
    frames += 1

    local now = os.clock()

    if now - lastFPS >= 1 then
        fps = frames
        frames = 0
        lastFPS = now

        local ping = 0

        local success,value = pcall(function()
            return Stats.Network.ServerStatsItem[
                "Data Ping"
            ]:GetValue()
        end)

        if success and typeof(value) == "number" then
            ping = math.floor(value)
        end

        PerformanceLabel.Text =
            "FPS "..tostring(fps)..
            "  |  PING "..tostring(ping).."ms"
    end
end)

-- ================================================================
-- GLOBAL SCALE
-- ================================================================

local Camera = workspace.CurrentCamera

local UIScale = MainGui:FindFirstChildOfClass("UIScale")

if not UIScale then
    UIScale = Instance.new("UIScale")
    UIScale.Name = "GlobalScale"
    UIScale.Parent = MainGui
end

local function UpdateScale()
    Camera = workspace.CurrentCamera or Camera

    if not Camera then
        return
    end

    local size = Camera.ViewportSize

    local baseWidth = 1100
    local scale = size.X / baseWidth

    if size.X < 500 then
        scale = math.clamp(scale,0.62,0.82)
    elseif size.X < 900 then
        scale = math.clamp(scale,0.72,0.92)
    else
        scale = math.clamp(scale,0.82,1.15)
    end

    UIScale.Scale = scale
end

UpdateScale()

if Camera then
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(
        UpdateScale
    )
end

-- ================================================================
-- SMART MINIMIZE BUBBLE
-- ================================================================

local Bubble = MainGui:FindFirstChild("AxomuscBubble")

if not Bubble then
    Bubble = Instance.new("ImageButton")
    Bubble.Name = "AxomuscBubble"
    Bubble.AnchorPoint = Vector2.new(1,0.5)
    Bubble.Position = UDim2.new(1,-22,0.5,0)
    Bubble.Size = UDim2.fromOffset(62,62)
    Bubble.BackgroundColor3 = COLORS.Black
    Bubble.BackgroundTransparency = 0.06
    Bubble.BorderSizePixel = 0
    Bubble.AutoButtonColor = false
    Bubble.Image = "rbxassetid://85647271976925"
    Bubble.ImageTransparency = 0.03
    Bubble.Visible = false
    Bubble.ZIndex = 11000
    Bubble.Parent = MainGui

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1,0)
    BC.Parent = Bubble

    local BS = Instance.new("UIStroke")
    BS.Color = COLORS.Tosca
    BS.Thickness = 2
    BS.Parent = Bubble
end

AddHover(Bubble)

local function ShowBubble()
    Bubble.Visible = true
    Bubble.Position = UDim2.new(1,80,0.5,0)

    TweenService:Create(
        Bubble,
        SPRING,
        {
            Position = UDim2.new(1,-22,0.5,0)
        }
    ):Play()
end

local function HideBubble()
    Bubble.Visible = false
end

local function ShowMain()
    if MainFrame then
        MainFrame.Visible = true
    else
        for _,obj in ipairs(MainGui:GetChildren()) do
            if obj:IsA("Frame") and obj ~= ToastContainer then
                obj.Visible = true
            end
        end
    end

    HideBubble()

    Toast(
        "Axomusc",
        "Interface restored.",
        1.5
    )
end

Bubble.Activated:Connect(function()
    Ripple(Bubble)
    ShowMain()
end)

-- ================================================================
-- MINIMIZE BUTTON DETECTION
-- ================================================================

local MinimizeButton = GetAny(
    "Minimize",
    "MinimizeButton",
    "CloseButton"
)

if MinimizeButton and MinimizeButton:IsA("GuiButton") then
    MinimizeButton.Activated:Connect(function()
        Ripple(MinimizeButton)

        if MainFrame then
            MainFrame.Visible = false
        else
            for _,obj in ipairs(MainGui:GetChildren()) do
                if obj:IsA("Frame") and
                    obj ~= ToastContainer and
                    obj ~= Bubble then
                    obj.Visible = false
                end
            end
        end

        ShowBubble()
    end)
end

-- ================================================================
-- KEYBIND SYSTEM
-- ================================================================

local Keybind = Enum.KeyCode.RightShift
local CapturingKey = false

local function ToggleInterface()
    if Bubble.Visible then
        ShowMain()
        return
    end

    if MainFrame then
        MainFrame.Visible = false
    else
        for _,obj in ipairs(MainGui:GetChildren()) do
            if obj:IsA("Frame") and
                obj ~= ToastContainer and
                obj ~= Bubble then
                obj.Visible = false
            end
        end
    end

    ShowBubble()
end

UserInputService.InputBegan:Connect(function(input,processed)
    if processed then
        return
    end

    if CapturingKey then
        return
    end

    if input.KeyCode == Keybind then
        ToggleInterface()
    end
end)

-- ================================================================
-- KEYBIND CAPTURER
-- ================================================================

local KeybindButton = GetAny(
    "KeybindButton",
    "Keybind",
    "KeyButton"
)

local KeybindLabel = GetAny(
    "KeybindLabel",
    "KeyText",
    "BindLabel"
)

local function BeginKeybindCapture()
    if CapturingKey then
        return
    end

    CapturingKey = true

    if KeybindLabel then
        KeybindLabel.Text = "PRESS ANY KEY..."
        KeybindLabel.TextColor3 = COLORS.Tosca
    end

    Toast(
        "Keybind",
        "Tekan tombol untuk mengatur toggle key.",
        2
    )

    local connection

    connection = UserInputService.InputBegan:Connect(
        function(input,processed)
            if processed then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            if input.KeyCode == Enum.KeyCode.Unknown then
                return
            end

            Keybind = input.KeyCode
            CapturingKey = false

            if KeybindLabel then
                KeybindLabel.Text = Keybind.Name
                KeybindLabel.TextColor3 = COLORS.White
            end

            Toast(
                "Keybind Updated",
                "Toggle key: "..Keybind.Name,
                2
            )

            if connection then
                connection:Disconnect()
            end
        end
    )
end

if KeybindButton and KeybindButton:IsA("GuiButton") then
    KeybindButton.Activated:Connect(BeginKeybindCapture)
end

-- ================================================================
-- FAVORITE SYSTEM
-- ================================================================

local Favorites = {}

local function IsFavorite(id)
    return Favorites[id] == true
end

local function ToggleFavorite(id,button)
    if not id then
        return
    end

    Favorites[id] = not Favorites[id]

    local state = Favorites[id]

    if button then
        if button:IsA("TextButton") then
            button.Text = state and "★" or "☆"
        elseif button:IsA("ImageButton") then
            button.ImageTransparency = state and 0 or 0.25
        end
    end

    Toast(
        "Favorite",
        state and "Ditambahkan ke Favorite."
            or "Dihapus dari Favorite.",
        1.7
    )
end

for _,obj in ipairs(MainGui:GetDescendants()) do
    if obj:IsA("GuiButton") then
        local lower = string.lower(obj.Name)

        if string.find(lower,"favorite")
            or string.find(lower,"favourite")
            or lower == "fav" then

            if not obj:GetAttribute("FavoriteConnected") then
                obj:SetAttribute(
                    "FavoriteConnected",
                    true
                )

                obj.Activated:Connect(function()
                    ToggleFavorite(
                        obj:GetFullName(),
                        obj
                    )
                end)
            end
        end
    end
end

-- ================================================================
-- PAGE NAVIGATION
-- ================================================================

local MusicButton = GetAny(
    "MusicEngineButton",
    "MusicButton",
    "MusicNav",
    "Music"
)

local CommunityNav = GetAny(
    "CommunityButton",
    "CommunityNav",
    "Community"
)

local function SetPage(page)
    if MusicPage then
        MusicPage.Visible = false
    end

    if CommunityPage then
        CommunityPage.Visible = false
    end

    if page == "Music" then
        if MusicPage then
            MusicPage.Visible = true
        end

        Toast(
            "Music Engine",
            "Music workspace active.",
            1.3
        )

    elseif page == "Community" then
        if CommunityPage then
            CommunityPage.Visible = true
        end

        Toast(
            "Axolion Community",
            "Community workspace active.",
            1.3
        )
    end
end

if MusicButton and MusicButton:IsA("GuiButton") then
    MusicButton.Activated:Connect(function()
        Ripple(MusicButton)
        SetPage("Music")
    end)
end

if CommunityNav and CommunityNav:IsA("GuiButton") then
    CommunityNav.Activated:Connect(function()
        Ripple(CommunityNav)
        SetPage("Community")
    end)
end

-- ================================================================
-- MUSIC CONTROLS
-- ================================================================

local Sound = MainGui:FindFirstChild(
    "AxomuscSound",
    true
)

if not Sound then
    Sound = Instance.new("Sound")
    Sound.Name = "AxomuscSound"
    Sound.Volume = 0.75
    Sound.Looped = false
    Sound.Parent = MainGui
end

local PlayButton = GetAny(
    "PlayButton",
    "PlayPause",
    "Play"
)

local PreviousButton = GetAny(
    "PreviousButton",
    "BackButton",
    "Previous"
)

local NextButton = GetAny(
    "NextButton",
    "ForwardButton",
    "Next"
)

local ReplayButton = GetAny(
    "ReplayButton",
    "RepeatButton",
    "Replay"
)

local ShuffleButton = GetAny(
    "ShuffleButton",
    "RandomButton",
    "Shuffle"
)

local SpeedButton = GetAny(
    "SpeedButton",
    "PlaybackSpeed"
)

local VolumeSlider = GetAny(
    "VolumeSlider",
    "VolumeBar",
    "Volume"
)

local VolumeKnob = GetAny(
    "VolumeKnob",
    "VolumeHandle"
)

local SpeedValues = {
    0.5,
    1,
    1.5,
    2
}

local CurrentSpeed = 1
local SpeedIndex = 2
local ShuffleEnabled = false
local ReplayEnabled = false

local function UpdatePlayVisual()
    if not PlayButton then
        return
    end

    if PlayButton:IsA("TextButton") then
        PlayButton.Text = Sound.IsPlaying
            and "❚❚"
            or "▶"
    end
end

if PlayButton and PlayButton:IsA("GuiButton") then
    PlayButton.Activated:Connect(function()
        Ripple(PlayButton)

        if Sound.IsPlaying then
            Sound:Pause()
        else
            Sound:Resume()
        end

        UpdatePlayVisual()
    end)
end

if ReplayButton and ReplayButton:IsA("GuiButton") then
    ReplayButton.Activated:Connect(function()
        Ripple(ReplayButton)

        ReplayEnabled = not ReplayEnabled

        if ReplayEnabled then
            Sound.Looped = true
        else
            Sound.Looped = false
        end

        Toast(
            "Repeat",
            ReplayEnabled and "Repeat aktif."
                or "Repeat nonaktif.",
            1.5
        )
    end)
end

if ShuffleButton and ShuffleButton:IsA("GuiButton") then
    ShuffleButton.Activated:Connect(function()
        Ripple(ShuffleButton)

        ShuffleEnabled = not ShuffleEnabled

        Toast(
            "Shuffle",
            ShuffleEnabled and "Shuffle aktif."
                or "Shuffle nonaktif.",
            1.5
        )
    end)
end

if SpeedButton and SpeedButton:IsA("GuiButton") then
    SpeedButton.Activated:Connect(function()
        Ripple(SpeedButton)

        SpeedIndex += 1

        if SpeedIndex > #SpeedValues then
            SpeedIndex = 1
        end

        CurrentSpeed = SpeedValues[SpeedIndex]
        Sound.PlaybackSpeed = CurrentSpeed

        if SpeedButton:IsA("TextButton") then
            SpeedButton.Text =
                string.format("%.1fx",CurrentSpeed)
        end

        Toast(
            "Playback Speed",
            string.format(
                "Speed %.1fx",
                CurrentSpeed
            ),
            1.5
        )
    end)
end

-- ================================================================
-- VOLUME SLIDER
-- ================================================================

local VolumeDragging = false

local function SetVolumeFromX(x)
    if not VolumeSlider then
        return
    end

    local absolutePosition =
        VolumeSlider.AbsolutePosition.X

    local absoluteSize =
        VolumeSlider.AbsoluteSize.X

    if absoluteSize <= 0 then
        return
    end

    local alpha = math.clamp(
        (x - absolutePosition) / absoluteSize,
        0,
        1
    )

    local percent = math.floor(
        alpha * 100 + 0.5
    )

    Sound.Volume = alpha

    if VolumeKnob then
        TweenService:Create(
            VolumeKnob,
            FAST,
            {
                Position = UDim2.new(
                    alpha,
                    0,
                    VolumeKnob.Position.Y.Scale,
                    VolumeKnob.Position.Y.Offset
                )
            }
        ):Play()
    end

    local volumeLabel = GetAny(
        "VolumeLabel",
        "VolumeValue",
        "VolumePercent"
    )

    if volumeLabel and volumeLabel:IsA("TextLabel") then
        volumeLabel.Text =
            tostring(percent).."%"
    end
end

if VolumeSlider then

    if VolumeSlider:IsA("GuiButton") then
        VolumeSlider.InputBegan:Connect(function(input)
            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                VolumeDragging = true
                SetVolumeFromX(input.Position.X)
            end
        end)
    end

    UserInputService.InputChanged:Connect(
        function(input)
            if not VolumeDragging then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                SetVolumeFromX(input.Position.X)
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)
            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                VolumeDragging = false
            end
        end
    )
end

-- ================================================================
-- MUSIC FOLDER SEARCH
-- ================================================================

local SearchBox = GetAny(
    "SearchBox",
    "MusicSearch",
    "Search"
)

local function FilterMusic(query)
    query = string.lower(
        tostring(query or "")
    )

    for _,obj in ipairs(MainGui:GetDescendants()) do
        if obj:IsA("GuiObject") then

            local isMusicItem =
                obj:GetAttribute("MusicItem") == true

            if isMusicItem then
                local title = obj:GetAttribute(
                    "MusicTitle"
                )

                if not title then
                    title = obj.Name
                end

                local match =
                    query == "" or
                    string.find(
                        string.lower(
                            tostring(title)
                        ),
                        query,
                        1,
                        true
                    ) ~= nil

                obj.Visible = match
            end
        end
    end
end

if SearchBox and SearchBox:IsA("TextBox") then
    SearchBox:GetPropertyChangedSignal(
        "Text"
    ):Connect(function()
        FilterMusic(SearchBox.Text)
    end)
end

-- ================================================================
-- PLAYLIST PANEL SWITCH
-- ================================================================

local PlaylistButton = GetAny(
    "PlaylistButton",
    "AddPlaylist",
    "Playlist"
)

local FolderPanel = GetAny(
    "FolderPanel",
    "AudioFolder",
    "Folders"
)

local PlaylistPanel = GetAny(
    "PlaylistPanel",
    "PlaylistWorkspace",
    "PlaylistContent"
)

if PlaylistPanel then
    PlaylistPanel.Visible = false
end

if PlaylistButton and PlaylistButton:IsA("GuiButton") then
    PlaylistButton.Activated:Connect(function()
        Ripple(PlaylistButton)

        if FolderPanel then
            FolderPanel.Visible =
                not FolderPanel.Visible
        end

        if PlaylistPanel then
            PlaylistPanel.Visible =
                not PlaylistPanel.Visible
        end
    end)
end

-- ================================================================
-- FOLDER SELECTION
-- ================================================================

for _,obj in ipairs(MainGui:GetDescendants()) do
    if obj:IsA("GuiButton") then

        local folderAttribute =
            obj:GetAttribute("AudioFolder")

        if folderAttribute then

            obj.Activated:Connect(function()
                Ripple(obj)

                if FolderPanel then
                    FolderPanel.Visible = false
                end

                if PlaylistPanel then
                    PlaylistPanel.Visible = true
                end

                for _,musicObj in ipairs(
                    MainGui:GetDescendants()
                ) do
                    if musicObj:IsA("GuiObject") then
                        local folder =
                            musicObj:GetAttribute(
                                "PlaylistFolder"
                            )

                        if folder then
                            musicObj.Visible =
                                tostring(folder)
                                == tostring(folderAttribute)
                        end
                    end
                end

                Toast(
                    "Audio Library",
                    tostring(folderAttribute),
                    1.5
                )
            end)
        end
    end
end

-- ================================================================
-- MUSIC ITEM SELECTION
-- ================================================================

for _,obj in ipairs(MainGui:GetDescendants()) do

    if obj:IsA("GuiButton") and
        obj:GetAttribute("MusicId") then

        obj:SetAttribute(
            "MusicItem",
            true
        )

        obj.Activated:Connect(function()
            Ripple(obj)

            local id = obj:GetAttribute(
                "MusicId"
            )

            local title = obj:GetAttribute(
                "MusicTitle"
            ) or obj.Name

            if id then

                local numeric =
                    tostring(id):match("%d+")

                if numeric then

                    Sound.SoundId =
                        "rbxassetid://"..numeric

                    Sound.TimePosition = 0

                    Sound.PlaybackSpeed =
                        CurrentSpeed

                    Sound:Play()

                    local titleLabel = GetAny(
                        "NowPlayingTitle",
                        "TrackTitle",
                        "SongTitle"
                    )

                    if titleLabel and
                        titleLabel:IsA("TextLabel") then

                        titleLabel.Text =
                            tostring(title)
                    end

                    local artistLabel = GetAny(
                        "NowPlayingArtist",
                        "ArtistLabel"
                    )

                    if artistLabel and
                        artistLabel:IsA("TextLabel") then

                        artistLabel.Text =
                            "Axolion Community"
                    end

                    UpdatePlayVisual()

                    Toast(
                        "Now Playing",
                        tostring(title),
                        1.8
                    )
                end
            end
        end)
    end
end

-- ================================================================
-- EQUALIZER VISUAL
-- ================================================================

local EqualizerContainer = GetAny(
    "Equalizer",
    "EQ",
    "EqualizerPanel"
)

if EqualizerContainer then

    local Bars = {}

    for i = 1,18 do

        local bar = Instance.new("Frame")
        bar.Name = "EQBar_"..i
        bar.AnchorPoint =
            Vector2.new(0.5,1)
        bar.Size =
            UDim2.new(
                0,
                4,
                0,
                math.random(8,28)
            )
        bar.BackgroundColor3 =
            COLORS.Tosca
        bar.BorderSizePixel = 0
        bar.LayoutOrder = i
        bar.Parent = EqualizerContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius =
            UDim.new(1,0)
        corner.Parent = bar

        table.insert(Bars,bar)
    end

    local layout =
        EqualizerContainer:FindFirstChildOfClass(
            "UIListLayout"
        )

    if not layout then
        layout = Instance.new("UIListLayout")
        layout.FillDirection =
            Enum.FillDirection.Horizontal
        layout.HorizontalAlignment =
            Enum.HorizontalAlignment.Center
        layout.VerticalAlignment =
            Enum.VerticalAlignment.Bottom
        layout.Padding =
            UDim.new(0,5)
        layout.Parent =
            EqualizerContainer
    end

    task.spawn(function()
        while EqualizerContainer.Parent do

            local active =
                Sound.IsPlaying

            for _,bar in ipairs(Bars) do

                local height

                if active then
                    height =
                        math.random(8,34)
                else
                    height = 8
                end

                TweenService:Create(
                    bar,
                    TweenInfo.new(
                        0.16,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Size = UDim2.new(
                            0,
                            4,
                            0,
                            height
                        )
                    }
                ):Play()
            end

            task.wait(0.16)
        end
    end)
end

-- ================================================================
-- DRAG SYSTEM
-- ================================================================

local DragTarget = MainFrame

if DragTarget then

    local dragging = false
    local dragStart
    local startPosition

    local function UpdateDrag(input)
        if not dragging then
            return
        end

        local delta =
            input.Position - dragStart

        local viewport =
            workspace.CurrentCamera
            and workspace.CurrentCamera.ViewportSize

        local targetX =
            startPosition.X.Offset +
            delta.X

        local targetY =
            startPosition.Y.Offset +
            delta.Y

        if viewport then

            local maxX =
                viewport.X -
                DragTarget.AbsoluteSize.X

            local maxY =
                viewport.Y -
                DragTarget.AbsoluteSize.Y

            targetX = math.clamp(
                targetX,
                0,
                math.max(0,maxX)
            )

            targetY = math.clamp(
                targetY,
                0,
                math.max(0,maxY)
            )
        end

        DragTarget.Position =
            UDim2.new(
                0,
                targetX,
                0,
                targetY
            )
    end

    DragTarget.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1
            or input.UserInputType ==
            Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = DragTarget.Position

            local connection

            connection =
                input.Changed:Connect(function()

                    if input.UserInputState ==
                        Enum.UserInputState.End then

                        dragging = false

                        if connection then
                            connection:Disconnect()
                        end
                    end
                end)
        end
    end)

    UserInputService.InputChanged:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                UpdateDrag(input)
            end
        end
    )
end

-- ================================================================
-- ACRYLIC GLASS EFFECT
-- ================================================================

for _,obj in ipairs(MainGui:GetDescendants()) do

    if obj:IsA("Frame") then

        local name =
            string.lower(obj.Name)

        if string.find(name,"panel")
            or string.find(name,"workspace")
            or string.find(name,"sidebar")
            or string.find(name,"container") then

            if obj.BackgroundTransparency < 1 then

                obj.BackgroundTransparency =
                    math.clamp(
                        obj.BackgroundTransparency +
                        0.04,
                        0,
                        0.28
                    )
            end
        end
    end
end

-- ================================================================
-- DYNAMIC BORDER
-- ================================================================

local BorderParts = {}

for _,obj in ipairs(MainGui:GetDescendants()) do

    if obj:IsA("UIStroke") then

        local parentName =
            string.lower(
                obj.Parent.Name
            )

        if parentName == "mainframe"
            or parentName == "main"
            or string.find(parentName,"window") then

            table.insert(
                BorderParts,
                obj
            )
        end
    end
end

task.spawn(function()

    local t = 0

    while MainGui.Parent do

        t += 0.025

        local pulse =
            (math.sin(t) + 1) / 2

        local color =
            COLORS.Tosca:Lerp(
                COLORS.ToscaSoft,
                pulse * 0.35
            )

        for _,stroke in ipairs(BorderParts) do
            if stroke and stroke.Parent then
                stroke.Color = color
                stroke.Transparency =
                    0.12 + pulse * 0.18
            end
        end

        task.wait(0.025)
    end
end)

-- ================================================================
-- SIDEBAR TOOLTIP
-- ================================================================

local Tooltip = Instance.new("Frame")
Tooltip.Name = "NavigationTooltip"
Tooltip.Size = UDim2.fromOffset(150,34)
Tooltip.BackgroundColor3 = COLORS.Black
Tooltip.BackgroundTransparency = 0.04
Tooltip.BorderSizePixel = 0
Tooltip.Visible = false
Tooltip.ZIndex = 12000
Tooltip.Parent = MainGui

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0,9)
TooltipCorner.Parent = Tooltip

local TooltipStroke = Instance.new("UIStroke")
TooltipStroke.Color = COLORS.Tosca
TooltipStroke.Thickness = 1
TooltipStroke.Parent = Tooltip

local TooltipText = Instance.new("TextLabel")
TooltipText.BackgroundTransparency = 1
TooltipText.Size = UDim2.new(1,-14,1,0)
TooltipText.Position = UDim2.fromOffset(7,0)
TooltipText.Font = Enum.Font.GothamMedium
TooltipText.TextColor3 = COLORS.White
TooltipText.TextSize = 11
TooltipText.TextXAlignment = Enum.TextXAlignment.Left
TooltipText.Text = ""
TooltipText.Parent = Tooltip

for _,obj in ipairs(MainGui:GetDescendants()) do

    if obj:IsA("GuiButton") then

        local tooltip =
            obj:GetAttribute("Tooltip")

        if tooltip then

            obj.MouseEnter:Connect(function()

                TooltipText.Text =
                    tostring(tooltip)

                Tooltip.Visible = true

                local pos =
                    obj.AbsolutePosition

                Tooltip.Position =
                    UDim2.fromOffset(
                        pos.X +
                        obj.AbsoluteSize.X +
                        8,
                        pos.Y +
                        obj.AbsoluteSize.Y/2 -
                        17
                    )

                Tooltip.BackgroundTransparency = 1

                TweenService:Create(
                    Tooltip,
                    FAST,
                    {
                        BackgroundTransparency = 0.04
                    }
                ):Play()
            end)

            obj.MouseLeave:Connect(function()

                local tween =
                    TweenService:Create(
                        Tooltip,
                        FAST,
                        {
                            BackgroundTransparency = 1
                        }
                    )

                tween:Play()

                tween.Completed:Connect(
                    function()
                        Tooltip.Visible = false
                    end
                )
            end)
        end
    end
end

-- ================================================================
-- COMMUNITY PAGE IMAGE
-- ================================================================

if CommunityPage then

    local CommunityLogo =
        CommunityPage:FindFirstChild(
            "CommunityLogo",
            true
        )

    if CommunityLogo and
        CommunityLogo:IsA("ImageLabel") then

        CommunityLogo.Image =
            "rbxassetid://100003155958609"
    end
end

-- ================================================================
-- MAIN LOGO
-- ================================================================

local MainLogo = GetAny(
    "MainLogo",
    "Logo",
    "BrandLogo"
)

if MainLogo and MainLogo:IsA("ImageLabel") then
    MainLogo.Image =
        "rbxassetid://85647271976925"
end

if MainLogo and MainLogo:IsA("ImageButton") then
    MainLogo.Image =
        "rbxassetid://85647271976925"
end

-- ================================================================
-- THUMBNAIL / ALBUM ART
-- ================================================================

local Thumbnail = GetAny(
    "Thumbnail",
    "AlbumArt",
    "AlbumImage",
    "TrackImage"
)

if Thumbnail and
    (Thumbnail:IsA("ImageLabel")
    or Thumbnail:IsA("ImageButton")) then

    Thumbnail.Image =
        "rbxassetid://84404991858137"
end

-- ================================================================
-- BRAND TEXT
-- ================================================================

for _,obj in ipairs(MainGui:GetDescendants()) do

    if obj:IsA("TextLabel")
        or obj:IsA("TextButton") then

        local lower =
            string.lower(obj.Name)

        if lower == "brand"
            or lower == "brandname"
            or lower == "title"
            or lower == "appname" then

            if obj.Text == ""
                or obj:GetAttribute(
                    "AxomuscBrand"
                ) then

                obj.Text =
                    "Axomusc"

                obj:SetAttribute(
                    "AxomuscBrand",
                    true
                )
            end
        end

        if lower == "subtitle"
            or lower == "version"
            or lower == "betatext" then

            if obj:GetAttribute(
                "AxomuscBeta"
            ) then

                obj.Text =
                    "Beta"

            end
        end
    end
end

-- ================================================================
-- BETA BADGE
-- ================================================================

local BetaBadge = MainGui:FindFirstChild(
    "BetaBadge",
    true
)

if not BetaBadge then

    BetaBadge = Instance.new("TextLabel")
    BetaBadge.Name = "BetaBadge"
    BetaBadge.Size = UDim2.fromOffset(42,19)
    BetaBadge.BackgroundColor3 =
        COLORS.Tosca
    BetaBadge.BackgroundTransparency = 0.08
    BetaBadge.BorderSizePixel = 0
    BetaBadge.Font = Enum.Font.GothamBold
    BetaBadge.Text = "BETA"
    BetaBadge.TextColor3 = COLORS.Black
    BetaBadge.TextSize = 8
    BetaBadge.TextXAlignment =
        Enum.TextXAlignment.Center
    BetaBadge.ZIndex = 5000
    BetaBadge.Parent = MainGui

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius =
        UDim.new(0,5)
    badgeCorner.Parent = BetaBadge
end

if MainFrame then

    local title =
        MainFrame:FindFirstChild(
            "Title",
            true
        )

    if title and title:IsA("TextLabel") then

        BetaBadge.Position =
            UDim2.fromOffset(
                title.AbsolutePosition.X +
                title.AbsoluteSize.X +
                7,
                title.AbsolutePosition.Y +
                math.max(
                    0,
                    title.AbsoluteSize.Y/2 - 10
                )
            )
    end
end

-- ================================================================
-- LIVE SOUND STATE
-- ================================================================

Sound.Played:Connect(function()
    UpdatePlayVisual()
end)

Sound.Paused:Connect(function()
    UpdatePlayVisual()
end)

Sound.Stopped:Connect(function()
    UpdatePlayVisual()
end)

-- ================================================================
-- AUTO NEXT
-- ================================================================

Sound.Ended:Connect(function()

    if ReplayEnabled then
        return
    end

    if ShuffleEnabled then

        local musicItems = {}

        for _,obj in ipairs(
            MainGui:GetDescendants()
        ) do

            if obj:IsA("GuiButton")
                and obj:GetAttribute("MusicId") then

                table.insert(
                    musicItems,
                    obj
                )
            end
        end

        if #musicItems > 0 then

            local randomItem =
                musicItems[
                    math.random(
                        1,
                        #musicItems
                    )
                ]

            randomItem:Activate()
        end

    elseif NextButton and
        NextButton:IsA("GuiButton") then

        NextButton:Activate()
    end
end)

-- ================================================================
-- NEXT / PREVIOUS BUTTON
-- ================================================================

local function GetMusicItems()

    local items = {}

    for _,obj in ipairs(
        MainGui:GetDescendants()
    ) do

        if obj:IsA("GuiButton")
            and obj:GetAttribute("MusicId") then

            table.insert(items,obj)
        end
    end

    return items
end

local function PlayRelative(direction)

    local items = GetMusicItems()

    if #items == 0 then
        return
    end

    local current =
        Sound.SoundId:match("%d+")

    local index = 1

    for i,obj in ipairs(items) do

        local id =
            tostring(
                obj:GetAttribute("MusicId")
            ):match("%d+")

        if id == current then
            index = i
            break
        end
    end

    index += direction

    if index > #items then
        index = 1
    elseif index < 1 then
        index = #items
    end

    items[index]:Activate()
end

if NextButton and
    NextButton:IsA("GuiButton") then

    NextButton.Activated:Connect(function()
        Ripple(NextButton)
        PlayRelative(1)
    end)
end

if PreviousButton and
    PreviousButton:IsA("GuiButton") then

    PreviousButton.Activated:Connect(function()
        Ripple(PreviousButton)
        PlayRelative(-1)
    end)
end

-- ================================================================
-- PROGRESS BAR
-- ================================================================

local ProgressBar = GetAny(
    "ProgressBar",
    "Progress",
    "Timeline"
)

local ProgressFill = GetAny(
    "ProgressFill",
    "TimelineFill",
    "ProgressIndicator"
)

local ProgressDragging = false

local function SetProgressFromX(x)

    if not ProgressBar then
        return
    end

    if Sound.TimeLength <= 0 then
        return
    end

    local start =
        ProgressBar.AbsolutePosition.X

    local width =
        ProgressBar.AbsoluteSize.X

    if width <= 0 then
        return
    end

    local alpha =
        math.clamp(
            (x - start) / width,
            0,
            1
        )

    Sound.TimePosition =
        Sound.TimeLength * alpha
end

if ProgressBar then

    ProgressBar.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                ProgressDragging = true
                SetProgressFromX(
                    input.Position.X
                )
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

            if not ProgressDragging then
                return
            end

            if input.UserInputType ==
                Enum.UserInputType.MouseMovement
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                SetProgressFromX(
                    input.Position.X
                )
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1
                or input.UserInputType ==
                Enum.UserInputType.Touch then

                ProgressDragging = false
            end
        end
    )
end

RunService.RenderStepped:Connect(function()

    if not ProgressBar
        or not ProgressFill then
        return
    end

    if ProgressDragging then
        return
    end

    if Sound.TimeLength > 0 then

        local alpha =
            math.clamp(
                Sound.TimePosition /
                Sound.TimeLength,
                0,
                1
            )

        ProgressFill.Size =
            UDim2.new(
                alpha,
                0,
                ProgressFill.Size.Y.Scale,
                ProgressFill.Size.Y.Offset
            )
    end
end)

-- ================================================================
-- TIME LABELS
-- ================================================================

local CurrentTimeLabel = GetAny(
    "CurrentTime",
    "TimeCurrent",
    "Elapsed"
)

local TotalTimeLabel = GetAny(
    "TotalTime",
    "TimeTotal",
    "Duration"
)

local function FormatTime(seconds)

    seconds = math.max(
        0,
        math.floor(
            tonumber(seconds) or 0
        )
    )

    local minutes =
        math.floor(seconds / 60)

    local secs =
        seconds % 60

    return string.format(
        "%d:%02d",
        minutes,
        secs
    )
end

RunService.Heartbeat:Connect(function()

    if CurrentTimeLabel
        and CurrentTimeLabel:IsA("TextLabel") then

        CurrentTimeLabel.Text =
            FormatTime(
                Sound.TimePosition
            )
    end

    if TotalTimeLabel
        and TotalTimeLabel:IsA("TextLabel") then

        TotalTimeLabel.Text =
            FormatTime(
                Sound.TimeLength
            )
    end
end)

-- ================================================================
-- AUDIO RESET
-- ================================================================

local function ResetAudio()

    Sound:Stop()
    Sound.SoundId = ""
    Sound.TimePosition = 0
    Sound.Volume = 0.75
    Sound.PlaybackSpeed = 1
    Sound.Looped = false

    ReplayEnabled = false
    ShuffleEnabled = false
    SpeedIndex = 2
    CurrentSpeed = 1

    UpdatePlayVisual()

    Toast(
        "Music Engine",
        "Audio engine telah di-reset.",
        1.8
    )
end

local ResetAudioButton = GetAny(
    "ResetAudio",
    "ResetButton",
    "AudioReset"
)

if ResetAudioButton and
    ResetAudioButton:IsA("GuiButton") then

    ResetAudioButton.Activated:Connect(
        function()
            Ripple(ResetAudioButton)
            ResetAudio()
        end
    )
end

-- ================================================================
-- COMMUNITY LINK SAFETY
-- ================================================================

local DiscordText = GetAny(
    "DiscordLink",
    "DiscordText"
)

local CommunityText = GetAny(
    "CommunityLink",
    "CommunityText"
)

if DiscordText and
    DiscordText:IsA("TextLabel") then

    DiscordText.Text =
        "discord.gg/dkuXRcS2hY"
end

if CommunityText and
    CommunityText:IsA("TextLabel") then

    CommunityText.Text =
        "roblox.com/share/g/245953568"
end

-- ================================================================
-- DOUBLE CLICK PROTECTION
-- ================================================================

local clickLocks = {}

local function LockedAction(key,callback)

    if clickLocks[key] then
        return
    end

    clickLocks[key] = true

    pcall(callback)

    task.delay(
        0.18,
        function()
            clickLocks[key] = nil
        end
    )
end

for _,obj in ipairs(MainGui:GetDescendants()) do

    if obj:IsA("GuiButton") then

        local original =
            obj.Activated

        if not obj:GetAttribute(
            "ActionGuard"
        ) then

            obj:SetAttribute(
                "ActionGuard",
                true
            )
        end
    end
end

-- ================================================================
-- UI Z-INDEX NORMALIZATION
-- ================================================================

for _,obj in ipairs(
    MainGui:GetDescendants()
) do

    if obj:IsA("GuiObject") then

        if obj.ZIndex <= 0 then
            obj.ZIndex = 1
        end
    end
end

ToastContainer.ZIndex = 10000
Bubble.ZIndex = 11000
Tooltip.ZIndex = 12000
PerformanceFrame.ZIndex = 9000

-- ================================================================
-- INITIAL STATE
-- ================================================================

if MusicPage then
    MusicPage.Visible = true
end

if CommunityPage then
    CommunityPage.Visible = false
end

if FolderPanel then
    FolderPanel.Visible = true
end

if PlaylistPanel then
    PlaylistPanel.Visible = false
end

Bubble.Visible = false

UpdateScale()
UpdatePlayVisual()

-- ================================================================
-- STARTUP TOAST
-- ================================================================

task.delay(
    0.65,
    function()

        Toast(
            "Axomusc (Beta)",
            "Axolion Community Music Engine siap.",
            2.5
        )
    end
)

-- ================================================================
-- FINAL SAFETY MONITOR
-- ================================================================

task.spawn(function()

    while MainGui and MainGui.Parent do

        pcall(function()

            if not MainGui.Enabled then
                MainGui.Enabled = true
            end

            if UIScale.Scale <= 0 then
                UpdateScale()
            end

        end)

        task.wait(2)
    end
end)

-- ================================================================
-- FINAL CLEANUP HOOK
-- ================================================================

local Cleanup = {}

function Cleanup.StopMusic()

    pcall(function()
        Sound:Stop()
    end)

end

function Cleanup.Hide()

    pcall(function()

        if MainFrame then
            MainFrame.Visible = false
        end

        ShowBubble()

    end)

end

function Cleanup.Show()

    pcall(function()
        ShowMain()
    end)

end

function Cleanup.Destroy()

    pcall(function()
        Sound:Destroy()
    end)

    pcall(function()
        ToastContainer:Destroy()
    end)

    pcall(function()
        Tooltip:Destroy()
    end)

    pcall(function()
        Bubble:Destroy()
    end)

    pcall(function()
        MainGui:Destroy()
    end)

end

-- ================================================================
-- FINAL BRAND CONFIGURATION
-- ================================================================

MainGui:SetAttribute(
    "ApplicationName",
    "Axomusc"
)

MainGui:SetAttribute(
    "ApplicationVersion",
    "Beta"
)

MainGui:SetAttribute(
    "CommunityName",
    "Axolion Community"
)

MainGui:SetAttribute(
    "Theme",
    "DarkBlue_Tosca_Black_White"
)

MainGui:SetAttribute(
    "MainLogo",
    "rbxassetid://85647271976925"
)

MainGui:SetAttribute(
    "Thumbnail",
    "rbxassetid://84404991858137"
)

MainGui:SetAttribute(
    "SubLogo",
    "rbxassetid://100003155958609"
)

MainGui:SetAttribute(
    "Discord",
    "https://discord.gg/dkuXRcS2hY"
)

MainGui:SetAttribute(
    "Community",
    "https://www.roblox.com/share/g/245953568"
)

-- ================================================================
-- FINAL STATE
-- ================================================================

Toast(
    "AXOMUSC",
    "Axolion Community • Beta",
    2
)

_G.Axomusc = {
    GUI = MainGui,
    Sound = Sound,
    Cleanup = Cleanup,
    Toggle = ToggleInterface,
    Show = ShowMain,
    Hide = function()
        if MainFrame then
            MainFrame.Visible = false
        end
        ShowBubble()
    end,
    Toast = Toast,
    Copy = CopyText,
    SetPage = SetPage,
    SetVolume = function(value)
        Sound.Volume =
            math.clamp(
                tonumber(value) or 0.75,
                0,
                1
            )
    end,
    SetSpeed = function(value)
        local speed =
            tonumber(value) or 1

        speed =
            math.clamp(
                speed,
                0.5,
                2
            )

        Sound.PlaybackSpeed = speed
        CurrentSpeed = speed
    end
}

-- ================================================================
-- END — AXOMUSC (BETA)
-- AXOLION COMMUNITY
-- ================================================================