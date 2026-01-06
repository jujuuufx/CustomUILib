--========================================================
-- SimpleUI Library
-- Lightweight Roblox UI Library for Scripts
-- Enhanced with tabs, sections, and various elements
--========================================================

local SimpleUI = {}
SimpleUI.__index = SimpleUI

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Default colors
local DEFAULT_BG = Color3.fromRGB(25, 25, 25)
local DEFAULT_ACCENT = Color3.fromRGB(0, 170, 255)
local DEFAULT_TEXT = Color3.fromRGB(255, 255, 255)
local DEFAULT_BORDER = Color3.fromRGB(50, 50, 50)
local DEFAULT_SHADOW = Color3.fromRGB(0, 0, 0)
local DEFAULT_HOVER = Color3.fromRGB(35, 35, 35)

-- Theme table
local Theme = {
    Background = DEFAULT_BG,
    Accent = DEFAULT_ACCENT,
    Text = DEFAULT_TEXT,
    Border = DEFAULT_BORDER,
    Shadow = DEFAULT_SHADOW,
    Hover = DEFAULT_HOVER
}

--========================
-- Utility Functions
--========================
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Transparency = transparency or 0.8
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function addHoverEffect(button, originalColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor:lerp(Color3.new(1,1,1), 0.1)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
end

--========================
-- Notification System
--========================
function SimpleUI:Notify(text, duration)
    local notifyGui = Instance.new("ScreenGui")
    notifyGui.Name = "SimpleUINotify"
    notifyGui.Parent = CoreGui
    
    local notifyFrame = Instance.new("Frame")
    notifyFrame.Size = UDim2.new(0, 300, 0, 50)
    notifyFrame.Position = UDim2.new(1, -310, 1, -60)
    notifyFrame.BackgroundColor3 = Theme.Background
    notifyFrame.BorderSizePixel = 0
    notifyFrame.Parent = notifyGui
    createCorner(notifyFrame, 8)
    createStroke(notifyFrame, Theme.Accent, 0.5, 2)
    
    local notifyLabel = Instance.new("TextLabel")
    notifyLabel.Size = UDim2.new(1, -10, 1, 0)
    notifyLabel.Position = UDim2.new(0, 5, 0, 0)
    notifyLabel.BackgroundTransparency = 1
    notifyLabel.Text = text
    notifyLabel.TextColor3 = Theme.Text
    notifyLabel.Font = Enum.Font.SourceSans
    notifyLabel.TextSize = 16
    notifyLabel.TextWrapped = true
    notifyLabel.Parent = notifyFrame
    
    -- Animate in
    notifyFrame.Position = UDim2.new(1, 0, 1, -60)
    TweenService:Create(notifyFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, -310, 1, -60)}):Play()
    
    -- Destroy after duration
    wait(duration or 3)
    TweenService:Create(notifyFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 1, -60)}):Play()
    wait(0.3)
    notifyGui:Destroy()
end

--========================
-- Create Window
--========================
function SimpleUI:CreateWindow(title, size, theme)
    local self = setmetatable({}, SimpleUI)
    
    if theme then
        Theme = theme
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    screenGui.Enabled = true  -- For visibility toggle
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = size or UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    createCorner(mainFrame, 8)
    createStroke(mainFrame, Theme.Shadow, 0.5, 2).ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Theme.Accent
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    createCorner(titleBar, 8)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -90, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "SimpleUI"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Minimize Button
    local minButton = Instance.new("TextButton")
    minButton.Size = UDim2.new(0, 30, 0, 30)
    minButton.Position = UDim2.new(1, -60, 0, 0)
    minButton.BackgroundTransparency = 1
    minButton.Text = "-"
    minButton.TextColor3 = Theme.Text
    minButton.Font = Enum.Font.SourceSansBold
    minButton.TextSize = 18
    minButton.Parent = titleBar
    
    local minimized = false
    minButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        self.TabContainer.Visible = not minimized
        self.ActiveTabContent.Visible = not minimized
        mainFrame.Size = minimized and UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, 30) or size
    end)
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "X"
    closeButton.TextColor3 = Theme.Text
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
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.Parent = tabContainer
    
    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, 0, 1, -60)
    contentArea.Position = UDim2.new(0, 0, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame
    
    -- Store references
    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
    self.TabContainer = tabContainer
    self.ContentArea = contentArea
    self.Tabs = {}
    self.ActiveTab = nil
    
    return self
end

--========================
-- Set Theme
--========================
function SimpleUI:SetTheme(newTheme)
    Theme = newTheme
    -- Note: This won't retroactively change existing elements; call before creating UI
end

--========================
-- Toggle Visibility
--========================
function SimpleUI:ToggleVisibility(keyCode)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == (keyCode or Enum.KeyCode.RightShift) then
            self.ScreenGui.Enabled = not self.ScreenGui.Enabled
        end
    end)
end

--========================
-- Create Tab
--========================
function SimpleUI:CreateTab(name)
    local tab = {}
    tab.Elements = {}
    
    -- Tab Button
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundColor3 = Theme.Background
    tabButton.Text = name
    tabButton.TextColor3 = Theme.Text
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 16
    tabButton.Parent = self.TabContainer
    createCorner(tabButton, 4)
    createStroke(tabButton)
    addHoverEffect(tabButton, Theme.Background)
    
    -- Tab Content
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = Theme.Border
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = self.ContentArea
    contentFrame.Visible = false
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = contentFrame
    
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingLeft = UDim.new(0, 10)
    uiPadding.PaddingRight = UDim.new(0, 10)
    uiPadding.PaddingTop = UDim.new(0, 10)
    uiPadding.PaddingBottom = UDim.new(0, 10)
    uiPadding.Parent = contentFrame
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    tab.ContentFrame = contentFrame
    tab.UIListLayout = uiListLayout
    
    -- Switch tab function
    tabButton.MouseButton1Click:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.ContentFrame.Visible = false
        end
        contentFrame.Visible = true
        self.ActiveTab = tab
        self.ActiveTabContent = contentFrame
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Set first tab active
    if not self.ActiveTab then
        tabButton:FireEvent("MouseButton1Click")
    end
    
    -- Tab methods
    function tab:AddSection(sectionName)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(1, 0, 0, 40)
        sectionFrame.BackgroundColor3 = Theme.Hover
        sectionFrame.Parent = self.ContentFrame
        createCorner(sectionFrame, 4)
        
        local sectionLabel = Instance.new("TextLabel")
        sectionLabel.Size = UDim2.new(1, 0, 1, 0)
        sectionLabel.BackgroundTransparency = 1
        sectionLabel.Text = sectionName
        sectionLabel.TextColor3 = Theme.Text
        sectionLabel.Font = Enum.Font.SourceSansBold
        sectionLabel.TextSize = 18
        sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        sectionLabel.Parent = sectionFrame
        
        -- Adjust size for elements
        local sectionList = Instance.new("UIListLayout")
        sectionList.Padding = UDim.new(0, 5)
        sectionList.Parent = sectionFrame
        
        sectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sectionFrame.Size = UDim2.new(1, 0, 0, sectionList.AbsoluteContentSize.Y + 10)
        end)
        
        return sectionFrame  -- Add elements to this frame
    end
    
    function tab:AddToggle(name, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 30)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = self.ContentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0, 50, 0, 24)
        toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
        toggleButton.BackgroundColor3 = Theme.Border
        toggleButton.Text = ""
        toggleButton.Parent = toggleFrame
        createCorner(toggleButton, 12)
        
        local toggleIndicator = Instance.new("Frame")
        toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
        toggleIndicator.Position = UDim2.new(0, 2, 0.5, -10)
        toggleIndicator.BackgroundColor3 = Theme.Text
        toggleIndicator.Parent = toggleButton
        createCorner(toggleIndicator, 10)
        
        local state = default or false
        if state then
            toggleIndicator.Position = UDim2.new(1, -22, 0.5, -10)
            toggleButton.BackgroundColor3 = Theme.Accent
        end
        
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local goal = {}
            if state then
                goal.Position = UDim2.new(1, -22, 0.5, -10)
                toggleButton.BackgroundColor3 = Theme.Accent
            else
                goal.Position = UDim2.new(0, 2, 0.5, -10)
                toggleButton.BackgroundColor3 = Theme.Border
            end
            TweenService:Create(toggleIndicator, tweenInfo, goal):Play()
            if callback then
                callback(state)
            end
        end)
        
        return toggleFrame
    end
    
    function tab:AddButton(name, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.BackgroundColor3 = Theme.Accent
        button.TextColor3 = Theme.Text
        button.Font = Enum.Font.SourceSans
        button.TextSize = 16
        button.Text = name
        button.Parent = self.ContentFrame
        createCorner(button)
        createStroke(button)
        
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        addHoverEffect(button, Theme.Accent)
        
        return button
    end
    
    function tab:AddSlider(name, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 40)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = self.ContentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame
        
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(1, 0, 0, 10)
        sliderBar.Position = UDim2.new(0, 0, 0, 25)
        sliderBar.BackgroundColor3 = Theme.Border
        sliderBar.Parent = sliderFrame
        createCorner(sliderBar, 5)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.Parent = sliderBar
        createCorner(fill, 5)
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 1, 0)
        valueLabel.Position = UDim2.new(1, -50, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Theme.Text
        valueLabel.Font = Enum.Font.SourceSans
        valueLabel.TextSize = 14
        valueLabel.Parent = sliderBar
        
        local value = default or min
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        valueLabel.Text = tostring(value)
        
        local dragging = false
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        sliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                local mouseX = UserInputService:GetMouseLocation().X
                local barX = sliderBar.AbsolutePosition.X
                local barWidth = sliderBar.AbsoluteSize.X
                local relative = math.clamp((mouseX - barX) / barWidth, 0, 1)
                value = math.round(min + relative * (max - min))
                fill.Size = UDim2.new(relative, 0, 1, 0)
                valueLabel.Text = tostring(value)
                if callback then
                    callback(value)
                end
            end
        end)
        
        return sliderFrame
    end
    
    function tab:AddTextbox(name, default, callback)
        local textboxFrame = Instance.new("Frame")
        textboxFrame.Size = UDim2.new(1, 0, 0, 30)
        textboxFrame.BackgroundTransparency = 1
        textboxFrame.Parent = self.ContentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = textboxFrame
        
        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(0.6, 0, 1, 0)
        textbox.Position = UDim2.new(0.4, 0, 0, 0)
        textbox.BackgroundColor3 = Theme.Background
        textbox.TextColor3 = Theme.Text
        textbox.Font = Enum.Font.SourceSans
        textbox.TextSize = 16
        textbox.Text = default or ""
        textbox.Parent = textboxFrame
        createCorner(textbox)
        createStroke(textbox)
        
        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textbox.Text)
            end
        end)
        
        return textboxFrame
    end
    
    function tab:AddDropdown(name, options, default, callback)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Size = UDim2.new(1, 0, 0, 30)
        dropdownFrame.BackgroundTransparency = 1
        dropdownFrame.Parent = self.ContentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.4, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = dropdownFrame
        
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Size = UDim2.new(0.6, 0, 1, 0)
        dropdownButton.Position = UDim2.new(0.4, 0, 0, 0)
        dropdownButton.BackgroundColor3 = Theme.Background
        dropdownButton.TextColor3 = Theme.Text
        dropdownButton.Font = Enum.Font.SourceSans
        dropdownButton.TextSize = 16
        dropdownButton.Text = default or options[1]
        dropdownButton.Parent = dropdownFrame
        createCorner(dropdownButton)
        createStroke(dropdownButton)
        
        local dropdownList = Instance.new("Frame")
        dropdownList.Size = UDim2.new(0.6, 0, 0, 0)
        dropdownList.Position = UDim2.new(0.4, 0, 1, 0)
        dropdownList.BackgroundColor3 = Theme.Background
        dropdownList.Visible = false
        dropdownList.Parent = dropdownFrame
        createCorner(dropdownList)
        createStroke(dropdownList)
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = dropdownList
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            dropdownList.Size = UDim2.new(0.6, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        for _, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 30)
            optionButton.BackgroundTransparency = 1
            optionButton.Text = option
            optionButton.TextColor3 = Theme.Text
            optionButton.Font = Enum.Font.SourceSans
            optionButton.TextSize = 16
            optionButton.Parent = dropdownList
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = option
                dropdownList.Visible = false
                if callback then
                    callback(option)
                end
            end)
        end
        
        dropdownButton.MouseButton1Click:Connect(function()
            dropdownList.Visible = not dropdownList.Visible
        end)
        
        return dropdownFrame
    end
    
    function tab:AddLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = self.ContentFrame
        return label
    end
    
    function tab:AddKeybind(name, default, callback)
        local keybindFrame = Instance.new("Frame")
        keybindFrame.Size = UDim2.new(1, 0, 0, 30)
        keybindFrame.BackgroundTransparency = 1
        keybindFrame.Parent = self.ContentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = keybindFrame
        
        local keybindButton = Instance.new("TextButton")
        keybindButton.Size = UDim2.new(0.3, 0, 1, 0)
        keybindButton.Position = UDim2.new(0.7, 0, 0, 0)
        keybindButton.BackgroundColor3 = Theme.Background
        keybindButton.Text = default.Name or "None"
        keybindButton.TextColor3 = Theme.Text
        keybindButton.Font = Enum.Font.SourceSans
        keybindButton.TextSize = 16
        keybindButton.Parent = keybindFrame
        createCorner(keybindButton)
        createStroke(keybindButton)
        
        local waiting = false
        keybindButton.MouseButton1Click:Connect(function()
            waiting = true
            keybindButton.Text = "..."
        end)
        
        UserInputService.InputBegan:Connect(function(input)
            if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                keybindButton.Text = input.KeyCode.Name
                waiting = false
                if callback then
                    callback(input.KeyCode)
                end
            end
        end)
        
        return keybindFrame
    end
    
    return tab
end

return SimpleUI
