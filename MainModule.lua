local UniUI = {}
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
        insetY = GuiService:GetGuiInset().Y
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
    White = Color3.fromRGB(255, 255, 255)
}

local OldButtonTheme = {
    Neutral = Color3.fromRGB(80, 80, 80),
    NeutralHover = Color3.fromRGB(100, 100, 100),
    CloseHover = Color3.fromRGB(200, 50, 60)
}

local function tween(inst, props, dur)
    dur = dur or 0.18
    local t = TweenService:Create(inst, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function applyCorner(inst, rad)
    local c = Instance.new("UICorner", inst)
    c.CornerRadius = UDim.new(0, rad)
    return c
end

local function applyStroke(inst, col, trans)
    local s = Instance.new("UIStroke", inst)
    s.Color = col
    s.Thickness = 1
    s.Transparency = trans or 0.55
    return s
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, startPos, startInputPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            startInputPos = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startInputPos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function truncate(text, max)
    text = tostring(text or "")
    max = max or 24
    if #text <= max then return text end
    return string.sub(text, 1, max - 2) .. "**"
end

local function safeParent(gui)
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    end
    gui.Parent = gethui and gethui() or CoreGui
end

local function createRow(parent, height)
    local row = Instance.new("Frame", parent)
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, height)
    return row
end

local function createText(parent, text, size, bold, color)
    local lbl = Instance.new("TextLabel", parent)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = text
    lbl.TextSize = size
    lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    lbl.TextColor3 = color or Theme.Text
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    return lbl
end

local function createToggle(parent, default, cb)
    local btn = Instance.new("TextButton", parent)
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.BackgroundColor3 = Theme.ToggleOff
    applyCorner(btn, 6)
    applyStroke(btn, Theme.StrokeSoft, 0.4)
    local state = default
    local function render()
        btn.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
    end
    render()
    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        pcall(cb, state)
    end)
    return {
        Set = function(v) state = v render() end,
        Get = function() return state end
    }
end

local function createDivider(parent)
    local div = Instance.new("Frame", parent)
    div.BackgroundColor3 = Theme.StrokeSoft
    div.BackgroundTransparency = 0.6
    div.Size = UDim2.new(1, -18, 0, 1)
    div.Position = UDim2.new(0, 9, 0, 0)
    return div
end

function UniUI:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Name or "UniUI"
    local subtitle = opts.Subtitle or "Universal"
    local footer = opts.Footer or subtitle
    local brand = opts.Brand or "U"
    local brandImg = opts.BrandImage
    local size = opts.Size
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

    local function computeSize()
        if size then return size.Width, size.Height end
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        local viewport = Camera.ViewportSize or Vector2.new(1280, 720)
        local insetY = getInsetY()
        local w = math.floor(viewport.X * 0.6)
        local h = math.floor((viewport.Y - insetY) * 0.6)
        return math.max(500, w), math.max(300, h)
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "UniUI"
    screen.ResetOnSpawn = false
    safeParent(screen)

    local overlay = Instance.new("Frame", screen)
    overlay.Name = "Overlay"
    overlay.BackgroundTransparency = 1
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.ZIndex = 10000

    local outsideToggle = Instance.new("TextButton", overlay)
    outsideToggle.Size = UDim2.new(0, 42, 0, 42)
    outsideToggle.Position = UDim2.new(1, -54, 0, 12)
    outsideToggle.BackgroundColor3 = Theme.Top
    outsideToggle.Text = ""
    outsideToggle.ZIndex = 10200
    applyCorner(outsideToggle, 10)
    applyStroke(outsideToggle, Theme.StrokeSoft, 0.6)

    local outsideLabel = createText(outsideToggle, brand, 16, true, Theme.Accent)
    outsideLabel.Size = UDim2.new(1, 0, 1, 0)
    outsideLabel.TextXAlignment = Enum.TextXAlignment.Center

    local outsideImg = Instance.new("ImageLabel", outsideToggle)
    outsideImg.Size = UDim2.new(0, 18, 0, 18)
    outsideImg.Position = UDim2.new(0.5, -9, 0.5, -9)
    outsideImg.Image = brandImg or ""
    outsideImg.ImageColor3 = Theme.Accent
    outsideImg.Visible = brandImg ~= nil
    if outsideImg.Visible then outsideLabel.Visible = false end

    local w, h = computeSize()
    local main = Instance.new("Frame", screen)
    main.Size = UDim2.new(0, w, 0, h)
    main.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
    main.BackgroundColor3 = Theme.Bg
    main.ClipsDescendants = true
    applyCorner(main, 10)
    applyStroke(main, Theme.Stroke, 0.6)

    local top = Instance.new("Frame", main)
    top.Size = UDim2.new(1, 0, 0, 52)
    top.BackgroundColor3 = Theme.Top
    applyCorner(top, 10)

    local topFix = Instance.new("Frame", top)
    topFix.Size = UDim2.new(1, 0, 0, 14)
    topFix.Position = UDim2.new(0, 0, 1, -14)
    topFix.BackgroundColor3 = Theme.Top

    local topLine = Instance.new("Frame", top)
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 1, 0)
    topLine.BackgroundColor3 = Theme.StrokeSoft
    topLine.BackgroundTransparency = 0.6

    local brandWrap = Instance.new("Frame", top)
    brandWrap.BackgroundTransparency = 1
    brandWrap.Size = UDim2.new(0, 40, 1, 0)
    brandWrap.Position = UDim2.new(0, 14, 0, 0)

    local brandLabel = createText(brandWrap, brand, 16, true, Theme.Accent)
    brandLabel.Size = UDim2.new(1, 0, 1, 0)
    brandLabel.TextXAlignment = Enum.TextXAlignment.Left

    local brandImage = Instance.new("ImageLabel", brandWrap)
    brandImage.Size = UDim2.new(0, 18, 0, 18)
    brandImage.Position = UDim2.new(0, 0, 0.5, -9)
    brandImage.Image = brandImg or ""
    brandImage.ImageColor3 = Theme.Accent
    brandImage.Visible = brandImg ~= nil
    if brandImage.Visible then brandLabel.Visible = false end

    local titleLabel = createText(top, title, 15, true)
    titleLabel.Size = UDim2.new(0, 260, 0, 18)
    titleLabel.Position = UDim2.new(0, 60, 0, 14)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local subtitleLabel = createText(top, "| " .. footer, 12, false, Theme.SubText)
    subtitleLabel.Size = UDim2.new(0, 260, 0, 16)
    subtitleLabel.Position = UDim2.new(0, 60, 0, 30)
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local controls = Instance.new("Frame", top)
    controls.BackgroundTransparency = 1
    controls.Size = UDim2.new(0, 44, 0, 16)
    controls.Position = UDim2.new(1, -58, 0, 18)

    local controlsLayout = Instance.new("UIListLayout", controls)
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Padding = UDim.new(0, 6)

    local minimizeBtn = Instance.new("TextButton", controls)
    minimizeBtn.Size = UDim2.new(0, 14, 0, 14)
    minimizeBtn.BackgroundColor3 = OldButtonTheme.Neutral
    minimizeBtn.Text = ""
    applyCorner(minimizeBtn, 12)

    local closeBtn = Instance.new("TextButton", controls)
    closeBtn.Size = UDim2.new(0, 14, 0, 14)
    closeBtn.BackgroundColor3 = OldButtonTheme.Neutral
    closeBtn.Text = ""
    applyCorner(closeBtn, 12)

    makeDraggable(main, top)

    local minimized = false
    local function toggleMinimize()
        minimized = not minimized
        local cw, ch = main.Size.X.Offset, main.Size.Y.Offset
        local targetPos = minimized and UDim2.new(0.5, -cw / 2, 1.5, 0) or UDim2.new(0.5, -cw / 2, 0.5, -ch / 2)
        tween(main, {Position = targetPos}, 0.22)
    end
    minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
    end)

    minimizeBtn.MouseEnter:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = OldButtonTheme.NeutralHover}, 0.12)
    end)
    minimizeBtn.MouseLeave:Connect(function()
        tween(minimizeBtn, {BackgroundColor3 = OldButtonTheme.Neutral}, 0.12)
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = OldButtonTheme.CloseHover}, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = OldButtonTheme.Neutral}, 0.12)
    end)

    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 176, 1, -52)
    sidebar.Position = UDim2.new(0, 0, 0, 52)
    sidebar.BackgroundColor3 = Theme.Side
    applyStroke(sidebar, Theme.StrokeSoft, 0.7)

    local nav = Instance.new("ScrollingFrame", sidebar)
    nav.BackgroundTransparency = 1
    nav.Size = UDim2.new(1, 0, 1, -72)
    nav.ScrollBarThickness = 0

    local navPad = Instance.new("UIPadding", nav)
    navPad.PaddingTop = UDim.new(0, 10)
    navPad.PaddingLeft = UDim.new(0, 10)
    navPad.PaddingRight = UDim.new(0, 10)

    local navLayout = Instance.new("UIListLayout", nav)
    navLayout.Padding = UDim.new(0, 6)
    navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        nav.CanvasSize = UDim2.new(0, 0, 0, navLayout.AbsoluteContentSize.Y + 14)
    end)

    local profile = Instance.new("Frame", sidebar)
    profile.Size = UDim2.new(1, 0, 0, 72)
    profile.Position = UDim2.new(0, 0, 1, -72)
    profile.BackgroundColor3 = Theme.Card
    applyStroke(profile, Theme.StrokeSoft, 0.7)

    local avatar = Instance.new("Frame", profile)
    avatar.Size = UDim2.new(0, 34, 0, 34)
    avatar.Position = UDim2.new(0, 12, 0, 19)
    avatar.BackgroundColor3 = Theme.Card2
    applyCorner(avatar, 17)
    applyStroke(avatar, Theme.StrokeSoft, 0.65)

    local avatarImg = Instance.new("ImageLabel", avatar)
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.ScaleType = Enum.ScaleType.Crop
    applyCorner(avatarImg, 17)
    task.spawn(function()
        local success, content = pcall(Players.GetUserThumbnailAsync, Players, LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if success then avatarImg.Image = content end
    end)

    local displayName = createText(profile, truncate(LocalPlayer.DisplayName or "User", 18), 10, true)
    displayName.Size = UDim2.new(1, -60, 0, 16)
    displayName.Position = UDim2.new(0, 54, 0, 22)
    displayName.TextTruncate = Enum.TextTruncate.AtEnd

    local username = createText(profile, truncate("@" .. (LocalPlayer.Name or "user"), 20), 9, false, Theme.SubText)
    username.Size = UDim2.new(1, -60, 0, 14)
    username.Position = UDim2.new(0, 54, 0, 38)
    username.TextTruncate = Enum.TextTruncate.AtEnd

    local content = Instance.new("Frame", main)
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -176, 1, -52)
    content.Position = UDim2.new(0, 176, 0, 52)

    local tabRoot = Instance.new("Frame", content)
    tabRoot.BackgroundTransparency = 1
    tabRoot.Size = UDim2.new(1, 0, 1, 0)

    local window = {
        _screen = screen,
        _main = main,
        _nav = nav,
        _tabs = {},
        _tabOrder = 0,
        _currentTab = nil,
        _overlay = overlay,
        _titleLabel = titleLabel,
        _subtitleLabel = subtitleLabel,
        _brandLabel = brandLabel,
        _brandImage = brandImage,
        _keybindListening = false,
        _toggleKey = toggleKey
    }

    local function computeSidebarW(w)
        if w < 680 then return 150 end
        if w < 760 then return 160 end
        return 176
    end

    local function applyLayout()
        local cw = main.Size.X.Offset
        local sw = computeSidebarW(cw)
        sidebar.Size = UDim2.new(0, sw, 1, -52)
        content.Size = UDim2.new(1, -sw, 1, -52)
        content.Position = UDim2.new(0, sw, 0, 52)
        for _, t in window._tabs do
            if t._applyColumns then t._applyColumns(cw) end
        end
    end
    applyLayout()
    main:GetPropertyChangedSignal("Size"):Connect(applyLayout)

    function window:updateSize()
        if size then return end
        if minimized then return end
        local viewport = Camera.ViewportSize
        local insetY = getInsetY()
        local nw = math.max(500, math.floor(viewport.X * 0.6))
        local maxH = math.floor((viewport.Y - insetY) * 0.6)
        local minH = 300
        local tab = window._currentTab
        if not tab then return end
        local leftH = tab._left.CanvasSize.Y.Offset + 24
        local rightH = tab._right.CanvasSize.Y.Offset + 24
        local contentH
        local gap = 0
        if tab._left.Size.X.Scale > 0 and tab._right.Size.X.Scale > 0 and tab._right.Position.Y.Scale == 0 then
            contentH = math.max(leftH, rightH)
        else
            contentH = leftH + rightH
            if leftH > 0 and rightH > 0 then gap = 12 end
            contentH = contentH + gap
        end
        local totalH = 52 + contentH
        totalH = math.clamp(totalH, minH, maxH)
        tween(main, {Size = UDim2.new(0, nw, 0, totalH), Position = UDim2.new(0.5, -nw/2, 0.5, -totalH/2)}, 0.22)
    end

    local function setTab(tab, active)
        if not tab then return end
        tab._content.Visible = active
        tween(tab._button, {BackgroundColor3 = active and Theme.Card2 or Theme.Side}, 0.12)
        tab._label.TextColor3 = active and Theme.Text or Theme.SubText
        tab._indicator.BackgroundTransparency = active and 0 or 1
        tab._iconTint.ImageColor3 = active and Theme.Accent or Theme.SubText
        if active then
            window._currentTab = tab
            window:updateSize()
        end
    end

    function window:CreateTab(opts)
        opts = type(opts) == "table" and opts or {Name = opts or "Tab"}
        local name = opts.Name
        local icon = opts.Icon
        local tab = {}
        window._tabOrder = window._tabOrder + 1

        local btn = Instance.new("TextButton", nav)
        btn.AutoButtonColor = false
        btn.Text = ""
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Theme.Side
        btn.LayoutOrder = window._tabOrder
        applyCorner(btn, 8)

        local indicator = Instance.new("Frame", btn)
        indicator.BackgroundColor3 = Theme.Accent
        indicator.BackgroundTransparency = 1
        indicator.Size = UDim2.new(0, 3, 0, 18)
        indicator.Position = UDim2.new(0, 6, 0.5, -9)
        applyCorner(indicator, 2)

        local iconImg = Instance.new("ImageLabel", btn)
        iconImg.BackgroundTransparency = 1
        iconImg.Size = UDim2.new(0, 16, 0, 16)
        iconImg.Position = UDim2.new(0, 18, 0.5, -8)
        iconImg.Image = icon or ""
        iconImg.ImageColor3 = Theme.SubText

        local label = createText(btn, truncate(name, 28), 12, false, Theme.SubText)
        label.Size = UDim2.new(1, -52, 1, 0)
        label.Position = UDim2.new(0, 42, 0, 0)
        label.TextTruncate = Enum.TextTruncate.AtEnd

        local tabContent = Instance.new("Frame", tabRoot)
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Visible = false

        local pad = Instance.new("UIPadding", tabContent)
        pad.PaddingTop = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.PaddingBottom = UDim.new(0, 12)

        local leftCol = Instance.new("ScrollingFrame", tabContent)
        leftCol.BackgroundTransparency = 1
        leftCol.ScrollBarThickness = 0
        leftCol.Size = UDim2.new(0.5, -8, 1, 0)

        local rightCol = Instance.new("ScrollingFrame", tabContent)
        rightCol.BackgroundTransparency = 1
        rightCol.ScrollBarThickness = 0
        rightCol.Size = UDim2.new(0.5, -8, 1, 0)
        rightCol.Position = UDim2.new(0.5, 8, 0, 0)

        local function attachLayout(col)
            local layout = Instance.new("UIListLayout", col)
            layout.Padding = UDim.new(0, 10)
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                col.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end)
        end
        attachLayout(leftCol)
        attachLayout(rightCol)

        leftCol:GetPropertyChangedSignal("CanvasSize"):Connect(function() window:updateSize() end)
        rightCol:GetPropertyChangedSignal("CanvasSize"):Connect(function() window:updateSize() end)

        local function applyColumns(w)
            local leftHeight = leftCol.CanvasSize.Y.Offset
            local rightHeight = rightCol.CanvasSize.Y.Offset
            local leftEmpty = leftHeight <= 10
            local rightEmpty = rightHeight <= 10
            if leftEmpty and rightEmpty then
                leftCol.Size = UDim2.new(1, 0, 1, 0)
                rightCol.Size = UDim2.new(0, 0, 1, 0)
            elseif leftEmpty then
                leftCol.Size = UDim2.new(0, 0, 1, 0)
                rightCol.Size = UDim2.new(1, 0, 1, 0)
                rightCol.Position = UDim2.new(0, 0, 0, 0)
            elseif rightEmpty then
                leftCol.Size = UDim2.new(1, 0, 1, 0)
                rightCol.Size = UDim2.new(0, 0, 1, 0)
            else
                if w < 650 then
                    leftCol.Size = UDim2.new(1, 0, 0.52, -6)
                    rightCol.Size = UDim2.new(1, 0, 0.48, -6)
                    rightCol.Position = UDim2.new(0, 0, 0.52, 12)
                else
                    leftCol.Size = UDim2.new(0.5, -8, 1, 0)
                    rightCol.Size = UDim2.new(0.5, -8, 1, 0)
                    rightCol.Position = UDim2.new(0.5, 8, 0, 0)
                end
            end
        end
        applyColumns(main.Size.X.Offset)

        btn.MouseButton1Click:Connect(function()
            for _, t in window._tabs do setTab(t, false) end
            setTab(tab, true)
        end)
        btn.MouseEnter:Connect(function()
            if window._currentTab ~= tab then tween(btn, {BackgroundColor3 = Theme.Card}, 0.12) end
        end)
        btn.MouseLeave:Connect(function()
            if window._currentTab ~= tab then tween(btn, {BackgroundColor3 = Theme.Side}, 0.12) end
        end)

        tab._button = btn
        tab._indicator = indicator
        tab._label = label
        tab._iconTint = iconImg
        tab._content = tabContent
        tab._left = leftCol
        tab._right = rightCol
        tab._applyColumns = applyColumns

        local function makePanel(col, pOpts)
            pOpts = pOpts or {}
            local pTitle = pOpts.Title or "Panel"
            local pIcon = pOpts.Icon
            local target = col == "Right" and rightCol or leftCol

            local card = Instance.new("Frame", target)
            card.BackgroundColor3 = Theme.Card
            applyCorner(card, 10)
            applyStroke(card, Theme.StrokeSoft, 0.55)

            local cardPad = Instance.new("UIPadding", card)
            cardPad.PaddingTop = UDim.new(0, 10)
            cardPad.PaddingBottom = UDim.new(0, 10)
            cardPad.PaddingLeft = UDim.new(0, 10)
            cardPad.PaddingRight = UDim.new(0, 10)

            local cardLayout = Instance.new("UIListLayout", card)
            cardLayout.Padding = UDim.new(0, 8)

            local headerRow = createRow(card, 22)

            local headerIcon = Instance.new("ImageLabel", headerRow)
            headerIcon.BackgroundTransparency = 1
            headerIcon.Size = UDim2.new(0, 16, 0, 16)
            headerIcon.Position = UDim2.new(0, 0, 0.5, -8)
            headerIcon.Image = pIcon or ""
            headerIcon.ImageColor3 = Theme.SubText

            local headerText = createText(headerRow, truncate(pTitle, 28), 13, true)
            headerText.Size = UDim2.new(1, -22, 1, 0)
            headerText.Position = UDim2.new(0, 22, 0, 0)
            headerText.TextTruncate = Enum.TextTruncate.AtEnd

            local body = Instance.new("Frame", card)
            body.BackgroundTransparency = 1

            local bodyLayout = Instance.new("UIListLayout", body)
            bodyLayout.Padding = UDim.new(0, 8)
            bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                body.Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y)
                card.Size = UDim2.new(1, 0, 0, 40 + bodyLayout.AbsoluteContentSize.Y)
            end)

            local panel = {}

            function panel:Divider()
                local dWrap = createRow(body, 6)
                createDivider(dWrap)
            end

            function panel:Toggle(opts)
                opts = opts or {}
                local row = createRow(body, 26)
                local x = 0
                if opts.Icon then
                    local ic = Instance.new("ImageLabel", row)
                    ic.BackgroundTransparency = 1
                    ic.Size = UDim2.new(0, 16, 0, 16)
                    ic.Position = UDim2.new(0, 0, 0.5, -8)
                    ic.Image = opts.Icon
                    ic.ImageColor3 = Theme.SubText
                    x = 22
                end
                local lbl = createText(row, truncate(opts.Name or "Toggle", 30), 12, false)
                lbl.Size = UDim2.new(1, -40 - x, 1, 0)
                lbl.Position = UDim2.new(0, x, 0, 0)
                lbl.TextTruncate = Enum.TextTruncate.AtEnd

                local tWrap = Instance.new("Frame", row)
                tWrap.BackgroundTransparency = 1
                tWrap.Size = UDim2.new(0, 22, 0, 22)
                tWrap.Position = UDim2.new(1, -22, 0.5, -11)
                return createToggle(tWrap, opts.Default or false, opts.Callback or function() end)
            end

            function panel:Label(opts)
                opts = type(opts) == "string" and {Text = opts} or opts or {}
                local row = createRow(body, opts.Height or 22)
                local lbl = createText(row, opts.Text or "Label", opts.Size or 12, opts.Bold or false, opts.Color or Theme.SubText)
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.TextXAlignment = opts.AlignRight and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                return lbl
            end

            function panel:Button(opts)
                opts = opts or {}
                local row = createRow(body, 28)
                local btn = Instance.new("TextButton", row)
                btn.AutoButtonColor = false
                btn.BackgroundColor3 = Theme.ToggleOff
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.Position = UDim2.new(0, 0, 0.5, -12)
                btn.Text = opts.Name or "Button"
                btn.TextColor3 = Theme.Text
                btn.TextSize = 12
                btn.Font = Enum.Font.Gotham
                btn.TextXAlignment = Enum.TextXAlignment.Center
                btn.TextTruncate = Enum.TextTruncate.AtEnd
                applyCorner(btn, 7)
                applyStroke(btn, Theme.StrokeSoft, 0.45)
                btn.MouseEnter:Connect(function()
                    tween(btn, {BackgroundColor3 = Theme.Card}, 0.12)
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, {BackgroundColor3 = Theme.ToggleOff}, 0.12)
                end)
                btn.MouseButton1Click:Connect(function()
                    pcall(opts.Callback)
                end)
                return btn
            end

            function panel:Slider(opts)
                opts = opts or {}
                local min, max, default, step, suffix = opts.Min or 0, opts.Max or 100, opts.Default or 0, opts.Increment or 1, opts.Suffix or "%"
                local cb = opts.Callback or function() end
                local wrap = Instance.new("Frame", body)
                wrap.BackgroundTransparency = 1
                wrap.Size = UDim2.new(1, 0, 0, 46)

                local titleRow = createRow(wrap, 18)
                local lbl = createText(titleRow, opts.Name or "Slider", 12, false)
                lbl.Size = UDim2.new(0.7, 0, 1, 0)
                lbl.TextTruncate = Enum.TextTruncate.AtEnd

                local val = Instance.new("TextLabel", titleRow)
                val.BackgroundTransparency = 1
                val.Size = UDim2.new(0.3, 0, 1, 0)
                val.Position = UDim2.new(0.7, 0, 0, 0)
                val.TextXAlignment = Enum.TextXAlignment.Right
                val.TextColor3 = Theme.SubText
                val.TextSize = 11
                val.Font = Enum.Font.Gotham
                val.TextTruncate = Enum.TextTruncate.AtEnd

                local track = Instance.new("Frame", wrap)
                track.BackgroundColor3 = Theme.Track
                track.Size = UDim2.new(1, 0, 0, 6)
                track.Position = UDim2.new(0, 0, 0, 28)
                applyCorner(track, 3)

                local fill = Instance.new("Frame", track)
                fill.BackgroundColor3 = Theme.Accent
                applyCorner(fill, 3)

                local knob = Instance.new("Frame", track)
                knob.BackgroundColor3 = Theme.White
                knob.Size = UDim2.new(0, 12, 0, 12)
                knob.Position = UDim2.new(0, -6, 0.5, -6)
                applyCorner(knob, 6)
                applyStroke(knob, Theme.StrokeSoft, 0.55)

                local current = default
                local dragging
                local function format(v)
                    val.Text = v .. "/" .. max .. suffix
                end
                local function set(v)
                    v = math.clamp(math.floor((v - min) / step + 0.5) * step + min, min, max)
                    current = v
                    local pct = (v - min) / (max - min)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    knob.Position = UDim2.new(pct, -6, 0.5, -6)
                    format(v)
                    pcall(cb, v)
                end
                set(default)
                local function update(x)
                    local rel = x - track.AbsolutePosition.X
                    local pct = math.clamp(rel / track.AbsoluteSize.X, 0, 1)
                    set(min + (max - min) * pct)
                end
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input.Position.X)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging then update(input.Position.X) end
                end)
                return { Set = set, Get = function() return current end }
            end

            function panel:Keybind(opts)
                opts = opts or {}
                local row = createRow(body, 28)
                local x = 0
                if opts.Icon then
                    local ic = Instance.new("ImageLabel", row)
                    ic.BackgroundTransparency = 1
                    ic.Size = UDim2.new(0, 16, 0, 16)
                    ic.Position = UDim2.new(0, 0, 0.5, -8)
                    ic.Image = opts.Icon
                    ic.ImageColor3 = Theme.SubText
                    x = 22
                end
                local lbl = createText(row, opts.Name or "Keybind", 12, false)
                lbl.Size = UDim2.new(1, -130 - x, 1, 0)
                lbl.Position = UDim2.new(0, x, 0, 0)
                lbl.TextTruncate = Enum.TextTruncate.AtEnd

                local keyBtn = Instance.new("TextButton", row)
                keyBtn.AutoButtonColor = false
                keyBtn.Size = UDim2.new(0, 110, 0, 22)
                keyBtn.Position = UDim2.new(1, -110, 0.5, -11)
                keyBtn.BackgroundColor3 = Theme.ToggleOff
                keyBtn.TextColor3 = Theme.Text
                keyBtn.TextSize = 11
                keyBtn.Font = Enum.Font.Gotham
                keyBtn.Text = opts.Default and opts.Default.Name or "None"
                keyBtn.TextXAlignment = Enum.TextXAlignment.Center
                keyBtn.TextTruncate = Enum.TextTruncate.AtEnd
                applyCorner(keyBtn, 7)
                applyStroke(keyBtn, Theme.StrokeSoft, 0.45)

                local current = opts.Default
                local listening = false
                local cb = opts.Callback or function() end
                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    window._keybindListening = true
                    keyBtn.Text = "Press key"
                    keyBtn.TextColor3 = Theme.Accent
                end)
                UserInputService.InputBegan:Connect(function(input)
                    if not listening then return end
                    listening = false
                    window._keybindListening = false
                    keyBtn.TextColor3 = Theme.Text
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == Enum.KeyCode.Backspace then
                            current = nil
                            keyBtn.Text = "None"
                        else
                            current = input.KeyCode
                            keyBtn.Text = current.Name
                        end
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                        current = input.UserInputType
                        keyBtn.Text = input.UserInputType == Enum.UserInputType.MouseButton1 and "Mouse1" or "Mouse2"
                    end
                    pcall(cb, current)
                end)
                return {
                    Set = function(v)
                        current = v
                        keyBtn.Text = typeof(v) == "EnumItem" and v.Name or (v == Enum.UserInputType.MouseButton1 and "Mouse1" or (v == Enum.UserInputType.MouseButton2 and "Mouse2" or "None"))
                    end,
                    Get = function() return current end
                }
            end

            function panel:Dropdown(opts)
                opts = opts or {}
                local list = opts.List or {}
                local current = opts.Default or list[1] or "None"
                local cb = opts.Callback or function() end
                local labelText = opts.Label

                local row = createRow(body, 30)
                if labelText then
                    local lbl = createText(row, labelText, 12, false)
                    lbl.Size = UDim2.new(0.5, 0, 1, 0)
                    lbl.TextTruncate = Enum.TextTruncate.AtEnd
                end

                local field = Instance.new("TextButton", row)
                field.AutoButtonColor = false
                field.BackgroundColor3 = Theme.ToggleOff
                field.Size = labelText and UDim2.new(0.5, 0, 0, 24) or UDim2.new(1, 0, 0, 24)
                field.Position = labelText and UDim2.new(0.5, 0, 0.5, -12) or UDim2.new(0, 0, 0.5, -12)
                field.Text = ""
                applyCorner(field, 7)
                applyStroke(field, Theme.StrokeSoft, 0.45)

                local valueLabel = Instance.new("TextLabel", field)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Size = UDim2.new(1, -26, 1, 0)
                valueLabel.Position = UDim2.new(0, 10, 0, 0)
                valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                valueLabel.Text = truncate(tostring(current), 26)
                valueLabel.TextColor3 = Theme.Text
                valueLabel.TextSize = 11
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.TextTruncate = Enum.TextTruncate.AtEnd

                local arrow = createText(field, "▾", 12, false, Theme.SubText)
                arrow.Size = UDim2.new(0, 22, 1, 0)
                arrow.Position = UDim2.new(1, -22, 0, 0)
                arrow.TextXAlignment = Enum.TextXAlignment.Center

                local catcher = Instance.new("TextButton", window._overlay)
                catcher.BackgroundTransparency = 1
                catcher.Size = UDim2.new(1, 0, 1, 0)
                catcher.Visible = false
                catcher.ZIndex = 10005
                catcher.Text = ""

                local drop = Instance.new("Frame", window._overlay)
                drop.Visible = false
                drop.BackgroundColor3 = Theme.Card
                drop.ClipsDescendants = true
                drop.ZIndex = 10010
                applyCorner(drop, 7)
                applyStroke(drop, Theme.StrokeSoft, 0.45)

                local dropLayout = Instance.new("UIListLayout", drop)
                dropLayout.Padding = UDim.new(0, 4)

                local dropPad = Instance.new("UIPadding", drop)
                dropPad.PaddingTop = UDim.new(0, 6)
                dropPad.PaddingBottom = UDim.new(0, 6)
                dropPad.PaddingLeft = UDim.new(0, 6)
                dropPad.PaddingRight = UDim.new(0, 6)

                local expanded = false
                local function place()
                    local pos = field.AbsolutePosition
                    local sz = field.AbsoluteSize
                    local vp = Camera.ViewportSize or Vector2.new(1280, 720)
                    local h = math.min(#list * 26 + 12, 156)
                    local openUp = vp.Y - (pos.Y + sz.Y) < h + 18
                    drop.Position = UDim2.fromOffset(pos.X, openUp and pos.Y - h - 6 or pos.Y + sz.Y + 6)
                    drop.Size = UDim2.fromOffset(sz.X, h)
                end

                local function rebuild()
                    for _, ch in drop:GetChildren() do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for i, item in list do
                        local it = Instance.new("TextButton", drop)
                        it.AutoButtonColor = false
                        it.BackgroundColor3 = Theme.Card2
                        it.BackgroundTransparency = 1
                        it.Size = UDim2.new(1, 0, 0, 24)
                        it.TextXAlignment = Enum.TextXAlignment.Left
                        it.Text = " " .. tostring(item)
                        it.TextColor3 = tostring(item) == tostring(current) and Theme.Accent or Theme.Text
                        it.TextSize = 11
                        it.Font = Enum.Font.Gotham
                        it.ZIndex = 10020
                        it.TextTruncate = Enum.TextTruncate.AtEnd
                        applyCorner(it, 6)
                        it.MouseEnter:Connect(function() it.BackgroundTransparency = 0 end)
                        it.MouseLeave:Connect(function() it.BackgroundTransparency = 1 end)
                        it.MouseButton1Click:Connect(function()
                            current = item
                            valueLabel.Text = truncate(tostring(current), 26)
                            expanded = false
                            arrow.Text = "▾"
                            catcher.Visible = false
                            tween(drop, {Size = UDim2.fromOffset(field.AbsoluteSize.X, 0)}, 0.12)
                            task.wait(0.12)
                            drop.Visible = false
                            pcall(cb, current)
                        end)
                    end
                end
                rebuild()

                field.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    arrow.Text = expanded and "▴" or "▾"
                    catcher.Visible = expanded
                    drop.Visible = expanded
                    if expanded then
                        place()
                        tween(drop, {Size = UDim2.fromOffset(field.AbsoluteSize.X, math.min(#list * 26 + 12, 156))}, 0.12)
                    end
                    if not expanded then
                        tween(drop, {Size = UDim2.fromOffset(field.AbsoluteSize.X, 0)}, 0.12)
                        task.wait(0.12)
                        drop.Visible = false
                    end
                end)

                catcher.MouseButton1Click:Connect(function()
                    expanded = false
                    arrow.Text = "▾"
                    catcher.Visible = false
                    tween(drop, {Size = UDim2.fromOffset(field.AbsoluteSize.X, 0)}, 0.12)
                    task.wait(0.12)
                    drop.Visible = false
                end)

                task.spawn(function()
                    while expanded do
                        place()
                        task.wait(0.05)
                    end
                end)

                return {
                    Set = function(v)
                        current = v
                        valueLabel.Text = truncate(tostring(v), 26)
                        rebuild()
                    end,
                    Update = function(newList)
                        list = newList or {}
                        rebuild()
                    end,
                    Get = function() return current end
                }
            end

            return panel
        end

        function tab:Panel(pOpts)
            return makePanel(pOpts.Column or "Left", pOpts)
        end

        function tab:Section(name)
            return makePanel("Left", {Title = name})
        end

        table.insert(window._tabs, tab)
        if #window._tabs == 1 then setTab(tab, true) end
        return tab
    end

    local notifyHost = Instance.new("Frame", overlay)
    notifyHost.BackgroundTransparency = 1
    notifyHost.Size = UDim2.new(0, 320, 1, -24)
    notifyHost.Position = UDim2.new(1, -332, 0, 12)
    notifyHost.ZIndex = 10100

    local notifyLayout = Instance.new("UIListLayout", notifyHost)
    notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifyLayout.Padding = UDim.new(0, 8)

    function window:Notify(opts)
        opts = opts or {}
        local nTitle = opts.Title or title
        local nText = opts.Text or ""
        local dur = opts.Duration or 2.5

        local toast = Instance.new("Frame", notifyHost)
        toast.BackgroundColor3 = Theme.Card
        toast.Size = UDim2.new(1, 0, 0, 56)
        toast.ZIndex = 10110
        applyCorner(toast, 10)
        applyStroke(toast, Theme.StrokeSoft, 0.55)
        toast.BackgroundTransparency = 1
        tween(toast, {BackgroundTransparency = 0}, 0.14)

        local pad = Instance.new("UIPadding", toast)
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)

        local t1 = createText(toast, nTitle, 12, true)
        t1.Size = UDim2.new(1, 0, 0, 18)
        t1.ZIndex = 10120
        t1.TextTruncate = Enum.TextTruncate.AtEnd

        local t2 = createText(toast, nText, 11, false, Theme.SubText)
        t2.Size = UDim2.new(1, 0, 0, 16)
        t2.Position = UDim2.new(0, 0, 0, 20)
        t2.ZIndex = 10120
        t2.TextTruncate = Enum.TextTruncate.AtEnd

        task.delay(dur, function()
            if toast then
                tween(toast, {BackgroundTransparency = 1}, 0.14)
                task.wait(0.16)
                toast:Destroy()
            end
        end)
    end

    function window:Toggle()
        main.Visible = not main.Visible
        if main.Visible and minimized then
            minimized = false
            local cw, ch = main.Size.X.Offset, main.Size.Y.Offset
            tween(main, {Position = UDim2.new(0.5, -cw / 2, 0.5, -ch / 2)}, 0.22)
        end
    end

    function window:SetTitle(t)
        titleLabel.Text = tostring(t)
    end

    function window:SetFooter(f)
        subtitleLabel.Text = "| " .. tostring(f)
    end

    function window:SetBrand(b)
        brandLabel.Text = tostring(b)
        brandLabel.Visible = true
        brandImage.Visible = false
        outsideLabel.Text = tostring(b)
        outsideLabel.Visible = true
        outsideImg.Visible = false
    end

    function window:SetBrandImage(img)
        brandImage.Image = tostring(img)
        brandImage.Visible = img ~= ""
        brandLabel.Visible = not brandImage.Visible
        outsideImg.Image = tostring(img)
        outsideImg.Visible = img ~= ""
        outsideLabel.Visible = not outsideImg.Visible
    end

    function window:Destroy()
        screen:Destroy()
    end

    function window:SetToggleKey(k)
        window._toggleKey = k
    end

    if Camera and not size then
        Camera:GetPropertyChangedSignal("ViewportSize"):Connect(window.updateSize)
    end

    local settingsTab = window:CreateTab("Settings")
    local panel = settingsTab:Panel({Title = "Settings"})
    panel:Keybind({
        Name = "Toggle UI Key",
        Default = toggleKey,
        Callback = function(key)
            if key then
                window:SetToggleKey(key)
                window:Notify({Title = title, Text = "Toggle key set to " .. (key.Name or "None"), Duration = 1.5})
            end
        end
    })

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or window._keybindListening then return end
        local key = window._toggleKey
        if key and ((input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key) or input.UserInputType == key) then
            window:Toggle()
        end
    end)

    outsideToggle.MouseButton1Click:Connect(window.Toggle)

    return window
end

return UniUI
