# UniUI: Universal Compact UI Library for Roblox

## Overview

UniUI is a lightweight, responsive, and user-friendly UI library for Roblox, designed for creating modern graphical user interfaces in scripts. It is an enhanced version of the original Sev.cc UI Library, optimized for universality, compactness, and better usability. UniUI supports draggable windows, tabs, panels, and various interactive elements like toggles, sliders, buttons, keybinds, and dropdowns. It features a dark theme, responsive design for mobile and desktop, notifications, and automatic resizing.

Key improvements over the original:
- Simplified API for easier integration.
- More compact code structure with optimized performance.
- Enhanced responsiveness for different screen sizes.
- Better error handling and backward compatibility.
- Universal naming and structure for broader use cases.

## Features

- **Responsive Design**: Automatically adjusts for mobile, tablet, and desktop viewports.
- **Draggable Windows**: Easy window movement with smooth animations.
- **Tabs and Panels**: Organize content into tabs and collapsible panels.
- **Interactive Elements**: Toggles, buttons, sliders, keybinds, dropdowns, labels, and dividers.
- **Notifications**: Display toast notifications with customizable duration.
- **Theming**: Built-in dark theme with customizable colors.
- **Keybind Support**: Global UI toggle keybind (default: RightShift).
- **Outside Toggle Button**: Always-visible button to show/hide the UI.
- **User Profile Integration**: Displays Roblox avatar and username.
- **Overlay Support**: For elements like dropdowns to appear above everything.

## Installation

1. **Copy the Script**: Paste the UniUI script into your Roblox script (e.g., LocalScript in StarterGui or a ModuleScript).
   
   ```lua
   -- Example: Load UniUI in your script
   local UniUI = loadstring(game:HttpGet("https://your-pastebin-or-github-raw-url/uniui.lua"))()  -- Or require(ModuleScript)
   ```

2. **Requirements**: This library uses Roblox services like TweenService, UserInputService, Players, CoreGui, and GuiService. No external dependencies needed.

3. **Protection**: The library automatically protects the GUI using `syn.protect_gui` if available, or falls back to `gethui()` or CoreGui.

## Basic Usage

Create a window and add elements step-by-step.

### Creating a Window

```lua
local window = UniUI:CreateWindow({
    Name = "My UI",          -- Window title
    Subtitle = "Description", -- Subtitle text
    Footer = "Footer Text",   -- Footer (defaults to subtitle)
    Brand = "M",              -- Brand text (or use BrandImage for an image)
    -- BrandImage = "rbxassetid://1234567890", -- Optional brand image
    Size = {Width = 860, Height = 480}, -- Optional fixed size (otherwise responsive)
    ToggleKey = Enum.KeyCode.RightShift -- Default toggle key
})
```

- The window appears centered and can be dragged via the top bar.
- Use `window:Toggle()` to show/hide programmatically.
- Minimize button slides the window down; close button hides it.

### Adding Tabs

Tabs organize content. Create tabs within the window.

```lua
local tab = window:CreateTab({
    Name = "Main Tab",
    Icon = "rbxassetid://1234567890" -- Optional icon
})
```

- First tab is selected by default.
- Tabs appear in the sidebar.

### Adding Panels/Sections

Panels (or sections) are containers for elements. Place them in left or right columns.

```lua
local panel = tab:Panel({
    Title = "Settings Panel",
    Icon = "rbxassetid://9876543210", -- Optional
    Column = "Left" -- "Left" (default) or "Right"
})

-- Backward compatible: tab:Section("Section Title") creates a left-column panel
local section = tab:Section("Quick Section")
```

### Adding Elements to Panels

UniUI supports various elements:

#### Toggle

```lua
local toggle = panel:Toggle({
    Name = "Enable Feature",
    Icon = "rbxassetid://111222333", -- Optional
    Default = false,
    Callback = function(state)
        print("Toggle state:", state)
    end
})

toggle.Set(true)  -- Set value
print(toggle.Get())  -- Get value
```

#### Label

```lua
local label = panel:Label({
    Text = "Info: This is a label",
    Size = 12,       -- Optional
    Bold = true,     -- Optional
    Color = Color3.fromRGB(255, 0, 0), -- Optional
    AlignRight = false, -- Optional
    Height = 22      -- Optional row height
})

-- Simple string shortcut
panel:Label("Simple Label")
```

#### Button

```lua
local button = panel:Button({
    Name = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
```

#### Slider

```lua
local slider = panel:Slider({
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 5,   -- Step size
    Suffix = "%",    -- Display suffix
    Callback = function(value)
        print("Slider value:", value)
    end
})

slider.Set(75)  -- Set value
print(slider.Get())  -- Get value
```

#### Keybind

```lua
local keybind = panel:Keybind({
    Name = "Action Key",
    Icon = "rbxassetid://444555666", -- Optional
    Default = Enum.KeyCode.E,
    Callback = function(key)
        print("New key:", key and key.Name or "None")
    end
})

keybind.Set(Enum.KeyCode.F)  -- Set key (or nil to clear)
print(keybind.Get())  -- Get key (EnumItem or nil)
```

- Supports keyboard keys and mouse buttons (Mouse1/Mouse2).

#### Dropdown

```lua
local dropdown = panel:Dropdown({
    Label = "Choose Option", -- Optional left label
    List = {"Option1", "Option2", "Option3"},
    Default = "Option1",
    Callback = function(selected)
        print("Selected:", selected)
    end
})

dropdown.Set("Option2")  -- Set value
dropdown.Update({"New1", "New2"})  -- Update list
print(dropdown.Get())  -- Get value
```

#### Divider

```lua
panel:Divider()  -- Adds a horizontal separator
```

### Notifications

Display toast notifications.

```lua
window:Notify({
    Title = "Alert",
    Text = "Something happened!",
    Duration = 3  -- Seconds (default: 2.5)
})
```

### Customization

- **Set Title/Footer/Brand**:
  ```lua
  window:SetTitle("New Title")
  window:SetFooter("New Footer")
  window:SetBrand("New Brand")
  window:SetBrandImage("rbxassetid://new-image")
  ```

- **Set Toggle Key**:
  ```lua
  window:SetToggleKey(Enum.KeyCode.RightAlt)
  ```

- **Destroy UI**:
  ```lua
  window:Destroy()
  ```

## Examples

### Full Example Script

```lua
local UniUI = ... -- Load the library

local window = UniUI:CreateWindow({Name = "Demo UI", Subtitle = "Test"})

local tab1 = window:CreateTab("Tab 1")
local panel1 = tab1:Panel({Title = "Panel 1"})

panel1:Toggle({Name = "Toggle Me", Default = true, Callback = print})
panel1:Button({Name = "Press", Callback = function() window:Notify({Text = "Clicked!"}) end})
panel1:Slider({Name = "Slide", Min = 1, Max = 10, Callback = print})

local tab2 = window:CreateTab("Tab 2")
local panel2 = tab2:Section("Section")
panel2:Dropdown({List = {"A", "B"}, Callback = print})
panel2:Keybind({Name = "Bind", Callback = print})
```

## API Reference

- **Window Methods**:
  - `CreateTab(opts)`: Returns tab object.
  - `Panel(opts)` / `Section(name)`: Returns panel object (on tab).
  - `Notify(opts)`: Shows toast.
  - `Toggle()`: Show/hide UI.
  - `SetTitle(text)`, `SetFooter(text)`, `SetBrand(text)`, `SetBrandImage(image)`, `SetToggleKey(key)`, `Destroy()`.

- **Panel Methods**:
  - `Toggle(opts)`, `Label(opts)`, `Button(opts)`, `Slider(opts)`, `Keybind(opts)`, `Dropdown(opts)`, `Divider()`.

- **Element Methods** (where applicable):
  - `Set(value)`, `Get()`, `Update(list)`.

## Notes

- **Responsiveness**: On small screens (<720px width), columns stack vertically.
- **Truncation**: Long texts are truncated with "**" for compactness.
- **Animations**: Uses TweenService for smooth transitions.
- **Compatibility**: Works in most Roblox environments; tested on desktop and mobile.
- **Limitations**: No support for custom themes yet; extend Theme table if needed.
