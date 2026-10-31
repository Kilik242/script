local baseUrl = "https://raw.githubusercontent.com/Kilik242/script/main/"

local function loadModule(path)
    local url = baseUrl .. path
    print("📥 Загрузка: " .. url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then return result else warn("❌ Ошибка: " .. path); return nil end
end

-- 1. Окно
local UI = loadModule("UI/MainWindow.lua")
if not UI then return end
local mainFrame = UI.CreateWindow()
if not mainFrame then return end

-- 2. Вкладки
local Tabs = loadModule("UI/Tabs.lua")
local tabContainers = nil
if Tabs and mainFrame then
    tabContainers = Tabs.SetupTabs(mainFrame)
end

-- 3. Тестируем только Ауру
if tabContainers then
    local tabCombat = tabContainers["⚔️ Боевое"]
    if tabCombat then
        print("--- ТЕСТ: Загружаю KillAura ---")
        local KillAura = loadModule("Combat/KillAura.lua")
        if KillAura then 
            print("KillAura загружена, вызываю Start...")
            KillAura.Start(tabCombat) 
            print("KillAura.Start вызван!")
        else
            print("KillAura НЕ загружена (nil)")
        end
    else
        print("Вкладка 'Боевое' не найдена")
    end
end

print("✅ Тест завершен!")