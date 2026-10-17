local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["AUTO"]
local UI = NexusX.UI
local Settings = NexusX.Settings

local collectStatusLabel
local autoFullToggleRef, autoFullDotRef

function NexusX.Features.startAutoLifting()
    NexusX.startThread("autoLifting", function()
        while Settings.autoLifting do
            if not NexusX.hasDumbbell() then NexusX.equipDumbbell() end
            if NexusX.hasDumbbell() then NexusX.activateTool() end
            task.wait(0.1)
        end
    end)
end

function NexusX.Features.startAutoRebirth()
    NexusX.startThread("autoRebirth", function()
        while Settings.autoRebirth do
            if NexusX.rEvents then
                local rr = NexusX.rEvents:FindFirstChild("rebirthRemote")
                if rr then pcall(function() rr:InvokeServer("rebirthRequest") end) end
            end
            task.wait(3)
        end
    end)
end

function NexusX.Features.startAutoClicker()
    NexusX.startThread("autoClicker", function()
        while Settings.autoClicker do NexusX.doClicker(); task.wait(0.01) end
    end)
end

function NexusX.Features.startAutoCollect()
    local collectIndex = 0
    NexusX.startThread("autoCollect", function()
        while Settings.autoCollect and collectIndex < #NexusX.CHESTS do
            collectIndex = collectIndex + 1
            local chest = NexusX.CHESTS[collectIndex]
            if collectStatusLabel then collectStatusLabel.Text = "Collecting: " .. chest.name .. " (" .. collectIndex .. "/" .. #NexusX.CHESTS .. ")" end
            local hrp = NexusX.Player.Character and NexusX.Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(chest.coords + Vector3.new(0, 3, 0)) end
            task.wait(2)
        end
        Settings.autoCollect = false
        if collectStatusLabel then collectStatusLabel.Text = "Collect: Done" end
    end)
end

local function startAutoFullThreads()
    NexusX.startThread("autoFullA", function()
        while Settings.autoFull do
            if Settings.autoFullSize then
                local char = NexusX.Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and math.abs((hrp.Size.X / 2) - 2) > 0.1 then NexusX.setSize(2) end
            end
            if Settings.autoFullTeleport then
                local hrp = NexusX.Player.Character and NexusX.Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(-8748, 124, -5859) end
            end
            if Settings.autoFullLifting then
                if not NexusX.hasDumbbell() then NexusX.equipDumbbell() end
                if NexusX.hasDumbbell() then NexusX.activateTool() end
            end
            task.wait(0.1)
        end
    end)
    NexusX.startThread("autoFullB", function()
        while Settings.autoFull do
            if Settings.autoFullRebirth and NexusX.rEvents then
                local rr = NexusX.rEvents:FindFirstChild("rebirthRemote")
                if rr then pcall(function() rr:InvokeServer("rebirthRequest") end) end
            end
            task.wait(1)
        end
    end)
end

local function stopAutoFullThreads()
    NexusX.stopThread("autoFullA")
    NexusX.stopThread("autoFullB")
end

UI.createToggle(content, "AUTO LIFTING", 15, Settings.autoLifting, function(v)
    Settings.autoLifting = v
    if v then NexusX.Features.startAutoLifting() else NexusX.stopThread("autoLifting") end
end, "autoLifting")

UI.createToggle(content, "AUTO REBIRTH", 55, Settings.autoRebirth, function(v)
    Settings.autoRebirth = v
    if v then NexusX.Features.startAutoRebirth() else NexusX.stopThread("autoRebirth") end
end, "autoRebirth")

UI.createToggle(content, "AUTO SIZE", 95, Settings.autoSize, function(v)
    Settings.autoSize = v
    if v then NexusX.setSize(2) end
end, "autoSize")

UI.createToggle(content, "AUTO CLICKER", 135, Settings.autoClicker, function(v)
    Settings.autoClicker = v
    if v then NexusX.Features.startAutoClicker() else NexusX.stopThread("autoClicker") end
end, "autoClicker")

UI.createToggle(content, "AUTO COLLECT", 175, Settings.autoCollect, function(v)
    Settings.autoCollect = v
    if v then NexusX.Features.startAutoCollect() else NexusX.stopThread("autoCollect"); if collectStatusLabel then collectStatusLabel.Text = "Collect: Stopped" end end
end, "autoCollect")

collectStatusLabel = UI.addText(content, "Collect: Idle", Color3.fromRGB(150, 200, 255), 13, 215)

local autoFullFrame = Instance.new("Frame", content)
autoFullFrame.Size = UDim2.new(1, -20, 0, 30)
autoFullFrame.Position = UDim2.new(0, 10, 0, 245)
autoFullFrame.BackgroundTransparency = 1

local autoFullLabel = Instance.new("TextLabel", autoFullFrame)
autoFullLabel.Size = UDim2.new(0.6, 0, 1, 0)
autoFullLabel.BackgroundTransparency = 1
autoFullLabel.Text = "AUTO FULL"
autoFullLabel.TextColor3 = NexusX.Colors.text
autoFullLabel.TextSize = 14
autoFullLabel.Font = Enum.Font.Gotham
autoFullLabel.TextXAlignment = Enum.TextXAlignment.Left

local gearBtn = Instance.new("TextButton", autoFullFrame)
gearBtn.Size = UDim2.new(0, 26, 0, 26)
gearBtn.Position = UDim2.new(1, -76, 0.5, -13)
gearBtn.BackgroundColor3 = NexusX.Colors.button
gearBtn.BorderSizePixel = 0
gearBtn.Text = "⚙"
gearBtn.TextColor3 = NexusX.Colors.text
gearBtn.TextSize = 16
gearBtn.Font = Enum.Font.GothamBold
gearBtn.AutoButtonColor = false
Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0, 5)
UI.addButtonStroke(gearBtn, Color3.fromRGB(80, 80, 80), 1)

local autoFullToggle = Instance.new("TextButton", autoFullFrame)
autoFullToggle.Size = UDim2.new(0, 40, 0, 20)
autoFullToggle.Position = UDim2.new(1, -40, 0.5, -10)
autoFullToggle.BackgroundColor3 = Settings.autoFull and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
autoFullToggle.BorderSizePixel = 0
autoFullToggle.Text = ""
Instance.new("UICorner", autoFullToggle).CornerRadius = UDim.new(1, 0)

local autoFullDot = Instance.new("Frame", autoFullToggle)
autoFullDot.Size = UDim2.new(0, 16, 0, 16)
autoFullDot.Position = Settings.autoFull and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
autoFullDot.BackgroundColor3 = NexusX.Colors.text
autoFullDot.BorderSizePixel = 0
Instance.new("UICorner", autoFullDot).CornerRadius = UDim.new(1, 0)

autoFullToggleRef = autoFullToggle
autoFullDotRef = autoFullDot

autoFullToggle.MouseButton1Click:Connect(function()
    Settings.autoFull = not Settings.autoFull
    NexusX.saveSetting("autoFull", Settings.autoFull)
    if Settings.autoFull then
        autoFullToggle.BackgroundColor3 = NexusX.Colors.toggleOn
        NexusX.TweenService:Create(autoFullDot, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        startAutoFullThreads()
    else
        autoFullToggle.BackgroundColor3 = NexusX.Colors.toggleOff
        NexusX.TweenService:Create(autoFullDot, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        stopAutoFullThreads()
    end
end)

if Settings.autoFull then startAutoFullThreads() end

local settingsFrame = Instance.new("Frame", content)
settingsFrame.Size = UDim2.new(1, -20, 0, 180)
settingsFrame.Position = UDim2.new(0, 10, 0, 285)
settingsFrame.BackgroundColor3 = NexusX.Colors.bg
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 8)

local settingsTitle = Instance.new("TextLabel", settingsFrame)
settingsTitle.Size = UDim2.new(1, 0, 0, 26)
settingsTitle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
settingsTitle.BorderSizePixel = 0
settingsTitle.Text = "Auto Full Settings"
settingsTitle.TextColor3 = NexusX.Colors.text
settingsTitle.TextSize = 12
settingsTitle.Font = Enum.Font.GothamBold
Instance.new("UICorner", settingsTitle).CornerRadius = UDim.new(0, 8)

local settingsClose = Instance.new("TextButton", settingsTitle)
settingsClose.Size = UDim2.new(0, 22, 0, 22)
settingsClose.Position = UDim2.new(1, -26, 0, 2)
settingsClose.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
settingsClose.BorderSizePixel = 0
settingsClose.Text = "X"
settingsClose.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsClose.TextSize = 12
settingsClose.Font = Enum.Font.GothamBold
Instance.new("UICorner", settingsClose).CornerRadius = UDim.new(0, 5)
settingsClose.MouseButton1Click:Connect(function() settingsFrame.Visible = false end)

local function createSubToggle(text, yPos, getter, setter, settingName)
    local frame = Instance.new("Frame", settingsFrame)
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = NexusX.Colors.text
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 36, 0, 18)
    btn.Position = UDim2.new(1, -36, 0.5, -9)
    btn.BorderSizePixel = 0
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    dot.BackgroundColor3 = NexusX.Colors.text

    if settingName then NexusX.UI.SubToggles[settingName] = {btn = btn, dot = dot} end

    local function update()
        if getter() then
            btn.BackgroundColor3 = NexusX.Colors.toggleOn
            dot.Position = UDim2.new(1, -16, 0.5, -7)
        else
            btn.BackgroundColor3 = NexusX.Colors.toggleOff
            dot.Position = UDim2.new(0, 2, 0.5, -7)
        end
    end
    update()

    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        if settingName then NexusX.saveSetting(settingName, getter()) end
        update()
    end)
end

createSubToggle("Auto Size", 34, function() return Settings.autoFullSize end, function(v) Settings.autoFullSize = v end, "autoFullSize")
createSubToggle("Auto Rebirth", 68, function() return Settings.autoFullRebirth end, function(v) Settings.autoFullRebirth = v end, "autoFullRebirth")
createSubToggle("Auto Teleport", 102, function() return Settings.autoFullTeleport end, function(v) Settings.autoFullTeleport = v end, "autoFullTeleport")
createSubToggle("Auto Lifting", 136, function() return Settings.autoFullLifting end, function(v) Settings.autoFullLifting = v end, "autoFullLifting")

gearBtn.MouseButton1Click:Connect(function() settingsFrame.Visible = not settingsFrame.Visible end)

table.insert(NexusX.Features.OnSettingsLoaded, function()
    NexusX.stopThread("autoLifting")
    NexusX.stopThread("autoRebirth")
    NexusX.stopThread("autoClicker")
    NexusX.stopThread("autoCollect")
    stopAutoFullThreads()

    if Settings.autoLifting then NexusX.Features.startAutoLifting() end
    if Settings.autoRebirth then NexusX.Features.startAutoRebirth() end
    if Settings.autoClicker then NexusX.Features.startAutoClicker() end
    if Settings.autoCollect then NexusX.Features.startAutoCollect() end
    if Settings.autoFull then startAutoFullThreads() end
    if Settings.autoSize then NexusX.setSize(2) end
    
    if autoFullToggleRef then
        autoFullToggleRef.BackgroundColor3 = Settings.autoFull and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
        if autoFullDotRef then autoFullDotRef.Position = Settings.autoFull and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) end
    end
end)
