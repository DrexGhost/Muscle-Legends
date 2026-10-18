local Core, GUI = ...
local LocalPlayer = game:GetService("Players").LocalPlayer

local function build()
    local tab = GUI.makeTab("Helper", 2, "helper")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Automation", 1)
    
    local autoStrThread, autoRebThread, autoClickThread

    local function startAutoStr()
        if autoStrThread then task.cancel(autoStrThread) end
        autoStrThread = task.spawn(function()
            while Core.settings.autoStrength do
                if not Core.hasDumbbell() then Core.equipDumbbell() end
                if Core.hasDumbbell() then
                    local char = LocalPlayer.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
                task.wait(0.15)
            end
        end)
    end

    local function startAutoReb()
        if autoRebThread then task.cancel(autoRebThread) end
        autoRebThread = task.spawn(function()
            while Core.settings.autoRebirth do
                Core.doRebirth()
                task.wait(2)
            end
        end)
    end

    local function startAutoClick()
        if autoClickThread then task.cancel(autoClickThread) end
        autoClickThread = task.spawn(function()
            while Core.settings.autoClicker do
                Core.doClicker()
                task.wait(0.05)
            end
        end)
    end

    GUI.makeToggle(page, "Auto Strength", "Автоматически качает силу", Core.settings.autoStrength, 2, function(v) 
        Core.settings.autoStrength = v
        if v then startAutoStr() else if autoStrThread then task.cancel(autoStrThread) end end
    end, "autoStrength")

    GUI.makeToggle(page, "Auto Rebirth", "Автоматическое перерождение", Core.settings.autoRebirth, 3, function(v) 
        Core.settings.autoRebirth = v
        if v then startAutoReb() else if autoRebThread then task.cancel(autoRebThread) end end
    end, "autoRebirth")

    GUI.makeToggle(page, "Auto Clicker", "Автоматические клики", Core.settings.autoClicker, 4, function(v) 
        Core.settings.autoClicker = v
        if v then startAutoClick() else if autoClickThread then task.cancel(autoClickThread) end end
    end, "autoClicker")

    if Core.settings.autoStrength then startAutoStr() end
    if Core.settings.autoRebirth then startAutoReb() end
    if Core.settings.autoClicker then startAutoClick() end

    GUI.makeSectionHeader(page, "Teleport", 5)
    
    local locations = {
        {name = "Tiny Island", coords = Vector3.new(-35, 7, 1876)},
        {name = "Frost Gym", coords = Vector3.new(-2597, 7, -407)},
        {name = "Mythical Gym", coords = Vector3.new(2231, 7, 1070)},
        {name = "Muscle King Gym", coords = Vector3.new(-8584, 17, -5678)},
        {name = "Eternal Gym", coords = Vector3.new(-6739, 7, -1282)},
        {name = "Legends Gym", coords = Vector3.new(4629, 991, -3896)},
        {name = "Jungle Gym", coords = Vector3.new(-8706, 6, 2387)},
        {name = "Industrial Gym", coords = Vector3.new(-5545, 60, 4941)},
        {name = "Electro Gym", coords = Vector3.new(-3134, 168, 4999)},
    }

    local order = 6
    for _, loc in ipairs(locations) do
        GUI.makeActionButton(page, loc.name, "blue", order, function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(loc.coords) end
        end)
        order = order + 1
    end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
