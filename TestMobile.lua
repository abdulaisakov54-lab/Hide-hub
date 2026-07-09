-- Ryzen Mobile Fly + Noclip + ESP + Aimbot
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera

local fly = false
local noclip = false
local esp = false
local aim = false
local speed = 40

-- GUI
local scr = Instance.new("ScreenGui")
scr.Parent = player.PlayerGui

local btnFly = Instance.new("TextButton")
btnFly.Size = UDim2.new(0, 80, 0, 40)
btnFly.Position = UDim2.new(0, 10, 0, 100)
btnFly.Text = "Fly"
btnFly.Parent = scr

local btnNoclip = Instance.new("TextButton")
btnNoclip.Size = UDim2.new(0, 80, 0, 40)
btnNoclip.Position = UDim2.new(0, 100, 0, 100)
btnNoclip.Text = "Noclip"
btnNoclip.Parent = scr

local btnESP = Instance.new("TextButton")
btnESP.Size = UDim2.new(0, 80, 0, 40)
btnESP.Position = UDim2.new(0, 10, 0, 150)
btnESP.Text = "ESP"
btnESP.Parent = scr

local btnAim = Instance.new("TextButton")
btnAim.Size = UDim2.new(0, 80, 0, 40)
btnAim.Position = UDim2.new(0, 100, 0, 150)
btnAim.Text = "Aim"
btnAim.Parent = scr

local bv

btnFly.MouseButton1Click:Connect(function()
    fly = not fly
    btnFly.Text = fly and "Fly ON" or "Fly OFF"
    if fly then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1,1,1)*1e5
        bv.Parent = hrp
        game:GetService("RunService").RenderStepped:Connect(function()
            if fly and hrp then
                local fwd = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                local up = Vector3.new(0,1,0)
                -- Управление через виртуальный джойстик (направление взгляда)
                local move = Vector3.new(0,0,0)
                -- Пример: двигаемся туда, куда смотрит камера + кнопка вверх/вниз
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
                bv.Velocity = move.Unit * speed
            end
        end)
    else
        if bv then bv:Destroy() end
    end
end)

btnNoclip.MouseButton1Click:Connect(function()
    noclip = not noclip
    btnNoclip.Text = noclip and "Noclip ON" or "Noclip OFF"
    game:GetService("RunService").Stepped:Connect(function()
        if noclip and char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

-- ESP и Aimbot аналогичны предыдущему скрипту (адаптация под мобильные кнопки)
btnESP.MouseButton1Click:Connect(function()
    esp = not esp
    btnESP.Text = esp and "ESP ON" or "ESP OFF"
    -- код ESP (как в первом скрипте)
end)

btnAim.MouseButton1Click:Connect(function()
    aim = not aim
    btnAim.Text = aim and "Aim ON" or "Aim OFF"
    -- код аима (как в первом скрипте)
end)
