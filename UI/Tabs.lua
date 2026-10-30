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
    local tabsData = {}

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
        
        -- СОЗДАЕМ СКРОЛЛ ДЛЯ КОНТЕНТА (чтобы все кнопки влезали)
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -10, 1, -10)
        content.Position = UDim2.new(0, 5, 0, 5)
        content.BackgroundTransparency = 1
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.ScrollBarThickness = 4
        content.Visible = false
        content.Parent = contentContainer
        
        -- АВТО-РАССТАНОВКА (все кнопки друг под другом)
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = content
        
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
        
        tabsData[name] = content
        return content
    end

    -- Создаем вкладки
    createTab("⚔️ Боевое", 1)
    createTab("📂 Сканеры", 2)
    createTab("⛏️ Руды", 3)
    createTab("🧲 Прикрепление", 4)
    createTab("⚙️ Настройки", 5)

    -- Активируем первую
    tabs[1].BackgroundColor3 = tabActive
    contents[1].Visible = true

    print("✅ Вкладки успешно созданы!")
    return tabsData
end

return module