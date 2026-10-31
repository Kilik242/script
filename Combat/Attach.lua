local module = {}
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- ===== НАСТРОЙКИ =====
local STEP = 5
local MAX_HEIGHT = 200
local MIN_HEIGHT = -200
-- =====================

-- ===== СОСТОЯНИЕ =====
local targetPart = nil
local currentHeight = 0
local selecting = false
local bodyPos = nil
local alignOrient = nil

local function getHRP()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function detach()
    local hrp = getHRP()
    if hrp then
        local w = hrp:FindFirstChild("AttachWeld")
        if w then w:Destroy() end
        local bp = hrp:FindFirstChild("HeightBodyPosition")
        if bp then bp:Destroy() end
        local ao = hrp:FindFirstChild("HeightAlignOrient")
        if ao then ao:Destroy() end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.Sit = false
        end
    end
    bodyPos = nil
    alignOrient = nil
    targetPart = nil
    currentHeight = 0
end

function module.Start(uiParent)
    if not uiParent then return end

    -- Кнопка Выбора
    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, -10, 0, 40)
    selectBtn.LayoutOrder = 1
    selectBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
    selectBtn.Text = "🎯 Выбрать деталь"
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
    statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = uiParent

    -- Высота (текст)
    local heightLabel = Instance.new("TextLabel")
    heightLabel.Size = UDim2.new(1, -10, 0, 28)
    heightLabel.LayoutOrder = 3
    heightLabel.BackgroundTransparency = 1
    heightLabel.Text = "Высота: 0"
    heightLabel.TextColor3 = Color3.fromRGB(120, 220, 255)
    heightLabel.Font = Enum.Font.GothamBold
    heightLabel.TextSize = 17
    heightLabel.TextXAlignment = Enum.TextXAlignment.Left
    heightLabel.Parent = uiParent

    -- Кнопки высоты
    local btnUp = Instance.new("TextButton")
    btnUp.Size = UDim2.new(0.32, -5, 0, 30)
    btnUp.LayoutOrder = 4
    btnUp.BackgroundColor3 = Color3.fromRGB(46, 160, 67)
    btnUp.Text = "▲ Вверх"
    btnUp.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnUp.Font = Enum.Font.GothamBold
    btnUp.Parent = uiParent
    Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 6)

    local btnDown = Instance.new("TextButton")
    btnDown.Size = UDim2.new(0.32, -5, 0, 30)
    btnDown.LayoutOrder = 5
    btnDown.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    btnDown.Text = "▼ Вниз"
    btnDown.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnDown.Font = Enum.Font.GothamBold
    btnDown.Parent = uiParent
    Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 6)

    local btnReset = Instance.new("TextButton")
    btnReset.Size = UDim2.new(0.32, -5, 0, 30)
    btnReset.LayoutOrder = 6
    btnReset.BackgroundColor3 = Color3.fromRGB(200, 160, 40)
    btnReset.Text = "⟲"
    btnReset.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnReset.Font = Enum.Font.GothamBold
    btnReset.Parent = uiParent
    Instance.new("UICorner", btnReset).CornerRadius = UDim.new(0, 6)

    -- Кнопка Отключить
    local detachBtn = Instance.new("TextButton")
    detachBtn.Size = UDim2.new(1, -10, 0, 30)
    detachBtn.LayoutOrder = 7
    detachBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
    detachBtn.Text = "⏻ Отключить"
    detachBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    detachBtn.Font = Enum.Font.GothamBold
    detachBtn.Parent = uiParent
    Instance.new("UICorner", detachBtn).CornerRadius = UDim.new(0, 6)

    -- Функция обновления текста высоты
    local function updateHeightLabel()
        heightLabel.Text = string.format("Высота: %.1f", currentHeight)
        heightLabel.TextColor3 = currentHeight < 0 and Color3.fromRGB(255, 160, 100) or Color3.fromRGB(120, 220, 255)
    end

    -- Функция прикрепления
    local function attachTo(part)
        if not part or not part:IsA("BasePart") then return end
        detach()

        local char = player.Character
        if not char then return end

        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

        targetPart = part
        currentHeight = 0

        hum.PlatformStand = true
        hrp.Anchored = false

        -- Создаем Weld (чтобы жестко зафиксировать по X и Z)
        local weld = Instance.new("Weld")
        weld.Name = "AttachWeld"
        weld.Part0 = hrp
        weld.Part1 = part
        weld.C0 = CFrame.new(0, 5, 0) -- Смещение вверх
        weld.Parent = hrp

        -- BodyPosition для управления высотой (только по Y)
        bodyPos = Instance.new("BodyPosition")
        bodyPos.Name = "HeightBodyPosition"
        bodyPos.MaxForce = Vector3.new(0, 100000, 0) -- ТОЛЬКО Y
        bodyPos.P = 15000
        bodyPos.D = 1500
        bodyPos.Parent = hrp

        -- AlignOrientation для поворота
        alignOrient = Instance.new("AlignOrientation")
        alignOrient.Name = "HeightAlignOrient"
        alignOrient.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignOrient.MaxTorque = 50000
        alignOrient.Responsiveness = 50
        alignOrient.Parent = hrp

        local attach0 = Instance.new("Attachment")
        attach0.Name = "AlignOrientAttach"
        attach0.Parent = hrp
        alignOrient.Attachment0 = attach0

        statusLabel.Text = "Прикреплён: " .. part.Name
        statusLabel.TextColor3 = Color3.fromRGB(120, 255, 150)
        updateHeightLabel()
    end

    -- Кнопки
    selectBtn.MouseButton1Click:Connect(function()
        selecting = true
        statusLabel.Text = "Кликни по детали в мире..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
    end)

    btnUp.MouseButton1Click:Connect(function()
        if not targetPart then return end
        currentHeight = math.clamp(currentHeight + STEP, MIN_HEIGHT, MAX_HEIGHT)
        updateHeightLabel()
    end)

    btnDown.MouseButton1Click:Connect(function()
        if not targetPart then return end
        currentHeight = math.clamp(currentHeight - STEP, MIN_HEIGHT, MAX_HEIGHT)
        updateHeightLabel()
    end)

    btnReset.MouseButton1Click:Connect(function()
        if not targetPart then return end
        currentHeight = 0
        updateHeightLabel()
    end)

    detachBtn.MouseButton1Click:Connect(detach)

    -- Клик по миру для выбора
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not selecting then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        local pos = input.Position
        local ray = camera:ViewportPointToRay(pos.X, pos.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { player.Character }

        local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
        if result and result.Instance and result.Instance:IsA("BasePart") then
            attachTo(result.Instance)
            selecting = false
        else
            statusLabel.Text = "Мимо, попробуй ещё раз"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
        end
    end)

    -- Слежение за деталью (обновляет высоту)
    RunService.Heartbeat:Connect(function()
        if not targetPart or not bodyPos or not bodyPos.Parent then return end
        local hrp = getHRP()
        if not hrp then return end

        -- Работает и для отрицательных значений
        local targetPos = Vector3.new(
            targetPart.Position.X,
            targetPart.Position.Y + currentHeight + 5,
            targetPart.Position.Z
        )
        bodyPos.Position = targetPos

        if alignOrient and alignOrient.Attachment0 then
            alignOrient.CFrame = targetPart.CFrame
        end
    end)

    -- Респавн
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if targetPart then
            local saved = targetPart
            detach()
            attachTo(saved)
        end
    end)

    updateHeightLabel()
end

return module