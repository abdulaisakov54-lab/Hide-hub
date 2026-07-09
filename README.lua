-- Ryzen Final.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Настройки
local Speed = 50
local ESP_Color = Color3.fromRGB(255, 50, 50)

-- Fly
local flyEnabled = false
local bodyGyro = Instance.new("BodyGyro")
local bodyVelocity = Instance.new("BodyVelocity")
bodyGyro.P = 9e4
bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
bodyGyro.CFrame = Root.CFrame
bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)
bodyGyro.Parent = Root
bodyVelocity.Parent = Root

UserInput.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.F then
        flyEnabled = not flyEnabled
        if flyEnabled then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if flyEnabled then
        local moveVector = Vector3.new(0, 0, 0)
        if UserInput:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector * Speed end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector * Speed end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector * Speed end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector * Speed end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, Speed, 0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, Speed, 0) end
        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = Camera.CFrame
    end
end)

-- Noclip
local noclipEnabled = false
UserInput.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.N then
        noclipEnabled = not noclipEnabled
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
end)

-- Wallhop
UserInput.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.W and UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then
        Root.CFrame = Root.CFrame + Root.CFrame.LookVector * 25
    end
end)

-- ESP
local espEnabled = false
local espObjects = {}
UserInput.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.E then
        espEnabled = not espEnabled
        if espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = player.Character
                    highlight.FillColor = ESP_Color
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.Parent = player.Character
                    table.insert(espObjects, highlight)
                end
            end
        else
            for _, obj in ipairs(espObjects) do
                obj:Destroy()
            end
            espObjects = {}
        end
    end
end)

-- Уведомление
LocalPlayer.PlayerGui:SetCore("SendNotification", {
    Title = "Ryzen Final",
    Text = "F=Fly | N=Noclip | E=ESP | Shift+W=Wallhop",
    Duration = 10
})

-- Автоматическое обновление ESP при появлении новых игроков
Players.PlayerAdded:Connect(function(player)
    if espEnabled then
        player.CharacterAdded:Connect(function(char)
            local highlight = Instance.new("Highlight")
            highlight.Adornee = char
            highlight.FillColor = ESP_Color
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.Parent = char
            table.insert(espObjects, highlight)
        end)
    end
end)
