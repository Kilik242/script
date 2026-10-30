local module = {}

function module.Start(uiParent)
    if not uiParent then return end

    -- Создаем скролл внутри переданной вкладки
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = uiParent

    -- Кнопка обновления
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, 0, 0, 40)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    refreshBtn.Text = "🔄 Обновить Сундуки"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.Parent = scroll

    -- Функция поиска сундуков
    local function updateChests()
        -- Очищаем старые кнопки
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") and child ~= refreshBtn then child:Destroy() end
        end

        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position

        local found = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local nameLower = obj.Name:lower()
                -- Ищем сундуки по имени
                if nameLower:find("chest") or nameLower:find("crate") then
                    -- Проверка, что сундук еще не открыт (если есть ClickDetector или Prompt)
                    local hasClick = obj:FindFirstChildOfClass("ClickDetector") ~= nil
                    local hasPrompt = obj:FindFirstChildOfClass("ProximityPrompt") ~= nil
                    
                    if hasClick or hasPrompt then
                        found = found + 1
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 35)
                        btn.Position = UDim2.new(0, 0, 0, 45 + (found - 1) * 40)
                        btn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                        btn.Text = obj.Name .. " (" .. dist .. "м)"
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.Font = Enum.Font.GothamBold
                        btn.Parent = scroll
                        
                        btn.MouseButton1Click:Connect(function()
                            char.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                        end)
                    end
                end
            end
        end
        print("📦 Найдено сундуков: " .. found)
    end

    refreshBtn.MouseButton1Click:Connect(updateChests)
    updateChests()
end

return module