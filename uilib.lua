local Nova = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
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
    NeutralButton = Color3.fromRGB(80, 80, 80),
    NeutralButtonHover = Color3.fromRGB(100, 100, 100),
    CloseButtonHover = Color3.fromRGB(200, 50, 60),
}
local Themes = {
    Dark = Theme,
    Light = {
        Bg = Color3.fromRGB(240, 240, 245),
        Top = Color3.fromRGB(255, 255, 255),
        Side = Color3.fromRGB(255, 255, 255),
        Card = Color3.fromRGB(255, 255, 255),
        Card2 = Color3.fromRGB(230, 230, 235),
        Stroke = Color3.fromRGB(200, 200, 210),
        StrokeSoft = Color3.fromRGB(210, 210, 220),
        Text = Color3.fromRGB(30, 30, 35),
        SubText = Color3.fromRGB(100, 100, 110),
        Accent = Color3.fromRGB(100, 100, 255),
        ToggleOff = Color3.fromRGB(220, 220, 225),
        Track = Color3.fromRGB(220, 220, 225),
        White = Color3.fromRGB(255, 255, 255),
        NeutralButton = Color3.fromRGB(150, 150, 150),
        NeutralButtonHover = Color3.fromRGB(170, 170, 170),
        CloseButtonHover = Color3.fromRGB(200, 50, 60),
    },
}
-- OldUI button colors (from oldui.lua default theme) now integrated into Theme
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
local function applyStroke(instance, colorKey, transparency)
    local s = Instance.new("UIStroke")
    s.Thickness = 1
    s.Transparency = transparency or 0.55
    s.Color = Themes.Dark[colorKey] -- Initial set
    s.Parent = instance
    return s
end
local UserInputService = game:GetService("UserInputService")
local function makeDraggable(frame, handle)
    local dragging = false
    local dragInput, mousePos, framePos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end
print("draggable yep yep")
local function truncateWithEllipsis(text, maxChars)
    text = tostring(text or "")
    maxChars = maxChars or 24
    if #text <= maxChars then
        return text
    end
    if maxChars <= 3 then
        return "..."
    end
    return string.sub(text, 1, maxChars - 3) .. "..."
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
local function createText(parent, text, size, bold, colorKey)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = text
    lbl.TextSize = size
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextColor3 = Theme[colorKey or "Text"]
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
    applyStroke(btn, "StrokeSoft", 0.4)
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
function Nova:CreateWindow(options)
    options = options or {}
    local titleText = options.Name or "Nova UI"
    local subtitleText = options.Subtitle or ""
    local footerText = options.Footer or subtitleText
    local brandText = options.BrandText or "N"
    local brandImage = options.BrandImage
    local brandImageSize = options.BrandImageSize or 18
    local forcedSize = options.Size
    local enableGroups = options.Groups == true
    local defaultToggleKey = options.ToggleKey or Enum.KeyCode.LeftAlt
    local enableHome = options.Home ~= false
    local homeOpts = typeof(options.Home) == "table" and options.Home or {}
    local enableSettings = options.Settings ~= false
    local enableConfig = options.Config ~= false
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
    screen.Name = "Nova"
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
    applyStroke(main, "Stroke", 0.6)
    -- Add resize handle - Made bigger and more noticeable
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Size = UDim2.new(0, 30, 0, 30)
    resizeHandle.Position = UDim2.new(1, -30, 1, -30)
    resizeHandle.Parent = main
    -- Add grip visuals (five diagonal lines, thicker)
    for i = 0, 4 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Theme.Accent -- Changed to Accent for better visibility
        line.BorderSizePixel = 0
        line.Size = UDim2.new(0, 12 - i * 2, 0, 2) -- Thicker lines
        line.Position = UDim2.new(1, -18 + i * 4, 1, -6 - i * 4)
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
    local brandWrapWidth = brandImageSize + 22
    local brandWrap = Instance.new("Frame")
    brandWrap.BackgroundTransparency = 1
    brandWrap.BorderSizePixel = 0
    brandWrap.Size = UDim2.new(0, brandWrapWidth, 1, 0)
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
    brandImg.Size = UDim2.new(0, brandImageSize, 0, brandImageSize)
    brandImg.Position = UDim2.new(0, 0, 0.5, -brandImageSize / 2)
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
    title.Position = UDim2.new(0, brandWrapWidth + 12, 0, 14)
    title.Text = titleText
    title.TextColor3 = Theme.Text
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top
    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(0, 260, 0, 16)
    subtitle.Position = UDim2.new(0, brandWrapWidth + 12, 0, 30)
    subtitle.Text = "| " .. footerText
    subtitle.TextColor3 = Theme.SubText
    subtitle.TextSize = 12
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = top
    -- Only 3 small buttons (minimize, full screen, close) with oldui.lua colors
    local controls = Instance.new("Frame")
    controls.BackgroundTransparency = 1
    controls.Size = UDim2.new(0, 66, 0, 16)
    controls.Position = UDim2.new(1, -80, 0, 18)
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
    minimizeBtn.BackgroundColor3 = Theme.NeutralButton
    minimizeBtn.LayoutOrder = 1
    minimizeBtn.Parent = controls
    applyCorner(minimizeBtn, 12)
    local fullScreenBtn = Instance.new("TextButton")
    fullScreenBtn.Name = "FullScreen"
    fullScreenBtn.AutoButtonColor = false
    fullScreenBtn.Text = ""
    fullScreenBtn.BorderSizePixel = 0
    fullScreenBtn.Size = UDim2.new(0, 14, 0, 14)
    fullScreenBtn.BackgroundColor3 = Theme.NeutralButton
    fullScreenBtn.LayoutOrder = 2
    fullScreenBtn.Parent = controls
    applyCorner(fullScreenBtn, 15)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.AutoButtonColor = false
    closeBtn.Text = ""
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0, 14, 0, 14)
    closeBtn.BackgroundColor3 = Theme.NeutralButton
    closeBtn.LayoutOrder = 3
    closeBtn.Parent = controls
    applyCorner(closeBtn, 12)
    makeDraggable(main, top)
    -- Minimize / FullScreen / Close behavior
    local minimized = false
    local isFullScreen = false
    local savedSize = main.Size
    local savedPos = main.Position
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
    fullScreenBtn.MouseButton1Click:Connect(function()
        isFullScreen = not isFullScreen
        if isFullScreen then
            savedSize = main.Size
            savedPos = main.Position
            local viewport = Camera.ViewportSize
            local topLeft, bottomRight = GuiService:GetGuiInset()
            main.Position = UDim2.new(0, topLeft.X, 0, topLeft.Y)
            main.Size = UDim2.new(1, -topLeft.X - bottomRight.X, 1, -topLeft.Y - bottomRight.Y)
        else
            main.Size = savedSize
            main.Position = savedPos
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)
    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, { BackgroundColor3 = Theme.NeutralButtonHover }, 0.12)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, { BackgroundColor3 = Theme.NeutralButton }, 0.12)
    end)
    fullScreenBtn.MouseEnter:Connect(function()
        tween(fullScreenBtn, { BackgroundColor3 = Theme.NeutralButtonHover }, 0.12)
    end)
    fullScreenBtn.MouseLeave:Connect(function()
        tween(fullScreenBtn, { BackgroundColor3 = Theme.NeutralButton }, 0.12)
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, { BackgroundColor3 = Theme.CloseButtonHover }, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, { BackgroundColor3 = Theme.NeutralButton }, 0.12)
    end)
    -- Responsive auto-size like oldui.lua (unless a fixed Size is provided)
    if Camera and not forcedSize then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if minimized or isFullScreen then
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
    applyStroke(sidebar, "StrokeSoft", 0.7)
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
    applyStroke(profile, "StrokeSoft", 0.7)
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 34, 0, 34)
    avatar.Position = UDim2.new(0, 12, 0, 19)
    avatar.BackgroundColor3 = Theme.Card2
    avatar.BorderSizePixel = 0
    avatar.Parent = profile
    applyCorner(avatar, 17)
    applyStroke(avatar, "StrokeSoft", 0.65)
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
    local displayName = createText(profile, truncateWithEllipsis((LocalPlayer and LocalPlayer.DisplayName) or "User", 18), 10, true, "Text")
    displayName.Size = UDim2.new(1, -60, 0, 16)
    displayName.Position = UDim2.new(0, 54, 0, 22)
    local username = createText(profile, truncateWithEllipsis((LocalPlayer and ("@" .. LocalPlayer.Name)) or "@user", 20), 9, false, "SubText")
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
    window._configElements = {}
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
        tab._applyColumns = applyColumnsForWidth
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
            applyStroke(card, "StrokeSoft", 0.55)
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
            local headerText = createText(headerRow, truncateWithEllipsis(pTitle, 28), 13, true, "Text")
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
            panel.Body = body -- Expose body for custom elements
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
                local lbl = createText(row, truncateWithEllipsis(opt.Name or "Toggle", 30), 12, false, "Text")
                lbl.Size = UDim2.new(1, -40 - x, 1, 0)
                lbl.Position = UDim2.new(0, x, 0, 0)
                local tWrap = Instance.new("Frame")
                tWrap.BackgroundTransparency = 1
                tWrap.Size = UDim2.new(0, 22, 0, 22)
                tWrap.Position = UDim2.new(1, -22, 0.5, -11)
                tWrap.Parent = row
                local cb = opt.Callback or function() end
                local toggle = createSquareToggle(tWrap, opt.Default or false, cb)
                if opt.ConfigKey then
                    window._configElements[opt.ConfigKey] = {Element = toggle}
                end
                return toggle
            end
            function panel:CreateLabel(opt)
                if type(opt) == "string" then
                    opt = { Text = opt }
                end
                opt = opt or {}
                local row = createRow(body, opt.Height or 22)
                local lbl = createText(row, opt.Text or "Label", opt.Size or 12, opt.Bold or false, opt.Color or "SubText")
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
                applyStroke(btn2, "StrokeSoft", 0.45)
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
                local suffix = opt.Suffix or ""
                local cb = opt.Callback or function() end
                local wrap = Instance.new("Frame")
                wrap.BackgroundTransparency = 1
                wrap.BorderSizePixel = 0
                wrap.Size = UDim2.new(1, 0, 0, 46)
                wrap.Parent = body
                local titleRow = createRow(wrap, 18)
                local lbl = createText(titleRow, nameText, 12, false, "Text")
                lbl.Size = UDim2.new(0.7, 0, 1, 0)
                local val = Instance.new("TextLabel")
                val.BackgroundTransparency = 1
                val.Size = UDim2.new(0.3, 0, 1, 0)
                val.Position = UDim2.new(0.7, 0, 0, 0)
                val.TextXAlignment = Enum.TextXAlignment.Right
                val.Text = tostring(default) .. suffix
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
                applyStroke(knob, "StrokeSoft", 0.55)
                local current = default
                local dragging = false
                local dragInput
                local function formatValue(v)
                    val.Text = tostring(v) .. suffix
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
                        updateFromX(input.Position.X)
                        local connection = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                            end
                        end)
                    end
                end)
                track.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        dragInput = input
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if input == dragInput and dragging then
                        updateFromX(input.Position.X)
                    end
                end)
                local slider = {
                    SetValue = function(_, v)
                        setValue(v)
                    end,
                    GetValue = function()
                        return current
                    end,
                }
                if opt.ConfigKey then
                    window._configElements[opt.ConfigKey] = {Element = slider}
                end
                return slider
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
                local lbl = createText(row, opt.Name or "Keybind", 12, false, "Text")
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
                applyStroke(keyBtn, "StrokeSoft", 0.45)
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
                        window._keybindListening = false
                        pcall(cb, current)
                        return
                    end
                end)
                local keybind = {
                    SetValue = function(_, v)
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
                if opt.ConfigKey then
                    window._configElements[opt.ConfigKey] = {Element = keybind}
                end
                return keybind
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
                    local lbl = createText(row, labelText, 12, false, "Text")
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
                applyStroke(field, "StrokeSoft", 0.45)
                local valueLabel = Instance.new("TextLabel")
                valueLabel.BackgroundTransparency = 1
                valueLabel.BorderSizePixel = 0
                valueLabel.Size = UDim2.new(1, -26, 1, 0)
                valueLabel.Position = UDim2.new(0, 10, 0, 0)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.TextYAlignment = Enum.TextYAlignment.Center
                valueLabel.Text = truncateWithEllipsis(tostring(current), 26)
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
                drop.Parent = window._overlay
                applyCorner(drop, 7)
                applyStroke(drop, "StrokeSoft", 0.45)
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
                    for _, ch in ipairs(drop:GetChildren()) do
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
                            valueLabel.Text = truncateWithEllipsis(tostring(current), 26)
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
                local dropdown = {
                    SetValue = function(_, v)
                        current = v
                        valueLabel.Text = truncateWithEllipsis(tostring(current), 26)
                        rebuild(list)
                    end,
                    UpdateList = function(_, newList)
                        list = newList or {}
                        rebuild(list)
                    end,
                    GetValue = function()
                        return current
                    end,
                }
                if opt.ConfigKey then
                    window._configElements[opt.ConfigKey] = {Element = dropdown}
                end
                return dropdown
            end
            function panel:CreateTextbox(opt)
                opt = opt or {}
                local row = createRow(body, 28)
                local lbl = createText(row, opt.Name or "Textbox", 12, false, "Text")
                lbl.Size = UDim2.new(1, -130, 1, 0)
                local textBox = Instance.new("TextBox")
                textBox.BackgroundColor3 = Theme.ToggleOff
                textBox.BorderSizePixel = 0
                textBox.Size = UDim2.new(0, 110, 0, 22)
                textBox.Position = UDim2.new(1, -110, 0.5, -11)
                textBox.TextColor3 = Theme.Text
                textBox.TextSize = 11
                textBox.Font = Enum.Font.Gotham
                textBox.Text = opt.Default or ""
                textBox.Parent = row
                applyCorner(textBox, 7)
                applyStroke(textBox, "StrokeSoft", 0.45)
                local cb = opt.Callback or function() end
                textBox.FocusLost:Connect(function(enter)
                    if enter then
                        pcall(cb, textBox.Text)
                    end
                end)
                local textbox = {
                    SetValue = function(_, v)
                        textBox.Text = tostring(v)
                    end,
                    GetValue = function()
                        return textBox.Text
                    end
                }
                if opt.ConfigKey then
                    window._configElements[opt.ConfigKey] = {Element = textbox}
                end
                return textbox
            end
            function panel:CreateColorPicker(opt)
                opt = opt or {}
                local nameText = opt.Name or "Color Picker"
                local default = opt.Default or Color3.new(1, 1, 1)
                local cb = opt.Callback or function() end
                local wrap = Instance.new("Frame")
                wrap.BackgroundTransparency = 1
                wrap.Size = UDim2.new(1, 0, 0, 200) -- Approximate height
                wrap.Parent = body
                local titleRow = createRow(wrap, 18)
                local lbl = createText(titleRow, nameText, 12, false, "Text")
                lbl.Size = UDim2.new(1, -30, 1, 0)
                local preview = Instance.new("Frame")
                preview.Size = UDim2.new(0, 22, 0, 22)
                preview.Position = UDim2.new(1, -22, 0, -2)
                preview.BackgroundColor3 = default
                preview.Parent = titleRow
                applyCorner(preview, 6)
                applyStroke(preview, "StrokeSoft", 0.4)
                -- Color picker components
                local pickerBody = Instance.new("Frame")
                pickerBody.BackgroundTransparency = 1
                pickerBody.Size = UDim2.new(1, 0, 0, 170)
                pickerBody.Position = UDim2.new(0, 0, 0, 24)
                pickerBody.Parent = wrap
                -- SV square
                local svSquare = Instance.new("Frame")
                svSquare.Size = UDim2.new(1, -50, 0, 120)
                svSquare.BackgroundColor3 = Color3.new(1, 0, 0) -- Initial hue
                svSquare.Parent = pickerBody
                applyCorner(svSquare, 6)
                applyStroke(svSquare, "StrokeSoft", 0.4)
                local svGradientH = Instance.new("UIGradient")
                svGradientH.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(0, 0, 0))
                svGradientH.Rotation = 0
                svGradientH.Parent = svSquare
                local svGradientV = Instance.new("UIGradient")
                svGradientV.Transparency = NumberSequence.new(0, 1)
                svGradientV.Rotation = 90
                svGradientV.Parent = svSquare
                local svCursor = Instance.new("Frame")
                svCursor.Size = UDim2.new(0, 8, 0, 8)
                svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                svCursor.BorderSizePixel = 0
                svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                svCursor.Parent = svSquare
                applyCorner(svCursor, 4)
                applyStroke(svCursor, "Stroke", 0)
                -- Hue slider
                local hueSlider = Instance.new("Frame")
                hueSlider.Size = UDim2.new(0, 30, 0, 120)
                hueSlider.Position = UDim2.new(1, -40, 0, 0)
                hueSlider.Parent = pickerBody
                applyCorner(hueSlider, 6)
                applyStroke(hueSlider, "StrokeSoft", 0.4)
                local hueGradient = Instance.new("UIGradient")
                hueGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.667, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                }
                hueGradient.Rotation = 90
                hueGradient.Parent = hueSlider
                local hueKnob = Instance.new("Frame")
                hueKnob.Size = UDim2.new(1, 0, 0, 4)
                hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
                hueKnob.Parent = hueSlider
                applyStroke(hueKnob, "Stroke", 0)
                -- RGB labels
                local rgbRow = createRow(pickerBody, 30)
                rgbRow.Position = UDim2.new(0, 0, 0, 130)
                local rLabel = createText(rgbRow, "R: " .. math.floor(default.R * 255), 12, false, "Text")
                rLabel.Size = UDim2.new(0.33, 0, 1, 0)
                local gLabel = createText(rgbRow, "G: " .. math.floor(default.G * 255), 12, false, "Text")
                gLabel.Size = UDim2.new(0.33, 0, 1, 0)
                gLabel.Position = UDim2.new(0.33, 0, 0, 0)
                local bLabel = createText(rgbRow, "B: " .. math.floor(default.B * 255), 12, false, "Text")
                bLabel.Size = UDim2.new(0.33, 0, 1, 0)
                bLabel.Position = UDim2.new(0.66, 0, 0, 0)
                -- Logic
                local currentColor = default
                local hue = 0
                local sat = 1
                local val = 1
                local function rgbToHsv(color)
                    local r, g, b = color.R, color.G, color.B
                    local maxVal = math.max(r, g, b)
                    local minVal = math.min(r, g, b)
                    local delta = maxVal - minVal
                    local h = 0
                    if delta ~= 0 then
                        if maxVal == r then
                            h = (g - b) / delta % 6
                        elseif maxVal == g then
                            h = (b - r) / delta + 2
                        else
                            h = (r - g) / delta + 4
                        end
                        h = h / 6
                    end
                    local s = maxVal == 0 and 0 or delta / maxVal
                    local v = maxVal
                    return h, s, v
                end
                hue, sat, val = rgbToHsv(default)
                local function updatePreview()
                    preview.BackgroundColor3 = currentColor
                    rLabel.Text = "R: " .. math.floor(currentColor.R * 255)
                    gLabel.Text = "G: " .. math.floor(currentColor.G * 255)
                    bLabel.Text = "B: " .. math.floor(currentColor.B * 255)
                    pcall(cb, currentColor)
                end
                local function updateFromHSV()
                    local color = Color3.fromHSV(hue, sat, val)
                    currentColor = color
                    svSquare.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    updatePreview()
                end
                local function updateHue(y)
                    local pct = math.clamp(1 - (y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                    hue = pct
                    hueKnob.Position = UDim2.new(0, 0, pct, 0)
                    updateFromHSV()
                end
                local function updateSV(pos)
                    local x = math.clamp((pos.X - svSquare.AbsolutePosition.X) / svSquare.AbsoluteSize.X, 0, 1)
                    local y = math.clamp(1 - (pos.Y - svSquare.AbsolutePosition.Y) / svSquare.AbsoluteSize.Y, 0, 1)
                    sat = x
                    val = y
                    svCursor.Position = UDim2.new(x, 0, 1 - y, 0)
                    updateFromHSV()
                end
                -- Initial positions
                hueKnob.Position = UDim2.new(0, 0, 1 - hue, 0)
                svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
                svSquare.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                updatePreview()
                -- Interactions
                local hueDragging = false
                hueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                        updateHue(input.Position.Y)
                    end
                end)
                hueSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateHue(input.Position.Y)
                    end
                end)
                local svDragging = false
                svSquare.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                        updateSV(input.Position)
                    end
                end)
                svSquare.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSV(input.Position)
                    end
                end)
                local colorPicker = {
                    SetValue = function(_, color)
                        currentColor = color
                        hue, sat, val = rgbToHsv(color)
                        updateFromHSV()
                    end,
                    GetValue = function()
                        return currentColor
                    end
                }
                if opt.ConfigKey then
                    window._configElements[opt.ConfigKey] = {Element = colorPicker}
                end
                return colorPicker
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
        applyStroke(toast, "StrokeSoft", 0.55)
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = toast
        local t1 = createText(toast, tostring(nTitle), 12, true, "Text")
        t1.Size = UDim2.new(1, 0, 0, 18)
        t1.ZIndex = 10_120
        local t2 = createText(toast, tostring(nText), 11, false, "SubText")
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
    end
    function window:SetBrandImage(image)
        window._brandImageLabel.Image = tostring(image or "")
        window._brandImageLabel.Visible = window._brandImageLabel.Image ~= ""
        window._brandTextLabel.Visible = not window._brandImageLabel.Visible
    end
    function window:Destroy()
        screen:Destroy()
    end
    function window:SetToggleKey(key)
        window._toggleKey = key
    end
    function window:ApplyTheme(themeName)
        Theme = Themes[themeName] or Themes.Dark
        -- Update all elements (assuming we replaced assignments with direct Theme references; in practice, refresh colors here if needed)
        -- For simplicity, assume elements use Theme directly or refresh key elements
        main.BackgroundColor3 = Theme.Bg
        top.BackgroundColor3 = Theme.Top
        topFix.BackgroundColor3 = Theme.Top
        topLine.BackgroundColor3 = Theme.StrokeSoft
        brand.TextColor3 = Theme.Accent
        brandImg.ImageColor3 = Theme.Accent
        title.TextColor3 = Theme.Text
        subtitle.TextColor3 = Theme.SubText
        minimizeBtn.BackgroundColor3 = Theme.NeutralButton
        fullScreenBtn.BackgroundColor3 = Theme.NeutralButton
        closeBtn.BackgroundColor3 = Theme.NeutralButton
        sidebar.BackgroundColor3 = Theme.Side
        profile.BackgroundColor3 = Theme.Card
        avatar.BackgroundColor3 = Theme.Card2
        displayName.TextColor3 = Theme.Text
        username.TextColor3 = Theme.SubText
        -- Add more if needed, or implement bindColor as planned for comprehensive update
    end
    if enableHome then
        Nova:CreateHomeTab(window, homeOpts)
    end
    if enableSettings or enableConfig then
        local settingsTab = window:CreateTab("Settings")
        settingsTab._button.LayoutOrder = 9999
        if enableSettings then
            local panel = settingsTab:CreatePanel({ Column = "Left", Title = "UI Settings" })
            panel:CreateKeybind({
                Name = "Toggle UI Key",
                Default = defaultToggleKey,
                ConfigKey = "ToggleUIKey",
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
            panel:CreateDropdown({
                Name = "Theme",
                List = {"Dark", "Light"},
                Default = "Dark",
                ConfigKey = "Theme",
                Callback = function(selected)
                    window:ApplyTheme(selected)
                end
            })
        end
        if enableConfig then
            local configPanel = settingsTab:CreatePanel({Column = "Right", Title = "Configuration"})
            local configName = configPanel:CreateTextbox({Name = "Config Name", Default = "Default"})
            local configsDropdown = configPanel:CreateDropdown({
                Name = "Existing Configs",
                List = {},
                Callback = function(selected)
                    configName:SetValue(selected)
                end
            })
            local refreshBtn = configPanel:CreateButton({Name = "Refresh List", Callback = function()
                local folder = "NovaConfigs/" .. tostring(game.PlaceId)
                local list = {}
                if isfolder and isfolder(folder) then
                    local files = listfiles(folder)
                    for _, f in ipairs(files) do
                        local fn = f:match(".+/(.-)%.json$")
                        if fn then
                            table.insert(list, fn)
                        end
                    end
                end
                configsDropdown:UpdateList(list)
            end})
            local saveBtn = configPanel:CreateButton({Name = "Save Config", Callback = function()
                local name = configName:GetValue()
                local data = {}
                for key, info in pairs(window._configElements) do
                    data[key] = info.Element:GetValue()
                end
                local json = HttpService:JSONEncode(data)
                local folder = "NovaConfigs/" .. tostring(game.PlaceId)
                if makefolder and not isfolder(folder) then
                    makefolder(folder)
                end
                if writefile then
                    writefile(folder .. "/" .. name .. ".json", json)
                    window:Notify({Title = "Config", Text = "Saved config " .. name})
                end
            end})
            local loadBtn = configPanel:CreateButton({Name = "Load Config", Callback = function()
                local name = configName:GetValue()
                local folder = "NovaConfigs/" .. tostring(game.PlaceId)
                local file = folder .. "/" .. name .. ".json"
                if isfile and isfile(file) then
                    local json = readfile(file)
                    local data = HttpService:JSONDecode(json)
                    for key, value in pairs(data) do
                        local info = window._configElements[key]
                        if info then
                            info.Element:SetValue(value)
                        end
                    end
                    window:Notify({Text = "Loaded config " .. name})
                else
                    window:Notify({Text = "Config " .. name .. " not found"})
                end
            end})
            local deleteBtn = configPanel:CreateButton({Name = "Delete Config", Callback = function()
                local name = configName:GetValue()
                local file = "NovaConfigs/" .. tostring(game.PlaceId) .. "/" .. name .. ".json"
                if isfile and isfile(file) then
                    delfile(file)
                    window:Notify({Text = "Deleted " .. name})
                end
            end})
        end
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
    return window
end
function Nova:CreateHomeTab(window, options)
    local icon = options.Icon or ""
    local backdrop = options.Backdrop or 0
    local discordInvite = options.DiscordInvite
    local supported = options.SupportedExecutors or {}
    local unsupported = options.UnsupportedExecutors or {}
    local changelog = options.Changelog or {}

    local executorName = "Unknown"
    local executorVersion = ""
    if identifyexecutor then
        executorName, executorVersion = identifyexecutor()
    elseif getexecutorname then
        executorName = getexecutorname()
    end
    local executor = executorName .. (executorVersion ~= "" and " " .. executorVersion or "")

    local function getExecutorStatus()
        if table.find(unsupported, executorName) then
            return "Unsupported", "Error" 
        elseif table.find(supported, executorName) then
            return "Supported", "Success"
        else
            return "Unknown", "Text"
        end
    end
    local execStatus, execColor = getExecutorStatus()
    
    local gameName = "Unknown"
    local gameIcon = "0"
    local creatorName = "Unknown"
    local creatorId = 0
    local universeId = game.GameId
    pcall(function()
        local productInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        gameName = productInfo.Name
        gameIcon = productInfo.IconImageAssetId
        creatorName = productInfo.Creator.Name
        creatorId = productInfo.Creator.Id
    end)

    local playersService = game:GetService("Players")
    local LocalPlayer = playersService.LocalPlayer
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size180x180
    local userThumbnail = "rbxassetid://0" 
    pcall(function()
        local content, isReady = playersService:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)
        if isReady then
            userThumbnail = content
        end
    end)
    local accountAge = LocalPlayer.AccountAge or 0
    local membership = tostring(LocalPlayer.MembershipType):gsub("Enum.MembershipType.", "") or "None"

    local homeTab = window:CreateTab({Name = "Home", Icon = icon})
    local content = homeTab._content
    local bgImage = Instance.new("ImageLabel")
    bgImage.BackgroundTransparency = 1
    bgImage.Size = UDim2.new(1, 0, 1, 0)
    bgImage.Position = UDim2.new(0, 0, 0, 0)
    bgImage.Image = "rbxassetid://" .. tostring(backdrop)
    bgImage.ScaleType = Enum.ScaleType.Fit 
    bgImage.Parent = content
    bgImage.ZIndex = -2
    
    local overlay = Instance.new("Frame")
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.7
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.Parent = content
    overlay.ZIndex = -1

    local userPanel = homeTab:CreatePanel({Column = "Left", Title = "User Information"})

    local avatarContainer = Instance.new("Frame")
    avatarContainer.BackgroundTransparency = 1
    avatarContainer.Size = UDim2.new(1, 0, 0, 120)
    avatarContainer.Parent = userPanel.Body

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 100, 0, 100)
    avatarImage.Position = UDim2.new(0.5, -50, 0, 10)
    avatarImage.Image = userThumbnail
    avatarImage.BackgroundTransparency = 1
    avatarImage.ScaleType = Enum.ScaleType.Fit
    avatarImage.Parent = avatarContainer
    applyCorner(avatarImage, 50) 
    applyStroke(avatarImage, "StrokeSoft", 0.3)  

    userPanel:CreateLabel({Text = "Welcome, " .. (LocalPlayer.DisplayName or "Unknown") .. "!", Bold = true, Size = 14, Color = "Accent"})
    userPanel:CreateLabel("Display Name: " .. (LocalPlayer.DisplayName or "Unknown"))
    userPanel:CreateLabel("Username: " .. (LocalPlayer.Name or "Unknown"))
    userPanel:CreateLabel("User ID: " .. tostring(LocalPlayer.UserId or "Unknown"))
    userPanel:CreateLabel("Account Age: " .. tostring(accountAge) .. " days")
    userPanel:CreateLabel("Membership: " .. membership)
    userPanel:CreateLabel({Text = "Executor: " .. executor .. " (" .. execStatus .. ")", Color = execColor})

    local infoPanel = homeTab:CreatePanel({Column = "Left", Title = "Info"})

    if discordInvite then
        infoPanel:CreateButton({Name = "Join Discord", Callback = function()
            local inviteUrl = discordInvite:match("^http") and discordInvite or "https://discord.gg/" .. discordInvite
            local success, err = pcall(setclipboard, inviteUrl)
            if success then
                window:Notify({Title = "Success", Text = "Copied Discord invite to clipboard: " .. inviteUrl, Duration = 3})
            else
                window:Notify({Title = "Error", Text = "Could not copy to clipboard. Invite URL: " .. inviteUrl, Duration = 5})
            end
        end})
    end

    infoPanel:CreateLabel({Text = "Supported Executors:", Bold = true})
    if #supported == 0 then
        infoPanel:CreateLabel("• None specified")
    else
        for _, exec in ipairs(supported) do
            infoPanel:CreateLabel("• " .. exec)
        end
    end

    infoPanel:CreateLabel({Text = "Unsupported Executors:", Bold = true})
    if #unsupported == 0 then
        infoPanel:CreateLabel("• None specified")
    else
        for _, exec in ipairs(unsupported) do
            infoPanel:CreateLabel("• " .. exec)
        end
    end

    local gamePanel = homeTab:CreatePanel({Column = "Right", Title = "Game Information"})

    local gameIconContainer = Instance.new("Frame")
    gameIconContainer.BackgroundTransparency = 1
    gameIconContainer.Size = UDim2.new(1, 0, 0, 120)
    gameIconContainer.Parent = gamePanel.Body

    local gameIconImage = Instance.new("ImageLabel")
    gameIconImage.Size = UDim2.new(0, 100, 0, 100)
    gameIconImage.Position = UDim2.new(0.5, -50, 0, 10)
    gameIconImage.Image = "rbxassetid://" .. gameIcon
    gameIconImage.BackgroundTransparency = 1
    gameIconImage.ScaleType = Enum.ScaleType.Fit
    gameIconImage.Parent = gameIconContainer
    applyCorner(gameIconImage, 10)
    applyStroke(gameIconImage, "StrokeSoft", 0.3)
    
    local gameNameLabel = gamePanel:CreateLabel("Game Name: " .. gameName)
    local creatorLabel = gamePanel:CreateLabel("Creator: " .. creatorName .. " (ID: " .. tostring(creatorId) .. ")")
    local placeIdLabel = gamePanel:CreateLabel("Place ID: " .. tostring(game.PlaceId))
    local universeIdLabel = gamePanel:CreateLabel("Universe ID: " .. tostring(universeId))
    local jobIdLabel = gamePanel:CreateLabel("Job ID: " .. game.JobId)
    local playersLabel = gamePanel:CreateLabel("Players: " .. #playersService:GetPlayers() .. "/" .. playersService.MaxPlayers)

    gamePanel:CreateButton({Name = "Refresh Info", Callback = function()
                
        playersLabel.Text = "Players: " .. #playersService:GetPlayers() .. "/" .. playersService.MaxPlayers
    
        window:Notify({Title = "Info Refreshed", Text = "Game information has been updated.", Duration = 2})
    end})

    local changePanel = homeTab:CreatePanel({Column = "Right", Title = "Changelog"})

    if #changelog == 0 then
        changePanel:CreateLabel("No changelog entries available.")
    else
        for i, entry in ipairs(changelog) do
            changePanel:CreateLabel({Text = (entry.Title or "Update " .. i) .. " - " .. (entry.Date or "Unknown"), Bold = true})
            changePanel:CreateLabel(entry.Description or "No description provided.")
            if i < #changelog then
                changePanel:Divider()
            end
        end
    end

    local actionsPanel = homeTab:CreatePanel({Column = "Left", Title = "Quick Actions"})
    actionsPanel:CreateButton({Name = "Copy User ID", Callback = function()
        setclipboard(tostring(LocalPlayer.UserId))
        window:Notify({Title = "Copied", Text = "User ID copied to clipboard.", Duration = 2})
    end})
    actionsPanel:CreateButton({Name = "Copy Place ID", Callback = function()
        setclipboard(tostring(game.PlaceId))
        window:Notify({Title = "Copied", Text = "Place ID copied to clipboard.", Duration = 2})
    end})
    actionsPanel:CreateButton({Name = "Copy Job ID", Callback = function()
        setclipboard(game.JobId)
        window:Notify({Title = "Copied", Text = "Job ID copied to clipboard.", Duration = 2})
    end})

    local perfPanel = homeTab:CreatePanel({Column = "Right", Title = "Performance Monitoring"})

    local fpsLabel = perfPanel:CreateLabel("FPS: Calculating...")
    local pingLabel = perfPanel:CreateLabel("Ping: Calculating...")
    local memoryLabel = perfPanel:CreateLabel("Memory Usage: Calculating...")

    local runService = game:GetService("RunService")
    local statsService = game:GetService("Stats")

    local lastTime = tick()
    local frameCount = 0
    local fps = 0

    local function updatePerformance()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fps = frameCount / (currentTime - lastTime)
            fpsLabel.Text = string.format("FPS: %.0f", fps)
            frameCount = 0
            lastTime = currentTime
        end

        local ping = statsService.Network.ServerStatsItem["Data Ping"]:GetValue()
        pingLabel.Text = string.format("Ping: %.0f ms", ping)
        
        local memory = collectgarbage("count") / 1024  -- Convert KB to MB
        memoryLabel.Text = string.format("Memory Usage: %.2f MB", memory)
    end
    
    local perfConnection = runService.Heartbeat:Connect(updatePerformance)

    content.AncestryChanged:Connect(function()
        if not content:IsDescendantOf(game) then
            perfConnection:Disconnect()
        end
    end)

    return homeTab
end
return Nova
