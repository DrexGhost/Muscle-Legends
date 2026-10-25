local Core, GUI = ...
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local VIM = game:GetService("VirtualInputManager")

local function build()
    local tab = GUI.makeTab("Event", 6, "combat")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Teleport", 1)
    GUI.makeActionButton(page, "Halloween Gym", "blue", 2, function()
        if Core.HRP then
            Core.HRP.AssemblyLinearVelocity = Vector3.zero
            Core.HRP.AssemblyAngularVelocity = Vector3.zero
            Core.HRP.CFrame = CFrame.new(5558, 85, 5838)
        end
    end)

    GUI.makeSectionHeader(page, "Event Farm", 3)

    local bossRefs = {}
    local bNames = {"EXTREME", "HARD", "MEDIUM", "EASY"}
    local order = 4

    for _, bName in ipairs(bNames) do
        local isActive = Core.settings.eventBosses[bName] == true
        local ref
        ref = GUI.makeToggle(page, bName, "Фармить " .. bName, isActive, order, function(v)
            Core.settings.eventBosses[bName] = v
            if v then
                for otherName, otherRef in pairs(bossRefs) do
                    if otherName ~= bName then
                        Core.settings.eventBosses[otherName] = false
                        if otherRef then otherRef.Set(false, true) end
                    end
                end
                Core.settings.autoEventFarm = true
            else
                local any = false
                for _, n in ipairs(Core.EVENT_BOSS_ORDER) do
                    if Core.settings.eventBosses[n] == true then any = true; break end
                end
                if not any then
                    Core.settings.autoEventFarm = false
                    Core.stopFarm()
                end
            end
            Core.saveSetting("eventBosses", Core.settings.eventBosses)
        end, "boss_" .. bName)
        bossRefs[bName] = ref
        order = order + 1

        local key = "eventHeight" .. bName
        local defaultHeight = Core.settings[key] or 143
        GUI.makeSlider(page, bName .. " Height", 0, 300, defaultHeight, order, function(v)
            Core.settings[key] = v
        end, key)
        order = order + 1
    end

    local any = false
    for _, n in ipairs(Core.EVENT_BOSS_ORDER) do
        if Core.settings.eventBosses[n] == true then any = true; break end
    end
    if not any then Core.settings.autoEventFarm = false end

    local function getBoss()
        for _, name in ipairs(Core.EVENT_BOSS_ORDER) do
            if Core.settings.eventBosses[name] == true then
                local b = Core.EVENT_BOSSES[name]
                local model = workspace:FindFirstChild(b.model)
                if model then
                    local part = model:FindFirstChild(b.part)
                    if part and part.Position.Y > 0 then
                        return model, part, name
                    end
                end
            end
        end
        return nil
    end

    local lastAttack, lastSearchTime = 0, 0
    local currentBossModel, currentBossPart, bossWasAlive = nil, nil, false
    local currentBossName = nil

    RunService.Heartbeat:Connect(function()
        if not Core.settings.autoEventFarm then return end
        if not Core.HRP or not Core.HRP.Parent or not Core.Hum then return end

        local now = os.clock()

        if currentBossPart then
            local stillEnabled = currentBossName ~= nil and Core.settings.eventBosses[currentBossName] == true
            local outOfWorld = not currentBossPart.Parent or currentBossPart.Position.Y <= 0

            if not stillEnabled or outOfWorld then
                if bossWasAlive then Core.returnToBase() end
                currentBossModel, currentBossPart, bossWasAlive, currentBossName = nil, nil, false, nil
            else
                local hp = currentBossModel:GetAttribute("Health") or currentBossPart:GetAttribute("Health")
                if hp and hp > 0 then
                    bossWasAlive = true
                elseif hp and hp <= 0 then
                    if bossWasAlive then
                        Core.returnToBase()
                        currentBossModel, currentBossPart, bossWasAlive, currentBossName = nil, nil, false, nil
                    end
                end
            end
        end

        if not currentBossPart then
            if now - lastSearchTime >= 2 then
                lastSearchTime = now
                local bModel, bPart, bName = getBoss()
                if bModel then
                    currentBossModel, currentBossPart, bossWasAlive, currentBossName = bModel, bPart, true, bName
                end
            end
            if not currentBossPart then return end
        end

        if not Core.NoclipActive then
            Core.setNoclip(true)
            Core.NoclipActive = true
        end

        Core.Hum.AutoRotate = false
        Core.Hum.PlatformStand = true
        Core.HRP.AssemblyLinearVelocity = Vector3.zero
        Core.HRP.AssemblyAngularVelocity = Vector3.zero

        local height = Core.settings["eventHeight" .. currentBossName] or Core.BOSS_HEIGHTS[currentBossModel.Name] or 143
        local targetPos = Vector3.new(currentBossPart.Position.X, height, currentBossPart.Position.Z)
        local lookTarget = currentBossPart.Position

        if (targetPos - lookTarget).Magnitude < 1 then
            lookTarget = targetPos + Vector3.new(0, 0, -1)
        end
        Core.HRP.CFrame = CFrame.lookAt(targetPos, lookTarget)

        if now - lastAttack >= 0.4 then
            lastAttack = now
            Core.punch()
        end
    end)

    GUI.makeSectionHeader(page, "New Event (Race)", order)
    order = order + 1

    local LOBBY_X = -12850
    local BOX_X = -12850
    local BOX_Z = -4205
    local FINISH_X = -14538
    local FINISH_STOP_X = FINISH_X - 5
    local FINISH_BACK_X = -14530
    local HURDLES_X = {-12947, -13007, -13067, -13127, -13187, -13247, -13307}
    local LANE_Z_LIST = {-4129, -4143, -4157, -4172, -4186, -4200, -4214, -4229, -4243, -4257}

    local raceState = false
    local raceActive = false
    local attachedHRP = nil
    local attachedHum = nil
    local raceConn = nil
    local raceCheckThread = nil
    local bodyVel = nil
    local lastJumpTime = 0
    local lastClickTime = 0

    local finishAttempts = 0
    local finishPhase = "going"
    local finishPhaseStart = 0

    local lastBoxTpTime = 0
    local boxWiggled = false
    local inBoxWiggle = false

    local getCurrentLane = function()
        if not Core.HRP then return 1 end
        local z = Core.HRP.Position.Z
        local best, bestDiff = 1, math.huge
        for i, lz in ipairs(LANE_Z_LIST) do
            local d = math.abs(z - lz)
            if d < bestDiff then bestDiff = d; best = i end
        end
        return best
    end

    local attach = function()
        if not Core.Char then return false end
        attachedHRP = Core.HRP
        attachedHum = Core.Hum
        return attachedHRP ~= nil and attachedHum ~= nil
    end

    local isReallyVisible = function(obj)
        local cur = obj
        while cur and cur ~= game do
            if cur:IsA("GuiObject") and not cur.Visible then return false end
            cur = cur.Parent
        end
        return true
    end

    local findVisibleText = function(targetText)
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name ~= "NexusML_UI" and gui.Name ~= "NexusWatermark" then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text == targetText then
                        if isReallyVisible(desc) then return desc end
                    end
                end
            end
        end
        return nil
    end

    local endCurrentRace = function()
        raceActive = false
        if raceConn then raceConn:Disconnect(); raceConn = nil end
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
        if attachedHum then
            pcall(function() attachedHum:Move(Vector3.new(0, 0, 0)) end)
            attachedHum.AutoRotate = true
        end
        pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
        finishAttempts = 0
        finishPhase = "going"
    end

    local doBoxWiggle = function()
        if inBoxWiggle then return end
        inBoxWiggle = true
        if not attachedHRP or not attachedHRP.Parent then inBoxWiggle = false; return end

        for i = 1, 10 do
            if not inBoxWiggle or not attachedHRP or not attachedHRP.Parent then return end
            attachedHRP.AssemblyLinearVelocity = Vector3.new(-25, 0, 0)
            task.wait(0.02)
        end
        for i = 1, 10 do
            if not inBoxWiggle or not attachedHRP or not attachedHRP.Parent then return end
            attachedHRP.AssemblyLinearVelocity = Vector3.new(25, 0, 0)
            task.wait(0.02)
        end
        if attachedHRP and attachedHRP.Parent then
            attachedHRP.AssemblyLinearVelocity = Vector3.zero
        end
        inBoxWiggle = false
    end

    local startRaceLoop = function()
        if raceActive then return end
        if not attach() then return end

        raceActive = true
        lastJumpTime = 0
        lastClickTime = 0
        finishAttempts = 0
        finishPhase = "going"
        finishPhaseStart = 0

        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "AutoRaceVelocity"
        bodyVel.MaxForce = Vector3.new(math.huge, 0, math.huge)
        bodyVel.Velocity = Vector3.new(-25, 0, 0)
        bodyVel.Parent = attachedHRP

        raceConn = RunService.Heartbeat:Connect(function()
            if not raceActive then return end
            if not attachedHRP or not attachedHRP.Parent or not attachedHum then
                if not attach() then return end
                if bodyVel then bodyVel:Destroy() end
                bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(math.huge, 0, math.huge)
                bodyVel.Velocity = Vector3.new(-25, 0, 0)
                bodyVel.Parent = attachedHRP
            end

            local now = os.clock()
            local pos = attachedHRP.Position
            local floor = attachedHum.FloorMaterial
            local ws = attachedHum.WalkSpeed

            if finishPhase == "going" and pos.X <= FINISH_STOP_X then
                finishPhase = "checking"
                finishPhaseStart = now
                if bodyVel then bodyVel.Velocity = Vector3.zero end
                attachedHum:Move(Vector3.new(0, 0, 0))
                return
            end

            if finishPhase == "checking" then
                if pos.X > LOBBY_X then
                    endCurrentRace()
                    return
                end
                if now - finishPhaseStart > 2.0 then
                    finishAttempts = finishAttempts + 1

                    if finishAttempts >= 3 then
                        endCurrentRace()
                        if Core.Char then
                            local hum = Core.Char:FindFirstChildOfClass("Humanoid")
                            if hum then pcall(function() hum.Health = 0 end) end
                        end
                        return
                    else
                        finishPhase = "rolling_back"
                        finishPhaseStart = now
                    end
                end
                return
            end

            if finishPhase == "rolling_back" then
                if pos.X >= FINISH_BACK_X or now - finishPhaseStart > 3.0 then
                    finishPhase = "going"
                    finishPhaseStart = now
                else
                    if bodyVel then
                        bodyVel.Velocity = Vector3.new(math.max(ws, 20), 0, 0)
                    end
                    attachedHum.AutoRotate = false
                    attachedHum:Move(Vector3.new(1, 0, 0))
                    return
                end
            end

            if pos.X > LOBBY_X then
                endCurrentRace()
                return
            end

            if pos.X <= -13350 and pos.X > -13675 then
                local laneNum = getCurrentLane()
                local laneName = string.format("Lane%02d", laneNum)
                local gym = workspace:FindFirstChild("StrongbloxianGym")
                local course = gym and gym:FindFirstChild("Course")
                local lanes = course and course:FindFirstChild("Lanes")
                local lane = lanes and lanes:FindFirstChild(laneName)
                local segs = lane and lane:FindFirstChild("Segments")
                local sledSeg = segs and segs:FindFirstChild("02_HeavySled")
                local sled = sledSeg and sledSeg:FindFirstChild("Sled")

                if sled and sled.Parent then
                    local runner = sled:GetAttribute("StrongbloxianSledRunner")
                    local isRunner = (tostring(runner) == tostring(LocalPlayer.UserId))
                    if not isRunner then
                        if bodyVel then bodyVel.Velocity = Vector3.new(-ws, 0, 0) end
                        attachedHum.AutoRotate = false
                        attachedHum:Move(Vector3.new(-1, 0, 0))
                        return
                    end
                end
            end

            if pos.X <= -13675 and pos.X > -13885 then
                local laneNum = getCurrentLane()
                local laneName = string.format("Lane%02d", laneNum)
                local gym = workspace:FindFirstChild("StrongbloxianGym")
                local course = gym and gym:FindFirstChild("Course")
                local lanes = course and course:FindFirstChild("Lanes")
                local lane = lanes and lanes:FindFirstChild(laneName)
                local segs = lane and lane:FindFirstChild("Segments")
                local liftSeg = segs and segs:FindFirstChild("03_HeavyLift")
                local barbell = liftSeg and liftSeg:FindFirstChild("Barbell")

                local nearBarbell = false
                if barbell then
                    local barPos = barbell:GetPivot().Position
                    local dist = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(barPos.X, 0, barPos.Z)).Magnitude
                    if dist < 10 then nearBarbell = true end
                end

                if nearBarbell then
                    if now - lastClickTime > 0.03 then
                        lastClickTime = now
                        local vp = workspace.CurrentCamera.ViewportSize
                        pcall(function()
                            VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 0)
                            VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 0)
                        end)
                    end
                end
            end

            if pos.X <= -13885 and pos.X > -14125 then
                if now - lastClickTime > 0.03 then
                    lastClickTime = now
                    local vp = workspace.CurrentCamera.ViewportSize
                    pcall(function()
                        VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 0)
                        VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 0)
                    end)
                end
            end

            if bodyVel then
                bodyVel.Velocity = Vector3.new(-math.max(ws, 0), 0, 0)
            end

            attachedHum.AutoRotate = false
            attachedHum:Move(Vector3.new(-1, 0, 0))

            for _, hX in ipairs(HURDLES_X) do
                local dist = pos.X - hX
                if dist > 0 and dist < 7 then
                    if floor ~= Enum.Material.Air and now - lastJumpTime > 0.4 then
                        attachedHum:ChangeState(Enum.HumanoidStateType.Jumping)
                        attachedHum.Jump = true
                        lastJumpTime = now
                    end
                    break
                end
            end
        end)
    end

    local stopRace = function()
        raceState = false
        if raceCheckThread then
            pcall(task.cancel, raceCheckThread)
            raceCheckThread = nil
        end
        inBoxWiggle = false
        endCurrentRace()
    end

    local startRace = function()
        raceState = true
        lastBoxTpTime = 0
        boxWiggled = false
        inBoxWiggle = false
        if raceCheckThread then pcall(task.cancel, raceCheckThread) end
        raceCheckThread = task.spawn(function()
            while raceState do
                if Core.HRP then
                    local raceLive = findVisibleText("RACE LIVE")
                    local stepHint = findVisibleText("STEP IN THE BOX TO RACE")
                    local raceWaiting = raceLive ~= nil or stepHint ~= nil

                    if raceWaiting then
                        if not raceActive then
                            if Core.HRP.Position.X > LOBBY_X then
                                Core.HRP.CFrame = CFrame.new(BOX_X, 6, BOX_Z)
                                Core.HRP.AssemblyLinearVelocity = Vector3.zero
                                Core.HRP.AssemblyAngularVelocity = Vector3.zero
                                lastBoxTpTime = os.clock()
                                boxWiggled = false
                                inBoxWiggle = false
                                attachedHRP = Core.HRP
                                attachedHum = Core.Hum
                            else
                                if not boxWiggled and lastBoxTpTime > 0 and (os.clock() - lastBoxTpTime) > 1.0 then
                                    boxWiggled = true
                                    task.spawn(doBoxWiggle)
                                end
                            end
                        end
                    else
                        inBoxWiggle = false
                        lastBoxTpTime = 0
                        boxWiggled = false
                        if not raceActive then
                            startRaceLoop()
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    end

    GUI.makeToggle(page, "Auto Race (Beta)", "Автоматическое прохождение гонки", false, order, function(v)
        if v then
            startRace()
        else
            stopRace()
        end
    end)

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build