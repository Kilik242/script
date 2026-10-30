local baseUrl = "https://raw.githubusercontent.com/Kilik242/script/main/"

local function loadModule(path)
    local url = baseUrl .. path
    print("📥 Загрузка: " .. url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then return result else warn("❌ Ошибка: " .. path); return nil end
end

-- 1. Создаем окно
local UI = loadModule("UI/MainWindow.lua")
if not UI then return end
local mainFrame = UI.CreateWindow()

-- 2. Создаем вкладки (и получаем ссылки на них)
local Tabs = loadModule("UI/Tabs.lua")
local tabContainers = nil
if Tabs and mainFrame then
    tabContainers = Tabs.SetupTabs(mainFrame)
end

-- 3. Загружаем сканер NPC в вкладку "Сканеры"
local NPCScanner = loadModule("Explorer/NPCScanner.lua")
if NPCScanner and tabContainers then
    -- Передаем контейнер вкладки "Сканеры" (по имени, как мы его создали)
    NPCScanner.Start(tabContainers["📂 Сканеры"])
end

-- 4. Загружаем сканер Сундуков в ту же вкладку
local ChestScanner = loadModule("Explorer/ChestScanner.lua")
if ChestScanner and tabContainers then
    ChestScanner.Start(tabContainers["📂 Сканеры"])
end

print("✅ Kukish_REP полностью загружен!")