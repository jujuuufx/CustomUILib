-- RobloxUILib: A lightweight UI framework

local UILib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Create a draggable window
function UILib:CreateWindow(config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = config.Title or "CustomUILib"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, config.Width or 350, 0, config.Height or 250)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -125)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Frame.BorderSizePixel = 0
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Text = config.Title or "UI Library"
    TitleBar.TextColor3 = Color3.new(1, 1, 1)
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.TextSize = 18
    TitleBar.Parent = Frame

    local Container = Instance.new("Frame")
    Container.Position = UDim2.new(0, 0, 0, 30)
    Container.Size = UDim2.new(1, 0, 1, -30)
    Container.BackgroundTransparency = 1
    Container.Name = "Container"
    Container.Parent = Frame

    return {
        CreateButton = function(self, cfg)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -20, 0, 30)
            Button.Position = UDim2.new(0, 10, 0, #Container:GetChildren() * 35)
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Button.BorderSizePixel = 0
            Button.Text = cfg.Name or "Button"
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 14
            Button.AutoButtonColor = true
            Button.Parent = Container

            Button.MouseButton1Click:Connect(function()
                if cfg.Callback then cfg.Callback() end
            end)
        end,

        CreateToggle = function(self, cfg)
            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(1, -20, 0, 30)
            Toggle.Position = UDim2.new(0, 10, 0, #Container:GetChildren() * 35)
            Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Toggle.BorderSizePixel = 0
            Toggle.Text = "[ OFF ] " .. (cfg.Name or "Toggle")
            Toggle.TextColor3 = Color3.new(1, 1, 1)
            Toggle.Font = Enum.Font.Gotham
            Toggle.TextSize = 14
            Toggle.AutoButtonColor = true
            Toggle.Parent = Container

            local state = cfg.Default or false

            Toggle.MouseButton1Click:Connect(function()
                state = not state
                Toggle.Text = (state and "[ ON  ] " or "[ OFF ] ") .. (cfg.Name or "Toggle")
                if cfg.Callback then cfg.Callback(state) end
            end)
        end
    }
end

return UILib
