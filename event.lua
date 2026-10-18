local Core, GUI = ...
local LocalPlayer = game:GetService("Players").LocalPlayer

local function build()
    local tab = GUI.makeTab("Event", 6, "combat")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Teleport", 1)
    GUI.makeActionButton(page, "Halloween Gym", "blue", 2, function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(5558, 85, 5838) end
    end)

    GUI.makeSectionHeader(page, "Event Farm", 3)
    GUI.makeToggle(page, "Auto Event Farm", "Фарм ивентовых боссов", Core.settings.autoEventFarm, 4, function(v)
        Core.settings.autoEventFarm = v
        if not v then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
            end
        end
    end, "autoEventFarm")

    local bNames = {"EXTREME", "HARD", "MEDIUM", "EASY"}
    local order = 5
    for _, bName in ipairs(bNames) do
        local isActive = (Core.settings.eventBoss == bName)
        GUI.makeToggle(page, "Select: " .. bName, "Фармить " .. bName, isActive, order, function(v)
            if v then
                Core.settings.eventBoss = bName
                Core.saveSetting("eventBoss", bName)
                for _, otherName in ipairs(bNames) do
                    if otherName ~= bName then
                        local ref = Core.toggleRefs["boss_" .. otherName]
                        if ref then ref.setEnabled(false, true) end
                    end
                end
            else
                Core.settings.eventBoss = nil
            end
        end, "boss_" .. bName)
        order = order + 1
    end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
