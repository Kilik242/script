local module = {}

function module.Start(uiParent)
    if not uiParent then return end
    local player = game.Players.LocalPlayer

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

    local activeButtons = {}
    local SCAN_RADIUS = 500

    local function updateOres()
        local myChar = player.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myPos = myChar.HumanoidRootPart.Position

        local parts = workspace:GetPartBoundsInRadius(myPos, SCAN_RADIUS)
        local foundOres = {}

        for _, obj in ipairs(parts) do
            if obj:IsA("BasePart") then
                local nameLower = obj.Name:lower()
                -- Ищем только маленькие камни (чтобы не брать стены)
                local size = obj.Size
                local maxSize = math.max(size.X, size.Y, size.Z)
                
                if maxSize < 15 then
                    if nameLower == "rock" or nameLower:find("ore") or nameLower:find("stone") then
                        local dist = (obj.Position - myPos).Magnitude
                        foundOres[obj] = dist
                    end
                end
            end
        end

        -- Удаляем сломанные
        for ore, btn in pairs(activeButtons) do
            if not foundOres[ore] or not ore.Parent then
                btn:Destroy()
                activeButtons[ore] = nil
            end
        end

        -- Добавляем новые
        local count = 0
        for ore, dist in pairs(foundOres) do
            count = count + 1
            if not activeButtons[ore] then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 35)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.Parent = scroll
                
                btn.MouseButton1Click:Connect(function()
                    if ore and ore.Parent then
                        myChar.HumanoidRootPart.CFrame = CFrame.new(ore.Position + Vector3.new(0, 5, 0))
                    end
                end)
                activeButtons[ore] = btn
            end
            
            local btn = activeButtons[ore]
            btn.Text = ore.Name .. " (" .. math.floor(dist) .. "м)"
            btn.LayoutOrder = math.floor(dist)
        end
        print("⛏️ Найдено руд: " .. count)
    end

    refreshBtn.MouseButton1Click:Connect(updateOres)
    updateOres()
end

return module