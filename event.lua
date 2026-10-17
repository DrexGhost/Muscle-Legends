local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["EVENT"]
local UI = NexusX.UI
local Settings = NexusX.Settings
local State = NexusX.State
local RunService = NexusX.RunService

local eventBossBtns = {}
local autoFarmToggle, autoFarmDot
local lastAttack = 0
local lastSizeCheck = 0
local searchStartTime = 0

local function getBoss()
    for _, name in ipairs(NexusX.EVENT_BOSS_ORDER) do
        if Settings.autoFarmBoss or Settings.selectedBosses[name] then
            local bossData = NexusX.EVENT_BOSSES[name]
            if bossData then
                local model = workspace:FindFirstChild(bossData.modelName)
                if model then
                    local part = model:FindFirstChild(bossData.partName)
                    if part and part:IsA("BasePart") then
                        local hp = model:GetAttribute("Health") or part:GetAttribute("Health") or 100
                        if hp > 0 then return model, part, name end
                    end
                end
            end
        end
    end
    return nil, nil, nil
end

function NexusX.Features.disableAutoFarmBoss()
    Settings.autoFarmBoss = false
    if autoFarmToggle then
        autoFarmToggle.BackgroundColor3 = NexusX.Colors.toggleOff
        if autoFarmDot then autoFarmDot.Position = UDim2.new(0, 2, 0.5, -8) end
    end
    local char = NexusX.Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

function NexusX.Features.disableAllEventBosses()
    for name, _ in pairs(Settings.selectedBosses) do
        Settings.selectedBosses[name] = false
    end
    for name, btn in pairs(eventBossBtns) do
        btn.BackgroundColor3 = NexusX.Colors.button
        btn.Text = name .. ": OFF"
    end
end

function NexusX.Features.hasAnyBossSelected()
    for _, v in pairs(Settings.selectedBosses) do
        if v then return true end
    end
    return false
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
            NexusX.Features.disableAutoFarmBoss()
            searchStartTime = os.clock()
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

autoFarmToggle = Instance.new("TextButton", autoFarmFrame)
autoFarmToggle.Size = UDim2.new(0, 40, 0, 20)
autoFarmToggle.Position = UDim2.new(1, -40, 0.5, -10)
autoFarmToggle.BackgroundColor3 = Settings.autoFarmBoss and NexusX.Colors.toggleOn or NexusX.Colors.toggleOff
autoFarmToggle.BorderSizePixel = 0
autoFarmToggle.Text = ""
Instance.new("UICorner", autoFarmToggle).CornerRadius = UDim.new(1, 0)

autoFarmDot = Instance.new("Frame", autoFarmToggle)
autoFarmDot.Size = UDim2.new(0, 16, 0, 16)
autoFarmDot.Position = Settings.autoFarmBoss and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
autoFarmDot.BackgroundColor3 = NexusX.Colors.text
autoFarmDot.BorderSizePixel = 0
Instance.new("UICorner", autoFarmDot).CornerRadius = UDim.new(1, 0)

autoFarmToggle.MouseButton1Click:Connect(function()
    Settings.autoFarmBoss = not Settings.autoFarmBoss
    NexusX.saveSetting("autoFarmBoss", Settings.autoFarmBoss)
    if Settings.autoFarmBoss then
        autoFarmToggle.BackgroundColor3 = NexusX.Colors.toggleOn
        NexusX.TweenService:Create(autoFarmDot, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
        if NexusX.Features.disableFarmBoss then NexusX.Features.disableFarmBoss() end
        NexusX.Features.disableAllEventBosses()
        searchStartTime = os.clock()
    else
        autoFarmToggle.BackgroundColor3 = NexusX.Colors.toggleOff
        NexusX.TweenService:Create(autoFarmDot, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
    end
end)

RunService.Heartbeat:Connect(function()
    if not (Settings.autoFarmBoss or NexusX.Features.hasAnyBossSelected()) then return end

    local char = NexusX.Player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local bModel, bPart, bossName = getBoss()

    if bModel then
        searchStartTime = os.clock()
    else
        if searchStartTime > 0 and os.clock() - searchStartTime >= 1 then
            NexusX.Features.disableAutoFarmBoss()
            NexusX.Features.disableAllEventBosses()
            hum.AutoRotate = true
        end
        return
    end

    if os.clock() - lastSizeCheck >= 1 then
        lastSizeCheck = os.clock()
        if math.abs((hrp.Size.X / 2) - 2) > 0.1 then
            NexusX.setSize(2)
        end
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    hum.AutoRotate = false

    local attackKind = bModel:GetAttribute("BossAttackKind")
    local targetPos

    if attackKind == "Stomp" then
        targetPos = bPart.Position + Vector3.new(0, 51, 0)
    else
        local look = bPart.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude < 0.1 then
            flatLook = Vector3.new(0, 0, -1)
        else
            flatLook = flatLook.Unit
        end
        targetPos = bPart.Position - (flatLook * 20) + Vector3.new(0, 3, 0)
    end

    local lookAtTarget = bPart.Position
    if (targetPos - lookAtTarget).Magnitude < 1 then
        lookAtTarget = targetPos + Vector3.new(0, 0, -1)
    end

    hrp.CFrame = CFrame.lookAt(targetPos, lookAtTarget)
    
    NexusX.createHitbox(bPart)

    local now = os.clock()
    if now - lastAttack >= 0.4 then
        lastAttack = now
        NexusX.punch()
    end
end)

table.insert(NexusX.Features.OnSettingsLoaded, function()
    for name, btn in pairs(eventBossBtns) do
        if Settings.selectedBosses[name] then
            btn.BackgroundColor3 = NexusX.Colors.toggleOn
            btn.Text = name .. ": ON"
        else
            btn.BackgroundColor3 = NexusX.Colors.button
            btn.Text = name .. ": OFF"
        end
    end

    if autoFarmToggle then
        if Settings.autoFarmBoss then
            autoFarmToggle.BackgroundColor3 = NexusX.Colors.toggleOn
            if autoFarmDot then autoFarmDot.Position = UDim2.new(1, -18, 0.5, -8) end
            searchStartTime = os.clock()
        else
            autoFarmToggle.BackgroundColor3 = NexusX.Colors.toggleOff
            if autoFarmDot then autoFarmDot.Position = UDim2.new(0, 2, 0.5, -8) end
            searchStartTime = 0
        end
    end
end)
