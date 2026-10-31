local module = {}
local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local isAutoAttackActive = false
local attackDelay = 0.2 -- Задержка между ударами (по умолчанию)

-- СПИСКИ (как в Ауре)
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

-- Поиск Торса врага в радиусе 15 метров
local function getClosestEnemyTorso()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    
    local closest = nil
    local minDist = 15
    
    local partsInRadius = workspace:GetPartBoundsInRadius(myPos, minDist)
    
    for _, obj in ipairs(partsInRadius) do
        if obj.Name == "Torso" and obj.Parent:IsA("Model") then
            local parentModel = obj.Parent
            local humanoid = parentModel:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and parentModel ~= char and isEnemy(parentModel) and not isIgnored(parentModel) then
                local dist = (obj.Position - myPos).Magnitude
                if dist < minDist then
                    closest = obj
                    minDist = dist
                end
            end
        end
    end
    return closest
end

-- МУЛЬТИ-КЛИК (3 быстрых клика подряд)
local function multiClick()
    if VirtualInputManager then
        for i = 1, 3 do
            -- Эмуляция нажатия (как на ПК, так и на телефоне)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            task.wait(0.01)
        end
    end
end

-- Нажатие клавиши (для слота 2)
local function pressKey(key)
    if VirtualInputManager then
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
end

function module.Start(uiParent)
    if not uiParent then return end

    -- 1. Кнопка ВКЛ/ВЫКЛ
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 40)
    toggleBtn.LayoutOrder = 8
    toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
    toggleBtn.Text = "⚔️ АВТО-АТАКА [ВЫКЛ]"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = uiParent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    -- 2. Ползунок скорости (задержки)
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, -10, 0, 25)
    speedFrame.LayoutOrder = 9
    speedFrame.BackgroundTransparency = 1
    speedFrame.Parent = uiParent

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 15)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Скорость ударов: " .. attackDelay
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 12
    speedLabel.Parent = speedFrame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 17)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.Parent = speedFrame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)

    local isDragging = false
    local function updateSlider(percent)
        percent = math.clamp(percent, 0, 1)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        attackDelay = 0.05 + (percent * 0.45) -- От 0.05 до 0.5 сек
        speedLabel.Text = string.format("Скорость ударов: %.2f", attackDelay)
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

    -- Логика Авто-Атаки
    local function toggleAutoAttack()
        isAutoAttackActive = not isAutoAttackActive
        toggleBtn.Text = isAutoAttackActive and "⚔️ АВТО-АТАКА [ВКЛ]" or "⚔️ АВТО-АТАКА [ВЫКЛ]"
        toggleBtn.BackgroundColor3 = isAutoAttackActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(150, 50, 150)

        if isAutoAttackActive then
            print("⚔️ Авто-атака ВКЛЮЧЕНА (Мульти-Клик)")
            task.spawn(function()
                while isAutoAttackActive do
                    task.wait(attackDelay)
                    
                    local targetTorso = getClosestEnemyTorso()
                    
                    if targetTorso then
                        -- Жмем "2" (достаем меч)
                        pressKey(Enum.KeyCode.Two)
                        task.wait(0.05)
                        
                        -- Бьем мульти-кликом (3 клика подряд)
                        multiClick()
                    end
                end
            end)
        else
            print("⚔️ Авто-атака ВЫКЛЮЧЕНА")
        end
    end

    toggleBtn.MouseButton1Click:Connect(toggleAutoAttack)
end

return module