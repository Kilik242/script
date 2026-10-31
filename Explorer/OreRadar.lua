local module = {}

function module.Start(uiParent)
    if not uiParent then return end

    local player = game.Players.LocalPlayer

    -- Настройки цветов (как в твоем скрипте)
    local ColorSettings = {
        { Name = "Уголь",     Color = Color3.fromRGB(0, 50, 120),   Tolerance = 70 },
        { Name = "Железо",    Color = Color3.fromRGB(200, 120, 50), Tolerance = 70 },
        { Name = "Золото",    Color = Color3.fromRGB(255, 200, 0),  Tolerance = 70 },
        { Name = "Бриллиант", Color = Color3.fromRGB(0, 255, 255),  Tolerance = 70 },
        { Name = "Изумруд",   Color = Color3.fromRGB(50, 255, 50),  Tolerance = 70 },
        { Name = "Рубин",     Color = Color3.fromRGB(255, 50, 50),  Tolerance = 70 },
    }

    local NameSettings = {
        { Keyword = "coal",     Name = "Уголь" },
        { Keyword = "iron",     Name = "Железо" },
        { Keyword = "gold",     Name = "Золото" },
        { Keyword = "diamond",  Name = "Бриллиант" },
        { Keyword = "emerald",  Name = "Изумруд" },
        { Keyword = "ruby",     Name = "Рубин" },
        { Keyword = "ore",      Name = "Руда" },
    }

    local SCAN_RADIUS = 1000
    local UPDATE_RATE = 2

    -- Создаем скролл внутри переданной вкладки
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = uiParent

    -- Кнопка обновления (чтобы не ждать авто-обновления)
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 40)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 40)
    refreshBtn.Text = "🔄 Обновить Руды"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.Parent = scroll

    local activeButtons = {}

    -- Функция определения цвета
    local function getOreNameByColor(part)
        if not part:IsA("BasePart") then return nil end
        local r, g, b = math.floor(part.Color.R * 255), math.floor(part.Color.G * 255), math.floor(part.Color.B * 255)
        for _, setting in ipairs(ColorSettings) do
            if math.abs(r - setting.Color.R * 255) <= setting.Tolerance and
               math.abs(g - setting.Color.G * 255) <= setting.Tolerance and
               math.abs(b - setting.Color.B * 255) <= setting.Tolerance then
                return setting.Name
            end
        end
        return nil
    end

    local function getOreNameByString(str)
        local lowerStr = str:lower()
        for _, setting in ipairs(NameSettings) do
            if lowerStr:find(setting.Keyword) then return setting.Name end
        end
        return nil
    end

    local function analyzeRock(rock)
        local name = getOreNameByColor(rock)
        if name then return name end
        if rock:IsA("Model") or #rock:GetChildren() > 0 then
            for _, child in ipairs(rock:GetDescendants()) do
                local childName = getOreNameByColor(child)
                if childName then return childName end
                local stringName = getOreNameByString(child.Name)
                if stringName then return stringName end
            end
        end
        return "Руда"
    end

    local function updateResourceList()
        -- Очищаем старые кнопки
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") and child ~= refreshBtn then child:Destroy() end
        end

        local myChar = player.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myPos = myChar.HumanoidRootPart.Position

        local parts = workspace:GetPartBoundsInRadius(myPos, SCAN_RADIUS)
        local foundOres = {}

        for _, obj in ipairs(parts) do
            if obj.Name == "Rock" or (obj.Parent and obj.Parent.Name == "Rock") then
                local rootRock = obj.Parent and obj.Parent.Name == "Rock" and obj.Parent or obj
                
                if not foundOres[rootRock] then
                    local oreName = analyzeRock(rootRock)
                    local dist = (rootRock:GetPivot().Position - myPos).Magnitude
                    foundOres[rootRock] = { name = oreName, distance = dist }
                end
            end
        end

        -- Сортируем по дистанции
        local sorted = {}
        for res, data in pairs(foundOres) do table.insert(sorted, {res = res, data = data}) end
        table.sort(sorted, function(a, b) return a.data.distance < b.data.distance end)

        -- Создаем кнопки
        for i, item in ipairs(sorted) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.Position = UDim2.new(0, 0, 0, 45 + (i - 1) * 40)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            btn.Text = item.data.name .. " (" .. math.floor(item.data.distance) .. "м)"
            
            -- Красим текст в цвет руды
            for _, setting in ipairs(ColorSettings) do
                if setting.Name == item.data.name then
                    btn.TextColor3 = setting.Color
                    break
                end
            end
            
            btn.Font = Enum.Font.GothamBold
            btn.Parent = scroll
            
            btn.MouseButton1Click:Connect(function()
                if item.res and item.res.Parent then
                    myChar.HumanoidRootPart.CFrame = CFrame.new(item.res:GetPivot().Position + Vector3.new(0, 5, 0))
                end
            end)
        end
    end

    refreshBtn.MouseButton1Click:Connect(updateResourceList)
    updateResourceList()
end

return module