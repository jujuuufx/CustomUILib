
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
