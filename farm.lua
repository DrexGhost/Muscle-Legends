local Core, GUI = ...

local function build()
    local tab = GUI.makeTab("Farm", 3, "farm")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Boss Farm", 1)
    GUI.makeToggle(page, "Boss Farm", "Фарм боссов", Core.settings.bossFarm, 2, function(v)
        Core.settings.bossFarm = v
        if not v then
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end
    end, "bossFarm")

    GUI.makeSectionHeader(page, "Chest", 3)
    GUI.makeToggle(page, "Collect Chest", "Сбор сундуков", Core.settings.collectChest, 4, function(v)
        Core.settings.collectChest = v
    end, "collectChest")

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
