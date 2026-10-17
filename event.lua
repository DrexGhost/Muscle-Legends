local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["EVENT"]
local UI = NexusX.UI
local Settings = NexusX.Settings
local State = NexusX.State
local RunService = NexusX.RunService

local eventBossBtns = {}

function NexusX.Features.disableAutoFarmBoss()
    Settings.autoFarmBoss = false
    if NexusX.UI.Toggles["autoFarmBoss"] then
        NexusX.UI.Toggles["autoFarmBoss"].toggle.BackgroundColor3 = NexusX.Colors.toggleOff
        NexusX.UI.Toggles["autoFarmBoss"].dot.Position = UDim2.new(0, 2, 0.5, -8)
    end
end

function NexusX.Features.disableAllEventBosses()
    for name, _ in pairs(Settings.selectedBosses) do Settings.selectedBosses[name] = false end
    for name, btn in pairs(eventBossBtns) do
        btn.BackgroundColor3 = NexusX.Colors.button
        btn.Text = name .. ": OFF"
    end
end

function NexusX.Features.hasAnyBossSelected()
    for _, v in pairs(Settings.selectedBosses) do if v then return true end end
    return false
end

function NexusX.Features.findAnySelectedEventBoss()
    for _, name in ipairs(NexusX.EVENT_BOSS_ORDER) do
        if Settings.autoFarmBoss or Settings.selectedBosses[name] then
            local bossData = NexusX.EVENT_BOSSES[name]
            if bossData then
                local model = workspace:FindFirstChild(bossData.modelName)
                if model then
                    local part = model:FindFirstChild(bossData.partName)
                    if part and part:IsA("BasePart") then return part, name end
                end
            end
        end
    end
    return nil, nil
end

UI.addText(content, "Halloween Event", Color3.fromRGB(255, 150, 50), 18, 5)
local halloweenBtn = Instance.new("TextButton", content)
halloweenBtn.Size = UDim2.new(0.9, 0, 0, 30)
halloweenBtn.Position = UDim2.new(0.05, 0, 0, 40)
halloweenBtn.BackgroundColor3 = NexusX.Colors.button
halloweenBtn.Text = "TP: Halloween Gym"
halloweenBtn.TextColor3 = NexusX.Colors.text
halloweenBtn.TextSize = 13
halloweenBtn.Font = Enum.Font.GothamSemibold
halloweenBtn.BorderSizePixel = 0
Instance.new("UICorner", halloweenBtn).CornerRadius = UDim.new(0, 6)
UI.addButtonStroke(halloweenBtn, Color3.fromRGB(80, 80, 80), 1)
halloweenBtn.MouseButton1Click:Connect(function()
    local hrp = NexusX.Player.Character and NexusX.Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(5558, 85, 5838) end
end)

UI.addText(content, "Boss Farm", Color3.fromRGB(255, 255, 255), 15, 80)
local bossNames = {"EASY", "MEDIUM", "HARD", "EXTREME"}
for idx, bossName in ipairs(bossNames) do
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0.45, 0, 0, 32)
    btn.Position = UDim2.new(0.05 + ((idx-1) % 2) * 0.48, 0, 0, 105 + math.floor((idx-1) / 2) * 38)
    btn.BackgroundColor3 = Settings.selectedBosses[bossName] and NexusX.Colors.toggleOn or NexusX.Colors.button
    btn.Text = bossName .. (Settings.selectedBosses[bossName] and ": ON" or ": OFF")
    btn.TextColor3 = NexusX.EVENT_BOSSES[bossName].color
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    UI.addButtonStroke(btn, Color3.fromRGB(80, 80, 80), 1)
    eventBossBtns[bossName] = btn

    btn.MouseButton1Click:Connect(function()
        local nowOn = not Settings.selectedBosses[bossName]
        Settings.selectedBosses[bossName] = nowOn
        if nowOn then
            btn.BackgroundColor3 = NexusX.Colors.toggleOn
            btn.Text = bossName .. ": ON"
            if NexusX.Features.disableFarmBoss then NexusX.Features.disableFarmBoss() end
        else
            btn.BackgroundColor3 = NexusX.Colors.button
            btn.Text = bossName .. ": OFF"
        end
    end)
end

local autoFarmFrame = Instance.new("Frame", content)
autoFarmFrame.Size = UDim2.new(1, -20, 0, 30)
autoFarmFrame.Position = UDim2.new(0, 10, 0, 210)
autoFarmFrame.BackgroundTransparency = 1

local autoFarmLabel = Instance.new("TextLabel", autoFarmFrame)
autoFarmLabel.Size = UDim2.new(0.7, 0, 1, 0)
autoFarmLabel.BackgroundTransparency = 1
autoFarmLabel.Text = "AUTO FARM BOSS"
autoFarmLabel.TextColor3 = NexusX.Colors.text
autoFarmLabel.TextSize = 14
autoFarmLabel.Font = Enum.Font.Gotham
autoFarmLabel.TextXAlignment = Enum.TextXAlignment.Left

local autoFarmToggle = Instance.new("TextButton", autoFarmFrame)
autoFarmToggle.Size = UDim2.new(0, 40, 0, 20)
autoFarmToggle.Position = UDim2.new(1, -40, 0.5, -10)
autoFarmToggle.BackgroundColor3 = Settings.autoFarmBoss and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
autoFarmToggle.BorderSizePixel = 0
autoFarmToggle.Text = ""
Instance.new("UICorner", autoFarmToggle).CornerRadius = UDim.new(1, 0)

local autoFarmDot = Instance.new("Frame", autoFarmToggle)
autoFarmDot.Size = UDim2.new(0, 16, 0, 16)
autoFarmDot.Position = Settings.autoFarmBoss and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
autoFarmDot.BackgroundColor3 = NexusX.Colors.text
autoFarmDot.BorderSizePixel = 0
Instance.new("UICorner", autoFarmDot).CornerRadius = UDim.new(1, 0)

NexusX.UI.Toggles["autoFarmBoss"] = {toggle = autoFarmToggle, dot = autoFarmDot}

autoFarmToggle.MouseButton1Click:Connect(function()
    Settings.autoFarmBoss = not Settings.autoFarmBoss
    NexusX.saveSetting("autoFarmBoss", Settings.autoFarmBoss)
    if Settings.autoFarmBoss then
        autoFarmToggle.BackgroundColor3 = NexusX.Colors.toggleOn
        NexusX.TweenService:Create(autoFarmDot, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        if NexusX.Features.disableFarmBoss then NexusX.Features.disableFarmBoss() end
    else
        autoFarmToggle.BackgroundColor3 = NexusX.Colors.toggleOff
        NexusX.TweenService:Create(autoFarmDot, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
    end
end)

RunService.Heartbeat:Connect(function()
    if not NexusX.Gui.Main.Parent then return end
    if Settings.autoFarmBoss or NexusX.Features.hasAnyBossSelected() then
        local myChar = NexusX.Player.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local bossPart = NexusX.Features.findAnySelectedEventBoss()
            if bossPart then
                State.searchStartTime = os.clock()
                myRoot.CFrame = bossPart.CFrame + Vector3.new(0, 55, 0)
                NexusX.createHitbox(bossPart)
                local now = os.clock()
                if now - State.lastAttack >= 0.4 then
                    State.lastAttack = now
                    NexusX.punch()
                end
            end
        end
    end
end)
