# Buster – Sev.cc UI Library

**Credits:** NotFate!

## Overview

Buster is a powerful and flexible Roblox UI library designed to help you create sleek, modern interfaces with minimal effort. It provides a rich set of components such as windows, tabs, panels, toggles, sliders, dropdowns, buttons, keybinds, labels, and notifications.

---

## Installation

Load the library using the code below:

```lua
local RAW_URL = "https://raw.githubusercontent.com/jujuuufx/CustomUILib/refs/heads/main/uilib.lua"
local Buster = loadstring(game:HttpGet(RAW_URL))()
assert(Buster, "Failed to load UI library from RAW_URL")
```

> **Important:** Always load the UI library at the very top of your script.

---

## Getting Started

### Creating a Window

```lua
local Window = Buster:CreateWindow({
    Name = "Sev.cc",
    Footer = "The Bronx",
    BrandText = "S",
    -- BrandImage = "rbxassetid://0" -- Optional: use an image instead of text
})
```

**Parameters:**

* **Name** *(string)* – Window title
* **Footer** *(string)* – Footer text shown at the bottom
* **BrandText** *(string)* – Short text or single letter for branding
* **BrandImage** *(string, optional)* – Asset ID for a custom brand image

The window is resizable by dragging the bottom-right corner.

* **Minimum size:** `300x200`

---

## Tabs

Organize your UI into sections using tabs:

```lua
local DashboardTab   = Window:CreateTab("Dashboard")
local LocalPlayerTab = Window:CreateTab("Local Player")
local PlayersTab     = Window:CreateTab("Players")
local TeleportsTab   = Window:CreateTab("Teleports / Purchases")
local MiscTab        = Window:CreateTab("Misc")
```

---

## Panels

Panels help organize components inside tabs. Panels can be placed in the **Left** or **Right** column.

```lua
local LeftCard = LocalPlayerTab:CreatePanel({
    Column = "Left",
    Title = "Local Player Modifications"
})

local RightCard = LocalPlayerTab:CreatePanel({
    Column = "Right",
    Title = "Player Options"
})
```

---

## Components

### Label

Display static text with optional color customization:

```lua
RightCard:CreateLabel({
    Text = "Quick actions",
    Color = Color3.fromRGB(150, 152, 160)
})
```

---

### Button

Create clickable buttons with callbacks:

```lua
RightCard:CreateButton({
    Name = "Test Notification",
    Callback = function()
        Window:Notify({
            Title = "Sev.cc",
            Text = "Notification test",
            Duration = 2
        })
    end
})
```

---

### Toggle

Create on/off switches:

```lua
LeftCard:CreateToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(value)
        print("Infinite Stamina:", value)
    end
})
```

**Parameters:**

* **Name** *(string)* – Toggle label
* **Default** *(boolean)* – Initial state
* **Callback** *(function)* – Fired when the value changes

---

### Slider

Create numeric sliders with custom ranges:

```lua
RightCard:CreateSlider({
    Name = "WalkSpeed Value",
    Min = 0,
    Max = 250,
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("WalkSpeed:", value)
    end
})
```

**Parameters:**

* **Name** *(string)* – Slider label
* **Min** *(number)* – Minimum value
* **Max** *(number)* – Maximum value
* **Default** *(number)* – Initial value
* **Increment** *(number)* – Step size
* **Suffix** *(string, optional)* – Text appended to the value
* **Callback** *(function)* – Fired when the value changes

---

### Dropdown

Create dropdown menus with selectable options:

```lua
RightCard:CreateDropdown({
    List = {"Bronx Market 1", "Bronx Market 2", "Bronx Market 3"},
    Default = "Bronx Market 2",
    Callback = function(value)
        print("Selected Market:", value)
    end
})
```

**Parameters:**

* **List** *(table)* – Options to display
* **Default** *(string)* – Initially selected option
* **Callback** *(function)* – Fired on selection change

---

### Keybind

Create customizable keybind inputs:

```lua
RightCard:CreateKeybind({
    Name = "Click Teleport Key",
    Default = Enum.KeyCode.LeftControl,
    Callback = function(key)
        print("Teleport Key changed to:", key)
    end
})
```

**Parameters:**

* **Name** *(string)* – Keybind label
* **Default** *(Enum.KeyCode)* – Initial key
* **Callback** *(function)* – Fired when the key changes

---

## Notifications

Display temporary notifications:

```lua
Window:Notify({
    Title = "Sev.cc",
    Text = "UI Loaded",
    Duration = 2
})
```

**Parameters:**

* **Title** *(string)* – Notification title
* **Text** *(string)* – Message content
* **Duration** *(number)* – Display time (seconds)

---

## Complete Example

```lua
-- Load library
local RAW_URL = "https://raw.githubusercontent.com/jujuuufx/CustomUILib/refs/heads/main/uilib.lua"
local Buster = loadstring(game:HttpGet(RAW_URL))()
assert(Buster, "Failed to load UI library from RAW_URL")

-- Create window
local Window = Buster:CreateWindow({
    Name = "Sev.cc",
    Footer = "The Bronx",
    BrandText = "S",
})

-- Create tab
local LocalPlayerTab = Window:CreateTab("Local Player")

-- Create panels
local LeftCard = LocalPlayerTab:CreatePanel({
    Column = "Left",
    Title = "Local Player Modifications"
})

local RightCard = LocalPlayerTab:CreatePanel({
    Column = "Right",
    Title = "Player Options"
})

-- Add components
LeftCard:CreateToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(value)
        print("Infinite Stamina:", value)
    end
})

RightCard:CreateSlider({
    Name = "WalkSpeed Value",
    Min = 0,
    Max = 250,
    Default = 50,
    Increment = 1,
    Suffix = "%",
    Callback = function(value)
        print("WalkSpeed:", value)
    end
})

-- Notify
Window:Notify({
    Title = "Sev.cc",
    Text = "UI Loaded",
    Duration = 2
})
```

---

## Features

* Modern, clean UI design
* Resizable window (minimum 300x200)
* Left / right column panel layout
* Rich components: toggles, sliders, dropdowns, buttons, keybinds, labels
* Built-in notification system
* Custom branding (text or image)
* Simple and intuitive API

---

## Credits

**NotFate!** – Creator of the Buster UI Library
