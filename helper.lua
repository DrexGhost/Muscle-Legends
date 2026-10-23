local Core, GUI = ...
local TweenService = game:GetService("TweenService")

local function build()
    local tab = GUI.makeTab("Helper", 2, "helper")
    local page = GUI.makePage()
    local T = Core.T

    GUI.makeSectionHeader(page, "Automation", 1)

    local autoStrThread, autoRebThread, autoClickThread

    local function safeCancel(t)
        if t then pcall(task.cancel, t) end
    end

    local function startAutoStr()
        safeCancel(autoStrThread)
        autoStrThread = task.spawn(function()
            while Core.settings.autoStrength do
                if Core.Char and Core.Char:FindFirstChildOfClass("Humanoid") then
                    local targetName = Core.settings.strengthTool or "Weight"
                    if not Core.hasTool(targetName) then
                        Core.equipTool(targetName)
                    end
                    local tool = Core.Char:FindFirstChild(targetName)
                    if tool and tool:IsA("Tool") then
                        pcall(function() tool:Activate() end)
                    end
                end
                task.wait(0.15)
            end
        end)
    end

    local function startAutoReb()
        safeCancel(autoRebThread)
        autoRebThread = task.spawn(function()
            while Core.settings.autoRebirth do
                Core.doRebirth()
                task.wait(2)
            end
        end)
    end

    local function startAutoClick()
        safeCancel(autoClickThread)
        autoClickThread = task.spawn(function()
            while Core.settings.autoClicker do
                Core.doClicker()
                task.wait(0.05)
            end
        end)
    end

    local autoStrToggle = GUI.makeToggle(page, "Auto Strength ", "Качает: " .. (Core.settings.strengthTool or "Weight"), Core.settings.autoStrength, 2, function(v)
        Core.settings.autoStrength = v
        if v then startAutoStr() else safeCancel(autoStrThread) end
    end, "autoStrength")

    local row = autoStrToggle.Row
    local nameLbl = autoStrToggle.NameLabel
    local descLbl = autoStrToggle.DescLabel

    nameLbl.Size = UDim2.new(1, -116, 0, 16)
    descLbl.Size = UDim2.new(1, -116, 0, 14)

    local gearBtn = Instance.new("TextButton", row)
    gearBtn.Size = UDim2.new(0, 30, 0, 30)
    gearBtn.Position = UDim2.new(1, -92, 0.5, -15)
    gearBtn.BackgroundColor3 = T.panelHi
    gearBtn.BorderSizePixel = 0
    gearBtn.Text = ""
    gearBtn.AutoButtonColor = false
    gearBtn.ZIndex = 3
    Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0, 7)

    local gearStroke = Instance.new("UIStroke", gearBtn)
    gearStroke.Color = T.stroke
    gearStroke.Thickness = 1
    gearStroke.Transparency = 0.3
    gearStroke.Parent = gearBtn

    local iconHolder = Instance.new("Frame", gearBtn)
    iconHolder.Size = UDim2.new(0, 16, 0, 16)
    iconHolder.Position = UDim2.new(0.5, -8, 0.5, -8)
    iconHolder.BackgroundTransparency = 1
    iconHolder.ZIndex = 4

    local function drawIconPart(size, pos, z)
        local f = Instance.new("Frame")
        f.Size = size
        f.Position = pos
        f.BackgroundColor3 = T.text
        f.BorderSizePixel = 0
        f.ZIndex = z
        f.Parent = iconHolder
        Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    end

    local rows = {{y = 2, x = 9}, {y = 7, x = 4}, {y = 12, x = 11}}
    for _, l in ipairs(rows) do
        drawIconPart(UDim2.new(0, 14, 0, 2), UDim2.new(0, 1, 0, l.y), 4)
        drawIconPart(UDim2.new(0, 4, 0, 4), UDim2.new(0, l.x, 0, l.y - 1), 5)
    end

    gearBtn.MouseEnter:Connect(function()
        TweenService:Create(gearBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.cardHover}):Play()
        TweenService:Create(gearStroke, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.5}):Play()
        for _, child in ipairs(iconHolder:GetChildren()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.15), {BackgroundColor3 = T.accent}):Play()
            end
        end
    end)

    gearBtn.MouseLeave:Connect(function()
        TweenService:Create(gearBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.panelHi}):Play()
        TweenService:Create(gearStroke, TweenInfo.new(0.15), {Color = T.stroke, Transparency = 0.3}):Play()
        for _, child in ipairs(iconHolder:GetChildren()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.15), {BackgroundColor3 = T.text}):Play()
            end
        end
    end)

    local toolMenu = nil
    local menuOpen = false

    local function closeToolMenu()
        if toolMenu then
            menuOpen = false
            local m = toolMenu
            toolMenu = nil
            
            local p = m.Position
            local h = m.Size.Y.Offset

            TweenService:Create(m, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 200, 0, 0),
                Position = UDim2.new(0, p.X.Offset, 0, p.Y.Offset + h / 2),
                BackgroundTransparency = 1
            }):Play()

            for _, child in ipairs(m:GetDescendants()) do
                if child:IsA("GuiObject") and child ~= m then
                    TweenService:Create(child, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                end
                if child:IsA("UIStroke") then
                    TweenService:Create(child, TweenInfo.new(0.15), {Transparency = 1}):Play()
                end
            end

            task.delay(0.15, function() if m then m:Destroy() end end)
        end
    end

    local function openToolMenu()
        if not GUI.Main.Visible or not page.Visible then return end
        closeToolMenu()

        local pos = gearBtn.AbsolutePosition
        local sz = gearBtn.AbsoluteSize
        local viewH = workspace.CurrentCamera.ViewportSize.Y
        local menuH = 40 + #Core.STRENGTH_TOOLS * 38 + 8

        local yPos = pos.Y + sz.Y + 4
        if yPos + menuH > viewH then yPos = pos.Y - menuH - 4 end

        toolMenu = Instance.new("TextButton")
        toolMenu.Name = "StrengthToolMenu"
        toolMenu.Size = UDim2.new(0, 200, 0, 0)
        toolMenu.Position = UDim2.new(0, pos.X - 85, 0, yPos + menuH / 2)
        toolMenu.BackgroundColor3 = T.panel
        toolMenu.BorderSizePixel = 0
        toolMenu.Text = ""
        toolMenu.AutoButtonColor = false
        toolMenu.ZIndex = 100
        toolMenu.ClipsDescendants = true
        toolMenu.Parent = GUI.screenGui
        Instance.new("UICorner", toolMenu).CornerRadius = UDim.new(0, 10)

        local mStroke = Instance.new("UIStroke", toolMenu)
        mStroke.Color = T.stroke
        mStroke.Thickness = 1
        mStroke.Transparency = 0.3
        mStroke.Parent = toolMenu

        local header = Instance.new("TextLabel", toolMenu)
        header.Size = UDim2.new(1, -40, 0, 26)
        header.Position = UDim2.new(0, 12, 0, 8)
        header.BackgroundTransparency = 1
        header.Text = "Swing"
        header.TextColor3 = T.text
        header.TextSize = 12
        header.Font = Enum.Font.GothamBold
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.ZIndex = 101

        local closeX = Instance.new("TextButton", toolMenu)
        closeX.Size = UDim2.new(0, 22, 0, 22)
        closeX.Position = UDim2.new(1, -28, 0, 10)
        closeX.BackgroundColor3 = T.panelHi
        closeX.BorderSizePixel = 0
        closeX.Text = "×"
        closeX.TextColor3 = T.textDim
        closeX.TextSize = 14
        closeX.Font = Enum.Font.GothamBold
        closeX.AutoButtonColor = false
        closeX.ZIndex = 101
        Instance.new("UICorner", closeX).CornerRadius = UDim.new(0, 5)
        closeX.MouseButton1Click:Connect(closeToolMenu)

        local list = Instance.new("Frame", toolMenu)
        list.Size = UDim2.new(1, -16, 1, -46)
        list.Position = UDim2.new(0, 8, 0, 40)
        list.BackgroundTransparency = 1
        list.ZIndex = 101

        local ll = Instance.new("UIListLayout", list)
        ll.Padding = UDim.new(0, 4)
        ll.SortOrder = Enum.SortOrder.LayoutOrder

        local mOrder = 1
        for _, toolName in ipairs(Core.STRENGTH_TOOLS) do
            local isActive = Core.settings.strengthTool == toolName
            
            local btn = Instance.new("TextButton", list)
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = T.card
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.LayoutOrder = mOrder
            btn.ZIndex = 102
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, -45, 1, 0)
            lbl.Position = UDim2.new(0, 12, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = toolName
            lbl.TextColor3 = T.text
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 103

            local pill = Instance.new("Frame", btn)
            pill.Name = "Pill"
            pill.Size = UDim2.new(0, 26, 0, 14)
            pill.Position = UDim2.new(1, -36, 0.5, -7)
            pill.BackgroundColor3 = isActive and T.accent or T.toggleOff
            pill.BorderSizePixel = 0
            pill.ZIndex = 103
            Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", pill)
            knob.Name = "Knob"
            knob.Size = UDim2.new(0, 10, 0, 10)
            knob.Position = isActive and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 104
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            btn.MouseButton1Click:Connect(function()
                Core.settings.strengthTool = toolName
                Core.saveSetting("strengthTool", toolName)
                
                if autoStrToggle and autoStrToggle.Desc then
                    autoStrToggle.Desc.Text = "Качает: " .. toolName
                end

                for _, otherBtn in ipairs(list:GetChildren()) do
                    if otherBtn:IsA("TextButton") then
                        local p = otherBtn:FindFirstChild("Pill")
                        local k = p and p:FindFirstChild("Knob")
                        if p and k then
                            local otherLbl = otherBtn:FindFirstChildOfClass("TextLabel")
                            local isCurrent = otherLbl and otherLbl.Text == toolName
                            TweenService:Create(p, TweenInfo.new(0.15), {BackgroundColor3 = isCurrent and T.accent or T.toggleOff}):Play()
                            TweenService:Create(k, TweenInfo.new(0.15), {Position = isCurrent and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)}):Play()
                        end
                    end
                end
            end)

            mOrder = mOrder + 1
        end

        TweenService:Create(toolMenu, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 200, 0, menuH),
            Position = UDim2.new(0, pos.X - 85, 0, yPos)
        }):Play()

        menuOpen = true
    end

    gearBtn.MouseButton1Click:Connect(function()
        if menuOpen then closeToolMenu() else openToolMenu() end
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            if menuOpen and toolMenu then
                if not GUI.Main.Visible or not page.Visible then
                    closeToolMenu()
                end
            end
        end
    end)

    GUI.makeToggle(page, "Auto Rebirth ", "Автоматическое перерождение", Core.settings.autoRebirth, 3, function(v)
        Core.settings.autoRebirth = v
        if v then startAutoReb() else safeCancel(autoRebThread) end
    end, "autoRebirth")

    GUI.makeToggle(page, "Auto Clicker", "Автоматические клики", Core.settings.autoClicker, 4, function(v)
        Core.settings.autoClicker = v
        if v then startAutoClick() else safeCancel(autoClickThread) end
    end, "autoClicker")

    if Core.settings.autoStrength then startAutoStr() end
    if Core.settings.autoRebirth then startAutoReb() end
    if Core.settings.autoClicker then startAutoClick() end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build