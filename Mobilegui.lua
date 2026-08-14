--// Mobile Cheat GUI | Fly + Noclip + ESP + Aim
--// Совместим с мобильными устройствами (Touch GUI)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileCheat"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 260)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "📱 Mobile Cheat"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local Corner2 = Instance.new("UICorner", Title)
Corner2.CornerRadius = UDim.new(0, 8)

--// Button Creator
local function createButton(name, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 45)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.AutoButtonColor = true
    btn.Parent = MainFrame
    
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    
    return btn
end

local flyBtn = createButton("✈️ Fly", 40, Color3.fromRGB(0, 120, 200))
local noclipBtn = createButton("👻 Noclip", 90, Color3.fromRGB(120, 0, 200))
local espBtn = createButton("👁️ ESP", 140, Color3.fromRGB(200, 80, 0))
local aimBtn = createButton("🎯 Aim", 190, Color3.fromRGB(200, 0, 0))

--// FLY SYSTEM
local flying = false
local flySpeed = 50
local flyConn

local function toggleFly()
    flying = not flying
    flyBtn.Text = flying and "✈️ Fly: ON" or "✈️ Fly: OFF"
    flyBtn.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 120, 200)
    
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    if flying then
        hum.PlatformStand = true
        flyConn = RunService.RenderStepped:Connect(function()
            if not flying then return end
            local dir = Vector3.new()
            local cam = camera.CFrame
            
            -- Mobile thumbstick + jump
            if hum.MoveDirection.Magnitude > 0 then
                dir = hum.MoveDirection
            end
            
            -- Для мобильных: проверяем джойстик
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                dir = dir - Vector3.new(0, 1, 0)
            end
            
            if dir.Magnitude > 0 then
                hrp.Velocity = dir.Unit * flySpeed
            else
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.LookVector)
        end)
    else
        hum.PlatformStand = false
        if flyConn then flyConn:Disconnect() end
    end
end

flyBtn.MouseButton1Click:Connect(toggleFly)

--// NOCLIP SYSTEM
local noclip = false
local noclipConn

local function toggleNoclip()
    noclip = not noclip
    noclipBtn.Text = noclip and "👻 Noclip: ON" or "👻 Noclip: OFF"
    noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(120, 0, 200)
    
    if noclip then
        noclipConn = RunService.Stepped:Connect(function()
            if not noclip then return end
            local char = player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

noclipBtn.MouseButton1Click:Connect(toggleNoclip)

--// ESP SYSTEM
local espEnabled = false
local espObjects = {}

local function createESP(target)
    if target == player then return end
    local char = target.Character
    if not char then return end
    
    -- Highlight (если поддерживается)
    local highlight = char:FindFirstChild("ESP_Highlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = char
    end
    
    -- Billboard (имя + дистанция)
    local head = char:FindFirstChild("Head")
    if head and not head:FindFirstChild("ESP_Billboard") then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_Billboard"
        bb.Size = UDim2.new(0, 100, 0, 40)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.Parent = head
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Parent = bb
        
        espObjects[target] = {highlight = highlight, bill = bb, label = label}
    end
end

local function updateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            createESP(plr)
            local data = espObjects[plr]
            if data and data.label then
                local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                local theirHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                if myHRP and theirHRP then
                    local dist = math.floor((myHRP.Position - theirHRP.Position).Magnitude)
                    data.label.Text = plr.Name .. "\n[" .. dist .. "m]"
                end
            end
        end
    end
end

local espConn

local function toggleESP()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "👁️ ESP: ON" or "👁️ ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 80, 0)
    
    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            createESP(plr)
        end
        espConn = RunService.RenderStepped:Connect(updateESP)
    else
        if espConn then espConn:Disconnect() end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                local h = plr.Character:FindFirstChild("ESP_Highlight")
                if h then h:Destroy() end
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local b = head:FindFirstChild("ESP_Billboard")
                    if b then b:Destroy() end
                end
            end
        end
        espObjects = {}
    end
end

espBtn.MouseButton1Click:Connect(toggleESP)

Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        plr.CharacterAdded:Wait()
        createESP(plr)
    end
end)

--// AIMBOT SYSTEM
local aimEnabled = false
local aimRange = 200
local aimPart = "Head" -- или "Torso"/"HumanoidRootPart"

local function getClosestPlayer()
    local closest = nil
    local shortestDist = aimRange
    local myChar = player.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild(aimPart) then
            local part = plr.Character[aimPart]
            local pos, onScreen = camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < shortestDist then
                    -- Проверка на стену (опционально, убери if для wallbang)
                    local ray = Workspace:Raycast(camera.CFrame.Position, (part.Position - camera.CFrame.Position).Unit * 500)
                    if not ray or ray.Instance:IsDescendantOf(plr.Character) then
                        shortestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

local aimConn

local function toggleAim()
    aimEnabled = not aimEnabled
    aimBtn.Text = aimEnabled and "🎯 Aim: ON" or "🎯 Aim: OFF"
    aimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 0)
    
    if aimEnabled then
        aimConn = RunService.RenderStepped:Connect(function()
            if not aimEnabled then return end
            local target = getClosestPlayer()
            if target then
                camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
            end
        end)
    else
        if aimConn then aimConn:Disconnect() end
    end
end

aimBtn.MouseButton1Click:Connect(toggleAim)

--// Respawn Handler
player.CharacterAdded:Connect(function()
    wait(1)
    if flying then toggleFly() wait() toggleFly() end
    if noclip then toggleNoclip() wait() toggleNoclip() end
end)

print("✅ Mobile Cheat Loaded | Fly + Noclip + ESP + Aim")
