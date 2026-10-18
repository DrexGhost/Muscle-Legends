local Core, GUI = ...

local function build()
    local tab = GUI.makeTab("Ultimate", 4, "settings")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Upgrades", 1)

    local order = 2
    for _, name in ipairs(Core.ABSOLUTE_ORDER) do
        GUI.makeToggle(page, name, "Автоматически улучшать", Core.settings.ultimates[name], order, function(v)
            Core.settings.ultimates[name] = v
        end, "ult_" .. name:gsub("%s+", ""))
        order = order + 1
    end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
