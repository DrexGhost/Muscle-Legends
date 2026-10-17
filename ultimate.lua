local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["ULTIMATE"]
local UI = NexusX.UI
local Settings = NexusX.Settings

local absoluteStatusLabel = UI.addText(content, "IDLE", Color3.fromRGB(150, 200, 255), 12, 30)
local absoluteUiRows = {}

function NexusX.Features.getFirstPendingUltimate()
    for _, displayName in ipairs(NexusX.ABSOLUTE_ORDER) do
        if Settings.selectedUltimates[displayName] then
            local attrName = NexusX.getUltimateAttr(displayName)
            if attrName then
                local max = NexusX.ABSOLUTE_MAX[attrName] or 5
                local lvl = NexusX.getUltimateLevel(attrName)
                if lvl < max then return displayName, attrName, lvl, max end
            end
        end
    end
    return nil
end

local function doUltimatePurchase(displayName)
    if not NexusX.rEvents then return false end
    local ur = NexusX.rEvents:FindFirstChild("ultimatesRemote")
    if not ur then return false end

    local attrName = NexusX.getUltimateAttr(displayName)
    if not attrName then return false end

    local max = NexusX.ABSOLUTE_MAX[attrName] or 5
    local before = NexusX.getUltimateLevel(attrName)
    if before >= max then return false end

    pcall(function() ur:InvokeServer("upgradeUltimate", displayName) end)
    task.wait(0.6)
    local after = NexusX.getUltimateLevel(attrName)
    return after > before
end

local function startUltimateThread()
    NexusX.startThread("autoUltimate", function()
        while Settings.autoAbsolute do
            local displayName, attrName, lvl, max = NexusX.Features.getFirstPendingUltimate()
            if displayName then
                if absoluteStatusLabel then
                    absoluteStatusLabel.Text = "Working: " .. displayName .. " (" .. lvl .. "/" .. max .. ")"
                end
                doUltimatePurchase(displayName)
            else
                if absoluteStatusLabel then
                    local anySelected = false
                    for _, v in pairs(Settings.selectedUltimates) do if v then anySelected = true break end end
                    absoluteStatusLabel.Text = anySelected and "DONE (все выбранные на MAX)" or "Включи хотя бы один Ultimate"
                end
            end
            task.wait(0.4)
        end
    end)
end

local startBtn = Instance.new("TextButton", content)
startBtn.Size = UDim2.new(0.9, 0, 0, 30)
startBtn.Position = UDim2.new(0.05, 0, 0, 55)
startBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
startBtn.Text = "START AUTO UPGRADE"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 13
startBtn.Font = Enum.Font.GothamBold
startBtn.BorderSizePixel = 0
startBtn.AutoButtonColor = false
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 6)
UI.addButtonStroke(startBtn, Color3.fromRGB(80, 180, 80), 1)

startBtn.MouseButton1Click:Connect(function()
    Settings.autoAbsolute = not Settings.autoAbsolute
    if Settings.autoAbsolute then
        startBtn.Text = "STOP AUTO UPGRADE"
        startBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        startUltimateThread()
    else
        startBtn.Text = "START AUTO UPGRADE"
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
        NexusX.stopThread("autoUltimate")
        if absoluteStatusLabel then absoluteStatusLabel.Text = "IDLE" end
    end
end)

if Settings.autoAbsolute then
    startBtn.Text = "STOP AUTO UPGRADE"
    startBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    startUltimateThread()
end

local rowStart = 95
for idx, displayName in ipairs(NexusX.ABSOLUTE_ORDER) do
    local row = Instance.new("Frame", content)
    row.Size = UDim2.new(1, -20, 0, 28)
    row.Position = UDim2.new(0, 10, 0, rowStart + (idx - 1) * 32)
    row.BackgroundColor3 = NexusX.Colors.bg
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 8, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = displayName
    nameLbl.TextColor3 = NexusX.Colors.text
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local lvlLbl = Instance.new("TextLabel", row)
    lvlLbl.Size = UDim2.new(0, 70, 1, 0)
    lvlLbl.Position = UDim2.new(0.55, 0, 0, 0)
    lvlLbl.BackgroundTransparency = 1
    lvlLbl.Text = "0/5"
    lvlLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    lvlLbl.TextSize = 11
    lvlLbl.Font = Enum.Font.GothamBold

    local toggle = Instance.new("TextButton", row)
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -48, 0.5, -10)
    toggle.BackgroundColor3 = Settings.selectedUltimates[displayName] and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", toggle)
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = Settings.selectedUltimates[displayName] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = NexusX.Colors.text
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    absoluteUiRows[displayName] = {toggle = toggle, dot = dot, level = lvlLbl}

    toggle.MouseButton1Click:Connect(function()
        Settings.selectedUltimates[displayName] = not Settings.selectedUltimates[displayName]
        if Settings.selectedUltimates[displayName] then
            toggle.BackgroundColor3 = NexusX.Colors.toggleOn
            NexusX.TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        else
            toggle.BackgroundColor3 = NexusX.Colors.toggleOff
            NexusX.TweenService:Create(dot, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
        end
    end)
end

NexusX.startThread("absoluteLevelUpdate", function()
    while content.Parent do
        for displayName, refs in pairs(absoluteUiRows) do
            local attrName = NexusX.getUltimateAttr(displayName)
            if attrName then
                local max = NexusX.ABSOLUTE_MAX[attrName] or 5
                local lvl = NexusX.getUltimateLevel(attrName)
                refs.level.Text = lvl .. "/" .. max
                refs.level.TextColor3 = lvl >= max and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 200, 100)
            end
        end
        task.wait(0.5)
    end
end)

table.insert(NexusX.Features.OnSettingsLoaded, function()
    for displayName, refs in pairs(absoluteUiRows) do
        refs.toggle.BackgroundColor3 = Settings.selectedUltimates[displayName] and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
        refs.dot.Position = Settings.selectedUltimates[displayName] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end
    if Settings.autoAbsolute then
        startBtn.Text = "STOP AUTO UPGRADE"
        startBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        startUltimateThread()
    else
        startBtn.Text = "START AUTO UPGRADE"
        startBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
        NexusX.stopThread("autoUltimate")
    end
end)
