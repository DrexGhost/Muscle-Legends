local Core, GUI = ...
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function build()
    local tab = GUI.makeTab("Helper", 2, "helper")
    local page = GUI.makePage()
    local T = Core.T

    GUI.makeSectionHeader(page, "Automation", 1)

    local autoStrThread, autoRebThread, autoClickThread, autoSpinThread, autoMachineThread

    local function safeCancel(t)
        if t then pcall(task.cancel, t) end
    end

    local function getMachinesForDropdown()
        local machinesFolder = workspace:FindFirstChild("machinesFolder")
        if not machinesFolder then return {} end
        local res = {}
        for _, m in ipairs(machinesFolder:GetChildren()) do
            if m:FindFirstChild("interactSeat") then
                table.insert(res, { name = m.Name, text = m.Name })
            end
        end
        return res
    end

    local function makeDropdownToggle(parent, name, desc, defaultToggle, order, onToggleChange, toggleSettingName, menuTitle, itemsProvider, defaultItemText, onItemSelect)
        local toggleObj = GUI.makeToggle(parent, name, desc, defaultToggle, order, onToggleChange, toggleSettingName)
        
        if not (toggleObj.Row and toggleObj.NameLabel and toggleObj.DescLabel) then
            return toggleObj
        end
        
        local row = toggleObj.Row
        local nameLbl = toggleObj.NameLabel
        local descLbl = toggleObj.DescLabel
        
        nameLbl.Size = UDim2.new(1, -116, 0, 16)
        descLbl.Size = UDim2.new(1, -116, 0, 14)
        
        local iconBtn = Instance.new("TextButton", row)
        iconBtn.Size = UDim2.new(0, 30, 0, 30)
        iconBtn.Position = UDim2.new(1, -92, 0.5, -15)
        iconBtn.BackgroundColor3 = T.panelHi
        iconBtn.BorderSizePixel = 0
        iconBtn.Text = ""
        iconBtn.AutoButtonColor = false
        iconBtn.ZIndex = 3
        Instance.new("UICorner", iconBtn).CornerRadius = UDim.new(0, 7)
        
        local iconStroke = Instance.new("UIStroke", iconBtn)
        iconStroke.Color = T.stroke
        iconStroke.Thickness = 1
        iconStroke.Transparency = 0.3
        iconStroke.Parent = iconBtn
        
        local iconHolder = Instance.new("Frame", iconBtn)
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
        
        local iconRows = {{y = 2, x = 9}, {y = 7, x = 4}, {y = 12, x = 11}}
        for _, l in ipairs(iconRows) do
            drawIconPart(UDim2.new(0, 14, 0, 2), UDim2.new(0, 1, 0, l.y), 4)
            drawIconPart(UDim2.new(0, 4, 0, 4), UDim2.new(0, l.x, 0, l.y - 1), 5)
        end
        
        iconBtn.MouseEnter:Connect(function()
            TweenService:Create(iconBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.cardHover}):Play()
            TweenService:Create(iconStroke, TweenInfo.new(0.15), {Color = T.accent, Transparency = 0.5}):Play()
            for _, child in ipairs(iconHolder:GetChildren()) do
                if child:IsA("Frame") then
                    TweenService:Create(child, TweenInfo.new(0.15), {BackgroundColor3 = T.accent}):Play()
                end
            end
        end)
        
        iconBtn.MouseLeave:Connect(function()
            TweenService:Create(iconBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.panelHi}):Play()
            TweenService:Create(iconStroke, TweenInfo.new(0.15), {Color = T.stroke, Transparency = 0.3}):Play()
            for _, child in ipairs(iconHolder:GetChildren()) do
                if child:IsA("Frame") then
                    TweenService:Create(child, TweenInfo.new(0.15), {BackgroundColor3 = T.text}):Play()
                end
            end
        end)
        
        local dropdown = nil
        local menuOpen = false
        
        local function closeMenu(instant)
            if dropdown then
                menuOpen = false
                local m = dropdown
                dropdown = nil
                
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
                        TweenService:Create(child, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
                    end
                    if child:IsA("UIStroke") then
                        TweenService:Create(child, TweenInfo.new(0.15), {Transparency = 1}):Play()
                    end
                end
                
                task.delay(0.15, function() if m then m:Destroy() end end)
            end
        end
        
        local function openMenu()
            if not GUI.Main.Visible or not parent.Visible then return end
            closeMenu(true)
            
            local items = itemsProvider()
            
            local cPos = GUI.Content.AbsolutePosition
            local cSize = GUI.Content.AbsoluteSize
            
            local menuW = 200
            local maxH = 300
            local listH = #items * 38
            local menuH = math.min(maxH, 40 + listH + 8)
            
            local targetX = cPos.X + (cSize.X / 2) - (menuW / 2)
            local targetY = cPos.Y + (cSize.Y / 2) - (menuH / 2)
            
            dropdown = Instance.new("TextButton")
            dropdown.Name = menuTitle .. "Menu"
            dropdown.Size = UDim2.new(0, menuW, 0, 0)
            dropdown.Position = UDim2.new(0, targetX, 0, targetY + menuH / 2)
            dropdown.BackgroundColor3 = T.panel
            dropdown.BorderSizePixel = 0
            dropdown.Text = ""
            dropdown.AutoButtonColor = false
            dropdown.ZIndex = 100
            dropdown.ClipsDescendants = true
            dropdown.Parent = GUI.screenGui
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 10)
            
            local mStroke = Instance.new("UIStroke", dropdown)
            mStroke.Color = T.stroke
            mStroke.Thickness = 1
            mStroke.Transparency = 0.3
            mStroke.Parent = dropdown
            
            local header = Instance.new("TextLabel", dropdown)
            header.Size = UDim2.new(1, -40, 0, 26)
            header.Position = UDim2.new(0, 12, 0, 8)
            header.BackgroundTransparency = 1
            header.Text = menuTitle
            header.TextColor3 = T.text
            header.TextSize = 12
            header.Font = Enum.Font.GothamBold
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.ZIndex = 101
            
            local closeX = Instance.new("TextButton", dropdown)
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
            closeX.MouseButton1Click:Connect(function() closeMenu(false) end)
            
            local scroll = Instance.new("ScrollingFrame", dropdown)
            scroll.Size = UDim2.new(1, -16, 1, -46)
            scroll.Position = UDim2.new(0, 8, 0, 40)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.CanvasSize = UDim2.new(0, 0, 0, listH)
            scroll.ScrollBarThickness = 3
            scroll.ScrollBarImageColor3 = T.accent
            scroll.ZIndex = 101
            
            local list = Instance.new("Frame", scroll)
            list.Size = UDim2.new(1, 0, 0, 0)
            list.AutomaticSize = Enum.AutomaticSize.Y
            list.BackgroundTransparency = 1
            list.ZIndex = 101
            
            local ll = Instance.new("UIListLayout", list)
            ll.Padding = UDim.new(0, 4)
            ll.SortOrder = Enum.SortOrder.LayoutOrder
            
            local mOrder = 1
            for _, item in ipairs(items) do
                local isActive = (Core.settings[toggleSettingName .. "Selected"] == item.name) or (toggleSettingName == "autoStrength" and Core.settings.strengthTool == item.name)
                
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
                lbl.Text = item.text
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
                    onItemSelect(item.name)
                    if toggleObj.Desc then
                        toggleObj.Desc.Text = "Выбрано: " .. item.text
                    end
                    
                    for _, otherBtn in ipairs(list:GetChildren()) do
                        if otherBtn:IsA("TextButton") then
                            local p = otherBtn:FindFirstChild("Pill")
                            local k = p and p:FindFirstChild("Knob")
                            if p and k then
                                local otherLbl = otherBtn:FindFirstChildOfClass("TextLabel")
                                local isCurrent = otherLbl and otherLbl.Text == item.text
                                TweenService:Create(p, TweenInfo.new(0.15), {BackgroundColor3 = isCurrent and T.accent or T.toggleOff}):Play()
                                TweenService:Create(k, TweenInfo.new(0.15), {Position = isCurrent and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)}):Play()
                            end
                        end
                    end
                end)
                
                mOrder = mOrder + 1
            end
            
            if #items == 0 then
                local emptyLbl = Instance.new("TextLabel", list)
                emptyLbl.Size = UDim2.new(1, 0, 0, 34)
                emptyLbl.BackgroundTransparency = 1
                emptyLbl.Text = "Ничего не найдено"
                emptyLbl.TextColor3 = T.textDim
                emptyLbl.TextSize = 12
                emptyLbl.Font = Enum.Font.Gotham
                emptyLbl.ZIndex = 102
            end
            
            TweenService:Create(dropdown, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, menuW, 0, menuH),
                Position = UDim2.new(0, targetX, 0, targetY)
            }):Play()
            
            menuOpen = true
        end
        
        iconBtn.MouseButton1Click:Connect(function()
            if menuOpen then closeMenu(false) else openMenu() end
        end)
        
        RunService.RenderStepped:Connect(function()
            if menuOpen and dropdown then
                if not parent.Visible or not GUI.Main.Visible or GUI.Main.Size.X.Offset < GUI.BASE_W then
                    closeMenu(true)
                end
            end
        end)
        
        return toggleObj
    end

    local function startAutoStr()
        safeCancel(autoStrThread)
        autoStrThread = task.spawn(function()
            while Core.settings.autoStrength do
                if Core.Char and Core.Char:FindFirstChildOfClass("Humanoid") then
                    local targetName = Core.settings.strengthTool or "Weight"
                    Core.unequipOtherTools(targetName)
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

    local function startAutoSpin()
        safeCancel(autoSpinThread)
        autoSpinThread = task.spawn(function()
            local failCount = 0
            while Core.settings.autoSpin do
                local rEvents = RS:FindFirstChild("rEvents")
                local wheelRemote = rEvents and rEvents:FindFirstChild("openFortuneWheelRemote")
                local shared = RS:FindFirstChild("shared")
                local wheelObj = shared and shared.catalogs and shared.catalogs.fortuneWheelChances and shared.catalogs.fortuneWheelChances:FindFirstChild("Fortune Wheel")

                if wheelRemote and wheelObj then
                    local ok, result = pcall(function()
                        if wheelRemote:IsA("RemoteFunction") then
                            return wheelRemote:InvokeServer("openFortuneWheel", wheelObj)
                        elseif wheelRemote:IsA("RemoteEvent") then
                            wheelRemote:FireServer("openFortuneWheel", wheelObj)
                            return true
                        end
                    end)

                    if ok and (type(result) == "table" and result.name or result == true) then
                        failCount = 0
                    else
                        failCount = failCount + 1
                        if failCount >= 3 then
                            Core.settings.autoSpin = false
                            if Core.toggleRefs["autoSpin"] then
                                Core.toggleRefs["autoSpin"].setEnabled(false, true)
                            end
                            break
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end

    local function startAutoMachine()
        safeCancel(autoMachineThread)
        autoMachineThread = task.spawn(function()
            while Core.settings.autoMachine do
                local machines = getMachinesForDropdown()
                local targetName = Core.settings.machineSelected
                local machine = nil
                for _, m in ipairs(machines) do
                    if m.name == targetName then machine = m; break end
                end
                if not machine and #machines > 0 then
                    machine = machines[1]
                end
                
                if machine and Core.HRP and Core.Hum then
                    Core.HRP.AssemblyLinearVelocity = Vector3.zero
                    Core.HRP.AssemblyAngularVelocity = Vector3.zero
                    Core.HRP.CFrame = CFrame.new(machine.seat.Position + Vector3.new(0, 5, 0))
                    task.wait(0.2)
                    
                    local rEvents = RS:FindFirstChild("rEvents")
                    local machineRemote = rEvents and rEvents:FindFirstChild("machineInteractRemote")
                    local muscleEvent = Core.Char and Core.Char:FindFirstChild("muscleEvent") or LocalPlayer:FindFirstChild("muscleEvent")
                    
                    if machineRemote then
                        pcall(function()
                            machineRemote:InvokeServer("useMachine", machine.seat)
                        end)
                    end
                    task.wait(0.5)
                    
                    for _ = 1, 10 do
                        if not Core.settings.autoMachine then break end
                        if muscleEvent then
                            pcall(function()
                                muscleEvent:FireServer("rep", machine.seat)
                                muscleEvent:FireServer("rep")
                            end)
                        end
                        task.wait(0.2)
                    end
                else
                    task.wait(1)
                end
            end
        end)
    end

    local autoStrToggle = makeDropdownToggle(
        page, "Auto Strength ", "Качает: " .. (Core.settings.strengthTool or "Weight"),
        Core.settings.autoStrength, 2, function(v)
            Core.settings.autoStrength = v
            if v then startAutoStr() else safeCancel(autoStrThread) end
        end, "autoStrength",
        "Swing",
        function()
            local list = {}
            for _, tool in ipairs(Core.STRENGTH_TOOLS) do
                table.insert(list, { name = tool, text = tool })
            end
            return list
        end,
        "Не выбран",
        function(itemName)
            Core.settings.strengthTool = itemName
            Core.saveSetting("strengthTool", itemName)
        end
    )

    GUI.makeToggle(page, "Auto Rebirth ", "Автоматическое перерождение", Core.settings.autoRebirth, 3, function(v)
        Core.settings.autoRebirth = v
        if v then startAutoReb() else safeCancel(autoRebThread) end
    end, "autoRebirth")

    GUI.makeToggle(page, "Auto Clicker", "Автоматические клики", Core.settings.autoClicker, 4, function(v)
        Core.settings.autoClicker = v
        if v then startAutoClick() else safeCancel(autoClickThread) end
    end, "autoClicker")

    GUI.makeToggle(page, "Auto Spin ", "Автоматически крутит колесо фортуны", Core.settings.autoSpin, 5, function(v)
        Core.settings.autoSpin = v
        if v then startAutoSpin() else safeCancel(autoSpinThread) end
    end, "autoSpin")

    local autoMachineToggle = makeDropdownToggle(
        page, "Auto Machine", "Качает на: " .. (Core.settings.machineSelected ~= "" and Core.settings.machineSelected or "Не выбран"),
        Core.settings.autoMachine, 6, function(v)
            Core.settings.autoMachine = v
            if v then startAutoMachine() else safeCancel(autoMachineThread) end
        end, "autoMachine",
        "Machine",
        getMachinesForDropdown,
        "Не выбран",
        function(itemName)
            Core.settings.machineSelected = itemName
            Core.saveSetting("machineSelected", itemName)
        end
    )

    if Core.settings.autoStrength then startAutoStr() end
    if Core.settings.autoRebirth then startAutoReb() end
    if Core.settings.autoClicker then startAutoClick() end
    if Core.settings.autoSpin then startAutoSpin() end
    if Core.settings.autoMachine then startAutoMachine() end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build