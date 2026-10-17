local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["KILL"]
local UI = NexusX.UI
local Settings = NexusX.Settings
local State = NexusX.State
local RunService = NexusX.RunService

local farmBossToggleBtn, farmBossToggleDot

function NexusX.Features.findFarmBossPart()
    local events = workspace:FindFirstChild("Events")
    if not events then return nil end
    local bossArena = events:FindFirstChild("BossArena")
    if not bossArena then return nil end
    local closest, closestDist = nil, math.huge
    local myRoot = NexusX.Player.Character and NexusX.Player.Character:FindFirstChild("HumanoidRootPart")
    for _, bossModel in ipairs(bossArena:GetChildren()) do
        local bossPart = bossModel:FindFirstChild("Boss")
        if bossPart and bossPart:IsA("MeshPart") then
            if myRoot then
                local dist = (myRoot.Position - bossPart.Position).Magnitude
                if dist < closestDist then closestDist = dist; closest = bossPart end
            else
                closest = bossPart; break
            end
        end
    end
    return closest
end

local function disableFarmBoss()
    State.searchStartTime = nil
    State.lastAttack = 0
    Settings.farmBoss = false
    if farmBossToggleBtn then
        farmBossToggleBtn.BackgroundColor3 = NexusX.Colors.toggleOff
        if farmBossToggleDot then farmBossToggleDot.Position = UDim2.new(0, 2, 0.5, -8) end
    end
    task.defer(NexusX.clearHitboxes)
end

local farmBossToggleFrame = UI.createToggle(content, "FARM BOSS", 15, Settings.farmBoss, function(v)
    if v then
        if NexusX.Features.disableAutoFarmBoss then NexusX.Features.disableAutoFarmBoss() end
        if NexusX.Features.disableAllEventBosses then NexusX.Features.disableAllEventBosses() end
        Settings.farmBoss = true
        State.searchStartTime = os.clock()
        State.lastAttack = 0
    else
        Settings.farmBoss = false
        State.searchStartTime = nil
        State.lastAttack = 0
        NexusX.clearHitboxes()
    end
end, "farmBoss", true)

farmBossToggleBtn = farmBossToggleFrame:FindFirstChildWhichIsA("TextButton")
if farmBossToggleBtn then farmBossToggleDot = farmBossToggleBtn:FindFirstChildWhichIsA("Frame") end

if Settings.farmBoss then
    State.searchStartTime = os.clock()
    State.lastAttack = 0
end

RunService.Heartbeat:Connect(function()
    if not NexusX.Gui.Main.Parent then return end
    if Settings.farmBoss then
        local myChar = NexusX.Player.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local bossPart = NexusX.Features.findFarmBossPart()
            if bossPart then
                State.searchStartTime = os.clock()
                myRoot.CFrame = bossPart.CFrame + Vector3.new(0, 55, 0)
                NexusX.createHitbox(bossPart)
                local now = os.clock()
                if now - State.lastAttack >= 0.4 then
                    State.lastAttack = now
                    NexusX.punch()
                end
            else
                if State.searchStartTime and os.clock() - State.searchStartTime >= 1 then
                    disableFarmBoss()
                end
            end
        end
        return
    end
end)
