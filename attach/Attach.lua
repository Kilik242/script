local module = {}
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local targetPart = nil
local currentHeight = 0
local bodyPos, alignOrient = nil, nil
local selecting = false

local function detach()
    if bodyPos then bodyPos:Destroy(); bodyPos = nil end
    if alignOrient then alignOrient:Destroy(); alignOrient = nil end
    targetPart = nil
    currentHeight = 0
end

function module.Start(uiParent)
    if not uiParent then return end

    -- Кнопка выбора
    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, -10, 0, 40)
    selectBtn.LayoutOrder = 1
    selectBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
    selectBtn.Text = "🧲 Выбрать деталь (Кликни)"
    selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectBtn.Font = Enum.Font.GothamBold
    selectBtn.Parent = uiParent
    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 6)

    -- Статус
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 0, 20)
    statusLabel.LayoutOrder = 2
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Деталь не выбрана"
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Parent = uiParent

    -- Кнопки высоты
    local btnUp = Instance.new("TextButton")
    btnUp.Size = UDim2.new(0.48, -5, 0, 30)
    btnUp.LayoutOrder = 3
    btnUp.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
    btnUp.Text = "▲ Вверх"
    btnUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnUp.Font = Enum.Font.GothamBold
    btnUp.Parent = uiParent
    Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 6)

    local btnDown = Instance.new("TextButton")
    btnDown.Size = UDim2.new(0.48, -5, 0, 30)
    btnDown.LayoutOrder = 4
    btnDown.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    btnDown.Text = "▼ Вниз"
    btnDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnDown.Font = Enum.Font.GothamBold
    btnDown.Parent = uiParent
    Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 6)

    -- Кнопка отключения
    local detachBtn = Instance.new("TextButton")
    detachBtn.Size = UDim2.new(1, -10, 0, 30)
    detachBtn.LayoutOrder = 5
    detachBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
    detachBtn.Text = "⏻ Отключить"
    detachBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    detachBtn.Font = Enum.Font.GothamBold
    detachBtn.Parent = uiParent
    Instance.new("UICorner", detachBtn).CornerRadius = UDim.new(0, 6)

    -- Логика выбора
    selectBtn.MouseButton1Click:Connect(function()
        selecting = true
        statusLabel.Text = "Кликни по детали..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not selecting then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        
        local ray = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {player.Character}
        local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)

        if result and result.Instance then
            detach()
            targetPart = result.Instance
            statusLabel.Text = "Прикреплён: " .. targetPart.Name
            statusLabel.TextColor3 = Color3.fromRGB(120, 255, 150)
            
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                bodyPos = Instance.new("BodyPosition")
                bodyPos.MaxForce = Vector3.new(0, 100000, 0)
                bodyPos.P = 15000; bodyPos.D = 1500
                bodyPos.Parent = hrp
                
                alignOrient = Instance.new("AlignOrientation")
                alignOrient.MaxTorque = 50000
                alignOrient.Parent = hrp
            end
        end
        selecting = false
    end)

    -- Кнопки высоты
    btnUp.MouseButton1Click:Connect(function()
        if targetPart then currentHeight = currentHeight + 5 end
    end)
    btnDown.MouseButton1Click:Connect(function()
        if targetPart then currentHeight = currentHeight - 5 end
    end)
    detachBtn.MouseButton1Click:Connect(detach)

    -- Слежение
    RunService.Heartbeat:Connect(function()
        if targetPart and bodyPos then
            bodyPos.Position = Vector3.new(targetPart.Position.X, targetPart.Position.Y + currentHeight + 5, targetPart.Position.Z)
        end
    end)
end

return module