local Core, GUI = ...

local function build()
    local tab = GUI.makeTab("Event", 6, "combat")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Event Farm", 1)
    GUI.makeToggle(page, "Auto Event Farm", "Фарм ивентовых боссов", Core.settings.autoEventFarm, 2, function(v)
        Core.settings.autoEventFarm = v
        if not v then
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end
    end, "autoEventFarm")

    local bNames = {"EXTREME", "HARD", "MEDIUM", "EASY"}
    local order = 3
    for _, bName in ipairs(bNames) do
        GUI.makeActionButton(page, "Select: " .. bName, Core.settings.eventBoss == bName and "primary" or "blue", order, function()
            Core.settings.eventBoss = bName
            Core.saveSetting("eventBoss", bName)
        end)
        order = order + 1
    end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
