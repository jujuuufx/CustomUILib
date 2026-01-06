```lua
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
```

# README.md

## UILibrary - A Simple and Nice Roblox UI Library

This is a basic UI library for Roblox, written in Lua (Luau). It provides easy-to-use functions to create styled UI elements like frames, buttons, labels, and draggable windows. The library includes simple styling with rounded corners, shadows, and hover effects for a "nice" modern look.

### Features
- **CreateFrame**: Creates a styled frame with rounding and shadow.
- **CreateButton**: Creates a button with text, hover effect, and callback.
- **CreateLabel**: Creates a simple text label.
- **CreateWindow**: Creates a draggable window with a title bar and content area.

The library uses dark-themed colors by default for a clean, professional appearance, but you can customize colors when creating elements.

### Installation

1. **Create a ModuleScript**:
   - In Roblox Studio, create a new ModuleScript (right-click in Explorer > Insert Object > ModuleScript).
   - Name it `UILibrary`.
   - Paste the provided Lua code into the script.
   - Place it in `ReplicatedStorage` (recommended for client-side UI) or `ServerScriptService` if needed.

2. **Require the Module**:
   - In your LocalScript (for client-side UI), require the module like this:
     ```lua
     local UILibrary = require(game.ReplicatedStorage.UILibrary)  -- Adjust path if placed elsewhere
     ```

### How to Load and Use

This library is designed for client-side use in LocalScripts, as UI elements are typically handled on the client.

#### Loading the Library
- Place a LocalScript in `StarterPlayerScripts` or inside a tool/ GUI.
- In the LocalScript:
  ```lua
  local UILibrary = require(game.ReplicatedStorage.UILibrary)
  ```

#### Usage Examples

1. **Creating a Simple Window with a Button and Label**:
   ```lua
   local content, window = UILibrary.CreateWindow("My Window", UDim2.new(0, 300, 0, 200), UDim2.new(0.5, -150, 0.5, -100))
   
   local label = UILibrary.CreateLabel(content, "Hello, Roblox!", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 10))
   
   local button = UILibrary.CreateButton(content, "Click Me", UDim2.new(0, 150, 0, 50), UDim2.new(0.5, -75, 0.5, 0), function()
       print("Button clicked!")
       label.Text = "Button was clicked!"
   end)
   ```

   This creates a draggable window centered on the screen with a label and a button. Clicking the button updates the label and prints to the console.

2. **Customizing Styles**:
   - When creating elements, pass custom parameters:
     ```lua
     local frame = UILibrary.CreateFrame(parent, "CustomFrame", UDim2.new(0, 250, 0, 150), UDim2.new(0, 10, 0, 10), Color3.fromRGB(100, 100, 255), Color3.fromRGB(0, 0, 0))
     ```

3. **Adding More Elements**:
   - You can nest frames or add more buttons/labels inside the content frame returned by `CreateWindow`.
   - For advanced UI, build upon these basics (e.g., add sliders or textboxes using similar patterns).

### Notes
- This library is client-side only. For server-client communication, use RemoteEvents.
- Test in Roblox Studio: Run the game and check the PlayerGui for the UI.
- Customization: Feel free to modify the code for more features like animations (using TweenService) or additional elements.
- Dependencies: None – uses built-in Roblox instances.

If you encounter issues, ensure the ModuleScript is accessible from the LocalScript's context. Enjoy building your Roblox UIs! 🚀
