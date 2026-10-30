local module = {}
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local isFlying = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil

function module.Start(uiParent)
    if not uiParent then return end

    -- Кнопка ВКЛ/ВЫКЛ
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -10, 0, 40)
    toggleBtn.Position = UDim2.new(0, 5, 0, 5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    toggleBtn.Text = "🕊️ ВКЛЮЧИТЬ ПОЛЕТ"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = uiParent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    -- Ползунок скорости
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -10, 0, 20)
    speedLabel.Position = UDim2.new(0, 5, 0, 55)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Скорость: " .. flySpeed
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 14
    speedLabel.Parent = uiParent

    -- Логика полета
    local function toggleFly()
        isFlying = not isFlying
        toggleBtn.Text = isFlying and "🕊️ ВЫКЛЮЧИТЬ ПОЛЕТ" or "🕊️ ВКЛЮЧИТЬ ПОЛЕТ"
        toggleBtn.BackgroundColor3 = isFlying and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 50, 150)

        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if isFlying then
            if hrp then
                -- Создаем физику для полета
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.Parent = hrp

                bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bodyGyro.P = 1000
                bodyGyro.D = 50
                bodyGyro.Parent = hrp
            end
        else
            -- Удаляем физику
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            bodyVelocity = nil
            bodyGyro = nil
        end
    end

    toggleBtn.MouseButton1Click:Connect(toggleFly)

    -- Цикл полета
    RunService.RenderStepped:Connect(function()
        if isFlying then
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local cam = workspace.CurrentCamera
            
            if hrp and bodyVelocity and bodyGyro then
                bodyGyro.CFrame = cam.CFrame
                
                local moveDir = Vector3.new(0, 0, 0)
                local speed = flySpeed
                
                -- WASD
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                -- Space/Ctrl (вверх/вниз)
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                bodyVelocity.Velocity = moveDir * speed
            end
        end
    end)
end

return module