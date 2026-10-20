local Core, GUI = ...
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function build()
    local tab = GUI.makeTab("Movement", 5, "motion")
    local page = GUI.makePage()

    local savedCollide = {}
    local noclipConnection = nil

    local function applyNoclip()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                if savedCollide[p] == nil then
                    savedCollide[p] = p.CanCollide
                end
                p.CanCollide = false
            end
        end
    end

    local function removeNoclip()
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        local char = LocalPlayer.Character
        if not char then return end
        
        for part, state in pairs(savedCollide) do
            if part and part.Parent then
                part.CanCollide = state
            end
        end
        savedCollide = {}
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end

    GUI.makeSectionHeader(page, "Player", 1)
    
    GUI.makeToggle(page, "Noclip", "Проходить сквозь стены", Core.settings.noclip, 2, function(v)
        Core.settings.noclip = v
        if v then
            applyNoclip()
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = RunService.Stepped:Connect(function()
                if Core.settings.noclip then
                    applyNoclip()
                end
            end)
        else
            removeNoclip()
        end
    end, "noclip")

    GUI.makeToggle(page, "Speed ", "Ускорение", Core.settings.speed, 3, function(v)
        Core.settings.speed = v
        if not v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end, "speed")

    GUI.makeToggle(page, "Size ", "Размер персонажа", Core.settings.size, 4, function(v)
        Core.settings.size = v
        if not v and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then Core.setSize(1) end
        end
    end, "size")

    GUI.makeSectionHeader(page, "Settings", 5)
    GUI.makeSlider(page, "Speed Value", 16, 200, Core.settings.walkSpeed, 6, function(v) Core.settings.walkSpeed = v end, "walkSpeed")
    GUI.makeSlider(page, "Size Value", 1, 100, Core.settings.sizeValue, 7, function(v) Core.settings.sizeValue = v end, "sizeValue")

    LocalPlayer.CharacterAdded:Connect(function()
        savedCollide = {}
        if Core.settings.noclip then
            task.wait(0.5)
            applyNoclip()
        end
    end)

    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        if Core.settings.speed then
            if hum.WalkSpeed ~= Core.settings.walkSpeed then
                hum.WalkSpeed = Core.settings.walkSpeed
            end
        end

        if Core.settings.size then
            if math.abs((hrp.Size.X / 2) - Core.settings.sizeValue) > 0.1 then
                Core.setSize(Core.settings.sizeValue)
            end
        end
    end)

    tab.Button.MouseButton1Click:Connect(function() GUI.switchTab(tab, page) end)
    return tab, page
end
return build
