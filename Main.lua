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

if tabContainers then
    print("✅ Вкладки созданы успешно!")
else
    warn("❌ Вкладки НЕ созданы (tabContainers = nil)")
end

print("✅ Тест завершен!")