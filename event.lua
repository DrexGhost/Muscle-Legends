local Core, GUI = ...
local RunService = game:GetService("RunService")

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

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build