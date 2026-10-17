local REPO_URL = "https://raw.githubusercontent.com/DrexGhost/Muscle-Legends/main/"
local FILES = {
    "core",
    "gui",
    "main",
    "auto",
    "teleport",
    "movement",
    "kill",
    "event",
    "ultimate",
    "other"
}

local function loadScript(file)
    local url = REPO_URL .. file .. ".lua"
    
    -- Добавляем рандомный параметр, чтобы GitHub не кэшировал старую версию
    local antiCacheUrl = url .. "?t=" .. tostring(tick())
    
    local success, code = pcall(function()
        return game:HttpGet(antiCacheUrl)
    end)
    
    if success and code and code ~= "" then
        local func, err = loadstring(code)
        if func then
            pcall(func)
            print("[NexusX] Успешно загружен: " .. file .. ".lua")
        else
            warn("[NexusX] Ошибка синтаксиса в " .. file .. ".lua: " .. tostring(err))
        end
    else
        warn("[NexusX] Не удалось скачать: " .. file .. ".lua")
    end
    task.wait(0.1)
end

print("[NexusX] Запуск...")
for _, file in ipairs(FILES) do
    loadScript(file)
end
print("[NexusX] Загрузка завершена!")
