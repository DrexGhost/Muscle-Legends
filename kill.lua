local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["KILL"]
local UI = NexusX.UI
local Settings = NexusX.Settings
local State = NexusX.State
local RunService = NexusX.RunService

local farmBossToggleBtn, farmBossToggleDot
local lastAttack = 0
local lastSizeCheck = 0

local function getBoss()
    local events = workspace:FindFirstChild("Events")
    if not events then return nil end
    local arena = events:FindFirstChild("BossArena")
    if not arena then return nil end
    for _, model in ipairs(arena:GetChildren()) do
        local part = model:FindFirstChild("Boss")
        if part and part:IsA("BasePart") then
            local hp = model:GetAttribute("Health") or part:GetAttribute("Health") or 100
            if hp > 0 then return model, part end
        end
    end
    return nil, nil
end

local function disableFarmBoss()
    State.searchStartTime = nil
    lastAttack = 0
    Settings.farmBoss = false
    if farmBossToggleBtn then
        farmBossToggleBtn.BackgroundColor3 = NexusX.Colors.toggleOff
        if farmBossToggleDot then farmBossToggleDot.Position = UDim2.new(0, 2, 0.5, -8) end
    end
    local char = NexusX.Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

local farmBossToggleFrame = UI.createToggle(content, "FARM BOSS", 15, Settings.farmBoss, function(v)
    if v then
        if NexusX.Features.disableAutoFarmBoss then NexusX.Features.disableAutoFarmBoss() end
        if NexusX.Features.disableAllEventBosses then NexusX.Features.disableAllEventBosses() end
        Settings.farmBoss = true
        State.searchStartTime = os.clock()
        lastAttack = 0
    else
        Settings.farmBoss = false
        State.searchStartTime = nil
        lastAttack = 0
    end
end, "farmBoss", true)

farmBossToggleBtn = farmBossToggleFrame:FindFirstChildWhichIsA("TextButton")
if farmBossToggleBtn then farmBossToggleDot = farmBossToggleBtn:FindFirstChildWhichIsA("Frame") end

if Settings.farmBoss then
    State.searchStartTime = os.clock()
    lastAttack = 0
end

RunService.Heartbeat:Connect(function()
    if not Settings.farmBoss then return end

    local char = NexusX.Player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local bModel, bPart = getBoss()

    if bModel then
        State.searchStartTime = os.clock()
    else
        if State.searchStartTime and os.clock() - State.searchStartTime >= 1 then
            disableFarmBoss()
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
    if farmBossToggleBtn then
        if Settings.farmBoss then
            farmBossToggleBtn.BackgroundColor3 = NexusX.Colors.toggleOn
            if farmBossToggleDot then farmBossToggleDot.Position = UDim2.new(1, -18, 0.5, -8) end
            State.searchStartTime = os.clock()
            lastAttack = 0
        else
            farmBossToggleBtn.BackgroundColor3 = NexusX.Colors.toggleOff
            if farmBossToggleDot then farmBossToggleDot.Position = UDim2.new(0, 2, 0.5, -8) end
            State.searchStartTime = nil
            lastAttack = 0
        end
    end
end)
