# 🌌 NebulaUI v2

*A modern, powerful Roblox exploit UI library*

NebulaUI is a custom-built Roblox UI library focused on **clean
visuals**, **smooth animations**, and **real usability**.\
Designed to replace common libraries like Rayfield, Venyx, CascadeUI,
etc.

------------------------------------------------------------------------

## ✨ Features

-   🎨 Modern dark / glass UI
-   🪟 Draggable window
-   📑 Tab system
-   📦 Sections
-   🔘 Animated toggles
-   🎚️ Sliders with fill bar
-   📂 Dropdowns
-   ⌨️ Keybind picker
-   🔔 Notification system
-   🎨 Live theme editor
-   🌫️ Blur / acrylic background
-   💾 Config save & load system
-   ⚡ Optimized for exploit usage

------------------------------------------------------------------------

## 📥 Loading the Library (IMPORTANT)

**Always load NebulaUI at the TOP of your script**

``` lua
local NebulaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/jujuuufx/CustomUILib/refs/heads/main/uilib.lua"))()
```

------------------------------------------------------------------------

## 🪟 Creating a Window

``` lua
local Window = NebulaUI:CreateWindow({
    Title = "Nebula Hub",
    Size = UDim2.new(0, 600, 0, 420),
    Position = UDim2.new(0.5, -300, 0.5, -210)
})
```

------------------------------------------------------------------------

## 📑 Creating Tabs

``` lua
local CombatTab = Window:CreateTab("Combat")
local VisualTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")
```

------------------------------------------------------------------------

## 📦 Creating Sections

``` lua
local DefenseSection = CombatTab:CreateSection("Defense")
```

------------------------------------------------------------------------

## 🔘 Toggle (Animated Switch)

``` lua
DefenseSection:CreateToggle({
    Name = "Auto Perfect Block",
    Default = false,
    Callback = function(value)
        print(value)
    end
})
```

------------------------------------------------------------------------

## 🎚️ Slider

``` lua
MovementSection:CreateSlider({
    Name = "WalkSpeed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print(value)
    end
})
```

------------------------------------------------------------------------

## 📂 Dropdown

``` lua
SettingsSection:CreateDropdown({
    Name = "Target Mode",
    Options = {"Closest", "Lowest HP", "FOV"},
    Default = "Closest",
    Callback = function(option)
        print(option)
    end
})
```

------------------------------------------------------------------------

## ⌨️ Keybind Picker

``` lua
SettingsSection:CreateKeybind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print(key)
    end
})
```

------------------------------------------------------------------------

## 🔔 Notifications

``` lua
NebulaUI:Notify("UI Loaded Successfully", 2)
```

------------------------------------------------------------------------

## 🎨 Theme Editor

``` lua
NebulaUI:SetTheme({
    Accent = Color3.fromRGB(255, 80, 80),
    Background = Color3.fromRGB(15, 15, 20)
})
```

------------------------------------------------------------------------

## 🌫️ Blur / Acrylic Effect

``` lua
NebulaUI:SetBlur(true)
NebulaUI:SetBlur(false)
```

------------------------------------------------------------------------

## 💾 Config System

Automatically saves & loads settings.

Config file:

    NebulaUI_Config.json

------------------------------------------------------------------------

## ⚠️ Notes

-   Requires exploit functions (`writefile`, `readfile`)
-   Uses CoreGui
-   Not intended for Roblox Studio

------------------------------------------------------------------------

## 🚀 Credits

NebulaUI by Xacks
