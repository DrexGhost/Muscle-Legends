local Core, GUI = ...
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function build()
    local tab = GUI.makeTab("Event", 6, "combat")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Teleport", 1)
    GUI.makeActionButton(page, "Halloween Gym", "blue", 2, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(5558, 85, 5838) end
    end)

    GUI.makeSectionHeader(page, "Event Farm", 3)
    GUI.makeToggle(page, "Auto Event Farm", "Фарм ивентовых боссов", Core.settings.autoEventFarm, 4, function(v)
        Core.settings.autoEventFarm = v
    end, "autoEventFarm")

    local bNames = {"EXTREME", "HARD", "MEDIUM", "EASY"}
    local order = 5
    for _, bName in ipairs(bNames) do
        local isActive = Core.settings.eventBosses[bName]
        GUI.makeToggle(page, bName, "Фармить " .. bName, isActive, order, function(v)
            Core.settings.eventBosses[bName] = v
            Core.saveSetting("eventBosses", Core.settings.eventBosses)
            if v and not Core.settings.autoEventFarm then
                Core.settings.autoEventFarm = true
                if Core.toggleRefs["autoEventFarm"] then Core.toggleRefs["autoEventFarm"].setEnabled(true, true) end
            end
        end, "boss_" .. bName)
        order = order + 1
    end

    local lastAttack, lastSearchTime = 0, 0
    local currentBossModel, currentBossPart, bossWasAlive = nil, nil, false
    local RETURN_POS = Vector3.new(-16.9, 36.3, -1243.5)

    local function getBoss()
        for _, name in ipairs(Core.EVENT_BOSS_ORDER) do
            if Core.settings.eventBosses[name] then
                local b = Core.EVENT_BOSSES[name]
                local model = workspace:FindFirstChild(b.model)
                if model then
                    local part = model:FindFirstChild(b.part)
                    if part and part.Position.Y > 0 then
                        return model, part
                    end
                end
            end
        end
        return nil
    end

    RunService.Heartbeat:Connect(function()
        if not Core.settings.autoEventFarm then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local now = os.clock()

        if currentBossPart then
            if not currentBossPart.Parent or currentBossPart.Position.Y <= 0 then
                currentBossModel, currentBossPart, bossWasAlive = nil, nil, false
            else
                local hp = currentBossModel:GetAttribute("Health") or currentBossPart:GetAttribute("Health")
                if hp and hp > 0 then bossWasAlive = true
                elseif hp and hp <= 0 then
                    if bossWasAlive then
                        hrp.CFrame = CFrame.new(RETURN_POS)
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

        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        hum.AutoRotate = false
        hum.PlatformStand = true

        local height = Core.BOSS_HEIGHTS[currentBossModel.Name] or 143
        local targetPos = Vector3.new(currentBossPart.Position.X, height, currentBossPart.Position.Z)
        local lookTarget = currentBossPart.Position
        
        if (targetPos - lookTarget).Magnitude < 1 then lookTarget = targetPos + Vector3.new(0, 0, -1) end
        hrp.CFrame = CFrame.lookAt(targetPos, lookTarget)

        if now - lastAttack >= 0.4 then
            lastAttack = now
            Core.punch()
        end
    end)

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
