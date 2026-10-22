local Core, GUI = ...

local function refreshAllUI()
    for name, ref in pairs(Core.toggleRefs) do
        local val = Core.settings[name]
        if val ~= nil then ref.setEnabled(val, true) end
    end

    for _, name in ipairs(Core.ABSOLUTE_ORDER) do
        local key = "ult_" .. name:gsub("%s+", "")
        local ref = Core.toggleRefs[key]
        if ref then
            ref.setEnabled(Core.settings.ultimates[name] or false, true)
        end
    end

    for _, bName in ipairs(Core.EVENT_BOSS_ORDER) do
        local key = "boss_" .. bName
        local ref = Core.toggleRefs[key]
        if ref then
            ref.setEnabled(Core.settings.eventBosses[bName] == true, true)
        end
    end

    for name, ref in pairs(Core.sliderRefs) do
        local val = Core.settings[name]
        if val ~= nil then ref.setValue(val, true) end
    end

    GUI.setScale((Core.settings.guiScale or 85) / 100)
    GUI.setButtonSize(Core.settings.floatBtnSize or 58)
    if Core.settings.floatBtnPos then GUI.setButtonPos(Core.settings.floatBtnPos) end
    if Core.Watermark then
        Core.Watermark.setEnabled(Core.settings.watermark or false)
        Core.Watermark.setScale((Core.settings.watermarkScale or 100) / 100)
    end
end

local function build()
    local tab = GUI.makeTab("Settings", 7, "settings")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Configs", 1)

    local inputRow = Instance.new("Frame", page)
    inputRow.Size = UDim2.new(1, 0, 0, 42); inputRow.BackgroundColor3 = Core.T.card; inputRow.BorderSizePixel = 0; inputRow.LayoutOrder = 2
    Instance.new("UICorner", inputRow).CornerRadius = UDim.new(0, 10)

    local nameInput = Instance.new("TextBox", inputRow)
    nameInput.Size = UDim2.new(1, -100, 1, 0); nameInput.Position = UDim2.new(0, 12, 0, 0)
    nameInput.BackgroundTransparency = 1
    nameInput.Text = ""
    nameInput.PlaceholderText = "Config name..."
    nameInput.PlaceholderColor3 = Core.T.textMuted
    nameInput.TextColor3 = Core.T.text
    nameInput.TextSize = 12
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextXAlignment = Enum.TextXAlignment.Left
    nameInput.ClearTextOnFocus = false

    local saveAsBtn = Instance.new("TextButton", inputRow)
    saveAsBtn.Size = UDim2.new(0, 80, 0, 28); saveAsBtn.Position = UDim2.new(1, -92, 0.5, -14); saveAsBtn.BackgroundColor3 = Core.T.accent; saveAsBtn.BorderSizePixel = 0; saveAsBtn.Text = "SAVE"; saveAsBtn.TextColor3 = Color3.fromRGB(10, 14, 24); saveAsBtn.TextSize = 11; saveAsBtn.Font = Enum.Font.GothamBold; saveAsBtn.AutoButtonColor = false
    Instance.new("UICorner", saveAsBtn).CornerRadius = UDim.new(0, 8)

    local configListFrame = Instance.new("Frame", page)
    configListFrame.Size = UDim2.new(1, 0, 0, 0); configListFrame.AutomaticSize = Enum.AutomaticSize.Y; configListFrame.BackgroundTransparency = 1; configListFrame.LayoutOrder = 3
    local configListLayout = Instance.new("UIListLayout", configListFrame); configListLayout.Padding = UDim.new(0, 6); configListLayout.Parent = configListFrame

    local function refreshConfigList()
        for _, c in ipairs(configListFrame:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        local configs = Core.listConfigs()
        for _, name in ipairs(configs) do
            local row = Instance.new("Frame", configListFrame)
            row.Size = UDim2.new(1, 0, 0, 38); row.BackgroundColor3 = Core.T.card; row.BorderSizePixel = 0
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

            local lbl = Instance.new("TextLabel", row); lbl.Size = UDim2.new(1, -170, 1, 0); lbl.Position = UDim2.new(0, 14, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Core.T.text; lbl.TextSize = 12; lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left

            local loadBtn = Instance.new("TextButton", row); loadBtn.Size = UDim2.new(0, 70, 0, 26); loadBtn.Position = UDim2.new(1, -152, 0.5, -13); loadBtn.BackgroundColor3 = Core.T.blue; loadBtn.Text = "LOAD"; loadBtn.TextColor3 = Color3.fromRGB(255,255,255); loadBtn.TextSize = 10; loadBtn.Font = Enum.Font.GothamBold; loadBtn.AutoButtonColor = false
            Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 7)
            local loadStroke = Instance.new("UIStroke", loadBtn); loadStroke.Color = Core.T.blueHi; loadStroke.Thickness = 1; loadStroke.Parent = loadBtn

            loadBtn.MouseButton1Click:Connect(function()
                if Core.loadConfigFrom(name) then refreshAllUI() end
            end)

            local delBtn = Instance.new("TextButton", row); delBtn.Size = UDim2.new(0, 70, 0, 26); delBtn.Position = UDim2.new(1, -74, 0.5, -13); delBtn.BackgroundColor3 = Core.T.danger; delBtn.Text = "DELETE"; delBtn.TextColor3 = Color3.fromRGB(255,255,255); delBtn.TextSize = 10; delBtn.Font = Enum.Font.GothamBold; delBtn.AutoButtonColor = false
            Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 7)
            local delStroke = Instance.new("UIStroke", delBtn); delStroke.Color = Core.T.danger; delStroke.Thickness = 1; delStroke.Parent = delBtn

            delBtn.MouseButton1Click:Connect(function() Core.deleteConfig(name); refreshConfigList() end)
        end
    end

    saveAsBtn.MouseButton1Click:Connect(function()
        local n = nameInput.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if n == "" then return end
        if Core.saveConfigAs(n) then
            refreshConfigList()
            nameInput.Text = ""
        end
    end)
    refreshConfigList()

    GUI.makeSectionHeader(page, "Appearance", 4)
    GUI.makeSlider(page, "GUI Size", 70, 95, Core.settings.guiScale, 5, function(v)
        Core.settings.guiScale = v
        GUI.setScale(v / 100)
    end, "guiScale")
    GUI.makeSlider(page, "Button Size", 40, 80, Core.settings.floatBtnSize, 6, function(v)
        Core.settings.floatBtnSize = v
        GUI.setButtonSize(v)
    end, "floatBtnSize")

    GUI.makeSlider(page, "Watermark Size", 60, 150, Core.settings.watermarkScale or 100, 7, function(v)
        Core.settings.watermarkScale = v
        if Core.Watermark then Core.Watermark.setScale(v / 100) end
    end, "watermarkScale")

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build