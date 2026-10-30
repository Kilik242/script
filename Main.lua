-- 3. Загружаем модули в нужные вкладки
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
        local Attach = loadModule("Combat/Attach.lua") -- Путь должен вести в Combat!
        if Attach then Attach.Start(tabAttach) end
    end

end