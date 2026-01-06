# SimpleUI Library

## Overview

SimpleUI is a lightweight, customizable UI library for Roblox scripts. It provides an easy way to create graphical user interfaces for your Roblox exploits, scripts, or games. The library supports **windows with tabs, sections, and various UI elements** like toggles, buttons, sliders, textboxes, dropdowns, labels, and keybinds.

It includes modern features such as:

* Theming support (default dark mode)
* Notifications
* Draggable windows
* Minimize/close buttons
* Smooth animations using TweenService

### Key Highlights

* **Lightweight:** Minimal dependencies, built with native Roblox instances.
* **Customizable:** Supports custom themes and sizes.
* **Responsive:** Draggable, minimizable, and scrollable content.
* **Elements:** Toggles, buttons, sliders, textboxes, dropdowns, labels, keybinds, and sections.
* **Extras:** Notification system, visibility toggle via keybind.

## Features

* Create draggable and resizable windows
* Add tabs for organized content
* Group elements into sections
* Built-in theme support with default dark mode
* Notification pop-ups
* Toggle UI visibility with a keybind
* Smooth transitions and hover effects
* Auto-resizing scroll frames for dynamic content

## Installation

SimpleUI can be loaded directly into your Roblox script using `loadstring`.

```lua
local SimpleUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourrepo/main/simpleui.lua"))()
```

* Replace the URL with the raw link to your library script.
* If using a **ModuleScript** in Roblox Studio, you can `require()` it instead.

## Usage

### Creating a Window

```lua
local Window = SimpleUI:CreateWindow("My Script Hub", UDim2.new(0, 500, 0, 400))
```

Optional parameters:

* `title` (string): Window title
* `size` (UDim2, default: 400x300)
* `theme` (table, optional): Custom theme

### Setting a Theme

Customize colors before creating the window:

```lua
local customTheme = {
    Background = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(255, 100, 100),
    Text = Color3.fromRGB(240, 240, 240),
    Border = Color3.fromRGB(60, 60, 60),
    Shadow = Color3.fromRGB(0, 0, 0),
    Hover = Color3.fromRGB(40, 40, 40)
}

SimpleUI:SetTheme(customTheme)
```

### Toggling Visibility

```lua
Window:ToggleVisibility(Enum.KeyCode.RightShift)
```

### Notifications

```lua
SimpleUI:Notify("Welcome to My Script!", 5)  -- Text, duration in seconds
```

### Creating Tabs

```lua
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")
```

### Adding Elements to Tabs

#### Sections

```lua
local section = MainTab:AddSection("Player Controls")
-- Add elements to 'section' instead of 'MainTab'
```

#### Toggle

```lua
MainTab:AddToggle("God Mode", false, function(state)
    print("God Mode:", state)
end)
```

#### Button

```lua
MainTab:AddButton("Teleport to Spawn", function()
    print("Teleporting...")
end)
```

#### Slider

```lua
MainTab:AddSlider("Walk Speed", 16, 100, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```

#### Textbox

```lua
MainTab:AddTextbox("Player Name", "Username", function(text)
    print("Entered:", text)
end)
```

#### Dropdown

```lua
MainTab:AddDropdown("Select Team", {"Red", "Blue", "Green"}, "Red", function(selected)
    print("Team:", selected)
end)
```

#### Label

```lua
MainTab:AddLabel("Status: Online")
```

#### Keybind

```lua
MainTab:AddKeybind("Fly Key", Enum.KeyCode.F, function(key)
    print("New Fly Key:", key.Name)
end)
```

## Example Script: Infinite Jump Toggle

```lua
-- Load the UI library
local SimpleUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourrepo/main/simpleui.lua"))()

-- Create the main window
local Window = SimpleUI:CreateWindow("Example Hub", UDim2.new(0, 400, 0, 300))

-- Create a tab
local MovementTab = Window:CreateTab("Movement")

-- Infinite Jump toggle variable
local infJumpEnabled = false

-- Function to handle infinite jump
local function onJumpRequest()
    if infJumpEnabled then
        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- Connect UserInputService to jump
local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(onJumpRequest)

-- Add the toggle to the tab
MovementTab:AddToggle("Infinite Jump", false, function(state)
    infJumpEnabled = state
    print("Infinite Jump is now", state)
    SimpleUI:Notify("Infinite Jump " .. (state and "Enabled" or "Disabled"), 3)
end)

-- Add more elements
MovementTab:AddSlider("Jump Power", 50, 200, 50, function(value)
    local Player = game.Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    Humanoid.JumpPower = value
end)

-- Toggle visibility
Window:ToggleVisibility(Enum.KeyCode.RightShift)
```

## API Reference

### SimpleUI Methods

* `CreateWindow(title, size, theme)` – Creates and returns a window object
* `SetTheme(theme)` – Sets a global theme
* `Notify(text, duration)` – Shows a notification

### Window Methods

* `ToggleVisibility(keyCode)` – Binds a key to toggle visibility
* `CreateTab(name)` – Creates and returns a tab object

### Tab Methods

* `AddSection(name)` – Returns a frame for grouping elements
* `AddToggle(name, default, callback)`
* `AddButton(name, callback)`
* `AddSlider(name, min, max, default, callback)`
* `AddTextbox(name, default, callback)`
* `AddDropdown(name, options, default, callback)`
* `AddLabel(text)`
* `AddKeybind(name, default, callback)
