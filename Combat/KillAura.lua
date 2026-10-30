local module = {}
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local isAuraActive = false
local currentDepth = 3
local currentBind = Enum.KeyCode.Z
local isWaitingForBind = false

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
    local minDist = 5000
    
    for _, obj in ipairs(workspace:GetDescendants()) do
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
    
    -- Создаем кнопку включения
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 40)
    toggleBtn.Position = UDim2.new(0, 5, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    toggleBtn.Text = "⚔️ ВКЛЮЧИТЬ АУРУ (Z)"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = uiParent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    -- Кнопка смены бинда
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(1, -10, 0, 30)
    bindBtn.Position = UDim2.new(0, 5, 0, 55)
    bindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    bindBtn.Text = "Бинд: " .. currentBind.Name
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.Parent = uiParent
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

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

    -- Цикл ауры
    task.spawn(function()
        local originalY = nil
        local currentTarget = nil
        local lastTargetPos = nil
        
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
                    lastTargetPos = nil
                end
                
                if currentTarget then
                    if not originalY then originalY = hrp.Position.Y end
                    local currentTargetPos = currentTarget.Position
                    local movedDist = 0
                    if lastTargetPos then movedDist = (currentTargetPos - lastTargetPos).Magnitude end
                    
                    if not lastTargetPos or movedDist > 5 then
                        hrp.Anchored = true
                        hrp.CFrame = CFrame.new(currentTargetPos.X, currentTargetPos.Y - currentDepth, currentTargetPos.Z)
                        lastTargetPos = currentTargetPos
                        task.delay(0.2, function()
                            if hrp and hrp.Parent then hrp.Anchored = false end
                        end)
                    end
                    if not hrp.Anchored then hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
                else
                    if hrp.Anchored then hrp.Anchored = false end
                    if originalY and hrp.Position.Y < originalY - 1 then
                        hrp.CFrame = CFrame.new(hrp.Position.X, originalY, hrp.Position.Z)
                    end
                    originalY = nil
                end
            else
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