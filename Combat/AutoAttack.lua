local module = {}
local player = game.Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local isAutoAttackActive = false

-- СПИСКИ (как в Ауре, чтобы не бить торговцев)
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

-- Поиск ближайшего врага (ищем по Торсу или Голове)
local function getClosestEnemy()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    
    local closest = nil
    local minDist = 15 -- Радиус удара (15 метров)
    
    local partsInRadius = workspace:GetPartBoundsInRadius(myPos, minDist)
    
    for _, obj in ipairs(partsInRadius) do
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and obj ~= char and isEnemy(obj) and not isIgnored(obj) then
                -- Ищем Торс или Голову
                local targetPart = obj:FindFirstChild("Torso") 
                                 or obj:FindFirstChild("Head") 
                                 or obj:FindFirstChild("HumanoidRootPart")
                
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

-- Клик мышкой (без изменения камеры)
local function clickMouse()
    if VirtualInputManager then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

function module.Start(uiParent)
    if not uiParent then return end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 40)
    toggleBtn.LayoutOrder = 8
    toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
    toggleBtn.Text = "⚔️ АВТО-АТАКА [ВЫКЛ]"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = uiParent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    local function toggleAutoAttack()
        isAutoAttackActive = not isAutoAttackActive
        toggleBtn.Text = isAutoAttackActive and "⚔️ АВТО-АТАКА [ВКЛ]" or "⚔️ АВТО-АТАКА [ВЫКЛ]"
        toggleBtn.BackgroundColor3 = isAutoAttackActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(150, 50, 150)

        if isAutoAttackActive then
            print("⚔️ Авто-атака ВКЛЮЧЕНА (радиус 15)")
            task.spawn(function()
                while isAutoAttackActive do
                    task.wait(0.15)
                    
                    local char = player.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    
                    local target = getClosestEnemy()
                    
                    if target and hum then
                        -- 1. Берем меч в руки
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if not tool then
                            local backpack = player:FindFirstChild("Backpack")
                            if backpack then
                                tool = backpack:FindFirstChildWhichIsA("Tool")
                            end
                        end
                        
                        if tool and tool.Parent ~= char then
                            hum:EquipTool(tool)
                            task.wait(0.1) -- Даем время надеть
                        end
                        
                        -- 2. Бьем (кликаем)
                        clickMouse()
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