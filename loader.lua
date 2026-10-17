local REPO_URL = "https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПО/main/"
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

for _, file in ipairs(FILES) do
    local url = REPO_URL .. file .. ".lua"
    local success, code = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and code and code ~= "" then
        local func, err = loadstring(code)
        if func then
            pcall(func)
        else
            warn("[NexusX] Ошибка компиляции " .. file .. ": " .. tostring(err))
        end
    else
        warn("[NexusX] Не удалось скачать " .. file)
    end
    task.wait(0.1)
end
