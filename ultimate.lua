local Core, GUI = ...

local function build()
    local tab = GUI.makeTab("Ultimate ", 4, "ultimate")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Upgrades", 1)

    local ultimateRefs = {}
    local order = 2

    for _, name in ipairs(Core.ABSOLUTE_ORDER) do
        local attrName = Core.ABSOLUTE_MAP[name]
        local max = Core.ABSOLUTE_MAX[attrName] or 5
        local lvl = Core.getUltimateLevel(name)
        local desc = string.format("Прокачен %d/%d", lvl, max)

        local myToggle
        myToggle = GUI.makeToggle(page, name, desc, Core.settings.ultimates[name], order, function(v)
            if v then
                local currentLvl = Core.getUltimateLevel(name)
                if currentLvl >= max then
                    if myToggle then myToggle.Set(false, true) end
                    Core.settings.ultimates[name] = false
                    return
                end
            end
            Core.settings.ultimates[name] = v
        end, "ult_" .. name:gsub("%s+", ""))

        ultimateRefs[name] = myToggle
        order = order + 1
    end

    task.spawn(function()
        while GUI.screenGui.Parent do
            task.wait(1)
            for _, name in ipairs(Core.ABSOLUTE_ORDER) do
                local attrName = Core.ABSOLUTE_MAP[name]
                local max = Core.ABSOLUTE_MAX[attrName] or 5
                local lvl = Core.getUltimateLevel(name)
                local ref = ultimateRefs[name]

                if ref and ref.Desc then
                    ref.Desc.Text = string.format("Прокачен %d/%d", lvl, max)
                    if lvl >= max and Core.settings.ultimates[name] then
                        Core.settings.ultimates[name] = false
                        ref.Set(false, true)
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while GUI.screenGui.Parent do
            task.wait(2)
            for _, name in ipairs(Core.ABSOLUTE_ORDER) do
                if Core.settings.ultimates[name] then
                    local attrName = Core.ABSOLUTE_MAP[name]
                    local max = Core.ABSOLUTE_MAX[attrName] or 5
                    local lvl = Core.getUltimateLevel(name)
                    if lvl < max then
                        Core.upgradeUltimate(name)
                        break
                    end
                end
            end
        end
    end)

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build