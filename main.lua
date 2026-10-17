local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["MAIN"]
local UI = NexusX.UI
local Settings = NexusX.Settings

UI.createToggle(content, "FPS", 15, Settings.fps, function(v)
    Settings.fps = v
    NexusX.Gui.FPSOverlay.Visible = v
end, "fps")

UI.createToggle(content, "ANTI-AFK", 55, Settings.antiAfk, function(v)
    Settings.antiAfk = v
end, "antiAfk")

UI.createSlider(content, "BUTTON SIZE", 100, 20, 80, Settings.openBtnSize, function(v)
    Settings.openBtnSize = v
    NexusX.Gui.OpenBtn.Size = UDim2.new(0, v, 0, v)
    NexusX.Gui.OpenBtn.TextSize = math.floor(v * 0.58)
end, "openBtnSize")

local saveBtn = Instance.new("TextButton", content)
saveBtn.Size = UDim2.new(0.42, 0, 0, 32)
saveBtn.Position = UDim2.new(0.05, 0, 0, 170)
saveBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
saveBtn.Text = "CONFIG: SAVE"
saveBtn.TextColor3 = Settings.text or NexusX.Colors.text
saveBtn.TextSize = 12
saveBtn.Font = Enum.Font.GothamBold
saveBtn.BorderSizePixel = 0
saveBtn.AutoButtonColor = false
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
UI.addButtonStroke(saveBtn, Color3.fromRGB(80, 140, 80), 1)

local loadBtn = Instance.new("TextButton", content)
loadBtn.Size = UDim2.new(0.42, 0, 0, 32)
loadBtn.Position = UDim2.new(0.53, 0, 0, 170)
loadBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
loadBtn.Text = "CONFIG: LOAD"
loadBtn.TextColor3 = NexusX.Colors.text
loadBtn.TextSize = 12
loadBtn.Font = Enum.Font.GothamBold
loadBtn.BorderSizePixel = 0
loadBtn.AutoButtonColor = false
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 6)
UI.addButtonStroke(loadBtn, Color3.fromRGB(80, 120, 160), 1)

local configStatus = Instance.new("TextLabel", content)
configStatus.Size = UDim2.new(0.9, 0, 0, 20)
configStatus.Position = UDim2.new(0.05, 0, 0, 210)
configStatus.BackgroundTransparency = 1
configStatus.Text = ""
configStatus.TextColor3 = Color3.fromRGB(150, 200, 255)
configStatus.TextSize = 12
configStatus.Font = Enum.Font.Gotham
configStatus.TextXAlignment = Enum.TextXAlignment.Center

function NexusX.applyLoadedSettings()
    NexusX.Gui.OpenBtn.Position = UDim2.new(Settings.openBtnPos[1], Settings.openBtnPos[2], Settings.openBtnPos[3], Settings.openBtnPos[4])
    NexusX.Gui.OpenBtn.Size = UDim2.new(0, Settings.openBtnSize, 0, Settings.openBtnSize)
    NexusX.Gui.OpenBtn.TextSize = math.floor(Settings.openBtnSize * 0.58)
    NexusX.Gui.FPSOverlay.Position = UDim2.new(Settings.fpsPos[1], Settings.fpsPos[2], Settings.fpsPos[3], Settings.fpsPos[4])
    NexusX.Gui.FPSOverlay.Visible = Settings.fps

    for settingName, refs in pairs(UI.Toggles) do
        local enabled = Settings[settingName]
        refs.toggle.BackgroundColor3 = enabled and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
        refs.dot.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end

    for settingName, refs in pairs(UI.Sliders) do
        local value = Settings[settingName]
        local percent = math.clamp((value - refs.min) / (refs.max - refs.min), 0, 1)
        refs.label.Text = refs.text .. ": " .. value
        refs.fill.Size = UDim2.new(percent, 0, 1, 0)
        refs.dragBtn.Position = UDim2.new(percent, -9, 0.5, -9)
    end
    
    for settingName, refs in pairs(UI.SubToggles) do
        local enabled = Settings[settingName]
        refs.btn.BackgroundColor3 = enabled and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
        refs.dot.Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    end

    for _, func in ipairs(NexusX.Features.OnSettingsLoaded) do
        pcall(func)
    end
end

saveBtn.MouseButton1Click:Connect(function()
    if not NexusX.hasFileSupport() then configStatus.Text = "No file support!" return end
    local ok = NexusX.saveConfigToFile()
    configStatus.Text = ok and "Saved!" or "Save failed!"
    task.delay(2, function() configStatus.Text = "" end)
end)

loadBtn.MouseButton1Click:Connect(function()
    if not NexusX.hasFileSupport() then configStatus.Text = "No file support!" return end
    if not isfile(NexusX.CONFIG_FILE) then configStatus.Text = "No config file!" return end
    local success, data = pcall(function() return NexusX.HttpService:JSONDecode(readfile(NexusX.CONFIG_FILE)) end)
    if success and data then
        for k, v in pairs(data) do
            if Settings[k] ~= nil and k ~= "menuOpen" then
                if (k == "selectedBosses" or k == "selectedUltimates") and type(v) == "table" then
                    for bk, bv in pairs(v) do Settings[k][bk] = bv end
                else
                    Settings[k] = v
                end
            end
        end
        NexusX.applyLoadedSettings()
        configStatus.Text = "Config loaded!"
    else
        configStatus.Text = "Failed to load!"
    end
    task.delay(2, function() configStatus.Text = "" end)
end)

NexusX.startThread("antiAfk", function()
    while NexusX.Gui.Main.Parent do
        if Settings.antiAfk then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
        task.wait(math.random(90, 180))
    end
end)
