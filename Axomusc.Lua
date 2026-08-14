--// ================================================================
--// AXOMUSC BETA
--// AXOLION COMMUNITY
--// PART 1/4 — UI LAYOUT FOUNDATION
--// Roblox Lua / Delta Executor
--// ================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

--// ================================================================
--// DELTA / EXECUTOR GUI ROOT
--// ================================================================

local gethuiSafe

pcall(function()
	gethuiSafe = gethui
end)

local function GetUIParent()
	local parent

	pcall(function()
		if gethuiSafe then
			parent = gethuiSafe()
		end
	end)

	if not parent then
		pcall(function()
			parent = CoreGui
		end)
	end

	if not parent then
		parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	return parent
end

local UIParent = GetUIParent()

--// ================================================================
--// CLEAN OLD INSTANCE
--// ================================================================

pcall(function()
	local old = UIParent:FindFirstChild("Axomusc_Beta_UI")
	if old then
		old:Destroy()
	end
end)

--// ================================================================
--// SERVICES / PLAYER
--// ================================================================

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// ================================================================
--// ASSETS
--// ================================================================

local MAIN_LOGO = "rbxassetid://85647271976925"
local THUMBNAIL = "rbxassetid://84404991858137"
local SUB_LOGO = "rbxassetid://100003155958609"

--// ================================================================
--// COLOR SYSTEM
--// ================================================================

local COLORS = {
	DarkBlue = Color3.fromRGB(5, 15, 31),
	DarkBlue2 = Color3.fromRGB(7, 21, 42),
	DarkBlue3 = Color3.fromRGB(10, 30, 52),

	Black = Color3.fromRGB(3, 5, 9),
	Black2 = Color3.fromRGB(7, 8, 12),
	Black3 = Color3.fromRGB(12, 14, 18),

	Tosca = Color3.fromRGB(39, 226, 204),
	ToscaDark = Color3.fromRGB(20, 148, 138),
	ToscaSoft = Color3.fromRGB(91, 245, 226),

	White = Color3.fromRGB(245, 250, 252),
	WhiteSoft = Color3.fromRGB(185, 199, 205),
	Gray = Color3.fromRGB(112, 127, 137),
	GrayDark = Color3.fromRGB(48, 58, 66),

	Transparent = Color3.fromRGB(255, 255, 255)
}

--// ================================================================
--// TWEEN PRESETS
--// ================================================================

local TWEEN = {
	Fast = TweenInfo.new(
		0.16,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	),

	Normal = TweenInfo.new(
		0.28,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	),

	Slow = TweenInfo.new(
		0.45,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	),

	Spring = TweenInfo.new(
		0.42,
		Enum.EasingStyle.Spring,
		Enum.EasingDirection.Out
	)
}

local function Tween(object, info, properties)
	if not object then
		return nil
	end

	local tween

	pcall(function()
		tween = TweenService:Create(
			object,
			info or TWEEN.Normal,
			properties
		)

		tween:Play()
	end)

	return tween
end

--// ================================================================
--// SAFE INSTANCE CREATION
--// ================================================================

local function New(className, properties, parent)
	local object

	local success = pcall(function()
		object = Instance.new(className)
	end)

	if not success or not object then
		return nil
	end

	if properties then
		for property, value in pairs(properties) do
			pcall(function()
				object[property] = value
			end)
		end
	end

	if parent then
		object.Parent = parent
	end

	return object
end

local function AddCorner(parent, radius)
	local corner = New("UICorner", {
		CornerRadius = UDim.new(0, radius or 8)
	}, parent)

	return corner
end

local function AddStroke(parent, color, thickness, transparency)
	local stroke = New("UIStroke", {
		Color = color or COLORS.Tosca,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, parent)

	return stroke
end

local function AddPadding(parent, left, right, top, bottom)
	return New("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0)
	}, parent)
end

local function AddList(parent, direction, padding)
	local layout = New("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 0)
	}, parent)

	return layout
end

--// ================================================================
--// SCREEN GUI
--// ================================================================

local ScreenGui = New("ScreenGui", {
	Name = "Axomusc_Beta_UI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999999
}, UIParent)

if not ScreenGui then
	return
end

--// ================================================================
--// GLOBAL SCALE
--// ================================================================

local GlobalScale = New("UIScale", {
	Scale = 1
}, ScreenGui)

local function UpdateScale()
	local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)

	local width = viewport.X
	local height = viewport.Y

	local scaleByWidth = width / 1100
	local scaleByHeight = height / 700

	local calculated = math.min(scaleByWidth, scaleByHeight)

	if calculated < 0.58 then
		calculated = 0.58
	end

	if calculated > 1.12 then
		calculated = 1.12
	end

	Tween(
		GlobalScale,
		TWEEN.Normal,
		{
			Scale = calculated
		}
	)
end

UpdateScale()

if Camera then
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		UpdateScale()
	end)
end

--// ================================================================
--// BACKDROP
--// ================================================================

local Backdrop = New("Frame", {
	Name = "Backdrop",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.92,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0, 0)
}, ScreenGui)

--// ================================================================
--// MAIN APPLICATION CONTAINER
--// ================================================================

local Main = New("Frame", {
	Name = "MainApplication",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 930, 0, 590),
	BackgroundColor3 = COLORS.DarkBlue,
	BackgroundTransparency = 0.055,
	BorderSizePixel = 0,
	ClipsDescendants = true
}, ScreenGui)

AddCorner(Main, 15)

local MainStroke = AddStroke(
	Main,
	COLORS.Tosca,
	1.4,
	0.05
)

--// ================================================================
--// MAIN BACKGROUND GLASS LAYERS
--// ================================================================

local GlassLayer = New("Frame", {
	Name = "AcrylicGlass",
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.22,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Position = UDim2.fromScale(0, 0),
	ZIndex = 1
}, Main)

AddCorner(GlassLayer, 15)

local GlassGradient = New("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLORS.DarkBlue3),
		ColorSequenceKeypoint.new(0.45, COLORS.DarkBlue),
		ColorSequenceKeypoint.new(1, COLORS.Black)
	}),
	Rotation = 35
}, GlassLayer)

--// ================================================================
--// TOP HEADER
--// ================================================================

local Header = New("Frame", {
	Name = "Header",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.16,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 74),
	ZIndex = 5
}, Main)

AddCorner(Header, 15)

local HeaderBottom = New("Frame", {
	Name = "HeaderBottomMask",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.16,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -15),
	Size = UDim2.new(1, 0, 0, 15),
	ZIndex = 5
}, Header)

--// ================================================================
--// HEADER LOGO
--// ================================================================

local HeaderLogoHolder = New("Frame", {
	Name = "LogoHolder",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 17, 0, 10),
	Size = UDim2.new(0, 53, 0, 53),
	ZIndex = 7
}, Header)

AddCorner(HeaderLogoHolder, 27)
AddStroke(HeaderLogoHolder, COLORS.Tosca, 1.2, 0.15)

local HeaderLogo = New("ImageLabel", {
	Name = "MainLogo",
	BackgroundTransparency = 1,
	Image = MAIN_LOGO,
	ImageColor3 = COLORS.White,
	ScaleType = Enum.ScaleType.Fit,
	Size = UDim2.new(1, -7, 1, -7),
	Position = UDim2.new(0, 3.5, 0, 3.5),
	ZIndex = 8
}, HeaderLogoHolder)

AddCorner(HeaderLogo, 25)

--// ================================================================
--// HEADER BRAND
--// ================================================================

local BrandContainer = New("Frame", {
	Name = "BrandContainer",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 84, 0, 8),
	Size = UDim2.new(0, 300, 0, 58),
	ZIndex = 7
}, Header)

local BrandTitle = New("TextLabel", {
	Name = "BrandTitle",
	BackgroundTransparency = 1,
	Text = "Axomusc",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 23,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 32),
	ZIndex = 8
}, BrandContainer)

local BetaBadge = New("TextLabel", {
	Name = "BetaBadge",
	BackgroundColor3 = COLORS.Tosca,
	BackgroundTransparency = 0.05,
	Text = "BETA",
	TextColor3 = COLORS.Black,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	Position = UDim2.new(0, 112, 0, 8),
	Size = UDim2.new(0, 43, 0, 20),
	ZIndex = 9
}, BrandContainer)

AddCorner(BetaBadge, 5)

local BrandSubtitle = New("TextLabel", {
	Name = "BrandSubtitle",
	BackgroundTransparency = 1,
	Text = "By. Axolion Community",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	Position = UDim2.new(0, 1, 0, 30),
	Size = UDim2.new(1, 0, 0, 22),
	ZIndex = 8
}, BrandContainer)

--// ================================================================
--// HEADER STATUS
--// ================================================================

local HeaderStatus = New("Frame", {
	Name = "HeaderStatus",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -58, 0, 10),
	Size = UDim2.new(0, 280, 0, 54),
	ZIndex = 8
}, Header)

local StatusTitle = New("TextLabel", {
	Name = "StatusTitle",
	BackgroundTransparency = 1,
	Text = "AXOLION ENGINE",
	TextColor3 = COLORS.ToscaSoft,
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 0, 0, 3),
	Size = UDim2.new(1, 0, 0, 18),
	ZIndex = 9
}, HeaderStatus)

local PerformanceLabel = New("TextLabel", {
	Name = "Performance",
	BackgroundTransparency = 1,
	Text = "FPS --   PING --",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.Code,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 0, 0, 22),
	Size = UDim2.new(1, 0, 0, 18),
	ZIndex = 9
}, HeaderStatus)

--// ================================================================
--// MINIMIZE BUTTON
--// ================================================================

local MinimizeButton = New("TextButton", {
	Name = "MinimizeButton",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	Text = "−",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 23,
	Position = UDim2.new(1, -48, 0, 20),
	Size = UDim2.new(0, 29, 0, 29),
	ZIndex = 12
}, Header)

AddCorner(MinimizeButton, 7)
AddStroke(MinimizeButton, COLORS.Tosca, 1, 0.35)

--// ================================================================
--// BODY
--// ================================================================

local Body = New("Frame", {
	Name = "Body",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 74),
	Size = UDim2.new(1, 0, 1, -74),
	ZIndex = 4
}, Main)

--// ================================================================
--// SIDEBAR
--// ================================================================

local Sidebar = New("Frame", {
	Name = "CollapsibleSidebar",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 190, 1, 0),
	ZIndex = 6,
	ClipsDescendants = true
}, Body)

AddCorner(Sidebar, 12)

local SidebarStroke = AddStroke(
	Sidebar,
	COLORS.ToscaDark,
	1,
	0.45
)

--// ================================================================
--// SIDEBAR HEADER
--// ================================================================

local SidebarHeader = New("Frame", {
	Name = "SidebarHeader",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 68),
	ZIndex = 8
}, Sidebar)

local SidebarMenuButton = New("TextButton", {
	Name = "SidebarToggle",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Text = "☰",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	Position = UDim2.new(0, 13, 0, 16),
	Size = UDim2.new(0, 40, 0, 40),
	ZIndex = 10
}, SidebarHeader)

AddCorner(SidebarMenuButton, 9)
AddStroke(SidebarMenuButton, COLORS.Tosca, 1, 0.55)

local SidebarTitle = New("TextLabel", {
	Name = "SidebarTitle",
	BackgroundTransparency = 1,
	Text = "WORKSPACE",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 66, 0, 14),
	Size = UDim2.new(1, -72, 0, 20),
	ZIndex = 9
}, SidebarHeader)

local SidebarSubtitle = New("TextLabel", {
	Name = "SidebarSubtitle",
	BackgroundTransparency = 1,
	Text = "Axolion System",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Gotham,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 66, 0, 33),
	Size = UDim2.new(1, -72, 0, 17),
	ZIndex = 9
}, SidebarHeader)

--// ================================================================
--// SIDEBAR NAVIGATION CONTAINER
--// ================================================================

local Navigation = New("ScrollingFrame", {
	Name = "Navigation",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 8, 0, 75),
	Size = UDim2.new(1, -16, 1, -91),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 0,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ZIndex = 8
}, Sidebar)

local NavigationLayout = AddList(
	Navigation,
	Enum.FillDirection.Vertical,
	7
)

--// ================================================================
--// SIDEBAR SECTION LABEL
--// ================================================================

local NavigationLabel = New("TextLabel", {
	Name = "NavigationLabel",
	BackgroundTransparency = 1,
	Text = "MAIN MENU",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.GothamBold,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, -8, 0, 23),
	ZIndex = 9
}, Navigation)

--// ================================================================
--// NAVIGATION BUTTON FACTORY
--// ================================================================

local NavigationButtons = {}

local function CreateNavigationButton(name, icon, title, description)
	local Button = New("TextButton", {
		Name = name,
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.DarkBlue2,
		BackgroundTransparency = 0.52,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, -8, 0, 57),
		ZIndex = 10
	}, Navigation)

	AddCorner(Button, 9)

	local ButtonStroke = AddStroke(
		Button,
		COLORS.Tosca,
		1,
		1
	)

	local IconHolder = New("Frame", {
		Name = "IconHolder",
		BackgroundColor3 = COLORS.Black,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(0, 41, 0, 41),
		ZIndex = 11
	}, Button)

	AddCorner(IconHolder, 9)

	local Icon = New("TextLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Text = icon,
		TextColor3 = COLORS.Tosca,
		Font = Enum.Font.GothamBold,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 12
	}, IconHolder)

	local Title = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = COLORS.White,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Position = UDim2.new(0, 60, 0, 7),
		Size = UDim2.new(1, -67, 0, 20),
		ZIndex = 12
	}, Button)

	local Description = New("TextLabel", {
		Name = "Description",
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = COLORS.Gray,
		Font = Enum.Font.Gotham,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Position = UDim2.new(0, 60, 0, 27),
		Size = UDim2.new(1, -67, 0, 18),
		ZIndex = 12
	}, Button)

	local Indicator = New("Frame", {
		Name = "ActiveIndicator",
		BackgroundColor3 = COLORS.Tosca,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 2, 0.5, -11),
		Size = UDim2.new(0, 3, 0, 22),
		ZIndex = 13
	}, Button)

	AddCorner(Indicator, 3)

	NavigationButtons[name] = {
		Button = Button,
		Stroke = ButtonStroke,
		IconHolder = IconHolder,
		Icon = Icon,
		Title = Title,
		Description = Description,
		Indicator = Indicator
	}

	return Button
end

local MusicNavigation = CreateNavigationButton(
	"MusicEngine",
	"♫",
	"Music Engine",
	"Audio workspace"
)

local CommunityNavigation = CreateNavigationButton(
	"Community",
	"◆",
	"Axolion Community",
	"Community hub"
)

--// ================================================================
--// SIDEBAR FOOTER
--// ================================================================

local SidebarFooter = New("Frame", {
	Name = "SidebarFooter",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 10, 1, -55),
	Size = UDim2.new(1, -20, 0, 42),
	ZIndex = 10
}, Sidebar)

local FooterLine = New("Frame", {
	Name = "Line",
	BackgroundColor3 = COLORS.ToscaDark,
	BackgroundTransparency = 0.65,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 1),
	ZIndex = 11
}, SidebarFooter)

local FooterText = New("TextLabel", {
	Name = "FooterText",
	BackgroundTransparency = 1,
	Text = "AXOLION COMMUNITY",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.GothamBold,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 1, 0, 10),
	Size = UDim2.new(1, 0, 0, 15),
	ZIndex = 11
}, SidebarFooter)

local FooterVersion = New("TextLabel", {
	Name = "FooterVersion",
	BackgroundTransparency = 1,
	Text = "AXOMUSC BETA",
	TextColor3 = COLORS.ToscaDark,
	Font = Enum.Font.Code,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 1, 0, 25),
	Size = UDim2.new(1, 0, 0, 13),
	ZIndex = 11
}, SidebarFooter)

--// ================================================================
--// WORKSPACE AREA
--// ================================================================

local WorkspaceArea = New("Frame", {
	Name = "WorkspaceArea",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 190, 0, 0),
	Size = UDim2.new(1, -190, 1, 0),
	ZIndex = 5,
	ClipsDescendants = true
}, Body)

--// ================================================================
--// WORKSPACE HEADER
--// ================================================================

local WorkspaceHeader = New("Frame", {
	Name = "WorkspaceHeader",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 20, 0, 15),
	Size = UDim2.new(1, -40, 0, 48),
	ZIndex = 7
}, WorkspaceArea)

local WorkspaceTitle = New("TextLabel", {
	Name = "WorkspaceTitle",
	BackgroundTransparency = 1,
	Text = "Music Engine",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 260, 0, 25),
	ZIndex = 8
}, WorkspaceHeader)

local WorkspaceDescription = New("TextLabel", {
	Name = "WorkspaceDescription",
	BackgroundTransparency = 1,
	Text = "Professional audio workspace",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Gotham,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 1, 0, 25),
	Size = UDim2.new(0, 300, 0, 17),
	ZIndex = 8
}, WorkspaceHeader)

local WorkspaceAccent = New("Frame", {
	Name = "Accent",
	BackgroundColor3 = COLORS.Tosca,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, 2),
	Size = UDim2.new(0, 42, 0, 2),
	ZIndex = 9
}, WorkspaceHeader)

AddCorner(WorkspaceAccent, 2)

--// ================================================================
--// MUSIC WORKSPACE
--// ================================================================

local MusicWorkspace = New("Frame", {
	Name = "MusicWorkspace",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 65),
	Size = UDim2.new(1, 0, 1, -65),
	ZIndex = 6
}, WorkspaceArea)

--// ================================================================
--// LEFT AUDIO LIBRARY PANEL
--// ================================================================

local AudioLibraryPanel = New("Frame", {
	Name = "AudioLibraryPanel",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.22,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 18, 0, 4),
	Size = UDim2.new(0, 175, 1, -21),
	ZIndex = 8
}, MusicWorkspace)

AddCorner(AudioLibraryPanel, 11)
AddStroke(AudioLibraryPanel, COLORS.ToscaDark, 1, 0.58)

local AudioLibraryHeader = New("Frame", {
	Name = "Header",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 10),
	Size = UDim2.new(1, -24, 0, 37),
	ZIndex = 9
}, AudioLibraryPanel)

local AudioLibraryTitle = New("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Text = "AUDIO LIBRARY",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, 0, 0, 18),
	ZIndex = 10
}, AudioLibraryHeader)

local AudioLibrarySubtitle = New("TextLabel", {
	Name = "Subtitle",
	BackgroundTransparency = 1,
	Text = "Folders & Sources",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Gotham,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 0, 0, 17),
	Size = UDim2.new(1, 0, 0, 16),
	ZIndex = 10
}, AudioLibraryHeader)

local AudioSearch = New("TextBox", {
	Name = "Search",
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	PlaceholderText = "Search folders...",
	PlaceholderColor3 = COLORS.Gray,
	Text = "",
	TextColor3 = COLORS.White,
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 10, 0, 53),
	Size = UDim2.new(1, -20, 0, 31),
	ZIndex = 10
}, AudioLibraryPanel)

AddCorner(AudioSearch, 7)
AddStroke(AudioSearch, COLORS.ToscaDark, 1, 0.78)
AddPadding(AudioSearch, 10, 8, 0, 0)

local AudioFolderContainer = New("ScrollingFrame", {
	Name = "FolderContainer",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 10, 0, 94),
	Size = UDim2.new(1, -20, 1, -104),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = COLORS.ToscaDark,
	ZIndex = 10
}, AudioLibraryPanel)

AddList(
	AudioFolderContainer,
	Enum.FillDirection.Vertical,
	5
)

--// ================================================================
--// CENTER PLAYER PANEL
--// ================================================================

local PlayerPanel = New("Frame", {
	Name = "PlayerPanel",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.19,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 204, 0, 4),
	Size = UDim2.new(1, -399, 1, -21),
	ZIndex = 8
}, MusicWorkspace)

AddCorner(PlayerPanel, 11)
AddStroke(PlayerPanel, COLORS.ToscaDark, 1, 0.62)

--// ================================================================
--// ALBUM ART CONTAINER
--// ================================================================

local AlbumHolder = New("Frame", {
	Name = "AlbumHolder",
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Position = UDim2.new(0.5, 0, 0, 21),
	Size = UDim2.new(0, 205, 0, 205),
	ZIndex = 10
}, PlayerPanel)

AddCorner(AlbumHolder, 14)
AddStroke(AlbumHolder, COLORS.Tosca, 1.4, 0.32)

local AlbumArt = New("ImageLabel", {
	Name = "AlbumArt",
	BackgroundColor3 = COLORS.DarkBlue,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Image = THUMBNAIL,
	ImageColor3 = COLORS.White,
	ScaleType = Enum.ScaleType.Crop,
	Position = UDim2.new(0, 5, 0, 5),
	Size = UDim2.new(1, -10, 1, -10),
	ZIndex = 11
}, AlbumHolder)

AddCorner(AlbumArt, 11)

local AlbumOverlay = New("Frame", {
	Name = "Overlay",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.58,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 12
}, AlbumHolder)

AddCorner(AlbumOverlay, 11)

local AlbumGlow = New("Frame", {
	Name = "Glow",
	BackgroundColor3 = COLORS.Tosca,
	BackgroundTransparency = 0.91,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, 20, 1, 20),
	ZIndex = 9
}, AlbumHolder)

AddCorner(AlbumGlow, 18)

--// ================================================================
--// TRACK INFORMATION
--// ================================================================

local TrackInfo = New("Frame", {
	Name = "TrackInfo",
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 0, 0, 236),
	Size = UDim2.new(1, -50, 0, 62),
	ZIndex = 10
}, PlayerPanel)

local TrackTitle = New("TextLabel", {
	Name = "TrackTitle",
	BackgroundTransparency = 1,
	Text = "No Track Selected",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 0, 27),
	ZIndex = 11
}, TrackInfo)

local TrackArtist = New("TextLabel", {
	Name = "TrackArtist",
	BackgroundTransparency = 1,
	Text = "Axolion Community",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.Gotham,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	Position = UDim2.new(0, 0, 0, 28),
	Size = UDim2.new(1, 0, 0, 19),
	ZIndex = 11
}, TrackInfo)

--// ================================================================
--// PROGRESS BAR FOUNDATION
--// ================================================================

local ProgressContainer = New("Frame", {
	Name = "Progress",
	BackgroundColor3 = COLORS.DarkBlue3,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 24, 0, 307),
	Size = UDim2.new(1, -48, 0, 5),
	ZIndex = 10
}, PlayerPanel)

AddCorner(ProgressContainer, 3)

local ProgressFill = New("Frame", {
	Name = "Fill",
	BackgroundColor3 = COLORS.Tosca,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 0, 1, 0),
	ZIndex = 11
}, ProgressContainer)

AddCorner(ProgressFill, 3)

local ProgressKnob = New("Frame", {
	Name = "Knob",
	BackgroundColor3 = COLORS.White,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0, 0, 0.5, 0),
	Size = UDim2.new(0, 9, 0, 9),
	ZIndex = 12
}, ProgressContainer)

AddCorner(ProgressKnob, 5)

local TimeCurrent = New("TextLabel", {
	Name = "CurrentTime",
	BackgroundTransparency = 1,
	Text = "0:00",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Code,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 24, 0, 316),
	Size = UDim2.new(0, 50, 0, 17),
	ZIndex = 10
}, PlayerPanel)

local TimeTotal = New("TextLabel", {
	Name = "TotalTime",
	BackgroundTransparency = 1,
	Text = "0:00",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Code,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -74, 0, 316),
	Size = UDim2.new(0, 50, 0, 17),
	ZIndex = 10
}, PlayerPanel)

--// ================================================================
--// CLASSIC MUSIC CONTROLS
--// ================================================================

local Controls = New("Frame", {
	Name = "MusicControls",
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, 0, 0, 344),
	Size = UDim2.new(1, -50, 0, 54),
	ZIndex = 10
}, PlayerPanel)

local ControlsLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 8)
}, Controls)

local function CreateControlButton(name, text, size, accent)
	local Button = New("TextButton", {
		Name = name,
		AutoButtonColor = false,
		BackgroundColor3 = accent and COLORS.Tosca or COLORS.DarkBlue2,
		BackgroundTransparency = accent and 0.02 or 0.15,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = accent and COLORS.Black or COLORS.White,
		Font = Enum.Font.GothamBold,
		TextSize = accent and 17 or 11,
		Size = size or UDim2.new(0, 37, 0, 37),
		ZIndex = 12
	}, Controls)

	AddCorner(Button, accent and 21 or 9)
	AddStroke(
		Button,
		accent and COLORS.ToscaSoft or COLORS.ToscaDark,
		1,
		accent and 0.1 or 0.65
	)

	return Button
end

local RepeatButton = CreateControlButton(
	"Repeat",
	"↻",
	UDim2.new(0, 34, 0, 34),
	false
)

local PlayOnceButton = CreateControlButton(
	"PlayOnce",
	"1×",
	UDim2.new(0, 34, 0, 34),
	false
)

local ShuffleButton = CreateControlButton(
	"Shuffle",
	"⌘",
	UDim2.new(0, 34, 0, 34),
	false
)

local BackButton = CreateControlButton(
	"Back",
	"‹‹",
	UDim2.new(0, 38, 0, 38),
	false
)

local PlayPauseButton = CreateControlButton(
	"PlayPause",
	"▶",
	UDim2.new(0, 48, 0, 48),
	true
)

local NextButton = CreateControlButton(
	"Next",
	"››",
	UDim2.new(0, 38, 0, 38),
	false
)

--// ================================================================
--// VOLUME FOUNDATION
--// ================================================================

local VolumePanel = New("Frame", {
	Name = "Volume",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 24, 1, -70),
	Size = UDim2.new(1, -48, 0, 42),
	ZIndex = 10
}, PlayerPanel)

local VolumeTitle = New("TextLabel", {
	Name = "VolumeTitle",
	BackgroundTransparency = 1,
	Text = "VOLUME",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.GothamBold,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 55, 0, 16),
	ZIndex = 11
}, VolumePanel)

local VolumeValue = New("TextLabel", {
	Name = "VolumeValue",
	BackgroundTransparency = 1,
	Text = "100%",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.Code,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -45, 0, 0),
	Size = UDim2.new(0, 45, 0, 16),
	ZIndex = 11
}, VolumePanel)

local VolumeBar = New("Frame", {
	Name = "Slider",
	BackgroundColor3 = COLORS.DarkBlue3,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 0, 22),
	Size = UDim2.new(1, 0, 0, 5),
	ZIndex = 11
}, VolumePanel)

AddCorner(VolumeBar, 3)

local VolumeFill = New("Frame", {
	Name = "Fill",
	BackgroundColor3 = COLORS.Tosca,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 12
}, VolumeBar)

AddCorner(VolumeFill, 3)

local VolumeKnob = New("Frame", {
	Name = "Knob",
	BackgroundColor3 = COLORS.White,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, 0, 0.5, 0),
	Size = UDim2.new(0, 9, 0, 9),
	ZIndex = 13
}, VolumeBar)

AddCorner(VolumeKnob, 5)

--// ================================================================
--// RIGHT PLAYLIST PANEL
--// ================================================================

local PlaylistPanel = New("Frame", {
	Name = "PlaylistPanel",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.22,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -18, 0, 4),
	Size = UDim2.new(0, 183, 1, -21),
	ZIndex = 8
}, MusicWorkspace)

AddCorner(PlaylistPanel, 11)
AddStroke(PlaylistPanel, COLORS.ToscaDark, 1, 0.58)

local PlaylistHeader = New("Frame", {
	Name = "Header",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 10),
	Size = UDim2.new(1, -24, 0, 42),
	ZIndex = 10
}, PlaylistPanel)

local PlaylistTitle = New("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Text = "PLAYLIST",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, -35, 0, 18),
	ZIndex = 11
}, PlaylistHeader)

local PlaylistSubtitle = New("TextLabel", {
	Name = "Subtitle",
	BackgroundTransparency = 1,
	Text = "Current queue",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Gotham,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 0, 0, 18),
	Size = UDim2.new(1, -35, 0, 16),
	ZIndex = 11
}, PlaylistHeader)

local PlaylistAddButton = New("TextButton", {
	Name = "AddPlaylist",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.Tosca,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Text = "+",
	TextColor3 = COLORS.Black,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	Position = UDim2.new(1, -29, 0, 1),
	Size = UDim2.new(0, 27, 0, 27),
	ZIndex = 12
}, PlaylistHeader)

AddCorner(PlaylistAddButton, 7)

local PlaylistContainer = New("ScrollingFrame", {
	Name = "PlaylistContainer",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 10, 0, 58),
	Size = UDim2.new(1, -20, 1, -69),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = COLORS.ToscaDark,
	ZIndex = 10
}, PlaylistPanel)

AddList(
	PlaylistContainer,
	Enum.FillDirection.Vertical,
	5
)

--// ================================================================
--// COMMUNITY WORKSPACE
--// ================================================================

local CommunityWorkspace = New("Frame", {
	Name = "CommunityWorkspace",
	BackgroundTransparency = 1,
	Visible = false,
	Position = UDim2.new(0, 0, 0, 65),
	Size = UDim2.new(1, 0, 1, -65),
	ZIndex = 6
}, WorkspaceArea)

--// ================================================================
--// COMMUNITY HERO
--// ================================================================

local CommunityHero = New("Frame", {
	Name = "CommunityHero",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.18,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 18, 0, 4),
	Size = UDim2.new(1, -36, 0, 170),
	ZIndex = 8
}, CommunityWorkspace)

AddCorner(CommunityHero, 13)
AddStroke(CommunityHero, COLORS.Tosca, 1.2, 0.48)

local CommunityLogoHolder = New("Frame", {
	Name = "SubLogoHolder",
	BackgroundColor3 = COLORS.DarkBlue,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 19, 0.5, -54),
	Size = UDim2.new(0, 108, 0, 108),
	ZIndex = 10
}, CommunityHero)

AddCorner(CommunityLogoHolder, 54)
AddStroke(CommunityLogoHolder, COLORS.Tosca, 1.5, 0.22)

local CommunityLogo = New("ImageLabel", {
	Name = "SubLogo",
	BackgroundTransparency = 1,
	Image = SUB_LOGO,
	ScaleType = Enum.ScaleType.Fit,
	Position = UDim2.new(0, 7, 0, 7),
	Size = UDim2.new(1, -14, 1, -14),
	ZIndex = 11
}, CommunityLogoHolder)

AddCorner(CommunityLogo, 50)

local CommunityHeroTitle = New("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Text = "Axolion Community",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
	Position = UDim2.new(0, 150, 0, 39),
	Size = UDim2.new(1, -175, 0, 35),
	ZIndex = 10
}, CommunityHero)

local CommunityHeroSubtitle = New("TextLabel", {
	Name = "Subtitle",
	BackgroundTransparency = 1,
	Text = "Official community hub • Axomusc Beta",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 151, 0, 75),
	Size = UDim2.new(1, -176, 0, 20),
	ZIndex = 10
}, CommunityHero)

local CommunityHeroDescription = New("TextLabel", {
	Name = "Description",
	BackgroundTransparency = 1,
	Text = "A centralized space for the Axolion Community.",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.Gotham,
	TextSize = 9,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Position = UDim2.new(0, 151, 0, 101),
	Size = UDim2.new(1, -176, 0, 38),
	ZIndex = 10
}, CommunityHero)

--// ================================================================
--// COMMUNITY INFORMATION PANEL
--// ================================================================

local CommunityInfoPanel = New("Frame", {
	Name = "CommunityInfo",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 18, 0, 187),
	Size = UDim2.new(1, -36, 1, -204),
	ZIndex = 8
}, CommunityWorkspace)

AddCorner(CommunityInfoPanel, 13)
AddStroke(CommunityInfoPanel, COLORS.ToscaDark, 1, 0.62)

local CommunityInfoTitle = New("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Text = "COMMUNITY INFORMATION",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 18, 0, 15),
	Size = UDim2.new(1, -36, 0, 20),
	ZIndex = 10
}, CommunityInfoPanel)

local CommunityInfoAccent = New("Frame", {
	Name = "Accent",
	BackgroundColor3 = COLORS.Tosca,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 18, 0, 38),
	Size = UDim2.new(0, 45, 0, 2),
	ZIndex = 11
}, CommunityInfoPanel)

AddCorner(CommunityInfoAccent, 2)

--// ================================================================
--// SMART MINIMIZE BUBBLE
--// ================================================================

local Bubble = New("TextButton", {
	Name = "SmartMinimizeBubble",
	AutoButtonColor = false,
	Visible = false,
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Text = "",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.08, 0.5),
	Size = UDim2.new(0, 60, 0, 60),
	ZIndex = 100
}, ScreenGui)

AddCorner(Bubble, 30)
AddStroke(Bubble, COLORS.Tosca, 1.7, 0.05)

local BubbleLogo = New("ImageLabel", {
	Name = "Logo",
	BackgroundTransparency = 1,
	Image = MAIN_LOGO,
	ScaleType = Enum.ScaleType.Fit,
	Position = UDim2.new(0, 7, 0, 7),
	Size = UDim2.new(1, -14, 1, -14),
	ZIndex = 101
}, Bubble)

AddCorner(BubbleLogo, 30)

--// ================================================================
--// TOAST CONTAINER
--// ================================================================

local ToastContainer = New("Frame", {
	Name = "ToastContainer",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.new(0, 285, 0, 300),
	ZIndex = 200
}, ScreenGui)

local ToastLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 7)
}, ToastContainer)

--// ================================================================
--// DRAG HANDLE
--// ================================================================

local DragHandle = New("TextButton", {
	Name = "DragHandle",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "",
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, -70, 0, 74),
	ZIndex = 20
}, Header)

--// ================================================================
--// LAYOUT STATE
--// ================================================================

local UIState = {
	SidebarOpen = true,
	CurrentPage = "MusicEngine",
	Minimized = false,
	Dragging = false,
	DragInput = nil,
	DragStart = nil,
	StartPosition = nil
}

--// ================================================================
--// CORNER SNAP DRAG SYSTEM
--// ================================================================

local function ClampMainPosition(position)
	local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)

	local scale = GlobalScale and GlobalScale.Scale or 1

	local halfWidth = (Main.AbsoluteSize.X * 0.5)
	local halfHeight = (Main.AbsoluteSize.Y * 0.5)

	local minX = 8
	local maxX = viewport.X - 8

	local minY = 8
	local maxY = viewport.Y - 8

	local x = math.clamp(position.X.Offset, minX - halfWidth, maxX - halfWidth)
	local y = math.clamp(position.Y.Offset, minY - halfHeight, maxY - halfHeight)

	return UDim2.new(
		0,
		x,
		0,
		y
	)
end

local function UpdateDrag(input)
	if not UIState.Dragging then
		return
	end

	if not UIState.DragStart or not UIState.StartPosition then
		return
	end

	local delta = input.Position - UIState.DragStart

	local target = UDim2.new(
		UIState.StartPosition.X.Scale,
		UIState.StartPosition.X.Offset + delta.X,
		UIState.StartPosition.Y.Scale,
		UIState.StartPosition.Y.Offset + delta.Y
	)

	Tween(
		Main,
		TWEEN.Fast,
		{
			Position = target
		}
	)
end

DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		UIState.Dragging = true
		UIState.DragInput = input
		UIState.DragStart = input.Position
		UIState.StartPosition = Main.Position
	end
end)

DragHandle.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		UIState.DragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == UIState.DragInput then
		UpdateDrag(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		UIState.Dragging = false
		UIState.DragInput = nil

		local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)

		local absolutePosition = Main.AbsolutePosition
		local absoluteSize = Main.AbsoluteSize

		local centerX = absolutePosition.X + absoluteSize.X / 2
		local centerY = absolutePosition.Y + absoluteSize.Y / 2

		local snapLeft = centerX < viewport.X * 0.18
		local snapRight = centerX > viewport.X * 0.82
		local snapTop = centerY < viewport.Y * 0.18
		local snapBottom = centerY > viewport.Y * 0.82

		if snapLeft or snapRight or snapTop or snapBottom then
			local targetX = centerX
			local targetY = centerY

			if snapLeft then
				targetX = absoluteSize.X / 2 + 10
			elseif snapRight then
				targetX = viewport.X - absoluteSize.X / 2 - 10
			end

			if snapTop then
				targetY = absoluteSize.Y / 2 + 10
			elseif snapBottom then
				targetY = viewport.Y - absoluteSize.Y / 2 - 10
			end

			Tween(
				Main,
				TWEEN.Spring,
				{
					Position = UDim2.fromOffset(targetX, targetY)
				}
			)
		end
	end
end)

--// ================================================================
--// BUTTON HOVER FOUNDATION
--// ================================================================

local function BindHover(button, normalColor, hoverColor)
	if not button then
		return
	end

	button.MouseEnter:Connect(function()
		Tween(
			button,
			TWEEN.Fast,
			{
				BackgroundColor3 = hoverColor or COLORS.DarkBlue3
			}
		)
	end)

	button.MouseLeave:Connect(function()
		Tween(
			button,
			TWEEN.Fast,
			{
				BackgroundColor3 = normalColor or COLORS.DarkBlue2
			}
		)
	end)
end

BindHover(
	MinimizeButton,
	COLORS.Black,
	COLORS.DarkBlue3
)

BindHover(
	SidebarMenuButton,
	COLORS.DarkBlue2,
	COLORS.DarkBlue3
)

BindHover(
	PlaylistAddButton,
	COLORS.Tosca,
	COLORS.ToscaSoft
)

for _, data in pairs(NavigationButtons) do
	BindHover(
		data.Button,
		COLORS.DarkBlue2,
		COLORS.DarkBlue3
	)
end

for _, button in ipairs({
	RepeatButton,
	PlayOnceButton,
	ShuffleButton,
	BackButton,
	PlayPauseButton,
	NextButton
}) do
	if button ~= PlayPauseButton then
		BindHover(
			button,
			COLORS.DarkBlue2,
			COLORS.DarkBlue3
		)
	else
		BindHover(
			button,
			COLORS.Tosca,
			COLORS.ToscaSoft
		)
	end
end

--// ================================================================
--// RIPPLE FOUNDATION
--// ================================================================

local function CreateRipple(button)
	if not button then
		return
	end

	local ripple = New("Frame", {
		Name = "Ripple",
		BackgroundColor3 = COLORS.White,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 0, 0, 0),
		ZIndex = button.ZIndex + 2
	}, button)

	AddCorner(ripple, 100)

	Tween(
		ripple,
		TWEEN.Normal,
		{
			Size = UDim2.new(1.8, 0, 1.8, 0),
			BackgroundTransparency = 1
		}
	)

	task.delay(0.35, function()
		pcall(function()
			ripple:Destroy()
		end)
	end)
end

local function BindRipple(button)
	if not button then
		return
	end

	button.Activated:Connect(function()
		CreateRipple(button)
	end)
end

BindRipple(MinimizeButton)
BindRipple(SidebarMenuButton)
BindRipple(PlaylistAddButton)
BindRipple(RepeatButton)
BindRipple(PlayOnceButton)
BindRipple(ShuffleButton)
BindRipple(BackButton)
BindRipple(PlayPauseButton)
BindRipple(NextButton)

for _, data in pairs(NavigationButtons) do
	BindRipple(data.Button)
end

--// ================================================================
--// SIDEBAR VISUAL STATE
--// ================================================================

local function SetNavigationActive(name)
	for key, data in pairs(NavigationButtons) do
		local active = key == name

		Tween(
			data.Button,
			TWEEN.Normal,
			{
				BackgroundTransparency = active and 0.08 or 0.52
			}
		)

		Tween(
			data.IconHolder,
			TWEEN.Normal,
			{
				BackgroundColor3 = active
					and COLORS.Tosca
					or COLORS.Black
			}
		)

		Tween(
			data.Icon,
			TWEEN.Normal,
			{
				TextColor3 = active
					and COLORS.Black
					or COLORS.Tosca
			}
		)

		Tween(
			data.Indicator,
			TWEEN.Normal,
			{
				BackgroundTransparency = active and 0 or 1
			}
		)

		if data.Stroke then
			Tween(
				data.Stroke,
				TWEEN.Normal,
				{
					Transparency = active and 0.55 or 1
				}
			)
		end
	end
end

SetNavigationActive("MusicEngine")

--// ================================================================
--// SIDEBAR COLLAPSE
--// ================================================================

local function SetSidebar(open)
	UIState.SidebarOpen = open

	local targetWidth = open and 190 or 67
	local workspaceOffset = open and 190 or 67

	Tween(
		Sidebar,
		TWEEN.Spring,
		{
			Size = UDim2.new(0, targetWidth, 1, 0)
		}
	)

	Tween(
		WorkspaceArea,
		TWEEN.Spring,
		{
			Position = UDim2.new(0, workspaceOffset, 0, 0),
			Size = UDim2.new(1, -workspaceOffset, 1, 0)
		}
	)

	Tween(
		SidebarTitle,
		TWEEN.Normal,
		{
			TextTransparency = open and 0 or 1
		}
	)

	Tween(
		SidebarSubtitle,
		TWEEN.Normal,
		{
			TextTransparency = open and 0 or 1
		}
	)

	Tween(
		FooterText,
		TWEEN.Normal,
		{
			TextTransparency = open and 0 or 1
		}
	)

	Tween(
		FooterVersion,
		TWEEN.Normal,
		{
			TextTransparency = open and 0 or 1
		}
	)

	for _, data in pairs(NavigationButtons) do
		Tween(
			data.Title,
			TWEEN.Normal,
			{
				TextTransparency = open and 0 or 1
			}
		)

		Tween(
			data.Description,
			TWEEN.Normal,
			{
				TextTransparency = open and 0 or 1
			}
		)
	end
end

SidebarMenuButton.Activated:Connect(function()
	SetSidebar(not UIState.SidebarOpen)
end)

--// ================================================================
--// PAGE SWITCH FOUNDATION
--// ================================================================

local function SwitchPage(pageName)
	if pageName == UIState.CurrentPage then
		return
	end

	UIState.CurrentPage = pageName

	if pageName == "MusicEngine" then
		CommunityWorkspace.Visible = false
		MusicWorkspace.Visible = true

		WorkspaceTitle.Text = "Music Engine"
		WorkspaceDescription.Text = "Professional audio workspace"

		SetNavigationActive("MusicEngine")
	else
		MusicWorkspace.Visible = false
		CommunityWorkspace.Visible = true

		WorkspaceTitle.Text = "Axolion Community"
		WorkspaceDescription.Text = "Community information hub"

		SetNavigationActive("Community")
	end
end

MusicNavigation.Activated:Connect(function()
	SwitchPage("MusicEngine")
end)

CommunityNavigation.Activated:Connect(function()
	SwitchPage("Community")
end)

--// ================================================================
--// MINIMIZE / RESTORE FOUNDATION
--// ================================================================

local SavedMainPosition = Main.Position

local function MinimizeUI()
	if UIState.Minimized then
		return
	end

	UIState.Minimized = true
	SavedMainPosition = Main.Position

	Tween(
		Main,
		TWEEN.Spring,
		{
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		}
	)

	task.delay(0.18, function()
		Bubble.Visible = true

		Bubble.Size = UDim2.new(0, 0, 0, 0)

		Tween(
			Bubble,
			TWEEN.Spring,
			{
				Size = UDim2.new(0, 60, 0, 60)
			}
		)
	end)
end

local function RestoreUI()
	if not UIState.Minimized then
		return
	end

	UIState.Minimized = false

	Tween(
		Bubble,
		TWEEN.Spring,
		{
			Size = UDim2.new(0, 0, 0, 0)
		}
	)

	task.delay(0.15, function()
		Bubble.Visible = false

		Tween(
			Main,
			TWEEN.Spring,
			{
				Size = UDim2.new(0, 930, 0, 590),
				BackgroundTransparency = 0.055,
				Position = SavedMainPosition
			}
		)
	end)
end

MinimizeButton.Activated:Connect(function()
	CreateRipple(MinimizeButton)
	MinimizeUI()
end)

Bubble.Activated:Connect(function()
	CreateRipple(Bubble)
	RestoreUI()
end)

BindHover(
	Bubble,
	COLORS.Black,
	COLORS.DarkBlue3
)

BindRipple(Bubble)

--// ================================================================
--// PERFORMANCE OVERLAY FOUNDATION
--// ================================================================

local frameCounter = 0
local frameTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)
	frameCounter += 1
	frameTimer += deltaTime

	if frameTimer >= 0.5 then
		local fps = math.floor(frameCounter / frameTimer)

		local ping = 0

		pcall(function()
			local stats = game:GetService("Stats")
			local network = stats.Network
			local serverStats = network.ServerStatsItem
			local pingItem = serverStats["Data Ping"]

			if pingItem then
				ping = math.floor(pingItem:GetValue())
			end
		end)

		PerformanceLabel.Text =
			"FPS "
			.. tostring(fps)
			.. "   PING "
			.. tostring(ping)
			.. "ms"

		frameCounter = 0
		frameTimer = 0
	end
end)

--// ================================================================
--// GLOBAL KEYBIND FOUNDATION
--// ================================================================

local ToggleKey = Enum.KeyCode.RightControl

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == ToggleKey then
		if UIState.Minimized then
			RestoreUI()
		else
			MinimizeUI()
		end
	end
end)

--// ================================================================
--// INITIAL POSITION
--// ================================================================

task.defer(function()
	local viewport = Camera and Camera.ViewportSize or Vector2.new(1280, 720)

	local x = viewport.X * 0.5
	local y = viewport.Y * 0.5

	Main.Position = UDim2.fromOffset(x, y)

	UpdateScale()
end)

--// ================================================================
--// INITIAL FADE-IN
--// ================================================================

Main.BackgroundTransparency = 1
Header.BackgroundTransparency = 1
Sidebar.BackgroundTransparency = 1
WorkspaceArea.Visible = true

task.defer(function()
	Tween(
		Main,
		TWEEN.Spring,
		{
			BackgroundTransparency = 0.055
		}
	)

	Tween(
		Header,
		TWEEN.Normal,
		{
			BackgroundTransparency = 0.16
		}
	)

	Tween(
		Sidebar,
		TWEEN.Normal,
		{
			BackgroundTransparency = 0.12
		}
	)
end)

--// ================================================================
--// LAYOUT REFRESH
--// ================================================================

local function RefreshCanvasLayouts()
	pcall(function()
		Navigation.CanvasSize = UDim2.new(
			0,
			0,
			0,
			NavigationLayout.AbsoluteContentSize.Y + 15
		)
	end)

	pcall(function()
		AudioFolderContainer.CanvasSize = UDim2.new(
			0,
			0,
			0,
			AudioFolderContainer.UIListLayout.AbsoluteContentSize.Y + 10
		)
	end)

	pcall(function()
		PlaylistContainer.CanvasSize = UDim2.new(
			0,
			0,
			0,
			PlaylistContainer.UIListLayout.AbsoluteContentSize.Y + 10
		)
	end)
end

NavigationLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
	RefreshCanvasLayouts
)

--// ================================================================
--// SAFE UI CONNECTION WATCHER
--// ================================================================

task.defer(function()
	while ScreenGui and ScreenGui.Parent do
		pcall(function()
			if Camera ~= workspace.CurrentCamera then
				Camera = workspace.CurrentCamera
				UpdateScale()
			end
		end)

		task.wait(1)
	end
end)


--// ================================================================
--// LOCAL REFERENCES
--// ================================================================

local ContentState = {
	SelectedFolder = "My Creations",
	SelectedTrack = nil,
	Volume = 100,
	Speed = 1,
	EqualizerEnabled = false,
	RepeatMode = "Off",
	ShuffleEnabled = false,
	PlayOnce = false,
	Playing = false,
	FolderOpen = false,
	PlaylistOpen = true
}

local FolderButtons = {}
local PlaylistButtons = {}
local ToastIndex = 0

--// ================================================================
--// SAFE TWEEN
--// ================================================================

local function SafeTween(object, info, properties)
	if not object then
		return
	end

	pcall(function()
		local tween = TweenService:Create(
			object,
			info or TWEEN.Normal,
			properties
		)

		tween:Play()
	end)
end

--// ================================================================
--// SAFE TEXT SET
--// ================================================================

local function SetText(object, text)
	if not object then
		return
	end

	pcall(function()
		object.Text = tostring(text)
	end)
end

--// ================================================================
--// TOAST NOTIFICATION
--// ================================================================

local function ShowToast(title, message)
	ToastIndex += 1

	local toast = New("Frame", {
		Name = "Toast_" .. tostring(ToastIndex),
		BackgroundColor3 = COLORS.Black,
		BackgroundTransparency = 0.06,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 265, 0, 61),
		ZIndex = 250
	}, ToastContainer)

	if not toast then
		return
	end

	AddCorner(toast, 10)

	local stroke = AddStroke(
		toast,
		COLORS.Tosca,
		1,
		0.5
	)

	local accent = New("Frame", {
		Name = "Accent",
		BackgroundColor3 = COLORS.Tosca,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 3, 1, 0),
		ZIndex = 251
	}, toast)

	AddCorner(accent, 3)

	local titleLabel = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Text = tostring(title or "Axomusc"),
		TextColor3 = COLORS.Tosca,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 16, 0, 10),
		Size = UDim2.new(1, -26, 0, 16),
		ZIndex = 252
	}, toast)

	local messageLabel = New("TextLabel", {
		Name = "Message",
		BackgroundTransparency = 1,
		Text = tostring(message or ""),
		TextColor3 = COLORS.WhiteSoft,
		Font = Enum.Font.Gotham,
		TextSize = 8,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Position = UDim2.new(0, 16, 0, 27),
		Size = UDim2.new(1, -26, 0, 23),
		ZIndex = 252
	}, toast)

	toast.Position = UDim2.new(
		1,
		35,
		1,
		0
	)

	SafeTween(
		toast,
		TWEEN.Spring,
		{
			Position = UDim2.new(
				1,
				0,
				1,
				0
			)
		}
	)

	task.delay(2.7, function()
		if toast and toast.Parent then
			SafeTween(
				toast,
				TWEEN.Normal,
				{
					Position = UDim2.new(
						1,
						35,
						1,
						0
					),
					BackgroundTransparency = 1
				}
			)

			task.wait(0.3)

			pcall(function()
				toast:Destroy()
			end)
		end
	end)
end

--// ================================================================
--// COPY SYSTEM
--// ================================================================

local function CopyToClipboard(text, successMessage)
	local copied = false

	pcall(function()
		if setclipboard then
			setclipboard(text)
			copied = true
		end
	end)

	if not copied then
		pcall(function()
			if toclipboard then
				toclipboard(text)
				copied = true
			end
		end)
	end

	if copied then
		ShowToast(
			"LINK COPIED",
			successMessage or "Link berhasil disalin."
		)
	else
		ShowToast(
			"CLIPBOARD",
			"Executor tidak menyediakan clipboard API."
		)
	end
end

--// ================================================================
--// GENERIC BUTTON HOVER
--// ================================================================

local function AddButtonInteraction(button, normal, hover)
	if not button then
		return
	end

	button.MouseEnter:Connect(function()
		SafeTween(
			button,
			TWEEN.Fast,
			{
				BackgroundColor3 = hover or COLORS.DarkBlue3
			}
		)
	end)

	button.MouseLeave:Connect(function()
		SafeTween(
			button,
			TWEEN.Fast,
			{
				BackgroundColor3 = normal or COLORS.DarkBlue2
			}
		)
	end)

	button.Activated:Connect(function()
		pcall(function()
			CreateRipple(button)
		end)
	end)
end

--// ================================================================
--// AUDIO FOLDER DATA
--// ================================================================

local AudioFolders = {
	{
		Name = "My Creations",
		Icon = "♫",
		Count = "Personal"
	},
	{
		Name = "System Audio",
		Icon = "◈",
		Count = "System"
	},
	{
		Name = "Favorites",
		Icon = "★",
		Count = "Pinned"
	},
	{
		Name = "Recent",
		Icon = "◷",
		Count = "Recent"
	},
	{
		Name = "Ambient",
		Icon = "◌",
		Count = "Atmosphere"
	},
	{
		Name = "Cinematic",
		Icon = "◆",
		Count = "Cinematic"
	},
	{
		Name = "Anime",
		Icon = "✦",
		Count = "Collection"
	},
	{
		Name = "Energy",
		Icon = "⚡",
		Count = "Effects"
	}
}

--// ================================================================
--// FOLDER BUTTON FACTORY
--// ================================================================

local function CreateFolderButton(folderData)
	local button = New("TextButton", {
		Name = "Folder_" .. folderData.Name:gsub("%s+", ""),
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.DarkBlue2,
		BackgroundTransparency = 0.58,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, 0, 0, 43),
		ZIndex = 12
	}, AudioFolderContainer)

	AddCorner(button, 8)

	local stroke = AddStroke(
		button,
		COLORS.ToscaDark,
		1,
		1
	)

	local iconHolder = New("Frame", {
		Name = "IconHolder",
		BackgroundColor3 = COLORS.Black,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(0, 31, 0, 31),
		ZIndex = 13
	}, button)

	AddCorner(iconHolder, 7)

	local icon = New("TextLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Text = folderData.Icon,
		TextColor3 = COLORS.Tosca,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 14
	}, iconHolder)

	local name = New("TextLabel", {
		Name = "FolderName",
		BackgroundTransparency = 1,
		Text = folderData.Name,
		TextColor3 = COLORS.White,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 46, 0, 4),
		Size = UDim2.new(1, -54, 0, 18),
		ZIndex = 14
	}, button)

	local count = New("TextLabel", {
		Name = "FolderType",
		BackgroundTransparency = 1,
		Text = folderData.Count,
		TextColor3 = COLORS.Gray,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 46, 0, 21),
		Size = UDim2.new(1, -54, 0, 14),
		ZIndex = 14
	}, button)

	FolderButtons[folderData.Name] = {
		Button = button,
		Stroke = stroke,
		Icon = icon,
		IconHolder = iconHolder,
		Name = name,
		Count = count
	}

	AddButtonInteraction(
		button,
		COLORS.DarkBlue2,
		COLORS.DarkBlue3
	)

	button.Activated:Connect(function()
		ContentState.SelectedFolder = folderData.Name

		for folderName, data in pairs(FolderButtons) do
			local selected = folderName == folderData.Name

			SafeTween(
				data.Button,
				TWEEN.Fast,
				{
					BackgroundTransparency = selected and 0.08 or 0.58
				}
			)

			SafeTween(
				data.IconHolder,
				TWEEN.Fast,
				{
					BackgroundColor3 = selected
						and COLORS.Tosca
						or COLORS.Black
				}
			)

			SafeTween(
				data.Icon,
				TWEEN.Fast,
				{
					TextColor3 = selected
						and COLORS.Black
						or COLORS.Tosca
				}
			)

			SafeTween(
				data.Stroke,
				TWEEN.Fast,
				{
					Transparency = selected and 0.42 or 1
				}
			)
		end

		ShowToast(
			"FOLDER",
			folderData.Name .. " selected."
		)

		--// Load playlist content for selected folder
		if ContentState.FolderOpen then
			pcall(function()
				RefreshPlaylistForFolder(folderData.Name)
			end)
		end
	end)

	return button
end

for _, folder in ipairs(AudioFolders) do
	CreateFolderButton(folder)
end

--// ================================================================
--// INITIAL FOLDER STATE
--// ================================================================

task.defer(function()
	local initial = FolderButtons["My Creations"]

	if initial then
		SafeTween(
			initial.Button,
			TWEEN.Fast,
			{
				BackgroundTransparency = 0.08
			}
		)

		SafeTween(
			initial.IconHolder,
			TWEEN.Fast,
			{
				BackgroundColor3 = COLORS.Tosca
			}
		)

		SafeTween(
			initial.Icon,
			TWEEN.Fast,
			{
				TextColor3 = COLORS.Black
			}
		)

		SafeTween(
			initial.Stroke,
			TWEEN.Fast,
			{
				Transparency = 0.42
			}
		)
	end
end)

--// ================================================================
--// TRACK DATA
--// ================================================================

local Tracks = {
	{
		Id = "Track_001",
		Name = "Celestial Awakening",
		Artist = "Axolion Audio",
		Duration = "03:42",
		Folder = "My Creations",
		Favorite = true
	},
	{
		Id = "Track_002",
		Name = "Azure Domain",
		Artist = "Axolion Audio",
		Duration = "04:18",
		Folder = "My Creations",
		Favorite = false
	},
	{
		Id = "Track_003",
		Name = "Eternal Night",
		Artist = "System Audio",
		Duration = "05:04",
		Folder = "System Audio",
		Favorite = false
	},
	{
		Id = "Track_004",
		Name = "Heavenly Pulse",
		Artist = "Axolion Audio",
		Duration = "03:27",
		Folder = "Cinematic",
		Favorite = true
	},
	{
		Id = "Track_005",
		Name = "Void Resonance",
		Artist = "Axolion Audio",
		Duration = "02:56",
		Folder = "Cinematic",
		Favorite = false
	},
	{
		Id = "Track_006",
		Name = "Spirit Flow",
		Artist = "Axolion Audio",
		Duration = "04:51",
		Folder = "Anime",
		Favorite = true
	},
	{
		Id = "Track_007",
		Name = "Thunder Ascension",
		Artist = "Axolion Audio",
		Duration = "03:12",
		Folder = "Energy",
		Favorite = false
	},
	{
		Id = "Track_008",
		Name = "Mystic Garden",
		Artist = "Axolion Audio",
		Duration = "06:20",
		Folder = "Ambient",
		Favorite = false
	}
}

--// ================================================================
--// PLAYLIST ITEM FACTORY
--// ================================================================

local function CreatePlaylistItem(track)
	local item = New("TextButton", {
		Name = track.Id,
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.DarkBlue2,
		BackgroundTransparency = 0.62,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, 0, 0, 54),
		ZIndex = 12
	}, PlaylistContainer)

	AddCorner(item, 8)

	local stroke = AddStroke(
		item,
		COLORS.ToscaDark,
		1,
		1
	)

	local thumbnail = New("ImageLabel", {
		Name = "Thumbnail",
		BackgroundColor3 = COLORS.Black,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Image = THUMBNAIL,
		ScaleType = Enum.ScaleType.Crop,
		Position = UDim2.new(0, 6, 0, 6),
		Size = UDim2.new(0, 42, 0, 42),
		ZIndex = 13
	}, item)

	AddCorner(thumbnail, 7)

	local title = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Text = track.Name,
		TextColor3 = COLORS.White,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 56, 0, 8),
		Size = UDim2.new(1, -86, 0, 16),
		ZIndex = 14
	}, item)

	local artist = New("TextLabel", {
		Name = "Artist",
		BackgroundTransparency = 1,
		Text = track.Artist,
		TextColor3 = COLORS.Gray,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.new(0, 56, 0, 26),
		Size = UDim2.new(1, -86, 0, 13),
		ZIndex = 14
	}, item)

	local duration = New("TextLabel", {
		Name = "Duration",
		BackgroundTransparency = 1,
		Text = track.Duration,
		TextColor3 = COLORS.ToscaDark,
		Font = Enum.Font.Code,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 56, 0, 39),
		Size = UDim2.new(0, 42, 0, 10),
		ZIndex = 14
	}, item)

	local favorite = New("TextButton", {
		Name = "Favorite",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = track.Favorite and "★" or "☆",
		TextColor3 = track.Favorite and COLORS.Tosca or COLORS.Gray,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		Position = UDim2.new(1, -30, 0, 18),
		Size = UDim2.new(0, 23, 0, 20),
		ZIndex = 16
	}, item)

	PlaylistButtons[track.Id] = {
		Button = item,
		Stroke = stroke,
		Title = title,
		Artist = artist,
		Duration = duration,
		Favorite = favorite,
		Data = track
	}

	AddButtonInteraction(
		item,
		COLORS.DarkBlue2,
		COLORS.DarkBlue3
	)

	item.Activated:Connect(function()
		ContentState.SelectedTrack = track
		ContentState.Playing = true

		SetText(
			TrackTitle,
			track.Name
		)

		SetText(
			TrackArtist,
			track.Artist
		)

		SetText(
			TimeTotal,
			track.Duration
		)

		PlayPauseButton.Text = "Ⅱ"

		for _, data in pairs(PlaylistButtons) do
			local selected = data.Data.Id == track.Id

			SafeTween(
				data.Button,
				TWEEN.Fast,
				{
					BackgroundTransparency = selected
						and 0.08
						or 0.62
				}
			)

			SafeTween(
				data.Stroke,
				TWEEN.Fast,
				{
					Transparency = selected
						and 0.38
						or 1
				}
			)
		end

		SafeTween(
			AlbumHolder,
			TWEEN.Spring,
			{
				Size = UDim2.new(0, 215, 0, 215)
			}
		)

		task.delay(0.16, function()
			if AlbumHolder then
				SafeTween(
					AlbumHolder,
					TWEEN.Spring,
					{
						Size = UDim2.new(0, 205, 0, 205)
					}
				)
			end
		end)

		ShowToast(
			"NOW PLAYING",
			track.Name
		)
	end)

	favorite.Activated:Connect(function()
		track.Favorite = not track.Favorite

		favorite.Text = track.Favorite
			and "★"
			or "☆"

		favorite.TextColor3 = track.Favorite
			and COLORS.Tosca
			or COLORS.Gray

		if track.Favorite then
			ShowToast(
				"FAVORITE",
				track.Name .. " pinned."
			)
		else
			ShowToast(
				"FAVORITE",
				track.Name .. " unpinned."
			)
		end
	end)

	AddButtonInteraction(
		favorite,
		COLORS.Black,
		COLORS.DarkBlue3
	)

	return item
end

--// ================================================================
--// PLAYLIST REFRESH
--// ================================================================

function RefreshPlaylistForFolder(folderName)
	if not PlaylistContainer then
		return
	end

	for _, child in ipairs(PlaylistContainer:GetChildren()) do
		if child:IsA("TextButton") then
			pcall(function()
				child:Destroy()
			end)
		end
	end

	PlaylistButtons = {}

	local searchText = ""

	pcall(function()
		searchText = string.lower(AudioSearch.Text or "")
	end)

	local created = 0

	for _, track in ipairs(Tracks) do
		local folderMatch =
			folderName == "Favorites"
			and track.Favorite
			or folderName == "Recent"
			and true
			or folderName == "My Creations"
			and track.Folder == "My Creations"
			or folderName == "System Audio"
			and track.Folder == "System Audio"
			or folderName == "Ambient"
			and track.Folder == "Ambient"
			or folderName == "Cinematic"
			and track.Folder == "Cinematic"
			or folderName == "Anime"
			and track.Folder == "Anime"
			or folderName == "Energy"
			and track.Folder == "Energy"

		if folderMatch then
			local lowerName = string.lower(track.Name)

			if searchText == ""
				or string.find(lowerName, searchText, 1, true) then

				CreatePlaylistItem(track)
				created += 1
			end
		end
	end

	if created == 0 then
		local empty = New("Frame", {
			Name = "EmptyPlaylist",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 90),
			ZIndex = 12
		}, PlaylistContainer)

		local emptyIcon = New("TextLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			Text = "♫",
			TextColor3 = COLORS.ToscaDark,
			Font = Enum.Font.GothamBold,
			TextSize = 24,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.new(0, 0, 0, 9),
			Size = UDim2.new(1, 0, 0, 32),
			ZIndex = 13
		}, empty)

		local emptyText = New("TextLabel", {
			Name = "Text",
			BackgroundTransparency = 1,
			Text = "No audio available",
			TextColor3 = COLORS.Gray,
			Font = Enum.Font.Gotham,
			TextSize = 8,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.new(0, 0, 0, 45),
			Size = UDim2.new(1, 0, 0, 18),
			ZIndex = 13
		}, empty)
	end

	pcall(function()
		PlaylistContainer.CanvasSize = UDim2.new(
			0,
			0,
			0,
			PlaylistContainer.UIListLayout.AbsoluteContentSize.Y + 10
		)
	end)
end

--// ================================================================
--// INITIAL PLAYLIST
--// ================================================================

RefreshPlaylistForFolder(
	ContentState.SelectedFolder
)

--// ================================================================
--// SEARCHABLE FOLDER FILTER
--// ================================================================

AudioSearch:GetPropertyChangedSignal("Text"):Connect(function()
	local search = string.lower(AudioSearch.Text or "")

	for _, data in pairs(FolderButtons) do
		local folderName = string.lower(data.Name.Text)

		data.Button.Visible =
			search == ""
			or string.find(folderName, search, 1, true) ~= nil
	end

	if ContentState.SelectedFolder then
		RefreshPlaylistForFolder(
			ContentState.SelectedFolder
		)
	end
end)

AudioSearch.Focused:Connect(function()
	SafeTween(
		AudioSearch,
		TWEEN.Fast,
		{
			BackgroundTransparency = 0.05
		}
	)
end)

AudioSearch.FocusLost:Connect(function()
	SafeTween(
		AudioSearch,
		TWEEN.Fast,
		{
			BackgroundTransparency = 0.2
		}
	)
end)

--// ================================================================
--// PLAYLIST ADD PANEL
--// ================================================================

local AddPlaylistPanel = New("Frame", {
	Name = "AddPlaylistPanel",
	Visible = false,
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0, 320, 0, 220),
	ZIndex = 150
}, ScreenGui)

AddCorner(AddPlaylistPanel, 13)
AddStroke(
	AddPlaylistPanel,
	COLORS.Tosca,
	1.2,
	0.35
)

local AddPlaylistTitle = New("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Text = "NEW PLAYLIST",
	TextColor3 = COLORS.White,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 18, 0, 15),
	Size = UDim2.new(1, -60, 0, 25),
	ZIndex = 151
}, AddPlaylistPanel)

local AddPlaylistDescription = New("TextLabel", {
	Name = "Description",
	BackgroundTransparency = 1,
	Text = "Create a personal audio collection.",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Gotham,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 19, 0, 40),
	Size = UDim2.new(1, -38, 0, 20),
	ZIndex = 151
}, AddPlaylistPanel)

local PlaylistNameInput = New("TextBox", {
	Name = "PlaylistName",
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.15,
	BorderSizePixel = 0,
	PlaceholderText = "Playlist name...",
	PlaceholderColor3 = COLORS.Gray,
	Text = "",
	TextColor3 = COLORS.White,
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	TextSize = 9,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 18, 0, 77),
	Size = UDim2.new(1, -36, 0, 38),
	ZIndex = 151
}, AddPlaylistPanel)

AddCorner(PlaylistNameInput, 8)
AddStroke(
	PlaylistNameInput,
	COLORS.ToscaDark,
	1,
	0.7
)
AddPadding(
	PlaylistNameInput,
	11,
	11,
	0,
	0
)

local PlaylistCancel = New("TextButton", {
	Name = "Cancel",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	Text = "CANCEL",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.GothamBold,
	TextSize = 8,
	Position = UDim2.new(0, 18, 1, -55),
	Size = UDim2.new(0, 112, 0, 35),
	ZIndex = 152
}, AddPlaylistPanel)

AddCorner(PlaylistCancel, 8)

local PlaylistCreate = New("TextButton", {
	Name = "Create",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.Tosca,
	BackgroundTransparency = 0.03,
	BorderSizePixel = 0,
	Text = "CREATE",
	TextColor3 = COLORS.Black,
	Font = Enum.Font.GothamBold,
	TextSize = 8,
	Position = UDim2.new(1, -130, 1, -55),
	Size = UDim2.new(0, 112, 0, 35),
	ZIndex = 152
}, AddPlaylistPanel)

AddCorner(PlaylistCreate, 8)

AddButtonInteraction(
	PlaylistCancel,
	COLORS.DarkBlue2,
	COLORS.DarkBlue3
)

AddButtonInteraction(
	PlaylistCreate,
	COLORS.Tosca,
	COLORS.ToscaSoft
)

PlaylistAddButton.Activated:Connect(function()
	AddPlaylistPanel.Visible = true

	AddPlaylistPanel.Size = UDim2.new(0, 260, 0, 175)

	SafeTween(
		AddPlaylistPanel,
		TWEEN.Spring,
		{
			Size = UDim2.new(0, 320, 0, 220)
		}
	)

	PlaylistNameInput:CaptureFocus()
end)

PlaylistCancel.Activated:Connect(function()
	SafeTween(
		AddPlaylistPanel,
		TWEEN.Normal,
		{
			Size = UDim2.new(0, 260, 0, 175)
		}
	)

	task.delay(0.25, function()
		AddPlaylistPanel.Visible = false
	end)
end)

PlaylistCreate.Activated:Connect(function()
	local name = PlaylistNameInput.Text

	if not name or name:gsub("%s+", "") == "" then
		ShowToast(
			"PLAYLIST",
			"Masukkan nama playlist."
		)

		return
	end

	ShowToast(
		"PLAYLIST CREATED",
		name .. " created successfully."
	)

	PlaylistNameInput.Text = ""

	SafeTween(
		AddPlaylistPanel,
		TWEEN.Normal,
		{
			Size = UDim2.new(0, 260, 0, 175)
		}
	)

	task.delay(0.25, function()
		AddPlaylistPanel.Visible = false
	end)
end)

--// ================================================================
--// EQUALIZER PANEL
--// ================================================================

local EqualizerPanel = New("Frame", {
	Name = "EqualizerPanel",
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 14, 1, -142),
	Size = UDim2.new(1, -28, 0, 62),
	ZIndex = 15
}, PlayerPanel)

AddCorner(EqualizerPanel, 9)
AddStroke(
	EqualizerPanel,
	COLORS.ToscaDark,
	1,
	0.72
)

local EqualizerTitle = New("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Text = "EQUALIZER",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.GothamBold,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 10, 0, 8),
	Size = UDim2.new(0, 80, 0, 14),
	ZIndex = 16
}, EqualizerPanel)

local EqualizerState = New("TextLabel", {
	Name = "State",
	BackgroundTransparency = 1,
	Text = "OFF",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.Code,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -53, 0, 8),
	Size = UDim2.new(0, 43, 0, 14),
	ZIndex = 16
}, EqualizerPanel)

local EqualizerToggle = New("TextButton", {
	Name = "Toggle",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.DarkBlue3,
	BackgroundTransparency = 0.1,
	BorderSizePixel = 0,
	Text = "",
	Position = UDim2.new(1, -40, 0, 28),
	Size = UDim2.new(0, 29, 0, 17),
	ZIndex = 17
}, EqualizerPanel)

AddCorner(EqualizerToggle, 9)

local EqualizerToggleKnob = New("Frame", {
	Name = "Knob",
	BackgroundColor3 = COLORS.Gray,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 3, 0.5, -5),
	Size = UDim2.new(0, 10, 0, 10),
	ZIndex = 18
}, EqualizerToggle)

AddCorner(EqualizerToggleKnob, 5)

local EqualizerBars = New("Frame", {
	Name = "Bars",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 93, 0, 13),
	Size = UDim2.new(1, -105, 0, 42),
	ZIndex = 16
}, EqualizerPanel)

local EqualizerBarLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 4)
}, EqualizerBars)

local EqualizerBarObjects = {}

for i = 1, 8 do
	local holder = New("Frame", {
		Name = "EQ_" .. tostring(i),
		BackgroundColor3 = COLORS.DarkBlue3,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 13, 1, 0),
		ZIndex = 17
	}, EqualizerBars)

	AddCorner(holder, 4)

	local bar = New("Frame", {
		Name = "Level",
		BackgroundColor3 = COLORS.Tosca,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -3),
		Size = UDim2.new(0, 7, 0, math.random(9, 29)),
		ZIndex = 18
	}, holder)

	AddCorner(bar, 3)

	EqualizerBarObjects[i] = bar
end

EqualizerToggle.Activated:Connect(function()
	ContentState.EqualizerEnabled =
		not ContentState.EqualizerEnabled

	if ContentState.EqualizerEnabled then
		SetText(EqualizerState, "ON")

		SafeTween(
			EqualizerToggle,
			TWEEN.Fast,
			{
				BackgroundColor3 = COLORS.Tosca
			}
		)

		SafeTween(
			EqualizerToggleKnob,
			TWEEN.Spring,
			{
				Position = UDim2.new(
					1,
					-13,
					0.5,
					-5
				),
				BackgroundColor3 = COLORS.Black
			}
		)

		ShowToast(
			"EQUALIZER",
			"Equalizer enabled."
		)
	else
		SetText(EqualizerState, "OFF")

		SafeTween(
			EqualizerToggle,
			TWEEN.Fast,
			{
				BackgroundColor3 = COLORS.DarkBlue3
			}
		)

		SafeTween(
			EqualizerToggleKnob,
			TWEEN.Spring,
			{
				Position = UDim2.new(
					0,
					3,
					0.5,
					-5
				),
				BackgroundColor3 = COLORS.Gray
			}
		)

		ShowToast(
			"EQUALIZER",
			"Equalizer disabled."
		)
	end
end)

AddButtonInteraction(
	EqualizerToggle,
	COLORS.DarkBlue3,
	COLORS.DarkBlue2
)

--// ================================================================
--// EQUALIZER ANIMATION
--// ================================================================

task.spawn(function()
	while ScreenGui and ScreenGui.Parent do
		if ContentState.EqualizerEnabled then
			for index, bar in pairs(EqualizerBarObjects) do
				if bar and bar.Parent then
					local level =
						10
						+ math.random(1, 27)
						+ math.floor(
							math.abs(
								math.sin(
									os.clock() * (1 + index * 0.14)
								)
							) * 12
						)

					SafeTween(
						bar,
						TWEEN.Fast,
						{
							Size = UDim2.new(
								0,
								7,
								0,
								level
							)
						}
					)
				end
			end
		end

		task.wait(0.09)
	end
end)

--// ================================================================
--// SPEED SELECTOR
--// ================================================================

local SpeedPanel = New("Frame", {
	Name = "SpeedPanel",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 14, 1, -78),
	Size = UDim2.new(0, 130, 0, 27),
	ZIndex = 16
}, PlayerPanel)

local SpeedLabel = New("TextLabel", {
	Name = "Label",
	BackgroundTransparency = 1,
	Text = "SPEED",
	TextColor3 = COLORS.Gray,
	Font = Enum.Font.GothamBold,
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 35, 1, 0),
	ZIndex = 17
}, SpeedPanel)

local SpeedButton = New("TextButton", {
	Name = "Speed",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.DarkBlue3,
	BackgroundTransparency = 0.12,
	BorderSizePixel = 0,
	Text = "1.0×",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.GothamBold,
	TextSize = 8,
	Position = UDim2.new(0, 39, 0, 0),
	Size = UDim2.new(0, 51, 0, 26),
	ZIndex = 17
}, SpeedPanel)

AddCorner(SpeedButton, 7)

local SpeedDropdown = New("Frame", {
	Name = "Dropdown",
	Visible = false,
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 39, 0, -120),
	Size = UDim2.new(0, 70, 0, 115),
	ZIndex = 100
}, SpeedPanel)

AddCorner(SpeedDropdown, 8)
AddStroke(
	SpeedDropdown,
	COLORS.ToscaDark,
	1,
	0.45
)

local SpeedLayout = AddList(
	SpeedDropdown,
	Enum.FillDirection.Vertical,
	3
)

AddPadding(
	SpeedDropdown,
	4,
	4,
	4,
	4
)

local SpeedOptions = {
	0.5,
	1.0,
	1.5,
	2.0
}

for _, speed in ipairs(SpeedOptions) do
	local option = New("TextButton", {
		Name = "Speed_" .. tostring(speed),
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.DarkBlue2,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Text = tostring(speed) .. "×",
		TextColor3 = COLORS.White,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		Size = UDim2.new(1, 0, 0, 24),
		ZIndex = 101
	}, SpeedDropdown)

	AddCorner(option, 5)

	AddButtonInteraction(
		option,
		COLORS.DarkBlue2,
		COLORS.DarkBlue3
	)

	option.Activated:Connect(function()
		ContentState.Speed = speed

		SetText(
			SpeedButton,
			tostring(speed) .. "×"
		)

		SpeedDropdown.Visible = false

		ShowToast(
			"PLAYBACK SPEED",
			"Speed set to " .. tostring(speed) .. "×."
		)
	end)
end

SpeedButton.Activated:Connect(function()
	SpeedDropdown.Visible =
		not SpeedDropdown.Visible

	if SpeedDropdown.Visible then
		SpeedDropdown.Size = UDim2.new(0, 70, 0, 0)

		SafeTween(
			SpeedDropdown,
			TWEEN.Spring,
			{
				Size = UDim2.new(0, 70, 0, 115)
			}
		)
	else
		SafeTween(
			SpeedDropdown,
			TWEEN.Fast,
			{
				Size = UDim2.new(0, 70, 0, 0)
			}
		)
	end
end)

AddButtonInteraction(
	SpeedButton,
	COLORS.DarkBlue3,
	COLORS.DarkBlue2
)

--// ================================================================
--// VOLUME SLIDER FUNCTIONALITY
--// ================================================================

local VolumeDragging = false

local function SetVolumeFromX(x)
	local absolutePosition = VolumeBar.AbsolutePosition.X
	local absoluteSize = VolumeBar.AbsoluteSize.X

	if absoluteSize <= 0 then
		return
	end

	local value =
		math.clamp(
			(x - absolutePosition) / absoluteSize,
			0,
			1
		)

	local percentage =
		math.floor(
			value * 100 + 0.5
		)

	ContentState.Volume = percentage

	SafeTween(
		VolumeFill,
		TWEEN.Fast,
		{
			Size = UDim2.new(
				value,
				0,
				1,
				0
			)
		}
	)

	SafeTween(
		VolumeKnob,
		TWEEN.Fast,
		{
			Position = UDim2.new(
				value,
				0,
				0.5,
				0
			)
		}
	)

	SetText(
		VolumeValue,
		tostring(percentage) .. "%"
	)
end

VolumeBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		VolumeDragging = true
		SetVolumeFromX(input.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not VolumeDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		SetVolumeFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		VolumeDragging = false
	end
end)

--// ================================================================
--// PROGRESS SLIDER FOUNDATION
--// ================================================================

local ProgressDragging = false

local function SetProgressFromX(x)
	local absolutePosition = ProgressContainer.AbsolutePosition.X
	local absoluteSize = ProgressContainer.AbsoluteSize.X

	if absoluteSize <= 0 then
		return
	end

	local value =
		math.clamp(
			(x - absolutePosition) / absoluteSize,
			0,
			1
		)

	SafeTween(
		ProgressFill,
		TWEEN.Fast,
		{
			Size = UDim2.new(
				value,
				0,
				1,
				0
			)
		}
	)

	SafeTween(
		ProgressKnob,
		TWEEN.Fast,
		{
			Position = UDim2.new(
				value,
				0,
				0.5,
				0
			)
		}
	)
end

ProgressContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		ProgressDragging = true

		SetProgressFromX(
			input.Position.X
		)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not ProgressDragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		SetProgressFromX(
			input.Position.X
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		ProgressDragging = false
	end
end)

--// ================================================================
--// PLAYBACK CONTROL
--// ================================================================

RepeatButton.Activated:Connect(function()
	local modes = {
		"Off",
		"All",
		"One"
	}

	local current = 1

	for index, mode in ipairs(modes) do
		if mode == ContentState.RepeatMode then
			current = index
			break
		end
	end

	current += 1

	if current > #modes then
		current = 1
	end

	ContentState.RepeatMode =
		modes[current]

	RepeatButton.Text =
		ContentState.RepeatMode == "One"
		and "↻1"
		or "↻"

	RepeatButton.TextColor3 =
		ContentState.RepeatMode ~= "Off"
		and COLORS.Tosca
		or COLORS.White

	ShowToast(
		"REPEAT",
		"Mode: " .. ContentState.RepeatMode
	)
end)

PlayOnceButton.Activated:Connect(function()
	ContentState.PlayOnce =
		not ContentState.PlayOnce

	PlayOnceButton.TextColor3 =
		ContentState.PlayOnce
		and COLORS.Tosca
		or COLORS.White

	ShowToast(
		"PLAY MODE",
		ContentState.PlayOnce
			and "Single play enabled."
			or "Single play disabled."
	)
end)

ShuffleButton.Activated:Connect(function()
	ContentState.ShuffleEnabled =
		not ContentState.ShuffleEnabled

	ShuffleButton.TextColor3 =
		ContentState.ShuffleEnabled
		and COLORS.Tosca
		or COLORS.White

	ShowToast(
		"SHUFFLE",
		ContentState.ShuffleEnabled
			and "Shuffle enabled."
			or "Shuffle disabled."
	)
end)

BackButton.Activated:Connect(function()
	ShowToast(
		"PREVIOUS",
		"Previous track requested."
	)
end)

NextButton.Activated:Connect(function()
	ShowToast(
		"NEXT",
		"Next track requested."
	)
end)

PlayPauseButton.Activated:Connect(function()
	ContentState.Playing =
		not ContentState.Playing

	if ContentState.Playing then
		PlayPauseButton.Text = "Ⅱ"

		ShowToast(
			"PLAYBACK",
			"Playback started."
		)
	else
		PlayPauseButton.Text = "▶"

		ShowToast(
			"PLAYBACK",
			"Playback paused."
		)
	end
end)

--// ================================================================
--// COMMUNITY LINK DATA
--// ================================================================

local DISCORD_LINK =
	"https://discord.gg/dkuXRcS2hY"

local COMMUNITY_LINK =
	"https://www.roblox.com/share/g/245953568"

--// ================================================================
--// COMMUNITY DESCRIPTION
--// ================================================================

local CommunityDescription = New("TextLabel", {
	Name = "InformationText",
	BackgroundTransparency = 1,
	Text = "Axolion Community adalah pusat komunitas untuk berbagai project, development, pengalaman Roblox, dan ekosistem Axolion. Gunakan tombol di bawah untuk mengakses channel resmi.",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.Gotham,
	TextSize = 9,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Position = UDim2.new(0, 18, 0, 50),
	Size = UDim2.new(1, -36, 0, 54),
	ZIndex = 10
}, CommunityInfoPanel)

--// ================================================================
--// COMMUNITY LINK CARD FACTORY
--// ================================================================

local function CreateCommunityLinkCard(parent, y, title, subtitle, value, icon)
	local card = New("Frame", {
		Name = title:gsub("%s+", ""),
		BackgroundColor3 = COLORS.DarkBlue2,
		BackgroundTransparency = 0.27,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 18, 0, y),
		Size = UDim2.new(1, -36, 0, 61),
		ZIndex = 11
	}, parent)

	AddCorner(card, 9)

	local stroke = AddStroke(
		card,
		COLORS.ToscaDark,
		1,
		0.7
	)

	local iconHolder = New("Frame", {
		Name = "Icon",
		BackgroundColor3 = COLORS.Black,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0.5, -21),
		Size = UDim2.new(0, 42, 0, 42),
		ZIndex = 12
	}, card)

	AddCorner(iconHolder, 9)

	local iconText = New("TextLabel", {
		Name = "IconText",
		BackgroundTransparency = 1,
		Text = icon,
		TextColor3 = COLORS.Tosca,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 13
	}, iconHolder)

	local titleLabel = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = COLORS.White,
		Font = Enum.Font.GothamBold,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 62, 0, 10),
		Size = UDim2.new(1, -180, 0, 17),
		ZIndex = 13
	}, card)

	local subtitleLabel = New("TextLabel", {
		Name = "Subtitle",
		BackgroundTransparency = 1,
		Text = subtitle,
		TextColor3 = COLORS.Gray,
		Font = Enum.Font.Gotham,
		TextSize = 7,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 62, 0, 29),
		Size = UDim2.new(1, -180, 0, 14),
		ZIndex = 13
	}, card)

	local copyButton = New("TextButton", {
		Name = "Copy",
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Tosca,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Text = "COPY",
		TextColor3 = COLORS.Black,
		Font = Enum.Font.GothamBold,
		TextSize = 8,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 75, 0, 32),
		ZIndex = 14
	}, card)

	AddCorner(copyButton, 7)

	AddButtonInteraction(
		copyButton,
		COLORS.Tosca,
		COLORS.ToscaSoft
	)

	copyButton.Activated:Connect(function()
		CopyToClipboard(
			value,
			title .. " link berhasil disalin."
		)
	end)

	card.MouseEnter:Connect(function()
		SafeTween(
			stroke,
			TWEEN.Fast,
			{
				Transparency = 0.32
			}
		)
	end)

	card.MouseLeave:Connect(function()
		SafeTween(
			stroke,
			TWEEN.Fast,
			{
				Transparency = 0.7
			}
		)
	end)

	return card
end

--// ================================================================
--// COMMUNITY DISCORD CARD
--// ================================================================

CreateCommunityLinkCard(
	CommunityInfoPanel,
	115,
	"Discord",
	"Join the official Axolion Discord",
	DISCORD_LINK,
	"◈"
)

--// ================================================================
--// COMMUNITY ROBLOX CARD
--// ================================================================

CreateCommunityLinkCard(
	CommunityInfoPanel,
	184,
	"Roblox Community",
	"Open the official Roblox Community",
	COMMUNITY_LINK,
	"R"
)

--// ================================================================
--// COMMUNITY STATUS CARD
--// ================================================================

local CommunityStatus = New("Frame", {
	Name = "StatusCard",
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.38,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 18, 1, -60),
	Size = UDim2.new(1, -36, 0, 38),
	ZIndex = 12
}, CommunityInfoPanel)

AddCorner(CommunityStatus, 8)

local StatusDot = New("Frame", {
	Name = "StatusDot",
	BackgroundColor3 = COLORS.Tosca,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 12, 0.5, -5),
	Size = UDim2.new(0, 10, 0, 10),
	ZIndex = 13
}, CommunityStatus)

AddCorner(StatusDot, 5)

local StatusText = New("TextLabel", {
	Name = "Status",
	BackgroundTransparency = 1,
	Text = "AXOLION COMMUNITY • ONLINE HUB",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.GothamBold,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 31, 0, 0),
	Size = UDim2.new(1, -42, 1, 0),
	ZIndex = 13
}, CommunityStatus)

--// ================================================================
--// COMMUNITY LOGO INTERACTION
--// ================================================================

CommunityLogoHolder.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SafeTween(
			CommunityLogoHolder,
			TWEEN.Spring,
			{
				Size = UDim2.new(0, 116, 0, 116)
			}
		)

		task.delay(0.18, function()
			if CommunityLogoHolder then
				SafeTween(
					CommunityLogoHolder,
					TWEEN.Spring,
					{
						Size = UDim2.new(0, 108, 0, 108)
					}
				)
			end
		end)
	end
end)

--// ================================================================
--// COMMUNITY HERO GLOW
--// ================================================================

task.spawn(function()
	local pulse = 0

	while ScreenGui and ScreenGui.Parent do
		pulse += 0.035

		local transparency =
			0.90
			+ (
				math.sin(pulse) * 0.045
			)

		pcall(function()
			CommunityLogoHolder.BackgroundTransparency =
				math.clamp(
					transparency,
					0.82,
					0.96
				)
		end)

		task.wait(0.035)
	end
end)

--// ================================================================
--// PLAYBACK VISUALIZER
--// ================================================================

local VisualizerContainer = New("Frame", {
	Name = "Visualizer",
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 21),
	Size = UDim2.new(0, 205, 0, 205),
	ZIndex = 13
}, PlayerPanel)

local VisualizerBars = {}

local VisualizerLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 3)
}, VisualizerContainer)

for i = 1, 17 do
	local visualBar = New("Frame", {
		Name = "Bar_" .. tostring(i),
		BackgroundColor3 = COLORS.Tosca,
		BackgroundTransparency = 0.68,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 4, 0, 5),
		ZIndex = 14
	}, VisualizerContainer)

	AddCorner(visualBar, 3)

	VisualizerBars[i] = visualBar
end

task.spawn(function()
	local visualTime = 0

	while ScreenGui and ScreenGui.Parent do
		visualTime += 0.09

		for index, bar in ipairs(VisualizerBars) do
			if bar and bar.Parent then
				local height

				if ContentState.Playing then
					height =
						7
						+ math.floor(
							(
								math.abs(
									math.sin(
										visualTime * 2.5
										+ index * 0.57
									)
								)
								+ math.random() * 0.65
							) * 31
						)
				else
					height =
						5
						+ math.floor(
							math.abs(
								math.sin(
									visualTime
									+ index
								)
							) * 4
						)
				end

				SafeTween(
					bar,
					TWEEN.Fast,
					{
						Size = UDim2.new(
							0,
							4,
							0,
							height
						),
						BackgroundTransparency =
							ContentState.Playing
							and 0.32
							or 0.68
					}
				)
			end
		end

		task.wait(0.065)
	end
end)

--// ================================================================
--// PLAYER CENTER GLOW
--// ================================================================

task.spawn(function()
	local glowTime = 0

	while ScreenGui and ScreenGui.Parent do
		glowTime += 0.035

		local transparency =
			ContentState.Playing
			and (
				0.86
				+ math.sin(glowTime * 2) * 0.07
			)
			or 0.92

		pcall(function()
			AlbumGlow.BackgroundTransparency =
				math.clamp(
					transparency,
					0.72,
					0.97
				)
		end)

		task.wait(0.035)
	end
end)

--// ================================================================
--// TRACK INFO RESET
--// ================================================================

local function ResetTrack()
	ContentState.SelectedTrack = nil
	ContentState.Playing = false

	SetText(
		TrackTitle,
		"No Track Selected"
	)

	SetText(
		TrackArtist,
		"Axolion Community"
	)

	SetText(
		TimeCurrent,
		"0:00"
	)

	SetText(
		TimeTotal,
		"0:00"
	)

	SetText(
		PlayPauseButton,
		"▶"
	)

	SafeTween(
		ProgressFill,
		TWEEN.Fast,
		{
			Size = UDim2.new(
				0,
				0,
				1,
				0
			)
		}
	)

	SafeTween(
		ProgressKnob,
		TWEEN.Fast,
		{
			Position = UDim2.new(
				0,
				0,
				0.5,
				0
			)
		}
	)
end

--// ================================================================
--// TRACK SIMULATION TIMER
--// ================================================================

task.spawn(function()
	local simulatedSeconds = 0

	while ScreenGui and ScreenGui.Parent do
		if ContentState.Playing
			and ContentState.SelectedTrack then

			simulatedSeconds += 1

			local totalSeconds = 240

			local minutes =
				math.floor(
					simulatedSeconds / 60
				)

			local seconds =
				simulatedSeconds % 60

			SetText(
				TimeCurrent,
				string.format(
					"%d:%02d",
					minutes,
					seconds
				)
			)

			local progress =
				math.clamp(
					simulatedSeconds / totalSeconds,
					0,
					1
				)

			SafeTween(
				ProgressFill,
				TWEEN.Fast,
				{
					Size = UDim2.new(
						progress,
						0,
						1,
						0
					)
				}
			)

			SafeTween(
				ProgressKnob,
				TWEEN.Fast,
				{
					Position = UDim2.new(
						progress,
						0,
						0.5,
						0
					)
				}
			)

			if simulatedSeconds >= totalSeconds then
				simulatedSeconds = 0

				if ContentState.PlayOnce then
					ContentState.Playing = false
					PlayPauseButton.Text = "▶"
				end
			end
		else
			task.wait(0.25)
		end

		task.wait(1)
	end
end)

--// ================================================================
--// FOLDER DROPDOWN STATE
--// ================================================================

local FolderDropdownButton = New("TextButton", {
	Name = "FolderDropdown",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.28,
	BorderSizePixel = 0,
	Text = "",
	Position = UDim2.new(1, -37, 0, 14),
	Size = UDim2.new(0, 25, 0, 25),
	ZIndex = 12
}, AudioLibraryPanel)

AddCorner(FolderDropdownButton, 7)

local FolderDropdownIcon = New("TextLabel", {
	Name = "Icon",
	BackgroundTransparency = 1,
	Text = "⌄",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 13
}, FolderDropdownButton)

AddButtonInteraction(
	FolderDropdownButton,
	COLORS.DarkBlue2,
	COLORS.DarkBlue3
)

FolderDropdownButton.Activated:Connect(function()
	ContentState.FolderOpen =
		not ContentState.FolderOpen

	if ContentState.FolderOpen then
		AudioFolderContainer.Visible = true

		SafeTween(
			AudioFolderContainer,
			TWEEN.Spring,
			{
				Position = UDim2.new(
					0,
					10,
					0,
					94
				)
			}
		)

		FolderDropdownIcon.Text = "⌃"
	else
		FolderDropdownIcon.Text = "⌄"
	end
end)

ContentState.FolderOpen = true

--// ================================================================
--// PLAYLIST PANEL TOGGLE
--// ================================================================

local PlaylistToggle = New("TextButton", {
	Name = "PlaylistToggle",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.28,
	BorderSizePixel = 0,
	Text = "◀",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.GothamBold,
	TextSize = 9,
	Position = UDim2.new(1, -43, 0, 15),
	Size = UDim2.new(0, 27, 0, 25),
	ZIndex = 13
}, PlaylistPanel)

AddCorner(PlaylistToggle, 7)

AddButtonInteraction(
	PlaylistToggle,
	COLORS.DarkBlue2,
	COLORS.DarkBlue3
)

PlaylistToggle.Activated:Connect(function()
	ContentState.PlaylistOpen =
		not ContentState.PlaylistOpen

	if ContentState.PlaylistOpen then
		SafeTween(
			PlaylistPanel,
			TWEEN.Spring,
			{
				Size = UDim2.new(
					0,
					183,
					1,
					-21
				)
			}
		)

		PlaylistToggle.Text = "◀"
	else
		SafeTween(
			PlaylistPanel,
			TWEEN.Spring,
			{
				Size = UDim2.new(
					0,
					43,
					1,
					-21
				)
			}
		)

		PlaylistToggle.Text = "▶"
	end
end)

--// ================================================================
--// COMMUNITY COPY QUICK ACTIONS
--// ================================================================

local CommunityQuickBar = New("Frame", {
	Name = "QuickActions",
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -205, 0, 12),
	Size = UDim2.new(0, 190, 0, 35),
	ZIndex = 20
}, CommunityHero)

local QuickDiscord = New("TextButton", {
	Name = "Discord",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.DarkBlue2,
	BackgroundTransparency = 0.18,
	BorderSizePixel = 0,
	Text = "DISCORD",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.GothamBold,
	TextSize = 7,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 88, 0, 29),
	ZIndex = 21
}, CommunityQuickBar)

AddCorner(QuickDiscord, 7)
AddStroke(
	QuickDiscord,
	COLORS.ToscaDark,
	1,
	0.65
)

local QuickCommunity = New("TextButton", {
	Name = "Roblox",
	AutoButtonColor = false,
	BackgroundColor3 = COLORS.Tosca,
	BackgroundTransparency = 0.04,
	BorderSizePixel = 0,
	Text = "COMMUNITY",
	TextColor3 = COLORS.Black,
	Font = Enum.Font.GothamBold,
	TextSize = 7,
	Position = UDim2.new(0, 96, 0, 0),
	Size = UDim2.new(0, 94, 0, 29),
	ZIndex = 21
}, CommunityQuickBar)

AddCorner(QuickCommunity, 7)

AddButtonInteraction(
	QuickDiscord,
	COLORS.DarkBlue2,
	COLORS.DarkBlue3
)

AddButtonInteraction(
	QuickCommunity,
	COLORS.Tosca,
	COLORS.ToscaSoft
)

QuickDiscord.Activated:Connect(function()
	CopyToClipboard(
		DISCORD_LINK,
		"Discord link berhasil disalin."
	)
end)

QuickCommunity.Activated:Connect(function()
	CopyToClipboard(
		COMMUNITY_LINK,
		"Roblox Community link berhasil disalin."
	)
end)

--// ================================================================
--// TOOLTIP SYSTEM
--// ================================================================

local Tooltip = New("Frame", {
	Name = "Tooltip",
	Visible = false,
	BackgroundColor3 = COLORS.Black,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Size = UDim2.new(0, 155, 0, 42),
	ZIndex = 500
}, ScreenGui)

AddCorner(Tooltip, 7)
AddStroke(
	Tooltip,
	COLORS.Tosca,
	1,
	0.5
)

local TooltipTitle = New("TextLabel", {
	Name = "Title",
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = COLORS.Tosca,
	Font = Enum.Font.GothamBold,
	TextSize = 8,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 9, 0, 5),
	Size = UDim2.new(1, -18, 0, 14),
	ZIndex = 501
}, Tooltip)

local TooltipText = New("TextLabel", {
	Name = "Description",
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = COLORS.WhiteSoft,
	Font = Enum.Font.Gotham,
	TextSize = 7,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Position = UDim2.new(0, 9, 0, 19),
	Size = UDim2.new(1, -18, 0, 18),
	ZIndex = 501
}, Tooltip)

local function ShowTooltip(title, description, position)
	SetText(TooltipTitle, title)
	SetText(TooltipText, description)

	Tooltip.Position =
		UDim2.fromOffset(
			position.X + 12,
			position.Y + 12
		)

	Tooltip.Visible = true
	Tooltip.BackgroundTransparency = 1
	TooltipTitle.TextTransparency = 1
	TooltipText.TextTransparency = 1

	SafeTween(
		Tooltip,
		TWEEN.Fast,
		{
			BackgroundTransparency = 0.05
		}
	)

	SafeTween(
		TooltipTitle,
		TWEEN.Fast,
		{
			TextTransparency = 0
		}
	)

	SafeTween(
		TooltipText,
		TWEEN.Fast,
		{
			TextTransparency = 0
		}
	)
end

local function HideTooltip()
	if not Tooltip.Visible then
		return
	end

	SafeTween(
		Tooltip,
		TWEEN.Fast,
		{
			BackgroundTransparency = 1
		}
	)

	SafeTween(
		TooltipTitle,
		TWEEN.Fast,
		{
			TextTransparency = 1
		}
	)

	SafeTween(
		TooltipText,
		TWEEN.Fast,
		{
			TextTransparency = 1
		}
	)

	task.delay(0.16, function()
		if Tooltip then
			Tooltip.Visible = false
		end
	end)
end

for key, data in pairs(NavigationButtons) do
	data.Button.MouseEnter:Connect(function()
		if not UIState.SidebarOpen then
			local position =
				data.Button.AbsolutePosition

			ShowTooltip(
				data.Title.Text,
				data.Description.Text,
				position
			)
		end
	end)

	data.Button.MouseLeave:Connect(function()
		HideTooltip()
	end)
end

--// ================================================================
--// RESPONSIVE CONTENT REFRESH
--// ================================================================

local function RefreshContentLayout()
	pcall(function()
		Navigation.CanvasSize = UDim2.new(
			0,
			0,
			0,
			NavigationLayout.AbsoluteContentSize.Y + 15
		)
	end)

	pcall(function()
		AudioFolderContainer.CanvasSize = UDim2.new(
			0,
			0,
			0,
			AudioFolderContainer.UIListLayout.AbsoluteContentSize.Y + 15
		)
	end)

	pcall(function()
		PlaylistContainer.CanvasSize = UDim2.new(
			0,
			0,
					0,
			PlaylistContainer.UIListLayout.AbsoluteContentSize.Y + 15
		)
	end)
end

task.defer(function()
	RefreshContentLayout()
end)

--// ================================================================
--// COMMUNITY HERO ENTRY ANIMATION
--// ================================================================

CommunityHero.Position = UDim2.new(
	0,
	35,
	0,
	4
)

CommunityInfoPanel.Position = UDim2.new(
	0,
	35,
	0,
	187
)

task.defer(function()
	task.wait(0.15)

	SafeTween(
		CommunityHero,
		TWEEN.Spring,
		{
			Position = UDim2.new(
				0,
				18,
				0,
				4
			)
		}
	)

	SafeTween(
		CommunityInfoPanel,
		TWEEN.Spring,
		{
			Position = UDim2.new(
				0,
				18,
				0,
				187
			)
		}
	)
end)

--// ================================================================
--// MUSIC ENTRY ANIMATION
--// ================================================================

local MusicPanels = {
	AudioLibraryPanel,
	PlayerPanel,
	PlaylistPanel
}

for index, panel in ipairs(MusicPanels) do
	if panel then
		local original = panel.Position

		panel.Position = UDim2.new(
			original.X.Scale,
			original.X.Offset + 18,
			original.Y.Scale,
			original.Y.Offset + 5
		)

		task.delay(
			0.08 * index,
			function()
				if panel then
					SafeTween(
						panel,
						TWEEN.Spring,
						{
							Position = original
						}
					)
				end
			end
		)
	end
end

--// ================================================================
--// FINAL PART 2 CONTENT REFRESH
--// ================================================================

task.defer(function()
	RefreshPlaylistForFolder(
		ContentState.SelectedFolder
	)

	RefreshContentLayout()

	ShowToast(
		"AXOMUSC BETA",
		"Music Engine ready."
	)
end)

--// ================================================================
--// PART 2 COMPLETE
--// CONTENT / WORKSPACE READY
--// ================================================================
--// ================================================================
--// AXOMUSC (BETA) — AXOLION COMMUNITY
--// PART 3/4 — FEATURES / CONTENT INTERACTION ENGINE
--// ================================================================
--// Lanjutan langsung dari PART 1 + PART 2.
--// Bagian ini berisi engine interaksi, audio simulation,
--// equalizer, visualizer, playlist/folder switching,
--// responsive behavior, drag, minimize, keybind, tooltip,
--// toast, performance monitor, favorite pinning, dan state engine.
--// ================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--// ================================================================
--// DELTA SAFE ENVIRONMENT
--// ================================================================

local function GetDeltaUIParent()
    local ok, hui = pcall(function()
        if gethui then
            return gethui()
        end
    end)

    if ok and hui then
        return hui
    end

    local ok2, core = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok2 and core then
        return core
    end

    return player:WaitForChild("PlayerGui")
end

local UIParent = GetDeltaUIParent()

--// ================================================================
--// DUPLICATE PROTECTION
--// ================================================================

pcall(function()
    local old = UIParent:FindFirstChild("Axomusc_Beta_UI")
    if old then
        old:Destroy()
    end
end)

--// ================================================================
--// COLORS
--// ================================================================

local DARK_BLUE = Color3.fromRGB(5, 13, 29)
local DARK_BLUE_2 = Color3.fromRGB(7, 20, 39)
local DARK_BLUE_3 = Color3.fromRGB(10, 28, 52)

local BLACK = Color3.fromRGB(2, 5, 10)
local BLACK_2 = Color3.fromRGB(4, 8, 15)

local TOSCA = Color3.fromRGB(35, 221, 198)
local TOSCA_DARK = Color3.fromRGB(17, 125, 116)
local TOSCA_LIGHT = Color3.fromRGB(98, 255, 231)

local WHITE = Color3.fromRGB(245, 250, 255)
local WHITE_2 = Color3.fromRGB(190, 204, 220)
local GREY = Color3.fromRGB(105, 123, 145)

local RED = Color3.fromRGB(255, 80, 95)
local ORANGE = Color3.fromRGB(255, 173, 76)

--// ================================================================
--// SAFE HELPERS
--// ================================================================

local function SafeCall(fn, ...)
    local args = {...}
    local ok, result = pcall(function()
        return fn(table.unpack(args))
    end)

    if ok then
        return result
    end

    return nil
end

local function NewTween(instance, duration, style, direction, properties)
    if not instance then
        return nil
    end

    local tweenInfo = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )

    local tween = SafeCall(function()
        return TweenService:Create(instance, tweenInfo, properties)
    end)

    if tween then
        SafeCall(function()
            tween:Play()
        end)
    end

    return tween
end

local function GetTextSize(text, font, size, bounds)
    return SafeCall(function()
        return game:GetService("TextService"):GetTextSize(
            text,
            size,
            font,
            bounds
        )
    end)
end

--// ================================================================
--// FIND EXISTING OBJECTS FROM PART 1 / PART 2
--// ================================================================

local ScreenGui = UIParent:FindFirstChild("Axomusc_Beta_UI")

if not ScreenGui then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Axomusc_Beta_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = UIParent
end

local function FindRecursive(name)
    return SafeCall(function()
        return ScreenGui:FindFirstChild(name, true)
    end)
end

local MainFrame = FindRecursive("MainFrame")
local Header = FindRecursive("Header")
local Sidebar = FindRecursive("Sidebar")
local WorkspaceArea = FindRecursive("WorkspaceArea")
local MusicWorkspace = FindRecursive("MusicWorkspace")
local CommunityWorkspace = FindRecursive("CommunityWorkspace")
local MinimizeBubble = FindRecursive("MinimizeBubble")
local ToastHolder = FindRecursive("ToastHolder")
local PerformanceLabel = FindRecursive("PerformanceLabel")

--// ================================================================
--// FALLBACK CORE UI
--// ================================================================

if not MainFrame then
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromScale(0.72, 0.72)
    MainFrame.Position = UDim2.fromScale(0.14, 0.14)
    MainFrame.BackgroundColor3 = DARK_BLUE
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = MainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = TOSCA
    stroke.Transparency = 0.2
    stroke.Thickness = 1.5
    stroke.Parent = MainFrame
end

if not WorkspaceArea then
    WorkspaceArea = Instance.new("Frame")
    WorkspaceArea.Name = "WorkspaceArea"
    WorkspaceArea.BackgroundTransparency = 1
    WorkspaceArea.Position = UDim2.new(0, 76, 0, 62)
    WorkspaceArea.Size = UDim2.new(1, -86, 1, -72)
    WorkspaceArea.Parent = MainFrame
end

--// ================================================================
--// STATE ENGINE
--// ================================================================

local State = {
    Visible = true,
    Minimized = false,
    CurrentPage = "Music Engine",

    Volume = 75,
    Speed = 1,
    RepeatMode = 0,
    Shuffle = false,

    IsPlaying = false,
    CurrentTrack = nil,
    CurrentFolder = "My Creations",

    SearchText = "",
    SelectedPlaylist = nil,

    FavoriteTracks = {},
    PlaylistFolders = {},

    Equalizer = {
        Low = 50,
        Mid = 50,
        High = 50,
    },

    Progress = 0,
    TrackLength = 213,

    SidebarExpanded = true,

    Dragging = false,
    DragStart = nil,
    StartPosition = nil,

    Keybind = Enum.KeyCode.RightShift,

    FPS = 60,
    Ping = 0,
}

--// ================================================================
--// DATA MODEL
--// ================================================================

local AudioLibrary = {
    ["My Creations"] = {
        {
            Name = "Axolion Horizon",
            Artist = "Axolion Community",
            Length = 213,
            Image = "rbxassetid://85647271976925",
            SoundId = "rbxassetid://9112892993",
        },
        {
            Name = "Tosca Night",
            Artist = "Axolion Studio",
            Length = 184,
            Image = "rbxassetid://84404991858137",
            SoundId = "rbxassetid://9112892993",
        },
        {
            Name = "Blue Dimension",
            Artist = "Axolion Audio",
            Length = 241,
            Image = "rbxassetid://100003155958609",
            SoundId = "rbxassetid://9112892993",
        },
    },

    ["System Audio"] = {
        {
            Name = "System Ambient",
            Artist = "System Audio",
            Length = 156,
            Image = "rbxassetid://84404991858137",
            SoundId = "rbxassetid://9112892993",
        },
        {
            Name = "Digital Pulse",
            Artist = "System Audio",
            Length = 202,
            Image = "rbxassetid://85647271976925",
            SoundId = "rbxassetid://9112892993",
        },
        {
            Name = "Future Signal",
            Artist = "System Audio",
            Length = 267,
            Image = "rbxassetid://100003155958609",
            SoundId = "rbxassetid://9112892993",
        },
    },

    ["Community Audio"] = {
        {
            Name = "Community Theme",
            Artist = "Axolion Community",
            Length = 225,
            Image = "rbxassetid://85647271976925",
            SoundId = "rbxassetid://9112892993",
        },
        {
            Name = "Axolion Gathering",
            Artist = "Axolion Community",
            Length = 190,
            Image = "rbxassetid://100003155958609",
            SoundId = "rbxassetid://9112892993",
        },
    },

    ["Favorites"] = {},
}

State.PlaylistFolders = {
    "My Creations",
    "System Audio",
    "Community Audio",
    "Favorites",
}

--// ================================================================
--// TOAST ENGINE
--// ================================================================

local function CreateToast(message, duration)
    duration = duration or 2.4

    local holder = ToastHolder

    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "ToastHolder"
        holder.AnchorPoint = Vector2.new(1, 1)
        holder.Position = UDim2.new(1, -18, 1, -18)
        holder.Size = UDim2.new(0, 300, 1, -36)
        holder.BackgroundTransparency = 1
        holder.Parent = ScreenGui

        local layout = Instance.new("UIListLayout")
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 8)
        layout.Parent = holder

        ToastHolder = holder
    end

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 48)
    toast.BackgroundColor3 = BLACK
    toast.BackgroundTransparency = 0.08
    toast.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toast

    local stroke = Instance.new("UIStroke")
    stroke.Color = TOSCA
    stroke.Thickness = 1
    stroke.Transparency = 0.25
    stroke.Parent = toast

    local icon = Instance.new("Frame")
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.Position = UDim2.new(0, 10, 0.5, -14)
    icon.BackgroundColor3 = TOSCA
    icon.Parent = toast

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = icon

    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.fromScale(1, 1)
    iconText.BackgroundTransparency = 1
    iconText.Text = "✓"
    iconText.TextColor3 = BLACK
    iconText.Font = Enum.Font.GothamBold
    iconText.TextSize = 15
    iconText.Parent = icon

    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 48, 0, 0)
    label.Size = UDim2.new(1, -58, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(message)
    label.TextColor3 = WHITE
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toast

    toast.Position = UDim2.new(1, 25, 0, 0)
    toast.BackgroundTransparency = 1

    NewTween(
        toast,
        0.32,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out,
        {
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 0.08,
        }
    )

    task.delay(duration, function()
        if toast and toast.Parent then
            local tween = NewTween(
                toast,
                0.28,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In,
                {
                    Position = UDim2.new(1, 25, 0, 0),
                    BackgroundTransparency = 1,
                }
            )

            if tween then
                tween.Completed:Wait()
            end

            SafeCall(function()
                toast:Destroy()
            end)
        end
    end)
end

--// ================================================================
--// CLIPBOARD
--// ================================================================

local function CopyToClipboard(text)
    local copied = false

    if setclipboard then
        copied = SafeCall(function()
            setclipboard(text)
            return true
        end)
    end

    if copied then
        CreateToast("Link Disalin")
    else
        CreateToast("Clipboard tidak tersedia")
    end
end

--// ================================================================
--// RIPPLE EFFECT
--// ================================================================

local function AddRipple(button)
    if not button or not button:IsA("GuiButton") then
        return
    end

    button.MouseButton1Down:Connect(function(x, y)
        local absolute = button.AbsolutePosition
        local size = button.AbsoluteSize

        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.fromOffset(
            x - absolute.X,
            y - absolute.Y
        )
        ripple.Size = UDim2.fromOffset(0, 0)
        ripple.BackgroundColor3 = TOSCA_LIGHT
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = button.ZIndex + 5
        ripple.Parent = button

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple

        local maximum = math.max(size.X, size.Y) * 1.8

        NewTween(
            ripple,
            0.45,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out,
            {
                Size = UDim2.fromOffset(maximum, maximum),
                BackgroundTransparency = 1,
            }
        )

        task.delay(0.5, function()
            SafeCall(function()
                ripple:Destroy()
            end)
        end)
    end)
end

local function BindRipples(root)
    if not root then
        return
    end

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            if not obj:GetAttribute("RippleBound") then
                obj:SetAttribute("RippleBound", true)
                AddRipple(obj)
            end
        end
    end
end

--// ================================================================
--// BUTTON HOVER
--// ================================================================

local function AddHover(button)
    if not button or not button:IsA("GuiButton") then
        return
    end

    if button:GetAttribute("HoverBound") then
        return
    end

    button:SetAttribute("HoverBound", true)

    local originalTransparency = button.BackgroundTransparency

    button.MouseEnter:Connect(function()
        NewTween(
            button,
            0.18,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out,
            {
                BackgroundTransparency = math.max(
                    0,
                    originalTransparency - 0.12
                ),
            }
        )
    end)

    button.MouseLeave:Connect(function()
        NewTween(
            button,
            0.2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out,
            {
                BackgroundTransparency = originalTransparency,
            }
        )
    end)
end

local function BindHover(root)
    if not root then
        return
    end

    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            AddHover(obj)
        end
    end
end

--// ================================================================
--// TOOLTIP ENGINE
--// ================================================================

local Tooltip = nil

local function ShowTooltip(text, target)
    if not target then
        return
    end

    if not Tooltip then
        Tooltip = Instance.new("TextLabel")
        Tooltip.Name = "GlobalTooltip"
        Tooltip.AutomaticSize = Enum.AutomaticSize.X
        Tooltip.Size = UDim2.new(0, 0, 0, 30)
        Tooltip.BackgroundColor3 = BLACK
        Tooltip.BackgroundTransparency = 0.04
        Tooltip.TextColor3 = WHITE
        Tooltip.Font = Enum.Font.GothamMedium
        Tooltip.TextSize = 11
        Tooltip.TextXAlignment = Enum.TextXAlignment.Center
        Tooltip.TextYAlignment = Enum.TextYAlignment.Center
        Tooltip.ZIndex = 9999
        Tooltip.Visible = false
        Tooltip.Parent = ScreenGui

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.Parent = Tooltip

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = Tooltip

        local stroke = Instance.new("UIStroke")
        stroke.Color = TOSCA
        stroke.Transparency = 0.3
        stroke.Parent = Tooltip
    end

    Tooltip.Text = text
    Tooltip.Visible = true

    local pos = target.AbsolutePosition
    local size = target.AbsoluteSize

    Tooltip.Position = UDim2.fromOffset(
        pos.X + size.X + 8,
        pos.Y + size.Y / 2 - 15
    )

    Tooltip.BackgroundTransparency = 1
    Tooltip.TextTransparency = 1

    NewTween(
        Tooltip,
        0.15,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        {
            BackgroundTransparency = 0.04,
            TextTransparency = 0,
        }
    )
end

local function HideTooltip()
    if not Tooltip then
        return
    end

    NewTween(
        Tooltip,
        0.12,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In,
        {
            BackgroundTransparency = 1,
            TextTransparency = 1,
        }
    )

    task.delay(0.13, function()
        if Tooltip then
            Tooltip.Visible = false
        end
    end)
end

local function BindTooltips(root)
    if not root then
        return
    end

    for _, obj in ipairs(root:GetDescendants()) do
        local tooltip = obj:GetAttribute("Tooltip")

        if tooltip and (obj:IsA("GuiButton") or obj:IsA("GuiObject")) then
            obj.MouseEnter:Connect(function()
                ShowTooltip(tooltip, obj)
            end)

            obj.MouseLeave:Connect(function()
                HideTooltip()
            end)
        end
    end
end

--// ================================================================
--// MUSIC SOUND ENGINE
--// ================================================================

local MusicSound = SoundService:FindFirstChild("Axomusc_RuntimeSound")

if not MusicSound then
    MusicSound = Instance.new("Sound")
    MusicSound.Name = "Axomusc_RuntimeSound"
    MusicSound.Volume = State.Volume / 100
    MusicSound.Looped = false
    MusicSound.Parent = SoundService
end

local function ApplyVolume()
    local volume = math.clamp(State.Volume / 100, 0, 1)

    NewTween(
        MusicSound,
        0.25,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        {
            Volume = volume,
        }
    )
end

local function ApplySpeed()
    local speed = tonumber(State.Speed) or 1

    SafeCall(function()
        MusicSound.PlaybackSpeed = speed
    end)
end

local function LoadTrack(track)
    if not track then
        return
    end

    State.CurrentTrack = track
    State.Progress = 0
    State.TrackLength = track.Length or 180

    SafeCall(function()
        MusicSound:Stop()
    end)

    SafeCall(function()
        MusicSound.SoundId = track.SoundId
    end)

    ApplyVolume()
    ApplySpeed()

    State.IsPlaying = true

    SafeCall(function()
        MusicSound:Play()
    end)

    CreateToast("Memutar • " .. track.Name)
end

local function PauseMusic()
    SafeCall(function()
        MusicSound:Pause()
    end)

    State.IsPlaying = false
end

local function ResumeMusic()
    if not State.CurrentTrack then
        local list = AudioLibrary[State.CurrentFolder]

        if list and #list > 0 then
            LoadTrack(list[1])
        end

        return
    end

    SafeCall(function()
        MusicSound:Resume()
    end)

    State.IsPlaying = true
end

local function TogglePlay()
    if State.IsPlaying then
        PauseMusic()
    else
        ResumeMusic()
    end
end

--// ================================================================
--// TRACK NAVIGATION
--// ================================================================

local function GetCurrentTrackList()
    local list = AudioLibrary[State.CurrentFolder]

    if not list then
        return {}
    end

    return list
end

local function GetCurrentTrackIndex()
    local list = GetCurrentTrackList()

    for index, track in ipairs(list) do
        if track == State.CurrentTrack then
            return index
        end
    end

    return 0
end

local function PlayNext()
    local list = GetCurrentTrackList()

    if #list == 0 then
        return
    end

    local index = GetCurrentTrackIndex()

    if State.Shuffle then
        index = math.random(1, #list)
    else
        index += 1

        if index > #list then
            index = 1
        end
    end

    LoadTrack(list[index])
end

local function PlayPrevious()
    local list = GetCurrentTrackList()

    if #list == 0 then
        return
    end

    local index = GetCurrentTrackIndex()

    if index <= 1 then
        index = #list
    else
        index -= 1
    end

    LoadTrack(list[index])
end

local function ToggleShuffle()
    State.Shuffle = not State.Shuffle

    if State.Shuffle then
        CreateToast("Shuffle Aktif")
    else
        CreateToast("Shuffle Nonaktif")
    end
end

local function CycleRepeat()
    State.RepeatMode += 1

    if State.RepeatMode > 2 then
        State.RepeatMode = 0
    end

    if State.RepeatMode == 0 then
        CreateToast("Repeat Nonaktif")
    elseif State.RepeatMode == 1 then
        CreateToast("Repeat Semua")
    else
        CreateToast("Repeat Satu Lagu")
    end
end

--// ================================================================
--// FAVORITE ENGINE
--// ================================================================

local function IsFavorite(track)
    if not track then
        return false
    end

    return State.FavoriteTracks[track.Name] == true
end

local function ToggleFavorite(track)
    if not track then
        return
    end

    State.FavoriteTracks[track.Name] = not State.FavoriteTracks[track.Name]

    if State.FavoriteTracks[track.Name] then
        table.insert(AudioLibrary.Favorites, track)
        CreateToast("Ditambahkan ke Favorite")
    else
        for index = #AudioLibrary.Favorites, 1, -1 do
            if AudioLibrary.Favorites[index] == track then
                table.remove(AudioLibrary.Favorites, index)
            end
        end

        CreateToast("Dihapus dari Favorite")
    end
end

--// ================================================================
--// PLAYLIST CREATOR
--// ================================================================

local function CreatePlaylist(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if name == "" then
        CreateToast("Nama playlist kosong")
        return false
    end

    if AudioLibrary[name] then
        CreateToast("Playlist sudah ada")
        return false
    end

    AudioLibrary[name] = {}

    table.insert(State.PlaylistFolders, name)

    CreateToast("Playlist dibuat • " .. name)

    return true
end

--// ================================================================
--// SEARCH ENGINE
--// ================================================================

local function SearchTracks(query)
    query = tostring(query or ""):lower()

    local results = {}

    for folderName, tracks in pairs(AudioLibrary) do
        for _, track in ipairs(tracks) do
            local name = tostring(track.Name):lower()
            local artist = tostring(track.Artist):lower()

            if query == ""
                or name:find(query, 1, true)
                or artist:find(query, 1, true)
            then
                table.insert(results, {
                    Track = track,
                    Folder = folderName,
                })
            end
        end
    end

    return results
end

--// ================================================================
--// EQUALIZER ENGINE
--// ================================================================

local EQState = {
    Low = 50,
    Mid = 50,
    High = 50,
}

local function ApplyEqualizer()
    EQState.Low = math.clamp(State.Equalizer.Low, 0, 100)
    EQState.Mid = math.clamp(State.Equalizer.Mid, 0, 100)
    EQState.High = math.clamp(State.Equalizer.High, 0, 100)

    -- Roblox Sound equalization can vary between executor/runtime
    -- versions, therefore this uses safe runtime objects.

    local low = MusicSound:FindFirstChild("AxomuscLowEQ")

    if not low then
        low = Instance.new("EqualizerSoundEffect")
        low.Name = "AxomuscLowEQ"
        low.Parent = MusicSound
    end

    local mid = MusicSound:FindFirstChild("AxomuscMidEQ")

    if not mid then
        mid = Instance.new("EqualizerSoundEffect")
        mid.Name = "AxomuscMidEQ"
        mid.Parent = MusicSound
    end

    SafeCall(function()
        low.LowGain = (EQState.Low - 50) / 2
        low.MidGain = (EQState.Mid - 50) / 3
        low.HighGain = (EQState.High - 50) / 3
    end)
end

--// ================================================================
--// SPEED ENGINE
--// ================================================================

local SpeedOptions = {
    0.5,
    1.0,
    1.5,
    2.0,
}

local function SetSpeed(speed)
    speed = tonumber(speed)

    if not speed then
        return
    end

    for _, option in ipairs(SpeedOptions) do
        if math.abs(option - speed) < 0.001 then
            State.Speed = option
            ApplySpeed()
            CreateToast("Speed • " .. tostring(option) .. "x")
            return
        end
    end
end

--// ================================================================
--// VISUALIZER ENGINE
--// ================================================================

local VisualizerContainer = FindRecursive("VisualizerContainer")

if not VisualizerContainer and MusicWorkspace then
    VisualizerContainer = Instance.new("Frame")
    VisualizerContainer.Name = "VisualizerContainer"
    VisualizerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    VisualizerContainer.Position = UDim2.fromScale(0.5, 0.34)
    VisualizerContainer.Size = UDim2.new(0.48, 0, 0, 130)
    VisualizerContainer.BackgroundTransparency = 1
    VisualizerContainer.Parent = MusicWorkspace
end

local VisualizerBars = {}

if VisualizerContainer then
    for index = 1, 28 do
        local bar = Instance.new("Frame")
        bar.Name = "Bar_" .. index
        bar.AnchorPoint = Vector2.new(0.5, 1)
        bar.Position = UDim2.new(
            (index - 0.5) / 28,
            0,
            1,
            0
        )
        bar.Size = UDim2.new(0, 4, 0, 15)
        bar.BackgroundColor3 = TOSCA
        bar.BackgroundTransparency = 0.18
        bar.BorderSizePixel = 0
        bar.Parent = VisualizerContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = bar

        table.insert(VisualizerBars, bar)
    end
end

--// ================================================================
--// ALBUM ART FINDER
--// ================================================================

local AlbumArt = FindRecursive("AlbumArt")
local TrackTitle = FindRecursive("TrackTitle")
local TrackArtist = FindRecursive("TrackArtist")

local function UpdateTrackVisuals(track)
    if not track then
        return
    end

    if AlbumArt and AlbumArt:IsA("ImageLabel") then
        AlbumArt.Image = track.Image
    end

    if TrackTitle and TrackTitle:IsA("TextLabel") then
        TrackTitle.Text = track.Name
    end

    if TrackArtist and TrackArtist:IsA("TextLabel") then
        TrackArtist.Text = track.Artist
    end
end

--// ================================================================
--// CONNECT PLAYBACK VISUALS
--// ================================================================

local function SyncTrackVisuals()
    if State.CurrentTrack then
        UpdateTrackVisuals(State.CurrentTrack)
    end
end

--// ================================================================
--// GENERIC BUTTON ACTION DETECTOR
--// ================================================================

local function FindButtonByNames(names)
    for _, name in ipairs(names) do
        local object = FindRecursive(name)

        if object and object:IsA("GuiButton") then
            return object
        end
    end

    return nil
end

local PlayButton = FindButtonByNames({
    "PlayButton",
    "PlayPauseButton",
    "PlayPause",
})

local NextButton = FindButtonByNames({
    "NextButton",
    "Next",
})

local PreviousButton = FindButtonByNames({
    "PreviousButton",
    "BackButton",
    "Back",
})

local ShuffleButton = FindButtonByNames({
    "ShuffleButton",
    "Shuffle",
})

local RepeatButton = FindButtonByNames({
    "RepeatButton",
    "Repeat",
})

local FavoriteButton = FindButtonByNames({
    "FavoriteButton",
    "Favorite",
})

--// ================================================================
--// BUTTON CONNECTIONS
--// ================================================================

if PlayButton then
    PlayButton.MouseButton1Click:Connect(function()
        TogglePlay()
    end)
end

if NextButton then
    NextButton.MouseButton1Click:Connect(function()
        PlayNext()
    end)
end

if PreviousButton then
    PreviousButton.MouseButton1Click:Connect(function()
        PlayPrevious()
    end)
end

if ShuffleButton then
    ShuffleButton.MouseButton1Click:Connect(function()
        ToggleShuffle()
    end)
end

if RepeatButton then
    RepeatButton.MouseButton1Click:Connect(function()
        CycleRepeat()
    end)
end

if FavoriteButton then
    FavoriteButton.MouseButton1Click:Connect(function()
        ToggleFavorite(State.CurrentTrack)
    end)
end

--// ================================================================
--// PLAYLIST / FOLDER BUTTON BINDING
--// ================================================================

local function BindFolderButton(button, folderName)
    if not button or not button:IsA("GuiButton") then
        return
    end

    if button:GetAttribute("FolderBound") then
        return
    end

    button:SetAttribute("FolderBound", true)

    button.MouseButton1Click:Connect(function()
        if AudioLibrary[folderName] then
            State.CurrentFolder = folderName
            State.CurrentTrack = nil
            State.Progress = 0

            CreateToast("Folder • " .. folderName)
        end
    end)
end

local function BindExistingFolderButtons()
    if not MusicWorkspace then
        return
    end

    for _, obj in ipairs(MusicWorkspace:GetDescendants()) do
        local folderName = obj:GetAttribute("FolderName")

        if folderName and obj:IsA("GuiButton") then
            BindFolderButton(obj, folderName)
        end
    end
end

--// ================================================================
--// COMMUNITY COPY ACTIONS
--// ================================================================

local DiscordButton = FindButtonByNames({
    "DiscordCopyButton",
    "CopyDiscord",
})

local CommunityButton = FindButtonByNames({
    "CommunityCopyButton",
    "CopyCommunity",
})

if DiscordButton then
    DiscordButton.MouseButton1Click:Connect(function()
        CopyToClipboard("https://discord.gg/dkuXRcS2hY")
    end)
end

if CommunityButton then
    CommunityButton.MouseButton1Click:Connect(function()
        CopyToClipboard("https://www.roblox.com/share/g/245953568")
    end)
end

--// ================================================================
--// DYNAMIC PLAYBACK LABEL
--// ================================================================

local PlayStateLabel = FindRecursive("PlayStateLabel")

local function UpdatePlayStateVisual()
    if not PlayStateLabel then
        return
    end

    if State.IsPlaying then
        PlayStateLabel.Text = "PLAYING"
        PlayStateLabel.TextColor3 = TOSCA
    else
        PlayStateLabel.Text = "PAUSED"
        PlayStateLabel.TextColor3 = WHITE_2
    end
end

--// ================================================================
--// PROGRESS ENGINE
--// ================================================================

local ProgressBar = FindRecursive("ProgressBar")
local ProgressFill = FindRecursive("ProgressFill")
local CurrentTimeLabel = FindRecursive("CurrentTimeLabel")
local DurationLabel = FindRecursive("DurationLabel")

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))

    local minutes = math.floor(seconds / 60)
    local remaining = seconds % 60

    return string.format("%d:%02d", minutes, remaining)
end

local function UpdateProgressVisual()
    if not State.CurrentTrack then
        return
    end

    local length = math.max(
        1,
        State.CurrentTrack.Length or State.TrackLength
    )

    local alpha = math.clamp(
        State.Progress / length,
        0,
        1
    )

    if ProgressFill then
        NewTween(
            ProgressFill,
            0.08,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out,
            {
                Size = UDim2.new(alpha, 0, 1, 0),
            }
        )
    end

    if CurrentTimeLabel then
        CurrentTimeLabel.Text = FormatTime(State.Progress)
    end

    if DurationLabel then
        DurationLabel.Text = FormatTime(length)
    end
end

--// ================================================================
--// PROGRESS CLICK / SEEK
--// ================================================================

if ProgressBar and ProgressBar:IsA("GuiButton") then
    ProgressBar.MouseButton1Click:Connect(function(x)
        if not State.CurrentTrack then
            return
        end

        local absolute = ProgressBar.AbsolutePosition
        local width = ProgressBar.AbsoluteSize.X

        local alpha = math.clamp(
            (x - absolute.X) / width,
            0,
            1
        )

        State.Progress =
            alpha * (State.CurrentTrack.Length or 180)

        SafeCall(function()
            MusicSound.TimePosition = State.Progress
        end)

        UpdateProgressVisual()
    end)
end

--// ================================================================
--// VOLUME SLIDER
--// ================================================================

local VolumeBar = FindRecursive("VolumeBar")
local VolumeFill = FindRecursive("VolumeFill")
local VolumeValue = FindRecursive("VolumeValue")

local function UpdateVolumeVisual()
    local alpha = math.clamp(State.Volume / 100, 0, 1)

    if VolumeFill then
        NewTween(
            VolumeFill,
            0.18,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out,
            {
                Size = UDim2.new(alpha, 0, 1, 0),
            }
        )
    end

    if VolumeValue then
        VolumeValue.Text =
            tostring(math.floor(State.Volume)) .. "%"
    end
end

local function SetVolumeFromX(x)
    if not VolumeBar then
        return
    end

    local absolute = VolumeBar.AbsolutePosition
    local width = VolumeBar.AbsoluteSize.X

    local alpha = math.clamp(
        (x - absolute.X) / width,
        0,
        1
    )

    State.Volume = math.floor(alpha * 100 + 0.5)

    ApplyVolume()
    UpdateVolumeVisual()
end

if VolumeBar and VolumeBar:IsA("GuiButton") then
    VolumeBar.MouseButton1Click:Connect(function(x)
        SetVolumeFromX(x)
    end)
end

--// ================================================================
--// EQUALIZER SLIDER BINDING
--// ================================================================

local function BindEQSlider(name, stateKey)
    local bar = FindRecursive(name)

    if not bar or not bar:IsA("GuiButton") then
        return
    end

    bar.MouseButton1Click:Connect(function(x)
        local absolute = bar.AbsolutePosition
        local width = bar.AbsoluteSize.X

        local alpha = math.clamp(
            (x - absolute.X) / width,
            0,
            1
        )

        State.Equalizer[stateKey] =
            math.floor(alpha * 100 + 0.5)

        ApplyEqualizer()
    end)
end

BindEQSlider("LowEQBar", "Low")
BindEQSlider("MidEQBar", "Mid")
BindEQSlider("HighEQBar", "High")

--// ================================================================
--// SPEED BUTTON BINDING
--// ================================================================

local function BindSpeedButton(name, speed)
    local button = FindRecursive(name)

    if not button or not button:IsA("GuiButton") then
        return
    end

    if button:GetAttribute("SpeedBound") then
        return
    end

    button:SetAttribute("SpeedBound", true)

    button.MouseButton1Click:Connect(function()
        SetSpeed(speed)
    end)
end

BindSpeedButton("Speed05", 0.5)
BindSpeedButton("Speed10", 1)
BindSpeedButton("Speed15", 1.5)
BindSpeedButton("Speed20", 2)

--// ================================================================
--// SIDEBAR NAVIGATION
--// ================================================================

local MusicNavButton = FindButtonByNames({
    "MusicEngineButton",
    "MusicButton",
    "MusicNav",
})

local CommunityNavButton = FindButtonByNames({
    "CommunityButton",
    "CommunityNav",
    "AxolionCommunityButton",
})

local function ShowWorkspace(workspace)
    if not workspace then
        return
    end

    workspace.Visible = true
    workspace.Position = UDim2.fromScale(0.025, 0.025)
    workspace.BackgroundTransparency = 1

    NewTween(
        workspace,
        0.32,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out,
        {
            Position = UDim2.fromScale(0, 0),
            BackgroundTransparency = 0,
        }
    )
end

local function HideWorkspace(workspace)
    if not workspace then
        return
    end

    workspace.Visible = false
end

local function SetPage(page)
    if page == "Music Engine" then
        State.CurrentPage = page

        HideWorkspace(CommunityWorkspace)

        if MusicWorkspace then
            ShowWorkspace(MusicWorkspace)
        end

        CreateToast("Music Engine")
    elseif page == "Axolion Community" then
        State.CurrentPage = page

        HideWorkspace(MusicWorkspace)

        if CommunityWorkspace then
            ShowWorkspace(CommunityWorkspace)
        end

        CreateToast("Axolion Community")
    end
end

if MusicNavButton then
    MusicNavButton.MouseButton1Click:Connect(function()
        SetPage("Music Engine")
    end)
end

if CommunityNavButton then
    CommunityNavButton.MouseButton1Click:Connect(function()
        SetPage("Axolion Community")
    end)
end

--// ================================================================
--// SIDEBAR COLLAPSE
--// ================================================================

local SidebarToggle = FindButtonByNames({
    "SidebarToggle",
    "MenuButton",
    "SidebarMenuButton",
})

local ExpandedSidebarWidth = 205
local CollapsedSidebarWidth = 58

local function ToggleSidebar()
    if not Sidebar then
        return
    end

    State.SidebarExpanded = not State.SidebarExpanded

    local width =
        State.SidebarExpanded
        and ExpandedSidebarWidth
        or CollapsedSidebarWidth

    NewTween(
        Sidebar,
        0.38,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out,
        {
            Size = UDim2.new(0, width, 1, -62),
        }
    )

    if WorkspaceArea then
        local left = width + 10

        NewTween(
            WorkspaceArea,
            0.38,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out,
            {
                Position = UDim2.new(0, left, 0, 62),
                Size = UDim2.new(1, -left - 10, 1, -72),
            }
        )
    end
end

if SidebarToggle then
    SidebarToggle.MouseButton1Click:Connect(function()
        ToggleSidebar()
    end)
end

--// ================================================================
--// MINIMIZE SYSTEM
--// ================================================================

local MinimizeButton = FindButtonByNames({
    "MinimizeButton",
    "Minimize",
})

local function ShowMain()
    if not MainFrame then
        return
    end

    State.Visible = true
    State.Minimized = false

    MainFrame.Visible = true
    MainFrame.BackgroundTransparency = 1

    NewTween(
        MainFrame,
        0.42,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out,
        {
            BackgroundTransparency = 0.08,
            Size = UDim2.fromScale(0.72, 0.72),
        }
    )
end

local function HideMain()
    if not MainFrame then
        return
    end

    State.Visible = false
    State.Minimized = true

    NewTween(
        MainFrame,
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In,
        {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.66, 0.66),
        }
    )

    task.delay(0.31, function()
        if MainFrame and State.Minimized then
            MainFrame.Visible = false
        end
    end)
end

local function ToggleUI()
    if State.Visible then
        HideMain()
    else
        ShowMain()
    end
end

if MinimizeButton then
    MinimizeButton.MouseButton1Click:Connect(function()
        HideMain()
    end)
end

if MinimizeBubble then
    MinimizeBubble.Visible = false

    MinimizeBubble.MouseButton1Click:Connect(function()
        ShowMain()

        MinimizeBubble.Visible = false
    end)
end

--// ================================================================
--// BUBBLE ACTIVATION
--// ================================================================

local function UpdateBubble()
    if not MinimizeBubble then
        return
    end

    MinimizeBubble.Visible = State.Minimized

    if State.Minimized then
        MinimizeBubble.BackgroundTransparency = 1

        NewTween(
            MinimizeBubble,
            0.35,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.Out,
            {
                BackgroundTransparency = 0.08,
            }
        )
    end
end

--// ================================================================
--// KEYBIND CAPTURE ENGINE
--// ================================================================

local KeybindCapturing = false
local KeybindButton = FindButtonByNames({
    "KeybindButton",
    "Keybind",
})

local KeybindLabel = FindRecursive("KeybindLabel")

local function UpdateKeybindVisual()
    if KeybindLabel then
        KeybindLabel.Text = State.Keybind.Name
    end
end

if KeybindButton then
    KeybindButton.MouseButton1Click:Connect(function()
        if KeybindCapturing then
            return
        end

        KeybindCapturing = true

        if KeybindLabel then
            KeybindLabel.Text = "PRESS KEY..."
            KeybindLabel.TextColor3 = TOSCA
        end

        CreateToast("Tekan tombol untuk Keybind")
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if KeybindCapturing then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            State.Keybind = input.KeyCode
            KeybindCapturing = false

            UpdateKeybindVisual()

            if KeybindLabel then
                KeybindLabel.TextColor3 = WHITE
            end

            CreateToast("Keybind • " .. input.KeyCode.Name)

            return
        end
    end

    if processed then
        return
    end

    if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == State.Keybind
    then
        ToggleUI()
        UpdateBubble()
    end
end)

--// ================================================================
--// DRAG SYSTEM
--// ================================================================

local DragTarget = Header or MainFrame

if DragTarget and MainFrame then
    DragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            State.Dragging = true
            State.DragStart = input.Position
            State.StartPosition = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    State.Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not State.Dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch
        then
            return
        end

        local delta = input.Position - State.DragStart

        local viewport =
            workspace.CurrentCamera
            and workspace.CurrentCamera.ViewportSize

        if viewport then
            local absolute = MainFrame.AbsoluteSize

            local scaleX = delta.X / viewport.X
            local scaleY = delta.Y / viewport.Y

            local newPosition = UDim2.new(
                State.StartPosition.X.Scale + scaleX,
                State.StartPosition.X.Offset,
                State.StartPosition.Y.Scale + scaleY,
                State.StartPosition.Y.Offset
            )

            local xScale = math.clamp(
                newPosition.X.Scale,
                0,
                1
            )

            local yScale = math.clamp(
                newPosition.Y.Scale,
                0,
                1
            )

            MainFrame.Position = UDim2.new(
                xScale,
                newPosition.X.Offset,
                yScale,
                newPosition.Y.Offset
            )
        end
    end)
end

--// ================================================================
--// CORNER SNAP
--// ================================================================

local function SnapToNearestCorner()
    if not MainFrame then
        return
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local centerX =
        MainFrame.AbsolutePosition.X
        + MainFrame.AbsoluteSize.X / 2

    local centerY =
        MainFrame.AbsolutePosition.Y
        + MainFrame.AbsoluteSize.Y / 2

    local targetX
    local targetY

    if centerX < viewport.X / 2 then
        targetX = 0.025
    else
        targetX = 0.975 - (
            MainFrame.AbsoluteSize.X / viewport.X
        )
    end

    if centerY < viewport.Y / 2 then
        targetY = 0.08
    else
        targetY = 0.92 - (
            MainFrame.AbsoluteSize.Y / viewport.Y
        )
    end

    NewTween(
        MainFrame,
        0.4,
        Enum.EasingStyle.Spring,
        Enum.EasingDirection.Out,
        {
            Position = UDim2.fromScale(
                math.clamp(targetX, 0, 0.9),
                math.clamp(targetY, 0, 0.85)
            ),
        }
    )
end

if DragTarget then
    DragTarget.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            task.delay(0.05, function()
                if not State.Dragging then
                    SnapToNearestCorner()
                end
            end)
        end
    end)
end

--// ================================================================
--// RESPONSIVE SCALE
--// ================================================================

local UIScale = MainFrame:FindFirstChildOfClass("UIScale")

if not UIScale then
    UIScale = Instance.new("UIScale")
    UIScale.Scale = 1
    UIScale.Parent = MainFrame
end

local function UpdateResponsiveScale()
    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local baseWidth = 1280
    local baseHeight = 720

    local widthScale = viewport.X / baseWidth
    local heightScale = viewport.Y / baseHeight

    local scale = math.min(
        widthScale,
        heightScale
    )

    scale = math.clamp(scale, 0.62, 1.2)

    NewTween(
        UIScale,
        0.22,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        {
            Scale = scale,
        }
    )
end

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal(
        "ViewportSize"
    ):Connect(UpdateResponsiveScale)
end

UpdateResponsiveScale()

--// ================================================================
--// PERFORMANCE MONITOR
--// ================================================================

local FrameCounter = 0
local FPSAccumulator = 0
local LastPerformanceUpdate = os.clock()

local function GetPing()
    local ping = 0

    local ok = pcall(function()
        local network =
            Stats.Network.ServerStatsItem[
                "Data Ping"
            ]

        if network then
            ping = network:GetValue()
        end
    end)

    if not ok then
        ping = 0
    end

    return math.floor(ping)
end

RunService.RenderStepped:Connect(function(deltaTime)
    FrameCounter += 1
    FPSAccumulator += deltaTime

    if FPSAccumulator >= 1 then
        State.FPS = math.floor(
            FrameCounter / FPSAccumulator
        )

        FrameCounter = 0
        FPSAccumulator = 0

        State.Ping = GetPing()

        if PerformanceLabel then
            PerformanceLabel.Text =
                "FPS "
                .. tostring(State.FPS)
                .. "  •  "
                .. tostring(State.Ping)
                .. " ms"
        end
    end
end)

--// ================================================================
--// VISUALIZER LOOP
--// ================================================================

local visualTime = 0

RunService.RenderStepped:Connect(function(dt)
    visualTime += dt

    for index, bar in ipairs(VisualizerBars) do
        if bar and bar.Parent then
            local wave =
                math.sin(
                    visualTime * 4
                    + index * 0.45
                )

            local secondary =
                math.sin(
                    visualTime * 2.3
                    + index * 0.19
                )

            local energy =
                math.abs(
                    wave * 0.65
                    + secondary * 0.35
                )

            local active =
                State.IsPlaying
                and energy
                or 0.18

            local height =
                14 + active * 65

            bar.Size = UDim2.new(
                0,
                4,
                0,
                height
            )

            bar.BackgroundTransparency =
                State.IsPlaying
                and 0.05
                or 0.3
        end
    end
end)

--// ================================================================
--// PLAYBACK TIME LOOP
--// ================================================================

RunService.Heartbeat:Connect(function(dt)
    if not State.CurrentTrack then
        return
    end

    if State.IsPlaying then
        local current = SafeCall(function()
            return MusicSound.TimePosition
        end)

        if current ~= nil then
            State.Progress = current
        else
            State.Progress += dt * State.Speed
        end

        local length =
            State.CurrentTrack.Length
            or State.TrackLength

        if State.Progress >= length - 0.05 then
            if State.RepeatMode == 2 then
                State.Progress = 0

                SafeCall(function()
                    MusicSound.TimePosition = 0
                    MusicSound:Play()
                end)

            elseif State.RepeatMode == 1 then
                PlayNext()

            else
                PlayNext()
            end
        end

        UpdateProgressVisual()
    end
end)

--// ================================================================
--// SOUND EVENT
--// ================================================================

MusicSound.Ended:Connect(function()
    if State.RepeatMode == 2 then
        SafeCall(function()
            MusicSound.TimePosition = 0
            MusicSound:Play()
        end)

        State.IsPlaying = true
    else
        PlayNext()
    end
end)

--// ================================================================
--// UPDATE PLAY BUTTON ICON
--// ================================================================

local function UpdatePlayButton()
    if not PlayButton then
        return
    end

    local textObject = PlayButton:FindFirstChildWhichIsA(
        "TextLabel",
        true
    )

    if textObject then
        textObject.Text =
            State.IsPlaying
            and "Ⅱ"
            or "▶"
    end
end

RunService.RenderStepped:Connect(function()
    UpdatePlayStateVisual()
    UpdatePlayButton()
end)

--// ================================================================
--// TRACK AUTO SYNC
--// ================================================================

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if State.CurrentTrack then
            SyncTrackVisuals()
        end

        task.wait(0.5)
    end
end)

--// ================================================================
--// APPLY INITIAL AUDIO SETTINGS
--// ================================================================

ApplyVolume()
ApplySpeed()
ApplyEqualizer()
UpdateVolumeVisual()
UpdateKeybindVisual()
BindExistingFolderButtons()

--// ================================================================
--// GLOBAL INTERACTION BIND
--// ================================================================

BindRipples(ScreenGui)
BindHover(ScreenGui)
BindTooltips(ScreenGui)

--// ================================================================
--// PAGE INITIALIZATION
--// ================================================================

if CommunityWorkspace then
    CommunityWorkspace.Visible = false
end

if MusicWorkspace then
    MusicWorkspace.Visible = true
end

State.CurrentPage = "Music Engine"

--// ================================================================
--// MINIMIZE STATE INITIALIZATION
--// ================================================================

if MinimizeBubble then
    MinimizeBubble.Visible = false
end

--// ================================================================
--// GLOBAL SAFE CLEANUP
--// ================================================================

local CleanupBindable = Instance.new("BindableEvent")
CleanupBindable.Name = "AxomuscCleanup"
CleanupBindable.Parent = ScreenGui

CleanupBindable.Event:Connect(function()
    State.Dragging = false
    State.IsPlaying = false

    SafeCall(function()
        MusicSound:Stop()
    end)

    SafeCall(function()
        MusicSound:Destroy()
    end)

    SafeCall(function()
        ScreenGui:Destroy()
    end)
end)

--// ================================================================
--// PUBLIC INTERNAL CONTROLLER
--// ================================================================

local Controller = {}

function Controller.Toggle()
    ToggleUI()
    UpdateBubble()
end

function Controller.Show()
    ShowMain()
    UpdateBubble()
end

function Controller.Hide()
    HideMain()
    UpdateBubble()
end

function Controller.Play()
    ResumeMusic()
end

function Controller.Pause()
    PauseMusic()
end

function Controller.Next()
    PlayNext()
end

function Controller.Previous()
    PlayPrevious()
end

function Controller.Volume(value)
    State.Volume = math.clamp(
        tonumber(value) or State.Volume,
        0,
        100
    )

    ApplyVolume()
    UpdateVolumeVisual()
end

function Controller.Speed(value)
    SetSpeed(value)
end

function Controller.Page(page)
    SetPage(page)
end

function Controller.Favorite()
    ToggleFavorite(State.CurrentTrack)
end

function Controller.Toast(message)
    CreateToast(message)
end

--// ================================================================
--// EXPOSE SAFE CONTROLLER
--// ================================================================

SafeCall(function()
    getgenv().AxomuscController = Controller
end)

--// ================================================================
--// FINAL VISUAL POLISH
--// ================================================================

if MainFrame then
    local stroke = MainFrame:FindFirstChildOfClass("UIStroke")

    if stroke then
        task.spawn(function()
            local phase = 0

            while stroke and stroke.Parent do
                phase += 0.025

                local pulse =
                    (math.sin(phase) + 1) / 2

                stroke.Transparency =
                    0.12 + pulse * 0.2

                stroke.Thickness =
                    1.25 + pulse * 0.75

                task.wait(0.035)
            end
        end)
    end
end

--// ================================================================
--// HEADER ACCENT ANIMATION
--// ================================================================

if Header then
    local headerStroke = Header:FindFirstChildOfClass(
        "UIStroke"
    )

    if headerStroke then
        task.spawn(function()
            local t = 0

            while Header and Header.Parent do
                t += 0.035

                local pulse =
                    (math.sin(t * 2) + 1) / 2

                headerStroke.Transparency =
                    0.15 + pulse * 0.22

                task.wait(0.04)
            end
        end)
    end
end

--// ================================================================
--// COMMUNITY PAGE IMAGE ENFORCEMENT
--// ================================================================

local CommunityLogo = FindRecursive("CommunityLogo")

if CommunityLogo and CommunityLogo:IsA("ImageLabel") then
    CommunityLogo.Image =
        "rbxassetid://100003155958609"
end

--// ================================================================
--// MUSIC ALBUM IMAGE ENFORCEMENT
--// ================================================================

if AlbumArt and AlbumArt:IsA("ImageLabel") then
    AlbumArt.Image =
        "rbxassetid://85647271976925"
end

--// ================================================================
--// TOOLTIP ATTRIBUTE FALLBACKS
--// ================================================================

if MusicNavButton then
    MusicNavButton:SetAttribute(
        "Tooltip",
        "Music Engine"
    )
end

if CommunityNavButton then
    CommunityNavButton:SetAttribute(
        "Tooltip",
        "Axolion Community"
    )
end

if SidebarToggle then
    SidebarToggle:SetAttribute(
        "Tooltip",
        "Collapse Sidebar"
    )
end

if MinimizeButton then
    MinimizeButton:SetAttribute(
        "Tooltip",
        "Minimize"
    )
end

if ShuffleButton then
    ShuffleButton:SetAttribute(
        "Tooltip",
        "Shuffle"
    )
end

if RepeatButton then
    RepeatButton:SetAttribute(
        "Tooltip",
        "Repeat"
    )
end

if PreviousButton then
    PreviousButton:SetAttribute(
        "Tooltip",
        "Previous"
    )
end

if PlayButton then
    PlayButton:SetAttribute(
        "Tooltip",
        "Play / Pause"
    )
end

if NextButton then
    NextButton:SetAttribute(
        "Tooltip",
        "Next"
    )
end

if FavoriteButton then
    FavoriteButton:SetAttribute(
        "Tooltip",
        "Favorite"
    )
end

BindTooltips(ScreenGui)

--// ================================================================
--// SAFE INITIAL TRACK
--// ================================================================

local initialTracks =
    AudioLibrary["My Creations"]

if initialTracks and #initialTracks > 0 then
    State.CurrentTrack = initialTracks[1]
    State.TrackLength = initialTracks[1].Length

    UpdateTrackVisuals(
        initialTracks[1]
    )
end

UpdateVolumeVisual()
UpdateProgressVisual()
UpdatePlayStateVisual()

--// ================================================================
--// INITIAL TOAST
--// ================================================================

task.delay(0.8, function()
    if ScreenGui and ScreenGui.Parent then
        CreateToast(
            "Axomusc Beta • Axolion Community"
        )
    end
end)

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