--[[
    BANKROLL.SOSU | Mobile HvH Suite
    Optimized for Mobile Executors (Delta, Hydrogen, Codex, Arceus X)
    Full HvH Feature Set with Mobile Optimization & Modern UI
--]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera

-- Parent GUI setup with safe execution for Mobile Executors
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BankrollGui_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false

local function ParentScreenGui()
    if gethui then
        local success = pcall(function() ScreenGui.Parent = gethui() end)
        if success and ScreenGui.Parent then return end
    end

    local successCore = pcall(function() ScreenGui.Parent = CoreGui end)
    if successCore and ScreenGui.Parent then return end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if playerGui then
        ScreenGui.Parent = playerGui
    end
end

ParentScreenGui()

---------------------------------------------------------
-- PRESETS CATALOG & STATE CONFIG
---------------------------------------------------------

local SkyboxPresets = {
    ["Purple Nebula"] = "rbxassetid://159454299",
    ["Space Stars"]   = "rbxassetid://266205510",
    ["Night City"]    = "rbxassetid://12064107",
    ["Cyber Red"]     = "rbxassetid://252765781"
}

local MaskPresets = {
    ["Payday Clown"]  = 142491170,
    ["Dallas Payday"] = 142491152,
    ["Dallas USA"]    = 143187121,
    ["Skull Payday"]   = 142491136,
    ["Dallas Classic"] = 143187140
}

local HitSounds = {
    ["SAMP bell"]  = "rbxassetid://13510737",
    ["Skeet"]      = "rbxassetid://566585149",
    ["Neverlose"]  = "rbxassetid://656667534",
    ["Стон тянки"] = "rbxassetid://1676645367",
    ["Click"]      = "rbxassetid://12221967",
    ["CS Headshot"]= "rbxassetid://143242095"
}

local Config = {
    Ragebot = {
        Enabled = true,
        AutoShoot = true,
        SilentAim = true,
        TargetSelection = "Distance", -- Distance, Health, FOV
        TargetPart = "Head",          -- Head, Chest, Pelvis
        FOV = 180,
        ShowFOVCircle = true,
        MinDamage = 25,
        AutoStop = true,
        Multipoint = true
    },
    AntiAim = {
        Enabled = true,
        Style = "spin",              -- spin, jitter, left-right
        BaseDirection = "backwards",  -- backwards, forward, left, right
        Pitch = "down",              -- down, up, zero
        SpinSpeed = 20,
        JitterRange = 45,
        FakeLag = true,
        FakeLagLimit = 8,
        FakeDuck = false,
        InvertSide = false,
        ManualDir = "Back"            -- Left, Right, Back
    },
    Movement = {
        StrafeSpeed = 32,
        BunnyHop = true,
        AutoStrafe = true,
        Fly = false,
        FlySpeed = 50,
        ThirdPerson = false,
        NoClip = false,
        AntiVoid = true
    },
    Visuals = {
        BoxESP = true,
        HealthBar = true,
        WeaponText = true,
        Chams = true,
        HitSound = true,
        HitSoundType = "SAMP bell",
        CustomSkybox = false,
        SkyboxType = "Purple Nebula",
        CustomMask = false,
        MaskType = "Payday Clown"
    },
    UI = {
        Font = "Code",
        ThemeAccent = Color3.fromRGB(140, 30, 220),
        MainBg = Color3.fromRGB(15, 15, 15),
        TopBarBg = Color3.fromRGB(20, 20, 20),
        Border = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(220, 220, 220),
        TextDim = Color3.fromRGB(150, 150, 150)
    }
}

---------------------------------------------------------
-- NOTIFICATION TOAST SYSTEM
---------------------------------------------------------

local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 220, 0, 300)
ToastContainer.Position = UDim2.new(1, -230, 0, 20)
ToastContainer.BackgroundTransparency = 1
ToastContainer.Parent = ScreenGui

local ToastList = Instance.new("UIListLayout")
ToastList.SortOrder = Enum.SortOrder.LayoutOrder
ToastList.Padding = UDim.new(0, 6)
ToastList.Parent = ToastContainer

local function Notify(title, message, duration)
    duration = duration or 3
    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 40)
    Toast.BackgroundColor3 = Config.UI.MainBg
    Toast.BorderColor3 = Config.UI.ThemeAccent
    Toast.BorderSizePixel = 1
    Toast.BackgroundTransparency = 1
    Toast.Parent = ToastContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Toast

    local TTitle = Instance.new("TextLabel")
    TTitle.Size = UDim2.new(1, -10, 0, 16)
    TTitle.Position = UDim2.new(0, 8, 0, 4)
    TTitle.BackgroundTransparency = 1
    TTitle.Text = title
    TTitle.TextColor3 = Config.UI.ThemeAccent
    TTitle.TextSize = 11
    TTitle.Font = Enum.Font.Code
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    TTitle.Parent = Toast

    local TMsg = Instance.new("TextLabel")
    TMsg.Size = UDim2.new(1, -10, 0, 16)
    TMsg.Position = UDim2.new(0, 8, 0, 20)
    TMsg.BackgroundTransparency = 1
    TMsg.Text = message
    TMsg.TextColor3 = Config.UI.Text
    TMsg.TextSize = 10
    TMsg.Font = Enum.Font.Code
    TMsg.TextXAlignment = Enum.TextXAlignment.Left
    TMsg.Parent = Toast

    TweenService:Create(Toast, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()

    task.delay(duration, function()
        local tw = TweenService:Create(Toast, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        tw:Play()
        tw.Completed:Connect(function() Toast:Destroy() end)
    end)
end

---------------------------------------------------------
-- MAIN GUI STRUCTURE
---------------------------------------------------------

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 370)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -185)
MainFrame.BackgroundColor3 = Config.UI.MainBg
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Config.UI.Border
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

---------------------------------------------------------
-- MODERN WATERMARK (FPS / PING / USER TOGGLE BUTTON)
---------------------------------------------------------

local Watermark = Instance.new("TextButton")
Watermark.Name = "WatermarkToggle"
Watermark.Position = UDim2.new(0, 15, 0, 12)
Watermark.Size = UDim2.new(0, 260, 0, 26)
Watermark.BackgroundColor3 = Config.UI.MainBg
Watermark.BorderColor3 = Config.UI.ThemeAccent
Watermark.BorderSizePixel = 1
Watermark.Text = " bankroll.sosu | 60 fps | 30 ms"
Watermark.TextColor3 = Config.UI.Text
Watermark.TextSize = 11
Watermark.Font = Enum.Font.Code
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.Parent = ScreenGui

local WmCorner = Instance.new("UICorner")
WmCorner.CornerRadius = UDim.new(0, 4)
WmCorner.Parent = Watermark

local WmPadding = Instance.new("UIPadding")
WmPadding.PaddingLeft = UDim.new(0, 8)
WmPadding.Parent = Watermark

Watermark.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local frameCount = 0
local lastFpsUpdate = os.clock()

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastFpsUpdate >= 0.5 then
        local fps = math.floor(frameCount / (now - lastFpsUpdate))
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        Watermark.Text = string.format(" bankroll.sosu | %s | %d fps | %d ms", LocalPlayer.Name, fps, ping)
        frameCount = 0
        lastFpsUpdate = now
    end
end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 28)
TopBar.BackgroundColor3 = Config.UI.TopBarBg
TopBar.BorderSizePixel = 1
TopBar.BorderColor3 = Config.UI.Border
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 6)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "bankroll | mobile hvh edition"
TitleLabel.TextColor3 = Config.UI.ThemeAccent
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 24, 0, 20)
ToggleMenuBtn.Position = UDim2.new(1, -30, 0, 4)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleMenuBtn.BorderColor3 = Config.UI.Border
ToggleMenuBtn.Text = "-"
ToggleMenuBtn.TextColor3 = Config.UI.Text
ToggleMenuBtn.TextSize = 14
ToggleMenuBtn.Font = Enum.Font.Code
ToggleMenuBtn.Parent = TopBar

ToggleMenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 26)
TabBar.Position = UDim2.new(0, 0, 0, 28)
TabBar.BackgroundColor3 = Config.UI.TopBarBg
TabBar.BorderSizePixel = 1
TabBar.BorderColor3 = Config.UI.Border
TabBar.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -20, 1, -66)
ContentArea.Position = UDim2.new(0, 10, 0, 58)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Tab Frames Creation
local RageTab = Instance.new("Frame"); RageTab.Size = UDim2.new(1,0,1,0); RageTab.BackgroundTransparency = 1; RageTab.Visible = true; RageTab.Parent = ContentArea
local AATab   = Instance.new("Frame"); AATab.Size = UDim2.new(1,0,1,0); AATab.BackgroundTransparency = 1; AATab.Visible = false; AATab.Parent = ContentArea
local MoveTab = Instance.new("Frame"); MoveTab.Size = UDim2.new(1,0,1,0); MoveTab.BackgroundTransparency = 1; MoveTab.Visible = false; MoveTab.Parent = ContentArea
local VisTab  = Instance.new("Frame"); VisTab.Size = UDim2.new(1,0,1,0); VisTab.BackgroundTransparency = 1; VisTab.Visible = false; VisTab.Parent = ContentArea
local CfgTab  = Instance.new("Frame"); CfgTab.Size = UDim2.new(1,0,1,0); CfgTab.BackgroundTransparency = 1; CfgTab.Visible = false; CfgTab.Parent = ContentArea

---------------------------------------------------------
-- HELPER UI CREATORS (FIXED LAYOUT CONTAINER)
---------------------------------------------------------

local function CreateGroupBox(parent, title, pos, size)
    local Box = Instance.new("Frame")
    Box.Position = pos; Box.Size = size
    Box.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Box.BorderColor3 = Config.UI.Border; Box.BorderSizePixel = 1
    Box.Parent = parent

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = Box

    local Label = Instance.new("TextLabel")
    Label.Position = UDim2.new(0, 10, 0, -8); Label.BackgroundColor3 = Config.UI.MainBg
    Label.Text = " " .. title .. " "; Label.TextColor3 = Config.UI.TextDim; Label.TextSize = 10; Label.Font = Enum.Font.Code
    Label.AutomaticSize = Enum.AutomaticSize.X; Label.Size = UDim2.new(0, 0, 0, 14)
    Label.ZIndex = 2
    Label.Parent = Box

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "Content"
    ContentContainer.Size = UDim2.new(1, -16, 1, -16)
    ContentContainer.Position = UDim2.new(0, 8, 0, 10)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Box

    local Layout = Instance.new("UIListLayout"); Layout.Parent = ContentContainer; Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Padding = UDim.new(0, 5)
    return ContentContainer
end

local function CreateToggle(parent, text, defaultState, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 18); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.Text = ""; ToggleBtn.Parent = parent

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(0, 12, 0, 12); Box.Position = UDim2.new(0, 0, 0.5, -6)
    Box.BackgroundColor3 = defaultState and Config.UI.ThemeAccent or Color3.fromRGB(30, 30, 30)
    Box.BorderColor3 = Config.UI.Border; Box.BorderSizePixel = 1; Box.Parent = ToggleBtn

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 2)
    BoxCorner.Parent = Box

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -20, 1, 0); Text.Position = UDim2.new(0, 20, 0, 0); Text.BackgroundTransparency = 1
    Text.Text = text; Text.TextColor3 = Config.UI.Text; Text.TextSize = 11; Text.Font = Enum.Font.Code; Text.TextXAlignment = Enum.TextXAlignment.Left; Text.Parent = ToggleBtn

    local state = defaultState
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and Config.UI.ThemeAccent or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 26); Container.BackgroundTransparency = 1; Container.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 12); Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default); Label.TextColor3 = Config.UI.Text; Label.TextSize = 11; Label.Font = Enum.Font.Code; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 6); Track.Position = UDim2.new(0, 0, 0, 16)
    Track.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Track.BorderColor3 = Config.UI.Border; Track.BorderSizePixel = 1; Track.Parent = Container

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Config.UI.ThemeAccent; Fill.BorderSizePixel = 0; Fill.Parent = Track

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
    Label.Size = UDim2.new(0.45, 0, 1, 0); Label.BackgroundTransparency = 1; Label.Text = labelText; Label.TextColor3 = Config.UI.Text; Label.TextSize = 11; Label.Font = Enum.Font.Code; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = Container

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.55, 0, 1, 0); Button.Position = UDim2.new(0.45, 0, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Button.BorderColor3 = Config.UI.Border; Button.BorderSizePixel = 1; Button.Text = defaultOption; Button.TextColor3 = Config.UI.ThemeAccent; Button.TextSize = 11; Button.Font = Enum.Font.Code; Button.Parent = Container

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
    {Name = "ragebot", Frame = RageTab},
    {Name = "anti-aim", Frame = AATab},
    {Name = "movement", Frame = MoveTab},
    {Name = "visuals", Frame = VisTab},
    {Name = "settings", Frame = CfgTab}
}

for i, tab in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1/#tabs, 0, 1, 0); TabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
    TabButton.BackgroundTransparency = 1; TabButton.Text = tab.Name
    TabButton.TextColor3 = (i == 1) and Config.UI.Text or Config.UI.TextDim; TabButton.TextSize = 11; TabButton.Font = Enum.Font.Code; TabButton.Parent = TabBar

    TabButton.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do t.Frame.Visible = false end
        tab.Frame.Visible = true
        for _, btn in ipairs(TabBar:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Config.UI.TextDim end end
        TabButton.TextColor3 = Config.UI.Text
    end)
end

---------------------------------------------------------
-- TAB CONTENTS
---------------------------------------------------------

-- 1. Ragebot Tab
local RageMain = CreateGroupBox(RageTab, "ragebot main", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(RageMain, "enabled", Config.Ragebot.Enabled, function(v) Config.Ragebot.Enabled = v end)
CreateToggle(RageMain, "auto shoot", Config.Ragebot.AutoShoot, function(v) Config.Ragebot.AutoShoot = v end)
CreateToggle(RageMain, "silent aim", Config.Ragebot.SilentAim, function(v) Config.Ragebot.SilentAim = v end)
CreateToggle(RageMain, "show fov circle", Config.Ragebot.ShowFOVCircle, function(v) Config.Ragebot.ShowFOVCircle = v end)
CreateSlider(RageMain, "fov angle", 10, 360, Config.Ragebot.FOV, function(v) Config.Ragebot.FOV = v end)
CreateSlider(RageMain, "min damage", 1, 100, Config.Ragebot.MinDamage, function(v) Config.Ragebot.MinDamage = v end)

local RageTarget = CreateGroupBox(RageTab, "targeting", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSelector(RageTarget, "target sel", {"Distance", "Health", "FOV"}, Config.Ragebot.TargetSelection, function(v) Config.Ragebot.TargetSelection = v end)
CreateSelector(RageTarget, "hitbox", {"Head", "Chest", "Pelvis"}, Config.Ragebot.TargetPart, function(v) Config.Ragebot.TargetPart = v end)
CreateToggle(RageTarget, "multipoint", Config.Ragebot.Multipoint, function(v) Config.Ragebot.Multipoint = v end)
CreateToggle(RageTarget, "auto stop", Config.Ragebot.AutoStop, function(v) Config.Ragebot.AutoStop = v end)

-- 2. Anti-Aim Tab
local AAMain = CreateGroupBox(AATab, "anti-aim main", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(AAMain, "enabled", Config.AntiAim.Enabled, function(v) Config.AntiAim.Enabled = v end)
CreateSelector(AAMain, "style", {"spin", "jitter", "left-right"}, Config.AntiAim.Style, function(v) Config.AntiAim.Style = v end)
CreateSelector(AAMain, "base dir", {"backwards", "forward", "left", "right"}, Config.AntiAim.BaseDirection, function(v) Config.AntiAim.BaseDirection = v end)
CreateSelector(AAMain, "pitch", {"down", "up", "zero"}, Config.AntiAim.Pitch, function(v) Config.AntiAim.Pitch = v end)

local AASpeed = CreateGroupBox(AATab, "anti-aim settings", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSlider(AASpeed, "spin speed", 5, 60, Config.AntiAim.SpinSpeed, function(v) Config.AntiAim.SpinSpeed = v end)
CreateSlider(AASpeed, "jitter range", 10, 180, Config.AntiAim.JitterRange, function(v) Config.AntiAim.JitterRange = v end)
CreateToggle(AASpeed, "fake lag", Config.AntiAim.FakeLag, function(v) Config.AntiAim.FakeLag = v end)
CreateSlider(AASpeed, "lag ticks", 1, 14, Config.AntiAim.FakeLagLimit, function(v) Config.AntiAim.FakeLagLimit = v end)

-- 3. Movement Tab
local MoveMain = CreateGroupBox(MoveTab, "movement main", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSlider(MoveMain, "strafe speed", 16, 120, Config.Movement.StrafeSpeed, function(v) Config.Movement.StrafeSpeed = v end)
CreateToggle(MoveMain, "bunny hop", Config.Movement.BunnyHop, function(v) Config.Movement.BunnyHop = v end)
CreateToggle(MoveMain, "auto strafe", Config.Movement.AutoStrafe, function(v) Config.Movement.AutoStrafe = v end)

local MoveExploits = CreateGroupBox(MoveTab, "movement exploits", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(MoveExploits, "fly mode", Config.Movement.Fly, function(v) Config.Movement.Fly = v end)
CreateSlider(MoveExploits, "fly speed", 10, 150, Config.Movement.FlySpeed, function(v) Config.Movement.FlySpeed = v end)
CreateToggle(MoveExploits, "noclip", Config.Movement.NoClip, function(v) Config.Movement.NoClip = v end)
CreateToggle(MoveExploits, "anti-void", Config.Movement.AntiVoid, function(v) Config.Movement.AntiVoid = v end)
CreateToggle(MoveExploits, "3rd person", Config.Movement.ThirdPerson, function(v)
    Config.Movement.ThirdPerson = v
    if not v then
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 0.5
    else
        LocalPlayer.CameraMinZoomDistance = 10
        LocalPlayer.CameraMaxZoomDistance = 128
    end
end)

-- Forward decls for world effects
local updateSkybox, updateMask

-- 4. Visuals Tab
local VisIndicators = CreateGroupBox(VisTab, "esp & visuals", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(VisIndicators, "box esp", Config.Visuals.BoxESP, function(v) Config.Visuals.BoxESP = v end)
CreateToggle(VisIndicators, "health bar", Config.Visuals.HealthBar, function(v) Config.Visuals.HealthBar = v end)
CreateToggle(VisIndicators, "weapon name", Config.Visuals.WeaponText, function(v) Config.Visuals.WeaponText = v end)
CreateToggle(VisIndicators, "chams (highlight)", Config.Visuals.Chams, function(v)
    Config.Visuals.Chams = v
    if not v then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("BankrollChams") then
                plr.Character.BankrollChams:Destroy()
            end
        end
    end
end)

local VisWorld = CreateGroupBox(VisTab, "world & sound", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(VisWorld, "hit sound", Config.Visuals.HitSound, function(v) Config.Visuals.HitSound = v end)
CreateSelector(VisWorld, "sound type", {"SAMP bell", "Skeet", "Neverlose", "Стон тянки", "Click", "CS Headshot"}, Config.Visuals.HitSoundType, function(v) Config.Visuals.HitSoundType = v end)

CreateToggle(VisWorld, "custom skybox", Config.Visuals.CustomSkybox, function(v)
    Config.Visuals.CustomSkybox = v
    if updateSkybox then updateSkybox() end
end)
CreateSelector(VisWorld, "skybox type", {"Purple Nebula", "Space Stars", "Night City", "Cyber Red"}, Config.Visuals.SkyboxType, function(v)
    Config.Visuals.SkyboxType = v
    if Config.Visuals.CustomSkybox and updateSkybox then updateSkybox() end
end)

CreateToggle(VisWorld, "payday mask", Config.Visuals.CustomMask, function(v)
    Config.Visuals.CustomMask = v
    if updateMask then updateMask() end
end)
CreateSelector(VisWorld, "mask model", {"Payday Clown", "Dallas Payday", "Dallas USA", "Skull Payday", "Dallas Classic"}, Config.Visuals.MaskType, function(v)
    Config.Visuals.MaskType = v
    if Config.Visuals.CustomMask and updateMask then updateMask() end
end)

---------------------------------------------------------
-- REAL JSON CONFIG SYSTEM
---------------------------------------------------------

local CfgManager = CreateGroupBox(CfgTab, "config system", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, 0, 0, 22); SaveBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); SaveBtn.BorderColor3 = Config.UI.Border
SaveBtn.Text = "Save Config"; SaveBtn.TextColor3 = Config.UI.ThemeAccent; SaveBtn.TextSize = 11; SaveBtn.Font = Enum.Font.Code; SaveBtn.Parent = CfgManager

local LoadBtn = Instance.new("TextButton")
LoadBtn.Size = UDim2.new(1, 0, 0, 22); LoadBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); LoadBtn.BorderColor3 = Config.UI.Border
LoadBtn.Text = "Load Config"; LoadBtn.TextColor3 = Config.UI.ThemeAccent; LoadBtn.TextSize = 11; LoadBtn.Font = Enum.Font.Code; LoadBtn.Parent = CfgManager

local ExportBtn = Instance.new("TextButton")
ExportBtn.Size = UDim2.new(1, 0, 0, 22); ExportBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ExportBtn.BorderColor3 = Config.UI.Border
ExportBtn.Text = "Export to Clipboard"; ExportBtn.TextColor3 = Config.UI.Text; ExportBtn.TextSize = 11; ExportBtn.Font = Enum.Font.Code; ExportBtn.Parent = CfgManager

local function SaveConfigData()
    local serialized = {
        Ragebot = Config.Ragebot,
        AntiAim = Config.AntiAim,
        Movement = Config.Movement,
        Visuals = Config.Visuals
    }
    return HttpService:JSONEncode(serialized)
end

SaveBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if writefile then
            writefile("bankroll_config.json", SaveConfigData())
            Notify("Config System", "Saved to bankroll_config.json!", 2)
        end
    end)
end)

LoadBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if readfile and isfile and isfile("bankroll_config.json") then
            local data = HttpService:JSONDecode(readfile("bankroll_config.json"))
            if data then
                if data.Ragebot then for k,v in pairs(data.Ragebot) do Config.Ragebot[k] = v end end
                if data.AntiAim then for k,v in pairs(data.AntiAim) do Config.AntiAim[k] = v end end
                if data.Movement then for k,v in pairs(data.Movement) do Config.Movement[k] = v end end
                if data.Visuals then for k,v in pairs(data.Visuals) do Config.Visuals[k] = v end end
                Notify("Config System", "Loaded from bankroll_config.json!", 2)
            end
        end
    end)
end)

ExportBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard(SaveConfigData())
            Notify("Clipboard", "Config JSON copied to clipboard!", 2)
        end
    end)
end)

local CfgCommunity = CreateGroupBox(CfgTab, "theme & community", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSelector(CfgCommunity, "accent color", {"Purple", "Cyan", "Red", "Green"}, "Purple", function(selected)
    if selected == "Purple" then Config.UI.ThemeAccent = Color3.fromRGB(160, 30, 240)
    elseif selected == "Cyan" then Config.UI.ThemeAccent = Color3.fromRGB(0, 200, 255)
    elseif selected == "Red" then Config.UI.ThemeAccent = Color3.fromRGB(255, 50, 50)
    elseif selected == "Green" then Config.UI.ThemeAccent = Color3.fromRGB(0, 255, 120) end

    Watermark.BorderColor3 = Config.UI.ThemeAccent
    TitleLabel.TextColor3 = Config.UI.ThemeAccent
    Notify("Theme", "Accent color updated to " .. selected, 2)
end)

---------------------------------------------------------
-- MOBILE ON-SCREEN MANUAL & FLY CONTROLS
---------------------------------------------------------

local ManualContainer = Instance.new("Frame")
ManualContainer.Name = "ManualContainer"
ManualContainer.Size = UDim2.new(0, 200, 0, 50)
ManualContainer.Position = UDim2.new(0.5, -100, 0.85, 0)
ManualContainer.BackgroundTransparency = 1
ManualContainer.Parent = ScreenGui

local ManualLayout = Instance.new("UIListLayout")
ManualLayout.FillDirection = Enum.FillDirection.Horizontal
ManualLayout.Padding = UDim.new(0, 5)
ManualLayout.Parent = ManualContainer

local function CreateManualBtn(text, dir)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 35, 0, 35)
    btn.BackgroundColor3 = Config.UI.TopBarBg
    btn.BorderColor3 = Config.UI.Border
    btn.Text = text
    btn.TextColor3 = Config.UI.Text
    btn.TextSize = 12
    btn.Font = Enum.Font.Code
    btn.Parent = ManualContainer

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        if dir == "INV" then
            Config.AntiAim.InvertSide = not Config.AntiAim.InvertSide
            btn.BorderColor3 = Config.AntiAim.InvertSide and Color3.fromRGB(0, 255, 120) or Config.UI.Border
        elseif dir == "FLY_UP" then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = root.CFrame + Vector3.new(0, 5, 0) end
        else
            Config.AntiAim.ManualDir = dir
            Notify("Anti-Aim", "Manual Direction: " .. dir, 1.5)
        end
    end)
end

CreateManualBtn("<", "Left")
CreateManualBtn("v", "Back")
CreateManualBtn(">", "Right")
CreateManualBtn("INV", "INV")
CreateManualBtn("▲", "FLY_UP")

---------------------------------------------------------
-- COMBAT / RAGEBOT ENGINE
---------------------------------------------------------

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderColor3 = Config.UI.ThemeAccent
FOVCircle.BorderSizePixel = 1
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local function GetTargetPlayer()
    local bestTarget = nil
    local bestVal = math.huge
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local vp = Camera.ViewportSize
    local viewportCenter = Vector2.new(vp.X / 2, vp.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local targetPart = plr.Character:FindFirstChild(Config.Ragebot.TargetPart) or plr.Character:FindFirstChild("Head")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                    if mouseDist <= Config.Ragebot.FOV then
                        local metric = mouseDist
                        if Config.Ragebot.TargetSelection == "Distance" then
                            metric = (targetPart.Position - myRoot.Position).Magnitude
                        elseif Config.Ragebot.TargetSelection == "Health" then
                            metric = plr.Character.Humanoid.Health
                        end

                        if metric < bestVal then
                            bestVal = metric
                            bestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function FireWeapon()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

local lastRageTick = 0
local lastFovVal = -1

RunService.RenderStepped:Connect(function()
    -- Performance: only update FOV circle properties when state/value changes
    local showFov = Config.Ragebot.ShowFOVCircle
    if FOVCircle.Visible ~= showFov then
        FOVCircle.Visible = showFov
    end
    if showFov and lastFovVal ~= Config.Ragebot.FOV then
        lastFovVal = Config.Ragebot.FOV
        local diameter = lastFovVal * 2
        FOVCircle.Size = UDim2.new(0, diameter, 0, diameter)
    end

    if not Config.Ragebot.Enabled then return end

    local now = os.clock()
    if now - lastRageTick >= 0.05 then
        lastRageTick = now
        local target = GetTargetPlayer()
        if target then
            if not Config.Ragebot.SilentAim then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
            if Config.Ragebot.AutoShoot then
                FireWeapon()
            end
        end
    end
end)

---------------------------------------------------------
-- ANTI-AIM ENGINE
---------------------------------------------------------

local currentAngle = 0
local lagCount = 0

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if root and hum and hum.Health > 0 then
        if Config.AntiAim.Enabled then
            hum.AutoRotate = false

            if Config.AntiAim.FakeLag then
                lagCount = (lagCount + 1) % Config.AntiAim.FakeLagLimit
                if lagCount ~= 0 then
                    root.Anchored = true
                else
                    root.Anchored = false
                end
            else
                root.Anchored = false
            end

            local baseYaw = Config.AntiAim.InvertSide and 90 or -90
            if Config.AntiAim.BaseDirection == "forward" then baseYaw = 0
            elseif Config.AntiAim.BaseDirection == "left" then baseYaw = 90
            elseif Config.AntiAim.BaseDirection == "right" then baseYaw = -90
            elseif Config.AntiAim.BaseDirection == "backwards" then baseYaw = 180 end

            if Config.AntiAim.ManualDir == "Left" then baseYaw = 90
            elseif Config.AntiAim.ManualDir == "Right" then baseYaw = -90
            elseif Config.AntiAim.ManualDir == "Back" then baseYaw = 180 end

            local finalYaw = baseYaw
            if Config.AntiAim.Style == "spin" then
                currentAngle = (currentAngle + Config.AntiAim.SpinSpeed) % 360
                finalYaw = baseYaw + currentAngle
            elseif Config.AntiAim.Style == "jitter" then
                finalYaw = baseYaw + math.random(-Config.AntiAim.JitterRange, Config.AntiAim.JitterRange)
            end

            local pitchAngle = 0
            if Config.AntiAim.Pitch == "down" then pitchAngle = -89
            elseif Config.AntiAim.Pitch == "up" then pitchAngle = 89 end

            local camYaw = math.atan2(-Camera.CFrame.LookVector.X, -Camera.CFrame.LookVector.Z)
            root.CFrame = CFrame.new(root.Position)
                * CFrame.Angles(0, camYaw + math.rad(finalYaw), 0)
                * CFrame.Angles(math.rad(pitchAngle), 0, 0)
        else
            root.Anchored = false
            hum.AutoRotate = true
        end
    end
end)

---------------------------------------------------------
-- MOVEMENT & AUTO-STRAFE ENGINE
---------------------------------------------------------

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if char and hum and root then
        hum.WalkSpeed = Config.Movement.StrafeSpeed

        if Config.Movement.BunnyHop and hum.FloorMaterial == Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        if Config.Movement.AutoStrafe and hum.FloorMaterial == Enum.Material.Air then
            local moveVector = hum.MoveDirection
            if moveVector.Magnitude > 0 then
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(moveVector.X * 2), 0)
            end
        end

        if Config.Movement.NoClip then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        if Config.Movement.AntiVoid and root.Position.Y < -50 then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 100, root.AssemblyLinearVelocity.Z)
        end

        if Config.Movement.Fly then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

---------------------------------------------------------
-- VISUALS & ESP / CHAMS SYSTEM
---------------------------------------------------------

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "BankrollESP"
ESPFolder.Parent = ScreenGui

-- Performance: cache ESP elements by player to eliminate per-frame FindFirstChild lookups and string concat
local espCache = {}

local function CreatePlayerESP(plr)
    if plr == LocalPlayer then return end

    local Box = Instance.new("Frame")
    Box.Name = "Box_" .. plr.Name
    Box.BackgroundTransparency = 1
    Box.BorderColor3 = Config.UI.ThemeAccent
    Box.BorderSizePixel = 1
    Box.Visible = false
    Box.Parent = ESPFolder

    local HealthBar = Instance.new("Frame")
    HealthBar.Name = "Health"
    HealthBar.Size = UDim2.new(0, 3, 1, 0)
    HealthBar.Position = UDim2.new(0, -6, 0, 0)
    HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    HealthBar.BorderSizePixel = 0
    HealthBar.Parent = Box

    local WeaponLabel = Instance.new("TextLabel")
    WeaponLabel.Name = "Weapon"
    WeaponLabel.Size = UDim2.new(1, 0, 0, 12)
    WeaponLabel.Position = UDim2.new(0, 0, 1, 2)
    WeaponLabel.BackgroundTransparency = 1
    WeaponLabel.Text = ""
    WeaponLabel.TextColor3 = Config.UI.Text
    WeaponLabel.TextSize = 9
    WeaponLabel.Font = Enum.Font.Code
    WeaponLabel.Parent = Box

    espCache[plr] = {
        Box = Box,
        HealthBar = HealthBar,
        WeaponLabel = WeaponLabel
    }
end

local function RemovePlayerESP(plr)
    local espData = espCache[plr]
    if espData then
        if espData.Box then
            espData.Box:Destroy()
        end
        espCache[plr] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do CreatePlayerESP(p) end
Players.PlayerAdded:Connect(CreatePlayerESP)
Players.PlayerRemoving:Connect(RemovePlayerESP)

RunService.RenderStepped:Connect(function()
    for plr, espData in pairs(espCache) do
        local box = espData.Box
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if char and root and hum and hum.Health > 0 and Config.Visuals.BoxESP then
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local head = char:FindFirstChild("Head")
                local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or screenPos
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2

                box.Size = UDim2.new(0, width, 0, height)
                box.Position = UDim2.new(0, screenPos.X - width/2, 0, screenPos.Y - height/2)
                box.Visible = true

                local hpBar = espData.HealthBar
                if hpBar then
                    hpBar.Visible = Config.Visuals.HealthBar
                    hpBar.Size = UDim2.new(0, 3, math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0)
                end

                local wpn = espData.WeaponLabel
                if wpn then
                    wpn.Visible = Config.Visuals.WeaponText
                    local tool = char:FindFirstChildOfClass("Tool")
                    wpn.Text = tool and tool.Name or ""
                end
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

-- Chams correctly parented inside Character Model
local function ApplyChams(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function(char)
        if Config.Visuals.Chams then
            local hl = Instance.new("Highlight")
            hl.Name = "BankrollChams"
            hl.FillColor = Config.UI.ThemeAccent
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0.2
            hl.Parent = char
        end
    end)
    if plr.Character and Config.Visuals.Chams then
        if not plr.Character:FindFirstChild("BankrollChams") then
            local hl = Instance.new("Highlight")
            hl.Name = "BankrollChams"
            hl.FillColor = Config.UI.ThemeAccent
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0.2
            hl.Parent = plr.Character
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do ApplyChams(p) end
Players.PlayerAdded:Connect(ApplyChams)

---------------------------------------------------------
-- SKYBOX ENGINE & PAYDAY MASK
---------------------------------------------------------

local currentSky = nil
updateSkybox = function()
    if Config.Visuals.CustomSkybox then
        if not currentSky then
            currentSky = Instance.new("Sky")
            currentSky.Name = "BankrollSkybox"
            currentSky.Parent = Lighting
        end
        local assetId = SkyboxPresets[Config.Visuals.SkyboxType]
        if assetId then
            currentSky.SkyboxBk = assetId
            currentSky.SkyboxDn = assetId
            currentSky.SkyboxFt = assetId
            currentSky.SkyboxLf = assetId
            currentSky.SkyboxRt = assetId
            currentSky.SkyboxUp = assetId
        end
    else
        if currentSky then
            currentSky:Destroy()
            currentSky = nil
        end
    end
end

local currentMaskModel = nil
local function removeMask()
    if currentMaskModel then
        pcall(function() currentMaskModel:Destroy() end)
        currentMaskModel = nil
    end
end

updateMask = function()
    removeMask()

    if not Config.Visuals.CustomMask then return end

    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    local assetId = MaskPresets[Config.Visuals.MaskType]
    if not head or not assetId then return end

    task.spawn(function()
        local success, rawObjects = pcall(function()
            if getobjects then return getobjects("rbxassetid://" .. tostring(assetId)) end
            if game.GetObjects then return game:GetObjects("rbxassetid://" .. tostring(assetId)) end
        end)

        if success and rawObjects and #rawObjects > 0 and LocalPlayer.Character == char then
            local maskObj = rawObjects[1]
            if maskObj then
                maskObj.Name = "BankrollPaydayMask"
                local handle = maskObj:IsA("Accessory") and maskObj:FindFirstChild("Handle")
                    or maskObj:IsA("BasePart") and maskObj
                    or maskObj:FindFirstChildOfClass("BasePart")

                if handle then
                    handle.CanCollide = false
                    if maskObj:IsA("Accessory") then
                        maskObj.Parent = char
                    else
                        local weld = Instance.new("Weld")
                        weld.Part0 = head
                        weld.Part1 = handle
                        weld.C0 = CFrame.new(0, 0, -0.1)
                        weld.Parent = handle
                        maskObj.Parent = char
                    end
                    currentMaskModel = maskObj
                end
            end
        end
    end)
end

---------------------------------------------------------
-- HIT SOUND ENGINE
---------------------------------------------------------

local HitSound = Instance.new("Sound")
HitSound.Parent = Workspace

local function TrackPlayerCharacter(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    local lastHealth = hum.Health
    hum.HealthChanged:Connect(function(health)
        if Config.Visuals.HitSound and health < lastHealth then
            local soundId = HitSounds[Config.Visuals.HitSoundType]
            if soundId then
                HitSound.SoundId = soundId
                HitSound:Play()
            end
        end
        lastHealth = health
    end)
end

local function OnPlayerAdded(plr)
    if plr == LocalPlayer then return end
    if plr.Character then TrackPlayerCharacter(plr.Character) end
    plr.CharacterAdded:Connect(TrackPlayerCharacter)
end

for _, p in pairs(Players:GetPlayers()) do OnPlayerAdded(p) end
Players.PlayerAdded:Connect(OnPlayerAdded)

---------------------------------------------------------
-- DRAGGING LOGIC (TOUCH & MOUSE)
---------------------------------------------------------

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

Notify("bankroll.sosu", "HvH Suite fully loaded & optimized!", 4)
