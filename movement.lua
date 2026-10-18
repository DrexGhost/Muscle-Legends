local Core, GUI = ...

local function build()
    local tab = GUI.makeTab("Movement", 5, "motion")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Player", 1)
    GUI.makeToggle(page, "Noclip", "Проходить сквозь стены", Core.settings.noclip, 2, function(v) Core.settings.noclip = v end, "noclip")
    GUI.makeToggle(page, "Speed", "Ускорение", Core.settings.speed, 3, function(v) Core.settings.speed = v end, "speed")
    GUI.makeToggle(page, "Size", "Размер персонажа", Core.settings.size, 4, function(v) Core.settings.size = v end, "size")

    GUI.makeSectionHeader(page, "Settings", 5)
    GUI.makeSlider(page, "Speed Value", 16, 200, Core.settings.walkSpeed, 6, function(v) Core.settings.walkSpeed = v end, "walkSpeed")
    GUI.makeSlider(page, "Size Value", 1, 10, Core.settings.sizeValue, 7, function(v) Core.settings.sizeValue = v end, "sizeValue")

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
