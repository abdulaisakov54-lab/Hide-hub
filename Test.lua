-- Ryzen System :: Roblox Utility Script
-- Активация: нажмите F1 для открытия GUI

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera

-- Переменные состояния
local flyEnabled = false
local noclipEnabled = false
local espEnabled = false
local aimbotEnabled = false
local speed = 50
local bodyVelocity = nil

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.Visible = false
frame.Parent = screenGui

local toggleFly = Instance.new("TextButton")
toggleFly.Size = UDim2.new(0, 180, 0, 30)
toggleFly.Position = UDim2.new(0, 10, 0, 10)
toggleFly.Text = "Fly (OFF)"
toggleFly.Parent = frame

local toggleNoclip = Instance.new("TextButton")
toggleNoclip.Size = UDim2.new(0, 180, 0, 30)
toggleNoclip.Position = UDim2.new(0, 10, 0, 50)
toggleNoclip.Text = "Noclip (OFF)"
toggleNoclip.Parent = frame

local toggleESP = Instance.new("TextButton")
toggleESP.Size = UDim2.new(0, 180, 0, 30)
toggleESP.Position = UDim2.new(0, 10, 0, 90)
toggleESP.Text = "ESP (OFF)"
toggleESP.Parent = frame

local toggleAimbot = Instance.new("TextButton")
toggleAimbot.Size = UDim2.new(0, 180, 0, 30)
toggleAimbot.Position = UDim2.new(0, 10, 0, 130)
toggleAimbot.Text = "Aimbot (OFF)"
toggleAimbot.Parent = frame

-- Fly
toggleFly.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    toggleFly.Text = flyEnabled and "Fly (ON)" or "Fly (OFF)"
    if flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
        bodyVelocity.Parent = character.HumanoidRootPart
        game:GetService("RunService").RenderStepped:Connect(function()
            if flyEnabled and character and character.HumanoidRootPart then
                local moveDir = Vector3.new(0, 0, 0)
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                bodyVelocity.Velocity = moveDir.Unit * speed
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame
            end
        end)
    else
        if bodyVelocity then bodyVelocity:Destroy() end
    end
end)

-- Noclip
toggleNoclip.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    toggleNoclip.Text = noclipEnabled and "Noclip (ON)" or "Noclip (OFF)"
    game:GetService("RunService").Stepped:Connect(function()
        if noclipEnabled and character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- ESP
local espObjects = {}
toggleESP.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleESP.Text = espEnabled and "ESP (ON)" or "ESP (OFF)"
    if espEnabled then
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = plr.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = plr.Character
                table.insert(espObjects, highlight)
            end
        end
        game.Players.PlayerAdded:Connect(function(newPlr)
            if espEnabled and newPlr ~= player then
                newPlr.CharacterAdded:Connect(function(char)
                    local h = Instance.new("Highlight")
                    h.Adornee = char
                    h.FillColor = Color3.fromRGB(255, 0, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                    h.Parent = char
                    table.insert(espObjects, h)
                end)
            end
        end)
    else
        for _, obj in pairs(espObjects) do obj:Destroy() end
        espObjects = {}
    end
end)

-- Aimbot (наводит на ближайшего игрока)
toggleAimbot.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleAimbot.Text = aimbotEnabled and "Aimbot (ON)" or "Aimbot (OFF)"
    game:GetService("RunService").RenderStepped:Connect(function()
        if aimbotEnabled then
            local target = nil
            local minDist = math.huge
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = plr
                    end
                end
            end
            if target and target.Character then
                cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end)
end)

-- Открытие GUI по F1
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F1 then
        frame.Visible = not frame.Visible
    end
end)

print("Ryzen System Loaded. Press F1 to toggle menu.")
