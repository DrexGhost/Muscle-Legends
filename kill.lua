local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["KILL"]
local UI = NexusX.UI
local Settings = NexusX.Settings
local State = NexusX.State
local RunService = NexusX.RunService

local farmBossToggleBtn, farmBossToggleDot
local lastAttack = 0
local lastSizeCheck = 0
local currentBossModel = nil
local currentBossPart = nil
local bv = nil
local lastSearchTime = 0

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
    currentBossModel = nil
    currentBossPart = nil
    if bv then bv:Destroy(); bv = nil end
    local char = NexusX.Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

local farmBossToggleFrame = UI.createToggle(content, "FARM BOSS", 15, Settings.farmBoss, function(v)
    if v then
        if NexusX.Features.disableAutoFarmBoss then NexusX.Features.disableAutoFarmBoss() end
        if NexusX.Features.disableAllEventBosses then NexusX.Features.disableAllEventBosses() end
        Settings.farmBoss = true
        State.searchStartTime = os.clock()
        lastAttack = 0
        lastSearchTime = 0
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
    lastSearchTime = 0
end

RunService.Heartbeat:Connect(function(dt)
    if not Settings.farmBoss then return end

    local char = NexusX.Player.Character
    if not char then disableFarmBoss(); return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if currentBossPart then
        if not currentBossPart.Parent then
            currentBossModel = nil
            currentBossPart = nil
        else
            local hp = currentBossModel:GetAttribute("Health") or currentBossPart:GetAttribute("Health")
            if hp and hp <= 0 then
                currentBossModel = nil
                currentBossPart = nil
                if bv then bv.Velocity = Vector3.zero end
            end
        end
    end

    if not currentBossPart then
        if os.clock() - lastSearchTime >= 5 then
            lastSearchTime = os.clock()
            local bModel, bPart = getBoss()
            if bModel then
                currentBossModel = bModel
                currentBossPart = bPart
            end
        end
        if not currentBossPart then
            if bv then bv.Velocity = Vector3.zero end
            return
        end
    end

    local bPart = currentBossPart
    local bModel = currentBossModel

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
        targetPos = bPart.Position - (flatLook * 15) + Vector3.new(0, 3, 0)
    end

    local distance = (targetPos - hrp.Position).Magnitude

    if distance > 5 then
        hum.PlatformStand = true
        
        if not bv or not bv.Parent then
            bv = Instance.new("BodyVelocity")
            bv.Name = "FarmSpeedBV"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = hrp
        end
        
        local dir = (targetPos - hrp.Position).Unit
        bv.Velocity = dir * 500
        hrp.CFrame = CFrame.lookAt(hrp.Position, bPart.Position)
    else
        if bv then bv.Velocity = Vector3.zero end
        hum.PlatformStand = false
        
        local lookTarget = bPart.Position
        if (targetPos - lookTarget).Magnitude < 1 then
            lookTarget = targetPos + Vector3.new(0, 0, -1)
        end
        hrp.CFrame = CFrame.lookAt(targetPos, lookTarget)
    end

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
            lastSearchTime = 0
        else
            farmBossToggleBtn.BackgroundColor3 = NexusX.Colors.toggleOff
            if farmBossToggleDot then farmBossToggleDot.Position = UDim2.new(0, 2, 0.5, -8) end
            State.searchStartTime = nil
            lastAttack = 0
        end
    end
end)
