local baseUrl = "https://raw.githubusercontent.com/Kilik242/script/main/"

local function loadModule(path)
    local url = baseUrl .. path
    print("📥 Загрузка: " .. url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then return result else warn("❌ Ошибка: " .. path); return nil end
end

print("1. Загружаю окно...")
local UI = loadModule("UI/MainWindow.lua")
if not UI then return end
local mainFrame = UI.CreateWindow()
if not mainFrame then return end

print("2. Загружаю вкладки...")
local Tabs = loadModule("UI/Tabs.lua")
local tabContainers = nil
if Tabs and mainFrame then
    tabContainers = Tabs.SetupTabs(mainFrame)
end

print("3. Проверка вкладок...")
if tabContainers then
    print("✅ Вкладки созданы!")
    -- Выводим список всех вкладок для проверки
    for name, _ in pairs(tabContainers) do
        print("Найдена вкладка: " .. name)
    end
else
    warn("❌ Вкладки НЕ созданы!")
end

print("✅ Тест завершен (без модулей)")