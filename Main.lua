-- Базовый URL
local baseUrl = "https://raw.githubusercontent.com/Kilik242/script/main/"

-- Функция загрузки с выводом ошибок
local function loadModule(path)
    local url = baseUrl .. path
    print("📥 Загрузка: " .. url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then 
        return result 
    else 
        warn("❌ ОШИБКА В МОДУЛЕ: " .. path)
        warn("Текст ошибки: " .. tostring(result))
        return nil 
    end
end

-- 1. Окно
local UI = loadModule("UI/MainWindow.lua")
if not UI then return end
local mainFrame = UI.CreateWindow()
if not mainFrame then return end

-- НОВОЕ: Водяной знак
local Watermark = loadModule("UI/Watermark.lua")
if Watermark then 
    Watermark.Create(mainFrame) 
end

-- 2. Вкладки
local Tabs = loadModule("UI/Tabs.lua")
local tabContainers = nil
if Tabs and mainFrame then
    tabContainers = Tabs.SetupTabs(mainFrame)
end

-- 3. Модули
if tabContainers then
    
    -- ================= ВКЛАДКА "БОЕВОЕ" =================
      local tabCombat = tabContainers["⚔️ Боевое"]
    if tabCombat then
        local KillAura = loadModule("Combat/KillAura.lua")
        if KillAura then KillAura.Start(tabCombat) end
        
        local Fly = loadModule("Combat/Fly.lua")
        if Fly then Fly.Start(tabCombat) end

        local Noclip = loadModule("Combat/Noclip.lua")
        if Noclip then Noclip.Start(tabCombat) end
        
        local AutoAttack = loadModule("Combat/AutoAttack.lua")
        if AutoAttack then AutoAttack.Start(tabCombat) end
    end
    -- ================= ВКЛАДКА "СКАНЕРЫ" =================
    local tabExplorer = tabContainers["📂 Сканеры"]
    if tabExplorer then
        local NPCScanner = loadModule("Explorer/NPCScanner.lua")
        if NPCScanner then NPCScanner.Start(tabExplorer) end

        local ChestScanner = loadModule("Explorer/ChestScanner.lua")
        if ChestScanner then ChestScanner.Start(tabExplorer) end
    end

    -- ================= ВКЛАДКА "РУДЫ" =================
    local tabOres = tabContainers["⛏️ Руды"]
    if tabOres then
        local OreRadar = loadModule("Explorer/OreRadar.lua")
        if OreRadar then OreRadar.Start(tabOres) end
    end

    -- ================= ВКЛАДКА "ПРИКРЕПЛЕНИЕ" =================
    local tabAttach = tabContainers["🧲 Прикрепление"]
    if tabAttach then
        local Attach = loadModule("Combat/Attach.lua")
        if Attach then Attach.Start(tabAttach) end
    else
        warn("❌ Не найдена вкладка '🧲 Прикрепление'")
    end

end -- Конец проверки if tabContainers

print("✅ Kukish_REP успешно загружен!")