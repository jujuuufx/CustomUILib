-- [Sev.cc] UI Library (Buster)
-- Layout-focused rebuild to match the provided screenshot
local Buster = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local function getInsetY()
    local insetY = 0
    pcall(function()
        local inset = GuiService:GetGuiInset()
        insetY = inset.Y
    end)
    return insetY
end
local Theme = {
    Bg = Color3.fromRGB(14, 15, 18),
    Top = Color3.fromRGB(18, 19, 23),
    Side = Color3.fromRGB(18, 19, 23),
    Card = Color3.fromRGB(17, 18, 22),
    Card2 = Color3.fromRGB(19, 20, 25),
    Stroke = Color3.fromRGB(49, 51, 60),
    StrokeSoft = Color3.fromRGB(42, 44, 52),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(150, 152, 160),
    Accent = Color3.fromRGB(142, 138, 255),
    ToggleOff = Color3.fromRGB(34, 35, 42),
    Track = Color3.fromRGB(32, 33, 39),
    White = Color3.fromRGB(255, 255, 255),
}
-- OldUI button colors (from oldui.lua default theme)
local OldButtonTheme = {
    Neutral = Color3.fromRGB(80, 80, 80),
    NeutralHover = Color3.fromRGB(100, 100, 100),
    CloseHover = Color3.fromRGB(200, 50, 60),
}
local function tween(instance, properties, duration)
    duration = duration or 0.18
    local t = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    t:Play()
    return t
end
local function applyCorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = instance
    return c
end
local function applyStroke(instance, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 1
    s.Transparency = transparency or 0.55
    s.Parent = instance
    return s
end
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput
    local startPos
    local startInputPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            startInputPos = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then
            return
        end
        if input == dragInput then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
local function truncateWithStars(text, maxChars)
    text = tostring(text or "")
    maxChars = maxChars or 24
    if #text <= maxChars then
        return text
    end
    if maxChars <= 2 then
        return "**"
    end
    return string.sub(text, 1, maxChars - 2) .. "**"
end
local function safeParentGui(gui)
    if syn and syn.protect_gui then
        pcall(function()
            syn.protect_gui(gui)
        end)
        gui.Parent = CoreGui
        return
    end
    if gethui then
        gui.Parent = gethui()
        return
    end
    gui.Parent = CoreGui
end
local function createRow(parent, height)
    local row = Instance.new("Frame")
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, height)
    row.Parent = parent
    return row
end
local function createText(parent, text, size, bold, color)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = text
    lbl.TextSize = size
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextColor3 = color or Theme.Text
    lbl.Parent = parent
    return lbl
end
local function createSquareToggle(parent, default, callback)
    local btn = Instance.new("TextButton")
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.BackgroundColor3 = Theme.ToggleOff
    btn.Parent = parent
    applyCorner(btn, 6)
    applyStroke(btn, Theme.StrokeSoft, 0.4)
    local state = default and true or false
    local function render()
        if state then
            btn.BackgroundColor3 = Theme.Accent
        else
            btn.BackgroundColor3 = Theme.ToggleOff
        end
    end
    render()
    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        pcall(callback, state)
    end)
    return {
        SetValue = function(_, v)
            state = v and true or false
            render()
        end,
        GetValue = function()
            return state
        end,
    }
end
local function createDivider(parent)
    local div = Instance.new("Frame")
    div.BorderSizePixel = 0
    div.BackgroundColor3 = Theme.StrokeSoft
    div.BackgroundTransparency = 0.6
    div.Size = UDim2.new(1, -18, 0, 1)
    div.Position = UDim2.new(0, 9, 0, 0)
    div.Parent = parent
    return div
end
function Buster:CreateWindow(options)
    options = options or {}
    local titleText = options.Name or "Sev.cc"
    local subtitleText = options.Subtitle or "The Bronx"
    local footerText = options.Footer or subtitleText
    local brandText = options.BrandText or "S"
    local brandImage = options.BrandImage
    local forcedSize = options.Size
    local enableGroups = options.Groups == true
    local defaultToggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    local function computeWindowSize()
        if forcedSize and forcedSize.Width and forcedSize.Height then
            return forcedSize.Width, forcedSize.Height
        end
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local isTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
        local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
        local insetY = getInsetY()
        if isMobile or isTablet then
            local w = math.floor(viewport.X * 0.88)
            local h = math.floor((viewport.Y - insetY) * 0.80)
            return math.max(580, w), math.max(360, h)
        end
        return 860, 480
    end
    local screen = Instance.new("ScreenGui")
    screen.Name = "Buster"
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.ResetOnSpawn = false
    safeParentGui(screen)
    -- Overlay layer (used by dropdowns to stay above everything)
    local overlay = Instance.new("Frame")
    overlay.Name = "Overlay"
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.ZIndex = 10_000
    overlay.Visible = true
    overlay.Parent = screen
    -- Outside toggle button (always available)
    local outsideToggle = Instance.new("TextButton")
    outsideToggle.Name = "OutsideToggle"
    outsideToggle.AutoButtonColor = false
    outsideToggle.BorderSizePixel = 0
    outsideToggle.Size = UDim2.new(0, 42, 0, 42)
    outsideToggle.Position = UDim2.new(1, -54, 0, 12)
    outsideToggle.BackgroundColor3 = Theme.Top
    outsideToggle.Text = ""
    outsideToggle.ZIndex = 10_200
    outsideToggle.Parent = overlay
    applyCorner(outsideToggle, 10)
    applyStroke(outsideToggle, Theme.StrokeSoft, 0.6)
    local outsideText = Instance.new("TextLabel")
    outsideText.Name = "OutsideText"
    outsideText.BackgroundTransparency = 1
    outsideText.Size = UDim2.new(1, 0, 1, 0)
    outsideText.Position = UDim2.new(0, 0, 0, 0)
    outsideText.Text = tostring(brandText)
    outsideText.TextColor3 = Theme.Accent
    outsideText.TextSize = 16
    outsideText.Font = Enum.Font.GothamBold
    outsideText.ZIndex = 10_210
    outsideText.Parent = outsideToggle
    local outsideImg = Instance.new("ImageLabel")
    outsideImg.Name = "OutsideImage"
    outsideImg.BackgroundTransparency = 1
    outsideImg.Size = UDim2.new(0, 18, 0, 18)
    outsideImg.Position = UDim2.new(0.5, -9, 0.5, -9)
    outsideImg.Image = brandImage or ""
    outsideImg.ImageColor3 = Theme.Accent
    outsideImg.Visible = brandImage ~= nil and brandImage ~= ""
    outsideImg.ZIndex = 10_210
    outsideImg.Parent = outsideToggle
    if outsideImg.Visible then
        outsideText.Visible = false
    end
    local main = Instance.new("Frame")
    main.Name = "Main"
    local startW, startH = computeWindowSize()
    main.Size = UDim2.new(0, startW, 0, startH)
    main.Position = UDim2.new(0.5, -startW / 2, 0.5, -startH / 2)
    main.BackgroundColor3 = Theme.Bg
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screen
    applyCorner(main, 10)
    applyStroke(main, Theme.Stroke, 0.6)
    -- Add resize handle
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.Parent = main
    -- Add grip visuals (three diagonal lines)
    for i = 0, 2 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Theme.SubText
        line.BorderSizePixel = 0
        line.Size = UDim2.new(0, 8 - i * 2, 0, 1)
        line.Position = UDim2.new(1, -12 + i * 4, 1, -4 - i * 4)
        line.Rotation = 45
        line.Parent = resizeHandle
    end
    local resizing = false
    local startSize
    local startInputPos
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            startSize = main.Size
            startInputPos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInputPos
            local newWidth = startSize.X.Offset + delta.X
            local newHeight = startSize.Y.Offset + delta.Y
            newWidth = math.max(300, newWidth) -- Minimum width
            newHeight = math.max(200, newHeight) -- Minimum height
            main.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    -- Top bar
    local top = Instance.new("Frame")
    top.Name = "TopBar"
    top.Size = UDim2.new(1, 0, 0, 52)
    top.BackgroundColor3 = Theme.Top
    top.BorderSizePixel = 0
    top.Parent = main
    applyCorner(top, 10)
    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 14)
    topFix.Position = UDim2.new(0, 0, 1, -14)
    topFix.BackgroundColor3 = Theme.Top
    topFix.BorderSizePixel = 0
    topFix.Parent = top
    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 1, 0)
    topLine.BackgroundColor3 = Theme.StrokeSoft
    topLine.BackgroundTransparency = 0.6
    topLine.BorderSizePixel = 0
    topLine.Parent = top
    -- Small brand at left
    local brandWrap = Instance.new("Frame")
    brandWrap.BackgroundTransparency = 1
    brandWrap.BorderSizePixel = 0
    brandWrap.Size = UDim2.new(0, 40, 1, 0)
    brandWrap.Position = UDim2.new(0, 14, 0, 0)
    brandWrap.Parent = top
    local brand = Instance.new("TextLabel")
    brand.Name = "BrandText"
    brand.BackgroundTransparency = 1
    brand.Size = UDim2.new(1, 0, 1, 0)
    brand.Position = UDim2.new(0, 0, 0, 0)
    brand.Text = tostring(brandText)
    brand.TextColor3 = Theme.Accent
    brand.TextSize = 16
    brand.Font = Enum.Font.GothamBold
    brand.TextXAlignment = Enum.TextXAlignment.Left
    brand.Parent = brandWrap
    local brandImg = Instance.new("ImageLabel")
    brandImg.Name = "BrandImage"
    brandImg.BackgroundTransparency = 1
    brandImg.Size = UDim2.new(0, 18, 0, 18)
    brandImg.Position = UDim2.new(0, 0, 0.5, -9)
    brandImg.Image = brandImage or ""
    brandImg.ImageColor3 = Theme.Accent
    brandImg.Visible = brandImage ~= nil and brandImage ~= ""
    brandImg.Parent = brandWrap
    if brandImg.Visible then
        brand.Visible = false
    end
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 260, 0, 18)
    title.Position = UDim2.new(0, 52, 0, 14)
    title.Text = titleText
    title.TextColor3 = Theme.Text
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top
    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(0, 260, 0, 16)
    subtitle.Position = UDim2.new(0, 52, 0, 30)
    subtitle.Text = "| " .. footerText
    subtitle.TextColor3 = Theme.SubText
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = top
    -- Only 2 small buttons (minimize + close) with oldui.lua colors
    local controls = Instance.new("Frame")
    controls.BackgroundTransparency = 1
    controls.Size = UDim2.new(0, 44, 0, 16)
    controls.Position = UDim2.new(1, -58, 0, 18)
    controls.Parent = top
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlsLayout.Padding = UDim.new(0, 6)
    controlsLayout.Parent = controls
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Text = ""
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Size = UDim2.new(0, 14, 0, 14)
    minimizeBtn.BackgroundColor3 = OldButtonTheme.Neutral
    minimizeBtn.LayoutOrder = 1
    minimizeBtn.Parent = controls
    applyCorner(minimizeBtn, 12)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.AutoButtonColor = false
    closeBtn.Text = ""
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0, 14, 0, 14)
    closeBtn.BackgroundColor3 = OldButtonTheme.Neutral
    closeBtn.LayoutOrder = 2
    closeBtn.Parent = controls
    applyCorner(closeBtn, 12)
    makeDraggable(main, top)
    -- Minimize / Close behavior
    local minimized = false
    local function centerTo(w, h)
        main.Size = UDim2.new(0, w, 0, h)
        main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
    end
    local function minimizeToggle()
        minimized = not minimized
        local w = main.Size.X.Offset
        local h = main.Size.Y.Offset
        if minimized then
            tween(main, { Position = UDim2.new(0.5, -w / 2, 1.5, 0) }, 0.22)
        else
            tween(main, { Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2) }, 0.22)
        end
    end
    minimizeBtn.MouseButton1Click:Connect(minimizeToggle)
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, { BackgroundColor3 = OldButtonTheme.NeutralHover }, 0.12)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, { BackgroundColor3 = OldButtonTheme.Neutral }, 0.12)
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, { BackgroundColor3 = OldButtonTheme.CloseHover }, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, { BackgroundColor3 = OldButtonTheme.Neutral }, 0.12)
    end)
    -- Responsive auto-size like oldui.lua (unless a fixed Size is provided)
    if Camera and not forcedSize then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if minimized then
                return
            end
            local w, h = computeWindowSize()
            tween(main, {
                Size = UDim2.new(0, w, 0, h),
                Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2),
            }, 0.22)
        end)
    end
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 176, 1, -52)
    sidebar.Position = UDim2.new(0, 0, 0, 52)
    sidebar.BackgroundColor3 = Theme.Side
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    applyStroke(sidebar, Theme.StrokeSoft, 0.7)
    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Nav"
    nav.BackgroundTransparency = 1
    nav.BorderSizePixel = 0
    nav.Size = UDim2.new(1, 0, 1, -72)
    nav.Position = UDim2.new(0, 0, 0, 0)
    nav.ScrollBarThickness = 0
    nav.CanvasSize = UDim2.new(0, 0, 0, 0)
    nav.Parent = sidebar
    local navPad = Instance.new("UIPadding")
    navPad.PaddingTop = UDim.new(0, 10)
    navPad.PaddingLeft = UDim.new(0, 10)
    navPad.PaddingRight = UDim.new(0, 10)
    navPad.Parent = nav
    local navLayout = Instance.new("UIListLayout")
    navLayout.SortOrder = Enum.SortOrder.LayoutOrder
    navLayout.Padding = UDim.new(0, 6)
    navLayout.Parent = nav
    navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        nav.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 14)
    end)
    -- User profile
    local profile = Instance.new("Frame")
    profile.Name = "Profile"
    profile.Size = UDim2.new(1, 0, 0, 72)
    profile.Position = UDim2.new(0, 0, 1, -72)
    profile.BackgroundColor3 = Theme.Card
    profile.BorderSizePixel = 0
    profile.Parent = sidebar
    applyStroke(profile, Theme.StrokeSoft, 0.7)
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 34, 0, 34)
    avatar.Position = UDim2.new(0, 12, 0, 19)
    avatar.BackgroundColor3 = Theme.Card2
    avatar.BorderSizePixel = 0
    avatar.Parent = profile
    applyCorner(avatar, 17)
    applyStroke(avatar, Theme.StrokeSoft, 0.65)
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "AvatarImage"
    avatarImg.BackgroundTransparency = 1
    avatarImg.BorderSizePixel = 0
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.Position = UDim2.new(0, 0, 0, 0)
    avatarImg.Image = ""
    avatarImg.ScaleType = Enum.ScaleType.Crop
    avatarImg.Parent = avatar
    applyCorner(avatarImg, 17)
    task.spawn(function()
        if LocalPlayer and LocalPlayer.UserId then
            local ok, content = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and content and avatarImg and avatarImg.Parent then
                avatarImg.Image = content
            end
        end
    end)
    local displayName = createText(profile, truncateWithStars((LocalPlayer and LocalPlayer.DisplayName) or "User", 18), 10, true, Theme.Text)
    displayName.Size = UDim2.new(1, -60, 0, 16)
    displayName.Position = UDim2.new(0, 54, 0, 22)
    local username = createText(profile, truncateWithStars((LocalPlayer and ("@" .. LocalPlayer.Name)) or "@user", 20), 9, false, Theme.SubText)
    username.Size = UDim2.new(1, -60, 0, 14)
    username.Position = UDim2.new(0, 54, 0, 38)
    -- Content area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Size = UDim2.new(1, -176, 1, -52)
    content.Position = UDim2.new(0, 176, 0, 52)
    content.Parent = main
    local tabRoot = Instance.new("Frame")
    tabRoot.Name = "TabRoot"
    tabRoot.BackgroundTransparency = 1
    tabRoot.Size = UDim2.new(1, 0, 1, 0)
    tabRoot.Parent = content
    local window = {}
    window._screen = screen
    window._main = main
    window._nav = nav
    window._tabs = {}
    window._tabOrder = 0
    window._currentTab = nil
    window._currentGroup = nil
    window._overlay = overlay
    window._titleLabel = title
    window._subtitleLabel = subtitle
    window._brandTextLabel = brand
    window._brandImageLabel = brandImg
    window._enableGroups = enableGroups
    window._keybindListening = false
    window._toggleKey = defaultToggleKey
    local function computeSidebarWidth(w)
        if UserInputService.TouchEnabled then
            if w < 680 then
                return 150
            end
            if w < 760 then
                return 160
            end
        end
        return 176
    end
    local function applySubLayout()
        local w = main.Size.X.Offset
        local sidebarW = computeSidebarWidth(w)
        sidebar.Size = UDim2.new(0, sidebarW, 1, -52)
        content.Size = UDim2.new(1, -sidebarW, 1, -52)
        content.Position = UDim2.new(0, sidebarW, 0, 52)
        for _, t in ipairs(window._tabs) do
            if t._applyColumns then
                t._applyColumns(w)
            end
        end
    end
    applySubLayout()
    main:GetPropertyChangedSignal("Size"):Connect(function()
        if minimized then
            return
        end
        applySubLayout()
    end)
    function window:AddGroup(name)
        if not window._enableGroups then
            window._currentGroup = name
            return nil
        end
        local header = Instance.new("TextLabel")
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1, 0, 0, 16)
        header.Text = name
        header.TextColor3 = Theme.SubText
        header.TextSize = 11
        header.Font = Enum.Font.Gotham
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = nav
        window._currentGroup = name
        return header
    end
    local function setTabActive(tab, active)
        if not tab or not tab._button then
            return
        end
        if active then
            tab._content.Visible = true
            tween(tab._button, { BackgroundColor3 = Theme.Card2 }, 0.12)
            tab._label.TextColor3 = Theme.Text
            tab._indicator.BackgroundTransparency = 0
            tab._iconTint.ImageColor3 = Theme.Accent
        else
            tab._content.Visible = false
            tween(tab._button, { BackgroundColor3 = Theme.Side }, 0.12)
            tab._label.TextColor3 = Theme.SubText
            tab._indicator.BackgroundTransparency = 1
            tab._iconTint.ImageColor3 = Theme.SubText
        end
    end
    function window:CreateTab(tabOptions)
        local name
        local icon
        local group
        if type(tabOptions) == "string" then
            name = tabOptions
            icon = nil
            group = window._currentGroup
        elseif type(tabOptions) == "table" then
            name = tabOptions.Name or "Tab"
            icon = tabOptions.Icon
            group = tabOptions.Group or window._currentGroup
        else
            name = "Tab"
            group = window._currentGroup
        end
        local tab = {}
        tab.Name = name
        tab.Group = group
        window._tabOrder = window._tabOrder + 1
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Theme.Side
        btn.LayoutOrder = window._tabOrder
        btn.Parent = nav
        applyCorner(btn, 8)
        local indicator = Instance.new("Frame")
        indicator.BorderSizePixel = 0
        indicator.BackgroundColor3 = Theme.Accent
        indicator.BackgroundTransparency = 1
        indicator.Size = UDim2.new(0, 3, 0, 18)
        indicator.Position = UDim2.new(0, 6, 0.5, -9)
        indicator.Parent = btn
        applyCorner(indicator, 2)
        local iconImg = Instance.new("ImageLabel")
        iconImg.Name = "Icon"
        iconImg.BackgroundTransparency = 1
        iconImg.Size = UDim2.new(0, 16, 0, 16)
        iconImg.Position = UDim2.new(0, 18, 0.5, -8)
        iconImg.Image = icon or "rbxassetid://0"
        iconImg.ImageColor3 = Theme.SubText
        iconImg.Parent = btn
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -52, 1, 0)
        label.Position = UDim2.new(0, 42, 0, 0)
        label.Text = tostring(name)
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextColor3 = Theme.SubText
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = btn
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "Content"
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false
        tabContent.Parent = tabRoot
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.Parent = tabContent
        -- Two columns (like the screenshot)
        local leftCol = Instance.new("ScrollingFrame")
        leftCol.Name = "Left"
        leftCol.BackgroundTransparency = 1
        leftCol.BorderSizePixel = 0
        leftCol.ScrollBarThickness = 0
        leftCol.Size = UDim2.new(0.58, -8, 1, 0)
        leftCol.Position = UDim2.new(0, 0, 0, 0)
        leftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        leftCol.Parent = tabContent
        local leftPad = Instance.new("UIPadding")
        leftPad.PaddingBottom = UDim.new(0, 12)
        leftPad.Parent = leftCol
        local rightCol = Instance.new("ScrollingFrame")
        rightCol.Name = "Right"
        rightCol.BackgroundTransparency = 1
        rightCol.BorderSizePixel = 0
        rightCol.ScrollBarThickness = 0
        rightCol.Size = UDim2.new(0.42, -8, 1, 0)
        rightCol.Position = UDim2.new(0.58, 16, 0, 0)
        rightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        rightCol.Parent = tabContent
        local rightPad = Instance.new("UIPadding")
        rightPad.PaddingBottom = UDim.new(0, 12)
        rightPad.Parent = rightCol
        local function attachLayout(sf)
            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 10)
            layout.Parent = sf
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end)
            return layout
        end
        attachLayout(leftCol)
        attachLayout(rightCol)
        local function applyColumnsForWidth(w)
            -- On small screens, stack columns so everything fits.
            if w < 720 then
                leftCol.Size = UDim2.new(1, 0, 0.52, -6)
                leftCol.Position = UDim2.new(0, 0, 0, 0)
                rightCol.Size = UDim2.new(1, 0, 0.48, -6)
                rightCol.Position = UDim2.new(0, 0, 0.52, 12)
            else
                leftCol.Size = UDim2.new(0.58, -8, 1, 0)
                leftCol.Position = UDim2.new(0, 0, 0, 0)
                rightCol.Size = UDim2.new(0.42, -8, 1, 0)
                rightCol.Position = UDim2.new(0.58, 16, 0, 0)
            end
        end
        applyColumnsForWidth(main.Size.X.Offset)
        btn.MouseButton1Click:Connect(function()
            for _, t in ipairs(window._tabs) do
                setTabActive(t, false)
            end
            setTabActive(tab, true)
            window._currentTab = tab
        end)
        btn.MouseEnter:Connect(function()
            if window._currentTab ~= tab then
                tween(btn, { BackgroundColor3 = Theme.Card }, 0.12)
            end
        end)
        btn.MouseLeave:Connect(function()
            if window._currentTab ~= tab then
                tween(btn, { BackgroundColor3 = Theme.Side }, 0.12)
            end
        end)
        tab._button = btn
        tab._indicator = indicator
        tab._label = label
        tab._iconTint = iconImg
        tab._content = tabContent
        tab._left = leftCol
        tab._right = rightCol
        tab.*applyColumns = applyColumnsForWidth
        -- Panels
        local function makePanel(column, panelOptions)
            panelOptions = panelOptions or {}
            local pTitle = panelOptions.Title or "Panel"
            local pIcon = panelOptions.Icon
            local target = (column == "Right") and rightCol or leftCol
            local card = Instance.new("Frame")
            card.BackgroundColor3 = Theme.Card
            card.BorderSizePixel = 0
            card.Size = UDim2.new(1, 0, 0, 100)
            card.Parent = target
            applyCorner(card, 10)
            applyStroke(card, Theme.StrokeSoft, 0.55)
            local cardPad = Instance.new("UIPadding")
            cardPad.PaddingTop = UDim.new(0, 10)
            cardPad.PaddingLeft = UDim.new(0, 10)
            cardPad.PaddingRight = UDim.new(0, 10)
            cardPad.PaddingBottom = UDim.new(0, 10)
            cardPad.Parent = card
            local cardLayout = Instance.new("UIListLayout")
            cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
            cardLayout.Padding = UDim.new(0, 8)
            cardLayout.Parent = card
            local headerRow = createRow(card, 22)
            headerRow.LayoutOrder = 1
            local headerIcon = Instance.new("ImageLabel")
            headerIcon.BackgroundTransparency = 1
            headerIcon.Size = UDim2.new(0, 16, 0, 16)
            headerIcon.Position = UDim2.new(0, 0, 0.5, -8)
            headerIcon.Image = pIcon or "rbxassetid://0"
            headerIcon.ImageColor3 = Theme.SubText
            headerIcon.Parent = headerRow
            local headerText = createText(headerRow, truncateWithStars(pTitle, 28), 13, true, Theme.Text)
            headerText.Size = UDim2.new(1, -22, 1, 0)
            headerText.Position = UDim2.new(0, 22, 0, 0)
            local body = Instance.new("Frame")
            body.BackgroundTransparency = 1
            body.BorderSizePixel = 0
            body.Size = UDim2.new(1, 0, 0, 0)
            body.LayoutOrder = 2
            body.Parent = card
            local bodyLayout = Instance.new("UIListLayout")
            bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
            bodyLayout.Padding = UDim.new(0, 8)
            bodyLayout.Parent = body
            bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                card.Size = UDim2.new(1, 0, 0, 10 + 22 + 8 + 10 + bodyLayout.AbsoluteContentSize.Y)
                body.Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y)
            end)
            local panel = {}
            panel.Frame = card
            function panel:Divider()
                local dWrap = createRow(body, 6)
                createDivider(dWrap)
                return dWrap
            end
            function panel:CreateToggle(opt)
                opt = opt or {}
                local row = createRow(body, 26)
                local hasIcon = opt.Icon ~= nil
                local x = 0
                if hasIcon then
                    local ic = Instance.new("ImageLabel")
                    ic.BackgroundTransparency = 1
                    ic.Size = UDim2.new(0, 16, 0, 16)
                    ic.Position = UDim2.new(0, 0, 0.5, -8)
                    ic.Image = opt.Icon
                    ic.ImageColor3 = Theme.SubText
                    ic.Parent = row
                    x = 22
                end
                local lbl = createText(row, truncateWithStars(opt.Name or "Toggle", 30), 12, false, Theme.Text)
                lbl.Size = UDim2.new(1, -40 - x, 1, 0)
                lbl.Position = UDim2.new(0, x, 0, 0)
                local tWrap = Instance.new("Frame")
                tWrap.BackgroundTransparency = 1
                tWrap.Size = UDim2.new(0, 22, 0, 22)
                tWrap.Position = UDim2.new(1, -22, 0.5, -11)
                tWrap.Parent = row
                local cb = opt.Callback or function() end
                return createSquareToggle(tWrap, opt.Default or false, cb)
            end
            function panel:CreateLabel(opt)
                if type(opt) == "string" then
                    opt = { Text = opt }
                end
                opt = opt or {}
                local row = createRow(body, opt.Height or 22)
                local lbl = createText(row, opt.Text or "Label", opt.Size or 12, opt.Bold or false, opt.Color or Theme.SubText)
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.TextXAlignment = opt.AlignRight and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
                return lbl
            end
            function panel:CreateButton(opt)
                opt = opt or {}
                local row = createRow(body, 28)
                local btn2 = Instance.new("TextButton")
                btn2.AutoButtonColor = false
                btn2.BorderSizePixel = 0
                btn2.BackgroundColor3 = Theme.ToggleOff
                btn2.Size = UDim2.new(1, 0, 0, 24)
                btn2.Position = UDim2.new(0, 0, 0.5, -12)
                btn2.Text = opt.Name or opt.Text or "Button"
                btn2.TextColor3 = Theme.Text
                btn2.TextSize = 12
                btn2.Font = Enum.Font.Gotham
                btn2.Parent = row
                applyCorner(btn2, 7)
                applyStroke(btn2, Theme.StrokeSoft, 0.45)
                btn2.MouseEnter:Connect(function()
                    tween(btn2, { BackgroundColor3 = Theme.Card }, 0.12)
                end)
                btn2.MouseLeave:Connect(function()
                    tween(btn2, { BackgroundColor3 = Theme.ToggleOff }, 0.12)
                end)
                btn2.MouseButton1Click:Connect(function()
                    pcall(opt.Callback or function() end)
                end)
                return btn2
            end
            function panel:CreateSlider(opt)
                opt = opt or {}
                local nameText = opt.Name or "Slider"
                local min = opt.Min or 0
                local max = opt.Max or 100
                local default = opt.Default or min
                local step = opt.Increment or 1
                local suffix = opt.Suffix or "%"
                local cb = opt.Callback or function() end
                local wrap = Instance.new("Frame")
                wrap.BackgroundTransparency = 1
                wrap.BorderSizePixel = 0
                wrap.Size = UDim2.new(1, 0, 0, 46)
                wrap.Parent = body
                local titleRow = createRow(wrap, 18)
                local lbl = createText(titleRow, nameText, 12, false, Theme.Text)
                lbl.Size = UDim2.new(0.7, 0, 1, 0)
                local val = Instance.new("TextLabel")
                val.BackgroundTransparency = 1
                val.Size = UDim2.new(0.3, 0, 1, 0)
                val.Position = UDim2.new(0.7, 0, 0, 0)
                val.TextXAlignment = Enum.TextXAlignment.Right
                val.Text = tostring(default) .. "/" .. tostring(max) .. suffix
                val.TextColor3 = Theme.SubText
                val.TextSize = 11
                val.Font = Enum.Font.Gotham
                val.Parent = titleRow
                local track = Instance.new("Frame")
                track.BorderSizePixel = 0
                track.BackgroundColor3 = Theme.Track
                track.Size = UDim2.new(1, 0, 0, 6)
                track.Position = UDim2.new(0, 0, 0, 28)
                track.Parent = wrap
                applyCorner(track, 3)
                local fill = Instance.new("Frame")
                fill.BorderSizePixel = 0
                fill.BackgroundColor3 = Theme.Accent
                fill.Size = UDim2.new(0, 0, 1, 0)
                fill.Parent = track
                applyCorner(fill, 3)
                local knob = Instance.new("Frame")
                knob.BorderSizePixel = 0
                knob.BackgroundColor3 = Theme.White
                knob.Size = UDim2.new(0, 12, 0, 12)
                knob.Position = UDim2.new(0, -6, 0.5, -6)
                knob.Parent = track
                applyCorner(knob, 6)
                applyStroke(knob, Theme.StrokeSoft, 0.55)
                local current = default
                local dragging = false
                local dragInput
                local function formatValue(v)
                    val.Text = tostring(v) .. "/" .. tostring(max) .. suffix
                end
                local function setValue(v)
                    v = math.clamp(v, min, max)
                    v = math.floor((v - min) / step + 0.5) * step + min
                    current = v
                    local pct = (max == min) and 0 or ((v - min) / (max - min))
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, -6, 0.5, -6)
                    formatValue(v)
                    pcall(cb, v)
                end
                setValue(default)
                local function updateFromX(x)
                    local rel = x - track.AbsolutePosition.X
                    local pct = math.clamp(rel / track.AbsoluteSize.X, 0, 1)
                    setValue(min + (max - min) * pct)
                end
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragInput = input
                        updateFromX(input.Position.X)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input == dragInput and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        dragging = false
                        dragInput = nil
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and dragInput and input == dragInput then
                        updateFromX(input.Position.X)
                    end
                end)
                return {
                    SetValue = function(*, v)
                        setValue(v)
                    end,
                    GetValue = function()
                        return current
                    end,
                }
            end
            function panel:CreateKeybind(opt)
                opt = opt or {}
                local row = createRow(body, 28)
                local hasIcon = opt.Icon ~= nil
                local x = 0
                if hasIcon then
                    local ic = Instance.new("ImageLabel")
                    ic.BackgroundTransparency = 1
                    ic.Size = UDim2.new(0, 16, 0, 16)
                    ic.Position = UDim2.new(0, 0, 0.5, -8)
                    ic.Image = opt.Icon
                    ic.ImageColor3 = Theme.SubText
                    ic.Parent = row
                    x = 22
                end
                local lbl = createText(row, opt.Name or "Keybind", 12, false, Theme.Text)
                lbl.Size = UDim2.new(1, -130 - x, 1, 0)
                lbl.Position = UDim2.new(0, x, 0, 0)
                local keyBtn = Instance.new("TextButton")
                keyBtn.AutoButtonColor = false
                keyBtn.BorderSizePixel = 0
                keyBtn.Size = UDim2.new(0, 110, 0, 22)
                keyBtn.Position = UDim2.new(1, -110, 0.5, -11)
                keyBtn.BackgroundColor3 = Theme.ToggleOff
                keyBtn.TextColor3 = Theme.Text
                keyBtn.TextSize = 11
                keyBtn.Font = Enum.Font.Gotham
                keyBtn.Text = (opt.Default and opt.Default.Name) or "None"
                keyBtn.Parent = row
                applyCorner(keyBtn, 7)
                applyStroke(keyBtn, Theme.StrokeSoft, 0.45)
                local current = opt.Default or Enum.KeyCode.LeftControl
                local listening = false
                local cb = opt.Callback or function() end
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    window._keybindListening = true
                    keyBtn.Text = "Press key"
                    keyBtn.TextColor3 = Theme.Accent
                end)
                UserInputService.InputBegan:Connect(function(input)
                    if not listening then
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Backspace then
                            current = nil
                            keyBtn.Text = "None"
                        else
                            current = input.KeyCode
                            keyBtn.Text = current.Name
                        end
                        keyBtn.TextColor3 = Theme.Text
                        listening = false
                        window._keybindListening = false
                        pcall(cb, current)
                        return
                    end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                        current = input.UserInputType
                        keyBtn.Text = (current == Enum.UserInputType.MouseButton1 and "Mouse1") or "Mouse2"
                        keyBtn.TextColor3 = Theme.Text
                        listening = false
                        window.*keybindListening = false
                        pcall(cb, current)
                        return
                    end
                end)
                return {
                    SetValue = function(*, v)
                        current = v
                        if typeof(current) == "EnumItem" then
                            keyBtn.Text = current.Name
                        elseif current == Enum.UserInputType.MouseButton1 then
                            keyBtn.Text = "Mouse1"
                        elseif current == Enum.UserInputType.MouseButton2 then
                            keyBtn.Text = "Mouse2"
                        else
                            keyBtn.Text = "None"
                        end
                    end,
                    GetValue = function()
                        return current
                    end,
                }
            end
            function panel:CreateDropdown(opt)
                opt = opt or {}
                local list = opt.List or {}
                local current = opt.Default or list[1] or "None"
                local cb = opt.Callback or function() end
                local labelText = opt.Name or opt.Label
                local row = createRow(body, 30)
                -- Optional label at left (rarely used; screenshot dropdown is label-less)
                if labelText and labelText ~= "" then
                    local lbl = createText(row, labelText, 12, false, Theme.Text)
                    lbl.Size = UDim2.new(0.5, 0, 1, 0)
                end
                local field = Instance.new("TextButton")
                field.AutoButtonColor = false
                field.BorderSizePixel = 0
                field.BackgroundColor3 = Theme.ToggleOff
                field.Size = labelText and UDim2.new(0.5, 0, 0, 24) or UDim2.new(1, 0, 0, 24)
                field.Position = labelText and UDim2.new(0.5, 0, 0.5, -12) or UDim2.new(0, 0, 0.5, -12)
                field.Text = ""
                field.Parent = row
                applyCorner(field, 7)
                applyStroke(field, Theme.StrokeSoft, 0.45)
                local valueLabel = Instance.new("TextLabel")
                valueLabel.BackgroundTransparency = 1
                valueLabel.BorderSizePixel = 0
                valueLabel.Size = UDim2.new(1, -26, 1, 0)
                valueLabel.Position = UDim2.new(0, 10, 0, 0)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.TextYAlignment = Enum.TextYAlignment.Center
                valueLabel.Text = truncateWithStars(tostring(current), 26)
                valueLabel.TextColor3 = Theme.Text
                valueLabel.TextSize = 11
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.Parent = field
                local arrow = Instance.new("TextLabel")
                arrow.BackgroundTransparency = 1
                arrow.Size = UDim2.new(0, 22, 1, 0)
                arrow.Position = UDim2.new(1, -22, 0, 0)
                arrow.Text = "▾"
                arrow.TextColor3 = Theme.SubText
                arrow.TextSize = 12
                arrow.Font = Enum.Font.Gotham
                arrow.TextXAlignment = Enum.TextXAlignment.Center
                arrow.Parent = field
                -- Render dropdown in overlay so it's always above everything and clickable
                local catcher = Instance.new("TextButton")
                catcher.Name = "DropdownCatcher"
                catcher.AutoButtonColor = false
                catcher.Text = ""
                catcher.BackgroundTransparency = 1
                catcher.BorderSizePixel = 0
                catcher.Size = UDim2.new(1, 0, 1, 0)
                catcher.Position = UDim2.new(0, 0, 0, 0)
                catcher.Visible = false
                catcher.ZIndex = 10_005
                catcher.Parent = window._overlay
                local drop = Instance.new("Frame")
                drop.Visible = false
                drop.BorderSizePixel = 0
                drop.BackgroundColor3 = Theme.Card
                drop.ClipsDescendants = true
                drop.Size = UDim2.new(0, 0, 0, 0)
                drop.Position = UDim2.new(0, 0, 0, 0)
                drop.ZIndex = 10_010
                drop.Parent = window.*overlay
                applyCorner(drop, 7)
                applyStroke(drop, Theme.StrokeSoft, 0.45)
                local listLayout = Instance.new("UIListLayout")
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Padding = UDim.new(0, 4)
                listLayout.Parent = drop
                local listPad = Instance.new("UIPadding")
                listPad.PaddingTop = UDim.new(0, 6)
                listPad.PaddingBottom = UDim.new(0, 6)
                listPad.PaddingLeft = UDim.new(0, 6)
                listPad.PaddingRight = UDim.new(0, 6)
                listPad.Parent = drop
                local expanded = false
                local openUp = false
                local function placeDrop(targetHeight)
                    local absPos = field.AbsolutePosition
                    local absSize = field.AbsoluteSize
                    local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
                    local h = targetHeight or drop.Size.Y.Offset
                    local belowSpace = viewport.Y - (absPos.Y + absSize.Y)
                    openUp = belowSpace < (h + 18)
                    local y = absPos.Y + absSize.Y + 6
                    if openUp then
                        y = absPos.Y - h - 6
                    end
                    drop.Position = UDim2.fromOffset(absPos.X, y)
                    drop.Size = UDim2.fromOffset(absSize.X, drop.Size.Y.Offset)
                end
                local function startTracking()
                    -- Keep overlay aligned if window is dragged/resized while expanded
                    task.spawn(function()
                        while expanded and drop.Visible and drop.Parent do
                            placeDrop(drop.Size.Y.Offset)
                            task.wait(0.05)
                        end
                    end)
                end
                local function rebuild(items)
                    for *, ch in ipairs(drop:GetChildren()) do
                        if ch:IsA("TextButton") then
                            ch:Destroy()
                        end
                    end
                    for i, item in ipairs(items) do
                        local it = Instance.new("TextButton")
                        it.AutoButtonColor = false
                        it.BorderSizePixel = 0
                        it.BackgroundColor3 = Theme.Card2
                        it.BackgroundTransparency = 1
                        it.Size = UDim2.new(1, 0, 0, 24)
                        it.TextXAlignment = Enum.TextXAlignment.Left
                        it.Text = " " .. tostring(item)
                        it.TextColor3 = (tostring(item) == tostring(current)) and Theme.Accent or Theme.Text
                        it.TextSize = 11
                        it.Font = Enum.Font.Gotham
                        it.LayoutOrder = i
                        it.Parent = drop
                        it.ZIndex = 10_020
                        applyCorner(it, 6)
                        it.MouseEnter:Connect(function()
                            it.BackgroundTransparency = 0
                        end)
                        it.MouseLeave:Connect(function()
                            it.BackgroundTransparency = 1
                        end)
                        it.MouseButton1Click:Connect(function()
                            current = item
                            valueLabel.Text = truncateWithStars(tostring(current), 26)
                            expanded = false
                            arrow.Text = "▾"
                            catcher.Visible = false
                            tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, 0) }, 0.12)
                            task.wait(0.12)
                            drop.Visible = false
                            pcall(cb, current)
                        end)
                    end
                end
                rebuild(list)
                field.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    if expanded then
                        drop.Visible = true
                        catcher.Visible = true
                        arrow.Text = "▴"
                        local h = math.min(#list * 26 + 12, 156)
                        placeDrop(h)
                        tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, h) }, 0.12)
                        startTracking()
                    else
                        arrow.Text = "▾"
                        catcher.Visible = false
                        tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, 0) }, 0.12)
                        task.wait(0.12)
                        drop.Visible = false
                    end
                end)
                catcher.MouseButton1Click:Connect(function()
                    if expanded then
                        expanded = false
                        arrow.Text = "▾"
                        catcher.Visible = false
                        tween(drop, { Size = UDim2.fromOffset(field.AbsoluteSize.X, 0) }, 0.12)
                        task.wait(0.12)
                        drop.Visible = false
                    end
                end)
                return {
                    SetValue = function(*, v)
                        current = v
                        valueLabel.Text = truncateWithStars(tostring(current), 26)
                        rebuild(list)
                    end,
                    UpdateList = function(*, newList)
                        list = newList or {}
                        rebuild(list)
                    end,
                    GetValue = function()
                        return current
                    end,
                }
            end
            -- Back-compat alias
            panel.CreateButton = panel.CreateButton
            return panel
        end
        function tab:CreatePanel(panelOptions)
            return makePanel(panelOptions and panelOptions.Column or "Left", panelOptions)
        end
        -- Backward compatible: sections become left-column panels
        function tab:CreateSection(sectionName)
            return makePanel("Left", { Title = sectionName })
        end
        table.insert(window._tabs, tab)
        if #window._tabs == 1 then
            setTabActive(tab, true)
            window._currentTab = tab
        end
        return tab
    end
    -- Notifications (toasts)
    local notifyHost = Instance.new("Frame")
    notifyHost.Name = "Notifications"
    notifyHost.BackgroundTransparency = 1
    notifyHost.BorderSizePixel = 0
    notifyHost.Size = UDim2.new(0, 320, 1, -24)
    notifyHost.Position = UDim2.new(1, -332, 0, 12)
    notifyHost.ZIndex = 10_100
    notifyHost.Parent = overlay
    local notifyLayout = Instance.new("UIListLayout")
    notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifyLayout.Padding = UDim.new(0, 8)
    notifyLayout.Parent = notifyHost
    function window:Notify(opt)
        opt = opt or {}
        local nTitle = opt.Title or titleText
        local nText = opt.Text or ""
        local duration = opt.Duration or 2.5
        local toast = Instance.new("Frame")
        toast.BackgroundColor3 = Theme.Card
        toast.BorderSizePixel = 0
        toast.Size = UDim2.new(1, 0, 0, 56)
        toast.ZIndex = 10_110
        toast.Parent = notifyHost
        applyCorner(toast, 10)
        applyStroke(toast, Theme.StrokeSoft, 0.55)
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = toast
        local t1 = createText(toast, tostring(nTitle), 12, true, Theme.Text)
        t1.Size = UDim2.new(1, 0, 0, 18)
        t1.ZIndex = 10_120
        local t2 = createText(toast, tostring(nText), 11, false, Theme.SubText)
        t2.Size = UDim2.new(1, 0, 0, 16)
        t2.Position = UDim2.new(0, 0, 0, 20)
        t2.ZIndex = 10_120
        toast.BackgroundTransparency = 1
        tween(toast, { BackgroundTransparency = 0 }, 0.14)
        task.delay(duration, function()
            if toast and toast.Parent then
                tween(toast, { BackgroundTransparency = 1 }, 0.14)
                task.wait(0.16)
                if toast and toast.Parent then
                    toast:Destroy()
                end
            end
        end)
    end
    function window:Toggle()
        if not main.Visible then
            main.Visible = true
            if minimized then
                minimized = false
            end
            local w = main.Size.X.Offset
            local h = main.Size.Y.Offset
            main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
        else
            main.Visible = false
        end
    end
    function window:SetTitle(text)
        window._titleLabel.Text = tostring(text)
    end
    function window:SetFooter(text)
        window._subtitleLabel.Text = "| " .. tostring(text)
    end
    function window:SetBrandText(text)
        window._brandTextLabel.Text = tostring(text)
        window._brandTextLabel.Visible = true
        window._brandImageLabel.Visible = false
        outsideText.Text = tostring(text)
        outsideText.Visible = true
        outsideImg.Visible = false
    end
    function window:SetBrandImage(image)
        window._brandImageLabel.Image = tostring(image or "")
        window._brandImageLabel.Visible = window._brandImageLabel.Image ~= ""
        window._brandTextLabel.Visible = not window._brandImageLabel.Visible
        outsideImg.Image = tostring(image or "")
        outsideImg.Visible = outsideImg.Image ~= ""
        outsideText.Visible = not outsideImg.Visible
    end
    function window:Destroy()
        screen:Destroy()
    end
    function window:SetToggleKey(key)
        window._toggleKey = key
    end
    -- Default Settings tab (always present)
    do
        local settingsTab = window:CreateTab("Settings")
        local panel = settingsTab:CreatePanel({ Column = "Left", Title = "Settings" })
        panel:CreateKeybind({
            Name = "Toggle UI Key",
            Default = defaultToggleKey,
            Callback = function(key)
                if typeof(key) == "EnumItem" then
                    window:SetToggleKey(key)
                    window:Notify({ Title = titleText, Text = "Toggle key set to " .. key.Name, Duration = 1.5 })
                elseif key == nil then
                    window:SetToggleKey(nil)
                    window:Notify({ Title = titleText, Text = "Toggle key cleared", Duration = 1.5 })
                end
            end,
        })
    end
    -- Global keybind to open/close UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if window._keybindListening then
            return
        end
        local key = window._toggleKey
        if not key then
            return
        end
        if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
                window:Toggle()
            end
            return
        end
        if typeof(key) == "EnumItem" and key.EnumType == Enum.UserInputType then
            if input.UserInputType == key then
                window:Toggle()
            end
        end
    end)
    -- Hook buttons
    outsideToggle.MouseButton1Click:Connect(function()
        window:Toggle()
    end)
    return window
end
function Buster:CreateHomeTab(window, options)
    local icon = options.Icon
    local backdrop = options.Backdrop
    local discordInvite = options.DiscordInvite
    local supported = options.SupportedExecutors or {}
    local unsupported = options.UnsupportedExecutors or {}
    local changelog = options.Changelog or {}
    local homeTab = window:CreateTab({Name = "Home", Icon = icon})
    local content = homeTab._content
    local bgImage = Instance.new("ImageLabel")
    bgImage.BackgroundTransparency = 1
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.Image = "rbxassetid://" .. tostring(backdrop or 0)
    bgImage.ScaleType = Enum.ScaleType.Fit
    bgImage.Parent = content
    bgImage.ZIndex = -1
    local infoPanel = homeTab:CreatePanel({Column = "Left", Title = "Info"})
    if discordInvite then
        infoPanel:CreateButton({Name = "Join Discord", Callback = function()
            window:Notify({Text = "Discord invite: " .. discordInvite})
        end})
    end
    infoPanel:CreateLabel("Supported Executors:")
    for _, exec in ipairs(supported) do
        infoPanel:CreateLabel(exec)
    end
    infoPanel:CreateLabel("Unsupported Executors:")
    for _, exec in ipairs(unsupported) do
        infoPanel:CreateLabel(exec)
    end
    local changePanel = homeTab:CreatePanel({Column = "Right", Title = "Changelog"})
    for _, entry in ipairs(changelog) do
        changePanel:CreateLabel(entry.Title .. " - " .. entry.Date)
        changePanel:CreateLabel(entry.Description)
        changePanel:Divider()
    end
    return homeTab
end
-- Backward compatibility: some scripts may still expect "BronxUI"
Buster.BronxUI = Buster
return Buster
