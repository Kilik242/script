local module = {}
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local isAuraActive = false
local currentDepth = 3
local currentBind = Enum.KeyCode.Z
local isWaitingForBind = false

-- СПИСКИ
local IGNORE_NAMES = {
    "poppy", "benji", "simon", "zack", "zacks", "trader", "shop", "merchant", 
    "seller", "guard", "npc", "postmaster", "banker", "repairing", 
    "companion", "statue", "dummy", "armor_stand", "mannequin",
    "mimic", "deathchest", "chest", "ozy", "gibbles", "fake"
}

local ENEMY_NAMES = {
    "goblin", "bandit", "miner", "batboss", "spider", "worm", 
    "larry", "vampire", "watcher", "widow", "bat minion",
    "boss", "enemy", "mob"
}

local function isIgnored(obj)
    local nameLower = obj.Name:lower()
    for _, ignore in ipairs(IGNORE_NAMES) do
        if nameLower:find(ignore) then return true end
    end
    return false
end

local function isEnemy(obj)
    local nameLower = obj.Name:lower()
    for _, enemy in ipairs(ENEMY_NAMES) do
        if nameLower:find(enemy) then return true end
    end
    return false
end

local function getClosestEnemy()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    
    local closest = nil
    local minDist = 10000 -- Твой радиус (10к)
    
    -- Ищем детали в радиусе (быстро, на уровне движка, без лагов)
    local partsInRadius = workspace:GetPartBoundsInRadius(myPos, minDist)
    
    for _, obj in ipairs(partsInRadius) do
        -- Проверяем, что это модель с Humanoid (моб)
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and obj ~= char and isEnemy(obj) and not isIgnored(obj) then
                local targetPart = obj:FindFirstChild("Torso") or obj:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local dist = (targetPart.Position - myPos).Magnitude
                    if dist < minDist then
                        closest = targetPart
                        minDist = dist
                    end
                end
            end
        end
    end
    return closest
end

function module.Start(uiParent)
    if not uiParent then return end
    
    -- 1. Кнопка включения (УБРАЛИ POSITION)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 40)
    toggleBtn.LayoutOrder = 1
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    toggleBtn.Text = "⚔️ ВКЛЮЧИТЬ АУРУ (Z)"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = uiParent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    -- 2. Текст глубины (УБРАЛИ POSITION)
    local depthLabel = Instance.new("TextLabel")
    depthLabel.Size = UDim2.new(1, -10, 0, 20)
    depthLabel.LayoutOrder = 2
    depthLabel.BackgroundTransparency = 1
    depthLabel.Text = "Глубина: " .. currentDepth .. "м"
    depthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    depthLabel.Font = Enum.Font.Gotham
    depthLabel.TextSize = 14
    depthLabel.Parent = uiParent

    -- 3. Ползунок глубины (ОБЕРНУЛИ В РАМКУ, УБРАЛИ POSITION)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 15)
    sliderFrame.LayoutOrder = 3
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = uiParent

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 1, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.Parent = sliderFrame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 5)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.1, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 5)

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new(0.1, -10, 0.5, -10)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.Parent = sliderBg
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

    -- 4. Кнопка смены бинда (УБРАЛИ POSITION)
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(1, -10, 0, 30)
    bindBtn.LayoutOrder = 4
    bindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    bindBtn.Text = "Бинд: " .. currentBind.Name
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.Parent = uiParent
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

    -- Логика ползунка
    local isDragging = false
    local function updateSlider(percent)
        percent = math.clamp(percent, 0, 1)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percent, -10, 0.5, -10)
        currentDepth = 1 + (percent * 20) -- От 1 до 20 метров
        depthLabel.Text = "Глубина: " .. math.floor(currentDepth) .. "м"
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local sliderX = sliderBg.AbsolutePosition.X
            local sliderWidth = sliderBg.AbsoluteSize.X
            updateSlider((mouseX - sliderX) / sliderWidth)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end
    end)

    local function toggleAura()
        isAuraActive = not isAuraActive
        toggleBtn.Text = isAuraActive and "⚔️ ВЫКЛЮЧИТЬ АУРУ" or "⚔️ ВКЛЮЧИТЬ АУРУ"
        toggleBtn.BackgroundColor3 = isAuraActive and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
    end

    toggleBtn.MouseButton1Click:Connect(toggleAura)

    -- Логика бинда
    bindBtn.MouseButton1Click:Connect(function()
        if isWaitingForBind then return end
        isWaitingForBind = true
        bindBtn.Text = "Нажми клавишу..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if isWaitingForBind then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentBind = input.KeyCode
                bindBtn.Text = "Бинд: " .. currentBind.Name
                bindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
                isWaitingForBind = false
            end
            return
        end
        if input.KeyCode == currentBind then toggleAura() end
    end)

    -- ЦИКЛ АУРЫ (С ПЛАВНЫМ ПРЕСЛЕДОВАНИЕМ)
    task.spawn(function()
        local originalY = nil
        local currentTarget = nil
        local bodyPos = nil
        
        while true do
            task.wait(0.1)
            if isAuraActive then
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
                local hrp = char.HumanoidRootPart
                
                local targetIsDead = false
                if not currentTarget or not currentTarget.Parent then
                    targetIsDead = true
                else
                    local hum = currentTarget.Parent:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health <= 0 then targetIsDead = true end
                end
                
                if targetIsDead then
                    currentTarget = getClosestEnemy()
                end
                
                if currentTarget then
                    if not originalY then originalY = hrp.Position.Y end
                    
                    if not bodyPos then
                        bodyPos = Instance.new("BodyPosition")
                        bodyPos.MaxForce = Vector3.new(100000, 100000, 100000)
                        bodyPos.P = 15000
                        bodyPos.D = 1500
                        bodyPos.Parent = hrp
                    end
                    
                    local targetPos = Vector3.new(
                        currentTarget.Position.X, 
                        currentTarget.Position.Y - currentDepth, 
                        currentTarget.Position.Z
                    )
                    bodyPos.Position = targetPos
                    hrp.Anchored = false
                else
                    if bodyPos then bodyPos:Destroy(); bodyPos = nil end
                    if originalY and hrp.Position.Y < originalY - 1 then
                        hrp.CFrame = CFrame.new(hrp.Position.X, originalY, hrp.Position.Z)
                    end
                    originalY = nil
                end
            else
                if bodyPos then bodyPos:Destroy(); bodyPos = nil end
                currentTarget = nil
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    if hrp.Anchored then hrp.Anchored = false end
                end
                originalY = nil
            end
        end
    end)
end

return module