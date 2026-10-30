local module = {}

function module.Start(uiParent)
    if not uiParent then return end

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
    refreshBtn.Text = "🔄 Обновить Камни/Руду"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.Parent = scroll

    -- СПИСОК ИМЕН ДЛЯ КАМНЕЙ (Rock - самый важный)
    local ORE_NAMES = {"rock", "ore", "stone", "coal", "metal"}

    local function updateOres()
        -- Очищаем старые кнопки
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") and child ~= refreshBtn then child:Destroy() end
        end

        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local myPos = char.HumanoidRootPart.Position
        
        local found = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            -- Ищем любую деталь (BasePart), а не только модели
            if obj:IsA("BasePart") then
                local nameLower = obj.Name:lower()
                for _, oreName in ipairs(ORE_NAMES) do
                    if nameLower:find(oreName) then
                        found = found + 1
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, 0, 0, 35)
                        btn.Position = UDim2.new(0, 0, 0, 45 + (found - 1) * 40)
                        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                        btn.Text = obj.Name .. " (" .. dist .. "м)"
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        btn.Font = Enum.Font.GothamBold
                        btn.Parent = scroll
                        
                        btn.MouseButton1Click:Connect(function()
                            char.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 5, 0))
                        end)
                        break
                    end
                end
            end
        end
        print("⛏️ Найдено камней: " .. found)
    end

    refreshBtn.MouseButton1Click:Connect(updateOres)
    updateOres()
end

return module