local baseUrl = "https://raw.githubusercontent.com/Kilik242/script/master/"

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

-- 2. Создаем вкладки
local Tabs = loadModule("UI/Tabs.lua")
local tabContainers = nil
if Tabs and mainFrame then
    tabContainers = Tabs.SetupTabs(mainFrame)
end

-- 3. Загружаем модули и вставляем их в нужные вкладки
if tabContainers then
    -- Вкладка "Сканеры"
    local NPCScanner = loadModule("Explorer/NPCScanner.lua")
    if NPCScanner then NPCScanner.Start(tabContainers["📂 Сканеры"]) end

    local ChestScanner = loadModule("Explorer/ChestScanner.lua")
    if ChestScanner then ChestScanner.Start(tabContainers["📂 Сканеры"]) end

    local OreScanner = loadModule("Explorer/OreScanner.lua")
    if OreScanner then OreScanner.Start(tabContainers["📂 Сканеры"]) end

    -- Вкладка "Боевое"
    local KillAura = loadModule("Combat/KillAura.lua")
    if KillAura then KillAura.Start(tabContainers["⚔️ Боевое"]) end
end

print("✅ Kukish_REP успешно загружен!")