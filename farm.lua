local Core, GUI = ...

local function build()
    local tab = GUI.makeTab("Farm", 3, "crosshair")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Boss Farm", 1)
    GUI.makeToggle(page, "Boss Farm", "Фарм обычных боссов на арене", Core.settings.bossFarm, 2, function(v)
        Core.settings.bossFarm = v
        if not v then
            local char = game.Players.LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end
    end, "bossFarm")

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
