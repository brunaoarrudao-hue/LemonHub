local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- Limpar UI Antiga
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "Rayfield" then v:Destroy() end
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🍋 Lemon Hub v4.8 | Combat Mode",
   LoadingTitle = "Carregando Módulos de Ataque...",
})

-- Variáveis Globais
_G.AutoFarm = false
_G.TweenSpeed = 300
_G.Aimbot = false
_G.ESP = false
_G.SkillZ = false
_G.SkillX = false
_G.SkillC = false
_G.SkillV = false

-- Função de Movimentação (Tween)
local function ToTween(TargetCFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not TargetCFrame then return end
    
    local distance = (root.Position - TargetCFrame.Position).Magnitude
    if distance < 5 then root.CFrame = TargetCFrame return end
    
    local tween = TweenService:Create(root, TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    tween:Play()
    
    -- NoClip durante o Tween
    local nc = RunService.Stepped:Connect(function()
        for _, v in pairs(char:GetDescendants()) do 
            if v:IsA("BasePart") then v.CanCollide = false end 
        end
        root.Velocity = Vector3.new(0,0,0)
    end)
    
    tween.Completed:Wait()
    nc:Disconnect()
end

-- Função para soltar Skill (Sem Segurar)
local function UseSkill(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, key, false, game)
end

-- Loop de Visuais (ESP e Aimbot)
task.spawn(function()
    while task.wait() do
        -- ESP
        if _G.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("LemonESP") then
                        local highlight = Instance.new("Highlight", p.Character)
                        highlight.Name = "LemonESP"
                        highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("LemonESP") then 
                    p.Character.LemonESP:Destroy() 
                end
            end
        end

        -- AIMBOT
        if _G.Aimbot then
            local target, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d target = p end
                end
            end
            if target then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

-- Loop de Farm (Matar Próximos)
task.spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                -- Procura o NPC mais próximo no workspace
                local targetNPC = nil
                local shortestDist = math.huge

                for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
                        local d = (root.Position - enemy.HumanoidRootPart.Position).Magnitude
                        if d < shortestDist then
                            shortestDist = d
                            targetNPC = enemy
                        end
                    end
                end

                if targetNPC then
                    -- Vai até o NPC usando Tween
                    ToTween(targetNPC.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))

                    -- Ataca enquanto o NPC estiver vivo
                    repeat
                        task.wait()
                        if not _G.AutoFarm then break end
                        
                        root.CFrame = targetNPC.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- Clique de Ataque
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        
                        -- Equipar Arma
                        if not char:FindFirstChildOfClass("Tool") then
                            local t = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                            if t then char.Humanoid:EquipTool(t) end
                        end

                        -- Usar Skills Selecionadas
                        if _G.SkillZ then UseSkill(Enum.KeyCode.Z) end
                        if _G.SkillX then UseSkill(Enum.KeyCode.X) end
                        if _G.SkillC then UseSkill(Enum.KeyCode.C) end
                        if _G.SkillV then UseSkill(Enum.KeyCode.V) end

                    until not targetNPC or targetNPC.Humanoid.Health <= 0 or not _G.AutoFarm
                end
            end)
        end
    end
end)

-- Interface Tabs
local MainTab = Window:CreateTab("Ataque", "crosshair")
MainTab:CreateToggle({
   Name = "Matar NPCs Próximos (Tween)",
   CurrentValue = false,
   Callback = function(v) _G.AutoFarm = v end,
})

local SkillTab = Window:CreateTab("Skills", "zap")
SkillTab:CreateToggle({Name = "Ativar Z", CurrentValue = false, Callback = function(v) _G.SkillZ = v end})
SkillTab:CreateToggle({Name = "Ativar X", CurrentValue = false, Callback = function(v) _G.SkillX = v end})
SkillTab:CreateToggle({Name = "Ativar C", CurrentValue = false, Callback = function(v) _G.SkillC = v end})
SkillTab:CreateToggle({Name = "Ativar V", CurrentValue = false, Callback = function(v) _G.SkillV = v end})

local VisualTab = Window:CreateTab("Combate", "eye")
VisualTab:CreateToggle({Name = "ESP Players", CurrentValue = false, Callback = function(v) _G.ESP = v end})
VisualTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) _G.Aimbot = v end})

local ConfigTab = Window:CreateTab("Ajustes", "settings")
ConfigTab:CreateSlider({
   Name = "Velocidade do Tween",
   Range = {100, 500},
   Increment = 10,
   CurrentValue = 300,
   Callback = function(v) _G.TweenSpeed = v end,
})
