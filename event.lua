local Core, GUI = ...
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function build()
    local tab = GUI.makeTab("Event", 6, "combat")
    local page = GUI.makePage()

    GUI.makeSectionHeader(page, "Zero Degrees Upgrade", 1)

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

    GUI.makeToggle(page, "Strength", "Прокачка силы", Core.settings.upgZeroStr, 2, function(v)
        Core.settings.upgZeroStr = v
        startUpgrades()
    end, "upgZeroStr")

    GUI.makeToggle(page, "Durability", "Прокачка выносливости", Core.settings.upgZeroDur, 3, function(v)
        Core.settings.upgZeroDur = v
        startUpgrades()
    end, "upgZeroDur")

    GUI.makeToggle(page, "Snowflakes", "Прокачка снежинок", Core.settings.upgZeroSnow, 4, function(v)
        Core.settings.upgZeroSnow = v
        startUpgrades()
    end, "upgZeroSnow")

    GUI.makeToggle(page, "Egg Luck", "Прокачка удачи яиц", Core.settings.upgZeroLuck, 5, function(v)
        Core.settings.upgZeroLuck = v
        startUpgrades()
    end, "upgZeroLuck")

    local levelLbl = Instance.new("TextLabel")
    levelLbl.Size = UDim2.new(1, 0, 0, 75)
    levelLbl.BackgroundColor3 = Core.T.card
    levelLbl.BorderSizePixel = 0
    levelLbl.Text = "Загрузка уровней..."
    levelLbl.TextColor3 = Core.T.text
    levelLbl.TextSize = 12
    levelLbl.Font = Enum.Font.Gotham
    levelLbl.TextXAlignment = Enum.TextXAlignment.Left
    levelLbl.TextYAlignment = Enum.TextYAlignment.Top
    levelLbl.LayoutOrder = 6
    levelLbl.Parent = page
    
    local lvlPad = Instance.new("UIPadding", levelLbl)
    lvlPad.PaddingLeft = UDim.new(0, 10)
    lvlPad.PaddingTop = UDim.new(0, 5)
    local lvlCorner = Instance.new("UICorner", levelLbl)
    lvlCorner.CornerRadius = UDim.new(0, 10)

    task.spawn(function()
        while GUI.screenGui.Parent do
            local str = LocalPlayer:GetAttribute("ZeroDegreesUpgrade_Strength") or 0
            local dur = LocalPlayer:GetAttribute("ZeroDegreesUpgrade_Durability") or 0
            local snow = LocalPlayer:GetAttribute("ZeroDegreesUpgrade_Snowflakes") or 0
            local luck = LocalPlayer:GetAttribute("ZeroDegreesUpgrade_EggLuck") or 0
            
            levelLbl.Text = string.format("Strength: %d\nDurability: %d\nSnowflakes: %d\nEgg Luck: %d", str, dur, snow, luck)
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