# Nova — UI Library

Overview
Nova is a lightweight, flexible Roblox UI library providing windows, tabs, panels and common controls (buttons, toggles, sliders, dropdowns, keybinds, labels, notifications) for building modern interfaces quickly.

Installation
Load the library at the top of your script:

```lua
local RAW_URL = "https://raw.githubusercontent.com/jujuuufx/CustomUILib/refs/heads/main/uilib.lua"
local Nova = loadstring(game:HttpGet(RAW_URL))()
assert(Nova, "Failed to load UI library from RAW_URL")
```

Important: Always require/load Nova at the top of your script.

Getting started

Create a window:

```lua
local Window = Nova:CreateWindow({
    Name = "Nova UI",
    Footer = "",
    BrandText = "N",
    -- BrandImage = "rbxassetid://0" -- optional
})
```

Window notes
- Resizable (drag bottom-right)
- Minimum size: 300 × 200

Tabs

```lua
local DashboardTab = Window:CreateTab("Dashboard")
local LocalPlayerTab = Window:CreateTab("Local Player")
```

Panels
Panels organize components inside tabs and can be placed in "Left" or "Right" columns:

```lua
local LeftCard = LocalPlayerTab:CreatePanel({ Column = "Left", Title = "Local Player Modifications" })
local RightCard = LocalPlayerTab:CreatePanel({ Column = "Right", Title = "Player Options" })
```

Components

Label
```lua
RightCard:CreateLabel({ Text = "Quick actions", Color = Color3.fromRGB(150,152,160) })
```
- Text (string)
- Color (Color3, optional)

Button
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

Toggle
```lua
LeftCard:CreateToggle({
  Name = "Infinite Stamina",
  Default = false,
  Callback = function(value) print("Infinite Stamina:", value) end
})
```
- Name (string), Default (boolean), Callback (function)

Slider
```lua
RightCard:CreateSlider({
  Name = "WalkSpeed Value",
  Min = 0, Max = 250, Default = 50, Increment = 1, Suffix = "%",
  Callback = function(value) print("WalkSpeed:", value) end
})
```
- Name, Min, Max, Default, Increment, Suffix (optional), Callback

Dropdown
```lua
RightCard:CreateDropdown({
  List = {"Option 1","Option 2","Option 3"},
  Default = "Option 2",
  Callback = function(value) print("Selected:", value) end
})
```
- List (table), Default (string), Callback

Keybind
```lua
RightCard:CreateKeybind({
  Name = "Click Teleport Key",
  Default = Enum.KeyCode.LeftControl,
  Callback = function(key) print("Key:", key) end
})
```
- Name, Default (Enum.KeyCode), Callback

Notifications
```lua
Window:Notify({ Title = "Nova UI", Text = "UI Loaded", Duration = 2 })
```
- Title, Text, Duration (seconds)

Complete example
```lua
local RAW_URL = "https://raw.githubusercontent.com/jujuuufx/CustomUILib/refs/heads/main/uilib.lua"
local Nova = loadstring(game:HttpGet(RAW_URL))()
assert(Nova)

local Window = Nova:CreateWindow({ Name = "Nova UI", Footer = "", BrandText = "N" })
local LocalPlayerTab = Window:CreateTab("Local Player")

local LeftCard = LocalPlayerTab:CreatePanel({ Column = "Left", Title = "Local Player Modifications" })
local RightCard = LocalPlayerTab:CreatePanel({ Column = "Right", Title = "Player Options" })

LeftCard:CreateToggle({ Name = "Infinite Stamina", Default = false, Callback = function(v) print("Infinite Stamina:", v) end })
RightCard:CreateSlider({ Name = "WalkSpeed Value", Min = 0, Max = 250, Default = 50, Increment = 1, Suffix = "%", Callback = function(v) print("WalkSpeed:", v) end })

Window:Notify({ Title = "Nova UI", Text = "UI Loaded", Duration = 2 })
```
