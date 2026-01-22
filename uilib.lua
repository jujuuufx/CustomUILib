function panel:CreateDropdown(opt)
    opt = opt or {}
    local list = opt.List or {}
    local current = opt.Default or list[1] or "None"
    local cb = opt.Callback or function() end
    local labelText = opt.Name or opt.Label
    local row = createRow(body, 32)
    if labelText and labelText ~= "" then
        local lbl = createText(row, labelText, 12, false, "Text")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
    end
    local field = Instance.new("TextButton")
    field.AutoButtonColor = false
    field.BorderSizePixel = 0
    field.BackgroundColor3 = Theme.ToggleOff
    field.Size = labelText and UDim2.new(0.5, 0, 0, 26) or UDim2.new(1, 0, 0, 26)
    field.Position = labelText and UDim2.new(0.5, 0, 0.5, -13) or UDim2.new(0, 0, 0.5, -13)
    field.Text = ""
    field.Parent = row
    applyCorner(field, 8)
    applyStroke(field, "StrokeSoft", 0.45)
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.BorderSizePixel = 0
    valueLabel.Size = UDim2.new(1, -26, 1, 0)
    valueLabel.Position = UDim2.new(0, 12, 0, 0)
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
    applyCorner(drop, 8)
    applyStroke(drop, "StrokeSoft", 0.45)

    -- NEW: Add ScrollingFrame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Theme.SubText
    scrollFrame.Parent = drop

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = scrollFrame
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 8)
    listPad.PaddingBottom = UDim.new(0, 8)
    listPad.PaddingLeft = UDim.new(0, 8)
    listPad.PaddingRight = UDim.new(0, 8)
    listPad.Parent = scrollFrame

    local expanded = false
    local openUp = false
    local function placeDrop(targetHeight)
        local absPos = field.AbsolutePosition
        local absSize = field.AbsoluteSize
        local viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
        local h = targetHeight or drop.Size.Y.Offset
        local belowSpace = viewport.Y - (absPos.Y + absSize.Y)
        openUp = belowSpace < (h + 18)
        local y = openUp and (absPos.Y - h - 6) or (absPos.Y + absSize.Y + 6)
        drop.Position = UDim2.fromOffset(absPos.X, y)
        drop.Size = UDim2.fromOffset(absSize.X, drop.Size.Y.Offset)
    end
    local function startTracking()
        task.spawn(function()
            while expanded and drop.Visible and drop.Parent do
                placeDrop(drop.Size.Y.Offset)
                task.wait(0.05)
            end
        end)
    end
    local function rebuild(items)
        for _, ch in ipairs(scrollFrame:GetChildren()) do  -- CHANGED: Clear from scrollFrame
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
            it.Size = UDim2.new(1, 0, 0, 26)
            it.TextXAlignment = Enum.TextXAlignment.Left
            it.Text = " " .. tostring(item)
            it.TextColor3 = (tostring(item) == tostring(current)) and Theme.Accent or Theme.Text
            it.TextSize = 11
            it.Font = Enum.Font.Gotham
            it.LayoutOrder = i
            it.Parent = scrollFrame  -- CHANGED: Parent to scrollFrame
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
            local h = math.min(listLayout.AbsoluteContentSize.Y + 16, 156)  -- Keep max height, but scroll if needed
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
        SetValue = function(self, v)
            current = v
            valueLabel.Text = truncateWithEllipsis(tostring(current), 26)
            rebuild(list)
        end,
        UpdateList = function(self, newList)
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
