local Core, GUI = ...

local function build()
    local tab = GUI.makeTab("Helper", 2, "helper")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Automation", 1)

    local autoStrThread, autoRebThread, autoClickThread

    local function safeCancel(t)
        if t then pcall(task.cancel, t) end
    end

    local function startAutoStr()
        safeCancel(autoStrThread)
        autoStrThread = task.spawn(function()
            while Core.settings.autoStrength do
                if Core.Char and Core.Char:FindFirstChildOfClass("Humanoid") then
                    local targetName = Core.settings.strengthTool or "Weight"
                    if not Core.hasTool(targetName) then
                        Core.equipTool(targetName)
                    end
                    if Core.hasTool(targetName) then
                        local tool = Core.Char:FindFirstChildOfClass("Tool")
                        if tool and tool.Name == targetName then
                            pcall(function() tool:Activate() end)
                        end
                    end
                end
                task.wait(0.15)
            end
        end)
    end

    local function startAutoReb()
        safeCancel(autoRebThread)
        autoRebThread = task.spawn(function()
            while Core.settings.autoRebirth do
                Core.doRebirth()
                task.wait(2)
            end
        end)
    end

    local function startAutoClick()
        safeCancel(autoClickThread)
        autoClickThread = task.spawn(function()
            while Core.settings.autoClicker do
                Core.doClicker()
                task.wait(0.05)
            end
        end)
    end

    GUI.makeToggle(page, "Auto Strength ", "Автоматически качает силу", Core.settings.autoStrength, 2, function(v)
        Core.settings.autoStrength = v
        if v then startAutoStr() else safeCancel(autoStrThread) end
    end, "autoStrength")

    GUI.makeToggle(page, "Auto Rebirth ", "Автоматическое перерождение", Core.settings.autoRebirth, 3, function(v)
        Core.settings.autoRebirth = v
        if v then startAutoReb() else safeCancel(autoRebThread) end
    end, "autoRebirth")

    GUI.makeToggle(page, "Auto Clicker", "Автоматические клики", Core.settings.autoClicker, 4, function(v)
        Core.settings.autoClicker = v
        if v then startAutoClick() else safeCancel(autoClickThread) end
    end, "autoClicker")

    if Core.settings.autoStrength then startAutoStr() end
    if Core.settings.autoRebirth then startAutoReb() end
    if Core.settings.autoClicker then startAutoClick() end

    GUI.makeSectionHeader(page, "Strength Tool", 5)

    local toolRefs = {}
    local order = 6
    for _, toolName in ipairs(Core.STRENGTH_TOOLS) do
        local key = "strengthTool_" .. toolName
        local isActive = Core.settings.strengthTool == toolName
        local ref
        ref = GUI.makeToggle(page, toolName, "Качать силу через " .. toolName, isActive, order, function(v)
            if v then
                Core.settings.strengthTool = toolName
                Core.saveSetting("strengthTool", toolName)
                for otherName, otherRef in pairs(toolRefs) do
                    if otherName ~= toolName then
                        Core.saveSetting("strengthTool_" .. otherName, false)
                        if otherRef then otherRef.Set(false, true) end
                    end
                end
            else
                if Core.settings.strengthTool == toolName then
                    Core.saveSetting(key, true)
                    ref.Set(true, true)
                end
            end
        end, key)
        toolRefs[toolName] = ref
        order = order + 1
    end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build