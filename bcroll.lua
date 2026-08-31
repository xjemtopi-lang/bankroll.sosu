-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local InsertService = game:GetService("InsertService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Safe GUI Parent Setup for Mobile Exploits (Delta)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BankrollGui"
ScreenGui.ResetOnSpawn = false

local successParent = pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
end)

if not successParent or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Preset Skyboxes
local SkyboxPresets = {
    ["Purple Nebula"] = "rbxassetid://159454299",
    ["Space Stars"]   = "rbxassetid://266205510",
    ["Night City"]    = "rbxassetid://12064107",
    ["Cyber Red"]     = "rbxassetid://252765781"
}

-- Payday Masks Catalog
local MaskPresets = {
    ["Payday Clown"] = 142491170,
    ["Dallas Payday"] = 142491152,
    ["Dallas USA"]   = 143187121,
    ["Skull Payday"]  = 142491136,
    ["Dallas Classic"] = 143187140
}

-- Hit Sounds List
local HitSounds = {
    ["SAMP bell"] = "rbxassetid://13510737",
    ["Skeet"] = "rbxassetid://566585149",
    ["Neverlose"] = "rbxassetid://656667534",
    ["Стон тянки"] = "rbxassetid://1676645367",
    ["Click"] = "rbxassetid://12221967",
    ["CS Headshot"] = "rbxassetid://143242095"
}

-- Style Config
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
local RagebotSettings = {
    AutoShoot = true,
    AutoWall = true,
    MinDamage = 25,
    AutoStop = true,
    TargetPart = "Head",
    Multipoint = true
}

local AntiAimSettings = {
    Enabled = true,
    Style = "spin",
    BaseDirection = "backwards",
    Pitch = "down",
    FakeLag = true,
    FakeLagLimit = 8,
    Freestanding = true,
    FakeDuck = false,
    InvertSide = false
}

local RageSettings = {
    StrafeSpeed = 32,
    BunnyHop = true,
    ThirdPerson = false,
    NoClip = false,
    Invisible = false,
    PixelSurf = false,
    InfiniteJump = false,
    AntiVoid = true
}

local VisualsSettings = {
    Box = true,
    Skeleton = true,
    Nickname = true,
    BulletTracers = true,
    Hitmarkers = true,
    AAIndicators = true,
    HitSound = true,
    HitSoundType = "SAMP bell",
    CustomSkybox = false,
    SkyboxType = "Purple Nebula",
    CustomMask = false,
    MaskType = "Payday Clown"
}

local MenuSettings = {
    SelectedFont = "Code",
    TGLink = "https://t.me/bankrollc"
}

-- Main Frame Setup
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = DarkTheme.MainBg
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = DarkTheme.Border
MainFrame.Active = true
MainFrame.Visible = true -- Открываем сразу!
MainFrame.Parent = ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 25)
TopBar.BackgroundColor3 = DarkTheme.TopBarBg
TopBar.BorderSizePixel = 1
TopBar.BorderColor3 = DarkTheme.Border
TopBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "bankroll | mobile hvh edition"
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
    Label.Text = " " .. title .. " "; Label.TextColor3 = DarkTheme.TextDim; Label.TextSize = 11; Label.Font = DarkTheme.Font; Label.SizeToTextBounds = true
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

-- Fill Ragebot Tab
local MainRage = CreateGroupBox(RagebotTab, "ragebot main", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(MainRage, "auto shoot", RagebotSettings.AutoShoot, function(v) RagebotSettings.AutoShoot = v end)
CreateToggle(MainRage, "auto wall", RagebotSettings.AutoWall, function(v) RagebotSettings.AutoWall = v end)
CreateToggle(MainRage, "auto stop", RagebotSettings.AutoStop, function(v) RagebotSettings.AutoStop = v end)
CreateSlider(MainRage, "min damage", 1, 100, RagebotSettings.MinDamage, function(v) RagebotSettings.MinDamage = v end)

local TargetRage = CreateGroupBox(RagebotTab, "target settings", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
local hitboxes = {"Head", "Chest", "Pelvis"}
CreateSelector(TargetRage, "hitbox", hitboxes, RagebotSettings.TargetPart, function(v) RagebotSettings.TargetPart = v end)
CreateToggle(TargetRage, "multipoint", RagebotSettings.Multipoint, function(v) RagebotSettings.Multipoint = v end)

-- Fill Anti-Aim Tab
local AAMain = CreateGroupBox(AntiAimTab, "anti-aim", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(AAMain, "enabled", AntiAimSettings.Enabled, function(v) AntiAimSettings.Enabled = v end)
CreateSelector(AAMain, "style", {"spin", "left-right", "jitter"}, AntiAimSettings.Style, function(v) AntiAimSettings.Style = v end)
CreateSelector(AAMain, "base dir", {"backwards", "forward", "left", "right"}, AntiAimSettings.BaseDirection, function(v) AntiAimSettings.BaseDirection = v end)
CreateSelector(AAMain, "pitch", {"down", "up", "zero"}, AntiAimSettings.Pitch, function(v) AntiAimSettings.Pitch = v end)

local AADesync = CreateGroupBox(AntiAimTab, "desync & fakelag", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(AADesync, "freestanding", AntiAimSettings.Freestanding, function(v) AntiAimSettings.Freestanding = v end)
CreateToggle(AADesync, "fake lag", AntiAimSettings.FakeLag, function(v) AntiAimSettings.FakeLag = v end)
CreateSlider(AADesync, "lag ticks", 1, 14, AntiAimSettings.FakeLagLimit, function(v) AntiAimSettings.FakeLagLimit = v end)
CreateToggle(AADesync, "fake duck", AntiAimSettings.FakeDuck, function(v) AntiAimSettings.FakeDuck = v end)

-- Fill Movement Tab
local MoveBox = CreateGroupBox(MovementTab, "movement", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSlider(MoveBox, "strafe speed", 16, 120, RageSettings.StrafeSpeed, function(v) RageSettings.StrafeSpeed = v end)
CreateToggle(MoveBox, "bunny hop", RageSettings.BunnyHop, function(v) RageSettings.BunnyHop = v end)
CreateToggle(MoveBox, "pixel surf", RageSettings.PixelSurf, function(v) RageSettings.PixelSurf = v end)
CreateToggle(MoveBox, "infinite jump", RageSettings.InfiniteJump, function(v) RageSettings.InfiniteJump = v end)

local ExploitBox = CreateGroupBox(MovementTab, "exploits", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(ExploitBox, "3rd person", RageSettings.ThirdPerson, function(v)
    RageSettings.ThirdPerson = v
    if not v then LocalPlayer.CameraMaxZoomDistance = 0.5 else LocalPlayer.CameraMaxZoomDistance = 128; LocalPlayer.CameraMinZoomDistance = 10 end
end)
CreateToggle(ExploitBox, "noclip", RageSettings.NoClip, function(v) RageSettings.NoClip = v end)
CreateToggle(ExploitBox, "anti-void", RageSettings.AntiVoid, function(v) RageSettings.AntiVoid = v end)

-- Forward declaration
local updateSkybox, updateMask

-- Fill Visuals Tab
local VisBox = CreateGroupBox(VisualsTab, "hvh indicators", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(VisBox, "box esp", VisualsSettings.Box, function(v) VisualsSettings.Box = v end)
CreateToggle(VisBox, "aa indicators", VisualsSettings.AAIndicators, function(v) VisualsSettings.AAIndicators = v end)
CreateToggle(VisBox, "bullet tracers", VisualsSettings.BulletTracers, function(v) VisualsSettings.BulletTracers = v end)
CreateToggle(VisBox, "hit sound", VisualsSettings.HitSound, function(v) VisualsSettings.HitSound = v end)
CreateSelector(VisBox, "sound", {"SAMP bell", "Skeet", "Neverlose", "Стон тянки", "Click", "CS Headshot"}, VisualsSettings.HitSoundType, function(v) VisualsSettings.HitSoundType = v end)

local WorldBox = CreateGroupBox(VisualsTab, "world & player", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateToggle(WorldBox, "custom skybox", VisualsSettings.CustomSkybox, function(v) 
    VisualsSettings.CustomSkybox = v 
    if updateSkybox then updateSkybox() end
end)
CreateSelector(WorldBox, "skybox type", {"Purple Nebula", "Space Stars", "Night City", "Cyber Red"}, VisualsSettings.SkyboxType, function(v)
    VisualsSettings.SkyboxType = v
    if VisualsSettings.CustomSkybox and updateSkybox then updateSkybox() end
end)

CreateToggle(WorldBox, "payday mask", VisualsSettings.CustomMask, function(v)
    VisualsSettings.CustomMask = v
    if updateMask then updateMask() end
end)
CreateSelector(WorldBox, "mask model", {"Payday Clown", "Dallas Payday", "Dallas USA", "Skull Payday", "Dallas Classic"}, VisualsSettings.MaskType, function(v)
    VisualsSettings.MaskType = v
    if VisualsSettings.CustomMask and updateMask then updateMask() end
end)

-- Fill Settings Tab
local UIConfigBox = CreateGroupBox(SettingsTab, "ui settings", UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))
CreateSelector(UIConfigBox, "font", {"Code", "SourceSansBold", "GothamBold", "Arcade"}, MenuSettings.SelectedFont, function(selected)
    MenuSettings.SelectedFont = selected
    local fontEnum = Enum.Font[selected] or Enum.Font.Code
    for _, obj in ipairs(ScreenGui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.Font = fontEnum
        end
    end
end)

CreateSelector(UIConfigBox, "menu size", {"Medium", "Small", "Large"}, "Medium", function(size)
    if size == "Small" then
        MainFrame.Size = UDim2.new(0, 420, 0, 290)
    elseif size == "Medium" then
        MainFrame.Size = UDim2.new(0, 520, 0, 360)
    elseif size == "Large" then
        MainFrame.Size = UDim2.new(0, 620, 0, 430)
    end
end)

local CommunityBox = CreateGroupBox(SettingsTab, "community", UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0))

local TGLabel = Instance.new("TextLabel")
TGLabel.Size = UDim2.new(1, 0, 0, 18)
TGLabel.BackgroundTransparency = 1
TGLabel.Text = "Telegram: @bankrollc"
TGLabel.TextColor3 = DarkTheme.Text
TGLabel.TextSize = 11
TGLabel.Font = DarkTheme.Font
TGLabel.TextXAlignment = Enum.TextXAlignment.Left
TGLabel.Parent = CommunityBox

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, 0, 0, 22)
CopyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CopyBtn.BorderColor3 = DarkTheme.Border
CopyBtn.BorderSizePixel = 1
CopyBtn.Text = "Copy TG Link"
CopyBtn.TextColor3 = DarkTheme.Accent
CopyBtn.TextSize = 11
CopyBtn.Font = DarkTheme.Font
CopyBtn.Parent = CommunityBox

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(MenuSettings.TGLink)
        CopyBtn.Text = "Copied!"
        task.wait(1.5)
        CopyBtn.Text = "Copy TG Link"
    end
end)

---------------------------------------------------------
-- SAFE PAYDAY MASK ENGINE
---------------------------------------------------------

local currentMaskModel = nil

local function removeMask()
    if currentMaskModel then
        currentMaskModel:Destroy()
        currentMaskModel = nil
    end
end

updateMask = function()
    removeMask()

    if not VisualsSettings.CustomMask then return end

    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    local assetId = MaskPresets[VisualsSettings.MaskType]
    if not assetId then return end

    task.spawn(function()
        local success, maskObj = pcall(function()
            if InsertService then
                return InsertService:LoadAsset(assetId)
            end
        end)

        if success and maskObj and LocalPlayer.Character == char then
            maskObj.Name = "BankrollPaydayMask"
            local realItem = maskObj:FindFirstChildOfClass("Accessory") or maskObj:FindFirstChildOfClass("Model") or maskObj
            
            local handle = realItem:FindFirstChild("Handle") or realItem:FindFirstChildOfClass("BasePart")
            if handle then
                handle.CanCollide = false
                if realItem:IsA("Accessory") then
                    realItem.Parent = char
                else
                    local weld = Instance.new("Weld")
                    weld.Part0 = head
                    weld.Part1 = handle
                    weld.C0 = CFrame.new(0, 0, -0.1)
                    weld.Parent = handle
                    realItem.Parent = char
                end
                currentMaskModel = realItem
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if VisualsSettings.CustomMask then updateMask() end
end)

---------------------------------------------------------
-- SKYBOX ENGINE
---------------------------------------------------------

local currentSky = nil

updateSkybox = function()
    if VisualsSettings.CustomSkybox then
        if not currentSky then
            currentSky = Instance.new("Sky")
            currentSky.Parent = Lighting
        end
        local assetId = SkyboxPresets[VisualsSettings.SkyboxType]
        currentSky.SkyboxBk = assetId
        currentSky.SkyboxDn = assetId
        currentSky.SkyboxFt = assetId
        currentSky.SkyboxLf = assetId
        currentSky.SkyboxRt = assetId
        currentSky.SkyboxUp = assetId
    else
        if currentSky then
            currentSky:Destroy()
            currentSky = nil
        end
    end
end

---------------------------------------------------------
-- WATERMARK & TOGGLE BUTTON LOGIC
---------------------------------------------------------

local Watermark = Instance.new("TextButton")
Watermark.Name = "WatermarkToggle"
Watermark.Position = UDim2.new(0, 15, 0, 15)
Watermark.Size = UDim2.new(0, 170, 0, 22)
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

Watermark.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

---------------------------------------------------------
-- HIT SOUND ENGINE
---------------------------------------------------------
local HitSound = Instance.new("Sound")
HitSound.Parent = Workspace

local function OnPlayerAdded(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        local lastHealth = hum.Health
        hum.HealthChanged:Connect(function(health)
            if VisualsSettings.HitSound and health < lastHealth then 
                HitSound.SoundId = HitSounds[VisualsSettings.HitSoundType] or ""
                HitSound:Play() 
            end
            lastHealth = health
        end)
    end)
end

for _, p in pairs(Players:GetPlayers()) do OnPlayerAdded(p) end
Players.PlayerAdded:Connect(OnPlayerAdded)

---------------------------------------------------------
-- MOBILE ON-SCREEN INVERTER BUTTON (HUD)
---------------------------------------------------------

local MobileInverterBtn = Instance.new("TextButton")
MobileInverterBtn.Name = "InverterButton"
MobileInverterBtn.Size = UDim2.new(0, 50, 0, 50)
MobileInverterBtn.Position = UDim2.new(0.85, 0, 0.4, 0)
MobileInverterBtn.BackgroundColor3 = DarkTheme.TopBarBg
MobileInverterBtn.BorderColor3 = DarkTheme.Accent
MobileInverterBtn.BorderSizePixel = 2
MobileInverterBtn.Text = "INV"
MobileInverterBtn.TextColor3 = DarkTheme.Text
MobileInverterBtn.TextSize = 14
MobileInverterBtn.Font = DarkTheme.Font
MobileInverterBtn.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(1, 0)
BtnCorner.Parent = MobileInverterBtn

MobileInverterBtn.MouseButton1Click:Connect(function()
    AntiAimSettings.InvertSide = not AntiAimSettings.InvertSide
    MobileInverterBtn.BorderColor3 = AntiAimSettings.InvertSide and Color3.fromRGB(0, 255, 120) or DarkTheme.Accent
end)

---------------------------------------------------------
-- ANTI-AIM LOGIC
---------------------------------------------------------

local currentAngle = 0

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if AntiAimSettings.Enabled and root and hum and hum.Health > 0 then
        -- Guard property assignment to eliminate Luau-to-C++ bridge overhead on every frame
        if hum.AutoRotate ~= false then hum.AutoRotate = false end

        local baseYaw = AntiAimSettings.InvertSide and 90 or -90
        if AntiAimSettings.BaseDirection == "backwards" then baseYaw = baseYaw + 180 end

        local finalYaw = baseYaw
        if AntiAimSettings.Style == "spin" then
            currentAngle = (currentAngle + 20) % 360
            finalYaw = baseYaw + currentAngle
        elseif AntiAimSettings.Style == "jitter" then
            finalYaw = baseYaw + math.random(-45, 45)
        end

        local pitchAngle = 0
        if AntiAimSettings.Pitch == "down" then pitchAngle = -89
        elseif AntiAimSettings.Pitch == "up" then pitchAngle = 89 end

        local camYaw = math.atan2(-Camera.CFrame.LookVector.X, -Camera.CFrame.LookVector.Z)
        root.CFrame = CFrame.new(root.Position) 
            * CFrame.Angles(0, camYaw + math.rad(finalYaw), 0)
            * CFrame.Angles(math.rad(pitchAngle), 0, 0)
    end
end)

---------------------------------------------------------
-- MOVEMENT ENGINE
---------------------------------------------------------

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if char and hum and root then
        hum.WalkSpeed = RageSettings.StrafeSpeed

        if RageSettings.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        if RageSettings.NoClip then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end

        if RageSettings.AntiVoid and root.Position.Y < -50 then
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 100, root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- Dragging Frame (Touch Compatible)
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
