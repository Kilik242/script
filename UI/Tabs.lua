local module = {}

function module.SetupTabs(parentFrame)
    print("📑 Создаю вкладки...")
    
    local tabActive = Color3.fromRGB(0, 150, 80)
    local tabInactive = Color3.fromRGB(20, 40, 20)
    local glassBg = Color3.fromRGB(15, 35, 15)

    -- Контейнер для кнопок вкладок
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 120, 1, -60)
    tabContainer.Position = UDim2.new(0, 10, 0, 50)
    tabContainer.BackgroundColor3 = glassBg
    tabContainer.BackgroundTransparency = 0.5
    tabContainer.Parent = parentFrame
    Instance.new("UICorner", tabContainer).CornerRadius = UDim.new(0, 8)

    -- Контейнер для контента
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -150, 1, -60)
    contentContainer.Position = UDim2.new(0, 140, 0, 50)
    contentContainer.BackgroundColor3 = Color3.fromRGB(10, 20, 10)
    contentContainer.BackgroundTransparency = 0.5
    contentContainer.Parent = parentFrame
    Instance.new("UICorner", contentContainer).CornerRadius = UDim.new(0, 8)

    local tabs = {}
    local contents = {}
    local tabsData = {} -- Сюда сохраним ссылки на контейнеры

    local function createTab(name, index)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 35)
        btn.Position = UDim2.new(0, 5, 0, 5 + (index - 1) * 40)
        btn.BackgroundColor3 = tabInactive
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = tabContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -10, 1, -10)
        content.Position = UDim2.new(0, 5, 0, 5)
        content.BackgroundTransparency = 1
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.Visible = false
        content.Parent = contentContainer
        
        table.insert(tabs, btn)
        table.insert(contents, content)
        
        btn.MouseButton1Click:Connect(function()
            for i, t in ipairs(tabs) do
                t.BackgroundColor3 = tabInactive
                contents[i].Visible = false
            end
            btn.BackgroundColor3 = tabActive
            content.Visible = true
        end)
        
        -- Сохраняем контейнер для возврата
        tabsData[name] = content
        return content
    end

    -- Создаем вкладки
    createTab("⚔️ Боевое", 1)
    createTab("📂 Сканеры", 2)
    createTab("⚙️ Настройки", 3)

    -- Активируем первую
    tabs[1].BackgroundColor3 = tabActive
    contents[1].Visible = true

    print("✅ Вкладки успешно созданы!")
    
    -- ВОЗВРАЩАЕМ таблицу с контейнерами
    return tabsData
end

return module