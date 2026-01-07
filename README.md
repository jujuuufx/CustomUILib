# Nova — UI Library

## Overview
Nova is a lightweight, flexible Roblox UI library providing windows, tabs, panels and common controls (buttons, toggles, sliders, dropdowns, keybinds, textboxes, labels, notifications) for building modern interfaces quickly. It also supports saving and loading configurations for UI elements.

## Installation
Load the library at the top of your script:
```lua
local RAW_URL = "https://raw.githubusercontent.com/jujuuufx/CustomUILib/refs/heads/main/uilib.lua"
local Nova = loadstring(game:HttpGet(RAW_URL))()
assert(Nova, "Failed to load UI library from RAW_URL")
```
Important: Always require/load Nova at the top of your script.

## Getting started
Create a window:
```lua
local Window = Nova:CreateWindow({
    Name = "Nova UI",
    Footer = "",
    BrandText = "N",
    -- BrandImage = "rbxassetid://0" -- optional
    -- Config = false -- optional, default true to enable Config tab
})
```
Window notes
- Resizable (drag bottom-right)
- Minimum size: 300 × 200

## Tabs
```lua
local DashboardTab = Window:CreateTab("Dashboard")
local LocalPlayerTab = Window:CreateTab("Local Player")
```

## Panels
Panels organize components inside tabs and can be placed in "Left" or "Right" columns:
```lua
local LeftCard = LocalPlayerTab:CreatePanel({ Column = "Left", Title = "Local Player Modifications" })
local RightCard = LocalPlayerTab:CreatePanel({ Column = "Right", Title = "Player Options" })
```

## Components
### Label
```lua
RightCard:CreateLabel({ Text = "Quick actions", Color = Color3.fromRGB(150,152,160) })
```
- Text (string)
- Color (Color3, optional)

### Button
```lua
RightCard:CreateButton({
  Name = "Test Notification",
  Callback = function()
    Window:Notify({ Title = "Nova UI", Text = "Notification test", Duration = 2 })
  end
})
```
- Name (string)
- Callback (function)

### Toggle
```lua
LeftCard:CreateToggle({
  Name = "Infinite Stamina",
  Default = false,
  ConfigKey = "InfiniteStamina", -- optional, to include in config saving/loading
  Callback = function(value) print("Infinite Stamina:", value) end
})
```
- Name (string), Default (boolean), ConfigKey (string, optional), Callback (function)

### Slider
```lua
RightCard:CreateSlider({
  Name = "WalkSpeed Value",
  Min = 0, Max = 250, Default = 50, Increment = 1, Suffix = "%",
  ConfigKey = "WalkSpeed", -- optional
  Callback = function(value) print("WalkSpeed:", value) end
})
```
- Name, Min, Max, Default, Increment, Suffix (optional), ConfigKey (string, optional), Callback

### Dropdown
```lua
RightCard:CreateDropdown({
  List = {"Option 1","Option 2","Option 3"},
  Default = "Option 2",
  ConfigKey = "SelectedOption", -- optional
  Callback = function(value) print("Selected:", value) end
})
```
- List (table), Default (string), ConfigKey (string, optional), Callback

### Keybind
```lua
RightCard:CreateKeybind({
  Name = "Click Teleport Key",
  Default = Enum.KeyCode.LeftControl,
  ConfigKey = "TeleportKey", -- optional
  Callback = function(key) print("Key:", key) end
})
```
- Name, Default (Enum.KeyCode), ConfigKey (string, optional), Callback

### Textbox
```lua
RightCard:CreateTextbox({
  Name = "Enter Text",
  Default = "Default text",
  ConfigKey = "UserInput", -- optional
  Callback = function(text) print("Entered:", text) end
})
```
- Name (string), Default (string), ConfigKey (string, optional), Callback (function, called on FocusLost with enter)

## Notifications
```lua
Window:Notify({ Title = "Nova UI", Text = "UI Loaded", Duration = 2 })
```
- Title, Text, Duration (seconds)

## Configuration
Nova supports saving and loading configurations for UI elements that have a `ConfigKey` specified. Configurations are stored as JSON files in a folder named `NovaConfigs/<PlaceId>/` (e.g., `NovaConfigs/1234567890/Default.json`).

To enable the Config tab (enabled by default):
- Pass `Config = true` (or omit) in `CreateWindow` options.

The Config tab includes:
- **Config Name**: Textbox to enter or select a config name.
- **Existing Configs**: Dropdown of saved configs.
- **Refresh List**: Button to update the dropdown with existing configs.
- **Save Config**: Saves current element values to a JSON file.
- **Load Config**: Loads values from the selected config file into elements.
- **Delete Config**: Deletes the selected config file.

Elements with `ConfigKey` (e.g., toggles, sliders, dropdowns, keybinds, textboxes) will have their values saved/loaded. Use unique keys across the UI.

Requires file system functions (`makefolder`, `isfolder`, `writefile`, `readfile`, `isfile`, `delfile`, `listfiles`) and `HttpService` for JSON handling.

## Complete example
```lua
local RAW_URL = "https://raw.githubusercontent.com/jujuuufx/CustomUILib/refs/heads/main/uilib.lua"
local Nova = loadstring(game:HttpGet(RAW_URL))()
assert(Nova)
local Window = Nova:CreateWindow({ Name = "Nova UI", Footer = "", BrandText = "N" })
local LocalPlayerTab = Window:CreateTab("Local Player")
local LeftCard = LocalPlayerTab:CreatePanel({ Column = "Left", Title = "Local Player Modifications" })
local RightCard = LocalPlayerTab:CreatePanel({ Column = "Right", Title = "Player Options" })
LeftCard:CreateToggle({ Name = "Infinite Stamina", Default = false, ConfigKey = "InfiniteStamina", Callback = function(v) print("Infinite Stamina:", v) end })
RightCard:CreateSlider({ Name = "WalkSpeed Value", Min = 0, Max = 250, Default = 50, Increment = 1, Suffix = "%", ConfigKey = "WalkSpeed", Callback = function(v) print("WalkSpeed:", v) end })
Window:Notify({ Title = "Nova UI", Text = "UI Loaded", Duration = 2 })
```
