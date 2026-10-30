-- Базовый URL для загрузки модулей (ветка main)
local baseUrl = "https://raw.githubusercontent.com/Kilik242/script/main/"

local function loadModule(path)
    local url = baseUrl .. path
    print("📥 Загрузка: " .. url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then 
        return result 
    else 
        warn("❌ Ошибка загрузки: " .. path)
        return nil 
    end
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

-- 3. Загружаем модули в нужные вкладки
if tabContainers then
    
    -- ================= ВКЛАДКА "БОЕВОЕ" =================
    local tabCombat = tabContainers["⚔️ Боевое"]
    
    if tabCombat then
        -- Килл-Аура
        local KillAura = loadModule("Combat/KillAura.lua")
        if KillAura then KillAura.Start(tabCombat) end
        
        -- Полёт (Fly)
        local Fly = loadModule("Combat/Fly.lua")
        if Fly then Fly.Start(tabCombat) end

        -- Noclip
        local Noclip = loadModule("Combat/Noclip.lua")
        if Noclip then Noclip.Start(tabCombat) end

        -- Attach (Прикрепление) - НОВОЕ
        local Attach = loadModule("Combat/Attach.lua")
        if Attach then Attach.Start(tabCombat) end
    else
        warn("❌ Не найдена вкладка '⚔️ Боевое'")
    end

    -- ================= ВКЛАДКА "СКАНЕРЫ" =================
    local tabExplorer = tabContainers["📂 Сканеры"]
    
    if tabExplorer then
        -- Сканер NPC
        local NPCScanner = loadModule("Explorer/NPCScanner.lua")
        if NPCScanner then NPCScanner.Start(tabExplorer) end

        -- Сканер Сундуков
        local ChestScanner = loadModule("Explorer/ChestScanner.lua")
        if ChestScanner then ChestScanner.Start(tabExplorer) end

        -- Сканер Руды/Камней
        local OreScanner = loadModule("Explorer/OreScanner.lua")
        if OreScanner then OreScanner.Start(tabExplorer) end
    else
        warn("❌ Не найдена вкладка '📂 Сканеры'")
    end

    -- ================= ВКЛАДКА "НАСТРОЙКИ" =================
    local tabSettings = tabContainers["⚙️ Настройки"]
    if tabSettings then
        local Config = loadModule("Settings/Config.lua")
        if Config then Config.Start(tabSettings) end
    else
        warn("❌ Не найдена вкладка '⚙️ Настройки'")
    end

end

print("✅ Kukish_REP Update 3.0 успешно загружен!")