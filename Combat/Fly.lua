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
    toggleBtn.LayoutOrder = 2
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    toggleBtn.Text = "🕊️ ВКЛЮЧИТЬ ПОЛЕТ"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = uiParent
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

    -- Ползунок скорости
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, -10, 0, 25)
    speedFrame.LayoutOrder = 3
    speedFrame.BackgroundTransparency = 1
    speedFrame.Parent = uiParent

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 15)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Скорость: " .. flySpeed
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
        flySpeed = 10 + (percent * 190) -- От 10 до 200
        speedLabel.Text = "Скорость: " .. math.floor(flySpeed)
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
            if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        end
    end

    toggleBtn.MouseButton1Click:Connect(toggleFly)

    RunService.RenderStepped:Connect(function()
        if isFlying then
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local cam = workspace.CurrentCamera
            
            if hrp and bodyVelocity and bodyGyro then
                bodyGyro.CFrame = cam.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                bodyVelocity.Velocity = moveDir * flySpeed
            end
        end
    end)
end

return module