local Core, GUI = ...
local RunService = game:GetService("RunService")

local function build()
    local tab = GUI.makeTab("Farm", 3, "farm")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Boss Farm", 1)
    GUI.makeToggle(page, "Boss Farm", "Фарм боссов", Core.settings.bossFarm, 2, function(v)
        Core.settings.bossFarm = v
        if not v and not Core.settings.collectChest then Core.stopFarm() end
    end, "bossFarm")

    local bossNames = {"Common", "Rare", "Epic", "Legendary", "Mystical", "Rainbow"}

    for i = 1, 6 do
        local key = "bossHeight" .. i
        local label = (bossNames[i] or ("Boss" .. i)) .. " Height"
        GUI.makeSlider(page, label, 0, 300, Core.settings[key] or 143, 2 + i, function(v)
            Core.settings[key] = v
        end, key)
    end

    GUI.makeSectionHeader(page, "Chest", 10)
    GUI.makeToggle(page, "Collect Chest", "Сбор сундуков", Core.settings.collectChest, 11, function(v)
        Core.settings.collectChest = v
        if not v and not Core.settings.bossFarm then Core.stopFarm() end
    end, "collectChest")

    local lastAttack, lastSearchTime, lastChestTime = 0, 0, 0
    local currentBossModel, currentBossPart, bossWasAlive = nil, nil, false
    local chestIndex = 1

    local function getBoss()
        local events = workspace:FindFirstChild("Events")
        local arena = events and events:FindFirstChild("BossArena")
        if not arena then return nil end
        for _, model in ipairs(arena:GetChildren()) do
            local part = model:FindFirstChild("Boss")
            if part and part:IsA("BasePart") then
                local hp = model:GetAttribute("Health") or part:GetAttribute("Health") or 100
                if hp > 0 and part.Position.Y > 0 then
                    return model, part
                end
            end
        end
        return nil
    end

    local function getBossHeight(name)
        local idx = tostring(name):match("^Boss(%d+)$")
        if idx then
            return Core.settings["bossHeight" .. idx] or 143
        end
        return Core.BOSS_HEIGHTS[name] or 143
    end

    RunService.Heartbeat:Connect(function()
        if not Core.settings.collectChest and not Core.settings.bossFarm then return end
        if not Core.HRP or not Core.HRP.Parent or not Core.Hum then return end

        local now = os.clock()

        if Core.settings.collectChest and not currentBossPart then
            if now - lastChestTime > 2 then
                lastChestTime = now
                if not Core.NoclipActive then Core.setNoclip(true); Core.NoclipActive = true end
                Core.Hum.PlatformStand = true
                Core.HRP.AssemblyLinearVelocity = Vector3.zero
                Core.HRP.AssemblyAngularVelocity = Vector3.zero
                local chest = Core.CHESTS[chestIndex]
                if chest then Core.HRP.CFrame = CFrame.new(chest + Vector3.new(0, 3, 0)) end
                chestIndex = chestIndex + 1
                if chestIndex > #Core.CHESTS then chestIndex = 1 end
            end
        end

        if Core.settings.bossFarm then
            if currentBossPart then
                if not currentBossPart.Parent or currentBossPart.Position.Y <= 0 then
                    if bossWasAlive then Core.returnToBase() end
                    currentBossModel, currentBossPart, bossWasAlive = nil, nil, false
                else
                    local hp = currentBossModel:GetAttribute("Health") or currentBossPart:GetAttribute("Health")
                    if hp and hp > 0 then
                        bossWasAlive = true
                    elseif hp and hp <= 0 then
                        if bossWasAlive then
                            Core.returnToBase()
                            currentBossModel, currentBossPart, bossWasAlive = nil, nil, false
                        end
                    end
                end
            end

            if not currentBossPart then
                if now - lastSearchTime >= 2 then
                    lastSearchTime = now
                    local bModel, bPart = getBoss()
                    if bModel then
                        currentBossModel, currentBossPart, bossWasAlive = bModel, bPart, true
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

            local height = getBossHeight(currentBossModel.Name)
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
        end
    end)

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build