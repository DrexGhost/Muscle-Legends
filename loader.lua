local base = "https://raw.githubusercontent.com/DrexGhost/Muscle-Legends/main/"

local function fetch(name)
    local url = base .. name
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then return nil end
    return code
end

local function compile(name, code)
    if not code then return nil end
    local fn, err = loadstring(code)
    if not fn then return nil end
    return fn
end

local function run(name, fn, ...)
    if not fn then return nil end
    local ok, result = pcall(fn, ...)
    if not ok then return nil end
    return result
end

local Core = run("core.lua", compile("core.lua", fetch("core.lua")))
if not Core then return end

Core.loadSettings()

local GUI = run("gui.lua", compile("gui.lua", fetch("gui.lua")), Core)
if not GUI then return end

local function loadTab(name)
    local code = fetch(name)
    if not code then return end
    local fn = compile(name, code)
    if not fn then return end
    local ok, build = pcall(fn, Core, GUI)
    if not ok then return end
    if type(build) == "function" then
        pcall(build)
    end
end

loadTab("main.lua")
loadTab("helper.lua")
loadTab("farm.lua")
loadTab("ultimate.lua")
loadTab("movement.lua")
loadTab("event.lua")
loadTab("settings.lua")

pcall(function() GUI.activateFirstTab() end)
pcall(function() GUI.setOpenState(Core.settings.menuOpen) end)
pcall(function() Core.startLoops() end)
