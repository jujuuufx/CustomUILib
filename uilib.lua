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
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Default colors
local DEFAULT_BG = Color3.fromRGB(25, 25, 25)
local DEFAULT_ACCENT = Color3.fromRGB(0, 170, 255)
local DEFAULT_TEXT = Color3.fromRGB(255, 255, 255)
local DEFAULT_BORDER = Color3.fromRGB(50, 50, 50)
local DEFAULT_SHADOW = Color3.fromRGB(0, 0, 0)

--========================
-- Create Window
--========================
function SimpleUI:CreateWindow(title, size)
    local self = setmetatable({}, SimpleUI)
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = size or UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = DEFAULT_BG
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Rounded corners for main frame
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = mainFrame
    
    -- Shadow effect
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = DEFAULT_SHADOW
    uiStroke.Transparency = 0.5
    uiStroke.Thickness = 2
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = DEFAULT_ACCENT
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "SimpleUI"
    titleLabel.TextColor3 = DEFAULT_TEXT
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "X"
    closeButton.TextColor3 = DEFAULT_TEXT
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 18
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Dragging functionality
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Content Frame with Scrolling
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = DEFAULT_BORDER
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Auto-size later
    contentFrame.Parent = mainFrame
    
    -- UIListLayout for content
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = contentFrame
    
    -- Padding for content
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, 10)
    uiPadding.PaddingRight = UDim.new(0, 10)
    uiPadding.PaddingTop = UDim.new(0, 10)
    uiPadding.PaddingBottom = UDim.new(0, 10)
    uiPadding.Parent = contentFrame
    
    -- Auto-resize canvas
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Store references
    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.ContentFrame = contentFrame
    self.UIListLayout = uiListLayout
    
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
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 24)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    toggleButton.BackgroundColor3 = DEFAULT_BORDER
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.Position = UDim2.new(0, 2, 0.5, -10)
    toggleIndicator.BackgroundColor3 = DEFAULT_TEXT
    toggleIndicator.Parent = toggleButton
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 10)
    indicatorCorner.Parent = toggleIndicator
    
    local state = default or false
    if state then
        toggleIndicator.Position = UDim2.new(1, -22, 0.5, -10)
        toggleButton.BackgroundColor3 = DEFAULT_ACCENT
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goal = {}
        if state then
            goal.Position = UDim2.new(1, -22, 0.5, -10)
            toggleButton.BackgroundColor3 = DEFAULT_ACCENT
        else
            goal.Position = UDim2.new(0, 2, 0.5, -10)
            toggleButton.BackgroundColor3 = DEFAULT_BORDER
        end
        TweenService:Create(toggleIndicator, tweenInfo, goal):Play()
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
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = DEFAULT_BORDER
    uiStroke.Transparency = 0.8
    uiStroke.Parent = button
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = DEFAULT_ACCENT:lerp(Color3.new(1,1,1), 0.1)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = DEFAULT_ACCENT}):Play()
    end)
    
    return button
end

return SimpleUI
