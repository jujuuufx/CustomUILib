--// ===============================
--// NebulaUI v2
--// Advanced Roblox Exploit UI
--// ===============================

local NebulaUI = {}
NebulaUI.__index = NebulaUI

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

--// ===============================
--// THEME
--// ===============================
local Theme = {
    Background = Color3.fromRGB(18,18,24),
    Panel = Color3.fromRGB(24,24,32),
    Accent = Color3.fromRGB(120,95,255),
    Text = Color3.fromRGB(235,235,240),
    SubText = Color3.fromRGB(160,160,175)
}

--// ===============================
--// UTILS
--// ===============================
local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    return obj
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

--// ===============================
--// BLUR / ACRYLIC
--// ===============================
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local function SetBlur(state)
    Tween(Blur, {Size = state and 16 or 0}, 0.3)
end

--// ===============================
--// CONFIG SYSTEM
--// ===============================
local Configs = {}
local ConfigFile = "NebulaUI_Config.json"

local function SaveConfig()
    writefile(ConfigFile, HttpService:JSONEncode(Configs))
end

local function LoadConfig()
    if isfile(ConfigFile) then
        Configs = HttpService:JSONDecode(readfile(ConfigFile))
    end
end

LoadConfig()

--// ===============================
--// NOTIFICATIONS
--// ===============================
function NebulaUI:Notify(text, duration)
    local gui = CoreGui:FindFirstChild("NebulaNotify") or Create("ScreenGui", {
        Name = "NebulaNotify",
        Parent = CoreGui
    })

    local frame = Create("Frame", {
        Size = UDim2.fromOffset(260, 60),
        Position = UDim2.fromScale(1,1),
        AnchorPoint = Vector2.new(1,1),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = gui
    })

    Create("UICorner", {CornerRadius = UDim.new(0,12), Parent = frame})

    Create("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextWrapped = true,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,-20),
        Position = UDim2.fromOffset(10,10),
        Parent = frame
    })

    Tween(frame, {Position = UDim2.fromScale(1,-0.02)}, 0.25)

    task.delay(duration or 2, function()
        Tween(frame, {Position = UDim2.fromScale(1,1)}, 0.25)
        task.wait(0.3)
        frame:Destroy()
    end)
end

--// ===============================
--// WINDOW
--// ===============================
function NebulaUI:CreateWindow(cfg)
    local Window = {}
    setmetatable(Window, self)

    SetBlur(true)

    local Gui = Create("ScreenGui", {
        Name = "NebulaUI",
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    local Main = Create("Frame", {
        Size = cfg.Size or UDim2.fromOffset(600,420),
        Position = cfg.Position or UDim2.fromScale(0.5,0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = Gui
    })

    Create("UICorner", {CornerRadius = UDim.new(0,16), Parent = Main})

    -- Drag
    local dragging, startPos, dragStart
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Tabs
    local TabBar = Create("Frame", {
        Size = UDim2.new(0,140,1,0),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        Parent = Main
    })

    local Content = Create("Frame", {
        Position = UDim2.fromOffset(140,0),
        Size = UDim2.new(1,-140,1,0),
        BackgroundTransparency = 1,
        Parent = Main
    })

    Window.Tabs = {}

    function Window:CreateTab(name)
        local Tab = {}
        local Button = Create("TextButton", {
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Theme.SubText,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,0,36),
            Parent = TabBar
        })

        local Page = Create("UIListLayout", {
            Padding = UDim.new(0,10),
            Parent = Create("Frame", {
                Size = UDim2.fromScale(1,1),
                Visible = false,
                BackgroundTransparency = 1,
                Parent = Content
            })
        })

        Button.MouseButton1Click:Connect(function()
            for _,t in pairs(Window.Tabs) do
                t.Page.Parent.Visible = false
                t.Button.TextColor3 = Theme.SubText
            end
            Page.Parent.Visible = true
            Button.TextColor3 = Theme.Text
        end)

        table.insert(Window.Tabs, {Button = Button, Page = Page})

        if #Window.Tabs == 1 then
            Page.Parent.Visible = true
            Button.TextColor3 = Theme.Text
        end

        -- ===============================
        -- SECTION
        -- ===============================
        function Tab:CreateSection(title)
            local Section = {}
            local Frame = Create("Frame", {
                Size = UDim2.new(1,-20,0,40),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Panel,
                BorderSizePixel = 0,
                Parent = Page.Parent
            })
            Create("UICorner",{CornerRadius=UDim.new(0,12),Parent=Frame})

            Create("TextLabel",{
                Text=title,Font=Enum.Font.GothamBold,TextSize=14,
                TextColor3=Theme.Text,BackgroundTransparency=1,
                Position=UDim2.fromOffset(10,8),
                Size=UDim2.new(1,-20,0,20),
                Parent=Frame
            })

            local Layout = Create("UIListLayout",{
                Padding=UDim.new(0,8),
                Parent=Frame
            })

            -- ===============================
            -- TOGGLE
            -- ===============================
            function Section:CreateToggle(cfg)
                local state = cfg.Default or false
                Configs[cfg.Name] = Configs[cfg.Name] ?? state

                local Toggle = Create("Frame", {
                    Size = UDim2.new(1,-20,0,32),
                    BackgroundTransparency = 1,
                    Parent = Frame
                })

                local Switch = Create("Frame", {
                    Size = UDim2.fromOffset(44,22),
                    Position = UDim2.fromScale(1,0.5),
                    AnchorPoint = Vector2.new(1,0.5),
                    BackgroundColor3 = Theme.Panel,
                    Parent = Toggle
                })
                Create("UICorner",{CornerRadius=UDim.new(1,0),Parent=Switch})

                local Knob = Create("Frame", {
                    Size = UDim2.fromOffset(18,18),
                    Position = state and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2),
                    BackgroundColor3 = state and Theme.Accent or Theme.SubText,
                    Parent = Switch
                })
                Create("UICorner",{CornerRadius=UDim.new(1,0),Parent=Knob})

                Toggle.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        state = not state
                        Configs[cfg.Name] = state
                        SaveConfig()

                        Tween(Knob,{
                            Position = state and UDim2.fromOffset(24,2) or UDim2.fromOffset(2,2),
                            BackgroundColor3 = state and Theme.Accent or Theme.SubText
                        })
                        cfg.Callback(state)
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return NebulaUI
