local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- Limpar UI Antiga para evitar sobreposição
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "Rayfield" then v:Destroy() end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🍋 Lemon Hub v4.9 | Ultimate Fix",
   LoadingTitle = "A carregar funções críticas...",
})

_G.AutoFarm = false
_G.TweenSpeed = 300
_G.Aimbot = false
_G.ESP = false
_G.SkillZ = false
_G.SkillX = false
_G.SkillC = false
_G.SkillV = false

-- Função de Tween Corrigida
local function ToTween(TargetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not TargetCFrame then return end
        
        local distance = (root.Position - TargetCFrame.Position).Magnitude
        if distance < 8 then root.CFrame = TargetCFrame return end
        
        local tween = TweenService:Create(root, TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
        tween:Play()
        
        local nc = RunService.Stepped:Connect(function()
            for _, v in pairs(char:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end
            root.Velocity = Vector3.new(0,0,0)
        end)
        
        tween.Completed:Wait()
        nc:Disconnect()
    end)
end

-- Função de Skill (Fixa)
local function CastSkill(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, key, false, game)
end

-- Sistema de Visuais (ESP/Aimbot)
local function CreateBillboard(player)
    local char = player.Character
    if char and not char:FindFirstChild("LemonUI") then
        local bgu = Instance.new("BillboardGui", char)
        bgu.Name = "LemonUI"
        bgu.AlwaysOnTop = true
        bgu.ExtentsOffset = Vector3.new(0, 3, 0)
        bgu.Size = UDim2.new(0, 200, 0, 50)

        local text = Instance.new("TextLabel", bgu)
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1, 0, 1, 0)
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0
        text.TextSize = 14
        text.Text = player.Name
        
        task.spawn(function()
            while bgu.Parent do
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                text.Text = player.Name .. " | " .. math.floor(dist) .. "m"
                task.wait(0.1)
            end
        end)
    end
end
task.spawn(function()
    while task.wait(0.5) do
        if _G.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character:FindFirstChild("LemonHighlight") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "LemonHighlight"
                        hl.FillColor = Color3.fromRGB(255, 255, 0)
                        hl.OutlineTransparency = 0
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("LemonHighlight") then
                    p.Character.LemonHighlight:Destroy()
                end
            end
        end
    end
end)

-- Loop de Farm por Proximidade
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local target = nil
            local dist = math.huge

            -- Procura em Enemies e NPCs (cobre todas as versões do jogo)
            local folders = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("NPCs"), workspace}
            for _, folder in pairs(folders) do
                if folder then
                    for _, enemy in pairs(folder:GetChildren()) do
                        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                            local d = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                            if d < dist and d < 2000 then -- Só foca no que está perto/na mesma ilha
                                dist = d
                                target = enemy
                            end
                        end
                    end
                end
            end

            if target then
                -- Movimenta
                ToTween(target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0))

                repeat
                    task.wait()
                    if not _G.AutoFarm or not target.Parent or target.Humanoid.Health <= 0 then break end
                    
                    root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    
                    -- Ataque e Equipar
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    
                    if not char:FindFirstChildOfClass("Tool") then
                        local tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                        if tool then char.Humanoid:EquipTool(tool) end
                    end

                    -- Skills
                    if _G.SkillZ then CastSkill(Enum.KeyCode.Z) end
                    if _G.SkillX then CastSkill(Enum.KeyCode.X) end
                    if _G.SkillC then CastSkill(Enum.KeyCode.C) end
                    if _G.SkillV then CastSkill(Enum.KeyCode.V) end
                    
                until target.Humanoid.Health <= 0 or not _G.AutoFarm
            end
        end
    end
end)

-- Interface
local Tab1 = Window:CreateTab("Principal", "bolt")
Tab1:CreateToggle({
   Name = "Matar NPCs Próximos",
   CurrentValue = false,
   Callback = function(v) _G.AutoFarm = v end,
})

local Tab2 = Window:CreateTab("Auto Skills", "zap")
Tab2:CreateToggle({Name = "Usar Z", CurrentValue = false, Callback = function(v) _G.SkillZ = v end})
Tab2:CreateToggle({Name = "Usar X", CurrentValue = false, Callback = function(v) _G.SkillX = v end})
Tab2:CreateToggle({Name = "Usar C", CurrentValue = false, Callback = function(v) _G.SkillC = v end})
Tab2:CreateToggle({Name = "Usar V", CurrentValue = false, Callback = function(v) _G.SkillV = v end})

local Tab3 = Window:CreateTab("PVP & Visual", "eye")
Tab3:CreateToggle({Name = "ESP Players", CurrentValue = false, Callback = function(v) _G.ESP = v end})
Tab3:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) _G.Aimbot = v end})

local Tab4 = Window:CreateTab("Config", "settings")
Tab4:CreateSlider({
   Name = "Velocidade Tween",
   Range = {100, 500},
   Increment = 10,
   CurrentValue = 300,
   Callback = function(v) _G.TweenSpeed = v end,
})
