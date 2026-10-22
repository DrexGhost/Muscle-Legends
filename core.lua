local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local rEvents = RS:FindFirstChild("rEvents")

local Core = {}

Core.CONFIG_FOLDER = "MuscleLegendsConfigs"
Core.RETURN_POS = Vector3.new(-16.9, 36.3, -1243.5)

Core.T = {
    bg1 = Color3.fromRGB(14, 18, 32),
    bg2 = Color3.fromRGB(6, 9, 18),
    panel = Color3.fromRGB(20, 26, 44),
    panelHi = Color3.fromRGB(30, 38, 62),
    card = Color3.fromRGB(24, 30, 50),
    cardHover = Color3.fromRGB(34, 42, 68),
    row = Color3.fromRGB(26, 32, 52),
    accent = Color3.fromRGB(0, 229, 204),
    accentDim = Color3.fromRGB(0, 140, 128),
    accentSoft = Color3.fromRGB(140, 250, 235),
    text = Color3.fromRGB(232, 238, 248),
    textDim = Color3.fromRGB(150, 162, 190),
    textMuted = Color3.fromRGB(90, 102, 130),
    stroke = Color3.fromRGB(44, 54, 86),
    success = Color3.fromRGB(80, 230, 140),
    warn = Color3.fromRGB(255, 200, 80),
    danger = Color3.fromRGB(255, 90, 110),
    toggleOff = Color3.fromRGB(48, 58, 88),
    online = Color3.fromRGB(80, 230, 140),
    blue = Color3.fromRGB(70, 130, 220),
    blueHi = Color3.fromRGB(90, 150, 240),
}

Core.settings = {
    menuOpen = true, antiAfk = true, autoStrength = false, autoRebirth = false,
    autoClicker = false, bossFarm = false, collectChest = false, noclip = false,
    speed = false, walkSpeed = 50, size = false, sizeValue = 2,
    autoEventFarm = false, eventBosses = {EASY = false, MEDIUM = false, HARD = false, EXTREME = false},
    ultimates = {}, watermark = false, watermarkScale = 100, guiScale = 85,
    floatBtnSize = 58, floatBtnPos = {0, 20, 0.5, 0}
}

Core.CHESTS = {
    Vector3.new(-139, 7, -275), Vector3.new(-2569, 7, -556),
    Vector3.new(2208, 7, 912), Vector3.new(-6714, 7, -1459),
    Vector3.new(4667, 1000, -3694), Vector3.new(-7915, 41, 3026),
    Vector3.new(-4757, 99, 5580), Vector3.new(-2297, 195, 5506),
}

Core.BOSS_HEIGHTS = {
    Boss1 = 143, Boss2 = 143, Boss3 = 143, Boss4 = 143, Boss5 = 143, Boss6 = 143,
    ["Grim Reaper"] = 255, ["Frankenbrute"] = 145, ["Pumpkin Titan"] = 256, ["Scarecrow Colossus"] = 156,
}

Core.EVENT_BOSSES = {
    EXTREME = { model = "Grim Reaper", part = "Body0021" },
    HARD = { model = "Frankenbrute", part = "BODY" },
    MEDIUM = { model = "Pumpkin Titan", part = "Mesh.001" },
    EASY = { model = "Scarecrow Colossus", part = "Cube.004" }
}
Core.EVENT_BOSS_ORDER = {"EXTREME", "HARD", "MEDIUM", "EASY"}

Core.ABSOLUTE_ORDER = {
    "Golden Rebirth", "Galaxy Gains", "Muscle Mind", "Demon Damage",
    "Infernal Health", "Jungle Swift", "x2 Chest Rewards", "x2 Quest Rewards",
    "+5% Rep Speed", "+1 Pet Slot", "+10 Item Capacity", "+1 Daily Spin",
}

Core.ABSOLUTE_MAP = {
    ["Golden Rebirth"] = "UltimateGoldenRebirth", ["Galaxy Gains"] = "UltimateGalaxyGains",
    ["Muscle Mind"] = "UltimateMuscleMind", ["Demon Damage"] = "UltimateDemonDamage",
    ["Infernal Health"] = "UltimateInfernalHealth", ["Jungle Swift"] = "UltimateJungleSwift",
    ["x2 Chest Rewards"] = "UltimateChestRewards", ["x2 Quest Rewards"] = "UltimateQuestRewards",
    ["+5% Rep Speed"] = "UltimateRepSpeed", ["+1 Pet Slot"] = "UltimatePetSlot",
    ["+10 Item Capacity"] = "UltimateItemCapacity", ["+1 Daily Spin"] = "UltimateDailySpin",
}

Core.ABSOLUTE_MAX = {
    UltimateGoldenRebirth = 5, UltimatePetSlot = 3, UltimateMuscleMind = 5,
    UltimateDemonDamage = 5, UltimateRepSpeed = 10, UltimateInfernalHealth = 5,
    UltimateChestRewards = 5, UltimateJungleSwift = 5, UltimateItemCapacity = 6,
    UltimateQuestRewards = 3, UltimateGalaxyGains = 5, UltimateDailySpin = 5,
}

for _, name in ipairs(Core.ABSOLUTE_ORDER) do
    Core.settings.ultimates[name] = false
end

Core.toggleRefs = {}
Core.sliderRefs = {}
Core.SavedCollide = {}
Core.NoclipActive = false
Core.Char, Core.HRP, Core.Hum = nil, nil, nil

function Core.bindCharacter(c)
    Core.Char = c
    Core.HRP = c:WaitForChild("HumanoidRootPart")
    Core.Hum = c:WaitForChild("Humanoid")
    Core.SavedCollide = {}
    Core.NoclipActive = false
end
if LocalPlayer.Character then Core.bindCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(Core.bindCharacter)

function Core.setNoclip(enabled)
    if not Core.Char then return end
    if enabled then
        for _, p in ipairs(Core.Char:GetDescendants()) do
            if p:IsA("BasePart") then
                if Core.SavedCollide[p] == nil then Core.SavedCollide[p] = p.CanCollide end
                p.CanCollide = false
            end
        end
    else
        for part, state in pairs(Core.SavedCollide) do
            if part and part.Parent then part.CanCollide = state end
        end
        Core.SavedCollide = {}
    end
end

function Core.findGroundPos(fromPos)
    if not Core.Char then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Core.Char }
    local result = workspace:Raycast(fromPos + Vector3.new(0, 5, 0), Vector3.new(0, -2000, 0), params)
    if result then return result.Position + Vector3.new(0, 3.5, 0) end
    return nil
end

function Core.stopFarm()
    if not Core.HRP or not Core.Hum then return end
    Core.HRP.AssemblyLinearVelocity = Vector3.zero
    Core.HRP.AssemblyAngularVelocity = Vector3.zero

    local target = Core.findGroundPos(Core.HRP.Position) or Core.findGroundPos(Core.RETURN_POS) or Core.RETURN_POS
    Core.HRP.CFrame = CFrame.new(target)

    if Core.NoclipActive then
        Core.setNoclip(false)
        Core.NoclipActive = false
    end

    Core.Hum.PlatformStand = false
    Core.Hum.AutoRotate = true
end

function Core.returnToBase()
    if not Core.HRP then return end
    Core.HRP.AssemblyLinearVelocity = Vector3.zero
    Core.HRP.AssemblyAngularVelocity = Vector3.zero
    local target = Core.findGroundPos(Core.RETURN_POS) or Core.RETURN_POS
    Core.HRP.CFrame = CFrame.new(target)
end

function Core.loadSettings()
    local ok, result = pcall(function()
        if not LocalPlayer:FindFirstChild("MLSettings") then
            local ds = Instance.new("Folder")
            ds.Name = "MLSettings"
            ds.Parent = LocalPlayer
        end
        return LocalPlayer.MLSettings
    end)
    if ok and result then
        Core.dataStore = result
        for name, defaultValue in pairs(Core.settings) do
            local stored = Core.dataStore:FindFirstChild(name)
            if stored then
                if stored:GetAttribute("dataType") == "table" and stored:IsA("StringValue") then
                    local sOk, decoded = pcall(function() return HttpService:JSONDecode(stored.Value) end)
                    if sOk then Core.settings[name] = decoded end
                elseif type(defaultValue) == type(stored.Value) then
                    Core.settings[name] = stored.Value
                end
            end
        end
    end
end

function Core.saveSetting(name, value)
    Core.settings[name] = value
    if not Core.dataStore then return end
    local stored = Core.dataStore:FindFirstChild(name)
    local dType
    if type(value) == "table" then dType = "table"
    elseif typeof(value) == "string" then dType = "string"
    elseif typeof(value) == "number" then dType = "number"
    elseif typeof(value) == "boolean" then dType = "bool"
    else return end

    if stored and stored:GetAttribute("dataType") ~= dType then
        stored:Destroy()
        stored = nil
    end
    if not stored then
        if dType == "table" then
            stored = Instance.new("StringValue")
            stored:SetAttribute("dataType", "table")
        elseif dType == "string" then stored = Instance.new("StringValue")
        elseif dType == "number" then stored = Instance.new("NumberValue")
        else stored = Instance.new("BoolValue") end
        stored.Name = name
        stored.Parent = Core.dataStore
    end
    if dType == "table" then stored.Value = HttpService:JSONEncode(value)
    else stored.Value = value end
end

function Core.listConfigs()
    if not isfolder or not listfiles then return {} end
    pcall(function() if not isfolder(Core.CONFIG_FOLDER) then makefolder(Core.CONFIG_FOLDER) end end)
    local result = {}
    local ok, files = pcall(function() return listfiles(Core.CONFIG_FOLDER) end)
    if not ok or type(files) ~= "table" then return result end
    for _, filePath in ipairs(files) do
        local n = tostring(filePath):match("([^/\\]+)%.json$")
        if n then table.insert(result, n) end
    end
    table.sort(result)
    return result
end

function Core.saveConfigAs(name)
    local data = {}
    for k, v in pairs(Core.settings) do data[k] = v end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    return pcall(function() writefile(Core.CONFIG_FOLDER .. "/" .. name .. ".json", encoded) end)
end

function Core.loadConfigFrom(name)
    local path = Core.CONFIG_FOLDER .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local ok, contents = pcall(function() return readfile(path) end)
    if not ok then return false end
    local ok2, decoded = pcall(function() return HttpService:JSONDecode(contents) end)
    if not ok2 or type(decoded) ~= "table" then return false end
    for k, v in pairs(decoded) do
        if Core.settings[k] ~= nil and type(Core.settings[k]) == type(v) then
            Core.settings[k] = v
            Core.saveSetting(k, v)
        end
    end
    return true
end

function Core.deleteConfig(name)
    return pcall(function() delfile(Core.CONFIG_FOLDER .. "/" .. name .. ".json") end)
end

function Core.hasDumbbell()
    if not Core.Char then return false end
    for _, child in pairs(Core.Char:GetChildren()) do
        if child:IsA("Tool") then
            local n = string.lower(child.Name)
            if string.find(n, "weight") or string.find(n, "dumbbell") or string.find(n, "barbell") then return true end
        end
    end
    return false
end

function Core.equipDumbbell()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp or not Core.Char then return end
    for _, tool in pairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if string.find(n, "weight") or string.find(n, "dumbbell") or string.find(n, "barbell") then
                tool.Parent = Core.Char
                task.wait(0.1)
                return
            end
        end
    end
end

function Core.doClicker()
    if VIM then
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

function Core.punch()
    if not Core.Char then return end
    local tool = Core.Char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    else
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            local p = bp:FindFirstChild("Punch")
            if p then
                p.Parent = Core.Char
                task.wait(0.1)
                pcall(function() p:Activate() end)
            end
        end
    end
end

function Core.setSize(val)
    if rEvents then
        local csr = rEvents:FindFirstChild("changeSpeedSizeRemote")
        if csr then pcall(function() csr:InvokeServer("changeSize", val) end) end
    end
end

function Core.doRebirth()
    if rEvents then
        local rr = rEvents:FindFirstChild("rebirthRemote")
        if rr then pcall(function() rr:InvokeServer("rebirthRequest") end) end
    end
end

function Core.upgradeUltimate(name)
    if rEvents then
        local ur = rEvents:FindFirstChild("ultimatesRemote")
        if ur then pcall(function() ur:InvokeServer("upgradeUltimate", name) end) end
    end
end

function Core.getUltimateLevel(name)
    local attr = Core.ABSOLUTE_MAP[name]
    if not attr then return 0 end
    local v = LocalPlayer:GetAttribute(attr)
    return typeof(v) == "number" and v or 0
end

Core.loadSettings()
if Core.settings.antiAfk == nil then Core.settings.antiAfk = true end
Core.saveSetting("antiAfk", Core.settings.antiAfk)

task.spawn(function()
    while task.wait(60) do
        if Core.settings.antiAfk then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
    end
end)

return Core