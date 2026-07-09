-- RYZEN MM2 ULTIMATE v6 (Максимально рабочий ESP + Aimbot + Иконка)
-- Murder Mystery 2 | ESP через стены + Aimbot + ESP пистолета
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ===== НАСТРОЙКИ =====
local settings = {
    espEnabled = false,
    aimEnabled = false,
    speedEnabled = false,
    gunESP = false,
    speedValue = 50,
    role = "Innocent"
}

-- ===== ОПРЕДЕЛЕНИЕ РОЛИ (МАКСИМАЛЬНО РАБОЧЕЕ) =====
function getPlayerRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    
    -- Проверяем все возможные способы
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local name = child.Name:lower()
            if name:find("knife") or name:find("dagger") then return "Murderer" end
            if name:find("gun") or name:find("pistol") then return "Sheriff" end
        end
        if child:IsA("Accessory") then
            local name = child.Name:lower()
            if name:find("knife") or name:find("murder") then return "Murderer" end
            if name:find("gun") or name:find("sheriff") or name:find("badge") then return "Sheriff" end
        end
    end
    
    if char:FindFirstChild("Murderer") then return "Murderer" end
    if char:FindFirstChild("Sheriff") then return "Sheriff" end
    if char:GetAttribute("Role") == "Murderer" then return "Murderer" end
    if char:GetAttribute("Role") == "Sheriff" then return "Sheriff" end
    
    -- Проверяем через BillboardGui
    if char:FindFirstChild("Head") then
        local head = char.Head
        for _, obj in pairs(head:GetChildren()) do
            if obj:IsA("BillboardGui") and obj.Name == "Role" then
                return obj.Text
            end
        end
    end
    
    return "Innocent"
end

-- ===== ИКОНКА ДЛЯ ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ =====
local icon = Instance.new("ImageButton")
icon.Size = UDim2.new(0, 50, 0, 50)
icon.Position = UDim2.new(0, 10, 0, 10)
icon.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
icon.BackgroundTransparency = 0.2
icon.Image = "rbxassetid://6031090973" -- Звезда
icon.Parent = player.PlayerGui
icon.Visible = true

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(1, 0)
iconCorner.Parent = icon

-- Анимация иконки
local iconTween = game:GetService("TweenService")
icon.MouseEnter:Connect(function()
    local tween = iconTween:Create(icon, TweenInfo.new(0.2), {Size = UDim2.new(0, 55, 0, 55)})
    tween:Play()
end)
icon.MouseLeave:Connect(function()
    local tween = iconTween:Create(icon, TweenInfo.new(0.2), {Size = UDim2.new(0, 50, 0, 50)})
    tween:Play()
end)

-- ===== КРАСИВОЕ МЕНЮ =====
local menuVisible = false
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false
screenGui.Enabled = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 380)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "✦ RYZEN MM2 ✦"
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Роль
local roleLabel = Instance.new("TextLabel")
roleLabel.Size = UDim2.new(1, 0, 0, 25)
roleLabel.Position = UDim2.new(0, 0, 0, 48)
roleLabel.Text = "Роль: Ожидание..."
roleLabel.TextSize = 14
roleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
roleLabel.BackgroundTransparency = 1
roleLabel.Font = Enum.Font.Gotham
roleLabel.Parent = mainFrame

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.9, 0, 0, 2)
divider.Position = UDim2.new(0.05, 0, 0, 78)
divider.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
divider.BackgroundTransparency = 0.5
divider.Parent = mainFrame

-- Функция кнопки
local function createBtn(text, y, icon, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.Text = icon .. " " .. text
    btn.TextSize = 15
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 55)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "✅ " or icon .. " ") .. text
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 0) or (color or Color3.fromRGB(35, 35, 55))
        callback(state)
    end)
    return btn, function() return state end
end

-- Кнопки
local espBtn, getESP = createBtn("ESP (Сквозь стены)", 90, "👁️", nil, function(v) 
    settings.espEnabled = v 
    if v then startESP() else stopESP() end
end)

local aimBtn, getAim = createBtn("Aimbot", 140, "🎯", nil, function(v) 
    settings.aimEnabled = v 
    if v then startAimbot() else stopAimbot() end
end)

local gunEspBtn, getGunEsp = createBtn("ESP Пистолета", 190, "🔫", Color3.fromRGB(0, 80, 150), function(v) 
    settings.gunESP = v 
    if v then startGunESP() else stopGunESP() end
end)

local speedBtn, getSpeed = createBtn("Speed Glitch", 240, "⚡", nil, function(v) 
    settings.speedEnabled = v 
    if v then startSpeed() else stopSpeed() end
end)

-- Регулировка скорости
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(0, 280, 0, 30)
speedFrame.Position = UDim2.new(0, 20, 0, 285)
speedFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = mainFrame
local sfCorner = Instance.new("UICorner")
sfCorner.CornerRadius = UDim.new(0, 8)
sfCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 120, 0, 30)
speedLabel.Position = UDim2.new(0, 10, 0, 0)
speedLabel.Text = "⚡ " .. settings.speedValue
speedLabel.TextSize = 14
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = speedFrame

local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0, 50, 0, 26)
speedUp.Position = UDim2.new(0, 190, 0, 2)
speedUp.Text = "+"
speedUp.TextSize = 18
speedUp.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUp.BorderSizePixel = 0
speedUp.Parent = speedFrame
local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 6)
upCorner.Parent = speedUp
speedUp.MouseButton1Click:Connect(function()
    settings.speedValue = math.min(settings.speedValue + 10, 200)
    speedLabel.Text = "⚡ " .. settings.speedValue
end)

local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0, 50, 0, 26)
speedDown.Position = UDim2.new(0, 245, 0, 2)
speedDown.Text = "-"
speedDown.TextSize = 18
speedDown.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDown.BorderSizePixel = 0
speedDown.Parent = speedFrame
local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 6)
downCorner.Parent = speedDown
speedDown.MouseButton1Click:Connect(function()
    settings.speedValue = math.max(settings.speedValue - 10, 10)
    speedLabel.Text = "⚡ " .. settings.speedValue
end)

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.Text = "✕"
closeBtn.TextSize = 18
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    menuVisible = false
end)

-- ===== ОТКРЫТИЕ МЕНЮ ПО ИКОНКЕ =====
icon.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    screenGui.Enabled = menuVisible
end)

-- ===== ОБНОВЛЕНИЕ РОЛИ =====
function updateRole()
    local role = getPlayerRole(player)
    settings.role = role
    roleLabel.Text = "Роль: " .. role
    roleLabel.TextColor3 = role == "Murderer" and Color3.fromRGB(255, 0, 0) or 
                           role == "Sheriff" and Color3.fromRGB(0, 100, 255) or 
                           Color3.fromRGB(0, 255, 0)
end

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    wait(1)
    updateRole()
end)

-- ===== ESP (МАКСИМАЛЬНО РАБОЧИЙ) =====
local espObjects = {}
local espConnections = {}

function startESP()
    local function addESP(plr)
        if plr == player then return end
        if not plr.Character then return end
        
        -- Удаляем старый ESP
        for i, obj in pairs(espObjects) do
            if obj and obj.Adornee == plr.Character then
                obj:Destroy()
                table.remove(espObjects, i)
            end
        end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = plr.Character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.25
        highlight.OutlineTransparency = 0.1
        
        local role = getPlayerRole(plr)
        if role == "Murderer" then
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 80, 80)
        elseif role == "Sheriff" then
            highlight.FillColor = Color3.fromRGB(0, 120, 255)
            highlight.OutlineColor = Color3.fromRGB(80, 180, 255)
        else
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(80, 255, 80)
        end
        
        highlight.Parent = plr.Character
        table.insert(espObjects, highlight)
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        addESP(plr)
    end
    
    espConnections[1] = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            wait(0.5)
            if settings.espEnabled then addESP(plr) end
        end)
    end)
    
    -- Постоянное обновление
    espConnections[2] = RunService.Stepped:Connect(function()
        if not settings.espEnabled then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local found = false
                for _, obj in pairs(espObjects) do
                    if obj and obj.Adornee == plr.Character then
                        found = true
                        local role = getPlayerRole(plr)
                        if role == "Murderer" then
                            obj.FillColor = Color3.fromRGB(255, 0, 0)
                            obj.OutlineColor = Color3.fromRGB(255, 80, 80)
                        elseif role == "Sheriff" then
                            obj.FillColor = Color3.fromRGB(0, 120, 255)
                            obj.OutlineColor = Color3.fromRGB(80, 180, 255)
                        else
                            obj.FillColor = Color3.fromRGB(0, 255, 0)
                            obj.OutlineColor = Color3.fromRGB(80, 255, 80)
                        end
                        break
                    end
                end
                if not found then
                    addESP(plr)
                end
            end
        end
    end)
end

function stopESP()
    for _, obj in pairs(espObjects) do
        if obj then obj:Destroy() end
    end
    espObjects = {}
    for _, conn in pairs(espConnections) do
        if conn then conn:Disconnect() end
    end
    espConnections = {}
end

-- ===== ESP ПИСТОЛЕТА =====
local gunObjects = {}
local gunConnection = nil

function startGunESP()
    gunConnection = RunService.Stepped:Connect(function()
        if not settings.gunESP then return end
        
        -- Удаляем старые
        for _, obj in pairs(gunObjects) do
            if obj then obj:Destroy() end
        end
        gunObjects = {}
        
        -- Ищем пистолеты
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") and (obj.Name:lower():find("gun") or obj.Name:lower():find("pistol")) then
                if obj:FindFirstChild("Handle") then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = obj
                    highlight.FillColor = Color3.fromRGB(255, 200, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency = 0.2
                    highlight.Parent = obj
                    table.insert(gunObjects, highlight)
                end
            end
        end
    end)
end

function stopGunESP()
    for _, obj in pairs(gunObjects) do
        if obj then obj:Destroy() end
    end
    gunObjects = {}
    if gunConnection then
        gunConnection:Disconnect()
        gunConnection = nil
    end
end

-- ===== AIMBOT (МАКСИМАЛЬНО РАБОЧИЙ) =====
local aimConnection = nil

function startAimbot()
    aimConnection = RunService.RenderStepped:Connect(function()
        if not settings.aimEnabled then
            if aimConnection then aimConnection:Disconnect() end
            return
        end
        
        local target = nil
        local minDist = 1000
        local playerRole = settings.role
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local dist = (head.Position - hrp.Position).Magnitude
                local targetRole = getPlayerRole(plr)
                
                if playerRole == "Murderer" then
                    if (targetRole == "Sheriff" or targetRole == "Innocent") and dist < minDist then
                        minDist = dist
                        target = head
                    end
                elseif playerRole == "Sheriff" then
                    if targetRole == "Murderer" and dist < minDist then
                        minDist = dist
                        target = head
                    end
                end
            end
        end
        
        if target then
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Position)
        end
    end)
end

function stopAimbot()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
end

-- ===== SPEED =====
local speedConnection = nil

function startSpeed()
    speedConnection = RunService.RenderStepped:Connect(function()
        if not settings.speedEnabled or not hrp then
            if speedConnection then speedConnection:Disconnect() end
            return
        end
        
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.Velocity = moveDir * settings.speedValue
        end
    end)
end

function stopSpeed()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
end

-- ===== ЗАПУСК =====
updateRole()

print("✦ RYZEN MM2 ULTIMATE v6 ЗАГРУЖЕН ✦")
print("Нажми на иконку ★ чтобы открыть меню")
print("ESP показывает ВСЕ роли через стены!")
