--[[
    BANKROLL.SOSU v2.0 | Mobile-Optimized HvH Suite
    ► Lazy-init системы (грузятся по требованию)
    ► Throttled loops (ESP/Chams не каждый кадр)
    ► Object pooling для Drawing
    ► Batch-обновления через таблицы
    ► Шейдеры чамсов (6 режимов)
    ► Полные визуалы мира/персонажа/оружия
    ► Настраиваемые ESP-параметры
--]]

----------------------------------------------------------------
-- FAST SERVICES (локальные ссылки = быстрее чем GetService в цикле)
----------------------------------------------------------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local Debris           = game:GetService("Debris")
local Camera           = Workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

----------------------------------------------------------------
-- LAZY GUI PARENT
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BR_" .. math.random(1000,9999)
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = gethui and gethui() or CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
end

----------------------------------------------------------------
-- PRESETS
----------------------------------------------------------------
local SkyboxPresets = {
    ["Purple Nebula"] = "rbxassetid://159454299",
    ["Space Stars"]   = "rbxassetid://266205510",
    ["Night City"]    = "rbxassetid://12064107",
    ["Cyber Red"]     = "rbxassetid://252765781",
    ["Void Black"]    = "rbxassetid://151022257",
}

local MaskPresets = {
    ["Payday Clown"]  = 142491170,
    ["Dallas"]        = 142491152,
    ["Skull"]         = 142491136,
}

local HitSounds = {
    ["SAMP bell"]   = "rbxassetid://13510737",
    ["Skeet"]       = "rbxassetid://566585149",
    ["Neverlose"]   = "rbxassetid://656667534",
    ["CS Headshot"] = "rbxassetid://143242095",
    ["Click"]       = "rbxassetid://12221967",
}

-- Цвета режимов чамсов
local ChamShaders = {
    ["Flat"]      = {fill=Color3.fromRGB(140,30,220),  outline=Color3.fromRGB(255,255,255), fillT=0.5, outT=0.0},
    ["Glow"]      = {fill=Color3.fromRGB(0,200,255),   outline=Color3.fromRGB(0,200,255),   fillT=0.3, outT=0.0},
    ["Wireframe"] = {fill=Color3.fromRGB(0,0,0),       outline=Color3.fromRGB(255,80,80),   fillT=1.0, outT=0.0},
    ["Ghost"]     = {fill=Color3.fromRGB(200,200,255), outline=Color3.fromRGB(255,255,255), fillT=0.85,outT=0.5},
    ["Rainbow"]   = {fill=Color3.fromRGB(255,0,0),     outline=Color3.fromRGB(255,255,0),   fillT=0.4, outT=0.0},
    ["Solid"]     = {fill=Color3.fromRGB(255,30,30),   outline=Color3.fromRGB(0,0,0),       fillT=0.0, outT=0.0},
}

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local Config = {
    Ragebot = {
        Enabled         = true,
        SilentAim       = true,
        TargetSelection = "FOV",   -- Distance / Health / FOV
        TargetPart      = "Head",
        FOV             = 160,
        ShowFOV         = true,
        AutoStop        = true,
        Multipoint      = true,
    },
    AntiAim = {
        Enabled     = true,
        Style       = "spin",      -- spin / jitter / left-right / static
        SpinSpeed   = 18,
        JitterRange = 40,
        Pitch       = "down",      -- down / up / none
        FakeLag     = true,
        FakeLagLimit= 8,
    },
    Movement = {
        BunnyHop    = true,
        AutoStrafe  = true,
        Fly         = false,
        FlySpeed    = 50,
        AntiVoid    = true,
        SpeedHack   = false,
        SpeedValue  = 28,
    },
    Visuals = {
        -- ESP персонажа
        BoxESP          = true,
        BoxStyle        = "Corner",  -- Full / Corner
        BoxColor        = Color3.fromRGB(140,30,220),
        HealthBar       = true,
        HealthBarSide   = "Left",    -- Left / Right / Bottom
        NameESP         = true,
        NameColor       = Color3.fromRGB(220,220,220),
        DistanceESP     = true,
        WeaponESP       = true,
        SkeletonESP     = false,
        TracerESP       = false,
        TracerOrigin    = "Bottom",  -- Bottom / Center / Top
        HeadDot         = true,
        -- Чамсы
        Chams           = true,
        ChamShader      = "Glow",
        ChamEnemy       = true,
        ChamTeammate    = false,
        -- Мир
        NoFog           = true,
        Fullbright      = false,
        CustomSkybox    = false,
        SkyboxType      = "Purple Nebula",
        -- Оружие
        WeaponChams     = false,
        WeaponColor     = Color3.fromRGB(255,200,0),
        DroppedESP      = true,
        -- Хит-звук
        HitSound        = true,
        HitSoundType    = "SAMP bell",
        -- Маска
        CustomMask      = false,
        MaskType        = "Payday Clown",
    },
    UI = {
        Accent  = Color3.fromRGB(140,30,220),
        MainBg  = Color3.fromRGB(13,13,13),
        Panel   = Color3.fromRGB(20,20,20),
        Border  = Color3.fromRGB(38,38,38),
        Text    = Color3.fromRGB(220,220,220),
        Dim     = Color3.fromRGB(140,140,140),
    },
}

----------------------------------------------------------------
-- THROTTLE СИСТЕМА (оптимизация для телефона)
-- Разные системы обновляются с разной частотой
----------------------------------------------------------------
local Throttle = {
    ESP      = {interval = 0.04,  last = 0},  -- 25fps достаточно для ESP
    Chams    = {interval = 0.1,   last = 0},  -- Чамсы — 10fps
    World    = {interval = 0.5,   last = 0},  -- Мир — 2fps
    Rainbow  = {interval = 0.05,  last = 0},  -- Радуга чамсов
    Weapon   = {interval = 0.15,  last = 0},  -- Weapon ESP
}

local function ShouldRun(key)
    local t = Throttle[key]
    local now = tick()
    if now - t.last >= t.interval then
        t.last = now
        return true
    end
    return false
end

----------------------------------------------------------------
-- UTILS (inline для скорости)
----------------------------------------------------------------
local function GetChar(p)   return p and p.Character end
local function GetRoot(p)   local c=GetChar(p) return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum(p)    local c=GetChar(p) return c and c:FindFirstChildOfClass("Humanoid") end
local function IsAlive(p)   local h=GetHum(p)  return h and h.Health > 0 end

local function GetDist(p)
    local a,b = GetRoot(LocalPlayer), GetRoot(p)
    return a and b and (a.Position-b.Position).Magnitude or math.huge
end

local function GetFOVAngle(p)
    local r = GetRoot(p)
    if not r then return math.huge end
    local sp, vis = Camera:WorldToScreenPoint(r.Position)
    if not vis then return math.huge end
    local c = Camera.ViewportSize/2
    return (Vector2.new(sp.X,sp.Y)-c).Magnitude
end

local function W2S(pos)
    local sp, vis = Camera:WorldToScreenPoint(pos)
    return vis, Vector2.new(sp.X, sp.Y), sp.Z
end

----------------------------------------------------------------
-- OBJECT POOL для Drawing (не создаём новые объекты каждый кадр)
----------------------------------------------------------------
local DrawPool = {}
local function NewDraw(type_)
    if not Drawing then return nil end
    if DrawPool[type_] and #DrawPool[type_] > 0 then
        return table.remove(DrawPool[type_])
    end
    return Drawing.new(type_)
end
local function ReturnDraw(type_, obj)
    if not obj then return end
    obj.Visible = false
    DrawPool[type_] = DrawPool[type_] or {}
    table.insert(DrawPool[type_], obj)
end

----------------------------------------------------------------
-- TARGET SELECTION
----------------------------------------------------------------
local function GetTarget()
    local best, bestVal = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer or not IsAlive(p) then continue end
        local val
        if     Config.Ragebot.TargetSelection == "Distance" then val = GetDist(p)
        elseif Config.Ragebot.TargetSelection == "Health"   then local h=GetHum(p) val = h and h.Health or math.huge
        elseif Config.Ragebot.TargetSelection == "FOV"      then val = GetFOVAngle(p) end
        if val and val < bestVal then bestVal=val best=p end
    end
    return best
end

local function GetTargetPart(p)
    local c = GetChar(p)
    return c and (c:FindFirstChild(Config.Ragebot.TargetPart) or c:FindFirstChild("HumanoidRootPart"))
end

----------------------------------------------------------------
-- HIT SOUND (pooled)
----------------------------------------------------------------
local SoundPool = {}
local function PlayHitSound()
    if not Config.Visuals.HitSound then return end
    local id = HitSounds[Config.Visuals.HitSoundType]
    if not id then return end
    local s = table.remove(SoundPool) or Instance.new("Sound")
    s.SoundId = id
    s.Volume  = 1
    s.Parent  = Workspace
    s:Play()
    task.delay(3, function()
        s.Parent = nil
        table.insert(SoundPool, s)
    end)
end

----------------------------------------------------------------
-- SILENT AIM
----------------------------------------------------------------
local function SilentAim(target)
    local part = GetTargetPart(target)
    if not part then return end
    local prev = Camera.CameraType
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
    task.defer(function() Camera.CameraType = prev end)
end

-- FOV Circle (создаём один раз)
local FOVCircle = Drawing and Drawing.new("Circle") or nil
if FOVCircle then
    FOVCircle.Visible   = false
    FOVCircle.Thickness = 1.5
    FOVCircle.Color     = Config.UI.Accent
    FOVCircle.Filled    = false
    FOVCircle.NumSides  = 48
end

local function UpdateFOV()
    if not FOVCircle then return end
    FOVCircle.Visible  = Config.Ragebot.ShowFOV and Config.Ragebot.Enabled
    FOVCircle.Position = Camera.ViewportSize/2
    FOVCircle.Radius   = Config.Ragebot.FOV
    FOVCircle.Color    = Config.UI.Accent
end

----------------------------------------------------------------
-- ANTI-AIM
----------------------------------------------------------------
local AAYaw = 0
local JFlip = 1

local function ApplyAntiAim()
    if not Config.AntiAim.Enabled then return end
    local c = GetChar(LocalPlayer)
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local style = Config.AntiAim.Style
    if style == "spin" then
        AAYaw = (AAYaw + Config.AntiAim.SpinSpeed) % 360
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(AAYaw), 0)
    elseif style == "jitter" then
        JFlip = -JFlip
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(Config.AntiAim.JitterRange * JFlip), 0)
    elseif style == "left-right" then
        JFlip = -JFlip
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(JFlip > 0 and 90 or -90), 0)
    end

    if Config.AntiAim.Pitch ~= "none" then
        local neck = c:FindFirstChild("Neck", true)
        if neck and neck:IsA("Motor6D") then
            local angle = Config.AntiAim.Pitch == "down" and 89 or -89
            neck.C0 = neck.C0 * CFrame.Angles(math.rad(angle), 0, 0)
        end
    end
end

----------------------------------------------------------------
-- FAKE LAG
----------------------------------------------------------------
local FLFrame = 0
local FLActive = false
local function HandleFakeLag()
    if not Config.AntiAim.FakeLag then FLActive=false return end
    FLFrame = FLFrame + 1
    if FLFrame >= Config.AntiAim.FakeLagLimit then
        FLFrame = 0
        FLActive = false
    else
        FLActive = true
    end
end

----------------------------------------------------------------
-- MOVEMENT
----------------------------------------------------------------
local FlyBV = nil

local function EnableFly()
    local c = GetChar(LocalPlayer) if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart") if not root then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Velocity  = Vector3.zero
    FlyBV.MaxForce  = Vector3.new(1e5,1e5,1e5)
    FlyBV.Parent    = root
end

local function DisableFly()
    if FlyBV then FlyBV:Destroy() FlyBV=nil end
    local c = GetChar(LocalPlayer)
    if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.PlatformStand=false end end
end

local function HandleFly()
    if not Config.Movement.Fly then if FlyBV then DisableFly() end return end
    if not FlyBV then EnableFly() end
    if not FlyBV then return end
    local dir = Vector3.zero
    local cf  = Camera.CFrame
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.yAxis end
    FlyBV.Velocity = dir.Magnitude>0 and dir.Unit*Config.Movement.FlySpeed or Vector3.zero
end

local function HandleBHop()
    if not Config.Movement.BunnyHop then return end
    local c = GetChar(LocalPlayer) if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid") if not hum then return end
    local root = c:FindFirstChild("HumanoidRootPart") if not root then return end
    if hum.FloorMaterial ~= Enum.Material.Air then
        local v = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(v.X, hum.JumpPower or 50, v.Z)
    end
end

local function HandleStrafe()
    if not Config.Movement.AutoStrafe then return end
    local c = GetChar(LocalPlayer) if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid") if not hum then return end
    local root = c:FindFirstChild("HumanoidRootPart") if not root then return end
    if hum.FloorMaterial == Enum.Material.Air then
        local v = root.AssemblyLinearVelocity
        local spd = Config.Movement.StrafeSpeed
        if v.X > 0 then root.AssemblyLinearVelocity = Vector3.new(spd, v.Y, v.Z)
        elseif v.X < 0 then root.AssemblyLinearVelocity = Vector3.new(-spd, v.Y, v.Z) end
    end
end

local function HandleAntiVoid()
    if not Config.Movement.AntiVoid then return end
    local root = GetRoot(LocalPlayer)
    if root and root.Position.Y < -150 then
        root.CFrame = CFrame.new(0,10,0)
    end
end

local function HandleSpeed()
    if not Config.Movement.SpeedHack then return end
    local c = GetChar(LocalPlayer) if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Config.Movement.SpeedValue end
end

----------------------------------------------------------------
-- CHAMS (Highlight, шейдеры)
----------------------------------------------------------------
local ChamObjects = {}   -- [player] = Highlight instance
local RainbowHue  = 0

local function GetChamShader()
    return ChamShaders[Config.Visuals.ChamShader] or ChamShaders["Flat"]
end

local function ApplyChams(player)
    if not Config.Visuals.Chams then return end
    local c = GetChar(player) if not c then return end
    if ChamObjects[player] and ChamObjects[player].Parent then return end

    local sh = GetChamShader()
    local hl = Instance.new("Highlight")
    hl.Adornee           = c
    hl.FillColor         = sh.fill
    hl.OutlineColor      = sh.outline
    hl.FillTransparency  = sh.fillT
    hl.OutlineTransparency = sh.outT
    hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent            = c
    ChamObjects[player]  = hl
end

local function RemoveChams(player)
    if ChamObjects[player] then
        ChamObjects[player]:Destroy()
        ChamObjects[player] = nil
    end
end

-- Обновление цветов чамсов (Rainbow анимация)
local function UpdateChamsColor()
    if not Config.Visuals.Chams then return end
    local sh = GetChamShader()
    RainbowHue = (RainbowHue + 2) % 360

    for player, hl in pairs(ChamObjects) do
        if not hl or not hl.Parent then
            ChamObjects[player] = nil
            continue
        end
        if Config.Visuals.ChamShader == "Rainbow" then
            hl.FillColor    = Color3.fromHSV(RainbowHue/360, 1, 1)
            hl.OutlineColor = Color3.fromHSV(((RainbowHue+120)%360)/360, 1, 1)
        else
            hl.FillColor         = sh.fill
            hl.OutlineColor      = sh.outline
            hl.FillTransparency  = sh.fillT
            hl.OutlineTransparency = sh.outT
        end
    end
end

----------------------------------------------------------------
-- WEAPON CHAMS (оружие в руках)
----------------------------------------------------------------
local WeaponChamsApplied = {}

local function ApplyWeaponChams(player)
    if not Config.Visuals.WeaponChams then return end
    if WeaponChamsApplied[player] then return end
    local c = GetChar(player) if not c then return end

    for _, obj in ipairs(c:GetDescendants()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            if not WeaponChamsApplied[obj] then
                WeaponChamsApplied[obj] = true
                local hl = Instance.new("Highlight")
                hl.Adornee          = obj
                hl.FillColor        = Config.Visuals.WeaponColor
                hl.OutlineColor     = Color3.new(1,1,1)
                hl.FillTransparency = 0.3
                hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent           = obj
            end
        end
    end
    WeaponChamsApplied[player] = true
end

----------------------------------------------------------------
-- ESP СИСТЕМА (батч-рендер с пулингом)
----------------------------------------------------------------
-- Структура на игрока:
-- {box, hp_line, name_text, dist_text, weapon_text, head_dot,
--  tracer_line, sk_lines[]}
local ESP = {}

-- Скелет: список пар костей
local SkeletonBones = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
}

local function GetESP(player)
    if ESP[player] then return ESP[player] end
    if not Drawing then return nil end
    local e = {sk={}}
    -- Box (4 линии для Corner-стиля или 1 Square для Full)
    e.box_sq  = Drawing.new("Square")
    e.box_sq.Filled    = false
    e.box_sq.Visible   = false
    e.box_sq.Thickness = 1.5

    -- Corner lines (8 линий)
    e.corners = {}
    for i=1,8 do
        local l = Drawing.new("Line")
        l.Visible   = false
        l.Thickness = 2
        table.insert(e.corners, l)
    end

    -- HP bar
    e.hp_bg = Drawing.new("Square")
    e.hp_bg.Filled  = true
    e.hp_bg.Visible = false
    e.hp_bg.Color   = Color3.fromRGB(30,30,30)

    e.hp_fill = Drawing.new("Square")
    e.hp_fill.Filled  = true
    e.hp_fill.Visible = false

    -- Тексты
    e.name   = Drawing.new("Text")
    e.name.Visible  = false
    e.name.Size     = 13
    e.name.Outline  = true
    e.name.Center   = true

    e.dist   = Drawing.new("Text")
    e.dist.Visible  = false
    e.dist.Size     = 11
    e.dist.Outline  = true
    e.dist.Center   = true
    e.dist.Color    = Color3.fromRGB(180,180,180)

    e.weapon = Drawing.new("Text")
    e.weapon.Visible  = false
    e.weapon.Size     = 11
    e.weapon.Outline  = true
    e.weapon.Center   = true
    e.weapon.Color    = Color3.fromRGB(255,220,80)

    -- Head dot
    e.head_dot = Drawing.new("Circle")
    e.head_dot.Visible   = false
    e.head_dot.Filled    = true
    e.head_dot.NumSides  = 16
    e.head_dot.Radius    = 4

    -- Tracer
    e.tracer = Drawing.new("Line")
    e.tracer.Visible   = false
    e.tracer.Thickness = 1

    -- Skeleton lines
    for i=1,#SkeletonBones do
        local l = Drawing.new("Line")
        l.Visible   = false
        l.Thickness = 1
        l.Color     = Color3.fromRGB(255,255,255)
        table.insert(e.sk, l)
    end

    ESP[player] = e
    return e
end

local function HideESP(e)
    e.box_sq.Visible  = false
    e.hp_bg.Visible   = false
    e.hp_fill.Visible = false
    e.name.Visible    = false
    e.dist.Visible    = false
    e.weapon.Visible  = false
    e.head_dot.Visible= false
    e.tracer.Visible  = false
    for _,l in ipairs(e.corners) do l.Visible=false end
    for _,l in ipairs(e.sk) do l.Visible=false end
end

local function GetPlayerWeapon(player)
    local c = GetChar(player) if not c then return "?" end
    for _, obj in ipairs(c:GetChildren()) do
        if obj:IsA("Tool") then return obj.Name end
    end
    return ""
end

-- Рисуем Corner-box (8 линий, по 2 на угол)
-- BOLT OPTIMIZATION: Assign Vector2 positions directly to line instances
-- to eliminate allocating temporary corner position tables and 16 Vector2 objects
-- per player every frame. Reduces GC pressure significantly in ESP hot loop.
local function DrawCornerBox(e, x, y, w, h, col)
    local cs = math.min(w,h) * 0.25  -- corner length
    local c = e.corners

    c[1].From = Vector2.new(x,y)      c[1].To = Vector2.new(x+cs,y)   c[1].Color = col c[1].Visible = true
    c[2].From = Vector2.new(x,y)      c[2].To = Vector2.new(x,y+cs)   c[2].Color = col c[2].Visible = true

    c[3].From = Vector2.new(x+w,y)    c[3].To = Vector2.new(x+w-cs,y) c[3].Color = col c[3].Visible = true
    c[4].From = Vector2.new(x+w,y)    c[4].To = Vector2.new(x+w,y+cs) c[4].Color = col c[4].Visible = true

    c[5].From = Vector2.new(x,y+h)    c[5].To = Vector2.new(x+cs,y+h) c[5].Color = col c[5].Visible = true
    c[6].From = Vector2.new(x,y+h)    c[6].To = Vector2.new(x,y+h-cs) c[6].Color = col c[6].Visible = true

    c[7].From = Vector2.new(x+w,y+h)  c[7].To = Vector2.new(x+w-cs,y+h) c[7].Color = col c[7].Visible = true
    c[8].From = Vector2.new(x+w,y+h)  c[8].To = Vector2.new(x+w,y+h-cs) c[8].Color = col c[8].Visible = true
end

local function UpdateESP()
    if not ShouldRun("ESP") then return end

    local vs   = Camera.ViewportSize
    local myR  = GetRoot(LocalPlayer)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local e = GetESP(player)
        if not e then continue end

        local c    = GetChar(player)
        local root = GetRoot(player)
        local hum  = GetHum(player)

        if not c or not root or not hum or hum.Health <= 0 then
            HideESP(e) continue
        end

        local vis1, sp_root = W2S(root.Position)
        local vis2, sp_head = W2S(root.Position + Vector3.new(0,3.2,0))
        if not vis1 or not vis2 then HideESP(e) continue end

        local height = math.abs(sp_root.Y - sp_head.Y) * 2.2
        local width  = height * 0.58
        local x      = sp_root.X - width/2
        local y      = sp_root.Y - height/2
        local hpPct  = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
        local boxCol = Config.Visuals.BoxColor
        local dist   = myR and (myR.Position - root.Position).Magnitude or 0

        -- BOX
        if Config.Visuals.BoxESP then
            if Config.Visuals.BoxStyle == "Corner" then
                e.box_sq.Visible = false
                for _,l in ipairs(e.corners) do l.Color = boxCol end
                DrawCornerBox(e, x, y, width, height, boxCol)
            else
                for _,l in ipairs(e.corners) do l.Visible=false end
                e.box_sq.Visible   = true
                e.box_sq.Position  = Vector2.new(x, y)
                e.box_sq.Size      = Vector2.new(width, height)
                e.box_sq.Color     = boxCol
            end
        else
            e.box_sq.Visible = false
            for _,l in ipairs(e.corners) do l.Visible=false end
        end

        -- HEALTH BAR
        if Config.Visuals.HealthBar then
            local barH = height
            local barW = 4
            local bx, by
            if Config.Visuals.HealthBarSide == "Left" then
                bx = x - 8
                by = y
            elseif Config.Visuals.HealthBarSide == "Right" then
                bx = x + width + 4
                by = y
            else -- Bottom
                bx = x
                by = y + height + 4
                barH = barW
                barW = width
            end

            e.hp_bg.Visible  = true
            e.hp_bg.Position = Vector2.new(bx, by)
            e.hp_bg.Size     = Config.Visuals.HealthBarSide=="Bottom"
                and Vector2.new(barW, barH)
                or  Vector2.new(barW, barH)

            e.hp_fill.Visible = true
            e.hp_fill.Position = Vector2.new(bx, by + barH*(1-hpPct))
            e.hp_fill.Size     = Config.Visuals.HealthBarSide=="Bottom"
                and Vector2.new(barW*hpPct, barH)
                or  Vector2.new(barW, barH*hpPct)
            e.hp_fill.Color    = Color3.fromRGB(
                math.floor((1-hpPct)*255),
                math.floor(hpPct*200+55),
                40
            )
        else
            e.hp_bg.Visible   = false
            e.hp_fill.Visible = false
        end

        -- NAME
        if Config.Visuals.NameESP then
            e.name.Visible  = true
            e.name.Position = Vector2.new(sp_root.X, y - 16)
            e.name.Text     = player.Name
            e.name.Color    = Config.Visuals.NameColor
        else e.name.Visible = false end

        -- DISTANCE
        if Config.Visuals.DistanceESP then
            e.dist.Visible  = true
            e.dist.Position = Vector2.new(sp_root.X, y + height + 2)
            e.dist.Text     = string.format("[%.0fm]", dist)
        else e.dist.Visible = false end

        -- WEAPON
        if Config.Visuals.WeaponESP then
            local wname = GetPlayerWeapon(player)
            if wname ~= "" then
                e.weapon.Visible  = true
                e.weapon.Position = Vector2.new(sp_root.X, y + height + 14)
                e.weapon.Text     = wname
            else e.weapon.Visible = false end
        else e.weapon.Visible = false end

        -- HEAD DOT
        if Config.Visuals.HeadDot then
            e.head_dot.Visible   = true
            e.head_dot.Position  = sp_head
            e.head_dot.Color     = boxCol
        else e.head_dot.Visible = false end

        -- TRACER
        if Config.Visuals.TracerESP then
            local origin
            if Config.Visuals.TracerOrigin == "Bottom" then
                origin = Vector2.new(vs.X/2, vs.Y)
            elseif Config.Visuals.TracerOrigin == "Top" then
                origin = Vector2.new(vs.X/2, 0)
            else
                origin = vs/2
            end
            e.tracer.Visible = true
            e.tracer.From    = origin
            e.tracer.To      = sp_root
            e.tracer.Color   = boxCol
        else e.tracer.Visible = false end

        -- SKELETON
        if Config.Visuals.SkeletonESP then
            for i, pair in ipairs(SkeletonBones) do
                local b1 = c:FindFirstChild(pair[1])
                local b2 = c:FindFirstChild(pair[2])
                local ln = e.sk[i]
                if b1 and b2 then
                    local v1, p1 = W2S(b1.Position)
                    local v2, p2 = W2S(b2.Position)
                    if v1 and v2 then
                        ln.Visible = true
                        ln.From    = p1
                        ln.To      = p2
                        ln.Color   = Color3.fromRGB(200,200,200)
                    else ln.Visible = false end
                else ln.Visible = false end
            end
        else
            for _,l in ipairs(e.sk) do l.Visible=false end
        end
    end
end

----------------------------------------------------------------
-- DROPPED WEAPON ESP
----------------------------------------------------------------
local DroppedHighlights = {}

-- BOLT OPTIMIZATION: Event-driven tracking for dropped tools in Workspace instead of calling Workspace:GetDescendants()
-- on a throttled loop. Scanning entire Workspace hierarchy (tens of thousands of instances) every 0.15s causes heavy CPU spikes.
local wasDroppedESPEnabled = false

local function AddToolHighlight(obj)
    if obj:IsA("Tool") and not obj:IsDescendantOf(Players) and not DroppedHighlights[obj] then
        local hl = Instance.new("Highlight")
        hl.Adornee          = obj
        hl.FillColor        = Color3.fromRGB(255,255,100)
        hl.OutlineColor     = Color3.fromRGB(255,200,0)
        hl.FillTransparency = 0.4
        hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent           = obj
        DroppedHighlights[obj] = hl
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if Config.Visuals.DroppedESP then
        AddToolHighlight(obj)
    end
end)

local function UpdateDroppedESP()
    if not ShouldRun("Weapon") then return end
    if not Config.Visuals.DroppedESP then
        if wasDroppedESPEnabled then
            wasDroppedESPEnabled = false
            for obj, hl in pairs(DroppedHighlights) do
                hl:Destroy()
                DroppedHighlights[obj] = nil
            end
        end
        return
    end

    -- Initial scan when feature is toggled on (runs once on toggle)
    if not wasDroppedESPEnabled then
        wasDroppedESPEnabled = true
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                AddToolHighlight(obj)
            end
        end
    end

    -- Clean up highlights for tools that were picked up or destroyed
    for obj, hl in pairs(DroppedHighlights) do
        if not obj.Parent or obj:IsDescendantOf(Players) then
            hl:Destroy()
            DroppedHighlights[obj] = nil
        end
    end
end

----------------------------------------------------------------
-- WORLD VISUALS
----------------------------------------------------------------
local OrigFog       = nil
local OrigAmbient   = nil
local CustomSkyInst = nil
local OrigSkyInst   = nil

local function ApplyWorldVisuals()
    if not ShouldRun("World") then return end

    -- NO FOG
    if Config.Visuals.NoFog then
        if not OrigFog then
            OrigFog = {
                Start      = Lighting.FogStart,
                End        = Lighting.FogEnd,
                Color      = Lighting.FogColor,
            }
        end
        Lighting.FogStart = 1e6
        Lighting.FogEnd   = 1e6
    elseif OrigFog then
        Lighting.FogStart = OrigFog.Start
        Lighting.FogEnd   = OrigFog.End
        Lighting.FogColor = OrigFog.Color
        OrigFog = nil
    end

    -- FULLBRIGHT
    if Config.Visuals.Fullbright then
        if not OrigAmbient then OrigAmbient = Lighting.Ambient end
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.Brightness = 5
    elseif OrigAmbient then
        Lighting.Ambient = OrigAmbient
        Lighting.Brightness = 1
        OrigAmbient = nil
    end

    -- SKYBOX
    -- BOLT OPTIMIZATION: Cache and reuse CustomSkyInst instead of destroying and re-instantiating Sky object every 0.5s.
    -- Re-creating Sky objects continuously wastes memory and causes texture reloading stutters.
    if Config.Visuals.CustomSkybox then
        local id = SkyboxPresets[Config.Visuals.SkyboxType]
        if id then
            if not OrigSkyInst then
                local s = Lighting:FindFirstChildOfClass("Sky")
                if s and s ~= CustomSkyInst then
                    OrigSkyInst = s
                    s.Parent = nil
                end
            end
            if not CustomSkyInst or not CustomSkyInst.Parent then
                local sky = Instance.new("Sky")
                sky.SkyboxBk = id sky.SkyboxDn = id sky.SkyboxFt = id
                sky.SkyboxLf = id sky.SkyboxRt = id sky.SkyboxUp = id
                sky.Parent   = Lighting
                CustomSkyInst = sky
            elseif CustomSkyInst.SkyboxBk ~= id then
                CustomSkyInst.SkyboxBk = id CustomSkyInst.SkyboxDn = id CustomSkyInst.SkyboxFt = id
                CustomSkyInst.SkyboxLf = id CustomSkyInst.SkyboxRt = id CustomSkyInst.SkyboxUp = id
            end
        end
    elseif CustomSkyInst then
        CustomSkyInst:Destroy()
        CustomSkyInst = nil
        if OrigSkyInst then OrigSkyInst.Parent = Lighting OrigSkyInst = nil end
    end
end

----------------------------------------------------------------
-- CUSTOM MASK
----------------------------------------------------------------
local MaskAcc = nil

local function ApplyMask()
    if not Config.Visuals.CustomMask then
        if MaskAcc then MaskAcc:Destroy() MaskAcc=nil end
        return
    end
    local c = GetChar(LocalPlayer) if not c then return end
    local head = c:FindFirstChild("Head") if not head then return end
    if MaskAcc and MaskAcc.Parent then return end
    if MaskAcc then MaskAcc:Destroy() end

    local acc = Instance.new("Accessory")
    acc.Name = "BRMask"
    local handle = Instance.new("Part")
    handle.Name = "Handle" handle.Size = Vector3.one
    handle.CanCollide = false handle.Massless = true
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://"..MaskPresets[Config.Visuals.MaskType]
    mesh.Parent = handle
    local weld = Instance.new("Weld")
    weld.Part0 = head weld.Part1 = handle
    weld.C0 = CFrame.new(0, 0.1, -0.1)
    weld.Parent = handle
    handle.Parent = acc
    acc.Parent = c
    MaskAcc = acc
end

----------------------------------------------------------------
-- RAGEBOT
----------------------------------------------------------------
local function RagebotTick()
    if not Config.Ragebot.Enabled then return end
    local target = GetTarget()
    if not target then return end
    if GetFOVAngle(target) > Config.Ragebot.FOV then return end

    if Config.Ragebot.SilentAim then SilentAim(target) end

    if Config.Ragebot.AutoStop then
        local c = GetChar(LocalPlayer)
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 0
            task.delay(0.08, function()
                if hum and hum.Parent then hum.WalkSpeed = 16 end
            end)
        end
    end
end

----------------------------------------------------------------
-- PLAYER HOOKS
----------------------------------------------------------------
local function OnCharAdded(player)
    task.wait(0.8)  -- ждём загрузки персонажа
    ChamObjects[player] = nil
    WeaponChamsApplied[player] = nil
    ApplyChams(player)
    if player == LocalPlayer then ApplyMask() end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        ApplyChams(p)
        p.CharacterAdded:Connect(function() OnCharAdded(p) end)
    else
        p.CharacterAdded:Connect(function() OnCharAdded(p) end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() OnCharAdded(p) end)
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveChams(p)
    if ESP[p] then
        HideESP(ESP[p])
        ESP[p] = nil
    end
end)

----------------------------------------------------------------
-- MAIN LOOPS (разделены по частоте)
----------------------------------------------------------------

-- RenderStepped — только самое необходимое
RunService.RenderStepped:Connect(function()
    UpdateFOV()
    UpdateESP()
    if ShouldRun("Chams") then
        UpdateChamsColor()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                ApplyChams(p)
                if Config.Visuals.WeaponChams then ApplyWeaponChams(p) end
            end
        end
    end
end)

-- Heartbeat — игровая логика
RunService.Heartbeat:Connect(function()
    RagebotTick()
    ApplyAntiAim()
    HandleFakeLag()
    HandleBHop()
    HandleStrafe()
    HandleAntiVoid()
    HandleSpeed()
    HandleFly()
    ApplyWorldVisuals()
    UpdateDroppedESP()
end)

----------------------------------------------------------------
-- UI
----------------------------------------------------------------
local Font = Enum.Font.GothamBold

-- Главный фрейм
local Main = Instance.new("Frame")
Main.Name              = "BankrollMain"
Main.Size              = UDim2.new(0, 340, 0, 480)
Main.Position          = UDim2.new(0.5, -170, 0.5, -240)
Main.BackgroundColor3  = Config.UI.MainBg
Main.BorderSizePixel   = 0
Main.Active            = true
Main.Draggable         = true
Main.Parent            = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainBorder = Instance.new("UIStroke")
MainBorder.Color     = Config.UI.Accent
MainBorder.Thickness = 1.5
MainBorder.Parent    = Main

-- Топ-бар
local TopBar = Instance.new("Frame")
TopBar.Size             = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Config.UI.Panel
TopBar.BorderSizePixel  = 0
TopBar.Parent           = Main

local TBCorner = Instance.new("UICorner")
TBCorner.CornerRadius = UDim.new(0, 10)
TBCorner.Parent = TopBar

-- Фикс нижних углов топбара
local TBFix = Instance.new("Frame")
TBFix.Size             = UDim2.new(1, 0, 0.5, 0)
TBFix.Position         = UDim2.new(0, 0, 0.5, 0)
TBFix.BackgroundColor3 = Config.UI.Panel
TBFix.BorderSizePixel  = 0
TBFix.Parent           = TopBar

local Logo = Instance.new("TextLabel")
Logo.Text              = "⚡ BANKROLL.SOSU"
Logo.Size              = UDim2.new(1, -40, 1, 0)
Logo.Position          = UDim2.new(0, 12, 0, 0)
Logo.BackgroundTransparency = 1
Logo.TextColor3        = Config.UI.Accent
Logo.Font              = Font
Logo.TextSize          = 15
Logo.TextXAlignment    = Enum.TextXAlignment.Left
Logo.Parent            = TopBar

-- Кнопка закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.AnchorPoint      = Vector2.new(1, 0.5)
CloseBtn.Position         = UDim2.new(1, -6, 0.5, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.new(1,1,1)
CloseBtn.Font             = Font
CloseBtn.TextSize         = 13
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TopBar
local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(1,0)
CBCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Табы
local TabNames = {"Ragebot","AntiAim","Movement","Visuals","World"}
local TabBtns  = {}
local TabPages = {}

local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1, 0, 0, 30)
TabBar.Position         = UDim2.new(0, 0, 0, 36)
TabBar.BackgroundColor3 = Config.UI.Panel
TabBar.BorderSizePixel  = 0
TabBar.Parent           = Main

local TBLayout = Instance.new("UIListLayout")
TBLayout.FillDirection = Enum.FillDirection.Horizontal
TBLayout.SortOrder     = Enum.SortOrder.LayoutOrder
TBLayout.Parent        = TabBar

-- Контент зона
local Content = Instance.new("Frame")
Content.Size             = UDim2.new(1, 0, 1, -66)
Content.Position         = UDim2.new(0, 0, 0, 66)
Content.BackgroundTransparency = 1
Content.BorderSizePixel  = 0
Content.Parent           = Main

-- Создаём таб-кнопки и страницы
local function SetTab(name)
    for _, n in ipairs(TabNames) do
        local btn  = TabBtns[n]
        local page = TabPages[n]
        if n == name then
            btn.BackgroundColor3 = Config.UI.Accent
            btn.TextColor3       = Color3.new(1,1,1)
            page.Visible         = true
        else
            btn.BackgroundColor3 = Config.UI.Panel
            btn.TextColor3       = Config.UI.Dim
            page.Visible         = false
        end
    end
end

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1/#TabNames, 0, 1, 0)
    btn.BackgroundColor3 = Config.UI.Panel
    btn.BorderSizePixel  = 0
    btn.Text             = name
    btn.Font             = Font
    btn.TextSize         = 11
    btn.TextColor3       = Config.UI.Dim
    btn.LayoutOrder      = i
    btn.Parent           = TabBar
    TabBtns[name] = btn
    btn.MouseButton1Click:Connect(function() SetTab(name) end)

    local page = Instance.new("ScrollingFrame")
    page.Size                   = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel        = 0
    page.ScrollBarThickness     = 3
    page.ScrollBarImageColor3   = Config.UI.Accent
    page.Visible                = false
    page.Parent                 = Content
    TabPages[name] = page

    local layout = Instance.new("UIListLayout")
    layout.Padding    = UDim.new(0, 4)
    layout.SortOrder  = Enum.SortOrder.LayoutOrder
    layout.Parent     = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft   = UDim.new(0, 8)
    padding.PaddingRight  = UDim.new(0, 8)
    padding.PaddingTop    = UDim.new(0, 6)
    padding.Parent        = page
end
SetTab("Ragebot")

-- UI helpers
local function MakeSection(page, title)
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1, 0, 0, 22)
    f.BackgroundColor3 = Config.UI.Border
    f.BorderSizePixel  = 0
    f.Parent           = page
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,4) corner.Parent=f
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-8,1,0) lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=title
    lbl.Font=Font lbl.TextSize=12
    lbl.TextColor3=Config.UI.Accent lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=f
    return f
end

local function MakeToggle(page, text, cfg, key, cb)
    local f = Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,28) f.BackgroundTransparency=1 f.Parent=page
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-42,1,0) lbl.Position=UDim2.new(0,4,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=text
    lbl.Font=Font lbl.TextSize=12 lbl.TextColor3=Config.UI.Text
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=f
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,32,0,18) btn.AnchorPoint=Vector2.new(1,0.5)
    btn.Position=UDim2.new(1,-4,0.5,0) btn.BorderSizePixel=0 btn.Text=""
    btn.Parent=f
    local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=btn
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,14,0,14) knob.AnchorPoint=Vector2.new(0,0.5)
    knob.BackgroundColor3=Color3.new(1,1,1) knob.BorderSizePixel=0 knob.Parent=btn
    local kc=Instance.new("UICorner") kc.CornerRadius=UDim.new(1,0) kc.Parent=knob
    local function Refresh()
        local v=cfg[key]
        btn.BackgroundColor3 = v and Config.UI.Accent or Config.UI.Border
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = v and UDim2.new(1,-16,0.5,0) or UDim2.new(0,2,0.5,0)
        }):Play()
    end
    Refresh()
    btn.MouseButton1Click:Connect(function()
        cfg[key]=not cfg[key] Refresh()
        if cb then cb(cfg[key]) end
    end)
    return f
end

local function MakeSlider(page, text, cfg, key, min, max)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,42) f.BackgroundTransparency=1 f.Parent=page
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,0,16) lbl.Position=UDim2.new(0,4,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=text..": "..tostring(cfg[key])
    lbl.Font=Font lbl.TextSize=11 lbl.TextColor3=Config.UI.Dim
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=f
    local track=Instance.new("Frame")
    track.BackgroundColor3=Config.UI.Border track.BorderSizePixel=0
    track.Size=UDim2.new(1,-8,0,6) track.Position=UDim2.new(0,4,0,22)
    track.Parent=f
    local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(1,0) tc.Parent=track
    local fill=Instance.new("Frame")
    fill.BackgroundColor3=Config.UI.Accent fill.BorderSizePixel=0
    fill.Size=UDim2.new((cfg[key]-min)/(max-min),0,1,0) fill.Parent=track
    local fc=Instance.new("UICorner") fc.CornerRadius=UDim.new(1,0) fc.Parent=fill
    local drag=false
    local function SetV(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.floor(min+rel*(max-min))
        cfg[key]=val
        fill.Size=UDim2.new(rel,0,1,0)
        lbl.Text=text..": "..tostring(val)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true SetV(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then
            SetV(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    return f
end

local function MakeDropdown(page, text, options, cfg, key)
    local open=false
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,28) f.BackgroundTransparency=1 f.Parent=page
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundColor3=Config.UI.Border
    btn.BorderSizePixel=0 btn.Font=Font btn.TextSize=12
    btn.TextColor3=Config.UI.Text btn.Parent=f
    local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,4) bc.Parent=btn
    local function RefreshBtn()
        btn.Text = text..": "..tostring(cfg[key]).."  ▾"
    end
    RefreshBtn()
    local dropdown=Instance.new("Frame")
    dropdown.BackgroundColor3=Config.UI.Panel dropdown.BorderSizePixel=0
    dropdown.ZIndex=10 dropdown.Visible=false
    dropdown.Size=UDim2.new(1,0,0,#options*26)
    dropdown.Position=UDim2.new(0,0,1,2)
    dropdown.Parent=btn
    local dl=Instance.new("UIListLayout") dl.SortOrder=Enum.SortOrder.LayoutOrder dl.Parent=dropdown
    local dc=Instance.new("UICorner") dc.CornerRadius=UDim.new(0,4) dc.Parent=dropdown
    for _, opt in ipairs(options) do
        local ob=Instance.new("TextButton")
        ob.Size=UDim2.new(1,0,0,26) ob.BackgroundTransparency=1
        ob.Text=opt ob.Font=Font ob.TextSize=11
        ob.TextColor3=Config.UI.Text ob.BorderSizePixel=0 ob.Parent=dropdown
        ob.MouseButton1Click:Connect(function()
            cfg[key]=opt RefreshBtn()
            dropdown.Visible=false open=false
        end)
    end
    btn.MouseButton1Click:Connect(function()
        open=not open dropdown.Visible=open
        f.Size=open and UDim2.new(1,0,0,28+#options*26) or UDim2.new(1,0,0,28)
    end)
    return f
end

-- Заполнение вкладок
local RPage = TabPages["Ragebot"]
MakeSection(RPage, "⚙ RAGEBOT")
MakeToggle(RPage, "Enabled",     Config.Ragebot, "Enabled")
MakeToggle(RPage, "Silent Aim",  Config.Ragebot, "SilentAim")
MakeToggle(RPage, "Auto Stop",   Config.Ragebot, "AutoStop")
MakeToggle(RPage, "Multipoint",  Config.Ragebot, "Multipoint")
MakeToggle(RPage, "Show FOV",    Config.Ragebot, "ShowFOV")
MakeSlider(RPage, "FOV Radius",  Config.Ragebot, "FOV", 10, 400)
MakeDropdown(RPage,"Target Select",{"Distance","Health","FOV"}, Config.Ragebot, "TargetSelection")
MakeDropdown(RPage,"Target Part", {"Head","HumanoidRootPart","UpperTorso"}, Config.Ragebot, "TargetPart")

local AAPage = TabPages["AntiAim"]
MakeSection(AAPage, "↩ ANTI-AIM")
MakeToggle(AAPage, "Enabled",    Config.AntiAim, "Enabled")
MakeToggle(AAPage, "Fake Lag",   Config.AntiAim, "FakeLag")
MakeSlider(AAPage, "Spin Speed", Config.AntiAim, "SpinSpeed", 1, 60)
MakeSlider(AAPage, "Jitter Range",Config.AntiAim,"JitterRange",5,180)
MakeSlider(AAPage, "FL Limit",   Config.AntiAim, "FakeLagLimit", 2, 20)
MakeDropdown(AAPage,"Style",{"spin","jitter","left-right","static"}, Config.AntiAim,"Style")
MakeDropdown(AAPage,"Pitch",{"down","up","none"}, Config.AntiAim,"Pitch")

local MvPage = TabPages["Movement"]
MakeSection(MvPage, "🏃 MOVEMENT")
MakeToggle(MvPage, "Bunny Hop",  Config.Movement, "BunnyHop")
MakeToggle(MvPage, "Auto Strafe",Config.Movement, "AutoStrafe")
MakeToggle(MvPage, "Fly",        Config.Movement, "Fly", function(v)
    if not v then DisableFly() end
end)
MakeToggle(MvPage, "Speed Hack", Config.Movement, "SpeedHack")
MakeToggle(MvPage, "Anti Void",  Config.Movement, "AntiVoid")
MakeSlider(MvPage, "Fly Speed",  Config.Movement, "FlySpeed", 10, 200)
MakeSlider(MvPage, "Speed Value",Config.Movement, "SpeedValue",16,100)

local VPage = TabPages["Visuals"]
MakeSection(VPage, "👁 ESP ПЕРСОНАЖА")
MakeToggle(VPage, "Box ESP",      Config.Visuals, "BoxESP")
MakeDropdown(VPage,"Box Style",{"Corner","Full"}, Config.Visuals,"BoxStyle")
MakeToggle(VPage, "Health Bar",   Config.Visuals, "HealthBar")
MakeDropdown(VPage,"HP Bar Side",{"Left","Right","Bottom"}, Config.Visuals,"HealthBarSide")
MakeToggle(VPage, "Name ESP",     Config.Visuals, "NameESP")
MakeToggle(VPage, "Distance ESP", Config.Visuals, "DistanceESP")
MakeToggle(VPage, "Weapon ESP",   Config.Visuals, "WeaponESP")
MakeToggle(VPage, "Skeleton ESP", Config.Visuals, "SkeletonESP")
MakeToggle(VPage, "Tracer",       Config.Visuals, "TracerESP")
MakeToggle(VPage, "Head Dot",     Config.Visuals, "HeadDot")
MakeDropdown(VPage,"Tracer From",{"Bottom","Center","Top"}, Config.Visuals,"TracerOrigin")
MakeSection(VPage, "💎 CHAMS")
MakeToggle(VPage, "Chams",        Config.Visuals, "Chams", function(v)
    if not v then
        for p,_ in pairs(ChamObjects) do RemoveChams(p) end
    end
end)
MakeDropdown(VPage,"Shader",{"Flat","Glow","Wireframe","Ghost","Rainbow","Solid"}, Config.Visuals,"ChamShader")
MakeToggle(VPage, "Weapon Chams", Config.Visuals, "WeaponChams")
MakeToggle(VPage, "Dropped ESP",  Config.Visuals, "DroppedESP")
MakeSection(VPage, "🔊 MISC")
MakeToggle(VPage, "Hit Sound",    Config.Visuals, "HitSound")
MakeDropdown(VPage,"Sound Type",{"SAMP bell","Skeet","Neverlose","CS Headshot","Click"}, Config.Visuals,"HitSoundType")
MakeToggle(VPage, "Custom Mask",  Config.Visuals, "CustomMask", function() ApplyMask() end)
MakeDropdown(VPage,"Mask Type",{"Payday Clown","Dallas","Skull"}, Config.Visuals,"MaskType")

local WPage = TabPages["World"]
MakeSection(WPage, "🌍 МИР")
MakeToggle(WPage, "No Fog",       Config.Visuals, "NoFog")
MakeToggle(WPage, "Fullbright",   Config.Visuals, "Fullbright")
MakeToggle(WPage, "Custom Skybox",Config.Visuals, "CustomSkybox")
MakeDropdown(WPage,"Skybox Type",{"Purple Nebula","Space Stars","Night City","Cyber Red","Void Black"}, Config.Visuals,"SkyboxType")

-- Авто-ресайз ScrollingFrame
for _, name in ipairs(TabNames) do
    local page = TabPages[name]
    local layout = page:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
        end)
    end
end

-- Мобильный toggle (двойной тап по экрану)
local lastTap = 0
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTap < 0.35 then
            Main.Visible = not Main.Visible
        end
        lastTap = now
    end
    -- ПК: Insert для показа/скрытия
    if input.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

print("✅ BANKROLL v2.0 loaded | Double-tap to toggle UI | Insert on PC")
