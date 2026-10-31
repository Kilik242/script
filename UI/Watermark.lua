local module = {}
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

function module.Create(mainFrame)
    if not mainFrame then return end
    
    -- Создаем сам Водяной знак
    local watermark = Instance.new("TextButton")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 180, 0, 40)
    watermark.Position = UDim2.new(0, 20, 0, 20)
    watermark.BackgroundColor3 = Color3.fromRGB(15, 35, 15)
    watermark.BackgroundTransparency = 0.3
    watermark.BorderSizePixel = 0
    watermark.Text = "🔥 Kukish_REP | v3.1"
    watermark.TextColor3 = Color3.fromRGB(0, 255, 100) -- Неоновый зеленый
    watermark.Font = Enum.Font.GothamBold
    watermark.TextSize = 16
    watermark.Parent = playerGui:FindFirstChild("KukishREP") or playerGui
    
    -- Скругление и обводка
    Instance.new("UICorner", watermark).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 100)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = watermark
    
    -- Логика открытия меню при клике
    watermark.MouseButton1Click:Connect(function()
        if mainFrame then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    -- Мигание (чтобы привлекало внимание)
    task.spawn(function()
        while watermark.Parent do
            for i = 1, 0.3, -0.1 do
                watermark.TextTransparency = i
                task.wait(0.05)
            end
            for i = 0.3, 1, 0.1 do
                watermark.TextTransparency = i
                task.wait(0.05)
            end
        end
    end)
    
    print("✅ Водяной знак создан!")
end

return module