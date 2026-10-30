local module = {}
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isNoclipActive = false
local noclipConnection = nil

-- Переменные для бинда
local currentBind = Enum.KeyCode.N -- Кнопка по умолчанию
local isWaitingForBind = false

function module.Start(uiParent)
    if not uiParent then return end

    -- 1. Кнопка ВКЛ/ВЫКЛ
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 40)
    toggleBtn.Position = UDim2.new(0, 5, 0, 50) -- Сдвинул вниз, чтобы не перекрывать другие кнопки
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    toggleBtn.Text = "👻 ВКЛЮЧИТЬ NOCLIP"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = uiParent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    -- 2. Кнопка смены бинда
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(1, -10, 0, 30)
    bindBtn.Position = UDim2.new(0, 5, 0, 95)
    bindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    bindBtn.Text = "Бинд: " .. currentBind.Name
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.Parent = uiParent
    Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 6)

    -- Функция переключения Noclip
    local function toggleNoclip()
        isNoclipActive = not isNoclipActive
        toggleBtn.Text = isNoclipActive and "👻 ВЫКЛЮЧИТЬ NOCLIP" or "👻 ВКЛЮЧИТЬ NOCLIP"
        toggleBtn.BackgroundColor3 = isNoclipActive and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)

        if isNoclipActive then
            -- Включаем Noclip
            noclipConnection = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Выключаем Noclip
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            -- Возвращаем коллизии
            local char = player.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end
    end

    -- Привязка клика по кнопке
    toggleBtn.MouseButton1Click:Connect(toggleNoclip)

    -- Логика смены бинда
    bindBtn.MouseButton1Click:Connect(function()
        if isWaitingForBind then return end
        isWaitingForBind = true
        bindBtn.Text = "Нажми клавишу..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
    end)

    -- Отслеживание нажатия клавиш
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Если ждем назначения клавиши
        if isWaitingForBind then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentBind = input.KeyCode
                bindBtn.Text = "Бинд: " .. currentBind.Name
                bindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
                isWaitingForBind = false
            end
            return
        end
        
        -- Если нажата забинденная клавиша - переключаем Noclip
        if input.KeyCode == currentBind then
            toggleNoclip()
        end
    end)
end

return module 