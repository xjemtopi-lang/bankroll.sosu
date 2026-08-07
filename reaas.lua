-- Minimalistic Fast GUI for Delta
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- GUI Container setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LiteGui_" .. math.random(100, 999)
ScreenGui.ResetOnSpawn = false

-- Safe parent check
if gethui then
    ScreenGui.Parent = gethui()
elseif pcall(function() ScreenGui.Parent = CoreGui end) then
    -- Parented to CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 3)
end

-- Watermark / Toggle Button
local WmBtn = Instance.new("TextButton")
WmBtn.Size = UDim2.new(0, 150, 0, 26)
WmBtn.Position = UDim2.new(0, 10, 0, 10)
WmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
WmBtn.BorderColor3 = Color3.fromRGB(120, 0, 180)
WmBtn.Text = " bankroll.sosu [TOGGLE]"
WmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WmBtn.TextSize = 11
WmBtn.Font = Enum.Font.Code
WmBtn.Parent = ScreenGui

-- Main Panel
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 220)
Main.Position = UDim2.new(0.5, -150, 0.4, -110)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderColor3 = Color3.fromRGB(120, 0, 180)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

WmBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Text = "bankroll lite | mobile hvh"
Title.TextColor3 = Color3.fromRGB(180, 100, 255)
Title.TextSize = 12
Title.Font = Enum.Font.Code
Title.Parent = Main

-- States
local Flags = {
    AutoShoot = false,
    AntiAim = false,
    BHop = false,
    BoxESP = false
}

-- Simple Toggle Creator
local function AddToggle(text, yPos, flag)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 24)
    Btn.Position = UDim2.new(0, 10, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.Code
    Btn.Parent = Main

    Btn.MouseButton1Click:Connect(function()
        Flags[flag] = not Flags[flag]
        if Flags[flag] then
            Btn.Text = text .. ": ON"
            Btn.TextColor3 = Color3.fromRGB(0, 255, 120)
            Btn.BorderColor3 = Color3.fromRGB(0, 255, 120)
        else
            Btn.Text = text .. ": OFF"
            Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            Btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
        end
    end)
end

-- Adding Controls
AddToggle("Auto Shoot", 35, "AutoShoot")
AddToggle("Anti-Aim (Spin)", 65, "AntiAim")
AddToggle("BunnyHop", 95, "BHop")
AddToggle("Box ESP", 125, "BoxESP")

-- Invert Button (Mobile AA)
local InvBtn = Instance.new("TextButton")
InvBtn.Size = UDim2.new(1, -20, 0, 26)
InvBtn.Position = UDim2.new(0, 10, 0, 160)
InvBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
InvBtn.BorderColor3 = Color3.fromRGB(120, 0, 180)
InvBtn.Text = "INVERT ANTI-AIM SIDE"
InvBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InvBtn.TextSize = 11
InvBtn.Font = Enum.Font.Code
InvBtn.Parent = Main
