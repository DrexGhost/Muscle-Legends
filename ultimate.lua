local Core, GUI = ...
local RunService = game:GetService("RunService")

local TRANSLATIONS = {
    ["Golden Rebirth"] = "Уменьшает стоимость перерождения на 10%",
    ["Galaxy Gains"] = "Увеличивает получаемую силу",
    ["Muscle Mind"] = "Увеличивает получаемую силу за повторения",
    ["Demon Damage"] = "Увеличивает урон по демонам",
    ["Infernal Health"] = "Увеличивает здоровье",
    ["Jungle Swift"] = "Увеличивает скорость в джунглях",
    ["x2 Chest Rewards"] = "Удваивает награды из сундуков",
    ["x2 Quest Rewards"] = "Удваивает награды за квесты",
    ["+5% Rep Speed"] = "Ускоряет скорость повторений",
    ["+1 Pet Slot"] = "Добавляет слот для питомца",
    ["+10 Item Capacity"] = "Увеличивает вместимость предметов",
    ["+1 Daily Spin"] = "Добавляет ежедневное вращение"
}

local function build()
    local tab = GUI.makeTab("Ultimate", 4, "settings")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Upgrades", 1)

    local order = 2
    for _, name in ipairs(Core.ABSOLUTE_ORDER) do
        local desc = TRANSLATIONS[name] or "Улучшение"
        GUI.makeToggle(page, name, desc, Core.settings.ultimates[name], order, function(v)
            Core.settings.ultimates[name] = v
        end, "ult_" .. name:gsub("%s+", ""))
        order = order + 1
    end

    local lastUltimate = 0
    RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastUltimate > 2 then
            lastUltimate = now
            for _, name in ipairs(Core.ABSOLUTE_ORDER) do
                if Core.settings.ultimates[name] then
                    local lvl = Core.getUltimateLevel(name)
                    local max = Core.ABSOLUTE_MAX["Ultimate" .. name:gsub("%s+", "")] or 5
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
