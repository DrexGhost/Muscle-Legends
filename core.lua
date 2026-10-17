local NexusX = {}
_G.NexusX = NexusX

NexusX.Player = game:GetService("Players").LocalPlayer
NexusX.UIS = game:GetService("UserInputService")
NexusX.RunService = game:GetService("RunService")
NexusX.TweenService = game:GetService("TweenService")
NexusX.ReplicatedStorage = game:GetService("ReplicatedStorage")
NexusX.HttpService = game:GetService("HttpService")
NexusX.VIM = game:GetService("VirtualInputManager")

NexusX.rEvents = NexusX.ReplicatedStorage:FindFirstChild("rEvents")
NexusX.Threads = {}
NexusX.Features = { OnSettingsLoaded = {} }
NexusX.UI = {}
NexusX.State = { searchStartTime = nil, lastAttack = 0 }

NexusX.CONFIG_FILE = "NexusXMuscle_Legends.json"

function NexusX.startThread(key, fn)
    if NexusX.Threads[key] then
        task.cancel(NexusX.Threads[key])
        NexusX.Threads[key] = nil
    end
    NexusX.Threads[key] = task.spawn(fn)
end

function NexusX.stopThread(key)
    if NexusX.Threads[key] then
        task.cancel(NexusX.Threads[key])
        NexusX.Threads[key] = nil
    end
end

NexusX.Colors = {
    bg = Color3.fromRGB(10, 10, 10),
    accent = Color3.fromRGB(20, 20, 20),
    button = Color3.fromRGB(25, 25, 25),
    buttonHover = Color3.fromRGB(35, 35, 35),
    text = Color3.fromRGB(210, 210, 210),
    toggleOn = Color3.fromRGB(60, 120, 60),
    toggleOff = Color3.fromRGB(50, 50, 50),
}

NexusX.CHESTS = {
    { name = "Golden", coords = Vector3.new(-139, 7, -275) },
    { name = "Enchanted", coords = Vector3.new(-2569, 7, -556) },
    { name = "Mythical", coords = Vector3.new(2208, 7, 912) },
    { name = "Magma", coords = Vector3.new(-6714, 7, -1459) },
    { name = "Legends", coords = Vector3.new(4667, 1000, -3694) },
    { name = "Jungle", coords = Vector3.new(-7915, 41, 3026) },
    { name = "Industrial", coords = Vector3.new(-4757, 99, 5580) },
    { name = "Overcharged", coords = Vector3.new(-2297, 195, 5506) },
}

NexusX.EVENT_BOSSES = {
    EASY = { modelName = "Scarecrow Colossus", partName = "Cube.004", color = Color3.fromRGB(100, 255, 100) },
    MEDIUM = { modelName = "Pumpkin Titan", partName = "Mesh.001", color = Color3.fromRGB(255, 255, 100) },
    HARD = { modelName = "Frankenbrute", partName = "BODY", color = Color3.fromRGB(255, 150, 50) },
    EXTREME = { modelName = "Grim Reaper", partName = "Body0021", color = Color3.fromRGB(180, 100, 255) }
}
NexusX.EVENT_BOSS_ORDER = {"EXTREME", "HARD", "MEDIUM", "EASY"}

NexusX.ABSOLUTE_ORDER = {
    "Golden Rebirth", "Galaxy Gains", "Muscle Mind", "Demon Damage",
    "Infernal Health", "Jungle Swift", "x2 Chest Rewards", "x2 Quest Rewards",
    "+5% Rep Speed", "+1 Pet Slot", "+10 Item Capacity", "+1 Daily Spin",
}

NexusX.ABSOLUTE_MAX = {
    UltimateGoldenRebirth = 5, UltimatePetSlot = 3, UltimateMuscleMind = 5,
    UltimateDemonDamage = 5, UltimateRepSpeed = 10, UltimateInfernalHealth = 5,
    UltimateChestRewards = 5, UltimateJungleSwift = 5, UltimateItemCapacity = 6,
    UltimateQuestRewards = 3, UltimateGalaxyGains = 5, UltimateDailySpin = 5,
}

pcall(function()
    NexusX.UltimateAttributes = require(NexusX.ReplicatedStorage.shared.config.UltimateAttributes)
end)

NexusX.Settings = {
    menuOpen = true, fps = false, antiAfk = true, autoFull = false,
    autoLifting = false, autoRebirth = false, autoSize = false, autoClicker = false,
    autoCollect = false, noclip = false, farmBoss = false, autoFarmBoss = false,
    speed = false, speedValue = 50, autoAbsolute = false,
    fpsPos = {0, 10, 0, 10}, openBtnPos = {0.5, -19, 0.5, -19},
    menuPos = {0.5, -300, 0.5, -150}, openBtnSize = 38,
    selectedBosses = {EASY = false, MEDIUM = false, HARD = false, EXTREME = false},
    selectedUltimates = {}, autoFullSize = true, autoFullRebirth = true,
    autoFullTeleport = true, autoFullLifting = true
}

for _, name in ipairs(NexusX.ABSOLUTE_ORDER) do
    NexusX.Settings.selectedUltimates[name] = false
end

function NexusX.hasFileSupport()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

function NexusX.loadSettings()
    if not NexusX.hasFileSupport() then return end
    if not isfile(NexusX.CONFIG_FILE) then return end
    local success, data = pcall(function()
        return NexusX.HttpService:JSONDecode(readfile(NexusX.CONFIG_FILE))
    end)
    if success and data then
        for k, v in pairs(data) do
            if NexusX.Settings[k] ~= nil and k ~= "menuOpen" then
                if (k == "selectedBosses" or k == "selectedUltimates") and type(v) == "table" then
                    for bk, bv in pairs(v) do NexusX.Settings[k][bk] = bv end
                else
                    NexusX.Settings[k] = v
                end
            end
        end
    end
end

function NexusX.saveConfigToFile()
    if not NexusX.hasFileSupport() then return false end
    local data = {}
    for k, v in pairs(NexusX.Settings) do
        if k ~= "menuOpen" then data[k] = v end
    end
    local ok = pcall(function()
        writefile(NexusX.CONFIG_FILE, NexusX.HttpService:JSONEncode(data))
    end)
    return ok
end

function NexusX.saveSetting(name, value)
    NexusX.Settings[name] = value
end

NexusX.loadSettings()

function NexusX.getStrength()
    local stats = NexusX.Player:FindFirstChild("leaderstats")
    if stats then local s = stats:FindFirstChild("Strength"); if s then return s.Value end end
    return 0
end

function NexusX.getRebirths()
    local stats = NexusX.Player:FindFirstChild("leaderstats")
    if stats then local r = stats:FindFirstChild("Rebirths"); if r then return r.Value end end
    return 0
end

function NexusX.formatNumber(n)
    if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(n)
end

function NexusX.getUltimateLevel(attrName)
    local v = NexusX.Player:GetAttribute(attrName)
    if typeof(v) == "number" then return v end
    return 0
end

function NexusX.getUltimateAttr(displayName)
    if NexusX.UltimateAttributes and NexusX.UltimateAttributes[displayName] then
        return NexusX.UltimateAttributes[displayName]
    end
    return nil
end

function NexusX.hasDumbbell()
    local char = NexusX.Player.Character
    if not char then return false end
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local n = string.lower(child.Name)
            if string.find(n, "weight") or string.find(n, "dumbbell") or string.find(n, "barbell") then return true end
        end
    end
    return false
end

function NexusX.equipDumbbell()
    local backpack = NexusX.Player:FindFirstChild("Backpack")
    if not backpack then return false end
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if string.find(n, "weight") or string.find(n, "dumbbell") or string.find(n, "barbell") then
                local ok = pcall(function() tool.Parent = NexusX.Player.Character end)
                return ok
            end
        end
    end
    return false
end

function NexusX.equipPunch()
    local myChar = NexusX.Player.Character
    if not myChar then return nil end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if tool then return tool end
    local backpack = NexusX.Player:FindFirstChild("Backpack")
    if not backpack then return nil end
    local punch = backpack:FindFirstChild("Punch")
    if punch and punch:IsA("Tool") then
        local ok = pcall(function() punch.Parent = myChar end)
        if ok then return punch end
    end
    return nil
end

function NexusX.activateTool()
    if not NexusX.Player.Character then return end
    local tool = NexusX.Player.Character:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
end

function NexusX.doClicker()
    NexusX.VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.02)
    NexusX.VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

function NexusX.setSize(scale)
    if not NexusX.rEvents then return end
    local csr = NexusX.rEvents:FindFirstChild("changeSpeedSizeRemote")
    if csr then pcall(function() csr:InvokeServer("changeSize", scale) end) end
end

function NexusX.getRandomHitboxName()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local name = "_"
    for i = 1, 8 do
        local idx = math.random(1, #chars)
        name = name .. chars:sub(idx, idx)
    end
    return name
end

local hitboxCache = {}
function NexusX.clearHitboxes()
    for parent, hitbox in pairs(hitboxCache) do
        if hitbox and hitbox.Parent then hitbox:Destroy() end
    end
    hitboxCache = {}
end

function NexusX.createHitbox(bossPart)
    if not bossPart or not bossPart.Parent then return end
    local parent = bossPart.Parent
    local cached = hitboxCache[parent]
    if cached and cached.Parent then
        cached.Size = Vector3.new(35, 35, 35)
        cached.CFrame = bossPart.CFrame
        return
    end
    for _, obj in ipairs(parent:GetChildren()) do
        if obj.Name:sub(1, 10) == "ML_Hitbox_" then obj:Destroy() end
    end
    local hitbox = Instance.new("Part")
    hitbox.Name = "ML_Hitbox_" .. NexusX.getRandomHitboxName()
    hitbox.Size = Vector3.new(35, 35, 35)
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Massless = true
    hitbox.CFrame = bossPart.CFrame
    hitbox.Parent = parent
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hitbox
    weld.Part1 = bossPart
    weld.Parent = hitbox
    hitboxCache[parent] = hitbox
end

function NexusX.punch()
    local myChar = NexusX.Player.Character
    if not myChar then return end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
        return
    end
    task.spawn(function()
        local punchTool = NexusX.equipPunch()
        if punchTool then pcall(function() punchTool:Activate() end) end
    end)
end
