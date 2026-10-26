local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

return function(Core, GUI, page, startOrder)
    local T = Core.T
    local order = startOrder
    local eggThread = nil
    local toolMenu = nil
    local menuOpen = false

    local function startHatching()
        if eggThread then pcall(task.cancel, eggThread) end
        eggThread = task.spawn(function()
            while Core.settings.hatchEggs do
                local rEvents = RS:FindFirstChild("rEvents")
                local remote = rEvents and rEvents:FindFirstChild("openCrystalRemote")
                
                if remote and remote:IsA("RemoteFunction") then
                    for _, eggName in ipairs(Core.EGGS_LIST) do
                        if Core.settings.hatchEggsSelected[eggName] and Core.settings.hatchEggs then
                            pcall(function()
                                remote:InvokeServer("openCrystalBulk", eggName, 10)
                            end)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end

    local toggle = GUI.makeToggle(page, "Hatch Eggs ", "Авто-открытие яиц", Core.settings.hatchEggs, order, function(v)
        Core.settings.hatchEggs = v
        if v then startHatching() else 
            if eggThread then pcall(task.cancel, eggThread) end 
        end
    end, "hatchEggs")

    if toggle.Row and toggle.NameLabel and toggle.DescLabel then
        local row = toggle.Row
        local nameLbl = toggle.NameLabel
        local descLbl = toggle.DescLabel

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

        local function closeToolMenu(instant)
            if toolMenu then
                menuOpen = false
                local m = toolMenu
                toolMenu = nil
                if instant then
                    m:Destroy()
                    return
                end
                local p = m.Position
                local h = m.Size.Y.Offset
                TweenService:Create(m, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 200, 0, 0),
                    Position = UDim2.new(0, p.X.Offset, 0, p.Y.Offset + h / 2),
                    BackgroundTransparency = 1
                }):Play()
                for _, child in ipairs(m:GetDescendants()) do
                    if child:IsA("GuiObject") and child ~= m then
                        local props = {BackgroundTransparency = 1}
                        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                            props.TextTransparency = 1
                        end
                        TweenService:Create(child, TweenInfo.new(0.15), props):Play()
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
            closeToolMenu(true)

            local cPos = GUI.Content.AbsolutePosition
            local cSize = GUI.Content.AbsoluteSize
            local menuW = 200
            local menuH = 250
            local targetX = cPos.X + (cSize.X / 2) - (menuW / 2)
            local targetY = cPos.Y + (cSize.Y / 2) - (menuH / 2)

            toolMenu = Instance.new("TextButton")
            toolMenu.Name = "EggsMenu"
            toolMenu.Size = UDim2.new(0, menuW, 0, 0)
            toolMenu.Position = UDim2.new(0, targetX, 0, targetY + menuH / 2)
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
            header.Text = "Select Egg"
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
            closeX.MouseButton1Click:Connect(function() closeToolMenu(false) end)

            local list = Instance.new("ScrollingFrame", toolMenu)
            list.Size = UDim2.new(1, -16, 1, -48)
            list.Position = UDim2.new(0, 8, 0, 40)
            list.BackgroundTransparency = 1
            list.BorderSizePixel = 0
            list.CanvasSize = UDim2.new(0, 0, 0, 0)
            list.AutomaticCanvasSize = Enum.AutomaticSize.Y
            list.ScrollBarThickness = 3
            list.ScrollBarImageColor3 = T.accent
            list.ScrollBarImageTransparency = 0.4
            list.ScrollingDirection = Enum.ScrollingDirection.Y
            list.ZIndex = 101

            local ll = Instance.new("UIListLayout", list)
            ll.Padding = UDim.new(0, 4)
            ll.SortOrder = Enum.SortOrder.LayoutOrder

            local listPad = Instance.new("UIPadding", list)
            listPad.PaddingBottom = UDim.new(0, 4)
            listPad.PaddingRight = UDim.new(0, 2)

            local eggRefs = {}

            local function updateVisuals()
                for name, ref in pairs(eggRefs) do
                    local isCurrent = Core.settings.hatchEggsSelected[name] == true
                    TweenService:Create(ref.Pill, TweenInfo.new(0.15), {BackgroundColor3 = isCurrent and T.accent or T.toggleOff}):Play()
                    TweenService:Create(ref.Knob, TweenInfo.new(0.15), {Position = isCurrent and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)}):Play()
                end
            end

            local mOrder = 1
            for _, eggName in ipairs(Core.EGGS_LIST) do
                local isActive = Core.settings.hatchEggsSelected[eggName] == true
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
                lbl.Text = eggName
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

                eggRefs[eggName] = { Pill = pill, Knob = knob }

                btn.MouseButton1Click:Connect(function()
                    local currentState = Core.settings.hatchEggsSelected[eggName] == true
                    Core.settings.hatchEggsSelected = {}
                    if not currentState then
                        Core.settings.hatchEggsSelected[eggName] = true
                    end
                    Core.saveSetting("hatchEggsSelected", Core.settings.hatchEggsSelected)
                    updateVisuals()
                end)
                mOrder = mOrder + 1
            end

            TweenService:Create(toolMenu, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, menuW, 0, menuH),
                Position = UDim2.new(0, targetX, 0, targetY)
            }):Play()
            menuOpen = true
        end

        gearBtn.MouseButton1Click:Connect(function()
            if menuOpen then closeToolMenu(false) else openToolMenu() end
        end)

        RunService.RenderStepped:Connect(function()
            if menuOpen and toolMenu then
                if not page.Visible or not GUI.Main.Visible or GUI.Main.Size.X.Offset < GUI.BASE_W then
                    closeToolMenu(true)
                end
            end
        end)
    end

    if Core.settings.hatchEggs then
        startHatching()
    end
end