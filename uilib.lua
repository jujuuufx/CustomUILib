--========================================================
-- SimpleUI Library
-- Lightweight Roblox UI Library for Scripts
--========================================================

local SimpleUI = {}
SimpleUI.__index = SimpleUI

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Default colors
local DEFAULT_BG = Color3.fromRGB(25, 25, 25)
local DEFAULT_ACCENT = Color3.fromRGB(0, 170, 255)
local DEFAULT_TEXT = Color3.fromRGB(255, 255, 255)

--========================
-- Create Window
--========================
function SimpleUI:CreateWindow(title)
    local self = setmetatable({}, SimpleUI)

    -- Main Frame
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = DEFAULT_BG
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundColor3 = DEFAULT_ACCENT
    titleLabel.Text = title or "SimpleUI"
    titleLabel.TextColor3 = DEFAULT_TEXT
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.Parent = mainFrame

    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -10, 1, -40)
    contentFrame.Position = UDim2.new(0, 5, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Store references
    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.ContentFrame = contentFrame

    return self
end

--========================
-- Add Toggle
--========================
function SimpleUI:AddToggle(name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = self.ContentFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = DEFAULT_TEXT
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, -5, 1, 0)
    button.Position = UDim2.new(0.7, 5, 0, 0)
    button.BackgroundColor3 = default and DEFAULT_ACCENT or DEFAULT_BG
    button.Text = ""
    button.Parent = toggleFrame

    local state = default or false

    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and DEFAULT_ACCENT or DEFAULT_BG
        if callback then
            callback(state)
        end
    end)

    return toggleFrame
end

--========================
-- Add Button
--========================
function SimpleUI:AddButton(name, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = DEFAULT_ACCENT
    button.TextColor3 = DEFAULT_TEXT
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Text = name
    button.Parent = self.ContentFrame

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return button
end

return SimpleUI
