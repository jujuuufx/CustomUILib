-- UI Library ModuleScript
-- Name this script "UILibrary" and place it as a ModuleScript in ReplicatedStorage or ServerScriptService

local UILibrary = {}

-- Helper function to create a basic frame with nice styling
function UILibrary.CreateFrame(parent, name, size, position, backgroundColor, borderColor)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size or UDim2.new(0, 200, 0, 100)
    frame.Position = position or UDim2.new(0.5, 0, 0.5, 0)
    frame.BackgroundColor3 = backgroundColor or Color3.fromRGB(40, 40, 40)
    frame.BorderColor3 = borderColor or Color3.fromRGB(60, 60, 60)
    frame.BorderSizePixel = 1
    frame.Parent = parent
    
    -- Add corner rounding for a nicer look
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Add shadow effect using UIStroke and UIGradient (simple glow)
    local stroke = Instance.new("UIStroke")
    stroke.Transparency = 0.5
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    return frame
end

-- Function to create a button with hover effect
function UILibrary.CreateButton(parent, text, size, position, callback)
    local button = Instance.new("TextButton")
    button.Name = text
    button.Text = text
    button.Size = size or UDim2.new(0, 150, 0, 50)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = parent
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    -- Click event
    button.MouseButton1Click:Connect(callback or function() end)
    
    return button
end

-- Function to create a label
function UILibrary.CreateLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.Name = text
    label.Text = text
    label.Size = size or UDim2.new(0, 150, 0, 30)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = parent
    
    return label
end

-- Function to create a simple window (draggable frame)
function UILibrary.CreateWindow(title, size, position)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UILibraryWindow"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local window = UILibrary.CreateFrame(screenGui, title, size, position, Color3.fromRGB(30, 30, 30))
    
    -- Title bar
    local titleBar = UILibrary.CreateFrame(window, "TitleBar", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Color3.fromRGB(50, 50, 50))
    local titleLabel = UILibrary.CreateLabel(titleBar, title, UDim2.new(1, 0, 1, 0), UDim2.new(0, 10, 0, 0))
    
    -- Make window draggable
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
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
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Content frame inside window
    local content = UILibrary.CreateFrame(window, "Content", UDim2.new(1, 0, 1, -30), UDim2.new(0, 0, 0, 30), Color3.fromRGB(30, 30, 30))
    content.BorderSizePixel = 0
    
    return content, window
end

return UILibrary
