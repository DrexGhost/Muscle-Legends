local RS = game:GetService("ReplicatedStorage")

return function(Core, GUI, page, startOrder)
    local order = startOrder or 7
    local evoThread = nil

    local function startEvo()
        if evoThread then pcall(task.cancel, evoThread) end
        evoThread = task.spawn(function()
            while Core.settings.autoEvo do
                local rEvents = RS:FindFirstChild("rEvents")
                local remote = rEvents and rEvents:FindFirstChild("petEvolveEvent")
                
                if remote and remote:IsA("RemoteEvent") then
                    pcall(function()
                        remote:FireServer("evolvePet", "Apex Overlord")
                    end)
                end
                task.wait(1)
            end
        end)
    end

    GUI.makeToggle(page, "Auto Evo", "Автоматическая эволюция питомца", Core.settings.autoEvo, order, function(v)
        Core.settings.autoEvo = v
        if v then startEvo() else
            if evoThread then pcall(task.cancel, evoThread) end
        end
    end, "autoEvo")

    if Core.settings.autoEvo then
        startEvo()
    end

    return order + 1
end