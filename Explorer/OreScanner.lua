local module = {}

function module.Start(uiParent)
    if not uiParent then return end

    local ColorSettings = {
        { Name = "Уголь",     Color = Color3.fromRGB(0, 50, 120),   Tolerance = 70 },
        { Name = "Железо",    Color = Color3.fromRGB(200, 120, 50), Tolerance = 70 },
        { Name = "Золото",    Color = Color3.fromRGB(255, 200, 0),  Tolerance = 70 },
        { Name = "Бриллиант", Color = Color3.fromRGB(0, 255, 255),  Tolerance = 70 },
        { Name = "Изумруд",   Color = Color3.fromRGB(50, 255, 50),  Tolerance = 70 },
        { Name = "Рубин",     Color = Color3.fromRGB(255, 50, 50),  Tolerance = 70 },
    }

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = uiParent

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 40)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 40)
    refreshBtn.Text = "🔄 Обновить Радар Руд"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.Parent = scroll

    -- Функция определения цвета
    local function getOreNameByColor(part)
        if not part:IsA("BasePart") then return nil end
        local r, g, b = part.Color.R * 255, part.Color.G * 255, part.Color.B * 255
        for _, setting in ipairs(ColorSettings) do
            if math.abs(r - setting.Color.R * 255) <= setting.Tolerance and
               math.abs(g - setting.Color.G * 255) <= setting.Tolerance and
               math.abs(b - setting.Color.B * 255) <= setting.Tolerance then
                return setting.Name
            end
        end
        return nil
    end

    local function updateOres()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") and child ~= refreshBtn then child:Destroy() end
        end

        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        
        local found = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Rock" or (obj.Parent and obj.Parent.Name == "Rock") then
                local rootRock = obj.Parent and obj.Parent.Name == "Rock" and obj.Parent or obj
                
                -- Ищем цветные вставки внутри
                local oreName = nil
                for _, child in ipairs(rootRock:GetDescendants()) do
                    oreName = getOreNameByColor(child)
                    if oreName then break end
                end
                
                if oreName then
                    found = found + 1
                    local dist = math.floor((rootRock:GetPivot().Position - myPos).Magnitude)
                    
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 35)
                    btn.Position = UDim2.new(0, 0, 0, 45 + (found - 1) * 40)
                    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    btn.Text = oreName .. " (" .. dist .. "м)"
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Font = Enum.Font.GothamBold
                    btn.Parent = scroll
                    
                    btn.MouseButton1Click:Connect(function()
                        char.HumanoidRootPart.CFrame = CFrame.new(rootRock:GetPivot().Position + Vector3.new(0, 5, 0))
                    end)
                end
            end
        end
        print("⛏️ Найдено руд: " .. found)
    end

    refreshBtn.MouseButton1Click:Connect(updateOres)
    updateOres()
end

return module