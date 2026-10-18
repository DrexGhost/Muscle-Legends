local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local rEvents = RS:FindFirstChild("rEvents")

local Core = {}

Core.CONFIG_FILE = "NexusXMuscle_Legends.json"
Core.CONFIG_FOLDER = "MuscleLegendsConfigs"

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
    menuOpen = true,
    autoStrength = false,
    autoRebirth = false,
    autoClicker = false,
    bossFarm = false,
    collectChest = false,
    noclip = false,
    speed = false,
    walkSpeed = 50,
    size = false,
    sizeValue = 2,
    autoEventFarm = false,
    eventBosses = {EASY = false, MEDIUM = false, HARD = false, EXTREME = false},
    ultimates = {},
    watermark = false,
    watermarkScale = 100,
    guiScale = 85,
    floatBtnSize = 58,
    floatBtnPos = {0, 20, 0.5, 0}
}

Core.CHESTS = {
    { name = "Golden", coords = Vector3.new(-139, 7, -275) },
    { name = "Enchanted", coords = Vector3.new(-2569, 7, -556) },
    { name = "Mythical", coords = Vector3.new(2208, 7, 912) },
    { name = "Magma", coords = Vector3.new(-6714, 7, -1459) },
    { name = "Legends", coords = Vector3.new(4667, 1000, -3694) },
    { name = "Jungle", coords = Vector3.new(-7915, 41, 3026) },
    { name = "Industrial", coords = Vector3.new(-4757, 99, 5580) },
    { name = "Overcharged", coords = Vector3.new(-2297, 195, 5506) },
}

Core.BOSS_HEIGHTS = {
    Boss1 = 143, Boss2 = 143, Boss3 = 143,
    Boss4 = 143, Boss5 = 143, Boss6 = 143
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

function Core.loadSettings()
    local success, result = pcall(function()
        if not LocalPlayer:FindFirstChild("MLSettings") then
            local ds = Instance.new("Folder")
            ds.Name = "MLSettings"
            ds.Parent = LocalPlayer
        end
        return LocalPlayer.MLSettings
    end)
    if success and result then
        Core.dataStore = result
        for name, defaultValue in pairs(Core.settings) do
            local stored = Core.dataStore:FindFirstChild(name)
            if stored then
                if stored:GetAttribute("dataType") == "table" and stored:IsA("StringValue") then
                    local ok, decoded = pcall(function() return HttpService:JSONDecode(stored.Value) end)
                    if ok then Core.settings[name] = decoded end
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
    local dataType
    if type(value) == "table" then dataType = "table"
    elseif typeof(value) == "string" then dataType = "string"
    elseif typeof(value) == "number" then dataType = "number"
    else dataType = "bool" end

    if stored and stored:GetAttribute("dataType") ~= dataType then
        stored:Destroy()
        stored = nil
    end
    if not stored then
        if dataType == "table" then
            stored = Instance.new("StringValue")
            stored:SetAttribute("dataType", "table")
        elseif dataType == "string" then stored = Instance.new("StringValue")
        elseif dataType == "number" then stored = Instance.new("NumberValue")
        else stored = Instance.new("BoolValue") end
        stored.Name = name
        stored.Parent = Core.dataStore
    end
    if dataType == "table" then stored.Value = HttpService:JSONEncode(value)
    else stored.Value = value end
end

function Core.ensureFolder()
    if not isfolder or not makefolder then return false end
    pcall(function() if not isfolder(Core.CONFIG_FOLDER) then makefolder(Core.CONFIG_FOLDER) end end)
    return true
end

function Core.listConfigs()
    if not isfolder or not listfiles then return {} end
    Core.ensureFolder()
    local result = {}
    local ok, files = pcall(function() return listfiles(Core.CONFIG_FOLDER) end)
    if not ok or type(files) ~= "table" then return result end
    for _, filePath in ipairs(files) do
        local fileName = tostring(filePath):match("([^/\\]+)$") or tostring(filePath)
        local n = fileName:match("^(.+)%.json$")
        if n then table.insert(result, n) end
    end
    table.sort(result)
    return result
end

function Core.saveConfigAs(name)
    Core.ensureFolder()
    local data = {}
    for k, v in pairs(Core.settings) do data[k] = v end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    local path = Core.CONFIG_FOLDER .. "/" .. name .. ".json"
    return pcall(function() writefile(path, encoded) end)
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
    local path = Core.CONFIG_FOLDER .. "/" .. name .. ".json"
    return pcall(function() delfile(path) end)
end

function Core.hasDumbbell()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local n = string.lower(child.Name)
            if string.find(n, "weight") or string.find(n, "dumbbell") or string.find(n, "barbell") then return true end
        end
    end
    return false
end

function Core.equipDumbbell()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    for _, tool in pairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if string.find(n, "weight") or string.find(n, "dumbbell") or string.find(n, "barbell") then
                tool.Parent = LocalPlayer.Character
                task.wait(0.1)
                return
            end
        end
    end
end

function Core.doClicker()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

function Core.punch()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    else
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            local p = bp:FindFirstChild("Punch")
            if p then
                p.Parent = char
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
    local attr = "Ultimate" .. name:gsub("%s+", "")
    local v = LocalPlayer:GetAttribute(attr)
    return typeof(v) == "number" and v or 0
end

return Core
