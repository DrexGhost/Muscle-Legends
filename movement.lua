local Core, GUI = ...
local RunService = game:GetService("RunService")

local function build()
    local tab = GUI.makeTab("Movement", 5, "motion")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Player", 1)

    GUI.makeToggle(page, "Noclip", "Проходить сквозь стены", Core.settings.noclip, 2, function(v)
        Core.settings.noclip = v
        if v then
            Core.setNoclip(true)
            Core.NoclipActive = true
        else
            Core.setNoclip(false)
            Core.NoclipActive = false
        end
    end, "noclip")

    GUI.makeToggle(page, "Speed ", "Ускорение", Core.settings.speed, 3, function(v)
        Core.settings.speed = v
        if not v and Core.Hum then Core.Hum.WalkSpeed = 16 end
    end, "speed")

    GUI.makeToggle(page, "Size ", "Размер персонажа", Core.settings.size, 4, function(v)
        Core.settings.size = v
        if not v then Core.setSize(1) end
    end, "size")

    GUI.makeSectionHeader(page, "Settings", 5)
    GUI.makeSlider(page, "Speed Value", 16, 500, Core.settings.walkSpeed, 6, function(v) Core.settings.walkSpeed = v end, "walkSpeed")
    GUI.makeSlider(page, "Size Value", 1, 100, Core.settings.sizeValue, 7, function(v) Core.settings.sizeValue = v end, "sizeValue")

    local lastSizeSent = 0

    RunService.Heartbeat:Connect(function()
        if not Core.Hum then return end

        if Core.settings.noclip and not Core.NoclipActive then
            Core.setNoclip(true)
            Core.NoclipActive = true
        end

        if Core.settings.speed then
            if Core.Hum.WalkSpeed ~= Core.settings.walkSpeed then
                Core.Hum.WalkSpeed = Core.settings.walkSpeed
            end
        end

        if Core.settings.size then
            local now = os.clock()
            if now - lastSizeSent > 1 then
                lastSizeSent = now
                Core.setSize(Core.settings.sizeValue)
            end
        end
    end)

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build