-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Delta Specific GUI Parent Handling
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BankrollGui_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false

local function ParentToUI()
    -- 1. Попытка через специфичную для Delta функцию gethui()
    if gethui then
        local success, err = pcall(function()
            ScreenGui.Parent = gethui()
        end)
        if success and ScreenGui.Parent then return end
    end

    -- 2. Попытка через CoreGui
    local successCore = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if successCore and ScreenGui.Parent then return end

    -- 3. Резервный вариант (PlayerGui)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if playerGui then
        ScreenGui.Parent = playerGui
    end
end

ParentToUI()

-- Theme Config
local DarkTheme = {
    MainBg = Color3.fromRGB(15, 15, 15),
    TopBarBg = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(40, 40, 40),
    Accent = Color3.fromRGB(120, 0, 180),
    Text = Color3.fromRGB(220, 220, 220),
    TextDim = Color3.fromRGB(150, 150, 150),
    Font = Enum.Font.Code
}

-- Settings State
local RagebotSettings = { AutoShoot = true, AutoWall = true, MinDamage = 25, AutoStop = true, TargetPart = "Head", Multipoint = true }
local AntiAimSettings = { Enabled = true, Style = "spin", BaseDirection = "backwards", Pitch = "down", FakeLag = true, FakeLagLimit = 8, Freestanding = true, FakeDuck = false, InvertSide = false }
local RageSettings = { StrafeSpeed = 32, BunnyHop = true, ThirdPerson = false, NoClip = false, PixelSurf = false, InfiniteJump = false, AntiVoid = true }
local VisualsSettings = { Box = true, Skeleton = true, Nickname = true, BulletTracers = true, Hitmarkers = true, AAIndicators = true, HitSound = true, HitSoundType = "SAMP bell", CustomSkybox = false, SkyboxType = "Purple Nebula", CustomMask = false, MaskType = "Payday Clown" }

-- Watermark Toggle
local Watermark = Instance.new("TextButton")
Watermark.Name = "WatermarkToggle"
Watermark.Position = UDim2.new(0, 15, 0, 15)
Watermark.Size = UDim2.new(0, 170, 0, 24)
Watermark.BackgroundColor3 = DarkTheme.MainBg
Watermark.BorderColor3 = DarkTheme.Accent
Watermark.BorderSizePixel = 1
Watermark.Text = " bankroll.sosu | 60 fps"
Watermark.TextColor3 = DarkTheme.Text
Watermark.TextSize = 12
Watermark.Font = DarkTheme.Font
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.Parent = ScreenGui

local WmPadding = Instance.new("UIPadding")
WmPadding.PaddingLeft = UDim.new(0, 8)
WmPadding.Parent = Watermark

-- Main Frame Setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = DarkTheme.MainBg
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = DarkTheme.Border
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

Watermark.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = DarkTheme.TopBarBg
TopBar.BorderSizePixel = 1
TopBar.BorderColor3 = DarkTheme.Border
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "bankroll | mobile hvh edition (Delta Fix)"
TitleLabel.TextColor3 = DarkTheme.Accent
TitleLabel.TextSize = 14
TitleLabel.Font = DarkTheme.Font
TitleLabel.Parent = TopBar

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 25)
TabBar.Position = UDim2.new(0, 0, 1, -25)
TabBar.BackgroundColor3 = DarkTheme.TopBarBg
TabBar.BorderSizePixel = 1
TabBar.BorderColor3 = DarkTheme.Border
TabBar.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -60)
ContentArea.Position = UDim2.new(0, 10, 0, 30)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Create Tab Frames
local RagebotTab = Instance.new("Frame"); RagebotTab.Size = UDim2.new(1,0,1,0); RagebotTab.BackgroundTransparency = 1; RagebotTab.Visible = true; RagebotTab.Parent = ContentArea
local AntiAimTab = Instance.new("Frame"); AntiAimTab.Size = UDim2.new(1,0,1,0); AntiAimTab.BackgroundTransparency = 1; AntiAimTab.Visible = false; AntiAimTab.Parent = ContentArea
local MovementTab = Instance.new("Frame"); MovementTab.Size = UDim2.new(1,0,1,0); MovementTab.BackgroundTransparency = 1; MovementTab.Visible = false; MovementTab.Parent = ContentArea
local VisualsTab = Instance.new("Frame"); VisualsTab.Size = UDim2.new(1,0,1,0); VisualsTab.BackgroundTransparency = 1; VisualsTab.Visible = false; VisualsTab.Parent = ContentArea
local SettingsTab = Instance.new("Frame"); SettingsTab.Size = UDim2.new(1,0,1,0); SettingsTab.BackgroundTransparency = 1; SettingsTab.Visible = false; SettingsTab.Parent = ContentArea

-- Helper Functions UI
local function CreateGroupBox(parent, title, pos, size)
    local Box = Instance.new("Frame")
    Box.Position = pos; Box.Size = size
    Box.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Box.BorderColor3 = DarkTheme.Border; Box.BorderSizePixel = 1
    Box.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.new(0, 10, 0, -8); Label.BackgroundColor3 = DarkTheme.MainBg
    Label.Text = " " .. title .. " "; Label.TextColor3 = DarkTheme.TextDim; Label.TextSize = 11; Label.Font = DarkTheme.Font
    Label.Size = UDim2.new(0, 100, 0, 14)
    Label.Parent = Box

    local Layout = Instance.new("UIListLayout"); Layout.Parent = Box; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 5)
    local Padding = Instance.new("UIPadding"); Padding.Parent = Box; Padding.PaddingTop = UDim.new(0, 10); Padding.PaddingLeft = UDim.new(0, 8); Padding.PaddingRight = UDim.new(0, 8)
    return Box
end

local function CreateToggle(parent, text, defaultState, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 18); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.Text = ""; ToggleBtn.Parent = parent

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 12, 0, 12); Box.Position = UDim2.new(0, 0, 0.5, -6)
    Box.BackgroundColor3 = defaultState and DarkTheme.Accent or Color3.fromRGB(30, 30, 30)
    Box.BorderColor3 = DarkTheme.Border; Box.BorderSizePixel = 1; Box.Parent = ToggleBtn

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -20, 1, 0); Text.Position = UDim2.new(0, 20, 0, 0); Text.BackgroundTransparency = 1
    Text.Text = text; Text.TextColor3 = DarkTheme.Text; Text.TextSize = 11; Text.Font = DarkTheme.Font; Text.TextXAlignment = Enum.TextXAlignment.Left; Text.Parent = ToggleBtn

    local state = defaultState
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and DarkTheme.Accent or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 26); Container.BackgroundTransparency = 1; Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 12); Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default); Label.TextColor3 = DarkTheme.Text; Label.TextSize = 11; Label.Font = DarkTheme.Font; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 6); Track.Position = UDim2.new(0, 0, 0, 16)
    Track.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Track.BorderColor3 = DarkTheme.Border; Track.BorderSizePixel = 1; Track.Parent = Container

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = DarkTheme.Accent; Fill.BorderSizePixel = 0; Fill.Parent = Track

    local sliding = false
    local function update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + pos * (max - min))
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Label.Text = text .. ": " .. tostring(val)
        callback(val)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true; update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
end

local function CreateSelector(parent, labelText, options, defaultOption, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 20); Container.BackgroundTransparency = 1; Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.45, 0, 1, 0); Label.BackgroundTransparency = 1; Label.Text = labelText; Label.TextColor3 = DarkTheme.Text; Label.TextSize = 11; Label.Font = DarkTheme.Font; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.55, 0, 1, 0); Button.Position = UDim2.new(0.45, 0, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Button.BorderColor3 = DarkTheme.Border; Button.BorderSizePixel = 1; Button.Text = defaultOption; Button.TextColor3 = DarkTheme.Accent; Button.TextSize = 11; Button.Font = DarkTheme.Font; Button.Parent = Container

    local currentIndex = 1
    for i, opt in ipairs(options) do if opt == defaultOption then currentIndex = i break end end

    Button.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #options) + 1
        local selected = options[currentIndex]
        Button.Text = selected
        callback(selected)
    end)
end

-- Tab Management
local tabs = {
    {Name = "ragebot", Frame = RagebotTab},
    {Name = "anti-aim", Frame = AntiAimTab},
    {Name = "movement", Frame = MovementTab},
    {Name = "visuals", Frame = VisualsTab},
    {Name = "settings", Frame = SettingsTab}
}

for i, tab in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1/#tabs, 0, 1, 0); TabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    TabButton.BackgroundTransparency = 1; TabButton.Text = tab.Name
    TabButton.TextColor3 = (i == 1) and DarkTheme.Text or DarkTheme.TextDim; TabButton.TextSize = 12; TabButton.Font = DarkTheme.Font; TabButton.Parent = TabBar

    TabButton.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do t.Frame.Visible = false end
        tab.Frame.Visible = true
        for _, btn in ipairs(TabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = DarkTheme.TextDim end end
        TabButton.TextColor3 = DarkTheme.Text
    end)
end

-- Fill Ragebot
local MainRage = CreateGroupBox(RagebotTab, "ragebot main", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(MainRage, "auto shoot", RagebotSettings.AutoShoot, function(v) RagebotSettings.AutoShoot = v end)
CreateToggle(MainRage, "auto wall", RagebotSettings.AutoWall, function(v) RagebotSettings.AutoWall = v end)
CreateToggle(MainRage, "auto stop", RagebotSettings.AutoStop, function(v) RagebotSettings.AutoStop = v end)
CreateSlider(MainRage, "min damage", 1, 100, RagebotSettings.MinDamage, function(v) RagebotSettings.MinDamage = v end)

local TargetRage = CreateGroupBox(RagebotTab, "target settings", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSelector(TargetRage, "hitbox", {"Head", "Chest", "Pelvis"}, RagebotSettings.TargetPart, function(v) RagebotSettings.TargetPart = v end)
CreateToggle(TargetRage, "multipoint", RagebotSettings.Multipoint, function(v) RagebotSettings.Multipoint = v end)

-- Fill Anti-Aim
local AAMain = CreateGroupBox(AntiAimTab, "anti-aim", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(AAMain, "enabled", AntiAimSettings.Enabled, function(v) AntiAimSettings.Enabled = v end)
CreateSelector(AAMain, "style", {"spin", "left-right", "jitter"}, AntiAimSettings.Style, function(v) AntiAimSettings.Style = v end)
CreateSelector(AAMain, "base dir", {"backwards", "forward", "left", "right"}, AntiAimSettings.BaseDirection, function(v) AntiAimSettings.BaseDirection = v end)
CreateSelector(AAMain, "pitch", {"down", "up", "zero"}, AntiAimSettings.Pitch, function(v) AntiAimSettings.Pitch = v end)

local AADesync = CreateGroupBox(AntiAimTab, "desync & fakelag", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(AADesync, "freestanding", AntiAimSettings.Freestanding, function(v) AntiAimSettings.Freestanding = v end)
CreateToggle(AADesync, "fake lag", AntiAimSettings.FakeLag, function(v) AntiAimSettings.FakeLag = v end)
CreateSlider(AADesync, "lag ticks", 1, 14, AntiAimSettings.FakeLagLimit, function(v) AntiAimSettings.FakeLagLimit = v end)

-- Fill Movement
local MoveBox = CreateGroupBox(MovementTab, "movement", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSlider(MoveBox, "strafe speed", 16, 120, RageSettings.StrafeSpeed, function(v) RageSettings.StrafeSpeed = v end)
CreateToggle(MoveBox, "bunny hop", RageSettings.BunnyHop, function(v) RageSettings.BunnyHop = v end)

local ExploitBox = CreateGroupBox(MovementTab, "exploits", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(ExploitBox, "noclip", RageSettings.NoClip, function(v) RageSettings.NoClip = v end)
CreateToggle(ExploitBox, "anti-void", RageSettings.AntiVoid, function(v) RageSettings.AntiVoid = v end)

-- Fill Visuals
local VisBox = CreateGroupBox(VisualsTab, "hvh indicators", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(VisBox, "box esp", VisualsSettings.Box, function(v) VisualsSettings.Box = v end)
CreateToggle(VisBox, "aa indicators", VisualsSettings.AAIndicators, function(v) VisualsSettings.AAIndicators = v end)

-- Mobile Inverter Button
local MobileInverterBtn = Instance.new("TextButton")
MobileInverterBtn.Name = "InverterButton"
MobileInverterBtn.Size = UDim2.new(0, 48, 0, 48)
MobileInverterBtn.Position = UDim2.new(0.85, 0, 0.4, 0)
MobileInverterBtn.BackgroundColor3 = DarkTheme.TopBarBg
MobileInverterBtn.BorderColor3 = DarkTheme.Accent
MobileInverterBtn.BorderSizePixel = 2
MobileInverterBtn.Text = "INV"
MobileInverterBtn.TextColor3 = DarkTheme.Text
MobileInverterBtn.TextSize = 13
MobileInverterBtn.Font = DarkTheme.Font
MobileInverterBtn.Parent = ScreenGui

MobileInverterBtn.MouseButton1Click:Connect(function()
    AntiAimSettings.InvertSide = not AntiAimSettings.InvertSide
    MobileInverterBtn.BorderColor3 = AntiAimSettings.InvertSide and Color3.fromRGB(0, 255, 120) or DarkTheme.Accent
end)

-- FPS Loop
local frameCount = 0
local lastFpsUpdate = os.clock()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastFpsUpdate >= 0.5 then
        local fps = math.floor(frameCount / (now - lastFpsUpdate))
        Watermark.Text = string.format(" bankroll.sosu | %d fps", fps)
        frameCount = 0
        lastFpsUpdate = now
    end
end)

-- Dragging System
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
