-- RobloxUILib: A lightweight and feature-rich UI framework

local UILib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Theme = {
    Background = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Gotham
}

function UILib:SetTheme(newTheme)
    for k, v in pairs(newTheme) do
        if Theme[k] ~= nil then
            Theme[k] = v
        end
    end
end

function UILib:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = config.Title or "CustomUILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, config.Width or 400, 0, config.Height or 300)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BorderSizePixel = 0
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Text = config.Title or "UI Library"
    TitleBar.TextColor3 = Theme.Text
    TitleBar.Font = Theme.Font
    TitleBar.TextSize = 18
    TitleBar.Parent = Frame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Text = "X"
    CloseButton.BackgroundColor3 = Theme.Accent
    CloseButton.TextColor3 = Theme.Text
    CloseButton.Font = Theme.Font
    CloseButton.TextSize = 16
    CloseButton.Parent = Frame
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local TabButtonsFrame = Instance.new("Frame")
    TabButtonsFrame.Size = UDim2.new(0, 100, 1, -30)
    TabButtonsFrame.Position = UDim2.new(0, 0, 0, 30)
    TabButtonsFrame.BackgroundColor3 = Theme.Background
    TabButtonsFrame.BorderSizePixel = 0
    TabButtonsFrame.Parent = Frame

    local TabContentFrame = Instance.new("Frame")
    TabContentFrame.Size = UDim2.new(1, -100, 1, -30)
    TabContentFrame.Position = UDim2.new(0, 100, 0, 30)
    TabContentFrame.BackgroundTransparency = 1
    TabContentFrame.Name = "TabContent"
    TabContentFrame.Parent = Frame

    local tabs = {}

    local function showOnly(tabFrame)
        for _, t in pairs(tabs) do
            t.Frame.Visible = false
        end
        tabFrame.Visible = true
    end

    return {
        CreateTab = function(self, name)
            local TabButton = Instance.new("TextButton")
            TabButton.Size = UDim2.new(1, 0, 0, 30)
            TabButton.BackgroundColor3 = Theme.Accent
            TabButton.TextColor3 = Theme.Text
            TabButton.Font = Theme.Font
            TabButton.TextSize = 14
            TabButton.Text = name
            TabButton.Parent = TabButtonsFrame

            local TabFrame = Instance.new("Frame")
            TabFrame.Size = UDim2.new(1, 0, 1, 0)
            TabFrame.BackgroundTransparency = 1
            TabFrame.Visible = false
            TabFrame.Parent = TabContentFrame

            TabButton.MouseButton1Click:Connect(function()
                showOnly(TabFrame)
            end)

            local index = #tabs + 1
            tabs[index] = { Frame = TabFrame }
            if index == 1 then TabFrame.Visible = true end

            local yOffset = 0
            local function getNextPosition()
                local pos = yOffset
                yOffset = yOffset + 35
                return pos
            end

            return {
                CreateButton = function(cfg)
                    local Button = Instance.new("TextButton")
                    Button.Size = UDim2.new(1, -20, 0, 30)
                    Button.Position = UDim2.new(0, 10, 0, getNextPosition())
                    Button.BackgroundColor3 = Theme.Accent
                    Button.BorderSizePixel = 0
                    Button.Text = cfg.Name or "Button"
                    Button.TextColor3 = Theme.Text
                    Button.Font = Theme.Font
                    Button.TextSize = 14
                    Button.Parent = TabFrame

                    Button.MouseButton1Click:Connect(function()
                        if cfg.Callback then cfg.Callback() end
                    end)
                end,

                CreateToggle = function(cfg)
                    local Toggle = Instance.new("TextButton")
                    Toggle.Size = UDim2.new(1, -20, 0, 30)
                    Toggle.Position = UDim2.new(0, 10, 0, getNextPosition())
                    Toggle.BackgroundColor3 = Theme.Accent
                    Toggle.BorderSizePixel = 0
                    Toggle.Text = "[ OFF ] " .. (cfg.Name or "Toggle")
                    Toggle.TextColor3 = Theme.Text
                    Toggle.Font = Theme.Font
                    Toggle.TextSize = 14
                    Toggle.Parent = TabFrame

                    local state = cfg.Default or false

                    Toggle.MouseButton1Click:Connect(function()
                        state = not state
                        Toggle.Text = (state and "[ ON  ] " or "[ OFF ] ") .. (cfg.Name or "Toggle")
                        if cfg.Callback then cfg.Callback(state) end
                    end)
                end,

                CreateSlider = function(cfg)
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -20, 0, 20)
                    Label.Position = UDim2.new(0, 10, 0, getNextPosition())
                    Label.BackgroundTransparency = 1
                    Label.Text = (cfg.Name or "Slider") .. ": " .. tostring(cfg.Default or cfg.Min)
                    Label.TextColor3 = Theme.Text
                    Label.Font = Theme.Font
                    Label.TextSize = 14
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = TabFrame

                    local Slider = Instance.new("TextButton")
                    Slider.Size = UDim2.new(1, -20, 0, 20)
                    Slider.Position = UDim2.new(0, 10, 0, getNextPosition())
                    Slider.BackgroundColor3 = Theme.Accent
                    Slider.Text = ""
                    Slider.AutoButtonColor = false
                    Slider.Parent = TabFrame

                    local Handle = Instance.new("Frame")
                    Handle.Size = UDim2.new(0, 10, 1, 0)
                    Handle.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                    Handle.Parent = Slider

                    local dragging = false

                    local function updateValue(x)
                        local rel = math.clamp((x - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                        Handle.Position = UDim2.new(rel, -5, 0, 0)
                        local val = math.floor(((cfg.Max - cfg.Min) * rel + cfg.Min) * 100) / 100
                        Label.Text = (cfg.Name or "Slider") .. ": " .. tostring(val)
                        if cfg.Callback then cfg.Callback(val) end
                    end

                    Slider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                        end
                    end)
                    Slider.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            updateValue(input.Position.X)
                        end
                    end)

                    updateValue((cfg.Default or cfg.Min) - cfg.Min / (cfg.Max - cfg.Min))
                end,

                CreateKeybind = function(cfg)
                    local Keybind = Instance.new("TextButton")
                    Keybind.Size = UDim2.new(1, -20, 0, 30)
                    Keybind.Position = UDim2.new(0, 10, 0, getNextPosition())
                    Keybind.BackgroundColor3 = Theme.Accent
                    Keybind.BorderSizePixel = 0
                    Keybind.TextColor3 = Theme.Text
                    Keybind.Font = Theme.Font
                    Keybind.TextSize = 14
                    Keybind.Text = (cfg.Name or "Keybind") .. ": None"
                    Keybind.Parent = TabFrame

                    local waitingForBind = false
                    Keybind.MouseButton1Click:Connect(function()
                        waitingForBind = true
                        Keybind.Text = (cfg.Name or "Keybind") .. ": ..."
                    end)

                    UserInputService.InputBegan:Connect(function(input, processed)
                        if waitingForBind and not processed then
                            waitingForBind = false
                            local key = input.KeyCode.Name
                            Keybind.Text = (cfg.Name or "Keybind") .. ": " .. key
                            if cfg.Callback then cfg.Callback(key) end
                        end
                    end)
                end
            }
        end
    }
end

return UILib
