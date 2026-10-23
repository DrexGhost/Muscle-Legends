local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local base = "https://raw.githubusercontent.com/DrexGhost/Muscle-Legends/main/"

local fileList = {
    "core.lua", "gui.lua", "main.lua", "helper.lua", "farm.lua",
    "ultimate.lua", "movement.lua", "event.lua", "settings.lua"
}
local total = #fileList

local oldLoad = PlayerGui:FindFirstChild("NexusX_Loading")
if oldLoad then oldLoad:Destroy() end

local loadGui = Instance.new("ScreenGui")
loadGui.Name = "NexusX_Loading"
loadGui.ResetOnSpawn = false
loadGui.IgnoreGuiInset = true
loadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadGui.DisplayOrder = 2147483647
loadGui.Parent = PlayerGui

local bgFrame = Instance.new("Frame")
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgFrame.BorderSizePixel = 0
bgFrame.Parent = loadGui

local logoLbl = Instance.new("TextLabel")
logoLbl.Size = UDim2.new(1, 0, 0, 44)
logoLbl.Position = UDim2.new(0, 0, 0.5, -90)
logoLbl.BackgroundTransparency = 1
logoLbl.Text = "NexusX"
logoLbl.TextColor3 = Color3.fromRGB(0, 229, 204)
logoLbl.TextSize = 40
logoLbl.Font = Enum.Font.GothamBlack
logoLbl.Parent = bgFrame

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, 0, 0, 22)
statusLbl.Position = UDim2.new(0, 0, 0.5, -30)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Загрузка..."
statusLbl.TextColor3 = Color3.fromRGB(232, 238, 248)
statusLbl.TextSize = 14
statusLbl.Font = Enum.Font.Gotham
statusLbl.Parent = bgFrame

local percentLbl = Instance.new("TextLabel")
percentLbl.Size = UDim2.new(1, 0, 0, 32)
percentLbl.Position = UDim2.new(0, 0, 0.5, 10)
percentLbl.BackgroundTransparency = 1
percentLbl.Text = "0%"
percentLbl.TextColor3 = Color3.fromRGB(0, 229, 204)
percentLbl.TextSize = 26
percentLbl.Font = Enum.Font.GothamBold
percentLbl.Parent = bgFrame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0, 320, 0, 6)
barBg.Position = UDim2.new(0.5, -160, 0.5, 60)
barBg.BackgroundColor3 = Color3.fromRGB(30, 38, 62)
barBg.BorderSizePixel = 0
barBg.Parent = bgFrame
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 229, 204)
barFill.BorderSizePixel = 0
barFill.Parent = barBg
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local function setProgress(loaded)
    local pct = math.floor(loaded / total * 100)
    percentLbl.Text = pct .. "%"
    barFill.Size = UDim2.new(loaded / total, 0, 1, 0)
end

setProgress(0)
task.wait(0.1)

local function httpGet(url)
    if request then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and res.Success and res.Body then return res.Body end
    end
    local ok, body = pcall(game.HttpGet, game, url)
    if ok then return body end
    return nil
end

local sources = {}

for i, name in ipairs(fileList) do
    statusLbl.Text = "Загрузка: " .. name
    task.wait(0.02)
    sources[name] = httpGet(base .. name)
    setProgress(i)
    task.wait(0.02)
end

statusLbl.Text = "Инициализация..."
task.wait(0.05)

local function compile(name, code)
    if not code then return nil end
    local fn = loadstring(code)
    if not fn then return nil end
    return fn
end

local function run(name, fn, ...)
    if not fn then return nil end
    local ok, result = pcall(fn, ...)
    if not ok then return nil end
    return result
end

local Core = run("core.lua", compile("core.lua", sources["core.lua"]))
if not Core then
    statusLbl.Text = "Ошибка: Core"
    statusLbl.TextColor3 = Color3.fromRGB(255, 90, 110)
    task.wait(2)
    loadGui:Destroy()
    return
end

local GUI = run("gui.lua", compile("gui.lua", sources["gui.lua"]), Core)
if not GUI then
    statusLbl.Text = "Ошибка: GUI"
    statusLbl.TextColor3 = Color3.fromRGB(255, 90, 110)
    task.wait(2)
    loadGui:Destroy()
    return
end

local tabs = {"main.lua", "helper.lua", "farm.lua", "ultimate.lua", "movement.lua", "event.lua", "settings.lua"}
for _, name in ipairs(tabs) do
    local fn = compile(name, sources[name])
    if fn then
        local ok, build = pcall(fn, Core, GUI)
        if ok and type(build) == "function" then
            pcall(build)
        end
    end
    task.wait(0.02)
end

pcall(function() GUI.activateFirstTab() end)
pcall(function() GUI.setOpenState(Core.settings.menuOpen) end)

statusLbl.Text = "Готово!"
task.wait(0.3)

loadGui:Destroy()