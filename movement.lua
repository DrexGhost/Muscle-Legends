local NexusX = _G.NexusX
local content = NexusX.Gui.Contents["MOVEMENT"]
local UI = NexusX.UI
local Settings = NexusX.Settings

local speedConnection, noclipConnection

local function applySpeed()
    if not NexusX.Player.Character then return end
    local hum = NexusX.Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Settings.speedValue end
end

local function stopSpeed()
    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    if NexusX.Player.Character then
        local hum = NexusX.Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

local function applyNoclip()
    if not NexusX.Player.Character then return end
    for _, part in ipairs(NexusX.Player.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

local function stopNoclip()
    if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    if NexusX.Player.Character then
        for _, part in ipairs(NexusX.Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

UI.createToggle(content, "NOCLIP", 15, Settings.noclip, function(v)
    Settings.noclip = v
    if v then
        applyNoclip()
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = NexusX.RunService.Stepped:Connect(function()
            if Settings.noclip then applyNoclip() end
        end)
    else
        stopNoclip()
    end
end, "noclip")

UI.createToggle(content, "SPEED", 55, Settings.speed, function(v)
    Settings.speed = v
    if v then
        applySpeed()
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = NexusX.RunService.Heartbeat:Connect(function()
            if Settings.speed and NexusX.Player.Character then
                local hum = NexusX.Player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= Settings.speedValue then hum.WalkSpeed = Settings.speedValue end
            end
        end)
    else
        stopSpeed()
    end
end, "speed")

UI.createSlider(content, "SPEED", 100, 16, 500, Settings.speedValue, function(v)
    Settings.speedValue = v
end, "speedValue")

table.insert(NexusX.Features.OnSettingsLoaded, function()
    if Settings.speed then
        applySpeed()
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = NexusX.RunService.Heartbeat:Connect(function()
            if Settings.speed and NexusX.Player.Character then
                local hum = NexusX.Player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.WalkSpeed ~= Settings.speedValue then hum.WalkSpeed = Settings.speedValue end
            end
        end)
    else
        stopSpeed()
    end

    if Settings.noclip then
        applyNoclip()
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = NexusX.RunService.Stepped:Connect(function()
            if Settings.noclip then applyNoclip() end
        end)
    else
        stopNoclip()
    end
end)
