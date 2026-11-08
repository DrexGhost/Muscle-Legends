local Core, GUI = ...
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function build()
    local tab = GUI.makeTab("Event", 6, "combat")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Zero Degrees Upgrade", 1)

    local upgRefs = {}
    local maxLvl = 10

    local function getLevel(attrName)
        return LocalPlayer:GetAttribute(attrName) or 0
    end

    local upgradeThread = nil
    local function startUpgrades()
        if upgradeThread then pcall(task.cancel, upgradeThread) end
        upgradeThread = task.spawn(function()
            while Core.settings.upgZeroStr or Core.settings.upgZeroDur or Core.settings.upgZeroSnow or Core.settings.upgZeroLuck do
                local pkgs = RS:FindFirstChild("packages")
                local net = pkgs and pkgs:FindFirstChild("Net")
                local remote = net and net:FindFirstChild("RF/ZeroDegreesUpgrade")
                
                if remote then
                    local upgs = {
                        {key = "upgZeroStr", name = "Strength"},
                        {key = "upgZeroDur", name = "Durability"},
                        {key = "upgZeroSnow", name = "Snowflakes"},
                        {key = "upgZeroLuck", name = "EggLuck"}
                    }
                    for _, upg in ipairs(upgs) do
                        if Core.settings[upg.key] then
                            local ok, res = pcall(function() return remote:InvokeServer(upg.name) end)
                            if ok and res then
                                if res.Ok == false then
                                    Core.settings[upg.key] = false
                                    if Core.toggleRefs[upg.key] then
                                        Core.toggleRefs[upg.key].setEnabled(false, true)
                                    end
                                end
                            end
                            task.wait(0.2)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end

    upgRefs.Str = GUI.makeToggle(page, "Strength", string.format("Прокачен %d/%d", getLevel("ZeroDegreesUpgrade_Strength"), maxLvl), Core.settings.upgZeroStr, 2, function(v)
        Core.settings.upgZeroStr = v
        startUpgrades()
    end, "upgZeroStr")

    upgRefs.Dur = GUI.makeToggle(page, "Durability", string.format("Прокачен %d/%d", getLevel("ZeroDegreesUpgrade_Durability"), maxLvl), Core.settings.upgZeroDur, 3, function(v)
        Core.settings.upgZeroDur = v
        startUpgrades()
    end, "upgZeroDur")

    upgRefs.Snow = GUI.makeToggle(page, "Snowflakes", string.format("Прокачен %d/%d", getLevel("ZeroDegreesUpgrade_Snowflakes"), maxLvl), Core.settings.upgZeroSnow, 4, function(v)
        Core.settings.upgZeroSnow = v
        startUpgrades()
    end, "upgZeroSnow")

    upgRefs.Luck = GUI.makeToggle(page, "Egg Luck", string.format("Прокачен %d/%d", getLevel("ZeroDegreesUpgrade_EggLuck"), maxLvl), Core.settings.upgZeroLuck, 5, function(v)
        Core.settings.upgZeroLuck = v
        startUpgrades()
    end, "upgZeroLuck")

    task.spawn(function()
        while GUI.screenGui.Parent do
            local strLvl = getLevel("ZeroDegreesUpgrade_Strength")
            local durLvl = getLevel("ZeroDegreesUpgrade_Durability")
            local snowLvl = getLevel("ZeroDegreesUpgrade_Snowflakes")
            local luckLvl = getLevel("ZeroDegreesUpgrade_EggLuck")

            if upgRefs.Str and upgRefs.Str.Desc then
                upgRefs.Str.Desc.Text = string.format("Прокачен %d/%d", strLvl, maxLvl)
                if strLvl >= maxLvl and Core.settings.upgZeroStr then
                    Core.settings.upgZeroStr = false
                    upgRefs.Str.Set(false, true)
                end
            end
            if upgRefs.Dur and upgRefs.Dur.Desc then
                upgRefs.Dur.Desc.Text = string.format("Прокачен %d/%d", durLvl, maxLvl)
                if durLvl >= maxLvl and Core.settings.upgZeroDur then
                    Core.settings.upgZeroDur = false
                    upgRefs.Dur.Set(false, true)
                end
            end
            if upgRefs.Snow and upgRefs.Snow.Desc then
                upgRefs.Snow.Desc.Text = string.format("Прокачен %d/%d", snowLvl, maxLvl)
                if snowLvl >= maxLvl and Core.settings.upgZeroSnow then
                    Core.settings.upgZeroSnow = false
                    upgRefs.Snow.Set(false, true)
                end
            end
            if upgRefs.Luck and upgRefs.Luck.Desc then
                upgRefs.Luck.Desc.Text = string.format("Прокачен %d/%d", luckLvl, maxLvl)
                if luckLvl >= maxLvl and Core.settings.upgZeroLuck then
                    Core.settings.upgZeroLuck = false
                    upgRefs.Luck.Set(false, true)
                end
            end
            task.wait(1)
        end
    end)

    if Core.settings.upgZeroStr or Core.settings.upgZeroDur or Core.settings.upgZeroSnow or Core.settings.upgZeroLuck then 
        startUpgrades() 
    end

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build